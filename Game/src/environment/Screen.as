package environment {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Screen extends Sprite {
		
		//screen variables
		private var format:TextFormat;
		private var display:TextField;
		private var base:Sprite = new Sprite();
		
		public function Screen():void {
			format = new TextFormat();
			format.align = "center";
			format.font = "square";
			
			display = new TextField();
			display.embedFonts = true;
			display.defaultTextFormat = format;
			
			display.multiline = true;
			display.wordWrap = true;
			display.selectable = false;
			display.width = 100;
			
			addChild(base);
			base.addChild(display);
			cacheAsBitmap = true;
		}
		
		private function getParam(message:String, name:String, paramtype:int):String {
			var cmessage:String = message;
			var result:String = "";
			while (true) {
				var id:int = message.indexOf(name);
				if (id != -1) {
					result += message.substring(0, id);
					message = message.substring(id);
					
					var params:Array = message.substring(name.length, message.indexOf("]")).split("|");
					message = message.substring(message.indexOf("]") + 1);
					
					switch (paramtype) {
						case 0:
							result += "<font size = '" + params[0] + "'>" + params[1] + "</font>";
							break;
						case 1:
							result += "<font color = '" + params[0] + "'>" + params[1] + "</font>";
							break;
					}
				}else {
					result += message.substring(0);
					break;
				}
			}
			return result;
		}
		
		public function updateDisplay(message:String, rotationdisplay:int = 0):void {
			var result:String = message;
			result = getParam(result, "size[", 0);
			result = getParam(result, "colour[", 1);
			result = result.replace("&[newline]", "<br>");
			result = result.replace("${greaterthan}", ">");
			result = result.replace("${lessthan}", "<");
			
			display.htmlText = result;
			display.x = 10;
			display.y = 27 - (display.textHeight / 2);
			
			display.x -= 60;
			display.y -= 30;
			base.rotation = rotationdisplay;
			base.x = 60;
			base.y = 30;
		}
	}
}