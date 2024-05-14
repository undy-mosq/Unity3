Shader "Unlit/WaterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Sun ("Sun", COLOR) = (0,0,0,0)
        _Mon ("Mon", range(0,1)) = 0
        _SinSize("SinSize", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
                float4 color: COLOR0;
                
                //float4 pos:POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Sun;
            float _Mon;
            float _SinSize;
            v2f vert (appdata v)
            {
                
                v2f o;
                float fx=v.vertex.x*2+v.vertex.y*5-_Time.z;
                float yoffect =sin( fx )*_SinSize;
                o.vertex = UnityObjectToClipPos(v.vertex+float4(0,yoffect,0,0));
                o.color = float4(-cos(fx)/2+0.6,-cos(fx)/2+0.6,-cos(fx)/2+0.6,-cos(fx)/3+1);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture

                fixed4 col = tex2D(_MainTex, i.uv).rgba;
                
                col = fixed4(max(col.x,col.x*i.color.x),    max(col.y,col.y*i.color.y),   max(col.z,col.z*i.color.z),  0.5f*i.color.w);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

    }
            FallBack "Sprites/Default"
}
