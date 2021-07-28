package;

import flixel.util.FlxTimer;
import haxe.Timer;
import flixel.FlxState;
import flixel.FlxG;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
import openfl.utils.Assets;

using StringTools;

class VideoState extends MusicBeatState {
	public var leSource:String = "";
	public var transClass:FlxState;
	public var txt:FlxText;
	public var fuckingVolume:Float = 1;
	public var notDone:Bool = true;
	public var vidSound:FlxSound;
	public var useSound:Bool = false;
	public var soundMultiplier:Float = 1;
	public var prevSoundMultiplier:Float = 1;
	public var videoFrames:Int = 0;
	public var videoFrameRate:Int = 0;
	public var prevFrameRate:Int = 0;
	public var defaultText:String = "";
	public var doShit:Bool = false;
	public var wait:Float = 0;

	public function new(source:String, toTrans:FlxState, ?waitTime:Float)
	{
		super();

		trace(source);
		trace(source.replace(".webm", "_FrameCount.txt"));
		trace(source.replace(".webm", "_FrameRate.txt"));
		
		wait = waitTime;
		leSource = source;
		transClass = toTrans;
	}
	
	override function create()
	{
		super.create();
		FlxG.autoPause = false;
		doShit = false;
		
		if (GlobalVideo.isWebm)
		{
			videoFrames = Std.parseInt(sys.io.File.getContent(leSource.replace(".webm", "_FrameCount.txt")));
			videoFrameRate = Std.parseInt(sys.io.File.getContent(leSource.replace(".webm", "_FrameRate.txt")));
		}
		
		fuckingVolume = FlxG.sound.music.volume;
		FlxG.sound.music.volume = 0;
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		txt = new FlxText(0, 0, FlxG.width,
			defaultText,
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
		
		var audioExtension:String = ".mp3";
		#if windows
		audioExtension = ".ogg";
		#end
		if (GlobalVideo.isWebm)
		{
			if (Assets.exists(leSource.replace(".webm", audioExtension), MUSIC) || Assets.exists(leSource.replace(".webm", audioExtension), SOUND))
			{
				useSound = true;
				vidSound = FlxG.sound.play(leSource.replace(".webm", audioExtension));
			}
		}

		GlobalVideo.get().source(leSource);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		prevFrameRate = FlxG.drawFramerate;
		FlxG.drawFramerate = videoFrameRate;
		GlobalVideo.get().show();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		} else {
			GlobalVideo.get().play();
		}

		vidSound.time = vidSound.length * soundMultiplier;
		doShit = true;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (useSound)
		{
			var wasFuckingHit = GlobalVideo.get().webm.wasHitOnce;
			soundMultiplier = GlobalVideo.get().webm.renderedCount / videoFrames;
			
			if (soundMultiplier > 1)
			{
				soundMultiplier = 1;
			}
			if (soundMultiplier < 0)
			{
				soundMultiplier = 0;
			}
			if (doShit)
			{
				var compareShit:Float = 50;
				if (vidSound.time >= (vidSound.length * soundMultiplier) + compareShit || vidSound.time <= (vidSound.length * soundMultiplier) - compareShit)
					vidSound.time = vidSound.length * soundMultiplier;
			}
			if (wasFuckingHit)
			{
			if (soundMultiplier == 0)
			{
				if (prevSoundMultiplier != 0)
				{
					vidSound.pause();
					vidSound.time = 0;
				}
			} else {
				if (prevSoundMultiplier == 0)
				{
					vidSound.resume();
					vidSound.time = vidSound.length * soundMultiplier;
				}
			}
			prevSoundMultiplier = soundMultiplier;
			}
		}
		
		if (notDone)
		{
			FlxG.sound.music.volume = 0;
		}
		GlobalVideo.get().update(elapsed);

		if (controls.RESET)
		{
			GlobalVideo.get().restart();
		}
		
		if (GlobalVideo.get().ended || GlobalVideo.get().stopped)
		{
			FlxG.drawFramerate = prevFrameRate;
			txt.visible = false;
			GlobalVideo.get().hide();
			GlobalVideo.get().stop();
		}
		
		if (GlobalVideo.get().ended)
		{
			notDone = false;
			FlxG.sound.music.volume = fuckingVolume;
			FlxG.autoPause = true;
			FlxG.drawFramerate = prevFrameRate;
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				FlxG.switchState(transClass);
			});
		}
		
		if (GlobalVideo.get().played || GlobalVideo.get().restarted)
		{
			GlobalVideo.get().show();
		}
		
		GlobalVideo.get().restarted = false;
		GlobalVideo.get().played = false;
		GlobalVideo.get().stopped = false;
		GlobalVideo.get().ended = false;
	}
}