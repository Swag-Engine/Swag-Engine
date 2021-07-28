package;

import flixel.system.FlxAssets.FlxShader;

class HueEffect
{
	public var shader(default, null):HueShader = new HueShader();
	public var hue(default, set):Float = 0;

	function set_hue(v:Float):Float
	{
		hue = v;
		shader.hue.value = [hue];
		return v;
	}

	public function new():Void
	{
	}

	public function update(elapsed:Float):Void
	{
	}
}

class HueShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float hue;

		vec3 hueShift( vec3 color, float hueAdjust ){

			const vec3  kRGBToYPrime = vec3 (0.299, 0.587, 0.114);
			const vec3  kRGBToI      = vec3 (0.596, -0.275, -0.321);
			const vec3  kRGBToQ      = vec3 (0.212, -0.523, 0.311);
		
			const vec3  kYIQToR     = vec3 (1.0, 0.956, 0.621);
			const vec3  kYIQToG     = vec3 (1.0, -0.272, -0.647);
			const vec3  kYIQToB     = vec3 (1.0, -1.107, 1.704);
		
			float   YPrime  = dot (color, kRGBToYPrime);
			float   I       = dot (color, kRGBToI);
			float   Q       = dot (color, kRGBToQ);
			float   hue     = atan (Q, I);
			float   chroma  = sqrt (I * I + Q * Q);
		
			hue += hueAdjust;
		
			Q = chroma * sin (hue);
			I = chroma * cos (hue);
		
			vec3    yIQ   = vec3 (YPrime, I, Q);
		
			return vec3( dot (yIQ, kYIQToR), dot (yIQ, kYIQToG), dot (yIQ, kYIQToB) );
		
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec4 ye = texture2D(bitmap, uv);
			vec3 transform = hueShift(vec3(ye.r, ye.g, ye.b), hue);
			ye.r = transform.r;
			ye.g = transform.g;
			ye.b = transform.b;
			gl_FragColor = ye;
		}')
	public function new()
	{
		super();
	}
}
