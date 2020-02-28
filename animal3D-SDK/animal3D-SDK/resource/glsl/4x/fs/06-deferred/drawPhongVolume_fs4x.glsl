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
	
	drawPhongVolume_fs4x.glsl
	Draw Phong lighting components to render targets (diffuse & specular).
*/

#version 410

#define MAX_LIGHTS 1024

// ****TO-DO: 
//	0) copy deferred Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare lighting data as uniform block
//	3) calculate lighting components (diffuse and specular) for the current 
//		light only, output results (they will be blended with previous lights)
//			-> use reverse perspective divide for position using scene depth
//			-> use expanded normal once sampled from normal g-buffer
//			-> do not use texture coordinate g-buffer

in vec4 vBiasedClipCoord;
flat in int vInstanceID;


// (2)
// simple point light
struct sPointLight
{
	vec4 worldPos;						// position in world space
	vec4 viewPos;						// position in viewer space
	vec4 color;							// RGB color with padding
	float radius;						// radius (distance of effect from center)
	float radiusInvSq;					// radius inverse squared (attenuation factor)
	float pad[2];						// padding
};

// (2)

uniform ubPointLight{
	sPointLight uLight[MAX_LIGHTS];
};

layout (location = 6) out vec4 rtDiffuseLight;
layout (location = 7) out vec4 rtSpecularLight;

// (1)

vec4 vVert;
vec4 vNormal;
vec4 vTransTex;

uniform sampler2D uImage01; //position attributes
uniform sampler2D uImage02; //normal attributes
uniform sampler2D uImage03; //texCoord attributes
uniform mat4 uPB_inv;


// (0)

vec4 getDiffuse(vec3 normNormal, vec4 lightPos, vec4 lightCol)
{
	// The position and color of the indexed light.
	vec3 pos = lightPos.xyz;
	vec4 col = lightCol;
	vec4 diffusedColor;

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
		diffusedColor = dot(normNormal, normLightVect) * col;

		diffusedColor.a = 1;

	return diffusedColor;
}


vec4 getSpecular(vec3 normNormal, vec3 normalPosition, float specularCoef, float specularBrightness, vec4 uLightPos, vec4 uLightCol)
{
	// The position and color of the indexed light.
	vec3 pos = uLightPos.xyz;
	vec4 col = uLightCol;

	vec4 finalColor;


	// By subtracting the light's position from the position of the vertex,
	// we are given the vector direction that the light is traveling.
	vec3 lightVec = pos - vVert.xyz;



		// Normalizing the light's direction will prepair it for the dot product,
		// and to be reflected.
		vec3 normLightVect = normalize(lightVec);

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
		vec4 reflective = pow(max(dot(normalPosition, reflectedRay), 0), specularCoef) * col;

		finalColor = reflective * specularBrightness;

//		finalColor.a = 0;
//
	// We take the reflectiveness mutliplied by the specular brightness (an optional parameter to change brightness),
	// and add it with the light's intensity and the general brightness of the scene (abient light).
	return finalColor;
}


void unTransformData()
{
	vec2 position = (vBiasedClipCoord / vBiasedClipCoord.w).xy; // Here we do persepective divide

	vVert = texture2D(uImage01, position);
	vNormal = texture2D(uImage02, position);
	vTransTex = texture2D(uImage03, position);


	vVert = uPB_inv * vVert;
	vVert /= vVert.w;
	vNormal = (vNormal - 0.5) * 2;
}

void main()
{
	sPointLight light = uLight[vInstanceID];
	unTransformData();
	vec3 normNormal = normalize(vNormal.xyz);
	vec3 normPosition = normalize(vVert.xyz);

	// For each light, get the color of fragment and add them together.
	rtDiffuseLight = getDiffuse(normNormal, light.worldPos, light.color);
	//rtDiffuseLight = vec4(vNormal.xyz, 1.0);
	rtSpecularLight = getSpecular(normNormal, normPosition, 16, 1, light.worldPos, light.color);
}
