package environment {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import tools.animation.AnimateControl;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Dirt extends Bitmap {
		
		//dirt variables
		private var activated:Boolean = false;
		private var breakanimation:AnimateControl;
		
		public function Dirt():void {
			super(Main.textures.dirtblocks[0]);
			breakanimation = Main.animation.create(this, [Main.textures.dirtblocks[1], Main.textures.dirtblocks[2]], 4);
			breakanimation.pause();
		}
		
		public function update():void {
			if (!activated) {
				if (Main.player.coordx + 1 == int(x / 20) && Main.player.coordy + 1 == int(y / 20) ||
				Main.player.coordx == int(x / 20) && Main.player.coordy + 1 == int(y / 20) ||
				Main.player.coordx + 1 == int(x / 20) && Main.player.coordy == int(y / 20) ||
				Main.player.coordx == int(x / 20) && Main.player.coordy == int(y / 20)) {
					Main.time.runFunctionIn(200, breakDirt);
					activated = true;
					breakanimation.play();
					return;
				}
				if (Main.player.coordx + 2 == int(x / 20) && Main.player.coordy == int(y / 20) ||
				Main.player.coordx - 1 == int(x / 20) && Main.player.coordy == int(y / 20)) {
					if (Main.player.rolling) {
						breakDirt();
						activated = true;
					}
				}
			}else if (activated) {
				breakanimation.update();
			}
		}
		
		public function breakDirt():void {
			Main.sound.playsfx(0);
			Main.particles.create(x, y, 4, 5, 5, 4);
			Main.env.remove(Main.env.dirts, this);
			Main.map.grid[int(y / 20) * Main.map.gridwidth + int(x / 20)].walkable = true;
		}
		
		public function reset():void {
			if (!stage) {
				bitmapData = Main.textures.dirtblocks[0];
				Main.screen.addChild(this);
				Main.env.dirts.push(this);
				Main.map.grid[int(y / 20) * Main.map.gridwidth + int(x / 20)].walkable = false;
				activated = false;
			}
		}
	}
}