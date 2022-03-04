using UnityEngine;
using UnityEngine.Rendering;
using Unity.Collections;


public class CustomRP : RenderPipeline
{
    CamRenderer renderer = new CamRenderer();


    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        foreach (Camera camera in cameras)
        {
            renderer.Render(context, camera);
            GraphicsSettings.lightsUseLinearIntensity = true;
        }
    }

    public CustomRP()
    {
        GraphicsSettings.useScriptableRenderPipelineBatching = true;
    }
}

public class CamRenderer
{
    ScriptableRenderContext context;
    Camera camera;
    CullingResults cullingResults;

    GeometryBuffer geometryBuffer = new GeometryBuffer();

    static ShaderTagId litShaderTagId = new ShaderTagId("Lit");

    const string bufferName = "Render Camera";
    CommandBuffer buffer = new CommandBuffer {name = bufferName};

    public void Render (ScriptableRenderContext context, Camera camera)
    {
        this.context = context;
        this.camera = camera;

        // If there are no vertices within the culling volume, stop the rendering process.
        if (!Cull())
            return;

        DrawBuffers();

        buffer.BeginSample(bufferName);

        ExecuteBuffer();

        buffer.EndSample(bufferName);

        Setup();     

        buffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);

        DrawGeometry();
        
        Submit();
    }

    void Setup()
    {
        context.SetupCameraProperties(camera);
        buffer.ClearRenderTarget(true, true, Color.clear);
        buffer.BeginSample(bufferName);

        ExecuteBuffer();
    }

    void DrawBuffers()
    {
        geometryBuffer.Setup(context, cullingResults, camera);
    }

    void DrawGeometry()
    {
        SortingSettings sortingSettings = new SortingSettings(camera);
        
        DrawingSettings drawingSettings = new DrawingSettings(litShaderTagId, sortingSettings)
        {
            perObjectData = PerObjectData.Lightmaps | PerObjectData.LightProbe | PerObjectData.LightProbeProxyVolume | PerObjectData.ReflectionProbes
        };
        
        FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all);
        
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
                
        context.DrawSkybox(camera);
    }

    void Submit()
    {
        buffer.EndSample(bufferName);
        ExecuteBuffer();
        context.Submit();
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    bool Cull()
    {
        ScriptableCullingParameters param;

        if (camera.TryGetCullingParameters(out param))
        {
            cullingResults = context.Cull(ref param);
            return true;
        }

        return false;
    }
}
