package tools.text {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class DisplayText extends Sprite {
		
		//displaytext variables
		public var base:Bitmap;
		public var logo:Bitmap;
		public var fading:Boolean = false;
		public var fadein:Boolean = false;
		public var fadeout:Boolean = false;
		public var doublefade:Boolean = false;
		public var faded:Boolean = false;
		public var fadespeed:Number = 0;
		public var destx:int = -1;
		public var fadedelay:int = 0;
		public var fadedelaytimer:int = 0;
		
		public function update():void {
			if (destx != -1) {
				x += (destx - x) / 25;
				if (x >= destx - 1 && x <= destx + 1) {
					destx = -1;
				}
			}
			
			if (fading) {
				++fadedelaytimer;
				if (fadedelaytimer < fadedelay) { return; }
				
				if (fadein) {
					alpha += fadespeed;
					if (alpha >= 1) {
						alpha = 1;
						fadein = false;
						if (doublefade && !faded) {
							fadeout = true; faded = true;
						}else {
							fading = false;
						}
					}
				}else {
					alpha -= fadespeed;
					if (alpha <= 0) {
						alpha = 0;
						visible = false;
						fadeout = false;
						if (doublefade && !faded) {
							fadein = true; faded = true;
						}else {
							fading = false;
						}
					}
				}
			}
		}
	}
}