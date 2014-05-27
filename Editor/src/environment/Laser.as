package environment {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Laser {
		
		//laser variables
		public var on:Boolean = false;
		public var from:Point = new Point();
		public var to:Point = new Point();
		private var machinegraphic1:int = 0;
		private var machinegraphic2:int = 0;
		private var machinegraphicoff1:int = 0;
		private var machinegraphicoff2:int = 0;
		private var lasergraphic:int = 0;
		
		public function Laser(delay:int):void {
			Main.time.runFunctionIn(delay, switchLaser, true);
		}
		
		public function calculateDirection():void {
			if (from.x - to.x > 0) {
				machinegraphic1 = 12;
				machinegraphic2 = 11;
				machinegraphicoff1 = 21;
				machinegraphicoff2 = 22;
				lasergraphic = 15;
				return;
			}else if (from.x - to.x < 0) {
				machinegraphic1 = 11;
				machinegraphic2 = 12;
				machinegraphicoff1 = 21;
				machinegraphicoff2 = 22;
				lasergraphic = 15;
				return;
			}
			
			if (from.y - to.y > 0) {
				machinegraphic1 = 13;
				machinegraphic2 = 10;
				machinegraphicoff1 = 20;
				machinegraphicoff2 = 23;
				lasergraphic = 14;
				return;
			}else if (from.y - to.y < 0) {
				machinegraphic1 = 10;
				machinegraphic2 = 13;
				machinegraphicoff1 = 20;
				machinegraphicoff2 = 23;
				lasergraphic = 14;
				return;
			}
		}
		
		public function switchLaser():void {
			var n:int = 0;
			var x:int = from.x;
			var y:int = from.y;
			if (on) {
				on = false;
				for (n = 0; n < (to.x - from.x) + (to.y - from.y) + 1; ++n) {
					Main.map.changeTile(x, y, 0, null, true);
					if (x != to.x) { ++x; } else if (y != to.y) { ++y; }
				}
				Main.map.changeTile(from.x, from.y, machinegraphicoff1, null, true);
				Main.map.changeTile(to.x, to.y, machinegraphicoff2, null, true);
			}else {
				on = true;
				for (n = 0; n < (to.x - from.x) + (to.y - from.y) + 1; ++n) {
					Main.map.changeTile(x, y, lasergraphic, null, true);
					if (x != to.x) { ++x; } else if (y != to.y) { ++y; }
				}
				Main.map.changeTile(from.x, from.y, machinegraphic1, null, true);
				Main.map.changeTile(to.x, to.y, machinegraphic2, null, true);
			}
		}
	}
}