package ui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
	public class Button extends Sprite {
		
		//button variables
		public var button:Bitmap;
		public var message:TextField = new TextField();
		public var centerimage:Bitmap;
		public var secondcenterimage:Bitmap;
		public var hoverspot:Shape = new Shape();
		public var clickfunc:Function;
		public var p:DisplayObject;
		
		public function Button(msg:String, posx:int, posy:int, type:int = 0, clickcall:Function = null, size:int = 40, bwidth:int = -1, image:BitmapData = null, 
		nobutton:Boolean = false, bheight:int = -1) {
			switch (type) {
				case 0:
					button = new Bitmap(Preloader.buttonbitmap.bitmapData);
					break;
				case 1:
					button = new Bitmap(Main.textures.smallbutton);
					break;
				case 2:
					button = new Bitmap(Preloader.musicbutton);
					break;
				case 3:
					button = new Bitmap(Preloader.musicbuttonoff);
					break;
				case 4:
					button = new Bitmap(Preloader.soundbutton);
					break;
				case 5:
					button = new Bitmap(Preloader.soundbuttonoff);
					break;
				case 6:
					button = new Bitmap(Preloader.pausebuttonui);
					break;
			}
			if (bwidth == -1) { bwidth = button.width; }
			if (bheight == -1) { bheight = button.height; }
			
			if (!nobutton) {
				button.width = bwidth;
				button.height = bheight;
				addChild(button);
			}
			
			hoverspot.graphics.lineStyle(1, 0x228BE1, .2);
			hoverspot.graphics.beginFill(0x228BE1, .2);
			hoverspot.graphics.drawRect(0, 0, bwidth, bheight);
			addChild(hoverspot);
			hoverspot.visible = false;
			
			x = posx; y = posy;
			if (!image) {
				var format:TextFormat = new TextFormat();
				format.font = "square";
				format.align = "center";
				format.size = size;
				message.embedFonts = true;
				message.defaultTextFormat = format;
				message.textColor = 0xFFFFFF;
				message.width = bwidth;
				message.height = button.height;
				message.x = 0;
				message.y = (button.height / 2) - ((message.textHeight + size) / 2);
				message.selectable = false;
				message.multiline = true;
				message.wordWrap = true;
				message.text = msg;
				addChild(message);
			}else {
				centerimage = new Bitmap(image);
				centerimage.x = (button.width / 2) - 10;
				centerimage.y = (button.height / 2) - 10;
				addChild(centerimage);
				
				if (nobutton) { centerimage.x = 0; centerimage.y = 0; setChildIndex(hoverspot, numChildren - 1); }
			}
			
			clickfunc = clickcall;
			start();
		}
		
		public function start():void {
			addEventListener(MouseEvent.MOUSE_UP, click);
			addEventListener(MouseEvent.MOUSE_OVER, mouseover);
			addEventListener(MouseEvent.MOUSE_OUT, mouseout);
		}
		
		private function click(event:MouseEvent):void {
			if (stage) {
				if (this.hitTestPoint(stage.mouseX, stage.mouseY)) {
					Main.sound.playsfx(15);
					if (clickfunc != null) { clickfunc(); }
				}
			}
		}
		
		public function removelisteners():void {
			removeEventListener(MouseEvent.CLICK, click);
			removeEventListener(MouseEvent.MOUSE_OVER, mouseover);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseout);
		}
		
		private function mouseover(event:MouseEvent):void {
			hoverspot.visible = true;
		}
		
		private function mouseout(event:MouseEvent):void {
			hoverspot.visible = false;
		}
	}
}