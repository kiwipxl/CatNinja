package managers {
	
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class MouseManager {
		
		//mousemanager variables
		public var mouseIsDown:Boolean = false;
		
		public function initiate():void {
			Main.universe.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			Main.universe.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		private function mouseDown(event:MouseEvent):void {
			mouseIsDown = true;
		}
		
		private function mouseUp(event:MouseEvent):void {
			mouseIsDown = false;
		}
	}
}