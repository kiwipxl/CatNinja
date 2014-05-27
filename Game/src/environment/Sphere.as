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
	public class Sphere extends Bitmap {
		
		//sphere variables
		private var animation:AnimateControl;
		private var collectable:Boolean = false;
		
		public function Sphere(collect:Boolean):void {
			super(Main.textures.spheres[0]);
			animation = Main.animation.create(this, Main.textures.spheres, 5, false);
			animation.play();
			collectable = collect;
		}
		
		public function update():void {
			animation.update();
			
			if (collectable && Main.player.x >= x - 20 && Main.player.x <= x + 20 && Main.player.y >= y - 20 && Main.player.y <= y + 20) {
				Main.sound.playsfx(1);
				Main.env.remove(Main.env.spheres, this);
				Main.particles.create(x, y, 40, 15, 15, 6, null);
				Main.map.changeTile(x / 20, y / 20, 0, null, null, false, true);
				
				++Main.collected;
				Main.collectedpositions.push(Main.map.currentLevel, int(x / 20), int(y / 20));
			}
		}
	}
}