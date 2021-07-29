package;
import openfl.geom.Vector3D;
import flixel.util.FlxColor;
import ColorSwap.ColorSwapEffect;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;

class NoteSplash extends FlxSprite {
	public var colorSwap:ColorSwapEffect;
	public function new(xPos:Float,yPos:Float,?c:Int, ?isOtherPlayer:Bool = false) {
		if (c == null) c = 0;
		super(xPos,yPos);

		colorSwap = new ColorSwapEffect();
		shader = colorSwap.shader;
		colorSwap.ignorewhite = true;
		colorSwap.active = true;

		if(FlxG.save.data.antialiasing)
		{
			antialiasing = true;
		}
		
		frames = Paths.getSparrowAtlas('noteSplashes', 'shared');
		animation.addByPrefix("note1-0", "note impact 1  blue", 24, false);
		animation.addByPrefix("note2-0", "note impact 1 green", 24, false);
		animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
		animation.addByPrefix("note3-0", "note impact 1 red", 24, false);

		animation.addByPrefix("note1-1", "note impact 2 blue", 24, false);
		animation.addByPrefix("note2-1", "note impact 2 green", 24, false);
		animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
		animation.addByPrefix("note3-1", "note impact 2 red", 24, false);
		/*if(FlxG.save.data.middleScroll && isOtherPlayer)
		{
			setGraphicSize(Std.int(width * 0.5), Std.int(height * 0.5));
		}*/
		setupNoteSplash(xPos,xPos,c);
	}
	public function setupNoteSplash(xPos:Float, yPos:Float, ?c:Int) {
		if (c == null) c = 0;
		setPosition(xPos, yPos);
		var arrowColors:Array<FlxColor> = 
		[
			FlxG.save.data.leftColor,
			FlxG.save.data.downColor,
			FlxG.save.data.upColor,
			FlxG.save.data.rightColor
		];
		colorSwap.col = new Vector3D(arrowColors[c].red, arrowColors[c].green, arrowColors[c].blue);
		alpha = 0.6;
		animation.play("note"+c+"-"+FlxG.random.int(0,1), true);
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
		updateHitbox();
		offset.set(0.3 * width, 0.3 * height);
	}
	override public function update(elapsed) {
		if (animation.curAnim.finished) {
			// club pengiun is
			kill();
		}
		super.update(elapsed);
	}
}