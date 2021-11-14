using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

[ExecuteInEditMode]
public class Bullethole : MonoBehaviour {

    // [NonSerialized]
    public Vector4[] bulletholePositions;


    // Start is called before the first frame update
    void OnEnable() {
        bulletholePositions = new Vector4[20];

        for (int idx = 0; idx < bulletholePositions.Length; idx++) {
            Vector2 uvPos = Random.insideUnitCircle;
            float yRot = Random.Range(0.0f, 1.0f);
            float wScale = Random.Range(0.0f, 1.0f);
            bulletholePositions[idx] = new Vector4(Mathf.Abs(uvPos.x), Mathf.Abs(uvPos.y), yRot, 1.0f + (5.0f * wScale));
        }
    }

    // Update is called once per frame
    void Update() {
        Shader.SetGlobalVectorArray("_Bullethole_Positions", bulletholePositions);
    }
}
