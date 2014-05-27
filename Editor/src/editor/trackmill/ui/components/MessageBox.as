package  editor.trackmill.ui.components {
	
	import editor.trackmill.ui.Assets;
	import editor.trackmill.ui.UIManager;
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
		public var title:TextField = new TextField();
		private var button1:Button;
		private var button2:Button;
		public var bgfadedscreen:Shape = new Shape();
		private var playanimation:Boolean = false;
		public var windowcontainer:Sprite = new Sprite();
		private var basecontainer:Sprite = new Sprite();
		private var scalenum:Number = .1;
		public var buttonamount:int = 0;
		
		public function MessageBox():void {
			bgfadedscreen.graphics.beginFill(0x000000, .8);
			bgfadedscreen.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			windowcontainer.addChild(bgfadedscreen);
			bgfadedscreen.x = -(Main.halfwidth); bgfadedscreen.y = -(Main.halfheight);
			UIManager.parent.addChild(windowcontainer);
			windowcontainer.x = Main.halfwidth; windowcontainer.y = Main.halfheight;
			
			base = new Bitmap(Assets.loginmessage);
			basecontainer.addChild(base);
			
			var format:TextFormat = new TextFormat();
			format.size = 14;
			format.align = "center";
			format.font = "square";
			info.defaultTextFormat = format;
			info.embedFonts = true; info.multiline = true; info.wordWrap = true; info.selectable = false;
			info.textColor = 0x4966DA;
			basecontainer.addChild(info);
			
			var titleformat:TextFormat = new TextFormat();
			titleformat.size = 14;
			titleformat.align = "left";
			titleformat.font = "square";
			title.defaultTextFormat = titleformat;
			title.embedFonts = true; title.multiline = false; title.wordWrap = false; title.selectable = false;
			title.textColor = 0x00FF00;
			basecontainer.addChild(title);
			
			button1 = new Button("Okay", 165, 85, 15, hide);
			basecontainer.addChild(button1);
			
			button2 = new Button("Cancel", 235, 85, 15, hide);
			basecontainer.addChild(button2);
			
			basecontainer.x = -base.width / 2; basecontainer.y = -base.height / 2;
			
			addChild(basecontainer);
			
			hide(false);
		}
		
		public function show(message:String = "", titlemessage:String = "", animation:Boolean = true, buttons:int = 1, 
		b1text:String = "Ok", b2text:String = "", button1call:Function = null, button2call:Function = null):void {
			buttonamount = buttons;
			UIManager.loadingbox.hide(); hide(false);
			if (button1call == null) { button1call = hide; } if (button2call == null) { button2call = hide; }
			UIManager.parent.setChildIndex(windowcontainer, UIManager.parent.numChildren - 1);
			if (animation) { scaleX = 0; scaleY = 0; windowcontainer.scaleX = 0; windowcontainer.scaleY = 0; scalenum = .2; }
			bgfadedscreen.width = Main.universe.stageWidth; bgfadedscreen.height = Main.universe.stageHeight;
			
			button1.message.text = b1text; button1.clickfunc = button1call; button2.message.text = b2text; button2.clickfunc = button2call;
			
			x = Main.halfwidth + (Assets.loginmessage.width - base.width) / 2;
			y = Main.halfheight + (Assets.loginmessage.height - base.height) / 2;
			button1.y = base.height - 28; button2.y = base.height - 28;
			
			title.width = base.width - 40; title.height = 20; title.x = 35; title.y = 2; title.text = titlemessage;
			info.width = base.width - 10; info.height = base.height - 10; info.htmlText = message;
			info.x = 10; info.y = 40;
			button1.visible = true; visible = true; bgfadedscreen.visible = true;
			
			if (buttons == 1) { button2.visible = false; button1.x = 220;
			}else if (buttons == 2) { button2.visible = true; button1.x = 140; button2.x = 220;
			}else if (buttons == 0) { button1.visible = false; button2.visible = false; }
			
			playanimation = animation;
			
			addEventListener(Event.ENTER_FRAME, update);
			UIManager.parent.addChild(this);
			UIManager.parent.setChildIndex(this, UIManager.parent.numChildren - 1);
		}
		
		public function hide(animation:Boolean = true):void {
			playanimation = animation;
			if (!animation) { visible = false; bgfadedscreen.visible = false; if (stage) { UIManager.parent.removeChild(this); } return; }
			if (visible) {
				addEventListener(Event.ENTER_FRAME, update);
				playanimation = true; scaleX = 1; scaleY = 1; windowcontainer.scaleX = 1; windowcontainer.scaleY = 1; scalenum = -.2;
			}
		}
		
		public function update(event:Event):void {
			if (playanimation) {
				scaleX += scalenum; scaleY += scalenum;
				windowcontainer.scaleX += scalenum * 2; windowcontainer.scaleY += scalenum * 2;
				if (scalenum > 0 && scaleX >= 1 || scalenum < 0 && scaleX <= 0) {
					playanimation = false;
					if (scalenum < 0) { visible = false; bgfadedscreen.visible = false; removeEventListener(Event.ENTER_FRAME, update);
					UIManager.parent.removeChild(this); }
				}
				if (scalenum > 0 && scaleX >= 1) { windowcontainer.scaleX = 1; windowcontainer.scaleY = 1;
				removeEventListener(Event.ENTER_FRAME, update); scaleX = 1; scaleY = 1;
				}else if (scalenum < 0 && windowcontainer.scaleX <= 0) { windowcontainer.scaleX = 0; windowcontainer.scaleY = 0; }
			}
		}
	}
}