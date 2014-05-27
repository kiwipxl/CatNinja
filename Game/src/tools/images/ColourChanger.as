package tools.images {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class ColourChanger {
		
		//colour transform variables
		public var transform:ColorTransform;
		private var redAdd:Number = 0;
		private var greenAdd:Number = 0;
		private var blueAdd:Number = 0;
		public var rgbspeed:Number = 0;
		private var maxrgb:Number = 0;
		public var container:Bitmap;
		private var reversed:Boolean = false;
		
		public function ColourChanger(applyTo:Bitmap = null, colourSpeed:Number = .002, maxItensity:Number = 1.4):void {
			rgbspeed = colourSpeed;
			maxrgb = maxItensity;
			container = applyTo;
			
			transform = new ColorTransform(maxrgb, 1, 1);
			redAdd = rgbspeed;
		}
		
		public function reset():void {
			container.transform.colorTransform = transform;
		}
		
		public function update():void {
			//transform colours of mapdata
			transform.redMultiplier += redAdd;
			transform.greenMultiplier += greenAdd;
			transform.blueMultiplier += blueAdd;
			
			if (transform.redMultiplier >= maxrgb) {
				transform.redMultiplier = maxrgb;
				transform.greenMultiplier = 1;
				if (reversed) {
					reverse();
				}else {
					revert();
				}
			}else if (transform.blueMultiplier >= maxrgb) {
				transform.redMultiplier = 1;
				transform.blueMultiplier = maxrgb;
				if (reversed) {
					reverse();
				}else {
					revert();
				}
			}else if (transform.greenMultiplier >= maxrgb) {
				transform.greenMultiplier = maxrgb;
				transform.blueMultiplier = 1;
				if (reversed) {
					reverse();
				}else {
					revert();
				}
			}
			if (container) { container.transform.colorTransform = transform; }
		}
		
		public function reverse():void {
			if (redAdd > 0) {
				greenAdd = rgbspeed;
				redAdd = -rgbspeed;
				blueAdd = 0;
			}else if (blueAdd > 0) {
				redAdd = rgbspeed;
				blueAdd = -rgbspeed;
				greenAdd = 0;
			}else if (greenAdd > 0) {
				redAdd = 0;
				blueAdd = rgbspeed;
				greenAdd = -rgbspeed;
			}
			reversed = true;
		}
		
		public function revert():void {
			if (redAdd > 0) {
				greenAdd = 0;
				redAdd = -rgbspeed;
				blueAdd = rgbspeed;
			}else if (blueAdd > 0) {
				redAdd = 0;
				blueAdd = -rgbspeed;
				greenAdd = rgbspeed;
			}else if (greenAdd > 0) {
				redAdd = rgbspeed;
				blueAdd = 0;
				greenAdd = -rgbspeed;
			}
			reversed = false;
		}
	}
}