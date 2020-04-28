# Intermediate Graphics Final, Black Hole Simulation
## Overview
For our final project, we created a ray tracing black hole fragment shader and an gravitational well vertex shader.
To access this project, navigate to the "Color manipulation" forward display mode located in the Shading with MRT Sub-mode.

### Fragment Shader
This effect, using a post-processing pass, takes the UV coordinates of each fragment and warps them towards the black hole.
This creates an effect where the earth (and the objects around it) seem to be bending in towards the black hole. 
This allows the user to see what they would not normally be able to see behind the black hole, as the fragments are being bent around it.
There are four main configurable parameters: 
blackHoleSharpness, which controls the blur effect around the black hole, 
brightness, 
schwarzschildRadius,
and brightnessMax, which prevents the rest of the scene's colors from going over 1.0.

### Vertex Shader
The vertex shader is a custom build one, named passBlackHole_transform_vs4x.glsl located in 4x/vs/02-shading.
The shader has five main configurable parameters: 
orbital speed, which controls the speed at which the orbit happens,
and orbital depth, which controls the depth at which the orbit will travel,
Mass, which is the mass of the black hole,
distance to black hole, which is exactly what the name suggests,
and change in time, the time difference between the black hole's and the user's reference points.
To change between this vertex shader and the default one, 
simply change passBlackHole_transform_vs under the prog_drawTexture_colorManip program (located in a3_DemoState_loading.c) to passTexcoord_transform_vs.

## Overview Video
[https://youtu.be/Rzda0JmUzTU](https://youtu.be/Rzda0JmUzTU)

## Team members contributions
### Jackson
Black Hole fragment shader implementation 

Creation / passing of relivant uniforms

### Steven
Vertex Shader implementation with time dilation and integration with fragment shader

## Description
This project uses fragment and vertex shaders to simulate the light warping effects observed nearby a black hole. We send rays out from each fragment simulating them as they travel through the scene, adjusting their direction based on how much force the gravity of the black hole would pull on it at any given position. If they hit either the black hole itself or its disk we set the color to match what it hit. The black hole's rotation, as well as the orbit's rotation, are determined by time dilation.

## Justification
Our project fits into the intermediate real-time effect category. This is because it is an intermediate level post-processing effect, which uses techniques that build on principals we have learned to date, such as UV remapping and vector distances.


## UML
![UML Diagram](https://cdn.discordapp.com/attachments/642176677128044548/704699771637465209/unknown.png "UML Diagram")
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
