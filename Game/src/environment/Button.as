package environment {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Button extends Bitmap {
		
		//button variables
		public var pressed:Boolean = false;
		private var minusScaleX:Number = 0;
		private var minusScaleY:Number = 0;
		private var offsetX:int = 0;
		private var offsetY:int = 0;
		public var datanum:int = 0;
		
		public function Button(graphic:BitmapData):void {
			super(graphic);
			if (graphic == Main.textures.button || graphic == Main.textures.buttonup) {
				minusScaleY = .25;
				offsetY = height / 4;
			}else {
				minusScaleX = .25;
			}
		}
		
		public function slam():void {
			if (!pressed && Main.player.x >= x - 25 && Main.player.x <= x + 25 && Main.player.y >= y - 25 && Main.player.y <= y + 25) {
				scaleX -= minusScaleX;
				scaleY -= minusScaleY;
				x += offsetX;
				y += offsetY;
				if (scaleX <= .25 || scaleY <= .25) {
					Main.sound.playsfx(8);
					Main.interpreter.interperate(0, "goto(unlocklaser)");
					pressed = true;
					if (scaleX <= .25) { scaleX = .25; } else if (scaleY <= .25) { scaleY = .25; }
					Main.map.changeTile(x / 20, y / 20, datanum + 12, null, null, true, true);
					Main.env.remove(Main.env.buttons, this);
				}
			}
		}
	}
}