package environment {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import tools.animation.AnimateControl;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Dirt {
		
		//dirt variables
		private var x:int;
		private var y:int;
		public var coordx:int;
		public var coordy:int;
		private var activated:Boolean = false;
		private var breakanimation:AnimateControl;
		private var lastdata:BitmapData;
		private var broke:Boolean = false;
		
		public function Dirt(posx:int, posy:int):void {
			x = posx; y = posy;
			coordx = int(x / 20); coordy = int(y / 20);
			Main.map.drawToGrid(Main.textures.dirtblocks[0], x, y);
			lastdata = Main.textures.dirtblocks[0];
			
			breakanimation = Main.animation.create(null, [Main.textures.dirtblocks[1], Main.textures.dirtblocks[2]], 4);
			breakanimation.pause();
		}
		
		public function update():void {
			if (!activated && !broke) {
				if (Main.player.x - 10 >= x - 20 && Main.player.x - 10 <= x + 20 && 
				Main.player.y - 10 >= y - 20 && Main.player.y - 10 <= y + 20) {
					Main.time.runFunctionIn(200, breakDirt);
					activated = true;
					breakanimation.play();
					return;
				}
			}else if (activated && !broke) {
				breakanimation.update();
				if (breakanimation.framedata != lastdata) {
					Main.map.drawToGrid(breakanimation.framedata, x, y);
					lastdata = breakanimation.framedata;
				}
			}
		}
		
		public function breakDirt():void {
			Main.sound.playsfx(0);
			Main.particles.create(x, y, 4, 5, 5, 4);
			Main.map.drawbackgroundtileat(coordx, coordy);
			Main.map.grid[int(y / 20) * Main.map.gridwidth + int(x / 20)].walkable = true;
			activated = false;
			broke = true;
		}
		
		public function reset():void {
			if (activated || broke) {
				Main.map.drawToGrid(Main.textures.dirtblocks[0], x, y);
				Main.map.grid[int(y / 20) * Main.map.gridwidth + int(x / 20)].walkable = false;
				activated = false;
				broke = false;
			}
		}
	}
}