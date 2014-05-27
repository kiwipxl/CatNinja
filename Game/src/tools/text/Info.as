package tools.text {
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Info {
		
		//infomanager variables
		public var info:TextField = new TextField();
		private var fpstimer:int = 0;
		private var timer:int = 0;
		
		//debug console variables
		public var console:Sprite = new Sprite();
		private var input:TextField = new TextField();
		private var loginfo:TextField = new TextField();
		private var consolePause:Boolean = false;
		
		public function initiate():void {
			var format:TextFormat = new TextFormat();
			format.font = "square";
			format.size = 15;
			info.embedFonts = true;
			info.defaultTextFormat = format;
			
			info.width = 300; info.height = 200;
			info.selectable = false;
			info.multiline = true;
			info.wordWrap = true;
			info.textColor = 0xFFFFFF;
			info.cacheAsBitmap = true;
			info.x = 0; info.y = 0;
			Main.universe.addChild(info);
			fpstimer = getTimer();
			
			createConsole();
		}
		
		private function createConsole():void {
			console.graphics.lineStyle(1, 0x000000);
			console.graphics.beginFill(0x000000, .6);
			console.graphics.drawRect(0, 0, 800, 150);
			console.x = 0; console.y = 0;
			Main.screen.addChild(console);
			
			loginfo.width = 750; loginfo.height = 120;
			loginfo.x = 25; loginfo.y = 10;
			loginfo.textColor = 0xFFFFFF;
			loginfo.multiline = true;
			loginfo.wordWrap = true;
			loginfo.selectable = true;
			console.addChild(loginfo);
			
			input.width = 750; input.height = 20;
			input.x = 25; input.y = 125;
			input.border = true;
			input.borderColor = 0x000000;
			input.background = true;
			input.backgroundColor = 0xFFFFFF;
			input.textColor = 0x000000;
			input.type = TextFieldType.INPUT;
			input.selectable = true;
			console.addChild(input);
			
			console.visible = false;
		}
		
		public function update(force:Boolean = false):void {
			++timer;
			if ((getTimer() - fpstimer) >= 1000 || force) {
				info.text = "Deaths: " + Main.pdeaths + 
				"\nCrystals Collected: " + Main.collected;
				fpstimer = getTimer();
				timer = 0;
			}
		}
		
		public function log():void {
			var text:String = input.text.toLowerCase();
			var args:Array = [];
			if (text == "help") {
				trace("<font color='#59D7FB'>Available commands:</font>\n" +
				"<font color='#FF860D'>pause / stop</font> - Pause logs\n" +
				"<font color='#FF860D'>resume / start</font> - Resume logs\n" +
				"<font color='#FF860D'>reset / clear</font> - Resets the map\n" +
				"<font color='#FF860D'>save</font> - Saves the map\n" +
				"<font color='#FF860D'>load</font> - Loads the map\n" +
				"<font color='#FF860D'>currentdimensions</font> - Displays current width and height of the map in tiles\n" +
				"<font color='#FF860D'>resize [width height]</font> - Resizes the map\n" +
				"<font color='#FF860D'>resizeright [width]</font> - Adds tiles to the right side of the map\n" +
				"<font color='#FF860D'>resizeleft [width]</font> - Adds tiles to the left side of the map\n" +
				"<font color='#FF860D'>resizedown [height]</font> - Adds tiles to the bottom side of the map\n" +
				"<font color='#FF860D'>resizeup [height]</font> - Adds tiles to the top side of the map\n" +
				"<font color='#FF860D'>flipx</font> - Flips the map on it's x axis\n" +
				"<font color='#FF860D'>eventhelp</font> - Shows the commands that can be used for event writing"
				, "");
			}else if (text == "eventhelp") {
				trace("<font color='#59D7FB'>Available event commands:</font>\n" +
				"<font color='#FF860D'>say [message, lastsfor]</font> - Displays a message box with a message in it for a period of time\n" +
				"<font color='#FF860D'>pause [ms]</font> - Pauses the compiler from running for a period of time\n" +
				"<font color='#FF860D'>if</font> - Runs an if command\n" +
				"<font color='#FF860D'>collision [tiletype]</font> - Returns a boolean whether the player collided with the inputted tile type or not\n" +
				"<font color='#FF860D'>%backspace [charamount, ms]</font> - Backspaces the current message and continues in a period of time"
				, "");
			}else if (text == "pause" || text == "stop") {
				trace("Console paused");
				consolePause = true;
			}else if (text == "resume" || text == "start") {
				consolePause = false;
				trace("Console resumed");
			}else if (text == "reset" || text == "clear") {
				trace("Map reset");
				toggleConsole();
				Main.mapeditor.redrawMap();
			}else if (text == "save") {
				trace("Saved map");
				toggleConsole();
				Main.mapeditor.saveMap();
			}else if (text == "load") {
				trace("Load dialog opened");
				toggleConsole();
				Main.mapeditor.saveMap();
			}else if (text == "currentdimensions") {
				trace("Map width: " + Main.mapeditor.gridwidth + ", height: " + Main.mapeditor.gridheight);
			}else if (text.substring(0, 11) == "resizeright") {
				args = getArgs(text, 1);
				if (args.length >= 1) {
					toggleConsole();
					Main.mapeditor.resizeMap(Main.mapeditor.gridwidth + int(args[1]), Main.mapeditor.gridheight);
					trace("Resized map width: " + Main.mapeditor.gridwidth);
				}
			}else if (text.substring(0, 10) == "resizeleft") {
				args = getArgs(text, 1);
				if (args.length >= 1) {
					toggleConsole();
					Main.mapeditor.negResizeX(int(args[1]));
					Main.mapeditor.resizeMap(Main.mapeditor.gridwidth, Main.mapeditor.gridheight);
					trace("Resized map width: " + Main.mapeditor.gridwidth);
				}
			}else if (text.substring(0, 8) == "resizeup") {
				args = getArgs(text, 1);
				if (args.length >= 1) {
					toggleConsole();
					Main.mapeditor.negResizeY(int(args[1]));
					Main.mapeditor.resizeMap(Main.mapeditor.gridwidth, Main.mapeditor.gridheight);
					trace("Resized map height: " + Main.mapeditor.gridheight);
				}
			}else if (text.substring(0, 10) == "resizedown") {
				args = getArgs(text, 1);
				if (args.length >= 1) {
					toggleConsole();
					Main.mapeditor.resizeMap(Main.mapeditor.gridwidth, Main.mapeditor.gridheight + int(args[1]));
					trace("Resized map height: " + Main.mapeditor.gridheight);
				}
			}else if (text.substring(0, 6) == "resize") {
				args = getArgs(text, 2);
				if (args.length >= 2) {
					toggleConsole();
					Main.mapeditor.resizeMap(args[1], args[2]);
					trace("Resized map width: " + Main.mapeditor.gridwidth + ", height: " + Main.mapeditor.gridheight);
				}
			}else if (text.substring(0, 6) == "flipx") {
				Main.mapeditor.flipx();
				trace("Flipped map on x axis");
			}else {
				trace("<font color='#FF9797'>Invalid command</font>", "");
			}
			input.text = "";
		}
		
		private function getArgs(from:String, required:int = 1):Array {
			var args:Array = from.split(" ");
			if (required == 1) {
				--required;
			}
			if (args.length > required) {
				return args;
			}else {
				trace("Not enough valid parameters given");
			}
			return [];
		}
		
		public function toggleConsole():void {
			if (console.visible) {
				console.visible = false;
				Main.universe.focus = null;
			}else {
				console.visible = true;
				Main.universe.focus = input;
			}
			input.text = "";
			Main.screen.setChildIndex(console, Main.screen.numChildren - 1);
		}
		
		public function trace(data:*, entrance:String = "log"):void {
			if (!consolePause) {
				if (entrance == "log") {
					var stackLine:String = new Error().getStackTrace().split( "\n" , 3)[2];
					var stackInfo:String = stackLine.substring(stackLine.lastIndexOf("\\") + 1, stackLine.length - 1);
					entrance = "<font color='#F717E6'>Log <font color='#1FABEF'>[" + stackInfo + "]:</font> </font>";
				}
				loginfo.htmlText += entrance + String(data) + "<br>";
				loginfo.scrollV = 9999;
			}
		}
	}
}