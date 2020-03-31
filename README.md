# Intermediate Graphics Midterm, Black Hole Simulation
## Overview
For our midterm project, we created a black hole fragment shader, and an orbiting vertex shader.
To access this project, navigate to the "Color manipulation" forward display mode located in the Shading with MRT Sub-mode.

# Fragment Shader

# Vertex Shader
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



## UML
![UML Diagram](https://cdn.discordapp.com/attachments/642176677128044548/694399303845675068/unknown.png "UML Diagram")
## Important Code
