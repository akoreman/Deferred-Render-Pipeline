using UnityEngine;
using UnityEngine.Rendering;
using Unity.Collections;

[System.Serializable]
public class BufferSettings
{
    [Min(0.001f)]
    public float maxDistance = 100f;

    [Range(0.001f, 1f)]
    public float distanceFade = 0.1f;

}

public class NormalBuffer
{
    const string bufferName = "NormalBuffer";

    ScriptableRenderContext context;
    Camera camera;
    CullingResults cullingResults;

    CommandBuffer buffer = new CommandBuffer { name = bufferName };

    static int normalBufferId = Shader.PropertyToID("_NormalBuffer");
    static int albedoBufferId = Shader.PropertyToID("_AlbedoBuffer");
    //static int depthBufferId = Shader.PropertyToID("_DepthBuffer");

    static ShaderTagId geometryShaderTagId = new ShaderTagId("Geometry");

    static RenderTargetIdentifier[] mrt = new RenderTargetIdentifier[2];


    public void Setup(ScriptableRenderContext context, CullingResults cullingResults, Camera camera)
    {
        this.context = context;
        this.cullingResults = cullingResults;
        this.camera = camera;

        ExecuteBuffer();

        Render();
        Cleanup();
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    public void Render()
    {
        context.SetupCameraProperties(camera);
        buffer.ClearRenderTarget(true, true, Color.clear);

        ExecuteBuffer();

        buffer.GetTemporaryRT(normalBufferId, camera.pixelWidth, camera.pixelHeight, 32, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        mrt[0] = new RenderTargetIdentifier(normalBufferId);

        buffer.GetTemporaryRT(albedoBufferId, camera.pixelWidth, camera.pixelHeight, 32, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        mrt[1] = new RenderTargetIdentifier(albedoBufferId);

        //buffer.SetRenderTarget(normalBufferId, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
        buffer.SetRenderTarget(mrt, 32);
        ExecuteBuffer();

        buffer.ClearRenderTarget(true, false, Color.clear);

        ExecuteBuffer();

        SortingSettings sortingSettings = new SortingSettings(camera);
        DrawingSettings drawingSettings = new DrawingSettings(geometryShaderTagId, sortingSettings);
        FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all);

        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

        ExecuteBuffer();
        context.Submit();
    }



    public void Cleanup()
    {
        ExecuteBuffer();
    }



}

public class AlbedoBuffer
{
    const string bufferName = "AlbedoBuffer";

    ScriptableRenderContext context;
    Camera camera;
    CullingResults cullingResults;

    CommandBuffer buffer = new CommandBuffer { name = bufferName };

    static int albedoBufferId = Shader.PropertyToID("_AlbedoBuffer");
    static ShaderTagId albedoShaderTagId = new ShaderTagId("Albedo");

    public void Setup(ScriptableRenderContext context, CullingResults cullingResults, Camera camera)
    {
        this.context = context;
        this.cullingResults = cullingResults;
        this.camera = camera;

        ExecuteBuffer();

        Render();
        Cleanup();
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }


    public void Render()
    {
        context.SetupCameraProperties(camera);
        buffer.ClearRenderTarget(true, true, Color.clear);

        ExecuteBuffer();

        buffer.GetTemporaryRT(albedoBufferId, camera.pixelWidth, camera.pixelHeight, 32, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        buffer.SetRenderTarget(albedoBufferId, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);

        ExecuteBuffer();

        buffer.ClearRenderTarget(true, false, Color.clear);

        ExecuteBuffer();

        

        SortingSettings sortingSettings = new SortingSettings(camera);
        DrawingSettings drawingSettings = new DrawingSettings(albedoShaderTagId, sortingSettings);
        FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all);

        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

        ExecuteBuffer();
        context.Submit();
    }


    public void Cleanup()
    {
        ExecuteBuffer();
    }


}