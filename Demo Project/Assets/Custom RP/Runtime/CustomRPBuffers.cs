using UnityEngine;
using UnityEngine.Rendering;
using Unity.Collections;

// Class to setup the MRT and setup and render to the appropriate targets.

public class GeometryBuffer
{
    const string bufferName = "NormalBuffer";

    ScriptableRenderContext context;
    Camera camera;
    CullingResults cullingResults;

    CommandBuffer buffer = new CommandBuffer { name = bufferName };

    // Setup IDs for the appropriate render targets.
    static int normalBufferId = Shader.PropertyToID("_NormalBuffer");
    static int albedoBufferId = Shader.PropertyToID("_AlbedoBuffer");
    static int worldPositionBufferId = Shader.PropertyToID("_worldPositionBuffer");

    static ShaderTagId geometryShaderTagId = new ShaderTagId("Geometry");

    // Create the array of RT IDs to send to the GPU as the MRTs.
    static RenderTargetIdentifier[] mrt = new RenderTargetIdentifier[3];

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

        // Create the render targets, create the IDs and throw them together in an array.
        buffer.GetTemporaryRT(normalBufferId, camera.pixelWidth, camera.pixelHeight, 24, FilterMode.Point, RenderTextureFormat.ARGBFloat);
        ExecuteBuffer();

        RenderTargetIdentifier hormalBufferID = new RenderTargetIdentifier(normalBufferId);
        ExecuteBuffer();


        buffer.GetTemporaryRT(albedoBufferId, camera.pixelWidth, camera.pixelHeight, 24, FilterMode.Point, RenderTextureFormat.ARGBFloat);
        ExecuteBuffer();

        RenderTargetIdentifier albedoBufferID = new RenderTargetIdentifier(albedoBufferId);
        ExecuteBuffer();

        buffer.GetTemporaryRT(worldPositionBufferId, camera.pixelWidth, camera.pixelHeight, 24, FilterMode.Point, RenderTextureFormat.ARGBFloat);
        ExecuteBuffer();

        RenderTargetIdentifier worldPositionBufferID = new RenderTargetIdentifier(worldPositionBufferId);
        ExecuteBuffer();

        mrt[0] = normalBufferId;
        mrt[1] = albedoBufferId;
        mrt[2] = worldPositionBufferID;

        ExecuteBuffer();

        // Create a render texture to use a the depth buffer.
        var depthBuffer = RenderTexture.GetTemporary(camera.pixelWidth, camera.pixelHeight, 24);

        buffer.SetRenderTarget(mrt, depthBuffer);
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
