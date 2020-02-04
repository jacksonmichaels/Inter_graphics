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
	
	drawTexture_coordManip_fs4x.glsl
	Draw texture sample after manipulating texcoord.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare inbound varying for texture coordinate
//	3) modify texture coordinate in some creative way
//	4) sample texture using modified texture coordinate
//	5) assign sample to output color

uniform vec4 uTex;
uniform double uTime;

in vec2 vTexcoord;
uniform sampler2D uSample;

out vec4 rtFragColor;

vec2 modifyTexCoord(vec2 texcoord)
{

	// Using the calculation for a sin wave,
	// we can create a modulating wave like effect
	// when the sin of time is used in place of time.
	float amplitude = 0.1;
	float angularFrequency = 10.0;
	float phase = 0;
	float sinFloatTime = sin(float(uTime));

	// Setting a new variable for the wavey effect for clarification purposes.
	vec2 wavyTexcoord;

	// The y coord will never change, 
	// as we are only changing the x coordinate for the sin wave effect.
	wavyTexcoord.y = texcoord.y;

	// We start by sampling the existing x coordinate for our baseline.
	// then, we add the results of the sin equation to it, with two changes;
	// we are also multiplying the y location with the time and angular frequency,
	// to vary each individual pixel, rather than shifting the whole thing along the x axis.
	wavyTexcoord.x = texcoord.x + amplitude * sin((angularFrequency * texcoord.y * sinFloatTime) + phase);

	return wavyTexcoord;
}

void main()
{
	vec2 newTexcoord = modifyTexCoord(vTexcoord);

	// Samples the texture based on the new texture coordinates, 
	// and sets that to the output color.
	rtFragColor = texture2D(uSample, newTexcoord);

}
