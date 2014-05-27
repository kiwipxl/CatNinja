package entities {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import tools.animation.AnimateControl;
	import tools.images.ColourChanger;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Player extends Sprite {
		
		//player variables
		private var base:Bitmap = new Bitmap();
		public var dead:Boolean = false;
		public var spawnx:int = 0;
		public var spawny:int = 0;
		public var spawnrotation:int = 0;
		public var spawnlevel:int = 0;
		private var offsetx:int = 0;
		private var offsety:int = 0;
		public var coordx:int = 0;
		public var coordy:int = 0;
		public var colourtransform:ColourChanger;
		private var scaleoffset:int = 0;
		public var stopMovement:Boolean = false;
		public var doublejump:Boolean = false;
		public var doublefalling:Boolean = false;
		public var rolling:Boolean = false;
		private var forceSlam:Boolean = false;
		private var hitwall:Boolean = false;
		public var maxspeedx:int = 0;
		public var maxgravity:int = 0;
		
		//movement variables
		public var speedx:Number = 0;
		public var gravity:Number = 0;
		private var onground:Boolean = true;
		public var MAXSPEED:int = 6;
		public const ORIGINALMAXSPEED:int = 6;
		public var ACCELERATION:Number = 1;
		public const ORIGINALACCELERATION:int = 1;
		public var FRICTION:Number = .9;
		public const ORIGINALFRICTION:Number = .9;
		private const FALLSPEED:Number = .5;
		public var trailfadespeed:Number = .02;
		
		//animation variables
		public var animation:AnimateControl;
		public var walkingframes:Array;
		public var jumpingframes:Array;
		
		//auto walk variables
		public var walkSteps:Boolean = false;
		public var stepAmount:int = 0;
		private var steps:int = 0;
		private var lastX:int = 0;
		
		//jetpack variables
		public var basejetpack:Bitmap;
		public var hasJetPack:Boolean = false;
		private var usingjetpack:Boolean = false;
		
		public function create():void {
			base.bitmapData = Main.textures.characteridle;
			basejetpack = new Bitmap(Main.textures.jetpackaddon);
			offsetx = base.width / 2;
			offsety = base.height / 2;
			base.x = -offsetx;
			base.y = -offsety;
			addChild(base);
			base.smoothing = true;
			basejetpack.x = -15;
			basejetpack.y = -offsety;
			
			Main.screen.addChild(this);
			
			reset();
			
			spawnx = x;
			spawny = y;
			spawnlevel = Main.map.currentLevel;
			
			colourtransform = new ColourChanger(null, .01, 2);
			
			walkingframes = [[Main.textures.characteridle, Main.textures.characteridle2], [Main.textures.characterwalk1, Main.textures.characterwalk2]];
			animation = Main.animation.create(base, walkingframes, 8, true);
		}
		
		public function reset():void {
			dead = false;
			forceSlam = false;
			x = Main.map.playerpoint.x + offsetx;
			y = Main.map.playerpoint.y + offsety;
			Main.mapcamera.moveTo(x, y);
			
			if (stage) { Main.screen.setChildIndex(this, Main.screen.numChildren - 1); }
		}
		
		public function walk():void {
			animation.update();
			animation.play();
			animation.framespeed = 12; animation.state = 1;
			if (stepAmount > 0) {
				x += 1;
			}else {
				x -= 1;
			}
			
			if (lastX != int((x - offsetx) / 20)) {
				lastX = int((x - offsetx) / 20);
				++steps;
				if (steps >= Math.abs(stepAmount)) {
					walkSteps = false;
					steps = 0;
					stepAmount = 0;
					animation.pause();
					base.bitmapData = Main.textures.characteridle;
				}
			}
		}
		
		public function update():void {
			if (walkSteps) {
				walk();
			}
			
			if (gravity >= maxgravity) { gravity = maxgravity; } else if (gravity <= -maxgravity) { gravity = -maxgravity; }
			if (speedx >= maxspeedx) { speedx = maxspeedx; } else if (speedx <= -maxspeedx) { speedx = -maxspeedx; }
			maxgravity = 12;
			maxspeedx = 6;
			
			if (!usingjetpack) { gravity += FALLSPEED; }
			if (!usingjetpack && Main.keyboard.downKeyDown && !stopMovement && !hitwall) {
				gravity += FALLSPEED * 2;
				maxspeedx = 10;
				FRICTION = .94;
				base.bitmapData = Main.textures.characterroll;
				basejetpack.visible = false;
				maxgravity = 15;
				if (onground && speedx == 0) {
					animation.pause(); base.bitmapData = Main.textures.characterduck; basejetpack.scaleY = .5; basejetpack.y = 0;
					basejetpack.visible = true;
				}
			}else {
				basejetpack.scaleY = 1; basejetpack.visible = true; basejetpack.y = -offsety;
				MAXSPEED = ORIGINALMAXSPEED;
				FRICTION = ORIGINALFRICTION;
			}
			
			if (hasJetPack && usingjetpack) {
				if (Main.keyboard.upKeyDown) { gravity -= FALLSPEED * 2; }
				if (Main.keyboard.downKeyDown) { gravity += FALLSPEED * 2; }
				if (gravity >= MAXSPEED) { gravity = MAXSPEED; } else if (gravity <= -MAXSPEED) { gravity = -MAXSPEED; }
				gravity = gravity * FRICTION;
				Main.trail.create(x + (5 * scaleoffset) - 15, y - offsety, null, 2, this, trailfadespeed, .8, null, rotation);
			}
			
			animation.update();
			
			updatecoords();
			Main.map.handleCollision(int(x / 20), int(y / 20));
			//teleporter collision
			if (Main.map.teleporternodes.length != 0) {
				Main.map.handleRangeCollision(int(x / 20) + 1, int(y / 20), 63, 66);
				Main.map.handleRangeCollision(int(x / 20) - 1, int(y / 20), 63, 66);
				Main.map.handleRangeCollision(int(x / 20), int(y / 20), 63, 66);
			}
			
			colourtransform.update();
			transform.colorTransform = colourtransform.transform;
			
			//accelerate
			if (Main.keyboard.rightKeyDown && !stopMovement) {
				speedx += ACCELERATION;
				animation.play();
				animation.framespeed = 8; animation.state = 1;
				scaleX = 1;
				if (Main.map.currentrotation == 180) { scaleoffset = base.width - 20; }else { scaleoffset = 0; }
			}
			if (Main.keyboard.leftKeyDown && !stopMovement) {
				speedx -= ACCELERATION;
				animation.play();
				animation.framespeed = 8; animation.state = 1;
				scaleX = -1;
				if (Main.map.currentrotation == 180) { scaleoffset = 0; }else { scaleoffset = base.width - 20; }
			}
			
			//friction
			speedx = speedx * FRICTION;
			var idle:Boolean = false;
			if (!Main.keyboard.rightKeyDown && !Main.keyboard.leftKeyDown && speedx <= .1 && speedx >= -.1 && !stopMovement && gravity > 0) {
				speedx = 0;
				animation.play();
				animation.framespeed = 25; animation.state = 0;
				idle = true;
			}
			if (gravity < 0 && !onground) {
				animation.pause();
				base.bitmapData = Main.textures.characterjump;
			}else if (gravity > 0 && !onground) {
				animation.play();
				animation.framespeed = 12; animation.state = 0;
			}
			
			//collision on block above player
			var hitroof:Boolean = false;
			if (gravity < 0 && !Main.map.collideUp(coordx, coordy).walkable) {
				gravity = 0;
				if (Main.map.currentrotation == 0) { y = (coordy + 1) * 20 + offsety;
				}else if (Main.map.currentrotation == 90) { x = (coordx + 1) * 20 + offsetx;
				}else if (Main.map.currentrotation == 180) { y = (coordy) * 20 + offsety;
				}else if (Main.map.currentrotation == -90) { x = (coordx) * 20 + offsetx; }
				hitroof = true;
			}
			
			//wall collision
			hitwall = false;
			if (!hitroof && speedx > 0 && coordx < Main.map.gridwidth - 1) {
				if (!Main.map.collideRight(coordx, coordy).walkable) {
					speedx = 0;
					if (Main.map.currentrotation == 0) { x = coordx * 20 + offsetx + 1;
					}else if (Main.map.currentrotation == 90) { y = (coordy + 1) * 20 + offsety - 1;
					}else if (Main.map.currentrotation == 180) { x = (coordx + 1) * 20 + offsetx - 1;
					}else if (Main.map.currentrotation == -90) { y = (coordy) * 20 + offsety; }
				}
			}
			if (!hitroof && speedx < 0 && coordx >= 0) {
				if (!Main.map.collideLeft(coordx, coordy).walkable) {
					speedx = 0;
					if (Main.map.currentrotation == 0) { x = (coordx + 1) * 20 + offsetx - 1;
					}else if (Main.map.currentrotation == 90) { y = (coordy) * 20 + offsety;
					}else if (Main.map.currentrotation == 180) { x = (coordx) * 20 + offsetx;
					}else if (Main.map.currentrotation == -90) { y = (coordy + 1) * 20 + offsety - 1; }
				}
			}
			walljump();
			
			if (coordx < 0) {
				Main.map.moveLeft();
				return;
			}else if (coordx > Main.map.gridwidth - 2) {
				Main.map.moveRight();
				return;
			}
			if (coordy < 0) {
				Main.map.moveUp();
				return;
			}else if (coordy > Main.map.gridheight - 1) {
				Main.map.moveDown();
				return;
			}
			
			switch (Main.map.currentrotation) {
				case 0:
					x += speedx; y += gravity;
					break;
				case 90:
					y -= speedx; x += gravity;
					break;
				case 180:
					x -= speedx; y -= gravity;
					break;
				case -90:
					y += speedx; x -= gravity;
					break;
			}
			
			//jumping movement
			onground = false;
			if (forceSlam) {
				base.bitmapData = Main.textures.characterroll;
				gravity = 10;
			}
			if (gravity >= 0) {
				if (!onground && gravity > 4 && coordy > 1 && coordy < Main.map.gridheight - 2) {
					//slow down if a block is under player
					if (!Main.map.collideDown(coordx, coordy + 1).walkable) {
						if (gravity >= 5) {
							slam();
						}
						gravity = gravity / 2;
					}
				}
				
				//collision on floor
				if (!Main.map.collideDown(coordx, coordy).walkable) {
					if (gravity >= 5) {
						slam();
					}
					gravity = 0;
					forceSlam = false;
					doublejump = true;
					doublefalling = false;
					if (Main.map.currentrotation == 0) { y = coordy * 20 + offsety;
					}else if (Main.map.currentrotation == 90) { x = coordx * 20 + offsetx;
					}else if (Main.map.currentrotation == 180) { y = (coordy + 1) * 20 + offsety - 1;
					}else if (Main.map.currentrotation == -90) { x = (coordx + 1) * 20 + offsety; }
					onground = true;
				}
			}
			
			if (!stopMovement) {
				if (!onground && !hitwall && doublefalling || Main.keyboard.downKeyDown && speedx != 0) {
					if (!usingjetpack && !doublefalling || !hasJetPack) {
						base.bitmapData = Main.textures.characterroll;
						if (scaleX == 1) {
							rotation += 20;
						}else {
							rotation -= 20;
						}
						if (hasJetPack && !rolling) { rotation = -Main.map.currentrotation; }
						if (Main.keyboard.downKeyDown && speedx != 0) {
							rolling = true;
						}
					}
				}else {
					rotation = -Main.map.currentrotation;
					rolling = false;
				}
			}
			
			if (!usingjetpack && Main.keyboard.downKeyDown && !stopMovement && !hitwall) {
				base.bitmapData = Main.textures.characterroll;
				basejetpack.visible = false;
				if (onground && speedx == 0) {
					animation.pause(); base.bitmapData = Main.textures.characterduck; basejetpack.scaleY = .5; basejetpack.y = 0;
					basejetpack.visible = true;
				}
			}
			
			if (!idle) {
				if (!hasJetPack || !usingjetpack) {
					Main.trail.create(x - offsetx - scaleoffset, y - offsety, base.bitmapData, 1, this, trailfadespeed, .25, colourtransform.transform, rotation);
				}
			}
		}
		
		public function updatecoords():void {
			coordx = int((x - offsetx) / 20);
			coordy = int((y - offsety) / 20);
		}
		
		public function die():void {
			if (!dead) {
				++Main.pdeaths;
				Main.info.update();
				if (Math.random() > .5) { Main.sound.playsfx(3); } else { Main.sound.playsfx(4); }
				Main.text.screenmessage("", Main.env.screenmanager.respawn);
				Main.particles.create(x, y - 20, 6, 15, 15, 0, Main.textures.characterparts);
				Main.particles.create(x, y - 20, 40, 25, 15, 1, null);
				Main.shakescreen.shake(15, 15);
				if (stage) { Main.screen.removeChild(this); }
				dead = true;
				Main.time.runFunctionIn(1500, respawn);
			}
		}
		
		public function respawn():void {
			Main.map.speedupoff();
			if (Main.map.currentLevel == spawnlevel) {
				Main.map.hallucinateoff(false);
				respawngame();
			}else {
				Main.map.hallucinateoff();
				Main.map.gotoLevel(spawnlevel, respawngame);
			}
		}
		
		public function respawngame():void {
			Main.sound.playsfx(14);
			Main.interpreter.interperate(0, "goto(respawn)", false);
			
			Main.particles.removeAll();
			if (!stage) { Main.screen.addChild(this); }
			
			Main.map.resetLevel();
			var snapcam:Boolean = false;
			if (Main.map.currentLevel != spawnlevel) {
				snapcam = true;
			}
			Main.shakescreen.shake(15, 15);
			
			Main.keyboard.rightKeyDown = false; Main.keyboard.leftKeyDown = false;
			Main.keyboard.upKeyDown = false; Main.keyboard.downKeyDown = false;
			if (Main.world.rotation == Main.map.currentrotation) { Main.map.rotateTo(spawnrotation);
			}else { Main.map.currentrotation = spawnrotation; Main.map.destrotate = spawnrotation; }
			
			x = spawnx + offsetx;
			y = spawny + offsety;
			if (snapcam) { Main.mapcamera.moveTo(x, y, true); }else { Main.mapcamera.moveTo(x, y, false, 8, true); }
			Main.particles.create(x, y - 20, 10, 20, 15, 2, null);
			gravity = 0;
			speedx = 0;
			onground = false;
			dead = false;
		}
		
		private function slam():void {
			var hit:Boolean = false;
			Main.sound.playsfx(11);
			for (var n:int = 0; n < 4; ++n) {
				var type:int;
				if (Main.map.currentrotation == 0) {
					type = Main.map.grid[(coordy + 2) * Main.map.gridwidth + (coordx + (n - 2))].type;
				}
				if (type == 32 || type == 35) {
					if (type == 32) {
						Main.map.changeTile(coordx + (n - 2), coordy + 2, 0, null, null, false, false);
						Main.particles.create(x, y, 6, 10, 10, 5);
						hit = true;
					}
				}
			}
			if (hit) {
				forceSlam = true;
				gravity = 15;
				coordy = int((y - offsety) / 20);
				slam();
			}
			
			if (gravity <= 10) { return; }
			Main.shakescreen.shake(gravity - 8, 15);
			Main.particles.create(x, y, gravity - 8, 6, 12, 3);
			for (var c:int = 0; c < Main.env.buttons.length; ++c) {
				Main.env.buttons[c].slam();
			}
		}
		
		public function upKeyDown():void {
			if (usingjetpack) { return; }
			updatecoords();
			
			//basic jump
			if (onground && !stopMovement) {
				gravity = -8;
				onground = false;
				Main.sound.playsfx(5);
			}
			
			if (doublejump && gravity >= -6 && !stopMovement) {
				gravity = -8;
				onground = false;
				doublejump = false;
				doublefalling = true;
				Main.sound.playsfx(2);
			}
			
			walljump(true);
		}
		
		private function walljump(jump:Boolean = false):void {
			if (coordy >= 0 && coordy < Main.map.gridheight) {
				if (speedx <= 0 && !onground) {
					if (!Main.map.collideLeft(coordx, coordy).walkable && Main.map.currentrotation == 0 || 
					!Main.map.collideLeft(coordx - 1, coordy).walkable && Main.map.currentrotation == 90 || 
					!Main.map.collideLeft(coordx, coordy).walkable && Main.map.currentrotation == -90 || 
					Main.map.currentrotation == 180 && !Main.map.collideLeft(coordx, coordy).walkable) {
						if (Main.map.mapnode.type != 1 && Main.map.mapnode.type != 90) { return; }
						if (jump) {
							speedx = 12;
							gravity = -12;
							Main.sound.playsfx(5);
						}else if (gravity >= 0 && Main.keyboard.leftKeyDown) {
							gravity = 2; animation.pause(); base.bitmapData = Main.textures.characterwallslide;
							hitwall = true;
						}
					}
				}
				if (speedx >= 0 && !onground) {
					if (!Main.map.collideRight(coordx, coordy).walkable && Main.map.currentrotation == 0 || 
					!Main.map.collideRight(coordx, coordy).walkable && Main.map.currentrotation == 90 || 
					!Main.map.collideRight(coordx, coordy).walkable && Main.map.currentrotation == -90 || 
					Main.map.currentrotation == 180 && !Main.map.collideRight(coordx, coordy).walkable) {
						if (Main.map.mapnode.type != 1 && Main.map.mapnode.type != 90) { return; }
						if (jump) {
							speedx = -12;
							gravity = -12;
							Main.sound.playsfx(5);
						}else if (gravity >= 0 && Main.keyboard.rightKeyDown) {
							gravity = 2; animation.pause(); base.bitmapData = Main.textures.characterwallslide;
							hitwall = true;
						}
					}
				}
			}
		}
		
		public function togglejetpack():void {
			if (hasJetPack) {
				if (usingjetpack) { usingjetpack = false; }else if (!rolling) { usingjetpack = true; }
			}
		}
		
		public function jetpackOn():void {
			hasJetPack = true;
			if (!basejetpack.stage) { addChild(basejetpack); setChildIndex(base, numChildren - 1); }
		}
		
		public function jetpackOff():void {
			hasJetPack = false;
			usingjetpack = false;
			if (basejetpack && basejetpack.stage) { removeChild(basejetpack); }
		}
	}
}