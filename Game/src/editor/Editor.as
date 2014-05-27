package editor {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import tools.images.ColourChanger;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Editor extends Sprite {
		
		//these are comments - they aren't compiled in the program but help us remember what we have written
		
		public var grid:Array = []; //our grid array that contains integer's
		public var gridwidth:int = 40; //the width of our grid
		public var gridheight:int = 25; //the height of our grid
		private var map:Bitmap; //our display object of the map
		private var mapdata:BitmapData; //our data of the map in pixels
		private var currentTile:int = 1; //the current block type to place on the editor
		private var mouseIsDown:Boolean = false; //sets to true when the left mouse button is down
		private var tilewidth:int = 20;  //width of tile
		private var tileheight:int = 20; //height of tile
		private var colourchanger:ColourChanger;
		public var created:Boolean = false;
		
		//movement variables
		private var rightkeydown:Boolean = false; //true when right key is down
		private var leftkeydown:Boolean = false; //true when left key is down
		private var upkeydown:Boolean = false; //true when up key is down
		private var downkeydown:Boolean = false; //true when down key is down
		private var ctrlKeyDown:Boolean = false; //true when ctrl key is down
		
		//brush variables
		private var brushsize:int = 1;
		private const sides:Array = [1, 0, 0, 1, -1, 0, 0, -1];
		private var brushtypes:Array = [0, 1, 3, 4, 2, 5, 6, 7];
		
		//ui variables
		private var mapDataField:TextField = new TextField();
		private var loading:Boolean = false;
		private var saving:Boolean = false;
		
		//event variables
		private var writingevents:Boolean = false;
		private var events:Array = [];
		private var currentPage:int = 0;
		private const MAXPAGES:int = 10;
		private const DEFAULTTEXT:String = "Write your events here";
		
		//all tile variables
		private var alltilescontainer:Bitmap;
		private var alltiles:BitmapData;
		private const TILECOUNT:int = 89;
		private const ALLTILESWIDTH:int = 35;
		
		public function create():void {
			//creates the map display object
			map = new Bitmap();
			//create our map data of the grid width and height multiplied by 20 to get the resulting pixel data
			mapdata = new BitmapData(gridwidth * tilewidth, gridheight * tileheight, true, 0);
			
			for (var x:int = 0; x < gridwidth; ++x) {
				for (var y:int = 0; y < gridheight; ++y) {
					mapdata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
					grid.push(0);
				}
			}
			
			map.bitmapData = mapdata; //apply data to graphical display object
			Main.screen.addChild(map); //add the map to the display stage
			colourchanger = new ColourChanger(map, .001, 1.4);
			
			//draw all tiles
			alltiles = new BitmapData(700, 500, false, 0x202020);
			var rowx:int = 0;
			var rowy:int = 0;
			for (var l:int = 0; l < TILECOUNT + 1; ++l) {
				drawDataByType(l, rowx, rowy, alltiles);
				++rowx;
				if (rowx >= ALLTILESWIDTH) {
					rowx = 0;
					++rowy;
				}
			}
			alltilescontainer = new Bitmap(alltiles);
			alltilescontainer.x = 50;
			alltilescontainer.y = 50;
			alltilescontainer.visible = false;
			Main.screen.addChild(alltilescontainer);
			alltilescontainer.alpha = .8;
			
			//load event pages
			for (var n:int = 0; n < 10; ++n) {
				events[n] = "Page " + (n + 1) + "\n" + DEFAULTTEXT;
			}
			
			created = true;
			
			//add events
			addEventListener(Event.ENTER_FRAME, loop); //loop event
			Main.universe.addEventListener(KeyboardEvent.KEY_DOWN, keyDown); //dispatches when a key is pressed down
			Main.universe.addEventListener(KeyboardEvent.KEY_UP, keyUp); //dispatches when a key is up
			Main.universe.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown); //dispatches when the left mouse is down
			Main.universe.addEventListener(MouseEvent.MOUSE_UP, mouseUp); //dispatches when the left mouse is up
		}
		
		//gets the bitmapdata to draw onto the map by it's tile type
		private function drawDataByType(type:int, x:int, y:int, data:BitmapData):void {
			x = x * tilewidth;
			y = y * tileheight;
			data.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
			
			switch (type) {
				case 1:
					data.copyPixels(Main.textures.groundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
					break;
				case 2:
					data.copyPixels(Main.textures.spikeup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 3:
					data.copyPixels(Main.textures.darkgroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 4:
					data.copyPixels(Main.textures.middarkgroundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 5:
					data.copyPixels(Main.textures.spikedown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 6:
					data.copyPixels(Main.textures.spikeright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 7:
					data.copyPixels(Main.textures.spikeleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 8:
					data.copyPixels(Main.textures.mineblinkoff, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 9:
					data.copyPixels(Main.textures.mineblinkoffup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 10:
					data.copyPixels(Main.textures.lasermachine, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 11:
					data.copyPixels(Main.textures.lasermachineright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 12:
					data.copyPixels(Main.textures.lasermachineleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 13:
					data.copyPixels(Main.textures.lasermachineup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 14:
					data.copyPixels(Main.textures.laser, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 15:
					data.copyPixels(Main.textures.laserup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 16:
					data.copyPixels(Main.textures.button, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 17:
					data.copyPixels(Main.textures.buttonright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 18:
					data.copyPixels(Main.textures.buttonleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 19:
					data.copyPixels(Main.textures.buttonup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 20:
					data.copyPixels(Main.textures.lasermachineoff, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 21:
					data.copyPixels(Main.textures.lasermachineoffright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 22:
					data.copyPixels(Main.textures.lasermachineoffleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 23:
					data.copyPixels(Main.textures.lasermachineoffup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 24:
					data.copyPixels(Main.textures.gravityblock, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 25:
					data.copyPixels(Main.textures.gravityblockright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 26:
					data.copyPixels(Main.textures.gravityblockleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 27:
					data.copyPixels(Main.textures.gravityblockup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 28:
					data.copyPixels(Main.textures.buttonpress, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 29:
					data.copyPixels(Main.textures.buttonpressright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 30:
					data.copyPixels(Main.textures.buttonpressleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 31:
					data.copyPixels(Main.textures.buttonpressup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 32:
					data.copyPixels(Main.textures.glass, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 33:
					data.copyPixels(Main.textures.dirtblocks[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 34:
					data.copyPixels(Main.textures.screen, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 35:
					data.copyPixels(Main.textures.crate, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 36:
					data.copyPixels(Main.textures.stickygroundtileleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 37:
					data.copyPixels(Main.textures.stickygroundtileright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 38:
					data.copyPixels(Main.textures.stickygroundtiledown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 39:
					data.copyPixels(Main.textures.stickygroundtileup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 40:
					data.copyPixels(Main.textures.gravitychanger, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 41:
					data.copyPixels(Main.textures.gravitychangerright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 42:
					data.copyPixels(Main.textures.gravitychangerleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 43:
					data.copyPixels(Main.textures.gravitychangerup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 44:
					data.copyPixels(Main.textures.jetpack, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 45:
					data.copyPixels(Main.textures.mineblinkoffright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 46:
					data.copyPixels(Main.textures.mineblinkoffleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 47:
					data.copyPixels(Main.textures.spikecornerup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 48:
					data.copyPixels(Main.textures.spikecornerright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 49:
					data.copyPixels(Main.textures.spikecornerleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 50:
					data.copyPixels(Main.textures.spikecornerdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 51:
					data.copyPixels(Main.textures.boostup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 52:
					data.copyPixels(Main.textures.boostright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 53:
					data.copyPixels(Main.textures.boostleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 54:
					data.copyPixels(Main.textures.boostdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 55:
					data.copyPixels(Main.textures.groundtilecornerupleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 56:
					data.copyPixels(Main.textures.groundtilecornerupright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 57:
					data.copyPixels(Main.textures.groundtilecornerdownleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 58:
					data.copyPixels(Main.textures.groundtilecornerdownright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 59:
					data.copyPixels(Main.textures.springdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 60:
					data.copyPixels(Main.textures.springright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 61:
					data.copyPixels(Main.textures.springleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 62:
					data.copyPixels(Main.textures.springup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 63:
					data.copyPixels(Main.textures.teleporterdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 64:
					data.copyPixels(Main.textures.teleporterright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 65:
					data.copyPixels(Main.textures.teleporterleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 66:
					data.copyPixels(Main.textures.teleporterup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 67:
					data.copyPixels(Main.textures.shieldshooter[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 68:
					data.copyPixels(Main.textures.shieldshooterright[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 69:
					data.copyPixels(Main.textures.shieldshooterleft[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 70:
					data.copyPixels(Main.textures.shieldshooterup[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 71:
					data.copyPixels(Main.textures.homingshooter[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 72:
					data.copyPixels(Main.textures.homingshooterright[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 73:
					data.copyPixels(Main.textures.homingshooterleft[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 74:
					data.copyPixels(Main.textures.homingshooterup[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 75:
					data.copyPixels(Main.textures.magnetdown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 76:
					data.copyPixels(Main.textures.magnetright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 77:
					data.copyPixels(Main.textures.magnetleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 78:
					data.copyPixels(Main.textures.magnetup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 79:
					data.copyPixels(Main.textures.checkpointoff, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 80:
					data.copyPixels(Main.textures.checkpointon, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 81:
					data.copyPixels(Main.textures.spheres[0], new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 82:
					data.copyPixels(Main.textures.speedup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 83:
					data.copyPixels(Main.textures.hallucinate, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 84:
					data.copyPixels(Main.textures.fallspikeup, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 85:
					data.copyPixels(Main.textures.fallspikedown, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 86:
					data.copyPixels(Main.textures.fallspikeright, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 87:
					data.copyPixels(Main.textures.fallspikeleft, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 88:
					data.copyPixels(Main.textures.sunspike, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y), null, null, true);
					break;
				case 89:
					data.copyPixels(Main.textures.groundtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
					break;
				case 90:
					data.copyPixels(Main.textures.jailcell, new Rectangle(0, 0, tilewidth, tileheight), new Point(x, y));
					break;
			}
		}
		
		private function keyDown(ev:KeyboardEvent):void {
			//movement keys turn to true if their key is down
			var key:int = ev.keyCode;
			if (key == 37 || key == 65) {
				leftkeydown = true;
			}
			if (key == 38 || key == 87) {
				upkeydown = true;
			}
			if (key == 39 || key == 68) {
				rightkeydown = true;
			}
			if (key == 40 || key == 83) {
				downkeydown = true;
			}
			
			if (key == 13) {
				if (loading) {
					createMapByXML(mapDataField.text);
					removeMapDataField();
				}
			}
			
			//keyboard number inputs
			if (!writingevents && key >= 49 && key <= 49 + (brushtypes.length)) {
				currentTile = brushtypes[key - 49];
			}
			
			if (key == 17) { //ctrl key down
				ctrlKeyDown = true;
			}
			
			if (key == 189) { //negative input
				--brushsize;
				if (brushsize < 1) {
					brushsize = 1;
				}
			}
			
			if (key == 187) { //positive input
				++brushsize;
				if (brushsize > 8) {
					brushsize = 8;
				}
			}
			
			if (key == 9) {
				toggleAllTiles();
			}
		}
		
		private function keyUp(ev:KeyboardEvent):void {
			//movement variables turn to false if their key is up
			var key:int = ev.keyCode;
			if (key == 37 || key == 65) {
				leftkeydown = false;
			}
			if (key == 38 || key == 87) {
				upkeydown = false;
			}
			if (key == 39 || key == 68) {
				rightkeydown = false;
			}
			if (key == 40 || key == 83) {
				downkeydown = false;
			}
			
			if (key == 17) { //ctrl key up
				ctrlKeyDown = false;
			}
			
			//keyboard number inputs
			if (ctrlKeyDown && writingevents && key >= 49 && key <= 57 || ctrlKeyDown && writingevents && key == 48) {
				removeMapDataField();
				if (key == 48) {
					currentPage = 9;
				}else {
					currentPage = key - 49;
				}
				showEventWriter();
			}
			
			//ctrl+s key to save map
			if (ctrlKeyDown && key == 83) {
				saveMap();
			}
			//ctrl+l key to load map
			if (ctrlKeyDown && key == 76) {
				loadMap();
			}
			//ctrl+t key to test map
			if (ctrlKeyDown && key == 86) {
				testMap(saveXMLMap());
			}
			//c to show event writer
			if (key == 67) {
				showEventWriter();
			}
			
			//open/hide console
			if (key == 192) {
				Main.info.toggleConsole();
			}
			//console receives input
			if (key == 13) {
				Main.info.log();
			}
		}
		
		public function saveMap():void {
			if (Main.info.console.visible || saving || loading || writingevents) {
				return;
			}
			Main.screen.addChild(mapDataField);
			mapDataField.width = 500;
			mapDataField.height = 400;
			mapDataField.x = 150;
			mapDataField.y = 100;
			mapDataField.border = true;
			mapDataField.borderColor = 0x000000;
			mapDataField.background = true;
			mapDataField.backgroundColor = 0xFFFFFF;
			mapDataField.type = TextFieldType.INPUT;
			mapDataField.multiline = true;
			mapDataField.wordWrap = true;
			Main.universe.focus = mapDataField;
			saving = true;
			
			mapDataField.text = saveXMLMap();
		}
		
		private function saveXMLMap():String {
			var data:String = "<map>\n<level width = '" + gridwidth + "' height = '" + gridheight + "' tiles = '";
			for (var y:int = 0; y < gridheight; ++y) {
				var column:String = "";
				for (var x:int = 0; x < gridwidth; ++x) {
					column += grid[y * gridwidth + x] + ",";
				}
				data += column + "\n";
			}
			data += "'></level>\n<events>";
			for (var n:int = 0; n < events.length; ++n) {
				if (events[n].indexOf(DEFAULTTEXT) == -1 && events[n] != "") {
					data += "\n<script id = '" + (n + 1) + "' data = '" + events[n] + "'></script>";
				}
			}
			data += "\n</events>\n</map>";
			return data;
		}
		
		private function testMap(xml:String):void {
			//foreach in screen
			//for (var child:DisplayObject in Main.screen) {
				
			//}
		}
		
		public function loadMap():void {
			if (Main.info.console.visible || loading || writingevents || saving) {
				return;
			}
			Main.screen.addChild(mapDataField);
			mapDataField.width = 500;
			mapDataField.height = 400;
			mapDataField.x = 150;
			mapDataField.y = 100;
			mapDataField.border = true;
			mapDataField.borderColor = 0x000000;
			mapDataField.background = true;
			mapDataField.backgroundColor = 0xFFFFFF;
			mapDataField.type = TextFieldType.INPUT;
			mapDataField.multiline = true;
			mapDataField.wordWrap = true;
			mapDataField.text = "Please enter an xml map here";
			Main.universe.focus = mapDataField;
			loading = true;
		}
		
		private function removeMapDataField():void {
			if (writingevents) {
				events[currentPage] = mapDataField.text;
			}
			Main.screen.removeChild(mapDataField);
			loading = false;
			saving = false;
			writingevents = false;
			mapDataField.text = "";
			Main.universe.focus = null;
			ctrlKeyDown = false;
		}
		
		private function loop(event:Event):void {
			if (saving || loading || writingevents) {
				return;
			}
			
			colourchanger.update();
			
			//move map around when keys are pressed
			if (!ctrlKeyDown && !Main.info.console.visible) {
				if (leftkeydown) {
					map.x += 20; //move right on x axis by 20 pixels
				}
				if (rightkeydown) {
					map.x -= 20; //move left on x axis by 20 pixels
				}
				if (upkeydown) {
					map.y += 20; //move down on y axis by 20 pixels
				}
				if (downkeydown) {
					map.y -= 20; //move up on y axis by 20 pixels
				}
			}
			
			if (mouseIsDown) {
				//calculates which tile we clicked on by getting the coordinates and 
				//subtracting it by the map's position and dividing it by our tiles size
				var pointx:int = (Main.screen.mouseX - map.x) / tilewidth;
				var pointy:int = (Main.screen.mouseY - map.y) / tileheight;
				
				if (alltilescontainer.visible) {
					getAllTile();
					return;
				}
				
				replaceTile(pointx, pointy);
				
				//brush algorithm
				if (brushsize > 1) {
					for (var c:int = 0; c < brushsize; ++c) {
						var lastx:int = -1 - (c / 2);
						var lasty:int = -1 - (c / 2);
						for (var u:int = 0; u < sides.length; u += 2) {
							var posx:int = lastx;
							var posy:int = lasty;
							for (var p:int = 0; p < 2 + c; ++p) {
								replaceTile(pointx + posx, pointy + posy);
								posx += sides[u];
								posy += sides[u + 1];
								lastx = posx;
								lasty = posy;
							}
						}
					}
				}
			}
		}
		
		private function replaceTile(pointx:int, pointy:int, type:int = -1):void {
			//gets type
			if (type == -1) {
				type = currentTile;
			}
			
			//copy different pixels according to the current tile type
			drawDataByType(type, pointx, pointy, mapdata);
			grid[pointy * gridwidth + pointx] = type;
		}
		
		private function mouseDown(event:MouseEvent):void {
			mouseIsDown = true;
		}
		
		private function mouseUp(event:MouseEvent):void {
			mouseIsDown = false;
			if (loading || saving || writingevents) {
				if (!mapDataField.hitTestPoint(event.stageX, event.stageY)) {
					removeMapDataField();
				}
			}
		}
		
		private function createMapByXML(xmldata:String):void {
			Main.screen.removeChild(map);
			map.bitmapData.dispose();
			grid.length = 0;
			
			var xml:XML = new XML(xmldata);
			gridwidth = xml.level.@width;
			gridheight = xml.level.@height;
			var tiles:String = xml.level.@tiles;
			
			//load events
			var count:int = 0;
			events.length = 0;
			for (var c:int = 0; c < 10; ++c) {
				var data:String = xml.events.script.(@id == (c + 1).toString()).@data;
				if (data != "") {
					events.push(data);
				}else {
					events.push("Page " + (c + 1) + "\n" + DEFAULTTEXT);
				}
			}
			
			tiles = tiles.replace(/\r/g, "");
			
			grid = tiles.split(",");
			
			map = new Bitmap();
			mapdata = new BitmapData(gridwidth * tilewidth, gridheight * tileheight, true, 0);
			map.bitmapData = mapdata;
			Main.screen.addChild(map);
			
			for (var y:int = 0; y < gridheight; ++y) {
				for (var x:int = 0; x < gridwidth; ++x) {
					var type:int = grid[y * gridwidth + x];
					drawDataByType(type, x, y, mapdata);
				}
			}
			
			colourchanger.container = map;
			
			Main.info.trace("Map loaded");
			
			Main.screen.setChildIndex(alltilescontainer, Main.screen.numChildren - 1);
		}
		
		public function redrawMap():void {
			if (Main.info.console.visible) {
				return;
			}
			Main.screen.removeChild(map);
			map.bitmapData.dispose();
			grid.length = 0;
			
			map = new Bitmap();
			mapdata = new BitmapData(gridwidth * tilewidth, gridheight * tileheight, true, 0);
			
			for (var x:int = 0; x < gridwidth; ++x) {
				for (var y:int = 0; y < gridheight; ++y) {
					mapdata.copyPixels(Main.textures.gridtile, new Rectangle(0, 0, tilewidth, tileheight), new Point(x * tilewidth, y * tileheight));
					grid.push(0);
				}
			}
			
			map.bitmapData = mapdata; //apply data to graphical display object
			Main.screen.addChild(map); //add the map to the display stage
			
			colourchanger.container = map;
			
			Main.screen.setChildIndex(alltilescontainer, Main.screen.numChildren - 1);
		}
		
		public function resizeMap(w:int, h:int):void {
			var x:int = 0; var y:int = 0;
			Main.screen.removeChild(map);
			map.bitmapData.dispose();
			map = new Bitmap();
			mapdata = new BitmapData(w * tilewidth, h * tileheight, true, 0);
			var oldgrid:Array = grid.concat();
			grid.length = 0;
			
			//display map
			for (x = 0; x < w; ++x) {
				for (y = 0; y < h; ++y) {
					var type:int;
					if (x >= gridwidth) {
						type = 0;
					}else {
						type = oldgrid[y * gridwidth + x];
					}
					drawDataByType(type, x, y, mapdata);
					grid[y * w + x] = type;
				}
			}
			
			gridwidth = w; gridheight = h;
			
			map.bitmapData = mapdata; //apply data to graphical display object
			Main.screen.addChild(map); //add the map to the display stage
			
			colourchanger.container = map;
			
			Main.screen.setChildIndex(alltilescontainer, Main.screen.numChildren - 1);
		}
		
		public function negResizeX(w:int):void {
			var rowx:int = 0;
			if (w < 0) {
				negResizeXRemove(Math.abs(w));
				return;
			}
			
			for (y = 0; y < w; ++y) {
				for (x = 0; x < gridheight; ++x) {
					grid.splice(rowx * gridwidth + x, 0, 0);
					++rowx;
				}
				rowx = -1;
				++gridwidth;
			}
		}
		
		public function negResizeXRemove(w:int):void {
			var newgrid:Array = [];
			for (y = 0; y < gridheight; ++y) {
				for (x = w; x < gridwidth; ++x) {
					newgrid.push(grid[y * gridwidth + x]);
				}
			}
			gridwidth -= w;
			grid = newgrid;
		}
		
		public function negResizeY(h:int):void {
			var rowy:int = 0;
			if (h < 0) {
				negResizeYRemove(Math.abs(h));
				return;
			}
			for (x = 0; x < h; ++x) {
				for (y = 0; y < gridwidth; ++y) {
					grid.splice(x * gridwidth + y, 0, 0);
				}
				++gridheight;
			}
		}
		
		public function negResizeYRemove(h:int):void {
			var newgrid:Array = [];
			for (x = h; x < gridheight; ++x) {
				for (y = 0; y < gridwidth; ++y) {
					newgrid.push(grid[x * gridwidth + y]);
				}
			}
			gridheight -= h;
			grid = newgrid;
		}
		
		public function flipx():void {
			var newgrid:Array = [];
			for (var y:int = 0; y < gridheight; ++y) {
				var temp:Array = [];
				for (var x:int = 0; x < gridwidth; ++x) {
					temp[x] = grid[y * gridwidth + x];
				}
				for (var i:int = gridwidth - 1; i > -1; --i) {
					newgrid.push(temp[i]);
				}
			}
			grid = newgrid;
			refreshMap();
			Main.info.toggleConsole();
		}
		
		public function refreshMap():void {
			for (var x:int = 0; x < gridwidth; ++x) {
				for (var y:int = 0; y < gridheight; ++y) {
					drawDataByType(grid[y * gridwidth + x], x, y, mapdata);
				}
			}
		}
		
		public function getPosition(event:ContextMenuEvent):void {
			var pointx:int = (Main.screen.mouseX - map.x) / tilewidth;
			var pointy:int = (Main.screen.mouseY - map.y) / tileheight;
			if (pointx >= 0 && pointx < gridwidth && pointy >= 0 && pointy < gridheight) {
				Main.info.trace("Tile position: " + pointx + ", " + pointy + " coordinates: " + pointx * 20 + ", " + pointy * 20);
			}
		}
		
		public function showEventWriter():void {
			if (writingevents || saving || loading) {
				return;
			}
			Main.screen.addChild(mapDataField);
			mapDataField.width = 500;
			mapDataField.height = 400;
			mapDataField.x = 150;
			mapDataField.y = 100;
			mapDataField.border = true;
			mapDataField.borderColor = 0x000000;
			mapDataField.background = true;
			mapDataField.backgroundColor = 0xFFFFFF;
			mapDataField.type = TextFieldType.INPUT;
			mapDataField.multiline = true;
			mapDataField.wordWrap = true;
			mapDataField.text = events[currentPage];
			Main.universe.focus = mapDataField;
			writingevents = true;
		}
		
		private function toggleAllTiles():void {
			if (alltilescontainer.visible) {
				alltilescontainer.visible = false;
			}else {
				alltilescontainer.visible = true;
			}
		}
		
		private function getAllTile():void {
			var pointx:int = (Main.screen.mouseX - 50) / tilewidth;
			var pointy:int = (Main.screen.mouseY - 50) / tileheight;
			currentTile = pointy * ALLTILESWIDTH + pointx;
			toggleAllTiles();
			mouseIsDown = false;
		}
	}
}