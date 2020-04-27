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

uniform vec2 uCenter;
uniform float uDem;

in vec2 vTexcoord;
uniform sampler2D uSample;

out vec4 rtFragColor;

void main()
{
	// Normalized pixel coordinates (from 0 to 1)
	vec2 UV = vTexcoord;

	// Where the black hole will be positioned in UV coords.
	vec2 center = uCenter;

	// Defines how wide the warping effect will be.
	float warpRadius = 0.1;

	// Finds the position of the fragment in relation to the black hole.
	vec2 positionRelativeToBlackHole = center - UV;
	positionRelativeToBlackHole.x *= uDem;

	// Calculate distance from the center of the black hole.
	float distanceToCenter = length(positionRelativeToBlackHole);
	
	// Calculate the vector pointing towards the black hole with a length of rad.
	vec2 vectorPointingToCenter = normalize(positionRelativeToBlackHole) * warpRadius * warpRadius;

	// Create a new UV coordinate system by adding the old UV and the warp offset.
	vec2 warpedUV = UV + (vectorPointingToCenter / distanceToCenter);

	// Sampling using our new UV coordinates.
	rtFragColor = texture2D(uSample, warpedUV);

	// Defining black hole specific warping variables.
	float blackHoleSharpness = -15.0;
	float brightness = 1.0;
	float schwarzschildRadius = 1.1;
	float brightnessMax = 1.0;
	float postWarpPosition = distanceToCenter / (warpRadius * schwarzschildRadius);

	float olda = rtFragColor.a;

	// The actual black hole warping effect:
	// 1. Mixes together the sharpness, brightness, and the fragment's position after warping
	// 2. Take the minimum of that value and a max brightness value, to prevent the fragments outside
	//    of the black hole from being too bright.
	float blackHoleDarkness = min(mix(blackHoleSharpness, brightness, postWarpPosition), brightnessMax);
	
	// Makes the black hole within the schwarzschild radius appear opaque.
	rtFragColor *= blackHoleDarkness;
	rtFragColor.a += 1 - blackHoleDarkness;
	// Makes the black hole within the schwarzschild radius appear opaque.
	rtFragColor.a+= 1 - blackHoleDarkness;
}
