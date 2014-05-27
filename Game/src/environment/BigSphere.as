package environment {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import tools.animation.AnimateControl;
	import tools.images.PixelModifier;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class BigSphere extends Sprite {
		
		//sphere variables
		private var container:Sprite = new Sprite();
		private var base:Bitmap;
		private var animation:AnimateControl;
		private var spheres:Vector.<Sphere> = new Vector.<Sphere>;
		private var timer:int = 0;
		private var finished:Boolean = false;
		private var crystals:int = 0;
		
		public function BigSphere():void {
			base = new Bitmap(Main.textures.bigspheres[0]);
			animation = Main.animation.create(base, Main.textures.bigspheres, 4, false);
			animation.play();
			
			container.x = -base.width / 2;
			container.y = -base.height;
			addChild(container);
			container.addChild(base);
			
			scaleX = .15; scaleY = .15;
			
			if (Main.collected == 0) { Main.collected = 1; }
		}
		
		public function update():void {
			animation.update();
			
			if (!finished && Main.player.x < x + 250) {
				Main.player.stopMovement = true;
				Main.player.rotation = 0;
				++timer;
				if (timer >= 10) {
					timer = 0;
					if (Main.collected > 0) {
						spheres.push(Main.env.createSphere(Main.player.x, Main.player.y, false));
						--Main.collected;
						Main.info.update(true);
					}
				}
			}
			
			for (var n:int = 0; n < spheres.length; ++n) {
				spheres[n].x -= (spheres[n].x - (x - 10)) / 10;
				spheres[n].y -= (spheres[n].y - (y - 20)) / 10;
				if (spheres[n].x >= x - 12 && spheres[n].x <= x + 12 && spheres[n].y >= y - 22 && spheres[n].y <= y + 22) {
					scaleX += .02; scaleY += .02;
					if (scaleX >= .5 || scaleY >= .5) { scaleX = .5; scaleY = .5; }
					Main.sound.playsfx(1);
					Main.env.remove(Main.env.spheres, spheres[n]);
					Main.particles.create(x, y, 5, 15, 15, 6, null);
					spheres.splice(n, 1);
					--n;
					++crystals;
					if (spheres.length <= 0) {
						finish();
					}
				}
			}
		}
		
		private function finish():void {
			Main.sound.playsfx(8);
			Main.player.stopMovement = false;
			finished = true;
			
			var coordx:int = int((x - (width / 2)) / 20);
			var coordy:int = int((y - height) / 20) + 1;
			var startx:int = coordx;
			
			for (var y:int = 0; y < Math.round(height / 20) + 1; ++y) {
				for (var x:int = 0; x < Math.round((width / 2) / 20) + 2; ++x) {
					++coordx;
					Main.map.grid[coordy * Main.map.gridwidth + coordx].walkable = false;
					Main.map.grid[coordy * Main.map.gridwidth + coordx].type = 1;
				}
				coordx = startx;
				++coordy;
			}
			
			if (crystals > 20) {
				Main.text.createtext("<font size='40' color='#00ff00'>Goob job Catninja!</font><br>" +
				"<font size='20' color='#99FB97'>You collected enough crystals to save the world... or something!</font>", 0, 40, .05, 0, false);
			}else {
				Main.text.createtext("<font size='40' color='#00ff00'>Goob job Catninja!</font><br>" +
				"<font size='20' color='#99FB97'>Unfortunately you did not collect enough crystals<br>" +
				"to save the world or something. You must try again!</font>", 0, 40, .05, 0, false);
			}
		}
	}
}