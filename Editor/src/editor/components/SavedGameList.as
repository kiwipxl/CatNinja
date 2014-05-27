package editor.components {
	
	import editor.trackmill.ui.UIManager;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import maps.MapDetails;
	import ui.Button;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class SavedGameList extends Sprite {
		
		//savedgamelist variables
		public var backgroundbox:Bitmap = new Bitmap();
		public var background:Shape = new Shape();
		private var colourtransform:ColorTransform = new ColorTransform();
		public var gamesboxcontainer:Sprite = new Sprite();
		private var colour:int;
		private var ctransform:ColorTransform;
		public var gameboxes:Vector.<SavedGameBox> = new Vector.<SavedGameBox>;
		private var backbutton:Button;
		private var savebutton:Button;
		private var loadbutton:Button;
		private var clearbutton:Button;
		public var selectedboxid:int = -1;
		
		//scroller variables
		private var scrollable:Boolean = false;
		private var scrolling:Boolean = false;
		private var desty:int = 0;
		private var rows:int = 0;
		private var scrollerbar:Shape = new Shape();
		private var scrollerbutton:Sprite = new Sprite();
		private var boxmask:Sprite;
		
		public function create():void {
			backgroundbox = new Bitmap(Main.textures.alltiles);
			Main.mapeditor.ui.pausewindow.visible = true;
			addChild(backgroundbox);
			backgroundbox.width = 560;
			backgroundbox.height = 460;
			backgroundbox.x = Main.halfwidth - (backgroundbox.width / 2);
			backgroundbox.y = Main.halfheight - (backgroundbox.height / 2);
			
			background.graphics.clear();
			background.graphics.beginBitmapFill(Main.textures.simplebackground);
			background.graphics.drawRect(0, 0, 520, 420);
			background.x = Main.halfwidth - (background.width / 2);
			background.y = Main.halfheight - (background.height / 2);
			colourtransform.redMultiplier = 1 + Math.random() * .5;
			colourtransform.greenMultiplier = 1 + Math.random() * .5;
			colourtransform.blueMultiplier = 1 + Math.random() * .5;
			var r:int = (colourtransform.redMultiplier - .5) * 510;
			var g:int = (colourtransform.greenMultiplier - .5) * 510;
			var b:int = (colourtransform.blueMultiplier - .5) * 510;
			colour = r << 16 | g << 8 | b;
			background.filters = [new GlowFilter(colour, 1, 4, 4, 8, 2, false, false), new BlurFilter(4, 4, 2)];
			background.transform.colorTransform = colourtransform;
			ctransform = colourtransform;
			addChild(background);
			background.alpha = .8;
			
			clearbutton = new Button("Clear", background.x + 10, background.y + 10, 1, cleargames, 15);
			addChild(clearbutton);
			backbutton = new Button("Back", background.x + 10, background.y + background.height - 32, 1, hide, 15);
			addChild(backbutton);
			savebutton = new Button("Remove", background.x + background.width - 80, background.y + 5, 1, removemap, 15);
			addChild(savebutton);
			loadbutton = new Button("Load", background.x + background.width - 80, background.y + background.height - 32, 1, loadmap, 15);
			addChild(loadbutton);
			
			Main.mapeditor.ui.settingswindow.showingsettings = true;
			Main.universe.addChild(this);
			
			loadgames();
		}
		
		public function cleargames():void {
			if (scrolling) { return; }
			
			Main.messagebox.show("<font color='#FCA0CA'>Are you sure you want to clear all saves? This action is irreversible</font>", 
			2, -1, -1, "Do it", "No", function():void {
				selectedboxid = -1;
				Main.mapeditor.savedmaps.length = 0;
				Main.mapeditor.mapid = 1;
				Main.mapeditor.sharedobject.data.maps = null;
				Main.mapeditor.sharedobject.flush();
				Main.messagebox.hide();
				cleargameboxes();
				removescroller();
			});
		}
		
		private function removemap():void {
			if (scrolling) { return; }
			
			if (selectedboxid == -1) {
				Main.messagebox.show("Please select a map to remove");
				return;
			}
			
			Main.messagebox.show("<font color='#FCA0CA'>Are you sure you want to remove all contents of map: " +
			gameboxes[selectedboxid].nametext.text + "</font>", 2, -1, -1, "Remove", "No way", function():void {
				Main.messagebox.hide();
				if (Main.mapeditor.savedmaps.length >= 1 && gameboxes.length >= 1) {
					Main.mapeditor.savedmaps[(selectedboxid * 3)].length = 0;
					Main.mapeditor.savedmaps[(selectedboxid * 3) + 1] = "";
					Main.mapeditor.savedmaps[(selectedboxid * 3) + 2] = "";
					Main.mapeditor.savedmaps.splice(selectedboxid * 3, 3);
					gameboxes[selectedboxid].removelisteners();
					gamesboxcontainer.removeChild(gameboxes[selectedboxid]);
					gameboxes[selectedboxid] = null;
					gameboxes.splice(selectedboxid, 1);
					loadgames();
					selectedboxid = -1;
				}
			}, null);
		}
		
		private function loadmap():void {
			if (scrolling) { return; }
			
			Main.messagebox.show("<font color='#FCA0CA'>This action will load a new map and erase all unfinished " +
			"data if not saved. Are you sure you want to do this?</font>", 2, -1, -1, "Load!", "No way", function():void {
				Main.messagebox.hide();
				if (selectedboxid == -1) {
					Main.messagebox.show("Please select a map to load");
					return;
				}
				
				Main.transition.show(function():void {
					gameboxes[selectedboxid].creategame();
				});
			}, null);
		}
		
		public function cleargameboxes():void {
			for (var n:int = 0; n < gameboxes.length; ++n) {
				gameboxes[n].removelisteners();
				gamesboxcontainer.removeChild(gameboxes[n]);
				gameboxes[n] = null;
			}
			gameboxes.length = 0;
		}
		
		public function loadgames():void {
			cleargameboxes();
			
			var rowx:int = 0; var rowy:int = 0;
			for (var n:int = 0; n < Main.mapeditor.savedmaps.length; n += 3) {
				createitem(n / 3, rowx, rowy, Main.mapeditor.savedmaps[n], Main.mapeditor.savedmaps[n + 1], Main.mapeditor.savedmaps[n + 2]);
				rowx += 80;
				if (rowx >= 400) { rowx = 0; rowy += 100; }
			}
			addChild(gamesboxcontainer);
			gamesboxcontainer.x = background.x + 50;
			gamesboxcontainer.y = background.y + 50;
			
			if (Main.mapeditor.savedmaps.length / 3 >= 16 && stage) {
				removescroller();
				scrollable = true;
				scrollerbar.graphics.lineStyle(1, 0xD329E7);
				scrollerbar.graphics.beginFill(0xE696F1, .6);
				scrollerbar.graphics.drawRect(0, 0, 15, 320);
				addChild(scrollerbar);
				scrollerbar.x = background.width + 95;
				scrollerbar.y = background.y + 45;
				
				scrollerbutton.graphics.lineStyle(1, 0xD329E7);
				scrollerbutton.graphics.beginFill(0xE696F1);
				scrollerbutton.graphics.drawRect(0, 0, 25, 20);
				addChild(scrollerbutton);
				scrollerbutton.x = background.width + 90;
				scrollerbutton.y = background.y + 45;
				
				setChildIndex(scrollerbar, 2);
				setChildIndex(scrollerbutton, 3);
				
				scrollerbutton.mouseChildren = true;
				Main.universe.addEventListener(MouseEvent.MOUSE_DOWN, scrollermousedown);
				Main.universe.addEventListener(MouseEvent.MOUSE_UP, scrollermouseup);
				addEventListener(Event.ENTER_FRAME, update);
				desty = background.y + 45;
				
				boxmask = new Sprite();
				boxmask.graphics.lineStyle(1, 0x5A0C5D);
				boxmask.graphics.beginFill(0x88198C, .4);
				boxmask.graphics.drawRect(0, 0, gamesboxcontainer.width + 100, 320);
				addChild(boxmask);
				boxmask.x = gamesboxcontainer.x - 50;
				boxmask.y = gamesboxcontainer.y;
				gamesboxcontainer.mask = boxmask
				
				rows = Math.ceil((gameboxes.length - 15) / 5);
			}else {
				removescroller();
			}
		}
		
		private function update(event:Event):void {
			if (scrolling) {
				desty = Main.universe.mouseY;
				if (desty <= background.y + 45) { desty = background.y + 45; }
				if (desty >= background.y + 25 + scrollerbar.height) { desty = background.y + 25 + scrollerbar.height; }
			}
			scrollerbutton.y -= (scrollerbutton.y - desty) / 4;
			
			var boxy:int = (background.y + 50) - (301 - ((background.y + 25 + scrollerbar.height) - desty)) * (rows * (1 / 3));
			gamesboxcontainer.y = boxy;
		}
		
		private function scrollermousedown(event:MouseEvent):void {
			if (scrollerbar.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY) || scrollerbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				scrolling = true;
			}
		}
		
		private function scrollermouseup(event:MouseEvent):void {
			scrolling = false;
		}
		
		private function createitem(id:int, x:int, y:int, settings:Array, screenshot:String, leveldata:String):void {
			var box:SavedGameBox = new SavedGameBox(id, colour, ctransform, settings[1], settings[0], settings[2], settings[3], screenshot, leveldata, settings[4]);
			box.x = x; box.y = y;
			gamesboxcontainer.addChild(box);
			gameboxes.push(box);
		}
		
		public function removescroller():void {
			if (scrollable) {
				scrollable = false;
				scrollerbar.graphics.clear();
				removeChild(scrollerbar);
				scrollerbutton.graphics.clear();
				removeChild(scrollerbutton);
				removeChild(boxmask);
				Main.universe.removeEventListener(MouseEvent.MOUSE_DOWN, scrollermousedown);
				Main.universe.removeEventListener(MouseEvent.MOUSE_UP, scrollermouseup);
				removeEventListener(Event.ENTER_FRAME, update);
				gamesboxcontainer.mask = null;
				boxmask.graphics.clear();
				boxmask = null;
			}
		}
		
		public function hide():void {
			if (scrolling) { return; }
			
			removescroller();
			cleargameboxes();
			gameboxes.length = 0;
			
			background.graphics.clear();
			Main.mapeditor.ui.pausewindow.visible = false;
			removeChild(background);
			removeChild(backgroundbox);
			removeChild(gamesboxcontainer);
			clearbutton.removelisteners(); removeChild(clearbutton); clearbutton = null;
			backbutton.removelisteners(); removeChild(backbutton); backbutton = null;
			savebutton.removelisteners(); removeChild(savebutton); savebutton = null;
			loadbutton.removelisteners(); removeChild(loadbutton); loadbutton= null;
			Main.universe.removeChild(this);
			
			Main.universe.focus = null;
			Main.mapeditor.ui.settingswindow.showingsettings = false;
		}
	}
}