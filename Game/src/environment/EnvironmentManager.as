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
		public var buttons:Vector.<Button> = new Vector.<Button>;
		public var dirts:Vector.<Dirt> = new Vector.<Dirt>;
		public var crates:Vector.<Crate> = new Vector.<Crate>;
		public var shieldshooters:Vector.<ShieldShooter> = new Vector.<ShieldShooter>;
		public var fallingspikes:Vector.<FallingSpike> = new Vector.<FallingSpike>;
		public var sunspikes:Vector.<SunSpike> = new Vector.<SunSpike>;
		public var spheres:Vector.<Sphere> = new Vector.<Sphere>;
		public var bigspheres:Vector.<BigSphere> = new Vector.<BigSphere>;
		public var resetters:Array = [];
		public var screenmanager:ScreenManager = new ScreenManager();
		
		public function createMine(x:int, y:int, graphic:int = 0):void {
			var mine:Mine = new Mine(graphic);
			mine.x = x;
			mine.y = y;
			Main.screen.addChild(mine);
			mines.push(mine);
			resetters.push(mine);
		}
		
		public function createButton(x:int, y:int, graphic:BitmapData, datanum:int = 0):void {
			var button:Button = new Button(graphic);
			button.x = x;
			button.y = y;
			button.datanum = datanum;
			Main.screen.addChild(button);
			buttons.push(button);
		}
		
		public function createDirt(x:int, y:int):void {
			var dirt:Dirt = new Dirt();
			dirt.x = x;
			dirt.y = y;
			Main.screen.addChild(dirt);
			dirts.push(dirt);
			resetters.push(dirt);
		}
		
		public function createCrate(x:int, y:int):void {
			var crate:Crate = new Crate();
			crate.x = x;
			crate.y = y;
			crate.originx = x;
			crate.originy = y;
			crate.updatepos();
			Main.screen.addChild(crate);
			crates.push(crate);
			resetters.push(crate);
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
		
		public function createSphere(x:int, y:int, collectable:Boolean = true):Sphere {
			var sphere:Sphere = new Sphere(collectable);
			sphere.x = x; sphere.y = y;
			spheres.push(sphere);
			Main.screen.addChild(sphere);
			
			return sphere;
		}
		
		public function createBigSphere(x:int, y:int):void {
			var sphere:BigSphere = new BigSphere();
			sphere.x = x; sphere.y = y + 20;
			bigspheres.push(sphere);
			Main.screen.addChild(sphere);
		}
		
		public function removeAll():void {
			removeAllFrom(mines);
			removeAllFrom(buttons);
			removeAllFrom(dirts);
			removeAllFrom(crates);
			removeAllFrom(fallingspikes);
			removeAllFrom(sunspikes);
			removeAllFrom(spheres);
			removeAllFrom(bigspheres);
			removeAllFrom(screenmanager.screens);
			
			for (var c:int = 0; c < shieldshooters.length; ++c) {
				shieldshooters[c].bullets.length = 0;
				Main.screen.removeChild(shieldshooters[c]);
			}
			shieldshooters.length = 0;
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
			updateVector(mines);
			updateVector(crates);
			updateVector(shieldshooters);
			updateVector(spheres);
			updateVector(fallingspikes);
			updateVector(sunspikes);
			updateVector(bigspheres);
		}
		
		private function updateVector(vector:*):void {
			for (var n:int = 0; n < vector.length; ++n) {
				vector[n].update();
			}
		}
	}
}