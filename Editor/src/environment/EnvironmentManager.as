package environment {
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class EnvironmentManager {
		
		//environment manager variables
		public var mines:Vector.<Mine> = new Vector.<Mine>;
		public var dirts:Vector.<Dirt> = new Vector.<Dirt>;
		public var flowers:Vector.<Flower> = new Vector.<Flower>;
		public var shieldshooters:Vector.<ShieldShooter> = new Vector.<ShieldShooter>;
		public var fallingspikes:Vector.<FallingSpike> = new Vector.<FallingSpike>;
		public var sunspikes:Vector.<SunSpike> = new Vector.<SunSpike>;
		public var spheres:Vector.<Sphere> = new Vector.<Sphere>;
		public var resetters:Array = [];
		public var bombcounter:int = 0;
		public var bulletcounter:int = 0;
		
		public function createMine(x:int, y:int, graphic:int = 0):void {
			var mine:Mine = new Mine(x, y, graphic);
			mines.push(mine);
			resetters.push(mine);
		}
		
		public function createDirt(x:int, y:int):void {
			var dirt:Dirt = new Dirt(x, y);
			dirts.push(dirt);
			resetters.push(dirt);
		}
		
		public function createFlower(x:int, y:int, type:int, specialtype:int = 0):void {
			var flower:Flower = new Flower(x, y, type, specialtype);
			flowers.push(flower);
			resetters.push(flower);
		}
		
		public function createLaser(fromx:int, fromy:int, tox:int, toy:int, delay:int):void {
			var laser:Laser = new Laser(delay);
			laser.from.x = fromx; laser.from.y = fromy;
			laser.to.x = tox; laser.to.y = toy;
			laser.calculateDirection();
		}
		
		public function createShieldShooter(x:int, y:int, graphic:int, homing:Boolean = false):void {
			var ss:ShieldShooter = new ShieldShooter(graphic, homing);
			ss.x = x; ss.y = y;
			shieldshooters.push(ss);
			Main.screen.addChild(ss);
		}
		
		public function createFallingSpike(x:int, y:int, graphic:int):void {
			var spike:FallingSpike = new FallingSpike(graphic, x, y);
			fallingspikes.push(spike);
			resetters.push(spike);
			Main.screen.addChild(spike);
		}
		
		public function createSunSpike(x:int, y:int):void {
			var sunspike:SunSpike = new SunSpike(x, y);
			sunspikes.push(sunspike);
			Main.screen.addChild(sunspike);
		}
		
		public function createSphere(x:int, y:int):Sphere {
			var sphere:Sphere = new Sphere(x, y);
			spheres.push(sphere);
			
			return sphere;
		}
		
		public function removeAll():void {
			removeAllFrom(fallingspikes);
			removeAllFrom(sunspikes);
			
			for (var c:int = 0; c < shieldshooters.length; ++c) {
				shieldshooters[c].bullets.length = 0;
				Main.screen.removeChild(shieldshooters[c]);
			}
			for (var d:int = 0; d < flowers.length; ++d) {
				flowers[d].removebombs();
			}
			shieldshooters.length = 0;
			dirts.length = 0;
			flowers.length = 0;
			mines.length = 0;
			spheres.length = 0;
		}
		
		private function removeAllFrom(array:*):void {
			for (var c:int = 0; c < array.length; ++c) {
				Main.screen.removeChild(array[c]);
			}
			array.length = 0;
		}
		
		public function remove(from:*, object:*):void {
			for (var n:int = 0; n < from.length; ++n) {
				if (from[n] == object) {
					Main.screen.removeChild(object);
					from.splice(n, 1);
					return;
				}
			}
		}
		
		public function splice(from:*, object:*):void {
			for (var n:int = 0; n < from.length; ++n) {
				if (from[n] == object) {
					from.splice(n, 1);
					return;
				}
			}
		}
		
		public function update():void {
			updateVector(dirts);
			updateVector(flowers);
			updateVector(mines);
			updateVector(shieldshooters);
			updateVector(fallingspikes);
			updateVector(sunspikes);
			updateVector(spheres);
		}
		
		private function updateVector(vector:*):void {
			for (var n:int = 0; n < vector.length; ++n) {
				vector[n].update();
			}
		}
	}
}