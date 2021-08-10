package modCharts;
//IGNORE THIS FOR NOW
// this file is for modchart things, this is to declutter playstate.hx

// Chart
import openfl.display3D.textures.VideoTexture;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
#if windows
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.app.Application;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
using StringTools;

class ModchartState 
{
	//public static var shaders:Array<ChartShader> = null;

	public var luaWiggles:Map<String,WiggleEffect> = new Map<String,WiggleEffect>();

	public static var langController:LangController = null;
	public static var instance:ModchartState = null;

	public function callChart(func_name : String, args : Array<Dynamic>, ?type : String)
	{
		langController.call(func_name, args, type);
	}

	public function getVar(func_name : String, ?type : String) : Dynamic
	{
		return langController.getVar(func_name, type);
	}
	public function setVar(var_name : String, object : Dynamic)
	{
		langController.setVar(var_name, object);
	}

	public function getActorByName(id:String):Dynamic
	{
		// pre defined names
		switch(id)
		{
			case 'boyfriend':
                @:privateAccess
				return PlayState.boyfriend;
			case 'girlfriend':
                @:privateAccess
				return PlayState.gf;
			case 'dad':
                @:privateAccess
				return PlayState.dad;
		}
		// chart objects or what ever
		if (chartSprites.get(id) == null)
		{
			if (Std.parseInt(id) == null)
				return Reflect.getProperty(PlayState.instance,id);
			return PlayState.PlayState.strumLineNotes.members[Std.parseInt(id)];
		}
		return chartSprites.get(id);
	}

	public function getPropertyByName(id:String)
	{
		return Reflect.field(PlayState.instance,id);
	}

	public static var chartSprites:Map<String,FlxSprite> = [];

	public function changeDadCharacter(id:String)
	{				var olddadx = PlayState.dad.x;
					var olddady = PlayState.dad.y;
					PlayState.instance.removeObject(PlayState.dad);
					PlayState.dad = new Character(olddadx, olddady, id);
					PlayState.instance.addObject(PlayState.dad);
					PlayState.instance.iconP2.animation.play(id);
	}

	public function changeBoyfriendCharacter(id:String)
	{				var oldboyfriendx = PlayState.boyfriend.x;
					var oldboyfriendy = PlayState.boyfriend.y;
					PlayState.instance.removeObject(PlayState.boyfriend);
					PlayState.boyfriend = new Boyfriend(oldboyfriendx, oldboyfriendy, id);
					PlayState.instance.addObject(PlayState.boyfriend);
					PlayState.instance.iconP2.animation.play(id);
	}

	public function makeAnimatedChartSprite(spritePath:String,names:Array<String>,prefixes:Array<String>,startAnim:String, id:String)
	{
		#if sys
		// pre lowercasing the song name (makeAnimatedChartSprite)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}

		var data:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/data/" + songLowercase + '/' + spritePath + ".png");

		var sprite:FlxSprite = new FlxSprite(0,0);

		sprite.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(data), Sys.getCwd() + "assets/data/" + songLowercase + "/" + spritePath + ".xml");

		trace(sprite.frames.frames.length);

		for (p in 0...names.length)
		{
			var i = names[p];
			var ii = prefixes[p];
			sprite.animation.addByPrefix(i,ii,24,false);
		}

		chartSprites.set(id,sprite);

        PlayState.instance.addObject(sprite);

		sprite.animation.play(startAnim);
		return id;
		#end
	}

	public function makeChartSprite(spritePath:String,toBeCalled:String, drawBehind:Bool)
	{
		#if sys
		// pre lowercasing the song name (makeChartSprite)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}

		var data:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/data/" + songLowercase + '/' + spritePath + ".png");

		var sprite:FlxSprite = new FlxSprite(0,0);
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

		// Cap the scale at x1
		if (scale > 1)
			scale = 1;

		sprite.makeGraphic(Std.int(data.width * scale),Std.int(data.width * scale),FlxColor.TRANSPARENT);

		var data2:BitmapData = sprite.pixels.clone();
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(scale, scale);
		data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		data2.draw(data, matrix, null, null, null, true);
		sprite.pixels = data2;
		
		chartSprites.set(toBeCalled,sprite);
		// and I quote:
		// shitty layering but it works!
        @:privateAccess
        {
            if (drawBehind)
            {
                PlayState.instance.removeObject(PlayState.gf);
                PlayState.instance.removeObject(PlayState.boyfriend);
                PlayState.instance.removeObject(PlayState.dad);
            }
            PlayState.instance.addObject(sprite);
            if (drawBehind)
            {
                PlayState.instance.addObject(PlayState.gf);
                PlayState.instance.addObject(PlayState.boyfriend);
                PlayState.instance.addObject(PlayState.dad);
            }
        }
		#end
		return toBeCalled;
	}

    public function die()
    {
        //Lua.close(chart);
		//chart = null;
    }

    // LUA SHIT

    function new()
    {
		instance = this;
        trace('opening a chart state (because we are cool :))');
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}
		
		if(Paths.modchart(songLowercase + "/modchart").endsWith(".hscript")) 
		{
			langController = new HScriptController();
		}
		else
		{
			langController = new LuaController();
		}

		var file = Paths.modchart(songLowercase + "/modchart");

		langController.Open(file);
		// get some fukin globals up in here bois
		langController.setVar("difficulty", PlayState.storyDifficulty);
		langController.setVar("bpm", Conductor.bpm);
		langController.setVar("scrollspeed", FlxG.save.data.scrollSpeed != 1 ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed);
		langController.setVar("fpsCap", FlxG.save.data.fpsCap);
		langController.setVar("downscroll", FlxG.save.data.downscroll);
		langController.setVar("flashing", FlxG.save.data.flashing);
		langController.setVar("distractions", FlxG.save.data.distractions);
		langController.setVar("curStep", 0);
		langController.setVar("curBeat", 0);
		langController.setVar("crochet", Conductor.stepCrochet);
		langController.setVar("safeZoneOffset", Conductor.safeZoneOffset);
		langController.setVar("hudZoom", PlayState.instance.camHUD.zoom);
		langController.setVar("cameraZoom", FlxG.camera.zoom);
		langController.setVar("cameraAngle", FlxG.camera.angle);
		langController.setVar("camHudAngle", PlayState.instance.camHUD.angle);
		langController.setVar("followXOffset",0);
		langController.setVar("followYOffset",0);
		langController.setVar("showOnlyStrums", false);
		langController.setVar("strumLine1Visible", true);
		langController.setVar("strumLine2Visible", true);
		langController.setVar("screenWidth",FlxG.width);
		langController.setVar("screenHeight",FlxG.height);
		langController.setVar("windowWidth",FlxG.width);
		langController.setVar("windowHeight",FlxG.height);
		langController.setVar("hudWidth", PlayState.instance.camHUD.width);
		langController.setVar("hudHeight", PlayState.instance.camHUD.height);
		langController.setVar("mustHit", false);
		langController.setVar("strumLineY", PlayState.instance.strumLine.y);
		
		// default strums
		for (i in 0...PlayState.strumLineNotes.length) {
			var member = PlayState.strumLineNotes.members[i];
			trace(PlayState.strumLineNotes.members[i].x + " " + PlayState.strumLineNotes.members[i].y + " " + PlayState.strumLineNotes.members[i].angle + " | strum" + i);
			//setVar("strum" + i + "X", Math.floor(member.x));
			langController.setVar("defaultStrum" + i + "X", Math.floor(member.x));
			//setVar("strum" + i + "Y", Math.floor(member.y));
			langController.setVar("defaultStrum" + i + "Y", Math.floor(member.y));
			//setVar("strum" + i + "Angle", Math.floor(member.angle));
			langController.setVar("defaultStrum" + i + "Angle", Math.floor(member.angle));
			trace("Adding strum" + i);
		}
    }

    public function executeState(name,args:Array<Dynamic>)
    {
        langController.call(name, args);
    }

    public static function createModchartState():ModchartState
    {
        return new ModchartState();
    }
}
#end
