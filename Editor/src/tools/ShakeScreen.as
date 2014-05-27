package tools {
	
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class ShakeScreen {
		
		//shakescreen variables
		private var shaking:Boolean = false;
		private var shakelength:int = 0;
		private var shakepower:int = 0;
		private var timer:int = 0;
		private var originX:int = 0;
		private var originY:int = 0;
		
		public function shake(power:int = 15, length:int = 15):void {
			shaking = true;
			shakepower = power;
			shakelength = length;
			timer = 0;
			originX = Main.player.x;
			originY = Main.player.y;
		}
		
		public function update():void {
			if (shaking && !Main.mapcamera.paused) {
				var destx:int = Math.random() * shakepower - Math.random() * shakepower;
				var desty:int = Math.random() * shakepower - Math.random() * shakepower;
				
				++timer;
				if (timer >= shakelength) {
					timer = 0;
					shaking = false;
					Main.mapcamera.moveTo(originX, originY);
				}
				
				Main.screen.x += destx;
				Main.screen.y += desty;
			}
		}
	}
}