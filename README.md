# Deferred Render Pipeline

A deferred render pipeline using Unity3D's scriptable render pipeline to demonstrate the fundamentals of using deferred shading and using Multiple Render Targets (MRT), for more advanced lighting/shadow techniques see the forward rendering project. This project shares some code with my forward rendering pipline project (https://github.com/akoreman/Forward-Render-Pipeline).

**Currently Implemented:**
- Using MRT to render the geometry buffers in a single pass.
- Sampling from these buffers to calculate diffuse shading from a directional light.
- Renders a screen-space triangle and sample the geometry buffer to a square of that to render the final image.

# Screenshots

**Normal buffer**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/GBufferNormals.png" width="400"> 

**Albedo buffer**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/GBufferAlbedo.png" width="400"> 

**World-space positions buffer**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/GBufferPosition.png" width="400"> 

**Combining the buffers for a diffuse shaded render**  
<img src="https://raw.github.com/akoreman/Deferred-Render-Pipeline/main/images/DiffuseShaded.png" width="400"> 
