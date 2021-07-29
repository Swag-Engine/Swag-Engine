package;

import lime.system.BackgroundWorker;
import openfl.geom.Vector3D;
import flixel.system.FlxAssets.FlxShader;

class ColorSwapEffect
{
	public var shader(default, null):ColorSwapShader = new ColorSwapShader();
	public var col(default, set):Vector3D;
	public var active(default, set):Bool;
	public var ignorewhite(default, set):Bool;

	function set_active(v:Bool):Bool
	{
		active = v;
		shader.active.value = [v];
		return v;
	}

	function set_ignorewhite(v:Bool):Bool
	{
		ignorewhite = v;
		shader.ignorewhite.value = [v];
		return v;
	}

	function set_col(v:Vector3D):Vector3D
	{
		col = v;
		shader.r.value = [v.x];
		shader.g.value = [v.y];
		shader.b.value = [v.z];
		return v;
	}

	public function new():Void
	{
	}
}

class ColorSwapShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform bool active;
		uniform bool ignorewhite;
		uniform float r;
		uniform float g;
		uniform float b;

		vec4 normalizeColor(vec4 color)
		{
			return vec4(color[0] / 255.0,color[1] / 255.0,color[2] / 255.0, color[3]);
		}
		vec3 normalizeColor2(vec3 color)
		{
			return vec3(color[0] / 255.0,color[1] / 255.0,color[2] / 255.0);
		}

		vec3 rgb2hsv(vec3 c)
		{
			vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
			vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
			float d = q.x - min(q.w, q.y);
			float e = 1.0e-10;
			return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		vec3 hsv2rgb(vec3 c)
		{
			vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
			return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}

		void main()
		{
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
			if(active)
			{
				vec4 swagColor = vec4(rgb2hsv(vec3(color[0], color[1], color[2])), color[3]);
				// [0] is the hue???
				color = vec4(hsv2rgb(vec3(swagColor[0], swagColor[1], swagColor[2])), swagColor[3]);
				vec3 s = rgb2hsv(normalizeColor(color));
				if((!(s[2] > 0.8) && !(s[1] < 0.1)))
				{
					vec3 rgb = rgb2hsv(normalizeColor2(vec3(r, g, b)));
					vec3 current = rgb2hsv(vec3(color[0], color[1], color[2]));
					vec3 new = hsv2rgb(vec3(rgb[0], rgb[1], min(rgb[2]*(current[2]/rgb[2]), rgb[2])));
					color = vec4(new[0]*rgb[2], new[1]*rgb[2], new[2]*rgb[2], color[3]);
				}
				else
				{
					if(!ignorewhite)
					{
						vec3 rgb = rgb2hsv(vec3(r, g, b));
						vec3 current = rgb2hsv(vec3(color[0], color[1], color[2]));
						vec3 new = hsv2rgb(vec3(rgb[0], rgb[1], min(rgb[2]*(current[2]/rgb[2]), rgb[2])));
						color = vec4(new[0], new[1], new[2], color[3]);
					}
				}
			}
			gl_FragColor = color;
		}
		'
	)
	public function new()
	{
		super();
	}
}
