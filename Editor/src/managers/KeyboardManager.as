package managers {
	
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	
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
		
		public function initiate():void {
			Main.universe.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			Main.universe.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		}
		
		private function keyDown(event:KeyboardEvent):void {
			if (Main.transition.created) { return; }
			var key:int = event.keyCode;
			
			if (key == 37 || key == 65) {
				leftKeyDown = true;
			}
			if (key == 38 || key == 87) {
				if (!upKeyDown && !Main.mapeditor.created) {
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
			if (key == 13) {
				Main.info.inputlog();
			}
			if (key == 82 && Main.testing && !Main.player.stopMovement && !Main.gamepaused) {
				Main.player.die();
			}
			if (key == 85 && Main.testing && !Main.player.stopMovement) {
				Main.mapmanager.resetgame();
			}
		}
		
		private function keyUp(event:KeyboardEvent):void {
			if (Main.transition.created) { return; }
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
			if (key == 192) {
				Main.info.toggleConsole();
			}
		}
	}
}