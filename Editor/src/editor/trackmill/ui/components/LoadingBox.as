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
	import editor.trackmill.com.tools.animation.AnimateControl;
	import editor.trackmill.com.tools.animation.Animation;
	
	/**
	 * ...
	 * @author Richman Stewart
	 */
	public class LoadingBox extends Sprite {
		
		//messagebox variables
		public var base:Bitmap;
		public var title:TextField = new TextField();
		public var bgfadedscreen:Shape = new Shape();
		private var playanimation:Boolean = false;
		public var windowcontainer:Sprite = new Sprite();
		private var basecontainer:Sprite = new Sprite();
		private var scalenum:Number = .1;
		private var spinningcircle:Bitmap;
		private var animation:AnimateControl;
		public var titleformat:TextFormat;
		
		public function LoadingBox():void {
			bgfadedscreen.graphics.beginFill(0x000000, .8);
			bgfadedscreen.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			windowcontainer.addChild(bgfadedscreen);
			bgfadedscreen.x = -(Main.halfwidth); bgfadedscreen.y = -(Main.halfheight);
			UIManager.parent.addChild(windowcontainer);
			windowcontainer.x = Main.halfwidth; windowcontainer.y = Main.halfheight;
			
			base = new Bitmap(Assets.loadingbox);
			basecontainer.addChild(base);
			
			spinningcircle = new Bitmap(Assets.spinningcircle[0]);
			animation = UIManager.animation.create(spinningcircle, Assets.spinningcircle, 5, false);
			basecontainer.addChild(spinningcircle);
			
			titleformat = new TextFormat();
			titleformat.size = 14;
			titleformat.align = "left";
			titleformat.font = "square";
			title.defaultTextFormat = titleformat;
			title.embedFonts = true; title.multiline = false; title.wordWrap = false; title.selectable = false;
			title.textColor = 0x00FF00;
			basecontainer.addChild(title);
			
			basecontainer.x = -base.width / 2; basecontainer.y = -base.height / 2;
			
			addChild(basecontainer);
			
			hide(false);
		}
		
		public function show(titlemessage:String = "", animation:Boolean = true, size:int = 14):void {
			playanimation = true; scaleX = 0; scaleY = 0; windowcontainer.scaleX = 0; windowcontainer.scaleY = 0; scalenum = .2;
			bgfadedscreen.width = Main.universe.stageWidth; bgfadedscreen.height = Main.universe.stageHeight;
			
			x = Main.halfwidth + (Assets.loadingbox.width - base.width) / 2;
			y = Main.halfheight + (Assets.loadingbox.height - base.height) / 2;
			
			titleformat.size = size;
			title.defaultTextFormat = titleformat;
			title.width = base.width - 40; title.height = 20; title.x = 35; title.y = 2; title.text = titlemessage;
			visible = true; bgfadedscreen.visible = true;
			spinningcircle.x = (base.width / 2) - (spinningcircle.width / 2); spinningcircle.y = 40;
			
			playanimation = animation;
			addEventListener(Event.ENTER_FRAME, update);
			
			UIManager.parent.addChild(this);
			UIManager.parent.setChildIndex(windowcontainer, UIManager.parent.numChildren - 1);
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
			animation.update();
			if (playanimation) {
				scaleX += scalenum; scaleY += scalenum;
				windowcontainer.scaleX += scalenum * 2; windowcontainer.scaleY += scalenum * 2;
				if (scalenum > 0 && scaleX >= 1 || scalenum < 0 && scaleX <= 0) {
					playanimation = false;
					if (scalenum < 0) { visible = false; bgfadedscreen.visible = false; removeEventListener(Event.ENTER_FRAME, update); }
				}
				if (scalenum > 0 && scaleX >= 1) { windowcontainer.scaleX = 1; windowcontainer.scaleY = 1; scaleX = 1; scaleY = 1;
				}else if (scalenum < 0 && windowcontainer.scaleX <= 0) { windowcontainer.scaleX = 0; windowcontainer.scaleY = 0; }
			}
		}
	}
}