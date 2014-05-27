package maps {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import tools.images.ColourChanger;
	import flash.utils.getTimer;
	import tools.text.Logo;
	import tools.text.TextManager;
	import ui.Button;
	
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
		public var xmlmaps:Vector.<XMLMap>;
		public var menumaps:Vector.<XMLMap>;
		
		//map variables
		public var map:Bitmap;
		public var mapdata:BitmapData;
		public var griddisplay:Bitmap;
		public var griddata:BitmapData;
		public var grid:Vector.<Node> = new Vector.<Node>;
		public var playerpoints:Array = [];
		public var playerpoint:Point = new Point();
		private var spawnpoint:Point = new Point();
		public var colourchanger:ColourChanger;
		public var events:Array = [];
		public var currentLevel:int = 0;
		
		//rotation variables
		public var destrotate:int = 0;
		public var currentrotation:int = 0;
		public var rotating:Boolean = false;
		public var hallucinate:Boolean = false;
		private var hoff:Boolean = false;
		private var speedup:Boolean = false;
		
		//room variables
		public var room:int = 0;
		public const DEFAULTROOM:int = 0;
		public const GRAVITYROOM:int = 1;
		public const TIMEROOM:int = 2;
		public var savedx:int;
		public var savedy:int;
		private var lastlevel:int = -1;
		private var savedlevel:Boolean = false;
		public var saveddestrotation:int = 0;
		public var savedworldrotation:int = 0;
		private var logo:Logo;
		private var createtrackmill:Logo;
		
		//node variables
		private var collidenode:Node;
		private var collidefreenode:Node;
		public var mapnode:Node;
		public var resetNodes:Vector.<int> = new Vector.<int>;
		private var checkpoints:Vector.<Checkpoint> = new Vector.<Checkpoint>;
		public var teleporternodes:Vector.<TeleporterNode> = new Vector.<TeleporterNode>;
		private var lastteleport:Point = new Point();
		private var hasmagnets:Boolean = false;
		
		public function initiate():void {
			trace("Creating XML Maps...");
			
			var timer:int = getTimer();
			xmlmaps = new Vector.<XMLMap>;
			menumaps = new Vector.<XMLMap>;
			events.length = 0;
			
			parsexmlinto(xmlmaps, Main.textures.levels);
			parsexmlinto(menumaps, Main.textures.menus);
			
			colourchanger = new ColourChanger();
			collidenode = new Node();
			collidenode.walkable = true;
			collidefreenode = new Node();
			collidefreenode.walkable = true;
			
			trace("Successfully created in " + (getTimer() - timer) + " ms");
		}
		
		private function parsexmlinto(vector:Vector.<XMLMap>, from:Array):void {
			for (var c:int = 0; c < from.length; ++c) {
				//read level data from xml level
				var xml:XML = new XML(from[c]);
				var xmlmap:XMLMap = new XMLMap();
				
				xmlmap.width = xml.level.@width;
				xmlmap.height = xml.level.@height;
				var tiles:String = xml.level.@tiles;
				tiles = tiles.replace(/\r\n/gi, "");
				xmlmap.tiles = tiles.split(",");
				
				//load events
				for (var n:int = 0; n < 10; ++n) {
					var data:String = xml.events.script.(@id == (n + 1).toString()).@data;
					if (data != "") {
						xmlmap.scripts.push(data);
					}
				}
				
				vector.push(xmlmap);
			}
		}
		
		public function create(level:int = 0):void {
			if (level >= Main.textures.levels.length) {
				level = 0;
			}
			if (level != currentLevel) { resetNodes.length = 0; }
			
			var xml:XMLMap;
			if (level == -1) {
				xml = menumaps[0];
				if (!logo) {
					logo = new Logo(0, 600 - Preloader.logo.height);
					Main.universe.addChild(logo);
				}
				if (createtrackmill && createtrackmill.stage) {
					Main.universe.removeChild(createtrackmill);
					createtrackmill = null;
				}
				logo.base.bitmapData = Preloader.logo;
				logo.y = 600 - logo.base.height;
				logo.url = "http://www.trackmill.com";
			}else {
				if (!logo) {
					logo = new Logo(0, 600 - Preloader.logo.height);
					Main.universe.addChild(logo);
				}
				if (!createtrackmill || !createtrackmill.stage) {
					trace("created");
					createtrackmill = new Logo(800 - Preloader.createtrackmill.width, 600 - Preloader.createtrackmill.height);
					createtrackmill.base.bitmapData = Preloader.createtrackmill;
					Main.universe.addChild(createtrackmill);
					createtrackmill.url = "http://trackmill.com/cat-ninja/";
				}
				xml = xmlmaps[level];
				if (logo && logo.y != 555 && logo.stage) { logo.base.bitmapData = Preloader.smalllogo; logo.y = 555; }
				logo.url = "http://www.trackmill.com/cat-ninja";
			}
			gridwidth = xml.width;
			gridheight = xml.height;
			var tilegrid:Array = xml.tiles;
			
			savedlevel = false;
			if (lastlevel == level && level != -1) { savedlevel = true; }
			currentLevel = level;
			if (level != -1) { lastlevel = level; }
			
			if (hallucinate) { hallucinateoff(); }
			if (speedup) { speedupoff(); }
			
			grid.length = 0;
			checkpoints.length = 0;
			teleporternodes.length = 0;
			resetNodes.length = 0;
			Main.env.resetters.length = 0;
			Main.player.jetpackOff();
			hasmagnets = false;
			
			if (level == -1) {
				Main.sound.play(2);
			}else if (level >= 0) {
				Main.sound.play(1);
			}
			
			mapwidth = gridwidth * tilewidth;
			mapheight = gridheight * tileheight;
			
			map = new Bitmap();
			griddisplay = new Bitmap();
			mapdata = new BitmapData(gridwidth * tilewidth, gridheight * tileheight, true, 0);
			griddata = new BitmapData(gridwidth * tilewidth, gridheight * tileheight, true, 0);
			map.bitmapData = mapdata;
			griddisplay.bitmapData = griddata;
			Main.screen.addChild(griddisplay);
			Main.screen.addChild(map);
			
			playerpoints = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
			
			spawnpoint.x = 0;
			spawnpoint.y = 0;
			for (var y:int = 0; y < gridheight; ++y) {
				for (var x:int = 0; x < gridwidth; ++x) {
					var node:Node = new Node();
					var type:String = tilegrid[y * gridwidth + x];
					var details:Array = [];
					if (type.indexOf("|") != -1) {
						details = type.substring(1, type.length - 1).split("|");
						type = "[" + details[0] + "]";
					}
					
					//detailed items
					switch (type) {
						case "[1]":
							griddata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
							playerpoints[0] = x; playerpoints[1] = y;
							if (details && details.length >= 2) { playerpoints[2] = details[1]; }
							break;
						case "[2]":
							griddata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
							playerpoints[3] = x - 1; playerpoints[4] = y;
							if (details && details.length >= 2) { playerpoints[5] = details[1]; }
							break;
						case "[3]":
							griddata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
							playerpoints[6] = x; playerpoints[7] = y;
							if (details && details.length >= 2) { playerpoints[8] = details[1]; }
							break;
						case "[4]":
							griddata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
							playerpoints[9] = x; playerpoints[10] = y;
							if (details && details.length >= 2) { playerpoints[11] = details[1]; }
							break;
						case "s":
							griddata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
							spawnpoint.x = x;
							spawnpoint.y = y;
							type = "0";
							break;
					}
					
					grid[y * gridwidth + x] = node;
					changeTile(x, y, int(type), griddata, mapdata);
				}
			}
			
			if (spawnpoint.x != 0 || spawnpoint.y != 0) {
				playerpoint.x = spawnpoint.x * 20; playerpoint.y = spawnpoint.y * 20;
			}else {
				playerpoint.x = playerpoints[0] * 20; playerpoint.y = playerpoints[1] * 20;
			}
			if (savedlevel) {
				playerpoint.x = savedx; playerpoint.y = savedy;
			}
			Main.mapcamera.moveTo(playerpoint.x, playerpoint.y, true);
			changeRoom("default");
			
			Main.interpreter.load(xml.scripts);
			colourchanger.container = map;
			colourchanger.reset();
			
			Main.world.x = 400;
			Main.world.y = 300;
			
			if (room != GRAVITYROOM) {
				rotateTo(0);
			}
			
			Main.env.screenmanager.drawAllScreens();
		}
		
		public function changeTile(gridx:int, gridy:int, type:int, bgdata:BitmapData = null, displaydata:BitmapData = null, clearTile:Boolean = false, updateXMLMap:Boolean = false, updateResetNode:Boolean = true, updateWalkable:Boolean = true):void {
			var x:int = gridx * tilewidth; var y:int = gridy * tilewidth;
			if (!bgdata) { bgdata = griddata; } if (!displaydata) { displaydata = mapdata; }
			if (gridx < 0 || gridx >= gridwidth || gridy < 0 || gridy >= gridheight) { return; }
			
			if (clearTile) {
				displaydata.fillRect(new Rectangle(x, y, tilewidth, tileheight), 0);
			}
			
			var walkable:Boolean = true;
			grid[gridy * gridwidth + gridx].type = int(type);
			if (updateXMLMap) {
				xmlmaps[currentLevel].tiles[gridy * gridwidth + gridx] = int(type);
			}
			if (type != 1 && type != 3 && type != 4) {
				bgdata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
			}
			
			switch (int(type)) {
				case 1:
					displaydata.copyPixels(Main.textures.groundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
					walkable = false;
					for (var n:int = 1; n < gridheight; ++n) {
						if (gridy - n > 0 && grid[(gridy - n) * gridwidth + gridx].type != 79) {
							if (n >= 2) {
								var checkpoint:Checkpoint = new Checkpoint();
								checkpoint.startpoint.x = gridx; checkpoint.startpoint.y = gridy - n;
								checkpoint.endpoint.x = gridx; checkpoint.endpoint.y = gridy - 1;
								checkpoints.push(checkpoint);
							}
							break;
						}
					}
					break;
				case 2:
					displaydata.copyPixels(Main.textures.spikeup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 3:
					displaydata.copyPixels(Main.textures.darkgroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
					break;
				case 4:
					displaydata.copyPixels(Main.textures.middarkgroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
					break;
				case 5:
					displaydata.copyPixels(Main.textures.spikedown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 6:
					displaydata.copyPixels(Main.textures.spikeright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 7:
					displaydata.copyPixels(Main.textures.spikeleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 8:
					Main.env.createMine(x, y, 0);
					break;
				case 9:
					Main.env.createMine(x, y, 1);
					break;
				case 10:
					displaydata.copyPixels(Main.textures.lasermachine, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 11:
					displaydata.copyPixels(Main.textures.lasermachineright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 12:
					displaydata.copyPixels(Main.textures.lasermachineleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 13:
					displaydata.copyPixels(Main.textures.lasermachineup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 14:
					displaydata.copyPixels(Main.textures.laser, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 15:
					displaydata.copyPixels(Main.textures.laserup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 16:
					Main.env.createButton(x, y, Main.textures.button, 16);
					break;
				case 17:
					Main.env.createButton(x, y, Main.textures.buttonright, 17);
					break;
				case 18:
					Main.env.createButton(x, y, Main.textures.buttonleft, 18);
					break;
				case 19:
					Main.env.createButton(x, y, Main.textures.buttonup, 19);
					break;
				case 20:
					displaydata.copyPixels(Main.textures.lasermachineoff, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 21:
					displaydata.copyPixels(Main.textures.lasermachineoffright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 22:
					displaydata.copyPixels(Main.textures.lasermachineoffleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 23:
					displaydata.copyPixels(Main.textures.lasermachineoffup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
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
					displaydata.copyPixels(Main.textures.buttonpress, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 29:
					displaydata.copyPixels(Main.textures.buttonpressright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 30:
					displaydata.copyPixels(Main.textures.buttonpressleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 31:
					displaydata.copyPixels(Main.textures.buttonpressup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 32:
					if (updateResetNode) { resetNodes.push(gridx, gridy, 32); }
					griddata.copyPixels(Main.textures.glass, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 33:
					Main.env.createDirt(x, y);
					walkable = false;
					break;
				case 34:
					Main.env.screenmanager.createScreen(x, y);
					walkable = false;
					break;
				case 35:
					Main.env.createCrate(x, y);
					walkable = false;
					break;
				case 36:
					mapdata.copyPixels(Main.textures.stickygroundtileleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 37:
					mapdata.copyPixels(Main.textures.stickygroundtileright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 38:
					mapdata.copyPixels(Main.textures.stickygroundtiledown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 39:
					mapdata.copyPixels(Main.textures.stickygroundtileup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					walkable = false;
					break;
				case 40:
					displaydata.copyPixels(Main.textures.gravitychanger, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 41:
					displaydata.copyPixels(Main.textures.gravitychangerright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 42:
					displaydata.copyPixels(Main.textures.gravitychangerleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 43:
					displaydata.copyPixels(Main.textures.gravitychangerup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 44:
					if (updateResetNode) { resetNodes.push(gridx, gridy, 44); }
					displaydata.copyPixels(Main.textures.jetpack, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 45:
					Main.env.createMine(x, y, 2);
					break;
				case 46:
					Main.env.createMine(x, y, 3);
					break;
				case 47:
					displaydata.copyPixels(Main.textures.spikecornerup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 48:
					displaydata.copyPixels(Main.textures.spikecornerright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 49:
					displaydata.copyPixels(Main.textures.spikecornerleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 50:
					displaydata.copyPixels(Main.textures.spikecornerdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 51:
					bgdata.copyPixels(Main.textures.boostup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 52:
					bgdata.copyPixels(Main.textures.boostright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 53:
					bgdata.copyPixels(Main.textures.boostleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 54:
					bgdata.copyPixels(Main.textures.boostdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 55:
					displaydata.copyPixels(Main.textures.groundtilecornerupleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 56:
					displaydata.copyPixels(Main.textures.groundtilecornerupright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 57:
					displaydata.copyPixels(Main.textures.groundtilecornerdownleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 58:
					displaydata.copyPixels(Main.textures.groundtilecornerdownright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 59:
					displaydata.copyPixels(Main.textures.springdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 60:
					displaydata.copyPixels(Main.textures.springright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 61:
					displaydata.copyPixels(Main.textures.springleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 62:
					displaydata.copyPixels(Main.textures.springup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 63:
					displaydata.copyPixels(Main.textures.teleporterdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 64:
					displaydata.copyPixels(Main.textures.teleporterright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 65:
					displaydata.copyPixels(Main.textures.teleporterleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 66:
					displaydata.copyPixels(Main.textures.teleporterup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 67:
					Main.env.createShieldShooter(x, y, 0);
					break;
				case 68:
					Main.env.createShieldShooter(x, y, 1);
					break;
				case 69:
					Main.env.createShieldShooter(x, y, 2);
					break;
				case 70:
					Main.env.createShieldShooter(x, y, 3);
					break;
				case 71:
					Main.env.createShieldShooter(x, y, 0, true);
					break;
				case 72:
					Main.env.createShieldShooter(x, y, 1, true);
					break;
				case 73:
					Main.env.createShieldShooter(x, y, 2, true);
					break;
				case 74:
					Main.env.createShieldShooter(x, y, 3, true);
					break;
				case 75:
					displaydata.copyPixels(Main.textures.magnetdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					hasmagnets = true;
					walkable = false;
					break;
				case 76:
					displaydata.copyPixels(Main.textures.magnetright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					hasmagnets = true;
					walkable = false;
					break;
				case 77:
					displaydata.copyPixels(Main.textures.magnetleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					hasmagnets = true;
					walkable = false;
					break;
				case 78:
					displaydata.copyPixels(Main.textures.magnetup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					hasmagnets = true;
					walkable = false;
					break;
				case 79:
					displaydata.copyPixels(Main.textures.checkpointoff, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 80:
					displaydata.copyPixels(Main.textures.checkpointon, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 81:
					for (var p:int = 0; p < Main.collectedpositions.length; p += 3) {
						if (Main.collectedpositions[p] == currentLevel) {
							if (Main.collectedpositions[p + 1] == gridx && Main.collectedpositions[p + 2] == gridy) {
								grid[gridy * gridwidth + gridx].walkable = true;
								return;
							}
						}
					}
					Main.env.createSphere(x, y);
					break;
				case 82:
					if (updateResetNode) { resetNodes.push(gridx, gridy, 82); }
					displaydata.copyPixels(Main.textures.speedup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 83:
					if (updateResetNode) { resetNodes.push(gridx, gridy, 83); }
					displaydata.copyPixels(Main.textures.hallucinate, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 84:
					Main.env.createFallingSpike(x, y, 0);
					break;
				case 85:
					Main.env.createFallingSpike(x, y, 1);
					break;
				case 86:
					Main.env.createFallingSpike(x, y, 2);
					break;
				case 87:
					Main.env.createFallingSpike(x, y, 3);
					break;
				case 88:
					Main.env.createSunSpike(x, y);
					break;
				case 89:
					displaydata.copyPixels(Main.textures.groundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
					break;
				case 90:
					displaydata.copyPixels(Main.textures.jailcell, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
					walkable = false;
					break;
				case 91:
					Main.env.createBigSphere(x, y);
					walkable = false;
					break;
			}
			if (updateWalkable) { grid[gridy * gridwidth + gridx].walkable = walkable; }
		}
		
		public function remove():void {
			Main.screen.removeChild(map);
			Main.screen.removeChild(griddisplay);
			grid.length = 0;
			Main.screen.x = 0;
			Main.screen.y = 0;
			Main.speech.removeAll();
			Main.particles.removeAll();
			Main.interpreter.data.length = 0;
			
			Main.env.removeAll();
			Main.text.remove();
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
				Main.sound.hsound = false;
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
				changeTile(resetNodes[c], resetNodes[c + 1], resetNodes[c + 2], null, null, true, false, false);
			}
			
			Main.player.jetpackOff();
		}
		
		public function redrawLevel():void {
			resetLevel();
			remove();
			create(currentLevel);
		}
		
		public function changeRoom(newroom:String):void {
			switch (newroom) {
				case "default":
					room = DEFAULTROOM;
					break;
				case "gravityRoom":
					room = GRAVITYROOM;
					break;
			}
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
			Main.player.spawnlevel = currentLevel;
			Main.particles.create(x * 20, y * 20, 2, 20, 15, 2, null);
			xmlmaps[currentLevel].tiles[y * gridwidth + x] = 80;
			grid[y * gridwidth + x].type = 80;
			Main.shakescreen.shake(6, 8);
		}
		
		public function handleRangeCollision(x:int, y:int, mintype:int, maxtype:int):void {
			if (x < 0 || x >= gridwidth || y < 0 || y >= gridheight) {
				return;
			}
			var type:int = grid[y * gridwidth + x].type;
			if (type < mintype || type > maxtype) { return; }
			
			switch (type) {
				case 63:
					teleportcheck(x, y);
					break;
				case 64:
					teleportcheck(x, y);
					break;
				case 65:
					teleportcheck(x, y);
					break;
				case 66:
					teleportcheck(x, y);
					break;
			}
		}
		
		private function magnetcollision(posx:int, posy:int, searchx:int, searchy:int, direction:int):void {
			while (true) {
				var node:Node = grid[posy * gridwidth + posx];
				posx += searchx; posy += searchy;
				if (posx < 0 || posx >= gridwidth || posy < 0 || posy >= gridheight) { return; }
				if (node.type >= 75 && node.type <= 78) {
					if (node.type == 75 && searchy == -1 || node.type == 76 && searchx == 1 ||
					node.type == 77 && searchx == -1 || node.type == 78 && searchy == 1) {
						pull(direction); return;
					}
				}
				if (!node.walkable) { return; }
			}
		}
		
		private function pull(direction:int, speed:Number = .8):void {
			if (direction == 0) {
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
				if (currentrotation == 0) {
					Main.player.gravity += speed;
				}else if (currentrotation == 90) {
					Main.player.speedx += speed;
				}else if (currentrotation == 180) {
					Main.player.gravity -= speed;
				}else if (currentrotation == -90) {
					Main.player.speedx += speed;
				}
			}else if (direction == 3) {
				Main.player.maxgravity = 15;
				Main.player.maxspeedx = 15;
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
		
		public function handleCollision(x:int, y:int):void {
			if (x < 0 || x >= gridwidth || y < 0 || y >= gridheight) {
				return;
			}
			var type:int = grid[y * gridwidth + x].type;
			
			if (type < 63 || type > 66) {
				if (x != lastteleport.x || y != lastteleport.y) {
					lastteleport.x = x; lastteleport.y = y;
				}
			}
			
			switch (type) {
				case 0:
					if (hasmagnets) {
						magnetcollision(x, y, 1, 0, 0);
						magnetcollision(x, y, -1, 0, 1);
						magnetcollision(x, y, 0, 1, 2);
						magnetcollision(x, y, 0, -1, 3);
					}
					break;
				case 2:
					griddata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
					mapdata.copyPixels(Main.textures.spikebloodup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight), null, null, true);
					Main.player.die();
					break;
				case 3:
					Main.player.die();
					break;
				case 5:
					griddata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
					mapdata.copyPixels(Main.textures.spikeblooddown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight), null, null, true);
					Main.player.die();
					break;
				case 6:
					griddata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
					mapdata.copyPixels(Main.textures.spikebloodright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight), null, null, true);
					Main.player.die();
					break;
				case 7:
					griddata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
					mapdata.copyPixels(Main.textures.spikebloodleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight), null, null, true);
					Main.player.die();
					break;
				case 24:
					if (currentrotation != 0) {
						Main.sound.playsfx(9);
					}
					currentrotation = 0;
					destrotate = 0;
					break;
				case 25:
					if (currentrotation != -90) {
						Main.sound.playsfx(9);
					}
					currentrotation = -90;
					destrotate = -90;
					break;
				case 26:
					if (currentrotation != 90) {
						Main.sound.playsfx(9);
					}
					currentrotation = 90;
					destrotate = 90;
					break;
				case 27:
					if (currentrotation != 180) {
						Main.sound.playsfx(9);
					}
					currentrotation = 180;
					destrotate = 180;
					break;
				case 40:
					if (destrotate != 0) {
						Main.sound.playsfx(9);
						rotateTo(0);
					}
					break;
				case 41:
					if (destrotate != -90) {
						Main.sound.playsfx(9);
						rotateTo( -90);
					}
					break;
				case 42:
					if (destrotate != 90) {
						Main.sound.playsfx(9);
						rotateTo(90);
					}
					break;
				case 43:
					if (destrotate != 180) {
						Main.sound.playsfx(9);
						rotateTo(180);
					}
					break;
				case 44:
					Main.sound.playsfx(7);
					Main.player.jetpackOn();
					changeTile(x, y, 0, null, null, true, false);
					break;
				case 51:
					pull(3);
					break;
				case 52:
					pull(0);
					break;
				case 53:
					pull(1);
					break;
				case 54:
					pull(2);
					break;
				case 59:
					Main.sound.playsfx(12);
					Main.player.gravity = -20; Main.player.doublejump = true;
					break;
				case 60:
					Main.sound.playsfx(12);
					Main.player.gravity = -20; Main.player.doublejump = true;
					break;
				case 61:
					Main.sound.playsfx(12);
					Main.player.gravity = -20; Main.player.doublejump = true;
					break;
				case 62:
					Main.sound.playsfx(12);
					Main.player.gravity = -20; Main.player.doublejump = true;
					break;
				case 79:
					for each (var checkpoint:Checkpoint in checkpoints) {
						for (var x:int = checkpoint.startpoint.y; x < checkpoint.endpoint.y; ++x) {
							if (y >= checkpoint.startpoint.y && y <= checkpoint.endpoint.y) {
								editCheckpointTile(checkpoint.startpoint.x, x + 1);
							}
						}
					}
					break;
				case 82:
					Main.sound.playsfx(7);
					changeTile(x, y, 0, null, null, true, false);
					speedup = true;
					Main.player.ACCELERATION = 5; Main.player.FRICTION = .94; Main.player.trailfadespeed = .01;
					break;
				case 83:
					Main.sound.playsfx(7);
					changeTile(x, y, 0, null, null, true, false);
					hallucinate = true;
					Main.sound.hsound = true;
					colourchanger.rgbspeed = .02;
					break;
			}
			if (type >= 11 && type <= 15) {
				Main.player.die();
			}
		}
		
		private function teleportcheck(x:int, y:int):void {
			if (Main.player.speedx >= -.5 && Main.player.speedx <= .5) {
				if (x != lastteleport.x || y != lastteleport.y) {
					for each (var node:TeleporterNode in teleporternodes) {
						if (x == node.startpoint.x && y == node.startpoint.y) {
							Main.sound.playsfx(13);
							Main.player.x = node.endpoint.x * 20;
							Main.player.y = node.endpoint.y * 20;
							Main.player.speedx = 0;
							Main.player.updatecoords();
							lastteleport.x = node.endpoint.x; lastteleport.y = node.endpoint.y;
							return;
						}
					}
				}
			}
		}
		
		public function update():void {
			colourchanger.update();
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
			
			if (hallucinate) {
				Main.world.rotation += (Math.random() * 1 - Math.random() * 1);
				Main.world.scaleX += (Math.random() * 1 - Math.random() * 1) / 50;
				Main.world.scaleY += (Math.random() * 1 - Math.random() * 1) / 50;
				if (Main.world.rotation >= 15) { Main.world.rotation = 15;
				}else if (Main.world.rotation <= -15) { Main.world.rotation = -15; }
				if (Main.world.scaleX >= 1.4) { Main.world.scaleX = 1.4;
				}else if (Main.world.scaleX <= .9) { Main.world.scaleX = .9; }
				if (Main.world.scaleY >= 1.4) { Main.world.scaleY = 1.4;
				}else if (Main.world.scaleY <= .9) { Main.world.scaleY = .9; }
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
		
		//change levels
		public function gotoLevel(level:int, func:Function = null):void {
			if (level != currentLevel) {
				currentLevel = level;
				updateLevel("", func);
			}
		}
		
		public function updateLevel(direction:String = "", func:Function = null):void {
			Main.fadingscreen = true;
			Main.doublefade = true;
			Main.fadein = true;
			Main.fadescreen.visible = true;
			Main.fadespeed = .08;
			Main.pausegame = true;
			Main.faded = false;
			Main.targetfunction = function():void {
				Main.pausegame = false;
				remove();
				create(currentLevel);
				
				//continue saved point
				if (Main.menu.exitedmap && currentLevel == -1) {
					playerpoints[6] = 140;
					playerpoints[7] = 15;
					playerpoints[5] = lastlevel;
					Main.menu.exitedmap = false;
				}else if (!Main.menu.exitedmap && currentLevel == -1) {
					lastlevel = -1;
					savedlevel = false;
					playerpoints[5] = 0;
				}
				if (direction == "right") {
					playerpoint.x = playerpoints[0] * 20; playerpoint.y = playerpoints[1] * 20;
				}else if (direction == "left") {
					playerpoint.x = playerpoints[3] * 20; playerpoint.y = playerpoints[4] * 20;
				}
				if (direction == "up") {
					playerpoint.x = playerpoints[9] * 20; playerpoint.y = playerpoints[10] * 20;
				}else if (direction == "down") {
					playerpoint.x = playerpoints[6] * 20; playerpoint.y = playerpoints[7] * 20;
				}
				if (savedlevel) {
					playerpoint.x = savedx; playerpoint.y = savedy;
					destrotate = saveddestrotation;
					currentrotation = saveddestrotation;
					Main.world.rotation = savedworldrotation;
					Main.player.rotation = savedworldrotation;
					rotating = false;
				}
				Main.mapcamera.moveTo(playerpoint.x, playerpoint.y, true);
				
				Main.player.reset();
				
				if (func != null) { func(); }
			}
		}
		
		//move to next or previous level
		public function moveRight():void {
			if (playerpoints[5] != 0) { currentLevel = playerpoints[5];
			}else { ++currentLevel; }
			updateLevel("right");
		}
		
		public function moveLeft():void {
			if (playerpoints[2] != 0) { currentLevel = playerpoints[2];
			}else { --currentLevel; }
			updateLevel("left");
		}
		
		public function moveDown():void {
			if (playerpoints[8] != 0) { currentLevel = playerpoints[8];
			}else { ++currentLevel; }
			updateLevel("down");
		}
		
		public function moveUp():void {
			if (playerpoints[11] != 0) { currentLevel = playerpoints[11];
			}else { --currentLevel; }
			updateLevel("up");
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
				coordy >= 0 && coordy < gridheight - 1 && !grid[coordy * gridwidth + (coordx + 1)].walkable && 
				!collisionUp(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == 90) {
				if (collisionRight(coordx, coordy) == collidenode && !collisionLeft(coordx, coordy).walkable ||
				coordy >= 0 && coordy < gridheight - 1 && !grid[(coordy + 1) * gridwidth + coordx].walkable && 
				!collisionLeft(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == 180) {
				if (collisionUp(coordx, coordy).walkable && !collisionDown(coordx, coordy).walkable ||
				coordy >= 0 && coordy < gridheight - 1 && !grid[(coordy + 1) * gridwidth + (coordx + 1)].walkable && 
				!collisionDown(coordx, coordy).walkable) { return mapnode; }
			}else if (currentrotation == -90) {
				if (collisionLeft(coordx, coordy) == collidenode && !collisionRight(coordx, coordy).walkable ||
				coordy >= 0 && coordy < gridheight - 1 && !grid[(coordy + 1) * gridwidth + (coordx + 1)].walkable && 
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
			if (coordy >= 0 && coordy < gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1) {
				mapnode = grid[(coordy + 1) * gridwidth + coordx];
				if (!mapnode.walkable) {
					return mapnode;
				}
			}
			return collidenode;
		}
		
		private function collisionUp(coordx:int, coordy:int):Node {
			if (coordy >= 0 && coordy < gridheight - 1 && coordx >= 0 && coordx < gridwidth - 1) {
				mapnode = grid[coordy * gridwidth + coordx];
				if (!mapnode.walkable) {
					return mapnode;
				}
			}
			return collidenode;
		}
	}
}