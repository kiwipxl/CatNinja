package ui {
	
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Countdown {
		
		//countdown variables
		private var completefunc:Function;
		private var format:TextFormat;
		private var containers:Vector.<Sprite> = new Vector.<Sprite>;
		public var created:Boolean = false;
		
		public function start(completefunction:Function):void {
			for (var n:int = 0; n < containers.length; ++n) {
				Main.universe.removeChild(containers[n]);
				containers[n] = null;
			}
			completefunc = completefunction;
			containers.length = 0;
			
			format = new TextFormat();
			format.font = "square";
			format.size = 200;
			format.align = "center";
			for (var c:int = 0; c < 3; ++c) {
				createnumbertext(3 - c);
			}
			containers[0].visible = true;
			created = true;
		}
		
		public function remove():void {
			for (var n:int = 0; n < containers.length; ++n) {
				Main.universe.removeChild(containers[n]);
				containers[n] = null;
			}
			containers.length = 0;
			format = null;
			completefunc = null;
			created = false;
		}
		
		private function createnumbertext(number:int):void {
			var container:Sprite = new Sprite();
			Main.universe.addChild(container);
			container.x = Main.halfwidth; container.y = Main.halfheight;
			
			var numbertext:TextField = new TextField();
			numbertext.embedFonts = true;
			numbertext.defaultTextFormat = format;
			numbertext.width = 600; numbertext.height = 400;
			numbertext.selectable = false; numbertext.multiline = false; numbertext.wordWrap = true;
			numbertext.filters = [new GlowFilter(0x000000, 1, 12, 12, 2, 1, false, false)];
			numbertext.text = String(number);
			numbertext.width = numbertext.textWidth; numbertext.height = numbertext.textHeight;
			numbertext.x = -(numbertext.width / 2); numbertext.y = -(numbertext.height / 2);
			container.addChild(numbertext);
			containers.push(container);
			container.visible = false;
			container.scaleX = 5; container.scaleY = 5;
			
			if (number == 3) { numbertext.textColor = 0x5AEE53;
			}else if (number == 2) { numbertext.textColor = 0xEAAB35;
			}else if (number == 1) { numbertext.textColor = 0xCE0B32; }
			Main.sound.playsfx(18);
		}
		
		public function update():void {
			if (containers.length > 0) {
				containers[0].scaleX -= .2; containers[0].scaleY -= .2;
				containers[0].alpha -= .04;
				if (containers[0].alpha <= 0) {
					Main.universe.removeChild(containers[0]);
					containers[0] = null;
					containers.splice(0, 1);
					if (containers.length == 0) {
						Main.sound.playsfx(19);
						created = false;
						format = null;
						if (completefunc != null) { completefunc(); }
						Main.gamepaused = false;
					}else {
						Main.sound.playsfx(18);
						containers[0].visible = true;
					}
				}
			}
		}
	}
}