package maps {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
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
			
			var halfwidth:int = Main.halfwidth;
			var halfheight:int = Main.halfheight;
			if (Main.universe.displayState != StageDisplayState.NORMAL) {
				if (Main.world.rotation == 90 || Main.world.rotation == -90) {
					halfwidth -= 150;
					halfheight -= 400;
				}
			}
			x -= halfwidth - 400;
			y -= halfheight - 300;
			
			var boundrycollision:Boolean = true;
			if (Main.world.rotation == 90 || Main.world.rotation == -90) {
				if (Main.universe.displayState != StageDisplayState.NORMAL) {
					boundrycollision = false;
				}
			}
			if (boundrycollision) {
				var lowoffsetx:int = 0;
				var lowoffsety:int = 0;
				var maxoffsetx:int = 0;
				var maxoffsety:int = 0;
				var mapwidth:int = Main.map.mapwidth;
				var mapheight:int = Main.map.mapheight;
				if (Main.universe.displayState != StageDisplayState.NORMAL) {
					if (Main.map.mapwidth < Main.universe.stageWidth) { lowoffsetx = -(Main.universe.stageWidth - Main.map.mapwidth); }
					if (Main.map.mapheight < Main.universe.stageHeight) { lowoffsety = -(Main.universe.stageHeight - Main.map.mapheight); }
					mapwidth -= 600 - lowoffsetx;
					mapheight -= 300 - lowoffsety;
					maxoffsetx = (Main.universe.stageWidth - 800) + lowoffsetx;
					maxoffsety = (Main.universe.stageHeight - 600) + lowoffsety;
				}
				
				lockedscroll = lock;
				var width:int = 400;
				var height:int = 300;
				if (Main.world.rotation == 90 || Main.world.rotation == -90) {
					var temp:int = width;
					width = height;
					height = temp;
				}
				var offsetx:int = width;
				var offsety:int = height;
				if (x - offsetx <= lowoffsetx) {
					x = offsetx + lowoffsetx;
				}else if (x + offsetx >= mapwidth) {
					x = Main.map.mapwidth - offsetx - maxoffsetx;
				}
				if (y - offsety <= lowoffsety) {
					y = offsety + lowoffsety;
				}else if (y + offsety >= mapheight) {
					y = Main.map.mapheight - offsety - maxoffsety;
				}
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