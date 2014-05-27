package managers {
	
	import flash.display.StageQuality;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import tools.text.DisplayText;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class KeyboardManager {
		
		//keyboard manager
		public var leftKeyDown:Boolean = false;
		public var rightKeyDown:Boolean = false;
		public var upKeyDown:Boolean = false;
		public var downKeyDown:Boolean = false;
		public var spaceKeyDown:Boolean = false;
		public var afkmessage:DisplayText;
		
		public function initiate():void {
			Main.universe.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			Main.universe.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		}
		
		private function keyDown(event:KeyboardEvent):void {
			var key:int = event.keyCode;
			
			if (key == 37 || key == 65) {
				leftKeyDown = true;
			}
			if (key == 38 || key == 87) {
				if (!upKeyDown) {
					Main.player.upKeyDown();
				}
				if (!upKeyDown) { upKeyDown = true; }
			}
			if (key == 39 || key == 68) {
				rightKeyDown = true;
			}
			if (key == 40 || key == 83) {
				downKeyDown = true;
			}
			if (key == 32 && !spaceKeyDown) {
				spaceKeyDown = true;
			}
			if (key == 82 && !Main.player.stopMovement) {
				Main.player.die();
			}
			
			if (!Main.env.screenmanager.pressedkey) {
				Main.env.screenmanager.pressedkey = true;
				Main.time.remove(Main.env.screenmanager.timer);
			}
		}
		
		private function keyUp(event:KeyboardEvent):void {
			var key:int = event.keyCode;
			
			if (key == 37 || key == 65) {
				leftKeyDown = false;
			}
			if (key == 38 || key == 87) {
				upKeyDown = false;
			}
			if (key == 39 || key == 68) {
				rightKeyDown = false;
			}
			if (key == 40 || key == 83) {
				downKeyDown = false;
			}
			if (key == 32) {
				spaceKeyDown = false;
				Main.player.togglejetpack();
			}
			if (key == 49) {
				Main.universe.stage.quality = StageQuality.LOW;
			}else if (key == 50) {
				Main.universe.stage.quality = StageQuality.MEDIUM;
			}else if (key == 51) {
				Main.universe.stage.quality = StageQuality.HIGH;
			}else if (key == 54) {
				Main.universe.stage.quality = StageQuality.BEST;
			}
			
			if (Main.env.screenmanager.pressedkey) {
				Main.env.screenmanager.pressedkey = false;
				Main.env.screenmanager.timer = Main.time.runFunctionIn(10000, function():void {
					afkmessage = Main.text.screenmessage("", Main.env.screenmanager.idle, "2D95EA", true, 540, 40);
				}, true);
			}else {
				if (afkmessage) { Main.text.removemessage(afkmessage); }
			}
		}
	}
}