Shader "Hidden/DepthEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HideInInspector]_CameraDepthTexture ("Depth", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthNormalsTexture; // get depth and normals

            float4x4 UNITY_MATRIX_IV; // inverse matrix from camera

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // assign NormalXYZ to floatXYZ, Depth to floatW
                float4 NormalDepth;

                // decode Depth Normal maps: (InputTex, out Depth, out NormalXYZ);
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), NormalDepth.w, NormalDepth.xyz);

                // this is world space normal
                float3 WorldNormal = mul(UNITY_MATRIX_IV, float4(NormalDepth.xyz, 0)).xyz;

                // col.rgb = WorldNormal;

                col.rgb = NormalDepth.w;

                // lets ignore the skybox/bg
                // if (NormalDepth.w >= 1.0) {
                    //     col.rgb = 0;
                // }

                return col;
            }
            ENDCG
        }
    }
}
