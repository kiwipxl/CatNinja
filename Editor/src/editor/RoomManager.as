package editor {
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import maps.MapDetails;
	import ui.Button;
	import flash.display.Shape;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class RoomManager {
		
		//roommanager variables
		public var rooms:Vector.<MapDetails> = new Vector.<MapDetails>;
		public const roomneighbours:Array = [ -1, -1, 0, -1, 1, -1, 1, 0, 1, 1, 0, 1, -1, 1, -1, 0];
		public var firstvisit:Boolean = true;
		public var currentroom:MapDetails;
		public var roomscreated:int = 0;
		public var roommenushown:Boolean = false;
		
		//ui variables
		public var roomcontainer:Sprite = new Sprite();
		public var backbutton:Button;
		public var background:Shape = new Shape();
		public var arrows:Shape = new Shape();
		private var matrix:Matrix;
		public var removebutton:Button;
		private var colourtransform:ColorTransform = new ColorTransform();
		private var backgrounddata:BitmapData;
		
		public function initiate():void {
			if (rooms.length == 0) {
				createroom(0, 0, false);
				Main.mapeditor.mapcreator.details = rooms[0];
				currentroom = rooms[0];
				roomscreated = 1;
				
				var rowx:int = 0; var rowy:int = -1; var angle:int = 0; var size:int = 2; var distance:int = 2;
				for (var i:int = 0; i < (size * 4); ++i) {
					for (var u:int = 0; u < distance;++u) {
						if (angle == 0) { ++rowx; }else if (angle == 1) { ++rowy; }else if (angle == 2) { --rowx; }else if (angle == 3) { --rowy; }
						createroom(rowx - 1, rowy, true);
					}
					++angle;
					if (angle >= 4) { distance += 2; rowx = -1; rowy = -2; angle = 0; }
				}
				
				matrix = new Matrix();
				matrix.scale(.045, .045);
			}else {
				Main.mapeditor.mapcreator.details = currentroom;
			}
		}
		
		public function drawbackground():void {
			background.graphics.beginBitmapFill(Main.textures.middarkgroundtile);
			background.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			
			backgrounddata = new BitmapData(40, 40, true, 0);
			var backgroundalpha:BitmapData = new BitmapData(40, 40, true, 0xFFFFFF + (50 << 24));
			backgrounddata.copyPixels(Main.textures.simplebackground, backgrounddata.rect, new Point(), backgroundalpha, null, true);
			background.graphics.beginBitmapFill(backgrounddata);
			background.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			background.filters = [new BlurFilter(2, 2, 2)];
			
			colourtransform.redMultiplier = 1 + Math.random() * 1;
			colourtransform.greenMultiplier = 1 + Math.random() * 1;
			colourtransform.blueMultiplier = 1 + Math.random() * 1;
			background.transform.colorTransform = colourtransform;
			
			backgroundalpha.dispose(); backgroundalpha = null;
		}
		
		public function createroom(gridx:int = 0, gridy:int = 0, blank:Boolean = false):void {
			var room:MapDetails = new MapDetails();
			room.gridx = gridx;
			room.gridy = gridy;
			room.blank = blank;
			rooms.push(room);
		}
		
		public function drawroomboxes():void {
			arrows.graphics.clear();
			arrows.graphics.lineStyle(5, 0xF2C0F8);
			arrows.alpha = .8;
			arrows.x = Main.halfwidth; arrows.y = Main.halfheight;
			clearroombuttons(false);
			for each (var room:MapDetails in rooms) {
				room.roombutton = null;
				var data:BitmapData = Main.textures.roombackgroundbox;
				if (room.blank) { data = Main.textures.roombackgroundquestionbox; }
				var roombutton:Button = new Button("", (Main.halfwidth - 45) + (room.gridx * 105), (Main.halfheight - 45) + (room.gridy * 105), 0, 
				checkroomcollision, 40, 150, data, true, 150);
				roombutton.scaleX = .6; roombutton.scaleY = .6;
				roombutton.start();
				roombutton.addEventListener(MouseEvent.DOUBLE_CLICK, doubleclick);
				roombutton.doubleClickEnabled = true;
				room.roombutton = roombutton;
				roomcontainer.addChild(roombutton);
				data = null;
				if (room.blank) { roombutton.alpha = .6; }
				
				if (!room.blank) {
					for (var n:int = 0; n < rooms.length; ++n) {
						if (rooms[n] != room && !rooms[n].blank) {
							if (rooms[n].gridx == room.gridx - 1 && rooms[n].gridy == room.gridy || rooms[n].gridx == room.gridx + 1 && rooms[n].gridy == room.gridy ||
							rooms[n].gridx == room.gridx && rooms[n].gridy == room.gridy - 1 || rooms[n].gridx == room.gridx && rooms[n].gridy == room.gridy + 1) {
								arrows.graphics.moveTo(room.gridx * 105, room.gridy * 105);
								arrows.graphics.lineTo(rooms[n].gridx * 105, rooms[n].gridy * 105);
							}
						}
					}
				}
			}
			if (roomcontainer.stage) { roomcontainer.setChildIndex(arrows, roomcontainer.numChildren - 1); }
		}
		
		public function doubleclick(event:MouseEvent):void {
			closeroommenu();
		}
		
		public function checkroomcollision():void {
			for each (var room:MapDetails in rooms) {
				if (room.roombutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
					if (room.blank) {
						Main.messagebox.show("Are you sure you want to create a new room?", 2, -1, -1, "No", "Yes", null, function():void {
							room.tiles = Main.mapeditor.mapcreator.defaultgrid.concat();
							room.backgroundtiles = Main.mapeditor.mapcreator.defaultbackgroundgrid.concat();
							room.width = Main.mapeditor.mapcreator.defaultgridwidth;
							room.height = Main.mapeditor.mapcreator.defaultgridheight;
							++roomscreated; room.blank = false; room.index = roomscreated; switchrooms(room);
							drawroomboxes(); drawnewroomimages(); Main.messagebox.hide();
						});
					}else {
						switchrooms(room);
						drawnewroomimages();
					}
					break;
				}
			}
		}
		
		public function drawnewroomimages():void {
			var data:BitmapData = Main.textures.roombackgroundquestionbox;
			for each (var room:MapDetails in rooms) {
				if (!room.blank) {
					data = Main.textures.roombackgroundbox;
					if (room == currentroom) { data = Main.textures.roombackgroundselectbox; }
					room.roombutton.centerimage.bitmapData = data;
					
					if (room.modified) {
						if (room.mapimagedisplay) { room.mapimage.dispose(); if (room.mapimagedisplay.stage) {
						Main.universe.removeChild(room.mapimagedisplay); } room.mapimagedisplay = null; }
						room.mapimage = new BitmapData(room.width - 15, room.height - 15, false, 0);
						room.mapimagedisplay = new Bitmap(room.mapimage);
						Main.universe.addChild(room.mapimagedisplay);
						room.mapimagedisplay.smoothing = true;
						room.mapimagedisplay.scaleX = .6;
						room.mapimagedisplay.scaleY = .6;
						room.mapimage.draw(Main.mapeditor.mapcreator.mapdata, matrix);
						room.modified = false;
					}else {
						if (room.mapimagedisplay && !room.mapimagedisplay.stage) { Main.universe.addChild(room.mapimagedisplay); }
					}
					room.mapimagedisplay.x = room.roombutton.x + (49 - ((room.width * .6) / 2));
					room.mapimagedisplay.y = room.roombutton.y + (49 - ((room.height * .6) / 2));
					if (room.mapimagedisplay && room.mapimagedisplay.stage) { Main.universe.setChildIndex(room.mapimagedisplay, Main.universe.numChildren - 1); }
				}
			}
			data = null;
		}
		
		public function openroommenu(showfirstjoinmessage:Boolean = true):void {
			if (roommenushown) { closeroommenu(); return; }
			if (Main.mapeditor.ui.settingswindow.showingsettings) { Main.mapeditor.ui.settingswindow.hidesettings(false); }
			Main.mapeditor.savedetails();
			
			roomcontainer = new Sprite();
			Main.universe.addChild(roomcontainer);
			roomcontainer.addChild(background);
			roomcontainer.addChild(arrows);
			
			Main.mapeditor.setoverlay();
			drawroomboxes();
			drawnewroomimages();
			drawbackground();
			
			Main.mapeditor.ui.currentroomtext.text = "Current room: Room " + currentroom.index;
			
			backbutton = new Button("Back", 0, 0, 1, function():void {
				closeroommenu();
			}, 15);
			backbutton.start();
			roomcontainer.addChild(backbutton);
			removebutton = new Button("Remove", 0, Main.universe.stageHeight - 26, 1, function():void {
				removeroom(currentroom);
			}, 15);
			removebutton.start();
			roomcontainer.addChild(removebutton);
			
			roommenushown = true;
			if (firstvisit && showfirstjoinmessage) {
				Main.messagebox.show("<font color='#C5E447' size='15'>Welcome to the room manager!</font>\n" +
				"This section of the editor allows you to create more rooms by linking each other");
				Main.mapeditor.sharedobject.data.showroomjoinmessage = false;
				Main.mapeditor.sharedobject.flush();
			}
			firstvisit = false;
		}
		
		public function removeroom(room:MapDetails):void {
			if (roomscreated <= 1) {
				Main.messagebox.show("You cannot delete the only room left"); return;
			}
			Main.messagebox.show("Are you sure you want to remove this room? This action cannot be undone", 2, -1, -1, "Cancel", "Ok", null, function():void {
				--roomscreated;
				room.blank = true;
				room.modified = false;
				room.tiles.length = 0;
				room.backgroundtiles.length = 0;
				room.finishtiles = 0;
				if (room.mapimagedisplay) { room.mapimage.dispose(); if (room.mapimagedisplay.stage) {
				Main.universe.removeChild(room.mapimagedisplay); } room.mapimagedisplay = null; }
				
				var newroom:MapDetails;
				for (var n:int = 0; n < rooms.length; ++n) {
					if (!rooms[n].blank) {
						newroom = rooms[n];
						if (rooms[n].index > room.index) {
							--rooms[n].index;
						}
					}
				}
				Main.messagebox.hide();
				room.index = 1;
				
				if (Main.mapeditor.mapcreator.charroom == room) {
					Main.mapeditor.mapcreator.currentcharpos.x = -1;
					Main.mapeditor.mapcreator.currentcharpos.y = -1;
					Main.mapeditor.mapcreator.charroom = null;
				}
				
				switchrooms(newroom);
				drawroomboxes();
				drawnewroomimages();
			});
		}
		
		public function clearroombuttons(removemapimages:Boolean = false):void {
			for (var n:int = 0; n < rooms.length; ++n) {
				if (rooms[n].roombutton != null) {
					rooms[n].roombutton.removelisteners();
					rooms[n].roombutton.removeEventListener(MouseEvent.DOUBLE_CLICK, doubleclick);
					roomcontainer.removeChild(rooms[n].roombutton);
					rooms[n].roombutton.removeChild(rooms[n].roombutton.centerimage);
					if (removemapimages && rooms[n].mapimagedisplay && rooms[n].mapimagedisplay.stage) {
						Main.universe.removeChild(rooms[n].mapimagedisplay);
					}
					rooms[n].roombutton = null;
				}
			}
		}
		
		public function closeroommenu():void {
			clearroombuttons(true);
			
			Main.universe.removeChild(roomcontainer);
			background.filters.length = 0; backgrounddata.dispose(); backgrounddata = null;
			roomcontainer.removeChild(background);
			background.graphics.clear();
			backbutton.removelisteners();
			roomcontainer.removeChild(backbutton);
			
			roommenushown = false;
			Main.universe.focus = null;
		}
		
		public function switchrooms(room:MapDetails):void {
			Main.mapeditor.savedetails();
			
			Main.mapeditor.mapcreator.details = room;
			Main.mapeditor.mapcreator.gridwidth = Main.mapeditor.mapcreator.details.width;
			Main.mapeditor.mapcreator.gridheight = Main.mapeditor.mapcreator.details.height;
			Main.mapeditor.mapcreator.grid = Main.mapeditor.mapcreator.details.tiles;
			Main.mapeditor.mapcreator.backgroundtiles = Main.mapeditor.mapcreator.details.backgroundtiles;
			
			currentroom.modified = false;
			currentroom = room;
			room.modified = true;
			Main.mapeditor.ui.currentroomtext.text = "Current room: Room " + room.index;
			Main.mapeditor.mapcreator.mapresizer.resizeMap(room.width, room.height, true);
		}
	}
}