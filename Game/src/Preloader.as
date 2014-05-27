package {
	
   import flash.display.Stage;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.ProgressEvent;
   import flash.filters.BevelFilter;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import tools.text.Logo;
   import ui.Button;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.utils.getDefinitionByName;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   
   public class Preloader extends MovieClip {
	   
	   [Embed(source = "../lib/fonts/square.ttf", embedAsCFF="false", fontName = "square")]
		public const squarefont:String;
		
		[Embed(source = "../lib/fonts/cubic.ttf", embedAsCFF="false", fontName = "cubic")]
		public const cubicfont:String;
		
		[Embed(source = "../lib/ui/preloaderscreen.png")]
		private const preloaderscreen:Class;
		private var preloaderscreenbitmap:Bitmap = new preloaderscreen();
		
		[Embed(source = "../lib/ui/button.png")]
		private static const button:Class;
		public static var buttonbitmap:Bitmap = new button();
		
		[Embed(source = "../lib/ui/musicbutton.png")]
		private const musicbuttonclass:Class;
		private const musicbuttondata:Bitmap = new musicbuttonclass();
		public static var musicbutton:BitmapData;
		
		[Embed(source = "../lib/ui/musicbuttonoff.png")]
		private const musicbuttonoffclass:Class;
		private const musicbuttonoffdata:Bitmap = new musicbuttonoffclass();
		public static var musicbuttonoff:BitmapData;
		
		[Embed(source = "../lib/ui/soundbutton.png")]
		private const soundbuttonclass:Class;
		private const soundbuttondata:Bitmap = new soundbuttonclass();
		public static var soundbutton:BitmapData;
		
		[Embed(source = "../lib/ui/soundbuttonoff.png")]
		private const soundbuttonoffclass:Class;
		private const soundbuttonoffdata:Bitmap = new soundbuttonoffclass();
		public static var soundbuttonoff:BitmapData;
		
		[Embed(source = "../lib/ui/pausebutton.png")]
		private const pausebuttonclass:Class;
		private const pausebuttondata:Bitmap = new pausebuttonclass();
		public static var pausebuttonui:BitmapData;

		[Embed(source = "../lib/ui/playbutton.png")]
		private const playbuttonclass:Class;
		private const playbuttondata:Bitmap = new playbuttonclass();
		public static var playbuttonui:BitmapData;
		
		[Embed(source = "../lib/ui/exitbutton.png")]
		private const exitbuttonclass:Class;
		private const exitbuttondata:Bitmap = new exitbuttonclass();
		public static var exitbutton:BitmapData;
		
		[Embed(source = "../lib/ui/logo.png")]
		private const logoclass:Class;
		private const logodata:Bitmap = new logoclass();
		public static var logo:BitmapData;
		private var logodisplay:Logo;
		
		[Embed(source = "../lib/ui/biglogo.png")]
		private const biglogoclass:Class;
		private const biglogodata:Bitmap = new biglogoclass();
		public static var biglogo:BitmapData;
		
		[Embed(source = "../lib/ui/smalllogo.png")]
		private const smalllogoclass:Class;
		private const smalllogodata:Bitmap = new smalllogoclass();
		public static var smalllogo:BitmapData;
		
		[Embed(source = "../lib/ui/createtrackmill.png")]
		private const createtrackmillclass:Class;
		private const createtrackmilldata:Bitmap = new createtrackmillclass();
		public static var createtrackmill:BitmapData;
		
		private var greybar:Shape;
		private var percentbar:Shape;
		private var playbutton:Button;
		private var info:TextField = new TextField();
		
		public function Preloader():void {
		  SoundMixer.soundTransform = new SoundTransform(1);
		  
		  if (stage) {
			stage.scaleMode = StageScaleMode.NO_SCALE;
		    stage.align = StageAlign.TOP_LEFT;
		  }
		  
		  addChild(preloaderscreenbitmap);
		  
		  musicbutton = musicbuttondata.bitmapData;
		  musicbuttonoff = musicbuttonoffdata.bitmapData;
		  soundbutton = soundbuttondata.bitmapData;
		  soundbuttonoff = soundbuttonoffdata.bitmapData;
		  pausebuttonui = pausebuttondata.bitmapData;
		  playbuttonui = playbuttondata.bitmapData;
		  exitbutton = exitbuttondata.bitmapData;
		  logo = logodata.bitmapData;
		  biglogo = biglogodata.bitmapData;
		  smalllogo = smalllogodata.bitmapData;
		  createtrackmill = createtrackmilldata.bitmapData;
		  
		  logodisplay = new Logo();
		  addChild(logodisplay);
		  
		  greybar = new Shape();
		  greybar.graphics.lineStyle(1, 0x999999, .5);
		  greybar.graphics.beginFill(0x999999, .2);
		  greybar.graphics.drawRect(0, 0, 650, 20);
		  greybar.x = 75; greybar.y = 420;
		  addChild(greybar);
		  
		  percentbar = new Shape();
		  percentbar.graphics.lineStyle(1, 0x9928E3, .6);
		  percentbar.graphics.beginFill(0x9928E3, .4);
		  percentbar.graphics.drawRect(0, 0, 650, 20);
		  percentbar.x = 75; percentbar.y = 420;
		  percentbar.scaleX = 0;
		  addChild(percentbar);
		  
		  var format:TextFormat = new TextFormat();
		  format.font = "cubic";
		  format.align = TextFormatAlign.CENTER;
		  format.size = 25;
		  info.embedFonts = true;
		  info.defaultTextFormat = format;
		  info.width = 800;
		  info.height = 40;
		  info.selectable = false;
		  info.text = "Loading...";
		  info.textColor = 0xFFFFFF;
		  info.x = 0; info.y = 350;
		  info.filters = [new BevelFilter(5, 120, 0xFFFFFF, .8, 0x000000, .3)];
		  addChild(info);
		  
		  addEventListener(Event.ENTER_FRAME, update);
		  loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
		}
		
		private function ioError(e:IOErrorEvent):void 
		{
			info.text = "An error occured. Please refresh";
		}
      
      private function update(e:Event):void {
		  percentbar.scaleX = (loaderInfo.bytesLoaded / loaderInfo.bytesTotal);
		  info.text = "Loading... (" + Math.round(percentbar.scaleX * 100) + "%)";
		 if (loaderInfo.bytesLoaded == loaderInfo.bytesTotal) {
			stop();
            removeEventListener(Event.ENTER_FRAME, update);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			info.text = "Loaded!";
			playbutton = new Button("Play", 330, 500, 0, function():void { startup(); } );
			addChild(playbutton);
			playbutton.start();
         }
      }
      
      private function startup():void {
		 if (playbutton.stage) {
			 logodisplay.remove();
			 removeChild(playbutton);
			 removeChild(preloaderscreenbitmap);
			 removeChild(greybar);
			 removeChild(percentbar);
			 removeChild(info);
			 
			 var main:Class = getDefinitionByName("Main") as Class;
			 addChild(new main(stage) as DisplayObject);
		 }
      }
   }
}