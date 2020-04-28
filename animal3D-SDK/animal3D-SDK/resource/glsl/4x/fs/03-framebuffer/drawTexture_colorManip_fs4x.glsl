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

uniform vec4 uBHPos;
uniform vec3 uCamPos;
uniform float uBHRad;
uniform double uTime;
uniform mat4x4 uV_inv;

in vec2 vTexcoord;
uniform sampler2D uSample;
uniform sampler2D uTex_sm;

out vec4 rtFragColor;

float calculateSchwarzschildRadius(double mass)
{
	// The Gravitational physics constant.
	float G = 0.0000000000667430;

	// The speed of light.
	float c = 299792458;

	// The equation to calculate the schwarzchild radius.
	return float((2.0 * G * mass) / pow(c, 2.0));
}

float getTimeDilationAmount(float changeInTime, double mass, float distanceToBlackHole)
{
	// Find the distance relative to the black hole's radius.
	float distanceVsBlackHoleRadius = (calculateSchwarzschildRadius(mass) / distanceToBlackHole);
	
	// Calculate time dilation based on the change in time between two
	// reference points, and the gravity amount of the gravity well.
	return changeInTime * sqrt(1.0 - distanceVsBlackHoleRadius);
}

void main()
{
	//declaring constants and other such fields
	vec2 UV = vTexcoord;
	float diskScalar = 3.5;
	int numSteps = 5000;
	float stepSize = 0.00009;
	vec3 bh = uBHPos.xyz;
	float G = 0.0000000000667430;
	float PI = 3.1414;

	//geting default color and new UV for projection
	vec4 col = texture2D(uSample, UV);
	vec2 newUV = UV * 2 - vec2(1, 1);

	//finding the ray direction and origin
	vec4 rayDir4 = (uV_inv * vec4(newUV, 1.f, 1.0f));
	vec3 rayDir = rayDir4.xyz / rayDir4.w;
	rayDir *= stepSize;
	vec3 pos = uCamPos;

	//setting up pre look constant values and memory
	vec2 diskUV = vec2(-1, -1);
	float shade = 0;
	vec3 dir;
	vec3 nextPos;
	float dist;
	float mass = 20000000000.0 * uBHRad;
	float c = 29;
	float grav_base = (4 * G * mass) /( c * c);
	float grav;


	for (int i = 0; i < numSteps; i++)
	{
		//getting gravity and next position
		dir = bh - pos;
		dist = length(dir);
		grav = grav_base/(dist * dist);
		dir = normalize(dir);
		rayDir += dir * grav;
		nextPos = pos + rayDir;

		//if we arent close to the black hole we can go faster
		if (grav < 1)
		{
			i += 5;
		}

		//checking if the ray has hit the black hole
		if (dist < uBHRad * 0.5)
		{
			col = vec4(0,0,0, 1);
			break;
		}
		
		//checking if the ray has hit the disk
		float dist2d = distance(pos.rg, bh.rg);
		if (dist2d < uBHRad * diskScalar)
		{
			if (sign(nextPos.z - bh.z) != sign(pos.z - bh.z))
			{
				shade = 1 - dist2d / (uBHRad * diskScalar);
				vec2 delta = bh.rg - pos.rg;
				float deg = atan(delta.x, delta.y) + PI;
				deg /= 2 * PI;
				deg = mod(deg + (float(uTime) * getTimeDilationAmount(1.0, pow(5.9722, 24), 10.0)) / 5, 1.0);
				diskUV = vec2(deg, shade);

				col = vec4( deg, 0, 1 - deg, 1);
				i = numSteps;
				break;
			}
							
		}
		
		//move position of ray
		pos = nextPos;		
	}

	//find out if we hit the disk, if so sample from the texture
	if (diskUV.x != -1)
	{
		col = texture2D(uTex_sm, diskUV);
	}
	rtFragColor = col;
}
