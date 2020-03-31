# Intermediate Graphics Midterm, Black Hole Simulation
## Overview
For our midterm project, we created a black hole fragment shader, and an orbiting vertex shader.
To access this project, navigate to the "Color manipulation" forward display mode located in the Shading with MRT Sub-mode.

### Fragment Shader
This effect, using a post processing pass, takes the UV coordinates of each fragment and warps them towards the black hole.
This creates an effect where the earth (and the objects around it) seem to be bending in towards the black hole. 
This allows the user to see what they would not normally be able to see behind the black hole, as the fragments are being bent around it.

### Vertex Shader
The vertex shader is a custom build one, named passBlackHole_transform_vs4x.glsl located in 4x/vs/02-shading.
The shader has a two main configurable parameters: 
orbital speed, which controls the speed at which the orbit happens,
and orbital deptch, which controls the depth at which the orbit will travel.
To change between this vertex shader and the default one, 
simply change passBlackHole_transform_vs under the prog_drawTexture_colorManip program (located in a3_DemoState_loading.c) to passTexcoord_transform_vs.

## Overview Video
[https://youtu.be/Rzda0JmUzTU](https://youtu.be/Rzda0JmUzTU)

## Team members contributions
### Jackson
Black Hole fragment shader implementation 

Creation / passing of relivant uniforms

### Steven
Vertex Shader implementation and integration with fragment shader

Refactored fragment shader for increased readability

## Description
This project uses fragment and vertex shaders to simulate the light warping effects observed neaby a black hole. The basic effect is to take the fragments that are close to the center of the black hole and shift them outwards to make the illusion that light from objects behind the Black Hole is being bent around the edges to the observers eye.

## Justification
Our project fits into the intermediate real-time effect category. This is because it is an intermediate level post processing effect, which uses techniques that build on principals we have learned to date, such as UV remapping and vector distances.


## UML
![UML Diagram](https://cdn.discordapp.com/attachments/642176677128044548/694399303845675068/unknown.png "UML Diagram")
## Important Code

### Overall
a3_DemoState_loading.c: Contains the black hole vertex shader program inclusion, 
and definitions for uDem and uCenter, which are two uniforms used in the fragment shader.

### Fragment
4x/vs/03-framebuffer/drawTexture_colorManip_fs4x.glsl: The black hole fragment shader.

a3_DemoShaderProgram.h: Contains definitions for uDem and uCenter.

a3_DemoState_idle-render.c: Passes uDem and uCenter to the shader.

### Vertex
4x/vs/02-shading/passBlackHole_transform_vs4x.glsl: The black hole orbit vertex shader.
