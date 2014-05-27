package maps {
	
	import editor.trackmill.ui.UIManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import tools.images.ColourChanger;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Map {
		
		//grid variables
		public var gridwidth:int = 50;
		public var gridheight:int = 50;
		public const tilewidth:int = 20;
		public const tileheight:int = 20;
		public var mapwidth:int = 0;
		public var mapheight:int = 0;
		private var gmapdetails:MapDetails;
		
		//map variables
		public var map:Bitmap;
		public var mapdata:BitmapData;
		public var grid:Vector.<Node> = new Vector.<Node>;
		public var playerpoint:Point = new Point();
		private var spawnpoint:Point = new Point();
		public var colourchanger:ColourChanger;
		public var events:Array = [];
		
		//rotation variables
		public var destrotate:int = 0;
		public var currentrotation:int = 0;
		public var rotating:Boolean = false;
		public var hallucinate:Boolean = false;
		private var hoff:Boolean = false;
		private var speedup:Boolean = false;
		
		//node variables
		private var collidenode:Node;
		private var collidefreenode:Node;
		public var mapnode:Node;
		public var resetNodes:Vector.<int> = new Vector.<int>;
		private var hasmagnets:Boolean = false;
		private var lastcheckpoint:Point = new Point();
		public var resettedgame:Boolean = false;
		
		public function initiate():void {
			colourchanger = new ColourChanger();
			collidenode = new Node();
			collidenode.walkable = true;
			collidefreenode = new Node();
			collidefreenode.walkable = true;
		}
		
		public function create(mapdetails:MapDetails):void {
			gmapdetails = mapdetails;
			gridwidth = mapdetails.width;
			gridheight = mapdetails.height;
			var tilegrid:Array = mapdetails.tiles.concat();
			
			if (hallucinate) { hallucinateoff(); }
			if (speedup) { speedupoff(); }
			
			grid.length = 0;
			resetNodes.length = 0;
			Main.env.resetters.length = 0;
			Main.player.jetpackOff();
			hasmagnets = false;
			lastcheckpoint.x = -1; lastcheckpoint.y = -1;
			
			mapwidth = gridwidth * tilewidth;
			mapheight = gridheight * tileheight;
			
			map = new Bitmap();
			mapdata = new BitmapData(gridwidth * tilewidth, gridheight * tileheight, true, 0);
			map.bitmapData = mapdata;
			Main.screen.addChild(map);
			
			for (var y:int = 0; y < gridheight; ++y) {
				for (var x:int = 0; x < gridwidth; ++x) {
					var node:Node = new Node();
					var type:String = tilegrid[y * gridwidth + x];
					grid[y * gridwidth + x] = node;
					if (int(type) == -1) {
						playerpoint.x = x * 20; playerpoint.y = y * 20;
					}
					changeTile(x, y, int(type), mapdata);
				}
			}
			
			Main.mapcamera.moveTo(playerpoint.x, playerpoint.y, true);
			
			colourchanger.container = map;
			colourchanger.reset();
			
			Main.world.x = 400;
			Main.world.y = 300;
			resettedgame = false;
		}
		
		public function changeTile(gridx:int, gridy:int, type:int, displaydata:BitmapData = null, clearTile:Boolean = false, updateXMLMap:Boolean = false, updateResetNode:Boolean = true, updateWalkable:Boolean = true):void {
			var x:int = gridx * tilewidth; var y:int = gridy * tilewidth;
			if (!displaydata) { displaydata = mapdata; }
			if (gridx < 0 || gridx >= gridwidth || gridy < 0 || gridy >= gridheight) { return; }
			
			if (clearTile) {
				displaydata.fillRect(new Rectangle(x, y, tilewidth, tileheight), 0);
			}
			
			var walkable:Boolean = true;
			grid[gridy * gridwidth + gridx].type = int(type);
			if (type != 1) {
				var bgtype:int = Main.mapmanager.currentmapdetails.backgroundtiles[gridy * gridwidth + gridx];
				displaydata.copyPixels(Main.mapeditor.mapcreator.getbgtilefrom(bgtype), new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
			}
			
			switch (int(type)) {
				case 1:
					displaydata.copyPixels(Main.textures.groundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
					walkable = false;
					break;
				case 2:
					displaydata.copyPixels(Main.textures.spikeup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 3:
					displaydata.copyPixels(Main.textures.spikeleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 4:
					displaydata.copyPixels(Main.textures.spikeright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 5:
					displaydata.copyPixels(Main.textures.spikedown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 6:
					Main.env.createMine(x, y, 0);
					break;
				case 7:
					Main.env.createMine(x, y, 1);
					break;
				case 8:
					Main.env.createDirt(x, y);
					walkable = false;
					break;
				case 9:
					mapdata.copyPixels(Main.textures.stickygroundtileleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 10:
					mapdata.copyPixels(Main.textures.stickygroundtileright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 11:
					mapdata.copyPixels(Main.textures.stickygroundtiledown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 12:
					mapdata.copyPixels(Main.textures.stickygroundtileup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 13:
					if (updateResetNode) { resetNodes.push(gridx, gridy, 13); }
					displaydata.copyPixels(Main.textures.jetpack, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 14:
					Main.env.createMine(x, y, 2);
					break;
				case 15:
					Main.env.createMine(x, y, 3);
					break;
				case 16:
					displaydata.copyPixels(Main.textures.boostup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 17:
					displaydata.copyPixels(Main.textures.boostright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 18:
					displaydata.copyPixels(Main.textures.boostleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 19:
					displaydata.copyPixels(Main.textures.boostdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 20:
					displaydata.copyPixels(Main.textures.springdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 21:
					displaydata.copyPixels(Main.textures.springright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 22:
					displaydata.copyPixels(Main.textures.springleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 23:
					displaydata.copyPixels(Main.textures.springup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 24:
					displaydata.copyPixels(Main.textures.gravityblock, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = true;
					break;
				case 25:
					displaydata.copyPixels(Main.textures.gravityblockright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = true;
					break;
				case 26:
					displaydata.copyPixels(Main.textures.gravityblockleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = true;
					break;
				case 27:
					displaydata.copyPixels(Main.textures.gravityblockup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = true;
					break;
				case 28:
					Main.env.createShieldShooter(x, y, 0);
					break;
				case 29:
					Main.env.createShieldShooter(x, y, 1);
					break;
				case 30:
					Main.env.createShieldShooter(x, y, 2);
					break;
				case 31:
					Main.env.createShieldShooter(x, y, 3);
					break;
				case 32:
					Main.env.createShieldShooter(x, y, 0, true);
					break;
				case 33:
					Main.env.createShieldShooter(x, y, 1, true);
					break;
				case 34:
					Main.env.createShieldShooter(x, y, 2, true);
					break;
				case 35:
					Main.env.createShieldShooter(x, y, 3, true);
					break;
				case 36:
					displaydata.copyPixels(Main.textures.magnetdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					hasmagnets = true;
					walkable = false;
					break;
				case 37:
					displaydata.copyPixels(Main.textures.magnetright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					hasmagnets = true;
					walkable = false;
					break;
				case 38:
					displaydata.copyPixels(Main.textures.magnetleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					hasmagnets = true;
					walkable = false;
					break;
				case 39:
					displaydata.copyPixels(Main.textures.magnetup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					hasmagnets = true;
					walkable = false;
					break;
				case 40:
					if (updateResetNode) { resetNodes.push(gridx, gridy, 40); }
					displaydata.copyPixels(Main.textures.speedup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 41:
					if (updateResetNode) { resetNodes.push(gridx, gridy, 41); }
					displaydata.copyPixels(Main.textures.hallucinate, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 42:
					displaydata.copyPixels(Main.textures.gravitychanger, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 43:
					displaydata.copyPixels(Main.textures.gravitychangerright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 44:
					displaydata.copyPixels(Main.textures.gravitychangerleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 45:
					displaydata.copyPixels(Main.textures.gravitychangerup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 46:
					Main.env.createFallingSpike(x, y, 0);
					break;
				case 47:
					Main.env.createFallingSpike(x, y, 1);
					break;
				case 48:
					Main.env.createFallingSpike(x, y, 2);
					break;
				case 49:
					Main.env.createFallingSpike(x, y, 3);
					break;
				case 50:
					Main.env.createSunSpike(x, y);
					break;
				case 51:
					displaydata.copyPixels(Main.textures.middarkgroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 52:
					displaydata.copyPixels(Main.textures.darkgroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 53:
					Main.env.createFlower(x, y, 0);
					break;
				case 54:
					Main.env.createFlower(x, y, 1);
					break;
				case 55:
					Main.env.createFlower(x, y, 2);
					break;
				case 56:
					Main.env.createFlower(x, y, 3);
					break;
				case 57:
					displaydata.copyPixels(Main.textures.grasstileup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					if (updateResetNode) { resetNodes.push(gridx, gridy, 57); }
					break;
				case 58:
					displaydata.copyPixels(Main.textures.finishtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 59:
					if (updateResetNode) { resetNodes.push(gridx, gridy, 59); }
					mapdata.copyPixels(Main.textures.glass, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 60:
					Main.env.createFlower(x, y, 4, 1);
					break;
				case 61:
					Main.env.createFlower(x, y, 5, 1);
					break;
				case 62:
					Main.env.createFlower(x, y, 6, 1);
					break;
				case 63:
					Main.env.createFlower(x, y, 7, 1);
					break;
				case 64:
					displaydata.copyPixels(Main.textures.brick, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 65:
					displaydata.copyPixels(Main.textures.checkpointoff, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 66:
					displaydata.copyPixels(Main.textures.lasermachine, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 67:
					displaydata.copyPixels(Main.textures.lasermachineleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 68:
					displaydata.copyPixels(Main.textures.lasermachineright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 69:
					displaydata.copyPixels(Main.textures.lasermachineup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 70:
					displaydata.copyPixels(Main.textures.laser, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 71:
					displaydata.copyPixels(Main.textures.laserup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 72:
					displaydata.copyPixels(Main.textures.grasstileleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					if (updateResetNode) { resetNodes.push(gridx, gridy, 72); }
					break;
				case 73:
					displaydata.copyPixels(Main.textures.grasstileright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					if (updateResetNode) { resetNodes.push(gridx, gridy, 73); }
					break;
				case 74:
					displaydata.copyPixels(Main.textures.grasstiledown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					if (updateResetNode) { resetNodes.push(gridx, gridy, 74); }
					break;
				case 75:
					displaydata.copyPixels(Main.textures.floatingmine, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					if (updateResetNode) { resetNodes.push(gridx, gridy, 75); }
					break;
				case 76:
					displaydata.copyPixels(Main.textures.water,  new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 77:
					displaydata.copyPixels(Main.textures.icetileup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 78:
					displaydata.copyPixels(Main.textures.icetileright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 79:
					displaydata.copyPixels(Main.textures.icetiledown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 80:
					displaydata.copyPixels(Main.textures.icetileleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 81:
					displaydata.copyPixels(Main.textures.snowblock, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 82:
					displaydata.copyPixels(Main.textures.coral, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 83:
					displaydata.copyPixels(Main.textures.coralleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 84:
					displaydata.copyPixels(Main.textures.coralright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 85:
					displaydata.copyPixels(Main.textures.coralup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 86:
					Main.env.createSphere(x, y);
					break;
				case 87:
					displaydata.copyPixels(Main.textures.redgroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 88:
					displaydata.copyPixels(Main.textures.greengroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 89:
					displaydata.copyPixels(Main.textures.bluegroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 90:
					displaydata.copyPixels(Main.textures.blackgroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 91:
					displaydata.copyPixels(Main.textures.yellowgroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 92:
					displaydata.copyPixels(Main.textures.lava, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 93:
					displaydata.copyPixels(Main.textures.lavasuit, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					if (updateResetNode) { resetNodes.push(gridx, gridy, 93); }
					break;
				case 999:
					if (resettedgame) {
						Main.env.createSphere(x, y);
						Main.mapmanager.currentmapdetails.tiles[y * gridwidth + x] = 86;
					}
					break;
			}
			if (updateWalkable) { grid[gridy * gridwidth + gridx].walkable = walkable; }
		}
		
		public function drawToGrid(bitmapdata:BitmapData, coordx:int, coordy:int):void {
			mapdata.copyPixels(bitmapdata, new Rectangle(0, 0, tilewidth, tileheight), new Point(coordx, coordy), null, null, true);
		}
		
		public function remove():void {
			mapdata.dispose();
			Main.screen.removeChild(map);
			grid.length = 0;
			Main.screen.x = 0;
			Main.screen.y = 0;
			Main.particles.removeAll();
			Main.trail.removeAll();
			Main.env.removeAll();
			map = null;
			mapdata = null;
		}
		
		public function hallucinateoff(force:Boolean = true):void {
			if (hallucinate) {
				if (force) {
					hoff = false;
					Main.world.scaleX = 1;
					Main.world.scaleY = 1;
					Main.world.rotation = 0;
				}else {
					hoff = true;
				}
				hallucinate = false;
				Main.sound.setvolume(Main.sound.maxvolume);
				colourchanger.rgbspeed = .002;
			}
		}
		
		public function speedupoff():void {
			if (speedup) {
				Main.player.ACCELERATION = Main.player.ORIGINALACCELERATION;
				Main.player.FRICTION = Main.player.ORIGINALFRICTION;
				Main.player.trailfadespeed = .02;
				speedup = false;
			}
		}
		
		public function resetLevel():void {
			var c:int;
			for (c = 0; c < Main.env.resetters.length; ++c) {
				Main.env.resetters[c].reset();
			}
			for (c = 0; c < resetNodes.length; c += 3) {
				changeTile(resetNodes[c], resetNodes[c + 1], resetNodes[c + 2], null, true, false, false, true);
			}
			
			Main.player.jetpackOff();
			Main.player.lavasuitoff();
			Main.mapmanager.updateinfotext();
		}
		
		public function redrawLevel():void {
			resetLevel();
			remove();
			create(gmapdetails);
		}
		
		public function checkCollision(x:int, y:int, collidetype:int, types:Array = null):Boolean {
			if (currentrotation == 90) { --x;
			}else if (currentrotation == 180) { ++y;
			}else if (currentrotation == -90) { ++x;
			}
			if (x < 0 || x >= gridwidth || y < 0 || y >= gridheight) {
				return false;
			}
			var type:int = grid[y * gridwidth + x].type;
			if (types && types.length > 0) {
				for (var c:int = 0; c < types.length; ++c) {
					if (type == types[c]) {
						return true;
					}
				}
			}else {
				if (type == collidetype) {
					return true;
				}
			}
			return false;
		}
		
		private function editCheckpointTile(x:int, y:int):void {
			Main.sound.playsfx(13);
			changeTile(x, y, 80);
			Main.player.spawnx = Main.player.coordx * 20;
			Main.player.spawny = Main.player.coordy * 20;
			Main.player.spawnrotation = destrotate;
			Main.particles.create(x * 20, y * 20, 2, 20, 15, 2, null);
			grid[y * gridwidth + x].type = 80;
			Main.shakescreen.shake(6, 8);
		}
		
		private function magnetcollision(posx:int, posy:int, searchx:int, searchy:int, direction:int):void {
			while (true) {
				var node:Node = grid[posy * gridwidth + posx];
				posx += searchx; posy += searchy;
				if (posx < 0 || posx >= gridwidth || posy < 0 || posy >= gridheight) { return; }
				if (node.type >= 36 && node.type <= 39) {
					if (node.type == 36 && searchy == -1 || node.type == 37 && searchx == 1 ||
					node.type == 38 && searchx == -1 || node.type == 39 && searchy == 1) {
						pull(direction); return;
					}
				}
				if (!node.walkable) { return; }
			}
		}
		
		private function pull(direction:int, speed:Number = .8):void {
			speed = speed;
			if (direction == 0) {
				Main.player.maxgravity = 15;
				Main.player.maxspeedx = 20;
				if (currentrotation == 0) {
					Main.player.speedx += speed;
				}else if (currentrotation == 90) {
					Main.player.gravity += speed;
				}else if (currentrotation == 180) {
					Main.player.speedx -= speed;
				}else if (currentrotation == -90) {
					Main.player.gravity -= speed;
				}
			}else if (direction == 1) {
				Main.player.maxgravity = 15;
				Main.player.maxspeedx = 20;
				if (currentrotation == 0) {
					Main.player.speedx -= speed;
				}else if (currentrotation == 90) {
					Main.player.gravity -= speed;
				}else if (currentrotation == 180) {
					Main.player.speedx += speed;
				}else if (currentrotation == -90) {
					Main.player.gravity += speed;
				}
			}else if (direction == 2) {
				Main.player.maxgravity = 15;
				Main.player.maxspeedx = 20;
				if (currentrotation == 0) {
					Main.player.gravity += speed;
				}else if (currentrotation == 90) {
					Main.player.speedx -= speed;
				}else if (currentrotation == 180) {
					Main.player.gravity -= speed;
				}else if (currentrotation == -90) {
					Main.player.speedx += speed;
				}
			}else if (direction == 3) {
				Main.player.maxgravity = 15;
				Main.player.maxspeedx = 20;
				if (currentrotation == 0) {
					Main.player.gravity -= speed;
				}else if (currentrotation == 90) {
					Main.player.speedx += speed;
				}else if (currentrotation == 180) {
					Main.player.gravity += speed;
				}else if (currentrotation == -90) {
					Main.player.speedx -= speed;
				}
			}
		}
		
		public function drawbackgroundtileat(coordx:int, coordy:int):void {
			var bgtype:int = Main.mapmanager.currentmapdetails.backgroundtiles[coordy * gridwidth + coordx];
			mapdata.copyPixels(Main.mapeditor.mapcreator.getbgtilefrom(bgtype), new Rectangle(0, 0, tilewidth, tileheight), new Point(coordx * 20, coordy * 20));
		}
		
		public function handleCollision(x:int, y:int):void {
			if (x < 0 || x >= gridwidth - 1 || y < 0 || y >= gridheight - 1) {
				return;
			}
			var type:int = grid[y * gridwidth + x].type;
			if (hasmagnets) {
				magnetcollision(x, y, 0, -1, 3);
				magnetcollision(x, y, 1, 0, 0);
				magnetcollision(x, y, -1, 0, 1);
				magnetcollision(x, y, 0, 1, 2);
			}
			
			if (type >= 66 && type <= 71) {
				Main.player.die(); return;
			}
			
			switch (type) {
				case 2:
					drawbackgroundtileat(x, y);
					mapdata.copyPixels(Main.textures.spikebloodup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight), null, null, true);
					Main.player.die();
					break;
				case 3:
					drawbackgroundtileat(x, y);
					mapdata.copyPixels(Main.textures.spikebloodleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight), null, null, true);
					Main.player.die();
					break;
				case 4:
					drawbackgroundtileat(x, y);
					mapdata.copyPixels(Main.textures.spikebloodright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight), null, null, true);
					Main.player.die();
					break;
				case 5:
					drawbackgroundtileat(x, y);
					mapdata.copyPixels(Main.textures.spikeblooddown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight), null, null, true);
					Main.player.die();
					break;
				case 13:
					Main.sound.playsfx(7);
					Main.player.jetpackOn();
					changeTile(x, y, 0, null, true, false);
					break;
				case 16:
					pull(3);
					break;
				case 17:
					pull(0);
					break;
				case 18:
					pull(1);
					break;
				case 19:
					pull(2);
					break;
				case 20:
					Main.sound.playsfx(12);
					if (currentrotation == 0 && Main.player.gravity > 0) { Main.player.gravity = -20; Main.player.doublejump = true;
					}else if (currentrotation == 90 && Main.player.speedx < 0) { Main.player.speedx = 20; 
					}else if (currentrotation == 180 && Main.player.gravity < 0) { Main.player.gravity = 20; Main.player.doublejump = true; 
					}else if (currentrotation == -90 && Main.player.speedx > 0) { Main.player.speedx = -20; }
					break;
				case 21:
					Main.sound.playsfx(12);
					if (currentrotation == 0 && Main.player.speedx < 0) { Main.player.speedx = 20; 
					}else if (currentrotation == 90 && Main.player.gravity < 0) { Main.player.gravity = 20; Main.player.doublejump = true;
					}else if (currentrotation == 180 && Main.player.speedx > 0) { Main.player.speedx = -20;
					}else if (currentrotation == -90 && Main.player.gravity > 0) { Main.player.gravity = -20; Main.player.doublejump = true; }
					break;
				case 22:
					Main.sound.playsfx(12);
					if (currentrotation == 0 && Main.player.speedx > 0) { Main.player.speedx = -20;
					}else if (currentrotation == 90 && Main.player.gravity > 0) { Main.player.gravity = -20; Main.player.doublejump = true;
					}else if (currentrotation == 180 && Main.player.speedx < 0) { Main.player.speedx = 20;
					}else if (currentrotation == -90 && Main.player.gravity < 0) { Main.player.gravity = 20; Main.player.doublejump = true; }
					break;
				case 23:
					Main.sound.playsfx(12);
					if (currentrotation == 0 && Main.player.gravity < 0) { Main.player.gravity = 20; Main.player.doublejump = true; 
					}else if (currentrotation == 90 && Main.player.speedx > 0) { Main.player.speedx = -20;
					}else if (currentrotation == 180 && Main.player.gravity > 0) { Main.player.gravity = -20; Main.player.doublejump = true;
					}else if (currentrotation == -90 && Main.player.speedx < 0) { Main.player.speedx = 20; }
					break;
				case 24:
					if (currentrotation != 0) {
						Main.sound.playsfx(9);
						Main.player.x = int(x * 20) + 10; Main.player.y = int(y * 20) + 10; Main.player.gravity = 0; Main.player.speedx = 0;
						Main.player.coordx = Main.player.x / 20; Main.player.coordy = Main.player.y / 20;
					}
					currentrotation = 0;
					destrotate = 0;
					break;
				case 25:
					if (currentrotation != -90) {
						Main.sound.playsfx(9);
						Main.player.x = int(x * 20) + 10; Main.player.y = int(y * 20) + 10; Main.player.gravity = 0; Main.player.speedx = 0;
						Main.player.coordx = Main.player.x / 20; Main.player.coordy = Main.player.y / 20;
					}
					currentrotation = -90;
					destrotate = -90;
					break;
				case 26:
					if (currentrotation != 90) {
						Main.sound.playsfx(9);
						Main.player.x = int(x * 20) + 10; Main.player.y = int(y * 20) + 10; Main.player.gravity = 0; Main.player.speedx = 0;
						Main.player.coordx = Main.player.x / 20; Main.player.coordy = Main.player.y / 20;
					}
					currentrotation = 90;
					destrotate = 90;
					break;
				case 27:
					if (currentrotation != 180) {
						Main.sound.playsfx(9);
						Main.player.x = int(x * 20) + 10; Main.player.y = int(y * 20) + 10; Main.player.gravity = 0; Main.player.speedx = 0;
						Main.player.coordx = Main.player.x / 20; Main.player.coordy = Main.player.y / 20;
					}
					currentrotation = 180;
					destrotate = 180;
					break;
				case 36:
					pull(3);
					break;
				case 37:
					pull(0);
					break;
				case 38:
					pull(1);
					break;
				case 39:
					pull(2);
					break;
				case 40:
					Main.sound.playsfx(7);
					changeTile(x, y, 0, null, true, false);
					speedup = true;
					Main.player.ACCELERATION = 5; Main.player.FRICTION = .94; Main.player.trailfadespeed = .01;
					break;
				case 41:
					Main.sound.playsfx(7);
					changeTile(x, y, 0, null, true, false);
					hallucinate = true;
					colourchanger.rgbspeed = .02;
					break;
				case 42:
					if (destrotate != 0) {
						Main.sound.playsfx(9);
						Main.player.x = int(x * 20) + 10; Main.player.y = int(y * 20) + 10; Main.player.gravity = 0; Main.player.speedx = 0;
						Main.player.coordx = Main.player.x / 20; Main.player.coordy = Main.player.y / 20;
						rotateTo(0);
					}
					break;
				case 43:
					if (destrotate != -90) {
						Main.sound.playsfx(9);
						Main.player.x = int(x * 20) + 10; Main.player.y = int(y * 20) + 10; Main.player.gravity = 0; Main.player.speedx = 0;
						Main.player.coordx = Main.player.x / 20; Main.player.coordy = Main.player.y / 20;
						rotateTo( -90);
					}
					break;
				case 44:
					if (destrotate != 90) {
						Main.sound.playsfx(9);
						Main.player.x = int(x * 20) + 10; Main.player.y = int(y * 20) + 10; Main.player.gravity = 0; Main.player.speedx = 0;
						Main.player.coordx = Main.player.x / 20; Main.player.coordy = Main.player.y / 20;
						rotateTo(90);
					}
					break;
				case 45:
					if (destrotate != 180) {
						Main.sound.playsfx(9);
						Main.player.x = int(x * 20) + 10; Main.player.y = int(y * 20) + 10; Main.player.gravity = 0; Main.player.speedx = 0;
						Main.player.coordx = Main.player.x / 20; Main.player.coordy = Main.player.y / 20;
						rotateTo(180);
					}
					break;
				case 58:
					Main.mapmanager.completedmap();
					break;
				case 65:
					if (lastcheckpoint.x != x * 20 || lastcheckpoint.y != y * 20) {
						Main.mapmanager.spawnmapdetails = Main.mapmanager.currentmapdetails;
						Main.particles.create(Main.player.x, Main.player.y, 5, 15, 15, 2, null);
						Main.player.spawnx = x * 20;
						Main.player.spawny = y * 20;
						Main.player.spawnrotation = destrotate;
						
						Main.sound.playsfx(8);
						
						drawToGrid(Main.textures.checkpointon, Main.player.spawnx, Main.player.spawny);
						if (lastcheckpoint.x != -1 || lastcheckpoint.y != -1) {
							drawToGrid(Main.textures.checkpointoff, lastcheckpoint.x, lastcheckpoint.y);
						}
						lastcheckpoint.x = Main.player.spawnx;
						lastcheckpoint.y = Main.player.spawny;
					}
					break;
				case 75:
					drawbackgroundtileat(x, y);
					Main.player.die();
					break;
				case 92:
					if (!Main.player.haslavasuit) {
						Main.player.die();
					}
					break;
				case 93:
					Main.sound.playsfx(7);
					Main.player.lavasuiton();
					changeTile(x, y, 0, null, true, false);
					break;
			}
		}
		
		
		public function update():void {
			colourchanger.update();
			map.transform.colorTransform = colourchanger.transform;
			if (rotating) {
				Main.mapcamera.moveTo(Main.player.x + 10, Main.player.y + 10, false, 6);
				Main.world.rotation += (destrotate - Main.world.rotation) / 5;
				Main.player.rotation = -Main.world.rotation;
				if (Main.world.rotation >= destrotate - 1 && Main.world.rotation <= destrotate + 1) {
					Main.world.rotation = destrotate;
					Main.player.rotation = -Main.world.rotation;
					currentrotation = destrotate;
					rotating = false;
				}
			}
			
			if (!rotating) {
				if (hallucinate) {
					if (currentrotation == 0) {
						Main.world.rotation += (Math.random() * 1 - Math.random() * 1);
						if (Main.world.rotation >= currentrotation + 8) { Main.world.rotation = currentrotation + 8;
						}else if (Main.world.rotation <= currentrotation - 8) { Main.world.rotation = currentrotation - 8; }
					}
					Main.world.scaleX += (Math.random() * 1 - Math.random() * 1) / 50;
					Main.world.scaleY += (Math.random() * 1 - Math.random() * 1) / 50;
					if (Main.world.scaleX >= 1.2) { Main.world.scaleX = 1.2;
					}else if (Main.world.scaleX <= .95) { Main.world.scaleX = .95; }
					if (Main.world.scaleY >= 1.2) { Main.world.scaleY = 1.2;
					}else if (Main.world.scaleY <= .95) { Main.world.scaleY = .95; }
				}else if (hoff) {
					Main.world.scaleX += (1 - Main.world.scaleX) / 50;
					Main.world.scaleY += (1 - Main.world.scaleY) / 50;
					Main.world.rotation += (.1 - Main.world.rotation) / 20;
					if (Main.world.scaleX >= 1 - .01 && Main.world.scaleX <= 1 + .01 &&
					Main.world.scaleY >= 1 - .01 && Main.world.scaleY <= 1 + .01 &&
					Main.world.rotation <= .2 && Main.world.rotation >= -.2) {
						hoff = false;
						Main.world.scaleX = 1; Main.world.scaleY = 1; Main.world.rotation = 0;
					}
				}
			}
		}
		
		public function rotate(angle:int):void {
			Main.player.speedx = 0;
			Main.player.gravity = 0;
			if (destrotate >= 180) {
				Main.world.rotation = -180;
				Main.player.rotation = 180;
			}
			destrotate += angle;
			if (destrotate >= 270) {
				destrotate = -90;
			}else if (destrotate == 360) {
				destrotate = 0;
			}
			rotating = true;
		}
		
		public function rotateTo(angle:int):void {
			destrotate = angle;
			rotating = true;
			if (destrotate != angle) {
				Main.player.gravity = 0;
				Main.player.speedx = 0;
			}
		}
		
		public function setRotation(angle:int):void {
			Main.world.rotation = angle;
			Main.player.rotation = -angle;
			destrotate = angle;
			currentrotation = angle;
			rotating = false;
		}
		
		//collisions
		public function collideDown(coordx:int, coordy:int):Node {
			if (currentrotation == 0) {
				if (collisionLeft(coordx, coordy) == collidenode && !collisionDown(coordx, coordy).walkable) { return mapnode; }
				if (collisionRight(coordx, coordy) == collidenode && !collisionDown(coordx + 1, coordy).walkable) { return mapnode; }
			}else if (currentrotation == 90) {
				if (collisionUp(coordx, coordy) == collidenode && !collisionRight(coordx, coordy).walkable) { return mapnode; }
				if (collisionDown(coordx, coordy) == collidenode && !collisionRight(coordx, coordy + 1).walkable) { return mapnode; }
			}else if (currentrotation == 180) {
				if (collisionLeft(coordx, coordy + 1) == collidenode && !collisionDown(coordx, coordy - 1).walkable) { return mapnode; }
				if (collisionRight(coordx, coordy + 1) == collidenode && !collisionDown(coordx + 1, coordy - 1).walkable) { return mapnode; }
			}else if (currentrotation == -90) {
				if (collisionUp(coordx + 1, coordy) == collidenode && !collisionLeft(coordx, coordy).walkable) { return mapnode; }
				if (collisionDown(coordx + 1, coordy) == collidenode && !collisionLeft(coordx, coordy + 1).walkable) { return mapnode; }
			}
			return collidefreenode;
		}
		
		public function collideRight(coordx:int, coordy:int):Node {
			if (currentrotation == 0) {
				if (!collisionRight(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == 90) {
				if (!collisionUp(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == 180) {
				if (!collisionLeft(coordx, coordy + 1).walkable) { return mapnode; }
			}else if (currentrotation == -90) {
				if (!collisionDown(coordx + 1, coordy).walkable) { return mapnode; }
			}
			return collidefreenode;
		}
		
		public function collideLeft(coordx:int, coordy:int):Node {
			if (currentrotation == 0) {
				if (!collisionLeft(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == 90) {
				if (!collisionDown(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == 180) {
				if (!collisionRight(coordx, coordy + 1).walkable) { return mapnode; }
			}else if (currentrotation == -90) {
				if (!collisionUp(coordx + 1, coordy).walkable) { return mapnode; }
			}
			return collidefreenode;
		}
		
		public function collideUp(coordx:int, coordy:int):Node {
			if (currentrotation == 0) {
				if (collisionDown(coordx, coordy).walkable && !collisionUp(coordx, coordy).walkable ||
				coordy >= 0 && coordy < gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1 && !grid[coordy * gridwidth + (coordx + 1)].walkable && 
				!collisionUp(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == 90) {
				if (collisionRight(coordx, coordy) == collidenode && !collisionLeft(coordx, coordy).walkable ||
				coordy >= 0 && coordy < gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1 && !grid[(coordy + 1) * gridwidth + coordx].walkable && 
				!collisionLeft(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == 180) {
				if (collisionUp(coordx, coordy).walkable && !collisionDown(coordx, coordy).walkable ||
				coordy >= 0 && coordy < gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1 && !grid[(coordy + 1) * gridwidth + (coordx + 1)].walkable && 
				!collisionDown(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == -90) {
				if (collisionLeft(coordx, coordy) == collidenode && !collisionRight(coordx, coordy).walkable ||
				coordy >= 0 && coordy < gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1 && !grid[(coordy + 1) * gridwidth + (coordx + 1)].walkable && 
				!collisionRight(coordx, coordy).walkable) { return mapnode; }
			}
			return collidefreenode;
		}	
		
		//tile collisions
		private function collisionRight(coordx:int, coordy:int):Node {
			if (coordy >= 0 && coordy < gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1) {
				mapnode = grid[(coordy) * gridwidth + (coordx + 1)];
				if (!mapnode.walkable) {
					return mapnode;
				}
			}
			return collidenode;
		}
		
		private function collisionLeft(coordx:int, coordy:int):Node {
			if (coordy >= 0 && coordy < gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1) {
				mapnode = grid[(coordy) * gridwidth + coordx];
				if (!mapnode.walkable) {
					return mapnode;
				}
			}
			return collidenode;
		}
		
		private function collisionDown(coordx:int, coordy:int):Node {
			if (coordy >= -1 && coordy < gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1) {
				mapnode = grid[(coordy + 1) * gridwidth + coordx];
				if (!mapnode.walkable) {
					return mapnode;
				}
			}
			return collidenode;
		}
		
		private function collisionUp(coordx:int, coordy:int):Node {
			if (coordy >= 0 && coordy <= gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1) {
				mapnode = grid[coordy * gridwidth + coordx];
				if (!mapnode.walkable) {
					return mapnode;
				}
			}
			return collidenode;
		}
	}
}