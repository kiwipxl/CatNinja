package tools.animation {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class AnimateControl {
		
		//animatecontrol variables
		public var base:Bitmap;
		public var frames:Array = [];
		public var framespeed:int = 0;
		public var currentframe:int = 0;
		private var timer:int = 0;
		private var paused:Boolean = false;
		public var state:int = 0;
		public var states:Boolean = false;
		public var reverse:Boolean = false;
		public var loop:Boolean = true;
		
		public function update():void {
			if (paused) {
				return;
			}
			
			++timer;
			if (timer >= framespeed) {
				updateFrame();
				
				if (!reverse) { ++currentframe; 
					if (loop && !states && currentframe >= frames.length || loop && states && currentframe >= frames[state].length) {
						currentframe = 0;
					}
					if (currentframe >= frames.length) { currentframe = frames.length - 1; }
				}else { --currentframe;
					if (loop && !states && currentframe < 0) {
						currentframe = frames.length - 1;
					}
					if (currentframe < 0) { currentframe = 0; }
				}
				timer = 0;
			}
		}
		
		public function updateFrame():void {
			var data:BitmapData;
			if (states) {
				data = frames[state][currentframe];
				if (data != null) { base.bitmapData = frames[state][currentframe]; }
			}else {
				data = frames[currentframe];
				if (data != null) { base.bitmapData = frames[currentframe]; }
			}
		}
		
		public function pause():void {
			paused = true;
		}
		
		public function play():void {
			paused = false;
			updateFrame();
		}
	}
}