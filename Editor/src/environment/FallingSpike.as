package environment {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import tools.animation.AnimateControl;
	import tools.images.PixelModifier;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class FallingSpike extends Bitmap {
		
		//fallingspike variables
		private var speedx:int;
		private var speedy:int;
		private var speed:int = 10;
		private var coordx:int;
		private var coordy:int;
		private var searchx:int;
		private var searchy:int;
		private var tempx:int;
		private var tempy:int;
		private var spawnx:int;
		private var spawny:int;
		private var fall:Boolean = false;
		
		public function FallingSpike(graphic:int, xpos:int, ypos:int):void {
			var temp:BitmapData;
			switch (graphic) {
				case 0:
					temp = Main.textures.fallspikeup;
					speedx = 0; speedy = -speed;
					break;
				case 1:
					temp = Main.textures.fallspikedown;
					speedx = 0; speedy = speed;
					break;
				case 2:
					temp = Main.textures.fallspikeright;
					speedx = speed; speedy = 0;
					break;
				case 3:
					temp = Main.textures.fallspikeleft;
					speedx = -speed; speedy = 0;
					break;
			}
			searchx = speedx / speed; searchy = speedy / speed;
			spawnx = xpos; spawny = ypos;
			x = spawnx; y = spawny;
			super(temp);
		}
		
		public function update():void {
			if (x >= Main.player.x - 800 && x <= Main.player.x + 800 && y >= Main.player.y - 600 && y <= Main.player.y + 600) {
				transform.colorTransform = Main.map.colourchanger.transform;
				coordx = int(x / 20); coordy = int(y / 20);
				if (x >= Main.player.x - 10 && x <= Main.player.x + 10 &&
					y >= Main.player.y - 10 && y <= Main.player.y + 10) {
					remove();
					Main.player.die();
				}
				if (fall) {
					x += speedx; y += speedy;
					coordx = Math.round(x / 20); coordy = Math.round(y / 20);
					if (coordx > 0 && coordx < Main.map.gridwidth - 1 && coordy > 0 && coordy < Main.map.gridheight - 1) {
						if (!Main.map.grid[coordy * Main.map.gridwidth + coordx].walkable) {
							remove();
						}
					}else {
						remove();
					}
				}else {
					tempx = coordx; tempy = coordy;
					for (var n:int = 0; n < 80; ++n) {
						if (tempx >= 1 && tempx < Main.map.gridwidth - 2 && tempy >= 1 && tempy < Main.map.gridheight - 2) {
							tempx += searchx; tempy += searchy;
							if (Main.map.grid[tempy * Main.map.gridwidth + tempx].walkable) {
								if (tempx >= Main.player.coordx - 1 && tempx <= Main.player.coordx + 1 &&
									tempy >= Main.player.coordy - 1 && tempy <= Main.player.coordy + 1) {
									fall = true;
									break;
								}
								continue;
							}
						}
						break;
					}
				}
			}
		}
		
		public function remove():void {
			Main.particles.create(x, y, 5, 10, 10, 5);
			Main.sound.playsfx(4);
			Main.env.remove(Main.env.fallingspikes, this);
		}
		
		public function reset():void {
			fall = false;
			x = spawnx; y = spawny;
			if (!stage) {
				Main.screen.addChild(this);
				Main.env.fallingspikes.push(this);
			}
		}
	}
}