#version 100
#extension GL_OES_fragment_precision_high : enable
#extension GL_OES_depth_texture : enable

precision highp float;

varying vec3 Normal;
varying vec3 Tan;
varying vec3 BiTan;
varying vec2 TexCoord;
varying vec3 ViewPos;


//Input textures
uniform sampler2D ShadowDepthTex;
uniform sampler2D diffuseTex;
uniform sampler2D normalTex;
uniform sampler2D specularTex;


uniform mat4 ViewMatrix;
uniform mat4 InvViewMatrix;
uniform mat4 BiasMatrix;
uniform mat4 ShadowViewProj;

//Directional light
uniform mediump vec3 dirlightDirection; // Light position in world coords.
uniform mediump vec3 dirlightIntensity; // Diffuse intensity
uniform mediump vec3 dirlightColor;

struct Pointlight {
	vec3 Position; // Light position in world coords.
	vec3 Intensity; // Diffuse intensity
	vec3 Color;
	float Range;
}; 
uniform Pointlight pointlights[1];

struct MaterialInfo {
	float Ks;
	float Shininess;
}; MaterialInfo Material;

vec3 NmNormal;

void phongModelDirLight(out vec3 ambient, out vec3 diffuse, out vec3 spec) 
{
    ambient = vec3(0.0);
    diffuse = vec3(0.0);
    spec    = vec3(0.0);

    vec3 lightVec = -normalize(( ViewMatrix*vec4(dirlightDirection, 0.0) ).xyz);

	ambient = dirlightColor * dirlightIntensity.x;

	vec3 E = normalize(ViewPos);

	float diffuseFactor = dot( lightVec, NmNormal );

	if(diffuseFactor > 0.0)
	{
		// For shadows
		vec4 worldPos = InvViewMatrix * vec4(ViewPos, 1.0);
		vec4 shadowCoord = BiasMatrix * ShadowViewProj * worldPos;

		float shadow = 1.0;
		vec4 shadowCoordinateWdivide = shadowCoord / shadowCoord.w;
		shadowCoordinateWdivide.z -= 0.0055;
		float distanceFromLight = texture2D(ShadowDepthTex, shadowCoordinateWdivide.st).z;
		
		if (shadowCoord.w > 0.0)
	 		shadow = distanceFromLight < shadowCoordinateWdivide.z ? 0.0 : 1.0 ;

		// diffuse
		diffuse = diffuseFactor * dirlightColor * dirlightIntensity.y * shadow;

		// specular
		vec3 v = reflect( lightVec, NmNormal );
		float specFactor = pow( max( dot(v, E), 0.0 ), Material.Shininess );
		spec = specFactor * dirlightColor * dirlightIntensity.z * Material.Ks * shadow;        
	}

	return;
}

void phongModel(int index, out vec3 ambient, out vec3 diffuse, out vec3 spec) 
{
	ambient = vec3(0.0);
	diffuse = vec3(0.0);
	spec    = vec3(0.0);

	vec3 thisLightPosition	= pointlights[0].Position;
	vec3 thisLightColor		= pointlights[0].Color;
	vec3 thisLightIntensity = pointlights[0].Intensity;

	vec3 lightVec = (ViewMatrix * vec4(thisLightPosition, 1.0)).xyz - ViewPos;
	float d = length(lightVec);

	if(d > pointlights[0].Range)
	  return;
	lightVec /= d; //normalizing
        
	ambient = thisLightColor * thisLightIntensity.x;
	vec3 E = normalize(ViewPos);
	float diffuseFactor = dot( lightVec, NmNormal );

	if(diffuseFactor > 0.0)
	{
		// diffuse
		diffuse = diffuseFactor * thisLightColor * thisLightIntensity.y;
		// specular
		vec3 v = reflect( lightVec, NmNormal );
		float specFactor = pow( max( dot(v, E), 0.0 ), Material.Shininess );
		spec = specFactor * thisLightColor * thisLightIntensity.z * Material.Ks;          
	}

	float att = 1.0 - pow((d/pointlights[0].Range), 1.0);

	ambient *= att;
	diffuse *= att;
	spec    *= att;

	return;
}


void main() 
{
	vec4 albedo_tex = texture2D( diffuseTex, TexCoord );

	// Normal data
	vec3 normal_map	  = texture2D( normalTex, TexCoord ).rgb;
	normal_map = (normal_map * 2.0) - 1.0;
	mat3 texSpace = mat3(Tan, BiTan, Normal);
	NmNormal = normalize( texSpace * normal_map );

	// Spec data
	vec3 spec_map = texture2D( specularTex, TexCoord ).rgb;
	Material.Ks			= spec_map.x;
	Material.Shininess  = spec_map.y * 254.0 + 1.0;
    
    vec3 ambient = vec3(0.0);
    vec3 diffuse = vec3(0.0);
    vec3 spec 	 = vec3(0.0);
    
	if(length( dirlightIntensity ) > 0.0)
	{
		vec3 a,d,s;

		phongModelDirLight(a, d, s);
		ambient += a;
		diffuse += d;
		spec    += s;
	}

    //för varje ljus-----------
	//if( length(pointlights[0].Intensity) > 0.0)
	//{
	//	vec3 a,d,s;
	//	phongModel(0, a, d, s);
	//	diffuse += d; ambient += a; spec += s;
	//}

	float glow = spec_map.z;
	vec4 glowvec = vec4(vec3(glow), 1.0);
    
    gl_FragColor = vec4(ambient + diffuse, 1.0) * albedo_tex + vec4(spec, 0.0) + glowvec;
	//gl_FragColor = vec4( (inverse(ViewMatrix) * vec4(Normal, 0.0)).xyz, 1.0);
	//gl_FragColor = albedo_tex; //vec4(Normal, 1.0);
    //gl_FragColor = vec4(ambient + diffuse, 1.0) * vec4(0.0, 0.0, 1.0, 1.0) + vec4(spec, 0.0); //albedo_tex;
}




