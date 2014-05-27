package entities {
	
	import environment.Bomb;
	import environment.Bullet;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Boss extends Sprite {
		
		//boss variables
		private var container:Sprite = new Sprite();
		private var base:Sprite = new Sprite();
		public var created:Boolean = false;
		private var lineoffset:int = 5;
		private const points:Array = [ -10, 40, 0, 80, 10, 40, 0, 0, 
			0, 80, 15, 120, 20, 80, 10, 40, 
			15, 120, 40, 140, 42, 120, 20, 80,
			40, 140, 80, 135, 65, 110, 42, 120,
			80, 135, 110, 110, 95, 90, 65, 110,
			110, 110, 120, 65, 110, 40, 95, 90,
			120, 65, 125, 25, 110, 0, 110, 40,
			125, 25, 115, -25, 105, -45, 110, 0,
			105, -45, 70, -55, 70, -30, 110, 0,
			70, -55, 25, -50, 40, -30, 70, -30,
			25, -50, 0, 0, 10, 40, 40, -30,
			20, 80, 40, 50, 40, 50, 25, 8,
			42, 120, 55, 80, 40, 50, 40, 50,
			65, 110, 55, 80, 55, 80, 55, 80,
			95, 90, 70, 60, 55, 80, 55, 80,
			110, 40, 85, 45, 55, 80, 55, 80,
			110, 0, 85, 20, 85, 45, 85, 45,
			70, -30, 65, -10, 85, 20, 85, 20,
			40, -30, 55, 10, 65, -10, 65, -10,
			40, 50, 55, 10, 55, 10, 55, 10,
			55, 10, 70, 60, 70, 60, 70, 60,
			55, 10, 85, 45, 85, 45, 85, 45,
			40, -30, 22, 8, 40, 50, 56, 16,
			110, 40, 85, 45, 85, 20, 110, 0];
		private var colours:Array = [0x1E9ADD, 0xD67A1F, 0x8C0003, 0x000000];
		private var id:int = 0;
		private var intro:Boolean = true;
		private var routineid:int = 0;
		private var attackid:int = 0;
		private var ptimer:int = 0;
		private var prate:int = 0;
		private var weapon:int = 0;
		private var bullettimer:int;
		private var maxbullets:int;
		private var bulletsshot:int = 0;
		private var homing:Boolean = false;
		private var destx:int;
		private var desty:int;
		private var bulletrate:int = 0;
		private var bullets:Vector.<Bullet> = new Vector.<Bullet>;
		private var bombs:Vector.<Bomb> = new Vector.<Bomb>;
		private var speed:int;
		private var invincibletimer:int;
		private var invincible:Boolean = false;
		private var defeated:Boolean = false;
		private var deftimer:int = 0;
		private var particletimer:int = 0;
		
		public function create():void {
			addChild(container);
			container.addChild(base);
			container.scaleX = -1;
			base.filters = [new GlowFilter(0, 1, 14, 14, 2, 1, true, false)];
			
			drawboss();
			x = 3600 + (width / 2); y = 550 + (height / 2);
			
			Main.screen.addChild(this);
			created = true;
			intro = true;
			defeated = false;
			particletimer = 0;
			deftimer = 0;
		}
		
		public function remove():void {
			if (created) {
				id = 0;
				x = 3600 + (width / 2); y = 650 + (height / 2);
				Main.screen.removeChild(this);
				created = false;
				scaleX = 1; scaleY = 1; base.alpha = 1;
				
				for (var n:int = 0; n < bombs.length; ++n) {
					Main.screen.removeChild(bombs[n]);
				}
				bullets.length = 0;
				bombs.length = 0;
			}
		}
		
		private function defeat():void {
			if (id >= 4) {
				Main.particles.create(x, y, 10, 25, 25, 1, null);
				defeated = true;
				particletimer = 0;
				deftimer = 0;
			}
		}
		
		public function update():void {
			if (!invincible && !defeated) {
				if (x >= Main.player.x - (base.width / 2) && x <= Main.player.x + (base.width / 2) &&
					y >= Main.player.y - base.height && y <= Main.player.y + base.height) {
					if (Main.player.y < y - (base.height / 1.5)) {
						Main.player.gravity = -40;
						Main.player.speedx = -Main.player.maxspeedx;
						hit();
						destx = 3550; desty = 600; speed = 15;
						routineid = 3;
						ptimer = 0;
						prate = 100;
						attackid = 0;
						invincible = true;
						invincibletimer = 0;
						defeat();
						for (var i:int = 0; i < 4; ++i) {
							Main.particles.create(x + Math.random() * 100 - Math.random() * 100, y + Math.random() * 100 - Math.random() * 100, 
															5, 25, 25, 1 + (Math.random() * 6), null);
							Main.sound.playsfx(4);
						}
					}else {
						Main.player.die();
						invincible = true;
						invincibletimer = 0;
					}
				}
			}
			
			if (intro) {
				--x;
				if (x <= 3250) {
					x = 3250;
					intro = false;
					Main.player.stopMovement = false;
					Main.text.createtext("<font size='60' color='#ff0000'>Kitty must die!</font>", 0, 20, .1, 1, true, 220);
					attackid = 0;
					routineid = 0;
					weapon = 0;
					ptimer = 0;
					prate = 50;
					destx = 3350;
					desty = 600;
					bullettimer = 0;
					bulletsshot = 0;
					homing = false;
					speed = 100;
					invincible = false;
					invincibletimer = 0;
				}
			}else if (defeated) {
				if (base.alpha > 0) {
					++particletimer;
					if (particletimer >= 5) {
						particletimer = 0;
						Main.particles.create(x + Math.random() * 100 - Math.random() * 100, y + Math.random() * 100 - Math.random() * 100, 
														10, 25, 25, 1 + (Math.random() * 6), null);
						Main.sound.playsfx(4);
					}
					base.alpha -= .001;
				}
				++deftimer;
				if (deftimer >= 400) {
					remove();
					deftimer = 0;
					if (!Main.player.dead) {
						Main.map.playerpoints[8] = 29;
						Main.map.moveDown();
					}
				}
			}else {
				x -= (x - destx) / speed;
				y -= (y - desty) / speed;
				
				if (attackid == 1) {
					++bullettimer;
					if (bullettimer >= bulletrate && bulletsshot < maxbullets) {
						bullettimer = 0;
						++bulletsshot;
						if (weapon == 1) {
							var bullet:Bullet = new Bullet(x, y - 100, Main.player, 6, Math.random() * (255 * 255 * 255), homing);
							bullets.push(bullet);
							Main.sound.playsfx(10);
						}else {
							var bomb:Bomb = new Bomb(x, y - 100);
							bombs.push(bomb);
							Main.screen.addChild(bomb);
							Main.sound.playsfx(6);
						}
					}
				}
				
				++ptimer;
				if (ptimer >= prate) {
					ptimer = 0;
					++routineid;
					if (routineid == 1) {
						bulletsshot = 0;
						attackid = 1;
						prate = 300;
						bulletrate = 50;
						if (id == 2) { bulletrate = 100; prate = 320; } else if (id == 3) { bulletrate = 80; prate = 550; }
						maxbullets = 4;
						if (id == 2) { maxbullets = 1; } else if (id == 3) { maxbullets = 3; }
						weapon = 1;
						speed = 80;
						destx = 3350; desty = 600;
					}else if (routineid == 2) {
						attackid = 1;
						bulletsshot = 0;
						maxbullets = 5;
						if (id == 2) { maxbullets = 8; } else if (id == 3) { maxbullets = 15; }
						prate = 150;
						bulletrate = 25;
						if (id == 2) { bulletrate = 20; } else if (id == 3) { bulletrate = 20; prate = 300; }
						speed = 80;
						destx = 3400; desty = 650;
						weapon = 2;
					}else if (routineid == 3) {
						attackid = 0;
						prate = 150;
						destx = 3300; desty = 800 + (id * 50);
					}else if (routineid == 4) {
						attackid = 0;
						prate = 0;
						if (id >= 2) {
							routineid = 0;
						}else {
							routineid = int(Math.random() * 2);
						}
					}
				}
				
				++invincibletimer;
				if (invincibletimer >= 80) {
					invincibletimer = 0;
					invincible = false;
				}
				
				var n:int = 0;
				for (n = 0; n < bullets.length; ++n) {
					bullets[n].update();
					if (bullets[n].removed) {
						Main.sound.playsfx(3);
						Main.particles.create(bullets[n].x, bullets[n].y, 2, 10, 10, 3);
						bullets.splice(n, 1);
						--n;
					}
				}
				for (n = 0; n < bombs.length; ++n) {
					bombs[n].update();
					if (bombs[n].removed) {
						Main.particles.create(bombs[n].x, bombs[n].y, 2, 10, 10, 1);
						Main.screen.removeChild(bombs[n]);
						bombs.splice(n, 1);
						--n;
					}
				}
			}
			
			drawboss();
		}
		
		private function drawboss():void {
			var rand:Array = [getrand(), getrand(), getrand(), getrand()];
			var colour:int = colours[id];
			
			base.graphics.clear();
			base.graphics.lineStyle(1, 0x000000);
			base.graphics.beginFill(colour);
			var count:int = 0;
			for (var n:int = 0; n < points.length; n += 2) {
				var cid:int = Math.random() * (rand.length - 1);
				var cid2:int = Math.random() * (rand.length - 1);
				if (count >= 4) {
					count = 0;
					base.graphics.moveTo(points[n] + rand[cid], points[n + 1] + rand[cid2]);
					
					base.graphics.endFill();
					base.graphics.lineStyle(1, 0xFF0000);
					if (n >= 176) {
						base.graphics.beginFill(0xA80004);
					}else if (n <= 80) {
						base.graphics.lineStyle(1, 0x000000);
						base.graphics.beginFill(colour);
					}
				}else {
					base.graphics.lineTo(points[n] + rand[cid], points[n + 1] + rand[cid2]);
				}
				++count;
			}
			base.x = -base.width / 2;
			base.y = -base.height / 2;
		}
		
		private function getrand():int {
			return Math.random() * lineoffset - Math.random() * lineoffset;
		}
		
		public function hit():void {
			++id;
			if (id == 1) {
				lineoffset = 7;
				container.scaleX = -1.1; scaleY = 1.1;
			}else if (id == 2) {
				lineoffset = 6;
				container.scaleX = -1.4; scaleY = 1.4;
				homing = true;
			}else if (id == 3) {
				lineoffset = 10;
				container.scaleX = -2; scaleY = 2;
				homing = true;
			}
		}
	}
}