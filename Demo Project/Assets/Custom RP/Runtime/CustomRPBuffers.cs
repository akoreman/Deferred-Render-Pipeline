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

    // Create the array of RT IDs to send to the GPU as the MRT.
    static RenderTargetIdentifier[] mrt = new RenderTargetIdentifier[3];

    static RenderTexture depthBuffer;

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
        RenderTargetIdentifier normalBufferID = new RenderTargetIdentifier(normalBufferId);

        buffer.GetTemporaryRT(albedoBufferId, camera.pixelWidth, camera.pixelHeight, 24, FilterMode.Point, RenderTextureFormat.ARGBFloat);
        RenderTargetIdentifier albedoBufferID = new RenderTargetIdentifier(albedoBufferId);

        buffer.GetTemporaryRT(worldPositionBufferId, camera.pixelWidth, camera.pixelHeight, 24, FilterMode.Point, RenderTextureFormat.ARGBFloat);
        RenderTargetIdentifier worldPositionBufferID = new RenderTargetIdentifier(worldPositionBufferId);

        mrt[0] = normalBufferID;
        mrt[1] = albedoBufferID;
        mrt[2] = worldPositionBufferID;

        ExecuteBuffer();

        // Create a render texture to use as the depth buffer.
        depthBuffer = RenderTexture.GetTemporary(camera.pixelWidth, camera.pixelHeight, 24);
        buffer.SetRenderTarget(mrt, depthBuffer);
        buffer.ClearRenderTarget(true, false, Color.clear);

        ExecuteBuffer();

        SortingSettings sortingSettings = new SortingSettings(camera);
        DrawingSettings drawingSettings = new DrawingSettings(geometryShaderTagId, sortingSettings);
        FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all);

        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
        context.Submit();

        ExecuteBuffer();
    }

    public void Cleanup()
    {
        buffer.ReleaseTemporaryRT(normalBufferId);
        buffer.ReleaseTemporaryRT(albedoBufferId);
        buffer.ReleaseTemporaryRT(worldPositionBufferId);
        RenderTexture.ReleaseTemporary(depthBuffer);

        ExecuteBuffer();
    }
}
