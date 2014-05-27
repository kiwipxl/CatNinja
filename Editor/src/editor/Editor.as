package editor {
	
	import editor.trackmill.com.adobe.Base64Decoder;
	import editor.trackmill.ui.UIManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import maps.MapDetails;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Editor extends Sprite {
		
		//editor variables
		public var ui:EditorUI = new EditorUI();
		public var roommanager:RoomManager = new RoomManager();
		public var mapcreator:MapCreator = new MapCreator();
		public var created:Boolean = false;
		public var sharedobject:SharedObject;
		public var savedmaps:Array = [];
		public var decoder:Base64Decoder = new Base64Decoder();
		public var mapid:int = 1;
		public var overwrite:Boolean = false;
		
		//movement variables
		public var rightkeydown:Boolean = false; //true when right key is down
		public var leftkeydown:Boolean = false; //true when left key is down
		public var upkeydown:Boolean = false; //true when up key is down
		public var downkeydown:Boolean = false; //true when down key is down
		public var ctrlKeyDown:Boolean = false; //true when ctrl key is down
		
		//brush variables
		public var brushsize:int = 1;
		public const sides:Array = [1, 0, 0, 1, -1, 0, 0, -1];
		public var brushtypes:Array = [ -1, 0, 1, 51, 52, 76, 2, 65, 58];
		
		//other variables
		public var mouseIsDown:Boolean = false; //sets to true when the left mouse button is down
		private var firstfinishtileask:Boolean = true;
		public var mapx:int = 0;
		public var mapy:int = 0;
		
		public function initiate():void {
			sharedobject = SharedObject.getLocal("catninjadata");
			if (sharedobject.data.maps && sharedobject.data.maps.length >= 1) {
				savedmaps = sharedobject.data.maps;
				mapid = sharedobject.data.maps[sharedobject.data.maps.length - 3][0];
			}
			if (sharedobject.data.firstfinishtileask != null) { firstfinishtileask = false; }
			if (sharedobject.data.showroomjoinmessage != null) { roommanager.firstvisit = false; }
			if (sharedobject.data.helpmessagesasked != null) { Main.mapmanager.helpmessagesasked = sharedobject.data.helpmessagesasked; }
		}
		
		public function create():void {
			roommanager.initiate();
			mapcreator.createmap();
			ui.settingswindow.initiate();
			ui.create();
			ui.tooltip.initiate();
			
			ctrlKeyDown = false;
			mouseIsDown = false;
			
			Main.sound.play(1);
			
			setoverlay();
			mapcreator.map.x = mapx;
			mapcreator.map.y = mapy;
			
			UIManager.messagebox.hide(false);
			
			//add events
			addEventListener(Event.ENTER_FRAME, loop); //loop event
			Main.universe.addEventListener(KeyboardEvent.KEY_DOWN, keyDown); //dispatches when a key is pressed down
			Main.universe.addEventListener(KeyboardEvent.KEY_UP, keyUp); //dispatches when a key is up
			Main.universe.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown); //dispatches when the left mouse is down
			Main.universe.addEventListener(MouseEvent.MOUSE_UP, mouseUp); //dispatches when the left mouse is up
		}
		
		public function savemap():void {
			if (mapcreator.currentcharpos.x == -1 && mapcreator.currentcharpos.y == -1) {
				Main.messagebox.show("Must set kitty starting position <font color='#88de71'>(The kitty starting tile in the eraser menu)</font>");
				return;
			}
			
			for (var n:int = 0; n < savedmaps.length; n += 3) {
				if (overwrite && savedmaps[n][0] == mapid) {
					Main.mapmanager.publishmap("Overwriting save...", true, function():void {
						UIManager.loadingbox.hide();
						UIManager.messagebox.show("Map saved successfully! Overwrote " + savedmaps[n][1], "Success!");
						savedmaps[n] = [mapid, ui.settingswindow.mapname, ui.settingswindow.mapdescription, ui.settingswindow.maptags, mapcreator.charroom];
						savedmaps[n + 1] = Main.mapmanager.trackmill.screenshot;
						savedmaps[n + 2] = Main.mapmanager.mapsaveddata;
						sharedobject.data.maps = savedmaps;
						sharedobject.flush();
					}, 120, 120);
					
					return;
				}
			}
			Main.mapmanager.publishmap("Saving...", true, function():void {
				UIManager.loadingbox.hide();
				UIManager.messagebox.show("Map saved successfully!", "Success!");
				overwrite = true;
				++mapid;
				if (ui.settingswindow.mapname == "") { ui.settingswindow.mapname = "Map " + (mapid - 1); }
				savedmaps.push([mapid, ui.settingswindow.mapname, ui.settingswindow.mapdescription, ui.settingswindow.maptags, mapcreator.charroom, 
				Main.mapmanager]);
				savedmaps.push(Main.mapmanager.trackmill.screenshot, Main.mapmanager.mapsaveddata);
				sharedobject.data.maps = savedmaps;
				sharedobject.flush();
			}, 120, 120);
		}
		
		public function testMap():void {
			if (ui.settingswindow.showingsettings || Main.messagebox.visible || roommanager.roommenushown || 
			UIManager.messagebox.visible || UIManager.loadingbox.visible || ui.savedgamelist.stage ||
			Main.mapmanager.trackmill.loginwindow && Main.mapmanager.trackmill.loginwindow.visible) {
				return;
			}
			
			var finishtiles:int = 0;
			for (var n:int = 0; n < roommanager.rooms.length; ++n) {
				if (!roommanager.rooms[n].blank) {
					finishtiles += roommanager.rooms[n].finishtiles;
				}
			}
			
			if (mapcreator.currentcharpos.x == -1 && mapcreator.currentcharpos.y == -1) {
				Main.messagebox.show("Must set kitty starting position <font color='#88de71'>(The kitty starting tile in the eraser menu)</font>");
			}else if (firstfinishtileask && finishtiles <= 0) {
				Main.messagebox.show("<font color='#88de71' size='25'>Hey! </font>Remember there are <font color='#E899F0'>completion tiles </font>" +
				"in the <font color='#89C9EF'>blocks tile menu</font>", 1, -1, -1, 
				"Continue", "", initiatetest, null);
				firstfinishtileask = false;
				sharedobject.data.firstfinishtileask = false;
				sharedobject.flush();
			}else {
				initiatetest();
			}
		}
		
		private function initiatetest():void {
			Main.transition.show(function():void {
				mapx = mapcreator.map.x;
				mapy = mapcreator.map.y;
				Main.messagebox.hide();
				Main.messagebox.visible = false;
				roommanager.currentroom.modified = false;
				roommanager.currentroom = mapcreator.charroom;
				exitMap();
				Main.mapmanager.startgame(roommanager.rooms, mapcreator.charroom);
			});
		}
		
		public function savedetails():void {
			mapcreator.details.width = mapcreator.gridwidth;
			mapcreator.details.height = mapcreator.gridheight;
			mapcreator.details.tiles = mapcreator.grid;
			mapcreator.details.backgroundtiles = mapcreator.backgroundtiles;
			mapcreator.details.timemode = ui.settingswindow.goalitembox.lastselecteditem;
			mapcreator.details.timeminutes = ui.settingswindow.minuteinterval;
			mapcreator.details.timeseconds = ui.settingswindow.secondinterval;
		}
		
		public function loaddetails(mapdetails:MapDetails):void {
			mapcreator.gridwidth = mapdetails.width;
			mapcreator.gridheight = mapdetails.height;
			mapcreator.grid = mapdetails.tiles;
			mapcreator.backgroundtiles = mapdetails.backgroundtiles;
			ui.settingswindow.goalitembox.lastselecteditem = mapdetails.timemode;
			ui.settingswindow.minuteinterval = mapdetails.timeminutes;
			ui.settingswindow.secondinterval = mapdetails.timeseconds;
			if (ui.currentroomtext) { ui.currentroomtext.text = "Current room: Room " + roommanager.currentroom.index; }
			mapcreator.details = roommanager.currentroom;
		}
		
		public function exitMap():void {
			savedetails();
			if (Main.messagebox.visible) { return; }
			
			mapcreator.remove();
			ui.remove();
			if (Main.mapmanager.fullscreenbutton) {
				Main.mapmanager.fullscreenbutton.removelisteners();
				Main.universe.removeChild(Main.mapmanager.fullscreenbutton);
				Main.mapmanager.fullscreenbutton = null;
			}
			
			removeEventListener(Event.ENTER_FRAME, loop); //loop event
			Main.universe.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown); //dispatches when a key is pressed down
			Main.universe.removeEventListener(KeyboardEvent.KEY_UP, keyUp); //dispatches when a key is up
			Main.universe.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown); //dispatches when the left mouse is down
			Main.universe.removeEventListener(MouseEvent.MOUSE_UP, mouseUp); //dispatches when the left mouse is up
		}
		
		public function setoverlay():void {
			Main.universe.setChildIndex(mapcreator.tileplacer, Main.universe.numChildren - 1);
			if (ui.tiledatawindow.stage) { Main.universe.setChildIndex(ui.tiledatawindow, Main.universe.numChildren - 1); }
			if (ui.testbutton.stage) {
				Main.universe.setChildIndex(ui.loadbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.savebutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.testbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.settingsbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.helpbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.clearbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.roombutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.sizeaddbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.sizesubtractbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.emptytilesbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.blocktilesbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.environmenttilesbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.upgradetilesbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.misctilesbutton, Main.universe.numChildren - 1);
				Main.universe.setChildIndex(ui.currenttilebox, Main.universe.numChildren - 1);
				if (Main.mapmanager.fullscreenbutton && Main.mapmanager.fullscreenbutton.stage) {
					Main.universe.setChildIndex(Main.mapmanager.fullscreenbutton, Main.universe.numChildren - 1);
				}
			}
			Main.universe.setChildIndex(Main.menu.navbar, Main.universe.numChildren - 1);
			Main.universe.setChildIndex(ui.pausewindow, Main.universe.numChildren - 1);
			if (ui.settingswindow.settingswindow && ui.settingswindow.showingsettings) {
			Main.universe.setChildIndex(ui.settingswindow.settingswindow, Main.universe.numChildren - 1); }
			if (ui.savedgamelist.stage) { Main.universe.setChildIndex(ui.savedgamelist, Main.universe.numChildren - 1); }
			if (Main.messagebox.visible) { Main.universe.setChildIndex(Main.messagebox.windowcontainer, Main.universe.numChildren - 1);
			Main.universe.setChildIndex(Main.messagebox, Main.universe.numChildren - 1); }
			if (UIManager.messagebox.visible) { Main.universe.setChildIndex(UIManager.messagebox.windowcontainer, Main.universe.numChildren - 1);
			Main.universe.setChildIndex(UIManager.messagebox, Main.universe.numChildren - 1); }
			if (UIManager.loadingbox.visible) { Main.universe.setChildIndex(UIManager.loadingbox.windowcontainer, Main.universe.numChildren - 1);
			Main.universe.setChildIndex(UIManager.loadingbox, Main.universe.numChildren - 1); }
			if (roommanager.roomcontainer.stage) { Main.universe.setChildIndex(roommanager.roomcontainer, Main.universe.numChildren - 1); }
			Main.universe.setChildIndex(ui.currentroomtext, Main.universe.numChildren - 1);
			Main.universe.setChildIndex(Main.info.console, Main.universe.numChildren - 1);
			Main.universe.setChildIndex(ui.cursor, Main.universe.numChildren - 1);
		}
		
		private function keyDown(ev:KeyboardEvent):void {
			if (Main.transition.created) { return; }
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
			
			//keyboard number inputs
			if (!ui.settingswindow.showingsettings && !Main.messagebox.visible && !ui.pausewindow.visible && key >= 49 && key <= 49 + (brushtypes.length)) {
				mapcreator.currentTile = brushtypes[key - 49]; mapcreator.originaltile = mapcreator.currentTile; mapcreator.tilerotateindex = 0;
				mapcreator.invalidtile = false;
				mapcreator.drawtileplacer();
				ui.drawcurrenttilebox();
			}
			
			if (key == 17) { //ctrl key down
				ctrlKeyDown = true;
				mapcreator.tileplacer.visible = false;
				mapcreator.lasttilepos.x = -1; mapcreator.lasttilepos.y = -1;
			}
			
			if (key == 189) { //negative input
				brushsizesubtract();
			}
			
			if (key == 187) { //positive input
				brushsizeadd();
			}
			
			if (key == 13) {
				if (Main.messagebox.visible && Main.messagebox.buttonamount == 1) { Main.messagebox.hide(); }
				if (UIManager.messagebox.visible && UIManager.messagebox.buttonamount == 1) { UIManager.messagebox.hide(); }
				Main.info.inputlog();
			}
			
			if (key == 16 && mapcreator.currentTile != 0) {
				mapcreator.lastcurrenttile = mapcreator.currentTile;
				mapcreator.currentTile = 0; mapcreator.originaltile = mapcreator.currentTile; mapcreator.tilerotateindex = 0;
				mapcreator.drawtileplacer();
				ui.drawcurrenttilebox();
			}
			
			if (key == 82) {
				var found:Boolean = false;
				for (var i:int = 0; i < ui.rotatabletiles.length; ++i) {
					if (ui.rotatabletiles[i] == mapcreator.originaltile) {
						found = true;
						break;
					}
				}
				if (!found) { return; }
				
				++mapcreator.currentTile;
				++mapcreator.tilerotateindex;
				
				var repeat:int = 2;
				if (mapcreator.originaltile != 70) {
					repeat = 4;
					found = false;
					for (var n:int = 0; n < ui.rotatedirections.length; n += 4) {
						if (mapcreator.originaltile == ui.rotatedirections[n]) {
							mapcreator.currentTile = ui.rotatedirections[n + mapcreator.tilerotateindex];
							ui.drawcurrenttilebox();
							found = true;
						}
					}
					if (!found) {
						if (mapcreator.tilerotateindex == 1) { mapcreator.currentTile = mapcreator.originaltile + 2; mapcreator.drawtileplacer(); return;
						}else if (mapcreator.tilerotateindex == 3) { mapcreator.currentTile = mapcreator.originaltile + 1; }
					}
				}
				
				if (mapcreator.tilerotateindex == repeat) {
					mapcreator.currentTile = mapcreator.originaltile;
					mapcreator.tilerotateindex = 0;
				}
				
				mapcreator.drawtileplacer();
				ui.drawcurrenttilebox();
			}
			
			if (key == 77 && !Main.messagebox.visible && !ui.pausewindow.visible && !ui.settingswindow.showingsettings &&
				!UIManager.messagebox.stage && !UIManager.loadingbox.stage) {
				if (!Main.mapmanager.trackmill.loginwindow || !Main.mapmanager.trackmill.loginwindow.stage) {
					roommanager.openroommenu();
				}
			}
		}
		
		public function brushsizeadd():void {
			if (mapcreator.currentTile == 50) { return; }
			++brushsize;
			if (brushsize > 8) {
				brushsize = 8;
			}
			mapcreator.drawtileplacer();
		}
		
		public function brushsizesubtract():void {
			if (mapcreator.currentTile == 50) { return; }
			--brushsize;
			if (brushsize < 1) {
				brushsize = 1;
			}
			mapcreator.drawtileplacer();
		}
		
		private function keyUp(ev:KeyboardEvent):void {
			if (Main.transition.created) { return; }
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
				mapcreator.tileplacer.visible = true;
				if (mapcreator.mapresizer.resizing) {
					ui.cursor.visible = false;
					Mouse.show();
					mouseIsDown = false;
					if (mapcreator.mapresizer.resizing) { ctrlKeyDown = true; mapcreator.mapresizer.checkborders(); ctrlKeyDown = false;
					ui.cursor.visible = false; Mouse.show(); mapcreator.mapresizer.resizing = false; }
				}
			}
			
			//open/hide console
			if (key == 192) {
				Main.info.toggleConsole();
			}
			
			if (key == 16) {
				mapcreator.currentTile = mapcreator.lastcurrenttile; mapcreator.originaltile = mapcreator.currentTile; mapcreator.tilerotateindex = 0;
				mapcreator.drawtileplacer();
				ui.drawcurrenttilebox();
			}
		}
		
		private function loop(event:Event):void {
			Main.sound.update();
			if (Main.transition.created) { return; }
			if (ui.settingswindow.showingsettings || Main.messagebox.visible || roommanager.roommenushown || 
			UIManager.messagebox.visible || UIManager.loadingbox.visible || ui.savedgamelist.stage ||
			Main.mapmanager.trackmill.loginwindow && Main.mapmanager.trackmill.loginwindow.visible) {
				Main.messagebox.update();
				return;
			}
			
			mapcreator.update();
			ui.update();
		}
		
		private function mouseDown(event:MouseEvent):void {
			if (Main.transition.created) { return; }
			mouseIsDown = true;
			
			roommanager.currentroom.modified = true;
			ui.mousedown();
		}
		
		private function mouseUp(event:MouseEvent):void {
			if (Main.transition.created) { return; }
			mouseIsDown = false;
			if (mapcreator.mapresizer.resizing) { ctrlKeyDown = true; mapcreator.mapresizer.checkborders();
			ctrlKeyDown = false; ui.cursor.visible = false; Mouse.show(); mapcreator.mapresizer.resizing = false; }
		}
	}
}