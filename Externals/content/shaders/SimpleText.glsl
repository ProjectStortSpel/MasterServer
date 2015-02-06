#version 440 core

// UNIFORMS
layout (local_size_x = 8, local_size_y = 16) in;

// output 
layout (rgba8, binding = 1) uniform image2D text_image;

// output 
layout (rgba32f, binding = 5) uniform image2D output_image;

layout (std430, binding = 4) buffer debugtext { int letter []; };

// uniforms
uniform vec4 text_color;

void main(void)
{
	vec4 color = vec4(0.1, 0.3, 0.4, 0);//imageLoad(output_image, ivec2(gl_GlobalInvocationID.xy));
	uint x = gl_WorkGroupID.x;
	uint y = (gl_NumWorkGroups.y-1)-gl_WorkGroupID.y;

	uint xy = x + y * gl_NumWorkGroups.x;

	int bokstav = letter[xy] - 32;
	
	ivec2 texCoord = ivec2(
		mod(bokstav, 20) * 8 + gl_LocalInvocationID.x,
		int(bokstav * 0.05f) * 16 + 16 - gl_LocalInvocationID.y
	);
	
	//vec4 something = vec4(float(texCoord.x)/159,float(texCoord.y)/59,0,1);

	vec4 something = imageLoad(text_image, texCoord);
	something *= text_color;

	if ( something.w > 0 )
	{
		imageStore(
			output_image,
			ivec2(gl_GlobalInvocationID.xy),
			something
		);
	}
}