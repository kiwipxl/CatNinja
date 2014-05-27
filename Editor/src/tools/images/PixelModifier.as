package tools.images {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class PixelModifier {
		
		//pixelmodifier variables
		
		public static function breakData(data:BitmapData, amount:int = 2):Array {
			var temp:Array = [];
			for (var p:int = 0; p < amount; ++p) {
				var posx:int = Math.random() * (data.width / 1.5);
				var posy:int = Math.random() * (data.height / 1.5);
				var width:int = 5 + int(Math.random() * data.width / 1.5);
				var height:int = 5 + int(Math.random() * data.height / 1.5);
				if (width >= data.width) { width = data.width; }
				if (height >= data.height) { height = data.height; }
				var part:BitmapData = new BitmapData(width, height, true, 0);
				
				for (var y:int = posy; y < posy + height; ++y) {
					for (var x:int = posx; x < posx + width; ++x) {
						part.setPixel32(x - posx, y - posy, data.getPixel32(x, y));
					}
				}
				temp.push(part);
			}
			return temp;
		}
		
		public static function flip(data:BitmapData, scaleX:Number, scaleY:Number):BitmapData {
			var temp:BitmapData = new BitmapData(data.width, data.height, true, 0);
			if (scaleX != 1 && scaleY == 1) {
				temp.draw(data, new Matrix(scaleX, 0, 0, scaleY, -scaleX * data.width, 0));
			}else if (scaleY != 1 && scaleX == 1) {
				temp.draw(data, new Matrix(scaleX, 0, 0, scaleY, 0, -scaleY * data.height));
			}else {
				temp.draw(data, new Matrix(scaleX, 0, 0, scaleY, -scaleX * data.width, -scaleY * data.height));
			}
			return temp;
		}
		
		public static function rotate(data:BitmapData, angle:int):BitmapData {
			var matrix:Matrix = new Matrix();
			matrix.translate(-data.width / 2, -data.height / 2);
			matrix.rotate(angle * (Math.PI / 180));
			matrix.translate(data.height / 2, data.width / 2);
			
			var temp:BitmapData = new BitmapData(data.height, data.width, true, 0);
			temp.draw(data, matrix);
			return temp;
		}
		
		public static function cutSheet(data:BitmapData, width:int, height:int):Array {
			var sheetwidth:int = data.width / width;
			var sheetheight:int = data.height / height;
			var temp:Array = [];
			var rowx:int = 0;
			var rowy:int = 0;
			
			for (var y:int = 0; y < sheetheight; ++y) {
				for (var x:int = 0; x < sheetwidth; ++x) {
					var sprite:BitmapData = new BitmapData(width, height);
					sprite.copyPixels(data, new Rectangle(rowx, rowy, width, height), new Point(0, 0));
					temp.push(sprite);
					rowx += width;
				}
				rowx = 0;
				rowy += height;
			}
			
			return temp;
		}
	}
}