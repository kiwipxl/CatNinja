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
	public class ShieldShooter extends Bitmap {
		
		//shieldshooter variables
		private var sheet:Array;
		private var timer:int = 0;
		private var startat:int = 0;
		private const RATE:int = 100;
		public var bullets:Vector.<Bullet> = new Vector.<Bullet>;
		private var animation:AnimateControl;
		private var homingbullet:Boolean = false;
		
		public function ShieldShooter(graphic:int, homing:Boolean):void {
			switch (graphic) {
				case 0:
					if (!homing) { sheet = Main.textures.shieldshooter;
					}else if (homing) { sheet = Main.textures.homingshooter; }
					break;
				case 1:
					if (!homing) { sheet = Main.textures.shieldshooterright;
					}else if (homing) { sheet = Main.textures.homingshooterright; }
					break;
				case 2:
					if (!homing) { sheet = Main.textures.shieldshooterleft;
					}else if (homing) { sheet = Main.textures.homingshooterleft; }
					break;
				case 3:
					if (!homing) { sheet = Main.textures.shieldshooterup;
					}else if (homing) { sheet = Main.textures.homingshooterup; }
					break;
			}
			super(sheet[0]);
			animation = Main.animation.create(this, sheet, 5, false);
			animation.play();
			animation.loop = false;
			homingbullet = homing;
			timer = (Math.random() * RATE) / 4;
		}
		
		public function update():void {
			if (x >= Main.player.x - 500 && x <= Main.player.x + 500 && y >= Main.player.y - 400 && y <= Main.player.y + 400) {
				++timer;
				if (!Main.player.dead && timer >= RATE) {
					if (Main.env.bulletcounter <= 15) {
						Main.sound.playsfx(10);
						var bullet:Bullet = new Bullet(x, y, Main.player, 6, Math.random() * (255 * 255 * 255), homingbullet);
						bullets.push(bullet);
						timer = (Math.random() * RATE) / 4;
						startat = timer;
						animation.currentframe = animation.frames.length - 1;
						animation.updateFrame();
						animation.reverse = true;
					}
				}
				if (timer >= RATE - 20) {
					animation.reverse = false;
					animation.update();
				}
				if (timer >= 40 && timer <= startat + 60 && animation.reverse) {
					animation.update();
				}
			}else {
				--timer; if (timer <= 0) { timer = 0; animation.reverse = true; }
				animation.update();
			}
			if (x >= Main.player.x - 1200 && x <= Main.player.x + 1200 && y >= Main.player.y - 800 && y <= Main.player.y + 800) {
				for (var n:int = 0; n < bullets.length; ++n) {
					bullets[n].update();
					if (bullets[n].removed) {
						Main.particles.create(bullets[n].x, bullets[n].y, 2, 10, 10, 3);
						bullets.splice(n, 1);
						--n;
						--Main.env.bulletcounter;
					}
				}
			}
		}
	}
}