package editor {
	
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.system.System;
	import tools.images.ColourChanger;
	import maps.MapDetails;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class MapCreator {
		
		//mapcreator variables
		public var mapresizer:MapResizer = new MapResizer();
		//public var blueprint:BlueprintManager = new BlueprintManager();
		public var grid:Array = []; //our grid array that contains integers
		public var gridwidth:int = 60; //the width of our grid
		public var gridheight:int = 40; //the height of our grid
		public var map:Bitmap; //our display object of the map
		public var mapdata:BitmapData; //our data of the map in pixels
		public const MAXWIDTH:int = 150;
		public const MAXHEIGHT:int = 150;
		public var currentTile:int = 1; //the current block type to place on the editor
		public var originaltile:int = 1;
		public var tilerotateindex:int = 0;
		public const tilewidth:int = 20;  //width of tile
		public const tileheight:int = 20; //height of tile
		public var details:MapDetails = new MapDetails();
		public var defaultgrid:Array = [];
		public var defaultgridwidth:int = 0;
		public var defaultgridheight:int = 0;
		public var firstload:Boolean = true;
		public var backgroundtiles:Array = [];
		public var defaultbackgroundgrid:Array = [];
		
		//block variables
		public var colourchanger:ColourChanger;
		public var currentcharpos:Point = new Point( -1, -1);
		public var charroom:MapDetails;
		public var lastcharpos:Point = new Point();
		public var solidblocks:Array = [1, 8, 9, 10, 11, 12, 57, 58, 59, 64, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 84, 85, 87, 88, 89, 90, 91];
		public var starttilepos:Point = new Point();
		public var lastcurrenttile:int = 0;
		
		//tileplacer variables
		public var tileplacer:Bitmap;
		public var tileplacerdata:BitmapData;
		public var invalidtile:Boolean = false;
		public var lasttilepos:Point = new Point();
		public var greentransform:ColorTransform;
		public var redtransform:ColorTransform;
		public var greentransformheavy:ColorTransform;
		public var redtransformheavy:ColorTransform;
		
		public function createmap():void {
			mapresizer.parent = this;
			//blueprint.parent = this;
			
			map = new Bitmap();
			mapdata = new BitmapData(gridwidth * tilewidth, gridheight * tileheight, true, 0);
			
			if (firstload) {
				for (var x:int = 0; x < gridwidth; ++x) {
					for (var y:int = 0; y < gridheight; ++y) {
						mapdata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
						grid.push(0);
					}
				}
				defaultbackgroundgrid = grid.concat();
				backgroundtiles = defaultbackgroundgrid.concat();
				
				var length:int = gridwidth;
				for (var m:int = 0; m < 4; ++m) {
					for (var p:int = 0; p < length; ++p) {
						if (m == 0) { replaceTile(p, 0, 1);
						}else if (m == 1) { replaceTile(p, gridheight - 1, 1);
						}else if (m == 2) { replaceTile(0, p, 1);
						}else if (m == 3) { replaceTile(gridwidth - 1, p, 1); }
					}
					if (m >= 1) { length = gridheight; }
				}
				
				defaultgrid = grid.concat();
				defaultgridwidth = gridwidth;
				defaultgridheight = gridheight;
			}
			
			map.bitmapData = mapdata;
			Main.universe.addChild(map);
			colourchanger = new ColourChanger(map, .001, 1.4);
			
			charroom = Main.mapeditor.roommanager.currentroom;
			tileplacerdata = new BitmapData(20, 20, true, 0);
			drawDataByType(currentTile, 0, 0, tileplacerdata, true, false, 20, 20, false);
			tileplacer = new Bitmap(tileplacerdata);
			Main.universe.addChild(tileplacer);
			drawtileplacer();
			
			greentransform = new ColorTransform(1, 1, 1, 1, 1, 150, 1);
			redtransform = new ColorTransform(1, 1, 1, 1, 150, 1, 1);
			greentransformheavy = new ColorTransform(1, 1, 1, 1, 1, 255, 1);
			redtransformheavy = new ColorTransform(1, 1, 1, 1, 255, 1, 1);
			tileplacer.transform.colorTransform = greentransform;
			
			if (currentcharpos.x == -1 && currentcharpos.y == -1) {
				lastcharpos.x = gridwidth / 2; lastcharpos.y = gridheight / 2;
				currentcharpos.x = lastcharpos.x; currentcharpos.y = lastcharpos.y;
				drawDataByType( -1, lastcharpos.x, lastcharpos.y, mapdata, true, false, 20, 20, false);
				replaceTile(0, 0, 1);
				grid[lastcharpos.y * gridwidth + lastcharpos.x] = -1;
			}
			charroom = Main.mapeditor.roommanager.currentroom;
			
			Main.mapeditor.created = true;
			mapresizer.resizing = false;
			firstload = false;
		}
		
		public function remove():void {
			Main.mapeditor.created = false;
			Main.universe.removeChild(map);
			Main.universe.removeChild(tileplacer);
			if (mapdata) { mapdata.dispose(); }
			tileplacerdata.dispose();
		}
		
		public function drawtileplacer():void {
			if (Main.mapeditor.brushsize != 1) {
				tileplacerdata = new BitmapData((Main.mapeditor.brushsize + 2) * 20, (Main.mapeditor.brushsize + 2) * 20, false, 0);
				for (var u:int = 0; u < Main.mapeditor.brushsize + 2; ++u) {
					for (var t:int = 0; t < Main.mapeditor.brushsize + 2; ++t) {
						tileplacerdata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, 20, 20), new Point(u * 20, t * 20));
						drawDataByType(currentTile, u, t, tileplacerdata, false, true, 20, 20, false);
					}
				}
			}else {
				tileplacerdata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, 20, 20), new Point(0, 0));
				if (tileplacerdata.width != 20) { tileplacerdata = new BitmapData(20, 20, false, 0); }
				drawDataByType(currentTile, 0, 0, tileplacerdata, false, true, 20, 20, false);
			}
			tileplacer.bitmapData = tileplacerdata;
		}
		
		//gets the bitmapdata to draw onto the map by it's tile type
		public function drawDataByType(type:int, x:Number, y:Number, data:BitmapData, drawgrid:Boolean = true, icon:Boolean = false, w:int = 20, h:int = 20, overridespecials:Boolean = true, bgtype:int = 0):void {
			x = x * w;
			y = y * h;
			
			if (type != -1 && overridespecials) {
				if (int(x / 20) == currentcharpos.x && int(y / 20) == currentcharpos.y) {
					if (charroom != null && Main.mapeditor.roommanager.currentroom != charroom) {
						charroom.tiles[currentcharpos.y * charroom.width + currentcharpos.x] = 0;
					}
					currentcharpos.x = -1; currentcharpos.y = -1;
				}
			}
			if (overridespecials && details.finishtiles > 0 && type != 58 && !icon && grid[int(y / 20) * gridwidth + int(x / 20)] == 58) {
				--details.finishtiles;
			}
			
			if (backgroundtiles.length > 0) {
				if (bgtype == 0) { bgtype = backgroundtiles[int(y / h) * gridwidth + int(x / w)]; }
				var bgtile:BitmapData = getbgtilefrom(bgtype);
				if (!icon && bgtile != null) {
					data.copyPixels(bgtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
				}else if (drawgrid) { data.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
				}
				bgtile = null;
			}
			
			switch (type) {
				case -1:
					if (!icon && overridespecials) {
						if (int(x / 20) != lastcharpos.x || int(y / 20) != lastcharpos.y) {
							replaceTile(lastcharpos.x, lastcharpos.y, backgroundtiles[lastcharpos.y * gridwidth + lastcharpos.x]);
						}
					}
					data.copyPixels(Main.textures.startingpoint, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					if (!icon && overridespecials) {
						currentcharpos.x = int(x / 20); currentcharpos.y = int(y / 20);
						lastcharpos.x = int(x / 20); lastcharpos.y = int(y / 20);
						charroom = Main.mapeditor.roommanager.currentroom;
					}
					break;
				case 1:
					data.copyPixels(Main.textures.groundtile, new Rectangle(0, 0, w, h), new Point(x, y));
					break;
				case 2:
					data.copyPixels(Main.textures.spikeup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 3:
					data.copyPixels(Main.textures.spikeleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 4:
					data.copyPixels(Main.textures.spikeright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 5:
					data.copyPixels(Main.textures.spikedown, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 6:
					data.copyPixels(Main.textures.mineblinkoff, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 7:
					data.copyPixels(Main.textures.mineblinkoffup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 8:
					data.copyPixels(Main.textures.dirtblocks[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 9:
					data.copyPixels(Main.textures.stickygroundtileleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 10:
					data.copyPixels(Main.textures.stickygroundtileright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 11:
					data.copyPixels(Main.textures.stickygroundtiledown, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 12:
					data.copyPixels(Main.textures.stickygroundtileup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 13:
					data.copyPixels(Main.textures.jetpack, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 14:
					data.copyPixels(Main.textures.mineblinkoffright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 15:
					data.copyPixels(Main.textures.mineblinkoffleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 16:
					data.copyPixels(Main.textures.boostup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 17:
					data.copyPixels(Main.textures.boostright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 18:
					data.copyPixels(Main.textures.boostleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 19:
					data.copyPixels(Main.textures.boostdown, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 20:
					data.copyPixels(Main.textures.springdown, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 21:
					data.copyPixels(Main.textures.springright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 22:
					data.copyPixels(Main.textures.springleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 23:
					data.copyPixels(Main.textures.springup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 24:
					data.copyPixels(Main.textures.gravityblock, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 25:
					data.copyPixels(Main.textures.gravityblockright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 26:
					data.copyPixels(Main.textures.gravityblockleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 27:
					data.copyPixels(Main.textures.gravityblockup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 28:
					data.copyPixels(Main.textures.shieldshooter[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 29:
					data.copyPixels(Main.textures.shieldshooterright[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 30:
					data.copyPixels(Main.textures.shieldshooterleft[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 31:
					data.copyPixels(Main.textures.shieldshooterup[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 32:
					data.copyPixels(Main.textures.homingshooter[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 33:
					data.copyPixels(Main.textures.homingshooterright[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 34:
					data.copyPixels(Main.textures.homingshooterleft[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 35:
					data.copyPixels(Main.textures.homingshooterup[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 36:
					data.copyPixels(Main.textures.magnetdown, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 37:
					data.copyPixels(Main.textures.magnetright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 38:
					data.copyPixels(Main.textures.magnetleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 39:
					data.copyPixels(Main.textures.magnetup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 40:
					data.copyPixels(Main.textures.speedup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 41:
					data.copyPixels(Main.textures.hallucinate, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 42:
					data.copyPixels(Main.textures.gravitychanger, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 43:
					data.copyPixels(Main.textures.gravitychangerright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 44:
					data.copyPixels(Main.textures.gravitychangerleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 45:
					data.copyPixels(Main.textures.gravitychangerup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 46:
					data.copyPixels(Main.textures.fallspikeup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 47:
					data.copyPixels(Main.textures.fallspikedown, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 48:
					data.copyPixels(Main.textures.fallspikeright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 49:
					data.copyPixels(Main.textures.fallspikeleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 50:
					data.copyPixels(Main.textures.sunspike, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 51:
					data.copyPixels(Main.textures.middarkgroundtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 52:
					data.copyPixels(Main.textures.darkgroundtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 53:
					data.copyPixels(Main.textures.pinkflowers[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 54:
					data.copyPixels(Main.textures.pinkflowersleft[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 55:
					data.copyPixels(Main.textures.pinkflowersright[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 56:
					data.copyPixels(Main.textures.pinkflowersup[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 57:
					data.copyPixels(Main.textures.grasstileup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 58:
					data.copyPixels(Main.textures.finishtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					if (!icon && overridespecials && grid[int(y / 20) * gridwidth + int(x / 20)] != 58) {
						++details.finishtiles;
					}
					break;
				case 59:
					data.copyPixels(Main.textures.glass, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 60:
					data.copyPixels(Main.textures.bombflowers[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 61:
					data.copyPixels(Main.textures.bombflowersleft[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 62:
					data.copyPixels(Main.textures.bombflowersright[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 63:
					data.copyPixels(Main.textures.bombflowersup[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 64:
					data.copyPixels(Main.textures.brick, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 65:
					data.copyPixels(Main.textures.checkpointoff, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 66:
					data.copyPixels(Main.textures.lasermachine, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 67:
					data.copyPixels(Main.textures.lasermachineleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 68:
					data.copyPixels(Main.textures.lasermachineright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 69:
					data.copyPixels(Main.textures.lasermachineup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 70:
					data.copyPixels(Main.textures.laser, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 71:
					data.copyPixels(Main.textures.laserup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 72:
					data.copyPixels(Main.textures.grasstileleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 73:
					data.copyPixels(Main.textures.grasstileright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 74:
					data.copyPixels(Main.textures.grasstiledown, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 75:
					data.copyPixels(Main.textures.floatingmine, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 76:
					data.copyPixels(Main.textures.water, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 77:
					data.copyPixels(Main.textures.icetileup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 78:
					data.copyPixels(Main.textures.icetileright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 79:
					data.copyPixels(Main.textures.icetiledown, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 80:
					data.copyPixels(Main.textures.icetileleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 81:
					data.copyPixels(Main.textures.snowblock, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 82:
					data.copyPixels(Main.textures.coral, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 83:
					data.copyPixels(Main.textures.coralleft, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 84:
					data.copyPixels(Main.textures.coralright, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 85:
					data.copyPixels(Main.textures.coralup, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 86:
					data.copyPixels(Main.textures.spheres[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 87:
					data.copyPixels(Main.textures.redgroundtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 88:
					data.copyPixels(Main.textures.greengroundtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 89:
					data.copyPixels(Main.textures.bluegroundtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 90:
					data.copyPixels(Main.textures.blackgroundtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 91:
					data.copyPixels(Main.textures.yellowgroundtile, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 92:
					data.copyPixels(Main.textures.lava, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 93:
					data.copyPixels(Main.textures.lavasuit, new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
				case 999:
					data.copyPixels(Main.textures.spheres[0], new Rectangle(0, 0, w, h), new Point(x, y), null, null, true);
					break;
			}
		}
		
		public function getbgtilefrom(type:int):BitmapData {
			switch (type) {
				case 0:
					return Main.textures.gridtile;
					break;
				case 51:
					return Main.textures.middarkgroundtile;
					break;
				case 52:
					return Main.textures.darkgroundtile;
					break;
				case 76:
					return Main.textures.water;
					break;
				case 92:
					return Main.textures.lava;
					break;
			}
			return null;
		}
		
		public function typeisbgtile(type:int):Boolean {
			if (type == 0 || type == 51 || type == 52 || type == 76 || type == 92) { return true;
			}else { return false; }
		}
		
		public function placetile():void {
			//calculates which tile we clicked on by getting the coordinates and 
			//subtracting it by the map's position and dividing it by our tiles size
			var pointx:int = (Main.universe.mouseX - map.x) / tilewidth;
			var pointy:int = (Main.universe.mouseY - map.y) / tileheight;
			
			if (invalidtile) { invalidtilemessage(); return; }
			
			replaceTile(pointx, pointy);
			
			//Main.mapeditor.brush algorithm
			if (Main.mapeditor.brushsize > 1) {
				for (var c:int = 0; c < Main.mapeditor.brushsize; ++c) {
					var lastx:int = -1 - (c / 2);
					var lasty:int = -1 - (c / 2);
					for (var u:int = 0; u < Main.mapeditor.sides.length; u += 2) {
						var posx:int = lastx;
						var posy:int = lasty;
						for (var p:int = 0; p < 2 + c; ++p) {
							replaceTile(pointx + posx, pointy + posy);
							posx += Main.mapeditor.sides[u];
							posy += Main.mapeditor.sides[u + 1];
							lastx = posx;
							lasty = posy;
						}
					}
				}
			}
		}
		
		public function replaceTile(pointx:int, pointy:int, type:int = -1):void {
			//gets type
			if (type == -1) {
				type = currentTile;
			}
			
			//copy different pixels according to the current tile type
			if (pointx >= 0 && pointx <= gridwidth - 1 && pointy >= 0 && pointy <= gridheight - 1) {
				drawDataByType(type, pointx, pointy, mapdata);
				grid[pointy * gridwidth + pointx] = type;
				if (typeisbgtile(type)) { backgroundtiles[pointy * gridwidth + pointx] = type; }
			}
		}
		
		public function update():void {
			//blueprint.update();
			colourchanger.update();
			
			//move map around when keys are pressed
			if (!Main.info.console.visible) {
				var tempx:int = map.x; var tempy:int = map.y;
				if (Main.mapeditor.leftkeydown || mapresizer.resizing && Main.universe.mouseX <= 40) {
					if (map.x < mapresizer.mapxoffset)
					map.x += 20; //move right on x axis by 20 pixels
					if (mapresizer.mapresizer) { map.x += 20; mapresizer.updatefilleffect(); }
				}
				if (Main.mapeditor.rightkeydown || mapresizer.resizing && Main.universe.mouseX >= Main.universe.stageWidth - 40) {
					if (map.x > -map.width + (Main.universe.stageWidth - mapresizer.mapxoffset))
					map.x -= 20; //move left on x axis by 20 pixels
					if (mapresizer.mapresizer) { map.x -= 20; mapresizer.updatefilleffect(); }
				}
				if (Main.mapeditor.upkeydown || mapresizer.resizing && Main.universe.mouseY <= 40) {
					if (map.y < mapresizer.mapyoffset)
					map.y += 20; //move down on y axis by 20 pixels
					if (mapresizer.mapresizer) { map.y += 20; mapresizer.updatefilleffect(); }
				}
				if (Main.mapeditor.downkeydown || mapresizer.resizing && Main.universe.mouseY >= Main.universe.stageHeight - 40) {
					if (map.y > -map.height + (Main.universe.stageHeight - mapresizer.mapyoffset))
					map.y -= 20; //move up on y axis by 20 pixels
					if (mapresizer.mapresizer) { map.y -= 20; mapresizer.updatefilleffect(); }
				}
			}
			
			tileplacer.x = (int((Main.universe.mouseX) / 20) * 20) - (tileplacer.width / 2) + 20 - (Main.mapeditor.brushsize % 2 * 10);
			tileplacer.y = (int((Main.universe.mouseY) / 20) * 20) - (tileplacer.height / 2) + 20 - (Main.mapeditor.brushsize % 2 * 10);
			
			if (tileplacer.x != lasttilepos.x || tileplacer.y != lasttilepos.y) {
				if (Main.mapeditor.ctrlKeyDown) { mapresizer.updatefilleffect(); }
				
				var gridx:int = (tileplacer.x - map.x) / 20;
				var gridy:int = (tileplacer.y - map.y) / 20;
				if (currentTile == 50) {
					if (solid(grid[gridy * gridwidth + (gridx + 1)]) || solid(grid[gridy * gridwidth + (gridx - 1)]) ||
						solid(grid[(gridy + 1) * gridwidth + gridx]) || solid(grid[(gridy - 1) * gridwidth + gridx])) {
						invalidtile = false;
					}else {
						invalidtile = true;
					}
				}
				
				if (invalidtile) { tileplacer.transform.colorTransform = redtransform;
				}else { tileplacer.transform.colorTransform = greentransform; }
			}
			lasttilepos.x = tileplacer.x; lasttilepos.y = tileplacer.y;
		}
		
		public function clearMap():void {
			backgroundtiles.length = 0;
			backgroundtiles = defaultbackgroundgrid.concat();
			
			var type:int = 0;
			for (var x:int = 0; x < gridwidth; ++x) {
				for (var y:int = 0; y < gridheight; ++y) {
					if (x == 0 || x == gridwidth - 1 || y == 0 || y == gridheight - 1) { type = 1; } else { type = 0; }
					grid[y * gridwidth + x] = type;
					drawDataByType(type, x, y, mapdata, true, false, 20, 20, false);
				}
			}
			details.finishtiles = 0;
			if (charroom == Main.mapeditor.roommanager.currentroom) {
				currentcharpos.x = -1; currentcharpos.y = -1;
				lastcharpos.x = -1; lastcharpos.y = -1;
			}
		}
		
		public function refreshMap():void {
			for (var x:int = 0; x < gridwidth; ++x) {
				for (var y:int = 0; y < gridheight; ++y) {
					drawDataByType(grid[y * gridwidth + x], x, y, mapdata, true, false, 20, 20, false);
				}
			}
		}
		
		private function invalidtilemessage():void {
			if (currentTile == 50) {
				Main.messagebox.show("Sun spikes must be placed next to a solid block");
			}
		}
		
		private function solid(type:int):Boolean {
			for (var n:int = 0; n < solidblocks.length; ++n) {
				if (type == solidblocks[n]) { return true; }
			}
			return false;
		}
	}
}