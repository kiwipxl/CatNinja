package environment {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class SunSpike extends Bitmap {
		
		//sunspike variables
		private var coordx:int = 0;
		private var coordy:int = 0;
		private var speedx:int = 0;
		private var speedy:int = 0;
		private const speed:int = 6;
		private var lastx:int = 0;
		private var lasty:int = 0;
		private var spritethis:Sprite;
		
		public function SunSpike(posx:int, posy:int):void {
			super(Main.textures.sunspike);
			
			spritethis = this as Sprite;
			
			x = posx; y = posy;
			coordx = Math.round(x / 20); coordy = Math.round(y / 20);
		}
		
		public function update():void {
			coordx = Math.round(x / 20); coordy = Math.round(y / 20);
			x += speedx; y += speedy;
			if (coordx != lastx || coordy != lasty) {
				x = coordx * 20; y = coordy * 20;
				Main.trail.create(x, y, bitmapData, 0, spritethis, .02, .5);
				lastx = coordx; lasty = coordy;
				calculatespeed();
			}
			
			if (x >= Main.player.x - 800 && x <= Main.player.x + 800 && y >= Main.player.y - 600 && y <= Main.player.y + 600) {
				coordx = Math.round(x / 20); coordy = Math.round(y / 20);
				if (coordx >= Main.player.coordx - 1 && coordx <= Main.player.coordx + 1 &&
					coordy >= Main.player.coordy - 1 && coordy <= Main.player.coordy + 1) {
					Main.player.die();
				}
			}
		}
		
		private function calculatespeed():void {
			if (Main.map.grid[(coordy + 1) * Main.map.gridwidth + coordx].type == 1) {
				speedx = speed; speedy = 0;
			}else if (Main.map.grid[(coordy + 1) * Main.map.gridwidth + coordx].type != 1 &&
				speedx == speed && speedy == 0) {
				speedx = 0; speedy = speed;
			}else if (Main.map.grid[coordy * Main.map.gridwidth + (coordx - 1)].type == 1) {
				speedx = 0; speedy = speed;
			}else if (Main.map.grid[coordy * Main.map.gridwidth + (coordx - 1)].type != 1 &&
				speedx == 0 && speedy == speed) {
				speedx = -speed; speedy = 0;
			}else if (Main.map.grid[(coordy - 1) * Main.map.gridwidth + coordx].type == 1) {
				speedx = -speed; speedy = 0;
			}else if (Main.map.grid[(coordy - 1) * Main.map.gridwidth + coordx].type != 1 &&
				speedx == -speed && speedy == 0) {
				speedx = 0; speedy = -speed;
			}else if (Main.map.grid[coordy * Main.map.gridwidth + (coordx + 1)].type == 1) {
				speedx = 0; speedy = -speed;
			}else if (Main.map.grid[coordy * Main.map.gridwidth + (coordx + 1)].type != 1 &&
				speedx == 0 && speedy == -speed) {
				speedx = speed; speedy = 0;
			}
		}
	}
}