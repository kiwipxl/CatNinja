package environment {
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import tools.TimeCounter;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class ScreenManager {
		
		//environment manager variables
		public var screens:Vector.<Screen> = new Vector.<Screen>;
		public var pressedkey:Boolean = true;
		public var timer:TimeCounter;
		public const idle:Array = ["HEY. Don't leave me",  "Where did you go?", "Don't you dare leave me.", "Help, don't leave me!"];
		public const respawn:Array = ["It's a shame you feel pain", "How did you die to that?", "You are bad and you should feel bad", 
		"That must have hurt", "Where did your paws go?<br>Oh, found them.", "Wow, you are a really bad kitty", "Come on, you really suck at this game.",
		"Stupid kitty.", "Silly kitty."];
		
		public function createScreen(x:int, y:int):void {
			var screen:Screen = new Screen();
			screen.x = x;
			screen.y = y;
			Main.screen.addChild(screen);
			screens.push(screen);
		}
		
		public function getRandomScreenMessage(screenmessage:Array):String {
			return screenmessage[int(Math.random() * screenmessage.length)];
		}
		
		public function updateAllScreensNear(x:int, y:int, radius:int, message:String, randomMessage:Boolean = false, from:Array = null):void {
			for (var c:int = 0; c < screens.length; ++c) {
				if (screens[c].x >= x - radius && screens[c].x <= x + radius &&
				screens[c].y >= y - radius && screens[c].y <= y + radius) {
					if (randomMessage) {
						message = getRandomScreenMessage(from);
					}
					screens[c].updateDisplay(message);
				}
			}
		}
		
		public function drawAllScreens():void {
			for (var c:int = 0; c < screens.length; ++c) {
				Main.map.mapdata.copyPixels(Main.textures.screen, new Rectangle(0, 0, 120, 60), new Point(screens[c].x, screens[c].y));
			}
		}
		
		public function updateScreen(id:int, message:String, rotation:int = 0):void {
			if (id == -1) {
				for (var c:int = 0; c < screens.length; ++c) {
					screens[c].updateDisplay(message, rotation);
				}
			}else {
				screens[id].updateDisplay(message, rotation);
			}
		}
	}
}