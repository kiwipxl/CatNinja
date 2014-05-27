package ui {
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Richman Stewart
	 */
	public class Button extends Sprite {
		
		//button variables
		public var button:Bitmap;
		public var message:TextField = new TextField();
		private var hoverspot:Shape = new Shape();
		private var clickfunc:Function;
		private var p:DisplayObject;
		
		public function Button(msg:String, posx:int, posy:int, type:int = 0, clickcall:Function = null) {
			switch (type) {
				case 0:
					button = new Bitmap(Preloader.buttonbitmap.bitmapData);
					break;
				case 1:
					button = new Bitmap(Preloader.musicbutton);
					break;
				case 2:
					button = new Bitmap(Preloader.musicbuttonoff);
					break;
				case 3:
					button = new Bitmap(Preloader.soundbutton);
					break;
				case 4:
					button = new Bitmap(Preloader.soundbuttonoff);
					break;
				case 5:
					button = new Bitmap(Preloader.pausebuttonui);
					break;
				case 6:
					button = new Bitmap(Preloader.exitbutton);
					break;
			}
			addChild(button);
			
			hoverspot.graphics.lineStyle(1, 0x228BE1, .2);
			hoverspot.graphics.beginFill(0x228BE1, .2);
			hoverspot.graphics.drawRect(0, 0, button.bitmapData.width, button.bitmapData.height);
			addChild(hoverspot);
			hoverspot.visible = false;
			
			x = posx; y = posy;
			var format:TextFormat = new TextFormat();
			format.font = "square";
			format.align = "center";
			format.size = 40;
			message.embedFonts = true;
			message.defaultTextFormat = format;
			message.textColor = 0xFFFFFF;
			message.width = button.width;
			message.height = button.height / 2;
			message.x = 0;
			message.y = (button.height - 20) / 4;
			message.selectable = false;
			message.multiline = true;
			message.wordWrap = true;
			message.text = msg;
			addChild(message);
			
			clickfunc = clickcall;
		}
		
		public function start(par:DisplayObject = null):void {
			if (par == null) { p = stage; } else { p = par; }
			p.addEventListener(MouseEvent.MOUSE_UP, click);
			p.addEventListener(MouseEvent.MOUSE_OVER, mouseover);
			p.addEventListener(MouseEvent.MOUSE_OUT, mouseout);
		}
		
		private function click(event:MouseEvent):void {
			if (stage) {
				if (this.hitTestPoint(stage.mouseX, stage.mouseY)) {
					if (clickfunc != null) { clickfunc(); }
				}
			}
		}
		
		public function removelisteners():void {
			p.removeEventListener(MouseEvent.CLICK, click);
			p.removeEventListener(MouseEvent.MOUSE_OVER, mouseover);
			p.removeEventListener(MouseEvent.MOUSE_OUT, mouseout);
		}
		
		private function mouseover(event:MouseEvent):void {
			hoverspot.visible = true;
		}
		
		private function mouseout(event:MouseEvent):void {
			hoverspot.visible = false;
		}
	}
}