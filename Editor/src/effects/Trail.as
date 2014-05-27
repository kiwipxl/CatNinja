package effects {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Trail extends Sprite {
		
		//trail variables
		public var base:Sprite = new Sprite();
		public var removed:Boolean = false;
		public var fadeSpeed:Number = 0;
		private var type:int = 0;
		private var speedx:Number = 0;
		private var speedy:Number = 0;
		
		public function Trail(graphic:BitmapData, colourtransform:ColorTransform, graphictype:int, startAlpha:Number, hex:int):void {
			if (graphic != null) {
				var g:Bitmap = new Bitmap(graphic);
				g = new Bitmap(graphic);
				g.x = -g.width / 2;
				g.y = -g.height / 2;
				base.addChild(g);
			}else {
				var shape:Shape = new Shape();
				switch (graphictype) {
					case 1:
						shape.graphics.lineStyle(1, 0x7028b0);
						shape.graphics.beginFill(0x7028b0);
						shape.graphics.drawCircle(0, 0, 8);
						break;
					case 2:
						shape.graphics.lineStyle(1, 0xFF0000);
						shape.graphics.beginFill(0xFF0000);
						shape.graphics.drawCircle(0, 0, 2 + Math.random() * 4);
						speedx = Math.random() * 1 - Math.random() * 1;
						speedy = 2 + Math.random() * 1 - Math.random() * 1;
						if (Main.map.currentrotation == 180) { speedy -= 4; }
						break;
					case 3:
						shape.graphics.lineStyle(1, hex);
						shape.graphics.beginFill(hex);
						shape.graphics.drawCircle(0, 0, 2 + Math.random() * 2);
						speedx = Math.random() * 1 - Math.random() * 1;
						speedy = Math.random() * 1 - Math.random() * 1;
						break;
					case 4:
						shape.graphics.lineStyle(1, 0x1AEA10);
						shape.graphics.beginFill(0x1AEA10);
						shape.graphics.drawCircle(0, 0, 2 + Math.random() * 4);
						speedx = Math.random() * 1 - Math.random() * 1;
						speedy = 2 + Math.random() * 1 - Math.random() * 1;
						if (Main.map.currentrotation == 180) { speedy -= 4; }
						break;
				}
				base.addChild(shape);
			}
			
			addChild(base);
			if (colourtransform) { transform.colorTransform = colourtransform; }
			type = graphictype;
			alpha = startAlpha;
			cacheAsBitmap = true;
		}
		
		public function update():void {
			if (type == 2 || type == 3) {
				x += speedx;
				y += speedy;
				scaleX -= .01;
				scaleY -= .01;
			}
			alpha -= fadeSpeed;
			if (alpha <= 0) {
				removed = true;
			}
		}
	}
}