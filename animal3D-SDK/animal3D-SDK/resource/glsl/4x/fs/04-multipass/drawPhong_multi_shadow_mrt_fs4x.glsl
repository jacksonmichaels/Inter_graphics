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
	
	drawPhong_multi_shadow_mrt_fs4x.glsl
	Draw Phong shading model for multiple lights with MRT output and 
		shadow mapping.
*/

#version 410

// ****TO-DO: 
//	0) copy existing Phong shader
//	1) receive shadow coordinate
//	2) perform perspective divide
//	3) declare shadow map texture
//	4) perform shadow test

layout(location = 0) out vec4 rtFragColor;
layout(location = 1) out vec4 rtViewPos;
layout(location = 2) out vec4 rtViewNormal;
layout(location = 3) out vec4 rtTexCoord;
layout(location = 4) out vec4 rtDiffuseMap;
layout(location = 5) out vec4 rtSpecularMap;
layout(location = 6) out vec4 rtDiffuseTotal;
layout(location = 7) out vec4 rtSpecularTotal;

in vec4 vVert;
in vec4 vNormal;
in vec4 vTransTex;
in vec4 vShadowCoord;

uniform int uLightCt;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];
uniform vec4 uTex;
uniform sampler2D uSample;
uniform sampler2D uTex_shadow;

bool getShadowTest()
{
	vec4 shadowPerspect = vShadowCoord / vShadowCoord.w;

	vec4 col = texture2D(uTex_shadow, vec2(shadowPerspect));

	float perspDist = col.r;

	bool isShadow = (perspDist + 0.0025< vShadowCoord.z);

	return isShadow;
}

vec4 getDiffuse(int lightIndex, vec3 normNormal)
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

	bool shadowed = getShadowTest();

	if (shadowed)
	{
		diffusedColor *= 0.0025;
	}
	return diffusedColor;
	

}


vec4 getSpecular(vec3 normNormal, vec3 normalPosition, int lightIndex, float specularCoef, float specularBrightness)
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

void main()
{
	rtFragColor = vec4(0.0);
	vec3 normNormal = normalize(vNormal.xyz);
	vec4 diffuse = vec4(0);
	vec4 specular = vec4(0);
	vec4 ambient = vec4(0);
	vec3 normPosition = normalize(vVert.xyz);

	bool shaded = getShadowTest();

	// For each light, get the color of fragment and add them together.
	for (int i = 0; i < 4; i++) {
		diffuse += getDiffuse(i, normNormal);
		specular += getSpecular(normNormal, normPosition, i, 16, 1);
	}
	rtFragColor += diffuse + specular + ambient;

	// Apply the color we recieve from the lights, and apply it to the given texture.
	vec4 texColor = texture2D(uSample, vec2(vTransTex));

	// Declaring new render targets for each applicable output.
	rtViewPos = vVert;
	rtViewNormal = vec4(normNormal, 1);
	rtTexCoord = vTransTex;
	rtDiffuseMap = texColor;
	rtSpecularMap = texColor;
	rtDiffuseTotal = diffuse;
	rtSpecularTotal = specular;
	rtFragColor *= texColor;
	//rtFragColor = vVert;
}