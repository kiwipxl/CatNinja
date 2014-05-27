package ui {
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Richman Stewart
	 */
	public class MessageBox extends Sprite {
		
		//messagebox variables
		public var base:Bitmap;
		public var info:TextField = new TextField();
		private var okbutton:Button;
		private var button2:Button;
		public var pausewindow:Shape = new Shape();
		private var playanimation:Boolean = false;
		public var windowcontainer:Sprite = new Sprite();
		private var basecontainer:Sprite = new Sprite();
		private var scalenum:Number = .1;
		public var buttonamount:int = 0;
		
		public function MessageBox():void {
			pausewindow.graphics.beginFill(0x000000, .8);
			pausewindow.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			windowcontainer.addChild(pausewindow);
			pausewindow.x = -Main.halfwidth; pausewindow.y = -Main.halfheight;
			Main.universe.addChild(windowcontainer);
			windowcontainer.x = Main.halfwidth; windowcontainer.y = Main.halfheight;
			
			base = new Bitmap(Main.textures.messagebox);
			basecontainer.addChild(base);
			
			var format:TextFormat = new TextFormat();
			format.size = 14;
			format.align = "center";
			format.font = "square";
			info.defaultTextFormat = format;
			info.embedFonts = true;
			info.width = 240;
			info.height = 80;
			info.x = 5;
			info.y = 10;
			info.multiline = true;
			info.wordWrap = true;
			info.selectable = false;
			info.textColor = 0xFFFFFF;
			basecontainer.addChild(info);
			
			okbutton = new Button("Okay", 165, 85, 1, hide, 15);
			okbutton.start();
			basecontainer.addChild(okbutton);
			
			button2 = new Button("Cancel", 235, 85, 1, hide, 15);
			button2.start();
			basecontainer.addChild(button2);
			
			basecontainer.x = -base.width / 2; basecontainer.y = -base.height / 2;
			x = base.width / 2; y = base.width / 2;
			
			Main.universe.addChild(this);
			addChild(basecontainer);
			
			x = 275;
			y = 240;
			
			hide(false);
		}
		
		public function show(text:String = "", buttons:int = 1, boxwidth:int = -1, boxheight:int = -1, button1text:String = "Ok", button2text:String = "",
									   button1call:Function = null, button2call:Function = null, animation:Boolean = true):void {
			if (button1call == null) { button1call = Main.messagebox.hide; }
			if (button2call == null) { button2call = Main.messagebox.hide; }
			okbutton.visible = true;
			buttonamount = buttons;
			Main.universe.setChildIndex(windowcontainer, Main.universe.numChildren - 1);
			playanimation = true; scaleX = 0; scaleY = 0; windowcontainer.scaleX = 0; windowcontainer.scaleY = 0; scalenum = .2;
			pausewindow.width = Main.universe.stageWidth; pausewindow.height = Main.universe.stageHeight;
			
			okbutton.message.text = button1text;
			okbutton.clickfunc = button1call;
			button2.message.text = button2text;
			button2.clickfunc = button2call;
			
			if (boxwidth == -1) { boxwidth = Main.textures.messagebox.width; }
			if (boxheight == -1) { boxheight = Main.textures.messagebox.height; }
			base.width = boxwidth; base.height = boxheight;
			
			x = Main.halfwidth + (Main.textures.messagebox.width - boxwidth) / 2;
			y = Main.halfheight + (Main.textures.messagebox.height - boxheight) / 2;
			okbutton.y = base.height - 35;
			button2.y = base.height - 35;
			
			info.width = boxwidth - 10;
			info.height = boxheight - 10;
			info.htmlText = text;
			visible = true;
			pausewindow.visible = true;
			
			if (buttons == 1) { button2.visible = false; okbutton.x = 170;
			}else if (buttons == 2) { button2.visible = true; okbutton.x = 90; button2.x = 170;
			}else if (buttons == 0) { okbutton.visible = false; button2.visible = false; }
			
			Main.universe.setChildIndex(this, Main.universe.numChildren - 1);
			
			if (!animation) {
				playanimation = false; visible = true; pausewindow.visible = true; scaleX = 1; scaleY = 1; windowcontainer.scaleX = 1; windowcontainer.scaleY = 1;
			}
		}
		
		public function hide(animation:Boolean = true):void {
			if (!animation) { playanimation = false; visible = false; pausewindow.visible = false; return; }
			if (visible) {
				playanimation = true; scaleX = 1; scaleY = 1; windowcontainer.scaleX = 1; windowcontainer.scaleY = 1; scalenum = -.2;
			}
		}
		
		public function update(event:Event = null):void {
			if (playanimation) {
				scaleX += scalenum; scaleY += scalenum;
				windowcontainer.scaleX += scalenum * 2; windowcontainer.scaleY += scalenum * 2;
				if (scalenum > 0 && scaleX >= 1 || scalenum < 0 && scaleX <= 0) {
					playanimation = false;
					if (scalenum < 0) { visible = false; pausewindow.visible = false; }
				}
				if (scalenum > 0 && windowcontainer.scaleX >= 1) { windowcontainer.scaleX = 1; windowcontainer.scaleY = 1;
				}else if (scalenum < 0 && windowcontainer.scaleX <= 0) { windowcontainer.scaleX = 0; windowcontainer.scaleY = 0; }
			}
		}
	}
}