package editor.trackmill.ui.components {
	
	import editor.trackmill.ui.Assets;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Richman Stewart
	 */
	public class Button extends Sprite {
		
		//button variables
		public var button:Bitmap;
		public var message:TextField = new TextField();
		public var clickfunc:Function;
		private var originalcolour:ColorTransform;
		private var highlightcolour:ColorTransform;
		
		public function Button(msg:String, posx:int, posy:int, size:int = 40, clickcall:Function = null, r:Number = 1, g:Number = 1, b:Number = 1.5) {
			button = new Bitmap(Assets.loginbutton);
			highlightcolour = new ColorTransform(1.8, 1.2, 1);
			originalcolour = new ColorTransform(r, g, b);
			button.transform.colorTransform = originalcolour;
			addChild(button);
			
			x = posx; y = posy;
			var format:TextFormat = new TextFormat();
			format.font = "square"; format.align = "center"; format.size = size;
			message.embedFonts = true;
			message.defaultTextFormat = format;
			message.textColor = 0xFFFFFF;
			message.width = button.width; message.height = button.height;
			message.x = 0; message.y = (button.height / 2) - ((message.textHeight + size) / 2);
			message.selectable = false; message.multiline = true; message.wordWrap = true;
			message.text = msg;
			addChild(message);
			
			clickfunc = clickcall;
			
			addEventListener(MouseEvent.MOUSE_UP, click);
			addEventListener(MouseEvent.MOUSE_OVER, mouseover);
			addEventListener(MouseEvent.MOUSE_OUT, mouseout);
		}
		
		private function click(event:MouseEvent):void {
			if (stage) {
				if (this.hitTestPoint(stage.mouseX, stage.mouseY)) {
					Main.sound.playsfx(15); if (clickfunc != null) { clickfunc(); }
				}
			}
		}
		
		public function removelisteners():void {
			removeEventListener(MouseEvent.CLICK, click);
			removeEventListener(MouseEvent.MOUSE_OVER, mouseover);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseout);
		}
		
		private function mouseover(event:MouseEvent):void {
			button.transform.colorTransform = highlightcolour;
		}
		
		private function mouseout(event:MouseEvent):void {
			button.transform.colorTransform = originalcolour;
		}
	}
}