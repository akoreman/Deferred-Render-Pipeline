# Deferred Render Pipeline

Working on a deferred render pipeline using Unity3D's scriptable render pipeline. Mainly to demonstrate the fundamentals of using deferred shading, for more advanced lighting techniques see the forward rendering project. This project shares some code with my forward rendering pipline project (https://github.com/akoreman/Forward-Render-Pipeline).

**Currently Implemented**
- Using MRT to render the buffers using a single geometry pass.
- Sampling from these buffers to calculate diffuse shading from directional lights.

# Screenshots

**Normals buffer**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/GBufferNormals.png" width="400"> 

**Albedo buffer**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/GBufferAlbedo.png" width="400"> 

**Combining the buffers for a diffuse shaded render**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/DiffuseShaded.png" width="400"> 
