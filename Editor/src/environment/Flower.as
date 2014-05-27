package environment {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import maps.Node;
	import tools.animation.AnimateControl;
	import tools.images.PixelModifier;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Flower {
		
		//flower variables
		private var x:Number;
		private var y:Number;
		public var coordx:int;
		public var coordy:int;
		private var waveanimation:AnimateControl;
		private var lastdata:BitmapData;
		private var flowerdata:Array;
		private var flowertype:int;
		private var stype:int;
		private var bombs:Vector.<Bomb> = new Vector.<Bomb>;
		private var bombtimer:int = 0;
		
		public function Flower(posx:int, posy:int, type:int, specialtype:int = 0):void {
			x = posx; y = posy;
			coordx = Math.round(x / 20); coordy = Math.round(y / 20);
			
			var id:int = Math.random() * 4;
			switch (type) {
				case 0:
					flowerdata = randflowers(id, 0);
					break;
				case 1:
					flowerdata = randflowers(id, 1);
					break;
				case 2:
					flowerdata = randflowers(id, 2);
					break;
				case 3:
					flowerdata = randflowers(id, 3);
					break;
				case 4:
					flowerdata = Main.textures.bombflowers;
					break;
				case 5:
					flowerdata = Main.textures.bombflowersleft;
					break;
				case 6:
					flowerdata = Main.textures.bombflowersright;
					break;
				case 7:
					flowerdata = Main.textures.bombflowersup;
					break;
			}
			flowertype = type;
			stype = specialtype;
			bombtimer = Math.random() * 100;
			
			waveanimation = Main.animation.create(null, [flowerdata[1], flowerdata[2], flowerdata[3]], 25 + Math.random() * 25);
			waveanimation.currentframe = Math.random() * waveanimation.frames.length - 1;
			waveanimation.updateFrame();
			
			Main.map.drawToGrid(waveanimation.framedata, x, y);
			lastdata = waveanimation.framedata;
			waveanimation.reverse = true;
		}
		
		private function randflowers(direction:int, id:int):Array {
			if (direction == 0) {
				if (id == 0) { return Main.textures.pinkflowers;
				}else if (id == 1) { return Main.textures.pinkflowersleft;
				}else if (id == 2) { return Main.textures.pinkflowersright;
				}else if (id == 3) { return Main.textures.pinkflowersup; }
			}else if (direction == 1) {
				if (id == 0) { return Main.textures.blueflowers;
				}else if (id == 1) { return Main.textures.blueflowersleft;
				}else if (id == 2) { return Main.textures.blueflowersright;
				}else if (id == 3) { return Main.textures.blueflowersup; }
			}else if (direction == 2) {
				if (id == 0) { return Main.textures.greenflowers;
				}else if (id == 1) { return Main.textures.greenflowersleft;
				}else if (id == 2) { return Main.textures.greenflowersright;
				}else if (id == 3) { return Main.textures.greenflowersup; }
			}else if (direction == 3) {
				if (id == 0) { return Main.textures.yellowflowers;
				}else if (id == 1) { return Main.textures.yellowflowersleft;
				}else if (id == 2) { return Main.textures.yellowflowersright;
				}else if (id == 3) { return Main.textures.yellowflowersup; }
			}
			return null;
		}
		
		public function update():void {
			waveanimation.update();
			if (waveanimation.framedata != lastdata && waveanimation.framedata != null) {
				Main.map.drawbackgroundtileat(coordx, coordy);
				Main.map.drawToGrid(waveanimation.framedata, x, y);
			}
			lastdata = waveanimation.framedata;
			
			for (var n:int = 0; n < bombs.length; ++n) {
				bombs[n].update();
				if (bombs[n].removed) {
					Main.particles.create(bombs[n].x, bombs[n].y, 2, 10, 10, 1);
					Main.screen.removeChild(bombs[n]);
					bombs.splice(n, 1);
					--n;
				}
			}
			
			if (stype == 1) {
				if (Main.player.x >= x - 250 && Main.player.x <= x + 250) {
					++bombtimer;
					if (bombtimer >= 200) {
						bombtimer = 0;
						if (Main.env.bombcounter <= 12) {
							var distance:Number = (x - Main.player.x) / 20;
							if (distance > 10) { distance = 10; } else if (distance < -10) { distance = -10; }
							var bomb:Bomb = new Bomb(x, y, distance + (Math.random() * 5 - Math.random() * 5), 0, 4 + (Math.random() * 4), 0, false);
							bombs.push(bomb);
							Main.screen.addChild(bomb);
							Main.sound.playsfx(6);
							
							++Main.env.bombcounter;
							bombtimer = Math.random() * 50;
						}
					}
				}
			}
		}
		
		public function breakflower():void {
			Main.map.drawbackgroundtileat(coordx, coordy);
			waveanimation.pause();
		}
		
		public function reset():void {
			Main.map.drawToGrid(waveanimation.framedata, x, y);
			waveanimation.play();
			
			for (var n:int = 0; n < bombs.length; ++n) {
				Main.screen.removeChild(bombs[n]);
			}
			bombs.length = 0;
			Main.env.bombcounter = 0;
		}
		
		public function removebombs():void {
			for (var n:int = 0; n < bombs.length; ++n) {
				Main.screen.removeChild(bombs[n]);
			}
			bombs.length = 0;
			Main.env.bombcounter = 0;
		}
	}
}