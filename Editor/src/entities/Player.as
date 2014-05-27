package entities {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import maps.Node;
	import tools.animation.AnimateControl;
	import tools.images.ColourChanger;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Player extends Sprite {
		
		//player variables
		public var base:Bitmap = new Bitmap();
		public var dead:Boolean = false;
		public var spawnx:int = 0;
		public var spawny:int = 0;
		public var spawnrotation:int = 0;
		public var spawnlevel:int = 0;
		public var offsetx:int = 0;
		public var offsety:int = 0;
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
		public var allowrespawn:Boolean = true;
		private var inwater:Boolean = false;
		public var respawns:int = 0;
		private var hat:Bitmap;
		
		//movement variables
		public var speedx:Number = 0;
		public var gravity:Number = 0;
		public var onground:Boolean = true;
		public var MAXSPEED:int = 6;
		public const ORIGINALMAXSPEED:int = 6;
		public var ACCELERATION:Number = 1;
		public const ORIGINALACCELERATION:int = 1;
		public var FRICTION:Number = .9;
		public const ORIGINALFRICTION:Number = .9;
		private var FALLSPEED:Number = .5;
		public var trailfadespeed:Number = .02;
		
		//animation variables
		public var animation:AnimateControl;
		public var walkingframes:Array;
		public var jumpingframes:Array;
		
		//jetpack variables
		public var basejetpack:Bitmap;
		public var hasJetPack:Boolean = false;
		private var usingjetpack:Boolean = false;
		
		//lava variables
		public var baselavasuit:Bitmap;
		public var haslavasuit:Boolean = false;
		
		public function create():void {
			base.bitmapData = Main.textures.characteridle;
			basejetpack = new Bitmap(Main.textures.jetpackaddon);
			baselavasuit = new Bitmap(Main.textures.lavasuitaddon);
			offsetx = base.width / 2;
			offsety = base.height / 2;
			base.x = -offsetx;
			base.y = -offsety;
			baselavasuit.x = -offsetx;
			baselavasuit.y = -offsety;
			addChild(base);
			base.smoothing = true;
			basejetpack.x = -15;
			basejetpack.y = -offsety;
			//hat = new Bitmap(Main.textures.christmashat);
			//addChild(hat);
			//hat.x = -offsetx;
			//hat.y = -16;
			respawns = 0;
			rotation = 0;
			
			Main.screen.addChild(this);
			
			reset();
			doublejump = true;
			
			speedx = 0;
			gravity = 0;
			spawnx = x;
			spawny = y;
			
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
		
		public function update():void {
			if (dead) { return; }
			
			var tilenode:Node;
			if (gravity >= maxgravity) { gravity = maxgravity; }else if (gravity <= -maxgravity) { gravity = -maxgravity; }
			if (speedx >= maxspeedx) { speedx = maxspeedx; }else if (speedx <= -maxspeedx) { speedx = -maxspeedx; }
			
			var backgroundtiles:Array = Main.mapmanager.currentmapdetails.backgroundtiles;
			if (inwater && backgroundtiles[coordy * Main.map.gridwidth + coordx] != 76 && inwater && backgroundtiles[coordy * Main.map.gridwidth + coordx] != 92) {
				if (gravity <= -2) { maxgravity = 5; gravity = -5; } inwater = false;
			}else if (!inwater && backgroundtiles[coordy * Main.map.gridwidth + coordx] == 76) {
				Main.particles.create(x, y, 15, 8, 15, 8, null);
				inwater = true;
			}else if (!inwater && backgroundtiles[coordy * Main.map.gridwidth + coordx] == 92) {
				Main.particles.create(x, y, 15, 8, 15, 1, null);
				inwater = true;
			}else if (backgroundtiles[coordy * Main.map.gridwidth + coordx] == 76 || backgroundtiles[coordy * Main.map.gridwidth + coordx] == 92) {
			inwater = true; }else { inwater = false; }
			
			if (inwater) {
				if (backgroundtiles[coordy * Main.map.gridwidth + coordx] == 76) { lavasuitoff(); }
				if (usingjetpack) { usingjetpack = false; }
				
				if (!onground) { rotation = -Main.map.currentrotation + (speedx * 5); }else { rotation = -Main.map.currentrotation; }
				if (gravity >= 0) {
					maxspeedx = 2;
					maxgravity = 1;
					FALLSPEED = .25;
					if (Main.keyboard.downKeyDown) {
						maxgravity = 4;
					}
				}
			}else {
				maxgravity = 12;
				maxspeedx = 6;
				FALLSPEED = .5;
			}
			
			if (!usingjetpack) { gravity += FALLSPEED; }
			
			if (!usingjetpack && Main.keyboard.downKeyDown && !stopMovement && !hitwall && !inwater) {
				gravity += FALLSPEED * 2;
				maxspeedx = 10;
				FRICTION = .94;
				base.bitmapData = Main.textures.characterroll;
				maxgravity = 15;
				if (onground && speedx == 0) {
					animation.pause(); base.bitmapData = Main.textures.characterduck; basejetpack.scaleY = .5; basejetpack.y = 0; if (hat) { hat.y = -5; }
				}
			}else {
				basejetpack.scaleY = 1; basejetpack.y = -offsety; if (hat) { hat.y = -16; }
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
			if (dead) { return; }
			
			colourtransform.update();
			transform.colorTransform = colourtransform.transform;
			
			tilenode = Main.map.collideDown(coordx, coordy);
			if (onground && tilenode.type >= 77 && tilenode.type <= 81) {
				ACCELERATION = .6; FRICTION = .98; maxspeedx = 10;
			}
			
			//accelerate
			if (Main.keyboard.rightKeyDown && !stopMovement) {
				speedx += ACCELERATION;
				animation.play();
				animation.framespeed = 8; animation.state = 1;
				scaleX = 1;
				if (Main.map.currentrotation == 180) { scaleoffset = base.width - 20; } else { scaleoffset = 0; }
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
				if (!hitwall) {
					gravity = 0;
					if (Main.map.currentrotation == 0) { y = (coordy + 1) * 20 + offsety;
					}else if (Main.map.currentrotation == 90) { x = (coordx + 1) * 20 + offsetx;
					}else if (Main.map.currentrotation == 180) { y = (coordy) * 20 + offsety;
					}else if (Main.map.currentrotation == -90) { x = (coordx) * 20 + offsetx; }
					hitroof = true;
				}
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
			
			if (Main.mapmanager.rooms.length >= 2) {
				if (coordx < 0) {
					Main.mapmanager.moverooms( -1, 0);
					return;
				}else if (coordx > Main.map.gridwidth - 2) {
					Main.mapmanager.moverooms(1, 0);
					return;
				}
				if (coordy < 0) {
					Main.mapmanager.moverooms(0, -1);
					return;
				}else if (coordy > Main.map.gridheight - 2) {
					Main.mapmanager.moverooms(0, 1);
					return;
				}
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
						if (gravity >= 10) {
							slam();
						}
						gravity = gravity / 2;
					}
				}
				
				//collision on floor
				if (!Main.map.collideDown(coordx, coordy).walkable) {
					//particle walking effects
					if (!inwater && speedx > 8 || !inwater && speedx < -8) {
						var n:Node = Main.map.collideDown(coordx, coordy);
						if (n.type == 57 || n.type >= 72 && n.type <= 74) { Main.particles.create(x, y, 1, 10, 5, 7, null); }
					}
					
					if (gravity >= 10) {
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
			
			if (!stopMovement && !inwater) {
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
							if (hat) { hat.y = -16; }
						}
					}
				}else {
					rotation = -Main.map.currentrotation;
					rolling = false;
				}
			}
			
			if (!usingjetpack && Main.keyboard.downKeyDown && !stopMovement && !hitwall && !inwater) {
				base.bitmapData = Main.textures.characterroll;
				if (onground && speedx == 0) {
					animation.pause(); base.bitmapData = Main.textures.characterduck; basejetpack.scaleY = .5; basejetpack.y = 0;
				}
			}
			
			if (!idle) {
				if (!hasJetPack || !usingjetpack) {
					if (!haslavasuit) {
						Main.trail.create(x - offsetx - scaleoffset, y - offsety, base.bitmapData, 1, this, trailfadespeed, .25, colourtransform.transform, rotation);
					}else {
						Main.trail.create(x - offsetx - scaleoffset, y - offsety, Main.textures.lavasuitaddon, 1, this, trailfadespeed, .25, colourtransform.transform, rotation);
					}
				}
			}
			
			if (coordx < -1 || coordy < -1 || coordx > Main.map.gridwidth || coordy > Main.map.gridheight) {
				die();
			}
		}
		
		public function updatecoords():void {
			coordx = int((x - offsetx) / 20);
			coordy = int((y - offsety) / 20);
		}
		
		public function die():void {
			if (!dead) {
				++respawns;
				dead = true;
				Main.mapmanager.updateinfotext();
				if (Math.random() > .5) { Main.sound.playsfx(3); } else { Main.sound.playsfx(4); }
				Main.particles.create(x, y - 20, 40, 25, 15, 1, null);
				Main.shakescreen.shake(15, 15);
				if (stage) { Main.screen.removeChild(this); }
				if (allowrespawn) { Main.time.runFunctionIn(1500, respawn); }
			}
		}

		public function remove():void {
			jetpackOff();
			lavasuitoff();
			if (stage) { if (hat && hat.stage) { removeChild(hat); } Main.screen.removeChild(this); }
		}
		
		public function respawn():void {
			Main.map.speedupoff();
			
			if (Main.mapmanager.currentmapdetails != Main.mapmanager.spawnmapdetails) {
				Main.map.hallucinateoff();
				Main.mapmanager.gotoroom(Main.mapmanager.spawnmapdetails);
			}else {
				Main.map.hallucinateoff(false);
				respawngame();
			}
		}
		
		public function respawngame(force:Boolean = false):void {
			if (allowrespawn || force) {
				Main.sound.playsfx(14);
				
				Main.particles.removeAll();
				if (!stage) { Main.screen.addChild(this); }
				
				Main.map.resetLevel();
				Main.shakescreen.shake(15, 15);
				
				Main.keyboard.rightKeyDown = false; Main.keyboard.leftKeyDown = false;
				Main.keyboard.upKeyDown = false; Main.keyboard.downKeyDown = false;
				if (Main.world.rotation == Main.map.currentrotation) { Main.map.rotateTo(spawnrotation);
				}else { Main.map.currentrotation = spawnrotation; Main.map.destrotate = spawnrotation; }
				x = spawnx;
				y = spawny;
				coordx = x / 20; coordy = y / 20;
				doublejump = true; doublefalling = false;
				
				Main.mapcamera.moveTo(x, y, true);
				Main.particles.create(x, y - 20, 10, 20, 15, 2, null);
				gravity = 0;
				speedx = 0;
				onground = false;
				dead = false;
				forceSlam = false;
				
				jetpackOff();
				lavasuitoff();
			}
		}
		
		private function slam():void {
			var hit:Boolean = false;
			Main.sound.playsfx(11);
			var offset:int;
			for (var n:int = 0; n < 3; ++n) {
				offset = -1 + n;
				if (coordy < Main.map.gridheight - 3 && coordy > 1 && coordx < Main.map.gridwidth - 3 && coordx > 1) {
					if (Main.map.grid[(coordy + 2) * Main.map.gridwidth + (coordx + offset)].type == 59) {
						Main.map.changeTile(coordx + offset, coordy + 2, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}else if (Main.map.grid[coordy * Main.map.gridwidth + (coordx + offset)].type == 59) {
						Main.map.changeTile(coordx + offset, coordy, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}else if (Main.map.grid[(coordy + offset) * Main.map.gridwidth + (coordx + offset)].type == 59) {
						Main.map.changeTile(coordx + offset, coordy + offset, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}else if (Main.map.grid[(coordy + offset) * Main.map.gridwidth + (coordx)].type == 59) {
						Main.map.changeTile(coordx, coordy + offset, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}
					
					if (Main.map.grid[(coordy + 2) * Main.map.gridwidth + coordx + 2].type == 59) {
						Main.map.changeTile(coordx + 2, coordy + 2, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}
					if (Main.map.grid[(coordy - 2) * Main.map.gridwidth + coordx - 2].type == 59) {
						Main.map.changeTile(coordx - 2, coordy - 2, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}
					if (Main.map.grid[(coordy + 2) * Main.map.gridwidth + coordx].type == 59) {
						Main.map.changeTile(coordx, coordy + 2, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}
					if (Main.map.grid[(coordy - 2) * Main.map.gridwidth + coordx].type == 59) {
						Main.map.changeTile(coordx, coordy - 2, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}if (Main.map.grid[(coordy) * Main.map.gridwidth + coordx + 2].type == 59) {
						Main.map.changeTile(coordx + 2, coordy, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}if (Main.map.grid[(coordy) * Main.map.gridwidth + coordx - 2].type == 59) {
						Main.map.changeTile(coordx - 2, coordy, 0, null, false, false); Main.particles.create(x, y, 6, 10, 10, 4); hit = true; gravity = 15; break;
					}
				}
			}
			if (hit) {
				forceSlam = true;
				slam();
			}
			
			if (gravity <= 10) { return; }
			Main.shakescreen.shake(gravity - 8, 15);
			Main.particles.create(x, y, gravity - 8, 6, 12, 3);
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
			
			if (inwater) { maxgravity = 5; gravity = -5; doublejump = true; doublefalling = false; }
			
			if (!inwater) { walljump(true); }
		}
		
		private function walljump(jump:Boolean = false):void {
			if (coordy >= 0 && coordy < Main.map.gridheight) {
				if (speedx <= 0 && !onground) {
					if (!Main.map.collideLeft(coordx, coordy).walkable && Main.map.currentrotation == 0 || 
					!Main.map.collideLeft(coordx - 1, coordy).walkable && Main.map.currentrotation == 90 || 
					!Main.map.collideLeft(coordx, coordy).walkable && Main.map.currentrotation == -90 || 
					Main.map.currentrotation == 180 && !Main.map.collideLeft(coordx, coordy).walkable) {
						if (Main.map.mapnode.type >= 9 && Main.map.mapnode.type <= 12) { return; }
						if (jump) {
							speedx = 12;
							gravity = -12;
							Main.sound.playsfx(5);
							hitwall = true;
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
						if (Main.map.mapnode.type >= 9 && Main.map.mapnode.type <= 12) { return; }
						if (jump) {
							speedx = -12;
							gravity = -12;
							Main.sound.playsfx(5);
							hitwall = true;
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
			rotation = -Main.map.currentrotation;
			if (!basejetpack.stage) { addChild(basejetpack); setChildIndex(base, numChildren - 1); if (hat && hat.stage) { setChildIndex(hat, numChildren - 1); } }
		}
		
		public function jetpackOff():void {
			hasJetPack = false;
			usingjetpack = false;
			if (basejetpack && basejetpack.stage) { removeChild(basejetpack); }
		}
		
		public function lavasuiton():void {
			haslavasuit = true;
			rotation = -Main.map.currentrotation;
			base.alpha = .2;
			if (!baselavasuit.stage) { addChild(baselavasuit); setChildIndex(base, numChildren - 1); if (hat && hat.stage) { setChildIndex(hat, numChildren - 1); } }
		}
		
		public function lavasuitoff():void {
			haslavasuit = false;
			base.alpha = 1;
			if (baselavasuit && baselavasuit.stage) { Main.particles.create(x, y, 15, 8, 15, 5, null); removeChild(baselavasuit); }
		}
	}
}