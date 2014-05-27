package maps {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class MapCamera {
		
		//mapcamera variables
		public var destx:int = 0;
		public var desty:int = 0;
		public var moving:Boolean = false;
		public var speed:int = 99;
		private var lockedscroll:Boolean = false;
		public var paused:Boolean = false;
		
		public function moveTo(x:int, y:int, snap:Boolean = false, scrollspeed:int = 15, lock:Boolean = false):void {
			//set borders to camera
			if (lock) { return; }
			
			lockedscroll = lock;
			var width:int = 400;
			var height:int = 300;
			if (Main.fullscreened) {
				width = (360 + (Main.universe.fullScreenWidth - 800)) / 2 - 20;
				height = Main.universe.fullScreenHeight / 3;
			}
			if (Main.world.rotation == 90 || Main.world.rotation == -90) {
				var temp:int = width;
				width = height;
				height = temp;
			}
			var offsetx:int = width;
			var offsety:int = height;
			if (x - offsetx <= 0) {
				x = offsetx;
			}else if (x + offsetx >= Main.map.mapwidth) {
				x = Main.map.mapwidth - offsetx;
			}
			if (y - offsety <= 0) {
				y = offsety;
			}else if (y + offsety >= Main.map.mapheight) {
				y = Main.map.mapheight - offsety;
			}
			
			if (snap) {
				Main.screen.x = -x;
				Main.screen.y = -y;
			}else {
				destx = -x;
				desty = -y;
			}
			
			if (Main.screen.x != destx || Main.screen.y != desty) {
				moving = true;
			}
			
			speed = scrollspeed;
		}
		
		public function update():void {
			if (moving && !paused) {
				if (Main.screen.x >= destx - 1 && Main.screen.x <= destx + 1 && Main.screen.y >= desty - 1 && Main.screen.y <= desty + 1) {
					Main.screen.x = destx;
					Main.screen.y = desty;
					moving = false;
					lockedscroll = false;
					return;
				}
				
				if (Main.screen.x >= destx - 10 && Main.screen.x <= destx + 10 && Main.screen.y >= desty - 10 && Main.screen.y <= desty + 10) {
					Main.screen.x += (destx - Main.screen.x) / (speed / 2);
					Main.screen.y += (desty - Main.screen.y) / (speed / 2);
				}else {
					Main.screen.x += (destx - Main.screen.x) / speed;
					Main.screen.y += (desty - Main.screen.y) / speed;
				}
			}
		}
	}
}