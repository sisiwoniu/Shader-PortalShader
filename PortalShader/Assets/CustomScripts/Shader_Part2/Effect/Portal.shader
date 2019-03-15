Shader "Custom/Portal"
{
    Properties
    {	
		[NoScaleOffset]
        _MainTex ("Texture", 2D) = "white" {}
		[NoScaleOffset]
		_SubTex ("Sub Texture", 2D) = "white" {}
		_Distortion ("Distortion", Range(0, 1)) = 0.05
		_Threshold ("Threshold", Range(0.1, 1)) = 1
		_Aspect("Aspect", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }

		Cull Back

		Blend SrcAlpha OneMinusSrcAlpha

        LOD 100

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _SubTex;
			float _Aspect;
			float _Radius;
			float _Distortion;
			float _Threshold;
			float2 _Pos;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//発生中心からの距離
				//_Aspectはパーセント変化量を与える
				float dist = distance(_Pos, i.uv) * _Aspect;

				//歪み具合
				//発生する原点より離れていくと歪み具合が掛かるように
				//内側にあればあるほど数値がMaxに近づき、逆だとMinに近づく
				float distortion = 1 - smoothstep(_Radius - _Distortion, _Radius, dist);

				//歪めたUV
				float2 uv = i.uv + (_Pos - i.uv) * distortion;
				
				//2枚目のテクスチャ色
				float4 subCol = tex2D(_SubTex, i.uv);

				//普通の一前目のテクスチャ色
                fixed4 col = tex2D(_MainTex, uv);

				//[_Threshold]を大きくすれば、中心に開ける穴が小さくなる ==（歪みエリアの割合が増える）
                return lerp(col, subCol, step(_Threshold, distortion));
            }
            ENDCG
        }
    }
}
