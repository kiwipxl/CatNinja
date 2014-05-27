package tools.text {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class TextManager {
		
		//text variables
		public var textfields:Vector.<DisplayText> = new Vector.<DisplayText>;
		
		public function createtext(message:String, x:int, y:int, fadespeed:Number = 1, fontid:int = 0, fadeout:Boolean = false, fadedelay:int = 0):DisplayText {
			var newtext:DisplayText = new DisplayText();
			var dtext:TextField = new TextField();
			
			var format:TextFormat = new TextFormat();
			format.align = "center";
			format.font = "square";
			if (fontid == 1) { format.font = "cubic"; }
			
			dtext.embedFonts = true;
			dtext.defaultTextFormat = format;
			
			dtext.multiline = true;
			dtext.wordWrap = true;
			dtext.selectable = false;
			dtext.width = 800;
			dtext.height = 400;
			dtext.filters = [new GlowFilter(0x000000, 1, 12, 12, 2, 2), new BevelFilter(5, 120, 0xFFFFFF, .8, 0x000000, .3)];
			
			if (message.indexOf("spec1") != -1) {
				message = "<font color='#E473EE' size='80'>Cat </font><font color='#1C6FD5' size='80'>Ninja:</font><br>" +
				"<font color='#B95BEC' size='25'> The search for the </font><br><font color='#12DFF5' size='50'>magical</font>" +
				"<font color='#3696E4' size='50'> energy </font><font color='#DB05E0' size='50'>crystals</font>";
				dtext.htmlText = message;
			}else if (message.indexOf("spec2") != -1) {
				message = "<font color='#1E84EA' size='35'> Programming </font><font color='#FFFFFF' size='25'> and </font>" +
				"<font color='#2FC5F0' size='35'> Artwork </font><font color='#FFFFFF' size='25'> by </font><br>" +
				"<font color='#BD55F4' size='40'>Richman Stewart</font>";
				newtext.destx = 0;
				dtext.htmlText = message;
			}else if (message.indexOf("spec3") != -1) {
				message = "<font color='#FFFFFF' size='25'>  In association with </font>";
				newtext.destx = 0;
				dtext.htmlText = message;
				newtext.logo = new Bitmap(Preloader.biglogo);
				newtext.addChild(newtext.logo);
				newtext.logo.x = 400 - (Preloader.biglogo.width / 2);
				newtext.logo.y = 80;
			}else if (message.indexOf("spec4") != -1) {
				message = "<font color='#CE4DCB' size='35'> Music </font><font color='#FFFFFF' size='25'> by </font>" +
				"<font color='#D579F2' size='45'> BunnyMajs </font><font color='#FFFFFF' size='25'> and </font>" +
				"<font color='#3379E3' size='45'> Eric Skiff </font>";
				newtext.destx = 0;
				dtext.htmlText = message;
			}else {
				dtext.htmlText = message;
			}
			
			var data:BitmapData = new BitmapData(dtext.width, dtext.height + 20, true, 0);
			data.draw(dtext, new Matrix(1, 0, 0, 1, 0, 20), null, null, null, true);
			newtext.base = new Bitmap(data);
			newtext.base.smoothing = true;
			newtext.addChild(newtext.base);
			newtext.x = x; newtext.y = y;
			
			Main.universe.addChild(newtext);
			textfields.push(newtext);
			Main.universe.setChildIndex(Main.fadescreen, Main.universe.numChildren - 1);
			
			if (fadeout) {
				newtext.fading = true;
				newtext.fadeout = fadeout;
				newtext.fadedelay = fadedelay;
				newtext.fadespeed = fadespeed;
			}else if (fadespeed != 1) {
				newtext.fadein = true;
				newtext.fadespeed = fadespeed;
				newtext.alpha = 0;
				newtext.fading = true;
			}
			dtext = null;
			
			Main.universe.setChildIndex(Main.menu.navbar, Main.universe.numChildren - 1);
			
			return newtext;
		}
		
		public function update():void {
			if (textfields.length > 0) {
				for (var n:int = 0; n < textfields.length; ++n) {
					textfields[n].update();
				}
			}
		}
		
		public function remove():void {
			for (var n:int = 0; n < textfields.length; ++n) {
				Main.universe.removeChild(textfields[n]);
			}
			textfields.length = 0;
		}
		
		public function removemessage(message:DisplayText):void {
			for (var n:int = 0; n < textfields.length; ++n) {
				if (message == textfields[n]) {
					Main.universe.removeChild(textfields[n]);
					textfields.splice(n, 1);
					return;
				}
			}
		}
		
		public function screenmessage(message:String, fromarray:Array = null, colour:String = "FF0000", 
															fadeout:Boolean = true, fadetime:int = 90, fontsize:int = 25):DisplayText {
			if (fromarray) { message = fromarray[int(Math.random() * (fromarray.length - 1))]; }
			message = "<font color='#" + colour + "' size='" + fontsize + "'>" + message + "</font>";
			
			return createtext(message, 0, 40, .05, 0, fadeout, fadetime);
		}
	}
}