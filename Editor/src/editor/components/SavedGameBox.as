package editor.components {
	
	import editor.trackmill.ui.UIManager;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import maps.MapDetails;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class SavedGameBox extends Sprite {
		
		//savedgamebox variables
		public var mapid:int = 0;
		public var levelcode:String = "";
		public var boxid:int = 0;
		private var timemode:int;
		private var timeseconds:int;
		private var timeminutes:int;
		private var finishtiles:int;
		private var mapdescription:String;
		private var maptags:String;
		
		//ui variables
		private var thumbnail:Bitmap;
		public var nametext:TextField = new TextField();
		
		public function SavedGameBox(idbox:int, colour:int, colourtransform:ColorTransform, mapname:String, id:int, description:String, tags:String, 
		screenshot:String, data:String, d:Object):void {
			mapid = id;
			levelcode = data;
			boxid = idbox;
			mapdescription = description;
			maptags = tags;
			timemode = d.timemode;
			timeseconds = d.timeseconds;
			timeminutes = d.timeminutes;
			finishtiles = d.finishtiles;
			Main.mapeditor.decoder.decode(screenshot);
			var bytes:ByteArray = Main.mapeditor.decoder.toByteArray();
			bytes.position = 0;
			screenshot = "";
			
			var loader:Loader = new Loader();
			loader.loadBytes(bytes);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {
				var info:LoaderInfo = event.target.content.loaderInfo;
				var screenshotdata:BitmapData = new BitmapData(info.width, info.height, true, 0);
				screenshotdata.draw(info.loader);
				var border:BitmapData = Main.textures.savedgameborder;
				if (boxid == Main.mapeditor.ui.savedgamelist.selectedboxid) { border = Main.textures.savedgameborderselect; }
				screenshotdata.copyPixels(border, screenshotdata.rect, new Point(), null, null, true);
				
				thumbnail = new Bitmap(screenshotdata);
				thumbnail.scaleX = .5; thumbnail.scaleY = .5;
				thumbnail.x = 10;
				addChild(thumbnail);
				bytes.length = 0;
			});
			
			var format:TextFormat = new TextFormat();
			format.font = "square";
			format.align = "center";
			format.size = 14;
			nametext.embedFonts = true;
			nametext.defaultTextFormat = format;
			nametext.width = 80; nametext.height = 40;
			nametext.multiline = true; nametext.wordWrap = true; nametext.selectable = false;
			nametext.text = mapname;
			nametext.textColor = colour;
			nametext.filters = [new GlowFilter(0x000000, 1, 2, 2, 2, 2), new DropShadowFilter(2, 45, 0x5F5F5F, 1, 2, 2)];
			nametext.y = 65;
			addChild(nametext);
			
			addEventListener(MouseEvent.ROLL_OVER, zoominimage);
			addEventListener(MouseEvent.ROLL_OUT, zoomoutimage);
			addEventListener(MouseEvent.CLICK, clickbox);
			mouseChildren = true;
		}
		
		private function zoominimage(event:MouseEvent):void {
			if (thumbnail) {
				thumbnail.scaleX = 1; thumbnail.scaleY = 1;
				thumbnail.x = -(thumbnail.width / 4) + 10;
				thumbnail.y = -(thumbnail.height / 4) + 10;
				Main.mapeditor.ui.savedgamelist.gamesboxcontainer.setChildIndex(this, Main.mapeditor.ui.savedgamelist.gamesboxcontainer.numChildren - 1);
			}
		}
		
		private function zoomoutimage(event:MouseEvent):void {
			if (thumbnail) {
				thumbnail.scaleX = .5; thumbnail.scaleY = .5;
				thumbnail.x = 10; thumbnail.y = 0;
			}
		}
		
		private function clickbox(event:MouseEvent):void {
			if (Main.mapeditor.ui.savedgamelist.selectedboxid != -1) {
				Main.mapeditor.ui.savedgamelist.gameboxes[Main.mapeditor.ui.savedgamelist.selectedboxid].thumbnail.bitmapData.copyPixels(
				Main.textures.savedgameborder, thumbnail.bitmapData.rect, new Point(), null, null, true);
			}
			Main.mapeditor.ui.savedgamelist.selectedboxid = boxid;
			thumbnail.bitmapData.copyPixels(Main.textures.savedgameborderselect, thumbnail.bitmapData.rect, new Point(), null, null, true);
		}
		
		public function removelisteners():void {
			removeEventListener(MouseEvent.ROLL_OVER, zoominimage);
			removeEventListener(MouseEvent.ROLL_OUT, zoomoutimage);
			removeEventListener(MouseEvent.CLICK, clickbox);
		}
		
		public function creategame():void {
			Main.mapeditor.ui.savedgamelist.hide();
			Main.mapmanager.loadsavededitorgame(mapid, nametext.text, mapdescription, maptags, levelcode, 
			timemode, timeseconds, timeminutes, finishtiles);
		}
	}
}