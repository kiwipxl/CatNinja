package environment {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import maps.Node;
	import tools.animation.AnimateControl;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Crate extends Bitmap {
		
		//crate variables
		public var originy:int;
		public var originx:int;
		private var last:Point = new Point();
		
		public function Crate():void {
			super(Main.textures.crate);
		}
		
		public function updatepos():void {
			x = originx;
			y = originy;
			last.x = int(x / 20);
			last.y = int(y / 20);
			Main.map.grid[last.y * Main.map.gridwidth + last.x].walkable = false;
		}
		
		private function setWalkable(x:int, y:int, walkable:Boolean, force:Boolean = false):void {
			if (x != Main.player.coordx || y != Main.player.coordy || force) {
				if (x - 1 != Main.player.coordx || y != Main.player.coordy || force) {
					Main.map.grid[y * Main.map.gridwidth + x].walkable = walkable;
				}
			}
		}
		
		public function update():void {
			var coordx:int = Math.round(x / 20);
			var coordy:int = int(y / 20);
			
			if (last.x != coordx) {
				setWalkable(last.x, last.y, true);
				last.x = coordx;
				setWalkable(last.x, last.y, false);
			}
			if (last.y != coordy) {
				setWalkable(last.x, last.y, true);
				last.y = coordy;
				setWalkable(last.x, last.y, false);
			}
			
			if (Main.map.currentLevel != 27) {
				if (Main.player.coordx + 2 == coordx && Main.player.coordy == coordy ||
				Main.player.coordx - 1 == coordx && Main.player.coordy == coordy) {
					if (Main.player.rolling && Main.player.speedx >= 8 || Main.player.rolling && Main.player.speedx <= -8) {
						breakCrate();
					}
				}
			}
		}
		
		public function slam():void {
			var coordx:int = int(x / 20);
			var coordy:int = int(y / 20);
			
			if (Main.player.coordx + 2 == coordx && Main.player.coordy == coordy ||
			Main.player.coordx - 1 == coordx && Main.player.coordy == coordy) {
				breakCrate();
			}
		}
		
		public function breakCrate():void {
			Main.sound.playsfx(0);
			setWalkable(last.x, last.y, true, true);
			
			Main.particles.create(x, y, 8, 25, 10, 4);
			Main.env.remove(Main.env.crates, this);
		}
		
		public function reset():void {
			setWalkable(last.x, last.y, true, true);
			updatepos();
			if (!stage) {
				Main.screen.addChild(this);
				Main.env.crates.push(this);
			}
		}
	}
}