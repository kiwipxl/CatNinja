package maps {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import ui.Button;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class MapDetails {
		
		//xmlmap variables
		public var width:int = 0;
		public var height:int = 0;
		public var backgroundtiles:Array = [];
		public var tiles:Array = [];
		public var timemode:int = 0;
		public var timeminutes:int = 0;
		public var timeseconds:int = 0;
		public var finishtiles:int = 0;
		public var drawingbytes:ByteArray;
		
		//room variables
		public var gridx:int = 0;
		public var gridy:int = 0;
		public var blank:Boolean = false;
		public var roombutton:Button;
		public var modified:Boolean = true;
		public var mapimage:BitmapData;
		public var mapimagedisplay:Bitmap;
		public var index:int = 1;
	}
}