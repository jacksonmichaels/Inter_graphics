/*
	Copyright 2011-2020 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawTexture_blurGaussian_fs4x.glsl
	Draw texture with Gaussian blurring.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) declare uniforms for pixel size and sampling axis
//	2) implement Gaussian blur function using a 1D kernel (hint: Pascal's triangle)
//	3) sample texture using Gaussian blur function and output result

uniform sampler2D uImage00;
uniform vec2 uAxis;
uniform vec2 uSize;

in vec4 passTexcoord;
in float samplingFBOwidth;
in float samplingFBOheight;


layout (location = 0) out vec4 rtFragColor;


vec4 blurGaussian0(in sampler2D img, in vec2 center, in vec2 dir)
{
	return texture(img, center);
}

vec4 blurGaussian1(in sampler2D img, in vec2 center, in vec2 dir)
{
	vec4 c = vec4(0.0);
	c += texture(img, center - dir/2);
	c += texture(img, center + dir/2);
	return c / 2;
}

vec4 blurGaussian2(in sampler2D img, in vec2 center, in vec2 dir)
{
	vec4 c = vec4(0.0);
	c += texture(img, center) * 2;
	c += texture(img, center - dir);
	c += texture(img, center + dir);
	return c / 4;
}

vec4 blurGaussian4(in sampler2D img, in vec2 center, in vec2 dir)
{
	vec4 c = vec4(0.0);
	c += texture(img, center - dir * 2);
	c += texture(img, center - dir) * 4;
	c += texture(img, center) * 6;
	c += texture(img, center + dir) * 4;
	c += texture(img, center + dir * 2);
	return c / 16;
}

vec4 blurGaussian6(in sampler2D img, in vec2 center, in vec2 dir)
{
	vec4 c = vec4(0.0);
	c += texture(img, center - dir * 3);
	c += texture(img, center - dir * 2) * 6;
	c += texture(img, center - dir) * 15;
	c += texture(img, center) * 20;
	c += texture(img, center + dir) * 15;
	c += texture(img, center + dir * 2) * 6;
	c += texture(img, center + dir * 3);
	return c / 64;
}

void main()
{
	//float pixelwidth = 1 / samplingFBOwidth;
	//float pixelheight = 1 / samplingFBOheight;

	// DUMMY OUTPUT: all fragments are OPAQUE MAGENTA
	//vec2(uAxis.x * uSize.x, uAxis.y * uSize.y)
	rtFragColor = blurGaussian4(uImage00, vec2(passTexcoord), vec2(uAxis.x * uSize.x, uAxis.y * uSize.y));
}
