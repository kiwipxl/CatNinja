package editor {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import maps.MapDetails;
	import ui.Button;
	import editor.components.ItemBox;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class SettingsWindow {
		
		//settingswindow variables
		public var settingsbox:Bitmap;
		private var settingscancelbutton:Button;
		private var settingsapplybutton:Button;
		private var settingspublishbutton:Button;
		public var showingsettings:Boolean = false;
		private var mapnametitle:TextField;
		private var mapnameinput:TextField;
		public var settingsformat:TextFormat;
		public var settingswindow:Sprite = new Sprite();
		private var mapsizetitle:TextField;
		private var mapsizeinputwidth:TextField;
		private var mapsizeinputheight:TextField;
		public var mapname:String = "";
		private var mapdescriptiontitle:TextField;
		private var mapdescriptioninput:TextField;
		public var mapdescription:String = "";
		private var maptagstitle:TextField;
		private var maptagsinput:TextField;
		public var maptags:String = "";
		private var goaltitle:TextField;
		public var goalitembox:ItemBox = new ItemBox();
		public var minutetextfield:TextField = new TextField();
		public var secondtextfield:TextField = new TextField();
		public var minutetitle:TextField;
		public var secondtitle:TextField;
		public var minuteinterval:int = 0;
		public var secondinterval:int = 30;
		public var goalcontainer:Sprite = new Sprite();
		private var musictitle:TextField = new TextField();
		public var musicitembox:ItemBox = new ItemBox();
		
		public function initiate():void {
			settingsformat = new TextFormat();
			settingsformat.size = 14;
			settingsformat.font = "square";
			
			minutetextfield.addEventListener(Event.CHANGE, function(event:Event):void {
				if (int(minutetextfield.text) >= 30) { minutetextfield.text = "30"; }
				if (isNaN(Number(minutetextfield.text))) { minutetextfield.text = "0"; }
			});
			secondtextfield.addEventListener(Event.CHANGE, function(event:Event):void {
				secondchangeupdate();
			});
			goalcontainer.visible = false;
		}
		
		public function secondchangeupdate():void {
			if (int(secondtextfield.text) >= 60 && secondtitle.text == "Secs:") { secondtextfield.text = "59"; }
			if (isNaN(Number(secondtextfield.text))) { secondtextfield.text = "1"; }
			if (int(secondtextfield.text) == 0 && secondtextfield.text != "" && int(minutetextfield.text) == 0) { secondtextfield.text = "1"; }
		}
		
		public function createTitleText(textfield:TextField, text:String, width:int, height:int, x:int, y:int, textcolor:int, align:String = "left", addto:Sprite = null):void {
			settingsformat.align = align;
			textfield.defaultTextFormat = settingsformat;
			textfield.embedFonts = true;
			textfield.text = text;
			textfield.textColor = textcolor;
			textfield.width = width;
			textfield.height = height;
			textfield.selectable = false;
			if (!addto) { settingswindow.addChild(textfield); }else { addto.addChild(textfield); }
			textfield.x = x;
			textfield.y = y;
		}
		
		public function createInputText(textfield:TextField, width:int, height:int, x:int, y:int, align:String = "left", addto:Sprite = null):void {
			settingsformat.align = align;
			textfield.defaultTextFormat = settingsformat;
			textfield.embedFonts = true;
			textfield.textColor = 0x000000;
			textfield.border = true;
			textfield.borderColor = 0x000000;
			textfield.background = true;
			textfield.backgroundColor = 0xFFFFFF;
			textfield.type = TextFieldType.INPUT;
			textfield.width = width;
			textfield.height = height;
			if (!addto) { settingswindow.addChild(textfield); }else { addto.addChild(textfield); }
			textfield.x = x;
			textfield.y = y;
		}
		
		public function showsettings(forcesave:Boolean = false):void {
			settingsbox = new Bitmap(Main.textures.alltiles);
			Main.mapeditor.ui.pausewindow.visible = true;
			Main.mapeditor.ui.pausewindow.width = Main.universe.stageWidth; Main.mapeditor.ui.pausewindow.height = Main.universe.stageHeight;
			settingswindow = new Sprite();
			Main.universe.addChild(settingswindow);
			settingswindow.addChild(settingsbox);
			settingsbox.width = 320;
			settingsbox.height = 400;
			settingsbox.x = (Main.universe.stageWidth / 2) - (settingsbox.width / 2);
			settingsbox.y = (Main.universe.stageHeight / 2) - (settingsbox.height / 2);
			
			mapnametitle = new TextField();
			mapnameinput = new TextField();
			mapsizetitle = new TextField();
			mapsizeinputwidth = new TextField();
			mapsizeinputheight = new TextField();
			mapdescriptiontitle = new TextField();
			mapdescriptioninput = new TextField();
			maptagstitle = new TextField();
			maptagsinput = new TextField();
			goaltitle = new TextField();
			minutetextfield = new TextField();
			secondtextfield = new TextField();
			minutetitle = new TextField();
			secondtitle = new TextField();
			var rowy:int = 44;
			createTitleText(mapnametitle, "Map name: ", 80, 20, settingsbox.x + 10, settingsbox.y + 20, 0xD15CDE);
			createInputText(mapnameinput, 200, 20, settingsbox.x + 100, settingsbox.y + 20);
			if (!forcesave) {
				createTitleText(mapsizetitle, "Room size:                                  x", settingsbox.width - 10, 20, settingsbox.x + 10, settingsbox.y + 55, 0xD15CDE);
				createInputText(mapsizeinputwidth, 60, 20, settingsbox.x + 150, settingsbox.y + 53, "center");
				createInputText(mapsizeinputheight, 60, 20, settingsbox.x + 240, settingsbox.y + 53, "center");
				rowy += 40;
			}
			createTitleText(mapdescriptiontitle, "Description: ", settingsbox.width - 10, 20, settingsbox.x + 10, settingsbox.y + rowy, 0xD15CDE);
			rowy += 22;
			createInputText(mapdescriptioninput, settingsbox.width - 30, 50, settingsbox.x + 15, settingsbox.y + rowy);
			rowy += 60;
			createTitleText(maptagstitle, "Tags (seperated by spaces): ", 200, 20, settingsbox.x + 10, settingsbox.y + rowy, 0xD15CDE);
			rowy += 20;
			createInputText(maptagsinput, settingsbox.width - 30, 20, settingsbox.x + 15, settingsbox.y + rowy);
			mapnameinput.text = mapname;
			mapnameinput.maxChars = 25;
			mapsizeinputwidth.maxChars = 3;
			mapsizeinputheight.maxChars = 3;
			mapsizeinputwidth.text = Main.mapeditor.mapcreator.gridwidth.toString();
			mapsizeinputheight.text = Main.mapeditor.mapcreator.gridheight.toString();
			mapdescriptioninput.maxChars = 200;
			mapdescriptioninput.text = mapdescription;
			mapdescriptioninput.multiline = true;
			mapdescriptioninput.wordWrap = true;
			maptagsinput.maxChars = 200;
			maptagsinput.text = maptags;
			
			var applytext:String = "Save";
			settingspublishbutton = new Button("Publish", (settingsbox.x + settingsbox.width) - 85, (settingsbox.y + settingsbox.height) - 40, 1, function():void {
				hidesettings(true, true);
			}, 15);
			settingspublishbutton.transform.colorTransform = new ColorTransform(1.8, 1.2, 1);
			settingsapplybutton = new Button("Apply", (settingsbox.x + settingsbox.width) - 165, (settingsbox.y + settingsbox.height) - 40, 1, function():void {
				hidesettings(true);
			}, 15);
			settingscancelbutton = new Button("Cancel", (settingsbox.x + settingsbox.width) - 245, (settingsbox.y + settingsbox.height) - 40, 1, function():void {
				hidesettings(false);
			}, 15);
			settingswindow.addChild(settingscancelbutton);
			settingswindow.addChild(settingsapplybutton);
			settingswindow.addChild(settingspublishbutton);
			
			if (!forcesave) {
				rowy += 35;
				createTitleText(goaltitle, "Goal configuration", 250, 20, settingsbox.x + 15, settingsbox.y + rowy, 0xD15CDE);
				rowy += 20;
				settingswindow.addChild(goalitembox);
				settingswindow.addChild(goalcontainer);
				
				createTitleText(minutetitle, "Mins:", 60, 15, settingsbox.x + 165, settingsbox.y + rowy, 0xD15CDE, "left", goalcontainer);
				createInputText(minutetextfield, 25, 20, settingsbox.x + 200, settingsbox.y + rowy, "center", goalcontainer);
				minutetextfield.maxChars = 2; minutetextfield.text = minuteinterval.toString();
				createTitleText(secondtitle, "Secs:", 60, 15, settingsbox.x + 240, settingsbox.y + rowy, 0xD15CDE, "left", goalcontainer);
				createInputText(secondtextfield, 25, 20, settingsbox.x + 280, settingsbox.y + rowy, "center", goalcontainer);
				secondtextfield.maxChars = 2; secondtextfield.text = secondinterval.toString();
				
				goalitembox.create(["Count up", "Finish under...", "Hide timer", "Collect amount"]);
				goalitembox.x = settingsbox.x + 15;
				goalitembox.y = settingsbox.y + rowy;
				secondchangeupdate();
				
				rowy += 35;
				createTitleText(musictitle, "Select your music!", 250, 20, settingsbox.x + 15, settingsbox.y + rowy, 0xD15CDE);
				rowy += 20;
				musicitembox.create(["Chiptune Theme", "Boss Battle", "Oxygen", "Aztec", "Desert Plains", "Force of cold", "Mysterious Mystery", "Grasslands", 
				"Microbe+", "Bitfunk"]);
				musicitembox.x = settingsbox.x + 15;
				musicitembox.y = settingsbox.y + rowy;
				settingswindow.addChild(musicitembox);
				settingswindow.setChildIndex(goalitembox, settingswindow.numChildren - 1);
				settingswindow.setChildIndex(musictitle, settingswindow.numChildren - 4);
			}
			
			showingsettings = true;
			Main.mapeditor.ui.tooltip.tileinfobox.visible = false;
			Main.mapeditor.mapcreator.tileplacer.visible = false;
			
			Main.mapeditor.setoverlay();
		}
		
		public function hidesettings(save:Boolean, publish:Boolean = false):void {
			if (!goalitembox.finishedmoving || !musicitembox.finishedmoving) { return; }
			
			if (save) {
				var w:int = int(mapsizeinputwidth.text);
				var h:int = int(mapsizeinputheight.text);
				if (isNaN(Number(mapsizeinputwidth.text)) || isNaN(Number(mapsizeinputheight.text))) {
					Main.messagebox.show("Map dimensions contains some invalid characters"); return;
				}else if (w > Main.mapeditor.mapcreator.MAXWIDTH || h > Main.mapeditor.mapcreator.MAXHEIGHT) {
					Main.messagebox.show("Map dimensions are too big. You can't create a map over 150 tiles."); return;
				}else if (w < 40 || h < 30) { Main.messagebox.show("Map dimensions are too small. Must be at least 40x30 tiles"); return;
				}else if (w != Main.mapeditor.mapcreator.gridwidth || h != Main.mapeditor.mapcreator.gridheight) {
					Main.mapeditor.mapcreator.mapresizer.resizeMap(w, h, true);
				}
				if (minutetextfield.text == "") {
					Main.messagebox.show("You must not leave the minute timer blank"); return;
				}else if (int(secondtextfield.text) <= 0 && minutetextfield.text == "") {
					Main.messagebox.show("The second timer must be greater than 0"); return;
				}else if (int(secondtextfield.text) == 0 && int(minutetextfield.text) == 0) {
					Main.messagebox.show("The minute and second times must not both be 0"); return;
				}
				
				//save variables
				mapname = mapnameinput.text;
				mapdescription = mapdescriptioninput.text;
				maptags = maptagsinput.text;
				minuteinterval = int(minutetextfield.text);
				secondinterval = int(secondtextfield.text);
				goalitembox.lastvaliditem = goalitembox.lastselecteditem;
				musicitembox.lastvaliditem = musicitembox.lastselecteditem;
				Main.mapmanager.songid = musicitembox.lastselecteditem;
				
				if (publish) {
					if (mapname == "") { Main.messagebox.show("Map name must not be empty"); return;
					}else if (mapdescription == "") { Main.messagebox.show("Map description must not be empty"); return;
					}else if (mapdescription.length <= 4) { Main.messagebox.show("Description must be longer than 4 characters"); return;
					}else if (mapname.length <= 4) { Main.messagebox.show("Map name must be longer than 4 characters"); return;
					}else if (maptags.length == 0) { Main.messagebox.show("Are you sure you want to publish without any tags?", 2, -1, -1, "No", "Yes", 
					null, Main.mapmanager.publishmap); return; }
					Main.mapmanager.publishmap();
				}
			}
			
			if (settingsapplybutton && settingsapplybutton.stage && settingspublishbutton.stage) {
				settingscancelbutton.removelisteners();
				settingsapplybutton.removelisteners();
				settingspublishbutton.removelisteners();
				settingswindow.removeChild(settingsbox);
				settingswindow.removeChild(settingscancelbutton);
				settingswindow.removeChild(settingsapplybutton);
				settingswindow.removeChild(settingspublishbutton);
				Main.universe.removeChild(settingswindow);
				Main.mapeditor.ui.pausewindow.visible = false;
				settingswindow.removeChild(goalitembox);
				settingswindow.removeChild(goalcontainer);
				goalcontainer.removeChild(minutetextfield);
				goalcontainer.removeChild(secondtextfield);
				goalcontainer.removeChild(minutetitle);
				goalcontainer.removeChild(secondtitle);
				goalitembox.clear();
				settingswindow.removeChild(musicitembox);
				settingswindow.removeChild(musictitle);
				musicitembox.clear();
				showingsettings = false;
				settingswindow = null;
				settingsbox = null;
				settingscancelbutton = null;
				settingsapplybutton = null;
				settingspublishbutton = null;
				mapnametitle = null;
				mapnameinput = null;
				mapsizetitle = null;
				mapsizeinputwidth = null;
				mapsizeinputheight = null;
				mapdescriptiontitle = null;
				mapdescriptioninput = null;
				maptagstitle = null;
				maptagsinput = null;
				goaltitle = null;
				minutetitle = null;
				secondtitle = null;
				Main.mapeditor.ui.tooltip.tileinfobox.visible = true;
				Main.mapeditor.mapcreator.tileplacer.visible = true;
				if (!save) { goalitembox.selecteditem = goalitembox.lastvaliditem; musicitembox.selecteditem = musicitembox.lastvaliditem; }
				Main.universe.focus = null;
			}
		}
	}
}