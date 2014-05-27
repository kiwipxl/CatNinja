package ui {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class SpeechBox extends Sprite {
		
		//speech variables
		private var box:Bitmap;
		public var text:TextField = new TextField();
		private var index:int = 0;
		private var lastindex:int = 0;
		public var speed:int = 1;
		public var originalSpeed:int = 0;
		private var data:String = "";
		private var rawdata:String = "";
		private var numberdata:String = "";
		public var typing:Boolean = false;
		public var followPlayer:*;
		public var following:Boolean = false;
		
		//backspace variables
		private var backspacedAmount:int = 0;
		private var backspaceNum:int = 0;
		private var backspacing:Boolean = false;
		
		public function SpeechBox(message:String):void {
			box = new Bitmap(Main.textures.messagebox);
			addChild(box);
			
			text.width = 250;
			text.height = 100;
			text.multiline = true;
			text.wordWrap = true;
			
			text.text = message;
			text.width = text.textWidth + 40;
			box.width = text.textWidth + 40;
			box.height = text.textHeight * 2;
			text.x = 0;
			text.y = box.height / 6;
			text.text = "";
			
			var format:TextFormat = new TextFormat();
			format.align = "center";
			text.defaultTextFormat = format;
			
			addChild(text);
			
			index = 1;
			lastindex = 0;
			data = message;
			rawdata = message;
			numberdata = message;
			typing = true;
			backspacing = false;
			backspacedAmount = 0;
		}
		
		public function updatePosition():void {
			x = followPlayer.x - (box.width / 2);
			y = followPlayer.y - 100;
			if (x < 0) {
				x = 20;
			}
		}
		
		public function remove():void {
			if (text.stage) {
				Main.speech.remove(this);
				typing = false;
			}
		}
		
		public function backspace(charnum:int, continuein:int):void {
			backspaceNum = charnum;
			Main.time.runFunctionIn(continuein, function():void { typing = true; } );
			backspacing = true;
			backspacedAmount = 0;
			index -= speed;
		}
		
		public function pause(ms:int):void {
			typing = false;
			Main.time.runFunctionIn(ms, function():void { typing = true; } );
		}
		
		public function update():void {
			if (following) {
				updatePosition();
			}
			if (!typing) {
				return;
			}
			
			if (backspacing) {
				index -= speed;
				++backspacedAmount;
				if (backspacedAmount >= backspaceNum) {
					backspacing = false;
					typing = false;
					data = data.substring(0, index) + data.substring(index + backspacedAmount);
				}
			}else {
				if (data.substring(lastindex + 1, speed).indexOf("%") != -1) {
					var char:int = data.indexOf("%");
					var dataclone:String = data;
					var func:String = data.substring(char, data.indexOf(")") + 1);
					data = dataclone.substring(0, char) + dataclone.substring(char + func.length);
					numberdata = dataclone.substring(char + func.length);
					Main.interpreter.interperate(0, func);
				}
				index += speed;
			}
			
			text.text = data.substring(0, index);
			lastindex = index;
			text.scrollV = 999;
			
			if (index >= data.length) {
				index = 0;
				lastindex = 0;
				typing = false;
				text.text = data;
			}
		}
	}
}