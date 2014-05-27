package effects {
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class TrailManager {
		
		//trailmanager variables
		public var trails:Vector.<Trail>;
		
		public function initiate():void {
			trails = new Vector.<Trail>;
		}
		
		public function create(x:int, y:int, graphic:BitmapData = null, graphictype:int = 0, parent:Sprite = null, fadeSpeed:Number = .04, startingAlpha:Number = 1, colourtransform:ColorTransform = null, rotation:int = 0, hex:int = 0):void {
			var trail:Trail = new Trail(graphic, colourtransform, graphictype, startingAlpha, hex);
			trail.x = x + trail.width / 2;
			trail.y = y + trail.height / 2;
			trail.rotation = rotation;
			trail.fadeSpeed = fadeSpeed;
			Main.screen.addChild(trail);
			trails.push(trail);
			
			if (parent != null && parent.stage) {
				Main.screen.setChildIndex(parent, Main.screen.numChildren - 1);
			}
		}
		
		public function update():void {
			for (var n:int = 0; n < trails.length; ++n) {
				trails[n].update();
				if (trails[n].removed) {
					Main.screen.removeChild(trails[n]);
					trails.splice(n, 1);
				}
			}
		}
	}
}