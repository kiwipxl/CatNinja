package entities {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class ScriptObject extends Sprite {
		
		//script object variables
		public var id:int = 0;
		private var base:Sprite = new Sprite();
		public var gravityOn:Boolean = false;
		public var gravity:Number = 0;
		private var offsetx:int;
		private var offsety:int;
		
		//step variables
		public var walkSteps:Boolean = false;
		public var stepAmount:int = 0;
		public var steps:int = 0;
		public var lastX:int = 0;
		
		public function ScriptObject(graphicidentifier:int, identifier:int):void {
			id = identifier;
			
			var graphic:Bitmap;
			var data:BitmapData;
			switch (graphicidentifier) {
				case 0:
					data = Main.textures.characteridle;
			}
			graphic = new Bitmap(data);
			offsetx = data.width / 2;
			offsety = data.height / 2;
			base.x = -offsetx;
			base.y = -offsety;
			
			base.addChild(graphic);
			addChild(base);
		}
		
		private function walk():void {
			if (stepAmount > 0) {
				x += 1;
			}else {
				x -= 1;
			}
			
			if (lastX != int((x - offsetx) / 20)) {
				lastX = int((x - offsetx) / 20);
				++steps;
				if (steps >= Math.abs(stepAmount)) {
					walkSteps = false;
					steps = 0;
					stepAmount = 0;
				}
			}
		}
		
		public function update():void {
			if (walkSteps) {
				walk();
			}
			
			if (gravityOn) {
				y += gravity;
				gravity += .5;
				if (gravity >= 15) {
					gravity = 15;
				}
				if (gravity > 0 && !Main.map.collideDown(int((x - offsetx) / 20), int((y - offsety) / 20)).walkable) {
					gravity = 0;
					y = (int(y / 20) * 20) + offsety;
					rotation = 0;
				}else {
					if (scaleX == 1) {
						rotation += 12;
					}else {
						rotation -= 12;
					}
				}
			}
		}
	}
}