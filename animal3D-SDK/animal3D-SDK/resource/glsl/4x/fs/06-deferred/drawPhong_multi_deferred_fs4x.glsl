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
	
	drawPhong_multi_deferred_fs4x.glsl
	Draw Phong shading model by sampling from input textures instead of 
		data received from vertex shader.
*/

#version 410

#define MAX_LIGHTS 4

// ****TO-DO: 
// My Note: Copy origonal phong, take the whole thing, and replace any avarying inputs we recieved from previous vertex shader with a texture sample
//	0) copy original forward Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare light data as block
//	3) replace geometric information normally received from fragment shader 
//		with samples from respective g-buffer textures; use to compute lighting
//			-> position calculated using reverse perspective divide; requires 
//				inverse projection-bias matrix and the depth map
//			-> normal calculated by expanding range of normal sample
//			-> surface texture coordinate is used as-is once sampled

in vec4 vTexcoord;

out vec4 rtFragColor;

uniform sampler2D uImage01; //position attributes
uniform sampler2D uImage02; //normal attributes
uniform sampler2D uImage03; //texCoord attributes

uniform sampler2D uTex_dm_ramp;

vec4 vVert;
vec4 vNormal;
vec4 vTransTex;


uniform int uLightCt;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];
uniform vec4 uTex;
uniform sampler2D uSample;
uniform mat4 uPB_inv;


vec4 getDiffuse(vec3 normNormal, int lightIndex)
{
	// The position and color of the indexed light.
	vec3 pos = uLightPos[lightIndex].xyz;
	vec4 col = uLightCol[lightIndex];

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

	diffusedColor.a = 1;

	return diffusedColor;
}


vec4 getSpecular(vec3 normNormal, vec3 normalPosition, float specularCoef, float specularBrightness, int lightIndex)
{
	// The position and color of the indexed light.
	vec3 pos = uLightPos[lightIndex].xyz;
	vec4 col = uLightCol[lightIndex];


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

	vec4 finalColor = reflective * specularBrightness;

	finalColor.a = 1;

	// We take the reflectiveness mutliplied by the specular brightness (an optional parameter to change brightness),
	// and add it with the light's intensity and the general brightness of the scene (abient light).
	return finalColor;
}


void unTransformData()
{
	vVert = texture2D(uImage01, vec2(vTexcoord));
	vNormal = texture2D(uImage02, vec2(vTexcoord));
	vTransTex = texture2D(uImage03, vec2(vTexcoord));


	vVert = uPB_inv * vVert;
	vVert /= vVert.w;
	vNormal = (vNormal - 0.5) * 2;
}


void main()
{
	unTransformData();
	vec3 normNormal = normalize(vNormal.xyz);
	vec4 ambient = vec4(0.0, 0.0, 0.0, 1);
	vec3 normPosition = normalize(vVert.xyz);

	// For each light, get the color of fragment and add them together.
	vec4 diffuse = vec4(0);
	vec4 specular = vec4(0);

	for (int i = 0; i < uLightCt; i++)
	{
		diffuse += getDiffuse(normNormal, i);
		specular += getSpecular(normNormal, normPosition, 16, 1, i);
	}
	

	rtFragColor = diffuse + specular + ambient;

	// Apply the color we recieve from the lights, and apply it to the given texture.
	vec4 texColor = texture2D(uTex_dm_ramp, vec2(vTransTex));

	// Declaring new render targets for each applicable output.
	rtFragColor *= texColor;
}
