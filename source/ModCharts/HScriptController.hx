package modCharts;
import hscript.Parser.Parser;
import sys.io.File;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;
import openfl.display3D.textures.VideoTexture;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
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

class HScriptController extends LangController
{
	public static var parser:ParserEx = null;
	public static var interp:InterpEx = null;

	public function new() 
	{

	}

	public override function setVar(var_name : String, object : Dynamic)
	{
		interp.variables.set(var_name, object);
	}

	public override function getVar(var_name : String, ?type : String) : Dynamic 
	{
		return interp.variables.get(var_name);
	}

	public override function Open(path:String)
	{
		parser = new hscript.ParserEx();
		interp = new hscript.InterpEx();

		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("stepHit", function (step) {});
		interp.variables.set("start", function (song) {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerOneTurn", function () {});
		interp.variables.set("playerTwoSing", function (note, time) {});
		interp.variables.set("playerOneSing", function (note, time) {});
		interp.variables.set("keyPressed", function (key) {});
		interp.variables.set("keyReleased", function (key) {});
		interp.variables.set("playerOneMiss", function (note, time) {});
		interp.variables.set("playerTwoMiss", function (note, time) {});

		interp.variables.set("makeSprite", ModchartState.instance.makeChartSprite);
		interp.variables.set("changeDadCharacter", ModchartState.instance.changeDadCharacter);
		interp.variables.set("changeBoyfriendCharacter", ModchartState.instance.changeBoyfriendCharacter);
		interp.variables.set("getProperty", ModchartState.instance.getPropertyByName);

		interp.variables.set("setNoteWiggle", 
			function(wiggleId) {
				PlayState.instance.camNotes.setFilters([new ShaderFilter(ModchartState.instance.luaWiggles.get(wiggleId).shader)]);
			}
		);
		interp.variables.set("setSustainWiggle", 
			function(wiggleId) {
				PlayState.instance.camSustains.setFilters([new ShaderFilter(ModchartState.instance.luaWiggles.get(wiggleId).shader)]);
			}
		);
		interp.variables.set("createWiggle", 
			function(freq:Float,amplitude:Float,speed:Float) {
				var wiggle = new WiggleEffect();
				wiggle.waveAmplitude = amplitude;
				wiggle.waveSpeed = speed;
				wiggle.waveFrequency = freq;

				var id = Lambda.count(ModchartState.instance.luaWiggles) + 1 + "";

				ModchartState.instance.luaWiggles.set(id,wiggle);
				return id;
			}
		);

		interp.variables.set("setWiggleTime", 
			function(wiggleId:String,time:Float) {
				var wiggle = ModchartState.instance.luaWiggles.get(wiggleId);

				wiggle.shader.uTime.value = [time];
			}
		);

		interp.variables.set("setWiggleAmplitude", 
			function(wiggleId:String,amp:Float) {
				var wiggle = ModchartState.instance.luaWiggles.get(wiggleId);
				wiggle.waveAmplitude = amp;
			}
		);

		interp.variables.set("destroySprite", function(id:String) {
			var sprite = ModchartState.chartSprites.get(id);
			if (sprite == null)
				return false;
			PlayState.instance.removeObject(sprite);
			return true;
		});

		// hud/camera

		interp.variables.set("initBackgroundVideo", function(videoName:String) {
			trace('playing assets/videos/' + videoName + '.webm');
			PlayState.instance.backgroundVideo("assets/videos/" + videoName + ".webm");
		});

		interp.variables.set("pauseVideo", function() {
			if (!GlobalVideo.get().paused)
				GlobalVideo.get().pause();
		});

		interp.variables.set("resumeVideo", function() {
			if (GlobalVideo.get().paused)
				GlobalVideo.get().pause();
		});
		
		interp.variables.set("restartVideo", function() {
			GlobalVideo.get().restart();
		});

		interp.variables.set("getVideoSpriteX", function() {
			return PlayState.instance.videoSprite.x;
		});

		interp.variables.set("getVideoSpriteY", function() {
			return PlayState.instance.videoSprite.y;
		});

		interp.variables.set("setVideoSpritePos", function(x:Int,y:Int) {
			PlayState.instance.videoSprite.setPosition(x,y);
		});
		
		interp.variables.set("setVideoSpriteScale", function(scale:Float) {
			PlayState.instance.videoSprite.setGraphicSize(Std.int(PlayState.instance.videoSprite.width * scale));
		});

		interp.variables.set("setHudAngle", function (x:Float) {
			PlayState.instance.camHUD.angle = x;
		});
		
		interp.variables.set("setHealth", function (heal:Float) {
			PlayState.instance.health = heal;
		});

		interp.variables.set("setHudPosition", function (x:Int, y:Int) {
			PlayState.instance.camHUD.x = x;
			PlayState.instance.camHUD.y = y;
		});

		interp.variables.set("getHudX", function () {
			return PlayState.instance.camHUD.x;
		});

		interp.variables.set("getHudY", function () {
			return PlayState.instance.camHUD.y;
		});
		
		interp.variables.set("setCamPosition", function (x:Int, y:Int) {
			FlxG.camera.x = x;
			FlxG.camera.y = y;
		});

		interp.variables.set("getCameraX", function () {
			return FlxG.camera.x;
		});

		interp.variables.set("getCameraY", function () {
			return FlxG.camera.y;
		});

		interp.variables.set("setCamZoom", function(zoomAmount:Float) {
			FlxG.camera.zoom = zoomAmount;
		});

		interp.variables.set("setHudZoom", function(zoomAmount:Float) {
			PlayState.instance.camHUD.zoom = zoomAmount;
		});

		// strumline

		interp.variables.set( "setStrumlineY", function(y:Float)
		{
			PlayState.instance.strumLine.y = y;
		});

		// actors
		
		interp.variables.set("getRenderedNotes", function() {
			return PlayState.instance.notes.length;
		});

		interp.variables.set("getRenderedNoteX", function(id:Int) {
			return PlayState.instance.notes.members[id].x;
		});

		interp.variables.set("getRenderedNoteY", function(id:Int) {
			return PlayState.instance.notes.members[id].y;
		});

		interp.variables.set("getRenderedNoteType", function(id:Int) {
			return PlayState.instance.notes.members[id].noteData;
		});

		interp.variables.set("isSustain", function(id:Int) {
			return PlayState.instance.notes.members[id].isSustainNote;
		});

		interp.variables.set("isParentSustain", function(id:Int) {
			return PlayState.instance.notes.members[id].prevNote.isSustainNote;
		});

		
		interp.variables.set("getRenderedNoteParentX", function(id:Int) {
			return PlayState.instance.notes.members[id].prevNote.x;
		});

		interp.variables.set("getRenderedNoteParentY", function(id:Int) {
			return PlayState.instance.notes.members[id].prevNote.y;
		});

		interp.variables.set("getRenderedNoteHit", function(id:Int) {
			return PlayState.instance.notes.members[id].mustPress;
		});

		interp.variables.set("getRenderedNoteCalcX", function(id:Int) {
			if (PlayState.instance.notes.members[id].mustPress)
				return PlayState.playerStrums.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
			return PlayState.strumLineNotes.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
		});

		interp.variables.set("anyNotes", function() {
			return PlayState.instance.notes.members.length != 0;
		});

		interp.variables.set("getRenderedNoteStrumtime", function(id:Int) {
			return PlayState.instance.notes.members[id].strumTime;
		});

		interp.variables.set("getRenderedNoteScaleX", function(id:Int) {
			return PlayState.instance.notes.members[id].scale.x;
		});

		interp.variables.set("setRenderedNotePos", function(x:Float,y:Float, id:Int) {
			if (PlayState.instance.notes.members[id] == null)
				throw('error! you cannot set a rendered notes position when it doesnt exist! ID: ' + id);
			else
			{
				PlayState.instance.notes.members[id].modifiedByLua = true;
				PlayState.instance.notes.members[id].x = x;
				PlayState.instance.notes.members[id].y = y;
			}
		});

		interp.variables.set("setRenderedNoteAlpha", function(alpha:Float, id:Int) {
			PlayState.instance.notes.members[id].modifiedByLua = true;
			PlayState.instance.notes.members[id].alpha = alpha;
		});

		interp.variables.set("setRenderedNoteScale", function(scale:Float, id:Int) {
			PlayState.instance.notes.members[id].modifiedByLua = true;
			PlayState.instance.notes.members[id].setGraphicSize(Std.int(PlayState.instance.notes.members[id].width * scale));
		});

		interp.variables.set("setRenderedNoteScale", function(scaleX:Int, scaleY:Int, id:Int) {
			PlayState.instance.notes.members[id].modifiedByLua = true;
			PlayState.instance.notes.members[id].setGraphicSize(scaleX,scaleY);
		});

		interp.variables.set("getRenderedNoteWidth", function(id:Int) {
			return PlayState.instance.notes.members[id].width;
		});


		interp.variables.set("setRenderedNoteAngle", function(angle:Float, id:Int) {
			PlayState.instance.notes.members[id].modifiedByLua = true;
			PlayState.instance.notes.members[id].angle = angle;
		});

		interp.variables.set("setActorX", function(x:Int,id:String) {
			ModchartState.instance.getActorByName(id).x = x;
		});
		
		interp.variables.set("setActorAccelerationX", function(x:Int,id:String) {
			ModchartState.instance.getActorByName(id).acceleration.x = x;
		});
		
		interp.variables.set("setActorDragX", function(x:Int,id:String) {
			ModchartState.instance.getActorByName(id).drag.x = x;
		});
		
		interp.variables.set("setActorVelocityX", function(x:Int,id:String) {
			ModchartState.instance.getActorByName(id).velocity.x = x;
		});
		
		interp.variables.set("playActorAnimation", function(id:String,anim:String,force:Bool = false,reverse:Bool = false) {
			ModchartState.instance.getActorByName(id).playAnim(anim, force, reverse);
		});

		interp.variables.set("setActorAlpha", function(alpha:Float,id:String) {
			ModchartState.instance.getActorByName(id).alpha = alpha;
		});

		interp.variables.set("setActorY", function(y:Int,id:String) {
			ModchartState.instance.getActorByName(id).y = y;
		});

		interp.variables.set("setActorAccelerationY", function(y:Int,id:String) {
			ModchartState.instance.getActorByName(id).acceleration.y = y;
		});
		
		interp.variables.set("setActorDragY", function(y:Int,id:String) {
			ModchartState.instance.getActorByName(id).drag.y = y;
		});
		
		interp.variables.set("setActorVelocityY", function(y:Int,id:String) {
			ModchartState.instance.getActorByName(id).velocity.y = y;
		});
		
		interp.variables.set("setActorAngle", function(angle:Int,id:String) {
			ModchartState.instance.getActorByName(id).angle = angle;
		});

		interp.variables.set("setActorScale", function(scale:Float,id:String) {
			ModchartState.instance.getActorByName(id).setGraphicSize(Std.int(ModchartState.instance.getActorByName(id).width * scale));
		});
		
		interp.variables.set( "setActorScaleXY", function(scaleX:Float, scaleY:Float, id:String)
		{
			ModchartState.instance.getActorByName(id).setGraphicSize(Std.int(ModchartState.instance.getActorByName(id).width * scaleX), Std.int(ModchartState.instance.getActorByName(id).height * scaleY));
		});

		interp.variables.set( "setActorFlipX", function(flip:Bool, id:String)
		{
			ModchartState.instance.getActorByName(id).flipX = flip;
		});

		interp.variables.set( "setActorFlipY", function(flip:Bool, id:String)
		{
			ModchartState.instance.getActorByName(id).flipY = flip;
		});

		interp.variables.set("getActorWidth", function (id:String) {
			return ModchartState.instance.getActorByName(id).width;
		});

		interp.variables.set("getActorHeight", function (id:String) {
			return ModchartState.instance.getActorByName(id).height;
		});

		interp.variables.set("getActorAlpha", function(id:String) {
			return ModchartState.instance.getActorByName(id).alpha;
		});

		interp.variables.set("getActorAngle", function(id:String) {
			return ModchartState.instance.getActorByName(id).angle;
		});

		interp.variables.set("getActorX", function (id:String) {
			return ModchartState.instance.getActorByName(id).x;
		});

		interp.variables.set("getActorY", function (id:String) {
			return ModchartState.instance.getActorByName(id).y;
		});

		interp.variables.set("setWindowPos",function(x:Int,y:Int) {
			Application.current.window.x = x;
			Application.current.window.y = y;
		});

		interp.variables.set("getWindowX",function() {
			return Application.current.window.x;
		});

		interp.variables.set("getWindowY",function() {
			return Application.current.window.y;
		});

		interp.variables.set("resizeWindow",function(Width:Int,Height:Int) {
			Application.current.window.resize(Width,Height);
		});
		
		interp.variables.set("getScreenWidth",function() {
			return Application.current.window.display.currentMode.width;
		});

		interp.variables.set("getScreenHeight",function() {
			return Application.current.window.display.currentMode.height;
		});

		interp.variables.set("getWindowWidth",function() {
			return Application.current.window.width;
		});

		interp.variables.set("getWindowHeight",function() {
			return Application.current.window.height;
		});

		//trace

		interp.variables.set("trace",function(thing:Dynamic) {
			trace(thing);
		});

		var ast = parser.parseString(sys.io.File.getContent(path));
		interp.execute(ast);
	}

	public override function call(func_name : String, args : Array<Dynamic>, ?type : String):Void
	{
		if (!interp.variables.exists(func_name)) {
			trace("Function doesn't exist, silently skipping...");
			return;
		}
		var method = interp.variables.get(func_name);
		switch(args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
			case 2:
				method(args[0], args[1]);
			case 3:
				method(args[0], args[1], args[2]);
		}
	}
}