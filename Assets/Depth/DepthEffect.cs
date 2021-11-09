using UnityEngine;
using System;

[ExecuteInEditMode, ImageEffectAllowedInSceneView, RequireComponent(typeof(Camera))]
public class DepthEffect : MonoBehaviour {

    [HideInInspector]
    public Shader dofShader;

    Camera cam;

    Material dofMaterial;


    void Update() {
        if (cam == null) {
            cam = this.GetComponent<Camera>();
            cam.depthTextureMode |= DepthTextureMode.Depth;
        }

        if (dofMaterial == null) {
            dofMaterial = new Material(dofShader);
            dofMaterial.hideFlags = HideFlags.HideAndDontSave;
        }
    }

    void OnPreRender() {
        if (cam != null) {
            // pass this camera matrix data to screen shader
            Shader.SetGlobalMatrix(Shader.PropertyToID("UNITY_MATRIX_IV"), cam.cameraToWorldMatrix);
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if (dofMaterial != null) {
            Graphics.Blit(source, destination, dofMaterial);
        }
    }
}