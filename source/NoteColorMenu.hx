package;

/// Code created by Rozebud for FPS Plus (thanks rozebud)
// modified by KadeDev for use in Kade Engine/Tricky

import lime.math.ARGB;
import openfl.geom.Vector3D;
import ColorSwap.ColorSwapEffect;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;


using StringTools;

class NoteColorMenu extends FlxSubState
{
	var colorText:Array<String> = ["R", "G", "B"];
	var curSelected:Int = 0;
	var colorTextDisplay:FlxText;
	var noteColor:Int;
	var blackBox:FlxSprite;
	var colors:Array<Array<Int>>;
	var preview:FlxSprite;
	var colorSwap:ColorSwapEffect;

	function colorToArray(color:FlxColor):Array<Int> 
	{
		return [color.red, color.green, color.blue, color.alpha];
	}

	function arrayToColor(color:Array<Int> ):FlxColor
	{
		return FlxColor.fromRGB(color[0], color[1], color[2], color[3]);
	}

	var defaultColors:Array<FlxColor> = 
	[
		FlxColor.fromRGB(126, 106, 181),
		FlxColor.fromRGB(0, 255, 255),
		FlxColor.fromRGB(18, 250, 5),
		FlxColor.fromRGB(249, 57, 63)
	];

	public override function new(_noteColor:Int)
	{
		super();
		noteColor = _noteColor;
	}

	function updateColors()
	{
		colorSwap.col = new Vector3D(colors[noteColor][0], colors[noteColor][1], colors[noteColor][2]);
	}

	override function create()
	{	
		colors = 
		[
			colorToArray(FlxG.save.data.leftColor),
			colorToArray(FlxG.save.data.downColor),
			colorToArray(FlxG.save.data.upColor),
			colorToArray(FlxG.save.data.rightColor)
		];
		for (i in 0...colors.length)
		{
			var k = colors[i];
			if (k == null)
				colors[i] = colorToArray(defaultColors[i]);
		}

		persistentUpdate = true;

		preview = new FlxSprite(FlxG.width/2 + 100, FlxG.height/2);
		preview.frames = Paths.getSparrowAtlas('skins/' + FlxG.save.data.noteSkin, 'shared');

		colorSwap = new ColorSwapEffect();
		preview.shader = this.colorSwap.shader;
		updateColors();
		colorSwap.ignorewhite = true;
		colorSwap.active = true;
		
		var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
		for (i in 0...4)
		{
			preview.animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
			preview.animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
			preview.animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
		}

		preview.animation.play(dataColor[noteColor] + 'Scroll');

		colorTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		colorTextDisplay.scrollFactor.set(0, 0);
		colorTextDisplay.setFormat("VCR OSD Mono", 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		colorTextDisplay.borderSize = 2;
		colorTextDisplay.borderQuality = 3;

		blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
		add(blackBox);
		add(preview);
		add(colorTextDisplay);

		blackBox.alpha = 0;
		colorTextDisplay.alpha = 0;
		preview.alpha = 0;

		FlxTween.tween(preview, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(colorTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

		OptionsMenu.instance.acceptInput = false;

		textUpdate();

		super.create();
	}
	override function update(elapsed:Float)
	{
		if(FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
		
	}

	function textUpdate()
	{
		var shift:Bool = FlxG.keys.pressed.SHIFT;
		if(FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
		{
			colors[noteColor][curSelected] -= (shift ? 1 : 10);
			if(colors[noteColor][curSelected] < 0)
				colors[noteColor][curSelected] = 255;
			if(colors[noteColor][curSelected] > 255)
				colors[noteColor][curSelected] = 0;
		}
		if(FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
		{
			colors[noteColor][curSelected] += (shift ? 1 : 10);
			if(colors[noteColor][curSelected] < 0)
				colors[noteColor][curSelected] = 255;
			if(colors[noteColor][curSelected] > 255)
				colors[noteColor][curSelected] = 0;
		}
		if(FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
		{
			curSelected--;
			if(curSelected < 0)
				curSelected = 2;
			if(curSelected > 2)
				curSelected = 0;
		}
		if(FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
		{
			curSelected++;
			if(curSelected < 0)
				curSelected = 2;
			if(curSelected > 2)
				curSelected = 0;
		}
		if(FlxG.keys.justPressed.ENTER)
		{
			quit();
		}
		colorTextDisplay.text = "\n\n";

		for(i in 0...3){

			var textStart = (i == curSelected) ? "> " : "  ";
			colorTextDisplay.text += textStart + " " + colors[noteColor][i] + "\n";
		}

		colorTextDisplay.screenCenter();
		updateColors();
	}

	function save(){

		FlxG.save.data.upColor = arrayToColor(colors[2]);
		FlxG.save.data.downColor = arrayToColor(colors[1]);
		FlxG.save.data.leftColor = arrayToColor(colors[0]);
		FlxG.save.data.rightColor = arrayToColor(colors[3]);

		FlxG.save.flush();
	}

	function reset(){

		for(i in 0...5){
			colors[i] = colorToArray(defaultColors[i]);
		}
		quit();

	}

	function quit()
	{
		save();

		OptionsMenu.instance.acceptInput = true;

		FlxTween.tween(preview, {x: FlxG.width}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(colorTextDisplay, {x: FlxG.width}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(flx:FlxTween){close();}});
	}

	function changeItem(_amount:Int = 0)
	{
		curSelected += _amount;
				
		if (curSelected > 3)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 3;
	}
}
