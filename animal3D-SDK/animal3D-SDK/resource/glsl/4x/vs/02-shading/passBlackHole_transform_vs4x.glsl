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
	
	passBlackHole_transform_vs4x.glsl
	Vertex shader that passes texture coordinate. Outputs transformed position 
		attribute and atlas transformed texture coordinate attribute.
*/

#version 410

layout (location = 0) in vec4 aPosition;
layout (location = 8) in vec4 aTexCoord;

uniform mat4 uAtlas;
uniform double uTime;

out vec2 vTexcoord;

// A normal position coordinate is passed in,
// and the position translated to the orbit is passed out.
float getOrbitCoord(float coord)
{
	// Time converted from a double to a float.
	float floatTime = float(uTime);

	// The speed that the orbit travels around the center.
	float orbitSpeed = 1.0;

	// The depth that the new orbit will travel to.
	float orbitalDepth = 10.0;

	// The final orbital coordinate to be offset with the original coordinate.
	float orbitalCoordinate = floatTime * orbitSpeed;

	// The final offset to be combined with the original coordinate.
	float orbitOffset = sin(coord * orbitalDepth + orbitalCoordinate);

	// Return the offset coordinate.
	return coord + (coord * orbitOffset);
}

void main()
{
	// Creating a new position value that we can modify.
	vec4 orbitalPosition = aPosition;

	// Get the new orbital coordinates.
	//orbitalPosition.x = getOrbitCoord(orbitalPosition.x);
	//orbitalPosition.y = getOrbitCoord(orbitalPosition.y);

	// Output the position with the new orbital coordinates.
	gl_Position = orbitalPosition;
	vTexcoord = vec2(uAtlas * aTexCoord);
}