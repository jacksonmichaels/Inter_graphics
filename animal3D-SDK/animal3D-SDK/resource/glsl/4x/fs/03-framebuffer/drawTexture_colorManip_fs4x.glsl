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
	
	drawTexture_colorManip_fs4x.glsl
	Draw texture sample and manipulate result.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare inbound varying for texture coordinate
//	3) sample texture using texture coordinate
//	4) modify sample in some creative way
//	5) assign modified sample to output color

uniform vec4 uTex;
uniform vec2 uCenter;
uniform float uDem;
uniform double uTime;

in vec2 vTexcoord;
uniform sampler2D uSample;

out vec4 rtFragColor;

vec4 modifySample(vec4 inputTexture)
{

	// We are taking the absolute value of the sin of float time
	// in order to avoid negative color values. A float conversion
	// is necessary since uTime starts out as a double, which we
	// cannot use in a vec4.
	float absSinFloatTime = abs(sin(float(uTime)));

	// This is the new color filter to use,
	// which uses a modulating green and inverse modulating red.
	vec4 modulatingRedAndGreen = vec4(1.0 - absSinFloatTime, absSinFloatTime, 0.0, 1.0);

	// Applies the filter to the sample, returning it.
	return (inputTexture * modulatingRedAndGreen);
}

void main()
{

	// Normalized pixel coordinates (from 0 to 1)
	vec2 uv = vTexcoord;
	vec2 center = uCenter;
	float rad = 0.1;
	//float aspect = iResolution.x / iResolution.y;

	vec2 dir = center - uv;
	dir.x *= uDem;
	float len = length(dir);
	vec2 new_dir = normalize(dir) * rad;
	vec2 new_uv = uv + new_dir * rad / len;



	rtFragColor = texture2D(uSample, new_uv);
	float olda = rtFragColor.a;

	rtFragColor *= min(mix(-15.0, 1.0, len / (rad * 1.1)), 1.0);

	rtFragColor.a = 1;



	// Returns a modified sample of the input texture.
}
