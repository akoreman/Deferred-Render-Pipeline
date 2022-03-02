# Deferred Render Pipeline

Working on a deferred render pipeline using Unity3D's scriptable render pipeline. Mainly to demonstrate the fundamentals of using deferred shading, for more advanced lighting techniques see the forward rendering project. This project shares some code with my forward rendering pipline project (https://github.com/akoreman/Forward-Render-Pipeline).

**Currently Implemented:**
- Using multiple passes to render the buffers.
- Sampling from these buffers to calculate diffuse shading from directional lights.

**To do:**
- Use MRT to render to the buffers in a single geometry pass.

# Screenshots

**Normals buffer**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/GBufferNormals.png" width="400"> 

**Albedo buffer**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/GBufferAlbedo.png" width="400"> 

**Combining the buffers for a diffuse shaded render**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/DiffuseShaded.png" width="400"> 
