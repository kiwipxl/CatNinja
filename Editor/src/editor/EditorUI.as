package editor {
	
	import editor.components.SavedGameList;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.StageDisplayState;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import maps.MapDetails;
	import ui.Button;
	import editor.components.ItemBox;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.geom.ColorTransform;
	import flash.text.TextFormat;
	import editor.components.ToolTip;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class EditorUI {
		
		//editorui variables
		public var settingswindow:SettingsWindow = new SettingsWindow();
		public var savedgamelist:SavedGameList = new SavedGameList();
		public var tooltip:ToolTip = new ToolTip();
		public var tiledatawindow:Sprite = new Sprite();
		public var windowscroller:Bitmap;
		public var windowscrollertop:Bitmap;
		public var tilewindowcontainer:Sprite = new Sprite();
		public var tilemask:Sprite = new Sprite();
		public var currenttilebox:Bitmap;
		public var currenttiledata:BitmapData;
		
		//tile info variables
		public var pausewindow:Shape = new Shape();
		public var cursor:Bitmap;
		private var helpmessage:String = "<font color='#FE98BE' size='15'>Help Manual</font>\n" +
									"The <font color='#DBAA15'>Empty tiles menu</font><font color='#FEE0EE'> contains 'erasing' blocks</font>\n" +
									"<font color='#FEE0EE'>Pressing </font><font color='#DBAA15'>R </font>" +
									"<font color='#FEE0EE'>rotates a block</font>\n" +
									"<font color='#DBAA15' size='20'>+</font><font color='#FEE0EE'> = Make paint brush larger</font>\n" +
									"<font color='#DBAA15' size='20'>-</font><font color='#FEE0EE'> = Make paint brush smaller</font>\n" +
									"<font color='#FEE0EE'>Holding </font><font color='#DBAA15'>CTRL</font>" +
									"<font color='#FEE0EE'>on the borders of the room allows you to resize the room</font>\n" +
									"<font color='#FEE0EE'>Holding </font><font color='#DBAA15'>SHIFT </font>" +
									"<font color='#FEE0EE'>activates the empty block</font>\n";
		public const alltileslist:Array = [0, -1, 1, 51, 52, 2, 3, 4, 5, 6, 7, 14, 15, 8, 9, 10, 11, 12, 13, 16, 17, 18, 19, 20, 21, 22, 23,
														24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46,
														47, 48, 49, 50, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71,
														72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 
														95];
		public const emptytilesdata:Array = [1, 0, 3, 4, 77, 93];
		public const blocktilesdata:Array = [2, 59, 14, 60, 78, 82, 58, 13, 65, 19, 27, 45, 88, 89, 90, 91, 92];
		public const environmenttilesdata:Array = [5, 66, 67, 71, 9, 76, 87, 23, 31, 35, 39, 49, 53];
		public const upgradetilesdata:Array = [18, 43, 44, 94];
		public const misctilesdata:Array = [54, 61, 83];
		public var currentwindowindex:int = -1;
		private var scrolling:Boolean = false;
		private var currentwindowdata:Array;
		private const destwindowypositions:Array = [25, 25, 25, 25, 25];
		private var destwindowy:int = 25;
		public var tilewindowopened:Boolean = false;
		public var tilewindowblocks:Array = [];
		public const rotatedirections:Array = [6, 15, 7, 14, 20, 21, 23, 22, 36, 37, 39, 38, 46, 48, 47, 49, 9, 12, 10, 11, 42, 43, 45, 44, 24, 25, 27, 26,
															53, 54, 56, 55, 60, 61, 63, 62, 57, 73, 74, 72, 66, 67, 69, 68, 16, 17, 19, 18, 77, 78, 79, 80, 82, 84, 85, 83,
															78, 79];
		public const rotatabletiles:Array = [2, 6, 9, 16, 20, 24, 28, 32, 36, 42, 46, 53, 57, 60, 66, 70, 74, 77, 78, 82];
		
		//ui button variables
		public var loadbutton:Button;
		public var savebutton:Button;
		public var testbutton:Button;
		public var settingsbutton:Button;
		public var helpbutton:Button;
		public var clearbutton:Button;
		public var roombutton:Button;
		public var sizeaddbutton:Button;
		public var sizesubtractbutton:Button;
		public var emptytilesbutton:Button;
		public var blocktilesbutton:Button;
		public var environmenttilesbutton:Button;
		public var upgradetilesbutton:Button;
		public var misctilesbutton:Button;
		
		//room ui variables
		private var roomformat:TextFormat;
		public var currentroomtext:TextField = new TextField();
		
		public function create():void {
			cursor = new Bitmap(Main.textures.resizearrowhorizontal);
			Main.universe.addChild(cursor);
			cursor.visible = false;
			
			pausewindow.graphics.clear();
			pausewindow.graphics.beginFill(0x000000, .4);
			pausewindow.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			Main.universe.addChild(pausewindow);
			pausewindow.visible = false;
			
			addnavbuttons();
			
			roomformat = new TextFormat();
			roomformat.size = 20;
			roomformat.align = "right";
			roomformat.font = "square";
			currentroomtext.embedFonts = true;
			currentroomtext.defaultTextFormat = roomformat;
			currentroomtext.width = 250;
			currentroomtext.height = 40;
			currentroomtext.multiline = false;
			currentroomtext.wordWrap = false;
			currentroomtext.selectable = false;
			currentroomtext.text = "Current room: Room 1";
			currentroomtext.textColor = 0xFFFFFF;
			currentroomtext.filters = [new GlowFilter(0x000000, 1, 2, 2, 2, 1, false, false), new DropShadowFilter(2, 45, 0x000000, 1, 4, 4)];
			Main.universe.addChild(currentroomtext);
			currentroomtext.x = Main.universe.stageWidth - 260;
			currentroomtext.y = Main.universe.stageHeight - 30;
		}
		
		public function drawcurrenttilebox():void {
			Main.mapeditor.mapcreator.drawDataByType(Main.mapeditor.mapcreator.currentTile, .1, .1, currenttiledata, true, true, 20, 20, false);
			currenttiledata.copyPixels(Main.textures.tileborder, currenttiledata.rect, new Point(), null, null, true);
		}
		
		public function removenavbuttons():void {
			loadbutton.removelisteners();
			savebutton.removelisteners();
			testbutton.removelisteners();
			settingsbutton.removelisteners();
			helpbutton.removelisteners();
			clearbutton.removelisteners();
			roombutton.removelisteners();
			sizeaddbutton.removelisteners();
			sizesubtractbutton.removelisteners();
			emptytilesbutton.removelisteners();
			blocktilesbutton.removelisteners();
			environmenttilesbutton.removelisteners();
			upgradetilesbutton.removelisteners();
			misctilesbutton.removelisteners();
			Main.universe.removeChild(loadbutton);
			Main.universe.removeChild(savebutton);
			Main.universe.removeChild(testbutton);
			Main.universe.removeChild(settingsbutton);
			Main.universe.removeChild(helpbutton);
			Main.universe.removeChild(clearbutton);
			Main.universe.removeChild(roombutton);
			Main.universe.removeChild(sizeaddbutton);
			Main.universe.removeChild(sizesubtractbutton);
			Main.universe.removeChild(emptytilesbutton);
			Main.universe.removeChild(blocktilesbutton);
			Main.universe.removeChild(environmenttilesbutton);
			Main.universe.removeChild(upgradetilesbutton);
			Main.universe.removeChild(misctilesbutton);
			Main.universe.removeChild(currenttilebox);
			currenttiledata.dispose();
			currenttilebox = null;
			currenttiledata = null;
			loadbutton = null;
			savebutton = null;
			testbutton = null;
			settingsbutton = null;
			helpbutton = null;
			clearbutton = null;
			roombutton = null;
			sizeaddbutton = null;
			sizesubtractbutton = null;
			emptytilesbutton = null;
			blocktilesbutton = null;
			environmenttilesbutton = null;
			upgradetilesbutton = null;
			misctilesbutton = null;
		}
		
		public function addnavbuttons():void {
			currenttiledata = new BitmapData(24, 24, false, 0);
			currenttilebox = new Bitmap(currenttiledata);
			currenttilebox.x = 5;
			currenttilebox.y = Main.universe.stageHeight - 32;
			currenttilebox.width = 30; currenttilebox.height = 30;
			Main.universe.addChild(currenttilebox);
			drawcurrenttilebox();
			
			testbutton = new Button("Test", 0, 0, 1, Main.mapeditor.testMap, 15);
			testbutton.transform.colorTransform = new ColorTransform(1.4, 1, 1);
			loadbutton = new Button("Load", 70, 0, 1, function():void {
				if (!settingswindow.showingsettings) { tooltip.tileinfobox.visible = false; savedgamelist.create(); }
			}, 15);
			savebutton = new Button("Save", 140, 0, 1, function():void {
				if (!settingswindow.showingsettings) { Main.mapeditor.savemap(); savedgamelist.loadgames(); }
			}, 15);
			settingsbutton = new Button("Settings", 210, 0, 1, function():void {
				if (settingswindow.showingsettings) { settingswindow.hidesettings(false); }else { settingswindow.showsettings(); }
			}, 15);
			roombutton = new Button("Rooms", 279, 0, 1, function():void {
				Main.mapeditor.roommanager.openroommenu();
			}, 15);
			clearbutton = new Button("New", 349, 0, 1, function():void {
				if (!settingswindow.showingsettings) {
						tooltip.tileinfobox.visible = false; Main.messagebox.show("<font color='#FCA0CA'>This will create a new map and erase all unfinished " +
						"data if not saved. Are you sure you want to do this?</font>", 2, -1, -1, "Remove!", "No way", function():void {
						Main.transition.show(function():void {
							Main.messagebox.hide(false);
							Main.mapeditor.exitMap();
							++Main.mapeditor.mapid;
							Main.mapeditor.overwrite = false;
							Main.mapeditor.mapcreator.currentcharpos.x = -1; Main.mapeditor.mapcreator.currentcharpos.y = -1;
							Main.mapeditor.mapcreator.charroom = null;
							Main.mapeditor.mapcreator.lastcharpos.x = -1; Main.mapeditor.mapcreator.lastcharpos.y = -1;
							Main.mapeditor.mapcreator.grid.length = 0;
							Main.mapeditor.mapcreator.backgroundtiles.length = 0;
							Main.mapeditor.mapcreator.defaultbackgroundgrid.length = 0;
							Main.mapeditor.mapcreator.defaultgrid.length = 0;
							Main.mapeditor.mapcreator.firstload = true;
							Main.mapeditor.roommanager.clearroombuttons(true);
							Main.mapeditor.roommanager.background.graphics.clear();
							Main.mapeditor.roommanager.rooms[0].finishtiles = 0;
							Main.mapeditor.roommanager.rooms.length = 0;
							Main.mapmanager.starteditor();
						});
					}, function():void {
						Main.messagebox.hide();
					});
				}
			}, 15);
			sizeaddbutton = new Button("+", 419, 0, 1, function():void {
				if (!settingswindow.showingsettings) { Main.mapeditor.brushsizeadd(); }
			}, 20, 25);
			sizesubtractbutton = new Button("-", 444, 0, 1, function():void {
				if (!settingswindow.showingsettings) { Main.mapeditor.brushsizesubtract(); }
			}, 20, 25);
			helpbutton = new Button("Help", 469, 0, 1, function():void {
				if (!settingswindow.showingsettings) { tooltip.tileinfobox.visible = false; Main.menu.showhelp(); }
			}, 15);
			emptytilesbutton = new Button("Empty", 539, 0, 1, null, 12, 47, Main.textures.eraser);
			emptytilesbutton.transform.colorTransform = new ColorTransform(1.15, 1, 1);
			blocktilesbutton = new Button("Blocks", 586, 0, 1, null, 12, 47, Main.textures.groundtile);
			blocktilesbutton.transform.colorTransform = new ColorTransform(1.15, 1, 1);
			environmenttilesbutton = new Button("Environment", 633, 0, 1, null, 12, 47, Main.textures.springdown);
			environmenttilesbutton.transform.colorTransform = new ColorTransform(1.15, 1, 1);
			upgradetilesbutton = new Button("Upgrade", 680, 0, 1, null, 12, 47, Main.textures.jetpack);
			upgradetilesbutton.transform.colorTransform = new ColorTransform(1.15, 1, 1);
			misctilesbutton = new Button("Misc", 727, 0, 1, null, 12, 48, Main.textures.pinkflowers[0]);
			misctilesbutton.transform.colorTransform = new ColorTransform(1.15, 1, 1);
			Main.universe.addChild(loadbutton);
			Main.universe.addChild(savebutton);
			Main.universe.addChild(testbutton);
			Main.universe.addChild(settingsbutton);
			Main.universe.addChild(helpbutton);
			Main.universe.addChild(clearbutton);
			Main.universe.addChild(roombutton);
			Main.universe.addChild(sizeaddbutton);
			Main.universe.addChild(sizesubtractbutton);
			Main.universe.addChild(emptytilesbutton);
			Main.universe.addChild(blocktilesbutton);
			Main.universe.addChild(environmenttilesbutton);
			Main.universe.addChild(upgradetilesbutton);
			Main.universe.addChild(misctilesbutton);
		}
		
		public function remove():void {
			//ui buttons
			removenavbuttons();
			
			//other ui
			Main.universe.removeChild(pausewindow);
			Main.universe.removeChild(cursor);
			Main.universe.removeChild(currentroomtext);
			roomformat = null;
			
			settingswindow.hidesettings(false);
			tooltip.remove();
		}
		
		public function update():void {
			if (!Main.mapeditor.ctrlKeyDown && Main.mapeditor.mouseIsDown && !Main.mapeditor.mapcreator.mapresizer.resizing &&
				!savebutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!loadbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!testbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!settingsbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!helpbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!clearbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!roombutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!sizesubtractbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!sizeaddbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!sizesubtractbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!emptytilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!blocktilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!environmenttilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!upgradetilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!misctilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!tiledatawindow.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!tilewindowcontainer.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) &&
				!Main.menu.navbar.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				Main.mapeditor.mapcreator.placetile();
			}else {
				tooltip.update();
			}
			
			if (Main.mapeditor.mapcreator.mapresizer.resizing) {
				cursor.x = Main.universe.mouseX; cursor.y = Main.universe.mouseY;
			}
			
			//if (Main.mapeditor.mapcreator.blueprint.mode == 0) {
				if (tilewindowopened) {
					if (!scrolling) {
						for (var g:int = 0; g < tilewindowblocks.length; ++g) {
							if (tilewindowblocks[g].hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
								tooltip.showtileinfobox(tooltip.tileinfo[currentwindowdata[g]], 
								tilewindowblocks[g].x + tiledatawindow.x + 22, (tilewindowblocks[g].y + tilewindowcontainer.y) + tiledatawindow.y - 25);
								break;
							}
						}
					}
					
					if (scrolling) {
						tiledatawindow.y += (25 - tiledatawindow.y) / 4;
						tilewindowcontainer.y += (destwindowy - tilewindowcontainer.y) / 6;
						if (tilewindowcontainer.y >= destwindowy - 2 && tilewindowcontainer.y <= destwindowy + 2 && tiledatawindow.y >= 24 && tiledatawindow.y <= 26) {
							scrolling = false;
							tiledatawindow.y = 25;
							tilewindowcontainer.y = destwindowy;
						}
					}
					if (windowscroller && tilewindowcontainer.y >= destwindowy - 5 && tilewindowcontainer.y <= destwindowy + 5 &&
						tiledatawindow.y >= 20 && tiledatawindow.y <= 30 && !scrolling || windowscroller && !scrolling) {
						if (Main.universe.mouseY >= windowscroller.y + 5) {
							if (tilewindowcontainer.y >= -((tilewindowblocks.length * 25) - 280)) {
								tilewindowcontainer.y -= 8;
								windowscrollertop.visible = true;
								if (tilemask.y != 40) { tilemask.height = tilemask.height - 15; }
								tilemask.y = 40;
							}
						}
						if (Main.universe.mouseY <= 42 && Main.universe.mouseY >= 20) {
							if (tilewindowcontainer.y <= 25) {
								tilewindowcontainer.y += 8;
							}else {
								windowscrollertop.visible = false;
								if (tilemask.y == 40) { tilemask.height = tilemask.height + 15; }
								tilemask.y = 25;
							}
						}
					}
				}
			//}
		}
		
		public function mousedown():void {
			if (tilewindowopened) {
				for (var g:int = 0; g < tilewindowblocks.length; ++g) {
					if (tilewindowblocks[g].hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
						if (!scrolling && Main.mapeditor.mouseIsDown) {
							Main.mapeditor.mapcreator.currentTile = alltileslist[currentwindowdata[g]];
							Main.mapeditor.mapcreator.originaltile = Main.mapeditor.mapcreator.currentTile;
							drawcurrenttilebox();
							Main.mapeditor.mapcreator.tilerotateindex = 0;
							if (Main.mapeditor.mapcreator.currentTile == 50) {
								Main.mapeditor.brushsize = 1; Main.mapeditor.mapcreator.invalidtile = true; Main.mapeditor.mapcreator.drawtileplacer();
							}else { Main.mapeditor.mapcreator.invalidtile = false; }
							hidetilemenu();
							Main.mapeditor.mapcreator.drawtileplacer();
							tooltip.tileinfobox.visible = false;
							Main.mapeditor.mouseIsDown = false;
						}
						break;
					}
				}
			}
		}
		
		public function hidetilemenu():void {
			for (var n:int = 0; n < tilewindowblocks.length; ++n) {
				tilewindowcontainer.removeChild(tilewindowblocks[n]);
			}
			if (!scrolling) { destwindowypositions[currentwindowindex] = tilewindowcontainer.y; }
			
			tilewindowblocks.length = 0;
			Main.universe.removeChild(tilewindowcontainer);
			if (windowscroller) { tiledatawindow.removeChild(windowscroller); tiledatawindow.removeChild(windowscrollertop); }
			Main.universe.removeChild(tiledatawindow);
			Main.universe.removeChild(tilemask);
			tiledatawindow.y = -tiledatawindow.height;
			
			windowscroller = null;
			tilewindowopened = false;
			scrolling = false;
			currentwindowindex = -1;
		}
		
		public function opentilemenu(data:Array, index:int):void {
			if (tilewindowopened) { hidetilemenu(); }
			
			tiledatawindow.graphics.clear();
			var h:int = data.length * 25; if (h >= 250) { h = 250; }
			tiledatawindow.graphics.lineStyle(1, 0x5A0C5D);
			tiledatawindow.graphics.beginFill(0x88198C, .4);
			tiledatawindow.graphics.drawRect(0, 0, 47, h + 10);
			Main.universe.addChild(tiledatawindow);
			tiledatawindow.x = emptytilesbutton.x + (index * 47);
			tiledatawindow.y = -h;
			Main.mapeditor.setoverlay();
			tilewindowopened = true;
			scrolling = true;
			currentwindowindex = index;
			currentwindowdata = data;
			
			Main.universe.addChild(tilewindowcontainer);
			tilewindowcontainer.x = tiledatawindow.x; tilewindowcontainer.y = tiledatawindow.y;
			tilewindowcontainer.x = tiledatawindow.x; tilewindowcontainer.y = tiledatawindow.y;
			
			tilemask = new Sprite();
			tilemask.graphics.lineStyle(1, 0x5A0C5D);
			tilemask.graphics.beginFill(0x88198C, .4);
			tilemask.graphics.drawRect(0, 0, 47, h + 10);
			Main.universe.addChild(tilemask);
			tilemask.x = tiledatawindow.x; tilemask.y = 25;
			
			destwindowy = destwindowypositions[currentwindowindex];
			if (h >= 250) {
				windowscroller = new Bitmap(Main.textures.windowscroll);
				tiledatawindow.addChild(windowscroller);
				windowscroller.x = 0; windowscroller.y = h + 10;
				windowscroller.width = 48;
				
				windowscrollertop = new Bitmap(Main.textures.windowscroll);
				tiledatawindow.addChild(windowscrollertop);
				windowscrollertop.x = 0; windowscrollertop.y = 15;
				windowscrollertop.width = 48;
				windowscrollertop.visible = false;
				windowscrollertop.scaleY = -1;
				
				if (destwindowy <= 22) { windowscrollertop.visible = true; tilemask.height = tilemask.height - 15; tilemask.y = 40; }
			}
			
			for (var n:int = 0; n < data.length; ++n) {
				var blockdata:BitmapData = new BitmapData(24, 24, true, 0);
				blockdata.copyPixels(Main.textures.tileborder, blockdata.rect, new Point());
				Main.mapeditor.mapcreator.drawDataByType(alltileslist[data[n]], .1, .1, blockdata, true, true);
				var block:Bitmap = new Bitmap(blockdata);
				tilewindowcontainer.addChild(block);
				block.x = 12;
				block.y = 5 + (n * 25);
				tilewindowblocks.push(block);
			}
			tilewindowcontainer.mask = tilemask;
		}
	}
}