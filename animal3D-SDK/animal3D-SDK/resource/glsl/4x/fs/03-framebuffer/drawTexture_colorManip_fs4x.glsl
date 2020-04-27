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
uniform float uDiskRad;
uniform double uTime;
uniform mat4x4 uV_inv;

in vec2 vTexcoord;
uniform sampler2D uSample;
uniform sampler2D uTex_sm;

out vec4 rtFragColor;

void main()
{
	// Normalized pixel coordinates (from 0 to 1)
	vec2 UV = vTexcoord;
	float diskScalar = 3.5;
	int numSteps = 10000;
	float stepSize = 0.00001;
	vec3 bh = uBHPos.xyz;
	//vec3 bh = vec3(0, 0, 8);
	float G = 0.0000000000667430;
	float PI = 3.1414;
	vec4 col = texture2D(uSample, UV);
	vec2 newUV = UV * 2 - vec2(1, 1);

	vec4 rayDir4 = (uV_inv * vec4(newUV, 1.f, 1.0f));
	vec3 rayDir = rayDir4.xyz / rayDir4.w;
	vec3 pos = uCamPos;


	rayDir *= stepSize;

	

	vec2 diskUV = vec2(-1, -1);
	float shade = 0;
	vec3 dir;
	vec3 nextPos;
	float dist;
	float mass = 200000000.0 * uBHRad;
	float c = 29;
	float grav;


	for (int i = 0; i < numSteps; i++)
	{
		dir = bh - pos;
		dist = length(dir);
		grav = (4 * G * mass) / (dist * dist * c * c);
		if (grav < 1)
		{
			i += 5;
		}
		dir = normalize(dir);
		rayDir += dir * grav;
		nextPos = pos + rayDir;

		if (dist < uBHRad * 0.5)
		{
			col = vec4(0,0,0, 1);
			break;
		}
					
		float dist2d = distance(pos.rg, bh.rg);
		if (dist2d < uBHRad * diskScalar)
		{

			if (sign(nextPos.z - bh.z) != sign(pos.z - bh.z))
			{
				shade = 1 - dist2d / (uBHRad * diskScalar);
				vec2 delta = bh.rg - pos.rg;
				float deg = atan(delta.x, delta.y) + PI;
				deg /= 2 * PI;
				deg = mod(deg + float(uTime) / 5, 1.0);
				diskUV = vec2(deg, shade);

				col = vec4( deg, 0, 1 - deg, 1);
				i = numSteps;
				break;
			}
			//col = vec4(0,0,0,1);
							
		}
		
		pos = nextPos;

					
	}
	if (diskUV.x != -1)
	{
		//col = vec4(shade, shade, shade, 1);
		col = texture2D(uTex_sm, diskUV);
	}
	rtFragColor = col;
}
