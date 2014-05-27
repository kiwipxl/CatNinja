package environment {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import tools.Collision;
	import tools.images.PixelModifier;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Mine {
		
		//mine variables
		public var x:int;
		public var y:int;
		private var setoff:Boolean = false;
		private var timer:int = 0;
		private var rate:int = 10;
		private var blinkon:Boolean = false;
		private var graphic:int = 0;
		private var off:Boolean = false;
		
		public function Mine(posx:int, posy:int, minegraphic:int):void {
			graphic = minegraphic;
			var bitmapData:BitmapData;
			if (graphic == 0) { bitmapData = Main.textures.mineblinkoff;
			}else if (graphic == 1) { bitmapData = Main.textures.mineblinkoffup;
			}else if (graphic == 2) { bitmapData = Main.textures.mineblinkoffright;
			}else if (graphic == 3) { bitmapData = Main.textures.mineblinkoffleft; }
			
			x = posx; y = posy;
			
			Main.map.drawToGrid(bitmapData, x, y);
			bitmapData = null;
			
			reset();
		}
		
		public function update():void {
			if (off) { return; }
			
			if (Main.player.x >= x - 20 && Main.player.x <= x + 20 && Main.player.y >= y - 20 && Main.player.y <= y + 20) {
				setoff = true;
			}
			if (setoff) {
				++timer;
				if (timer >= rate) {
					var bitmapData:BitmapData;
					if (blinkon) {
						if (graphic == 0) { bitmapData = Main.textures.mineblinkoff;
						}else if (graphic == 1) { bitmapData = Main.textures.mineblinkoffup;
						}else if (graphic == 2) { bitmapData = Main.textures.mineblinkoffright;
						}else if (graphic == 3) { bitmapData = Main.textures.mineblinkoffleft; }
						blinkon = false;
						Main.map.drawbackgroundtileat(x / 20, y / 20);
						Main.map.drawToGrid(bitmapData, x, y);
					}else {
						if (graphic == 0) { bitmapData = Main.textures.mineblinkon;
						}else if (graphic == 1) { bitmapData = Main.textures.mineblinkonup;
						}else if (graphic == 2) { bitmapData = Main.textures.mineblinkonright;
						}else if (graphic == 3) { bitmapData = Main.textures.mineblinkonleft; }
						blinkon = true;
						Main.map.drawbackgroundtileat(x / 20, y / 20);
						Main.map.drawToGrid(bitmapData, x, y);
					}
					timer = 0;
					rate -= 2;
					if (rate <= 0) {
						Main.sound.playsfx(6);
						if (Collision.inRadius(x / 20, y / 20, Main.player.coordx, Main.player.coordy, 4)) {
							Main.player.die();
						}
						Main.particles.create(x, y, 20, 15, 15);
						if (graphic == 0) { bitmapData = Main.textures.mineoff;
						}else if (graphic == 1) { bitmapData = Main.textures.mineoffup;
						}else if (graphic == 2) { bitmapData = Main.textures.mineoffright;
						}else if (graphic == 3) { bitmapData = Main.textures.mineoffleft; }
						off = true;
						Main.map.drawbackgroundtileat(x / 20, y / 20);
						Main.map.drawToGrid(bitmapData, x, y);
					}
					bitmapData = null;
				}
			}
		}
		
		public function reset():void {
			var bitmapData:BitmapData;
			if (graphic == 1) { bitmapData = Main.textures.mineblinkoffup;
			}else if (graphic == 2) { bitmapData = Main.textures.mineblinkoffright;
			}else if (graphic == 3) { bitmapData = Main.textures.mineblinkoffleft;
			}else { bitmapData = Main.textures.mineblinkoff; }
			Main.map.drawbackgroundtileat(x / 20, y / 20);
			Main.map.drawToGrid(bitmapData, x, y);
			bitmapData = null;
			timer = 0;
			setoff = false;
			rate = 10;
			blinkon = false;
			off = false;
		}
	}
}