Shader "Custom/StarNest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness ("Brightness", Float) = 0.0015
        _DarkMatter ("Dark Matter", Float) = 0.3
        _DistFading ("Distance Fading", Float) = 0.73
        _Saturation ("Saturation", Float) = 0.85
        _Zoom ("Zoom", Float) = 0.8
        _Tile ("Tile", Float) = 0.85
        _Speed ("Speed", Float) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Background" }
        Pass
        {
            ZWrite Off
            Cull Off
            Fog { Mode Off }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Properties
            sampler2D _MainTex;
            float _Brightness;
            float _DarkMatter;
            float _DistFading;
            float _Saturation;
            float _Zoom;
            float _Tile;
            float _Speed;

            // Constants
            #define iterations 17
            #define formuparam 0.53
            #define volsteps 20
            #define stepsize 0.1

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 fragCoord = i.uv * _ScreenParams.xy;
                float2 uv = fragCoord / _ScreenParams.xy - 0.5;
                uv.y *= _ScreenParams.y / _ScreenParams.x;

                float3 dir = float3(uv * _Zoom, 1.0);
                float time = _Time.y * _Speed + 0.25;

                // camera rotation (no mouse here, so just fixed)
                float a1 = 0.5;
                float a2 = 0.8;
                float2x2 rot1 = float2x2(cos(a1), sin(a1), -sin(a1), cos(a1));
                float2x2 rot2 = float2x2(cos(a2), sin(a2), -sin(a2), cos(a2));

                dir.xz = mul(rot1, dir.xz);
                dir.xy = mul(rot2, dir.xy);

                float3 from = float3(1.0, 0.5, 0.5);
                from += float3(0.0, time, -2.0);
                from.xz = mul(rot1, from.xz);
                from.xy = mul(rot2, from.xy);

                // volumetric rendering
                float s = 0.1;
                float fade = 1.0;
                float3 v = float3(0.0, 0.0, 0.0);

                for (int r = 0; r < volsteps; r++)
                {
                    float3 p = from + s * dir * 0.5;
                    p = abs(float3(_Tile, _Tile, _Tile) - fmod(p, _Tile * 2.0));

                    float pa = 0.0, a = 0.0;
                    for (int j = 0; j < iterations; j++)
                    {
                        p = abs(p) / dot(p, p) - formuparam;
                        a += abs(length(p) - pa);
                        pa = length(p);
                    }

                    float dm = max(0.0, _DarkMatter - a * a * 0.001);
                    a *= a * a;

                    if (r > 6) fade *= 1.0 - dm;

                    v += float3(fade, fade, fade);
                    v += float3(s, s * s, s * s * s * s) * a * _Brightness * fade;
                    fade *= _DistFading;
                    s += stepsize;
                }

                v = lerp(float3(length(v), length(v), length(v)), v, _Saturation);
                return float4(v * 0.01, 1.0);
            }
            ENDCG
        }
    }
}
