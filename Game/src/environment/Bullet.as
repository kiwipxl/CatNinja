package environment {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Bullet {
		
		//bullet variables
		public var x:Number = 0;
		public var y:Number = 0;
		private var speedx:Number = 0;
		private var speedy:Number = 0;
		private var coord:Point = new Point();
		public var removed:Boolean = false;
		private var bulletcolour:int;
		public var homingbullet:Boolean = false;
		private var angle:Number;
		private var t:Object;
		private var bspeed:int;
		private var homingtimer:int = 0;
		private var htimer:int = 0;
		
		public function Bullet(posx:int, posy:int, target:Object, speed:int, colour:int, homing:Boolean):void {
			x = posx; y = posy;
			bulletcolour = colour;
			t = target;
			bspeed = speed;
			homingbullet = homing;
			updateAngle();
		}
		
		private function updateAngle():void {
			angle = -Math.atan2(t.y - y, t.x - x) * (180 / Math.PI);
			speedx = bspeed * Math.cos((Math.PI / 180) * angle);
			speedy = -bspeed * Math.sin((Math.PI / 180) * angle);
		}
		
		public function update():void {
			Main.trail.create(x, y, null, 3, null, .08, 1, Main.map.colourchanger.transform, 0, bulletcolour);
			x += speedx;
			y += speedy;
			coord.x = x / 20; coord.y = y / 20;
			
			if (!Main.map.collideRight(coord.x, coord.y).walkable || !Main.map.collideLeft(coord.x, coord.y).walkable ||
			!Main.map.collideDown(coord.x, coord.y - 1).walkable || !Main.map.collideUp(coord.x, coord.y).walkable) {
				removed = true;
				return;
			}
			if (!Main.player.dead) {
				++htimer;
				if (htimer < 150) {
					if (homingbullet) { ++homingtimer; if (homingtimer >= 10) { updateAngle(); homingtimer = 0; } }
				}
				if (x >= Main.player.x - 20 && x <= Main.player.x + 20 && y >= Main.player.y - 20 && y <= Main.player.y + 20) {
					Main.player.die();
					removed = true;
				}
			}
		}
	}
}