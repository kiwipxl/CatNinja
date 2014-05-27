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
	public class Sphere {
		
		//sphere variables
		private var x:int;
		private var y:int;
		private var coordx:int;
		private var coordy:int;
		private var animationtimer:int = 0;
		private var index:int = 0;
		private var reverse:Boolean = false;
		private var collected:Boolean = false;
		
		public function Sphere(posx:int, posy:int):void {
			x = posx; y = posy;
			coordx = posx / 20; coordy = posy / 20;
			index = int(Math.random() * (Main.textures.spheres.length - 1));
			Main.map.drawToGrid(Main.textures.spheres[index], x, y);
		}
		
		public function update():void {
			++animationtimer;
			if (animationtimer >= 5) {
				if (reverse) { --index; }else { ++index; }
				if (index <= 0 && reverse) { index = 10; }
				animationtimer = 0;
				Main.map.drawbackgroundtileat(coordx, coordy);
				Main.map.drawToGrid(Main.textures.spheres[index], x, y);
				if (index >= 10 && !reverse) { index = 0; }
			}
			
			if (Main.player.x >= x - 20 && Main.player.x <= x + 20 && Main.player.y >= y - 20 && Main.player.y <= y + 20) {
				Main.sound.playsfx(1);
				Main.map.drawbackgroundtileat(coordx, coordy);
				Main.particles.create(x, y, 40, 15, 15, 6, null);
				
				Main.env.splice(Main.env.spheres, this);
				collected = true;
				++Main.collected;
				Main.mapmanager.currentmapdetails.tiles[coordy * Main.map.gridwidth + coordx] = 999;
				Main.mapmanager.updateinfotext();
			}
		}
	}
}