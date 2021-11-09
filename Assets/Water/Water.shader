Shader "Custom/Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Foam ("Foam", Range(0,1)) = 0.5
        _FlowSpeed ("Flow Speed", Range(0,10)) = 1.0
        _Magnitude ("Magnitude", Range(0,10)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "UnityCG.cginc"
        #include "Noise.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Magnitude;
        half _Foam;
        half _FlowSpeed;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        fixed3 GetWave(float2 uv, float2 speed, float2 magnitude) {
            fixed3 wave = unity_gradientNoise((uv + _Time.x * speed) * 10 * magnitude);

            wave += unity_gradientNoise((uv + _Time.x / 2 * speed) * 5 * magnitude);
            wave += unity_gradientNoise((uv + _Time / 4 * speed) * 2 * magnitude);

            return wave;
        }

        void vert (inout appdata_full v) {
            float3 wave = GetWave(v.vertex.xz, _FlowSpeed, _Magnitude);
            half height = length(wave);

            v.vertex.xyz += height * v.normal * _Magnitude;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            float3 wave = lerp(_Color.rgb, float4(1,1,1,1), step(1 - _Foam, GetWave(IN.uv_MainTex, _FlowSpeed, _Magnitude).rgb));

            half foamHeight = smoothstep(0, 1, length(1 - wave));

            // o.Albedo = lerp(float3(0,1,0), float3(1,0,0), foamHeight);
            o.Albedo = wave;
            // o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = foamHeight * _Metallic;
            o.Smoothness =  foamHeight * _Glossiness;
            o.Alpha = _Color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
