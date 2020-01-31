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
	
	drawPhong_multi_fs4x.glsl
	Draw Phong shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Phong shading model
//	Note: test all data and inbound values before using them!

out vec4 rtFragColor;

<<<<<<< HEAD
void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE GREEN
	rtFragColor = vec4(0.0, 1.0, 0.0, 1.0);
=======
in vec4 vVert;
in vec4 vNormal;
in vec4 vTransTex;

uniform int uLightCt;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];
uniform vec4 uTex;
uniform sampler2D uSample;

vec4 getColorForLight(int lightIndex, float ambientLight, float specularCoef, float specularBrightness)
{
	// The position and color of the indexed light.
	vec3 pos = uLightPos[lightIndex].xyz;
	vec4 col = uLightCol[lightIndex];

	// By normalizing the normals, we prepair it for
	// the dot product function.
	vec3 normNormal = normalize(vNormal.xyz);

	// By subtracting the light's position from the position of the vertex,
	// we are given the vector direction that the light is traveling.
	vec3 lightVec = pos - vVert.xyz;

	// Normalizing the light's direction will prepair it for the dot product,
	// and to be reflected.
	vec3 normLightVect = normalize(lightVec);
	
	// Since the Phong shader needs to know the camera's position,
	// we need to add the normalized vertex position.
	vec3 normalPosition = normalize(vVert.xyz);

	// By taking the dot product of the vertex's normals and the direction
	// of light, we can find the light's intensity.
	vec4 diffusedColor = dot(normNormal, normLightVect) * col;

	// The normalized light vector is reflected over the normalized vertex position,
	// In order to compute if we should show a bright spot at the location.
	vec3 reflectedRay = reflect(normLightVect, normNormal);

	// We take the dot product of the normalized position and the reflected ray,
	// in order to compute how well the two vectors line up with eachother.
	// We take the max of this result and 0, to avoid the scene rendering completely dark;
	// aka the specular reflection is never negative.
	// We then take that result to the power of the specular coefficient, or 'shininess',
	// in order to compute how large the reflected spot is.
	// Finally, we multiply this result by the light's color to get the final color value.
	vec4 reflective = pow( max(dot(normalPosition, reflectedRay),0), specularCoef) * col;

	// We take the reflectiveness mutliplied by the specular brightness (an optional parameter to change brightness),
	// and add it with the light's intensity and the general brightness of the scene (abient light).
	return (reflective * specularBrightness) + diffusedColor + vec4(ambientLight);
}

void main()
{
	rtFragColor = vec4(0.0);

	// For each light, get the color of fragment and add them together.
	for (int i = 0; i < 4; i++){
		rtFragColor += getColorForLight(i, 0.05, 16, 1);
	}

	// Apply the color we recieve from the lights, and apply it to the given texture.
	rtFragColor *= texture2D(uSample, vec2( vTransTex));
>>>>>>> ba0570f812eb69be68e10130cfdffff217e973ae
}
