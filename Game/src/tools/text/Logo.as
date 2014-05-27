package tools.text {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Logo extends Sprite {
		
		//logo variables
		public var base:Bitmap;
		public var url:String = "http://www.trackmill.com";
		
		public function Logo(posx:int = 0, posy:int = 0):void {
			base = new Bitmap(Preloader.logo);
			addChild(base);
			addEventListener(MouseEvent.CLICK, logoclick);
			addEventListener(MouseEvent.MOUSE_OVER, logomouseover);
			addEventListener(MouseEvent.MOUSE_OUT, logomouseout);
			x = posx; y = posy;
		}
		
		private function logoclick(event:MouseEvent):void {
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request, "_blank");
		}
		
		private function logomouseover(event:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
		}
		
		private function logomouseout(event:MouseEvent):void {
			Mouse.cursor = MouseCursor.ARROW;
		}
		
		public function remove():void {
			removeChild(base);
			removeEventListener(MouseEvent.MOUSE_OVER, logomouseover);
			removeEventListener(MouseEvent.MOUSE_OUT, logomouseout);
			parent.removeChild(this);
		}
	}
}