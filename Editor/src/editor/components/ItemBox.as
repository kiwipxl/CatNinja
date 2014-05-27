package editor.components {
	
	import editor.trackmill.ui.UIManager;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class ItemBox extends Sprite {
		
		//itembox variables
		public var items:Array = [];
		public var boxwidth:int;
		public var boxheight:int;
		public var expanded:Boolean = false;
		public var selecteditem:int = 0;
		public var selecteditemtext:String = "";
		private var firstitembox:Sprite;
		private var index:int = 0;
		private var listitems:Array = [];
		public var finishedmoving:Boolean = true;
		private var timer:int = 0;
		public var lastselecteditem:int = 0;
		private var ordereditems:Array = [];
		public var lastvaliditem:int = 0;
		
		public function create(itemlist:Array, w:int = 120, h:int = 20):void {
			boxwidth = w;
			boxheight = h;
			items = itemlist;
			ordereditems = itemlist.concat();
			finishedmoving = true;
			
			if (selecteditem != 0) {
				var temp:String = items[0];
				items[0] = items[selecteditem];
				items[selecteditem] = temp;
				selecteditem = 0;
			}
			
			selecteditemtext = items[selecteditem];
			createitem(items[selecteditem]);
			
			Main.universe.addEventListener(MouseEvent.MOUSE_DOWN, mousedown);
		}
		
		private function createitem(text:String, xpos:int = 0, ypos:int = 0):void {
			var w:int = boxwidth - 20;
			var box:Sprite = new Sprite();
			box.graphics.lineStyle(1, 0xF576F2);
			if (index == 0) { box.graphics.beginFill(0xFDE3FB);
			}else { box.graphics.beginFill(0xF79FEE); w += 20; }
			box.graphics.drawRect(0, 0, w, boxheight);
			if (index == 0) {
				box.graphics.beginFill(0xF7C5FE);
				box.graphics.drawRect(w + 1, 0, 20, boxheight);
				if (ordereditems[0] == "Count up") {
					Main.mapeditor.ui.settingswindow.goalcontainer.visible = true;
					if (text == "Hide timer" || text == "Count up") {
						Main.mapeditor.ui.settingswindow.goalcontainer.visible = false;
					}else if (text == "Collect amount") {
						Main.mapeditor.ui.settingswindow.minutetextfield.visible = false;
						Main.mapeditor.ui.settingswindow.minutetitle.visible = false;
						Main.mapeditor.ui.settingswindow.secondtitle.text = "Amnt:";
						Main.mapeditor.ui.settingswindow.secondtextfield.maxChars = 3;
					}else {
						Main.mapeditor.ui.settingswindow.minutetextfield.visible = true;
						Main.mapeditor.ui.settingswindow.minutetitle.visible = true;
						Main.mapeditor.ui.settingswindow.secondtitle.text = "Secs:";
						Main.mapeditor.ui.settingswindow.secondtextfield.maxChars = 2;
					}
					Main.mapeditor.ui.settingswindow.secondchangeupdate();
				}
			}
			box.x = xpos;
			box.y = ypos;
			addChild(box);
			listitems.push(box);
			
			var textfield:TextField = new TextField();
			textfield.width = w;
			textfield.height = boxheight;
			var format:TextFormat = new TextFormat();
			format.font = "square";
			format.align = "center";
			textfield.embedFonts = true;
			textfield.defaultTextFormat = format;
			textfield.text = text;
			textfield.y = 2;
			textfield.multiline = false;
			textfield.wordWrap = false;
			textfield.selectable = false;
			textfield.textColor = 0x600F68;
			box.addChild(textfield);
			
			if (text == selecteditemtext) { firstitembox = box; }
			setChildIndex(firstitembox, numChildren - 1);
			++index;
		}
		
		public function expand():void {
			if (!Main.mapeditor.ui.settingswindow.goalitembox.finishedmoving) { return; }
			
			expanded = true;
			if (!finishedmoving) { removeEventListener(Event.ENTER_FRAME, update); removedropdown(); }
			addEventListener(Event.ENTER_FRAME, update);
			finishedmoving = true;
			
			for (var n:int = 0; n < items.length; ++n) {
				if (selecteditemtext != items[n]) {
					createitem(items[n], 0, 0);
				}
			}
			setChildIndex(firstitembox, numChildren - 1);
		}
		
		public function collapse():void {
			expanded = false;
			finishedmoving = false;
			timer = 0;
			
			var i:int = 0; var text:String = "";
			for (var n:int = 1; n < listitems.length; ++n) {
				if (listitems[n].hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
					i = n;
					text = items[n];
					break;
				}
			}
			if (i != selecteditem) {
				selecteditemtext = text;
				removeChild(listitems[0]);
				listitems.splice(0, 1);
				
				var temp:String = items[0];
				items[0] = items[i];
				items[i] = temp;
				index = 0;
				
				createitem(selecteditemtext);
				
				var tempitem:Sprite = listitems[0];
				listitems[0] = listitems[listitems.length - 1];
				listitems[listitems.length - 1] = tempitem;
				
				for (var p:int = 0; p < ordereditems.length; ++p) {
					if (ordereditems[p] == selecteditemtext) {
						lastselecteditem = p;
						break;
					}
				}
				
				if (listitems.length >= 5) {
					if (!Main.sound.musiclist[lastselecteditem].isBuffering && Main.sound.musiclist[lastselecteditem].length == 0) {
						UIManager.loadingbox.show("Buffering " + selecteditemtext + "...");
						Main.sound.getsong(lastselecteditem, false, true);
					}else if (Main.sound.musiclist[lastselecteditem].length > 0) {
						Main.sound.musicchannel.stop();
						Main.sound.play(2 + lastselecteditem);
					}
				}
			}
			index = 1;
		}
		
		private function mousedown(event:MouseEvent):void {
			if (expanded) {
				collapse();
			}else if (this.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				expand();
			}
		}
		
		public function update(event:Event):void {
			for (var n:int = 1; n < listitems.length; ++n) {
				if (expanded) {
					listitems[n].y += ((n * 20) - listitems[n].y) / 2;
				}else {
					listitems[n].y += ( -listitems[n].y) / 2;
				}
			}
			
			if (!expanded) {
				++timer;
				if (timer >= 10) {
					timer = 0;
					removedropdown();
					finishedmoving = true;
					removeEventListener(Event.ENTER_FRAME, update);
				}
			}
		}
		
		public function removedropdown():void {
			for (var c:int = 1; c < listitems.length; ++c) {
				removeChild(listitems[c]);
				listitems.splice(c, 1);
				--c;
			}
			expanded = false;
		}
		
		public function clear():void {
			items.length = 0;
			listitems.length = 0;
			ordereditems.length = 0;
			index = 0;
			expanded = false;
			timer = 0;
			selecteditem = lastselecteditem;
			finishedmoving = false;
			if (!finishedmoving) { removeEventListener(Event.ENTER_FRAME, update); removedropdown(); }
			Main.universe.removeEventListener(MouseEvent.MOUSE_DOWN, mousedown);
		}
	}
}