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
	
	drawTexture_outline_fs4x.glsl
	Draw texture sample with outlines.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) implement outline algorithm - see render code for uniform hints

in vec4 passTexcoord;

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform sampler2D uTex_nm;



//lab 2
//out vec4 rtFragColor;

//lab 3
layout (location = 0) out vec4 rtFragColor;
layout (location = 3) out vec4 rtTexCoord;

void main()
{
	
	// Outline line thickness
	float offset = 1.0 / 280.0;

	// The current position of the fragment we are using
	vec2 texturePos = vec2(passTexcoord);

	// The depth map
	vec4 sample_depth = texture2D(uTex_sm, texturePos);

	// The texture's real colors
	vec4 sample_real = texture2D(uTex_dm, texturePos);

	// If we are not drawing an outline at the current
	// fragment, set its color to the real texture color.
	vec4 finalColor = sample_real;

	// The value to be tested against from the depth buffer.
	float testColor = sample_depth.b;

	// The threshold at which a neighboring pixel color must be
	// in order to display the outline.
	float threshold = testColor - 0.005;

	// The color of the outline
	vec4 outlineColor = vec4(0.0, 0.0, 0.0, 1.0);

	// If any of the texture's neighboring pixel values are bellow a certain threshold,
	// make the fragment the specified color. If not, the fragment will the the texture's default color.
	bool showOutline = (texture2D(uTex_sm, vec2(texturePos.x + offset, texturePos.y)).b  < threshold ||
	texture2D(uTex_sm, vec2(texturePos.x, texturePos.y - offset)).b  < threshold ||
	texture2D(uTex_sm, vec2(texturePos.x - offset, texturePos.y)).b  < threshold ||
	texture2D(uTex_sm, vec2(texturePos.x, texturePos.y + offset)).b  < threshold);

	if (showOutline)
	{
		finalColor = outlineColor;
	}
	
	rtFragColor = finalColor;
	rtTexCoord = passTexcoord;
}
