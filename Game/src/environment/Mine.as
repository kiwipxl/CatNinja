package environment {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import tools.Collision;
	import tools.images.PixelModifier;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Mine extends Bitmap {
		
		//mine variables
		private var setoff:Boolean = false;
		private var timer:int = 0;
		private var rate:int = 10;
		private var blinkon:Boolean = false;
		private var graphic:int = 0;
		private var off:Boolean = false;
		
		public function Mine(minegraphic:int):void {
			graphic = minegraphic;
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
					if (blinkon) {
						if (graphic == 0) { bitmapData = Main.textures.mineblinkoff;
						}else if (graphic == 1) { bitmapData = Main.textures.mineblinkoffup;
						}else if (graphic == 2) { bitmapData = Main.textures.mineblinkoffright;
						}else if (graphic == 3) { bitmapData = Main.textures.mineblinkoffleft; }
						blinkon = false;
					}else {
						if (graphic == 0) { bitmapData = Main.textures.mineblinkon;
						}else if (graphic == 1) { bitmapData = Main.textures.mineblinkonup;
						}else if (graphic == 2) { bitmapData = Main.textures.mineblinkonright;
						}else if (graphic == 3) { bitmapData = Main.textures.mineblinkonleft; }
						blinkon = true;
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
					}
				}
			}
		}
		
		public function reset():void {
			if (graphic == 1) { bitmapData = Main.textures.mineblinkoffup;
			}else if (graphic == 2) { bitmapData = Main.textures.mineblinkoffright;
			}else if (graphic == 3) { bitmapData = Main.textures.mineblinkoffleft;
			}else { bitmapData = Main.textures.mineblinkoff; }
			timer = 0;
			setoff = false;
			rate = 10;
			blinkon = false;
			off = false;
		}
	}
}