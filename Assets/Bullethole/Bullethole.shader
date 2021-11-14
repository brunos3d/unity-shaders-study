Shader "Unlit/Bullethole"
{
    Properties
    {
        _Test ("Test", Range(0, 1)) = 1.0
        _AlphaClip ("Alpha Clip", Range(0, 1)) = 1.0
        _Cutoff  ("Cutoff", Float) = 0.5
        _MainTex ("Texture", 2D) = "white" {}
        _BulletholeTex ("Bullethole", 2D) = "gray" {}
        _BulletholeMaskTex ("Bullethole", 2D) = "white" {}
    }
    SubShader
    {
        Tags {
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest"
        }
        
        LOD 100

        Pass
        {

            CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
            #pragma exclude_renderers d3d11 gles
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #define TAU 6.283185307179586

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float _Test;
            float _AlphaClip;
            float _Cutoff;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BulletholeTex;
            float4 _BulletholeTex_ST;
            sampler2D _BulletholeMaskTex;
            float4 _BulletholeMaskTex_ST;
            fixed4 _Bullethole_Positions[20];

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float2 rotateUV(float2 uv, float rotation)
            {
                float mid = 0.5;
                return float2(cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid, cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float2 uv = i.uv;

                for (int i = 0; i < 20; i++) {
                    float2 bpos = float2(_Bullethole_Positions[i].xy);
                    float brot = _Bullethole_Positions[i].z;
                    float bscale = _Bullethole_Positions[i].w;

                    float2 buv = (uv - bpos) * _BulletholeTex_ST;
                    float2 bmuv = (uv - bpos) * _BulletholeMaskTex_ST;

                    fixed4 bcol = tex2D(_BulletholeTex, rotateUV(buv, brot * TAU));
                    fixed4 bmcol = tex2D(_BulletholeMaskTex, rotateUV(bmuv, brot * TAU));
                    half t = bcol.a * step(bcol.a, 1 - _AlphaClip);
                    
                    fixed4 cres = lerp(col, bcol, t);

                    clip(cres.a * (1 - bmcol.a) - _Cutoff);

                    col = cres;
                }


                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col;
            }
            ENDCG
        }
    }
}
