using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class computeshader : MonoBehaviour {
    public ComputeShader computeShader;
    public RenderTexture renderTexture;

    // Start is called before the first frame update
    void Start() {

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if (renderTexture == null) {
            renderTexture = new RenderTexture(256, 256, 24);
            renderTexture.enableRandomWrite = true;
            renderTexture.Create();
        }

        computeShader.SetTexture(0, "Result", renderTexture);
        computeShader.SetFloat("Resolution", renderTexture.width);
        computeShader.Dispatch(0, renderTexture.width / 8, renderTexture.height / 8, 1);

        Graphics.Blit(renderTexture, destination);
    }

    // Update is called once per frame
    void Update() {

    }
}
