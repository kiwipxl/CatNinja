package editor.trackmill.ui {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import tools.images.PixelModifier;
	
	/**
	 * ...
	 * @author Richman Stewart
	 */
	public class Assets {
		
		//asset variables
		[Embed(source = "../../../../lib/trackmill/button.png")]
		private static const loginbuttonclass:Class;
		private static const loginbuttondata:Bitmap = new loginbuttonclass();
		public static const loginbutton:BitmapData = loginbuttondata.bitmapData;
		
		[Embed(source = "../../../../lib/trackmill/loginscreen.png")]
		private static const loginscreenclass:Class;
		private static const loginscreendata:Bitmap = new loginscreenclass();
		public static const loginscreen:BitmapData = loginscreendata.bitmapData;
		
		[Embed(source = "../../../../lib/trackmill/messagebox.png")]
		private static const loginmessageboxclass:Class;
		private static const loginmessageboxdata:Bitmap = new loginmessageboxclass();
		public static const loginmessage:BitmapData = loginmessageboxdata.bitmapData;
		
		[Embed(source = "../../../../lib/trackmill/spinningcircle.png")]
		private static const spinningcircleclass:Class;
		private static const spinningcircledata:Bitmap = new spinningcircleclass();
		public static var spinningcircle:Array;
		
		[Embed(source = "../../../../lib/trackmill/loadingbox.png")]
		private static const loadingboxclass:Class;
		private static const loadingboxdata:Bitmap = new loadingboxclass();
		public static const loadingbox:BitmapData = loadingboxdata.bitmapData;
		
		public static function initiate():void {
			spinningcircle = PixelModifier.cutSheet(spinningcircledata.bitmapData, 32, 32);
		}
	}
}