package managers {
	
	import entities.ScriptObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class ScriptObjectManager {
		
		//script object manager
		public var objects:Vector.<ScriptObject> = new Vector.<ScriptObject>;
		public var objectLoop:Vector.<ScriptObject> = new Vector.<ScriptObject>;
		
		public function create(graphicid:int, id:int, x:int, y:int):void {
			var object:ScriptObject = new ScriptObject(graphicid, id);
			object.x = (x * 20) + object.width / 2;
			object.y = (y * 20) + object.height / 2;
			objects.push(object);
			Main.screen.addChild(object);
		}
		
		public function scale(id:int, amountX:Number, amountY:Number):void {
			var object:ScriptObject = getObject(id);
			if (object) {
				object.scaleX = amountX;
				object.scaleY = amountY;
			}else if (id == -1) {
				Main.player.scaleX = amountX;
				Main.player.scaleY = amountY;
			}
		}
		
		public function jump(id:int, jumpheight:int):void {
			var object:ScriptObject = getObject(id);
			if (object) {
				object.gravity = jumpheight;
			}else if (id == -1) {
				Main.player.gravity = jumpheight;
			}
		}
		
		public function walk(id:int, steps:int):void {
			var object:ScriptObject = getObject(id);
			if (steps > 0) { ++steps; }else { --steps }
			if (object) {
				object.walkSteps = true;
				object.stepAmount = steps;
				object.steps = 0;
			}else if (id == -1) {
				Main.player.walkSteps = true;
				Main.player.stepAmount = steps;
			}
		}
		
		public function getObject(id:int):ScriptObject {
			for (var n:int = 0; n < objects.length; ++n) {
				if (objects[n].id == id) {
					return objects[n];
				}
			}
			return null;
		}
		
		public function gravityOn(params:Array):void {
			for (var i:int = 0; i < params.length; ++i) {
				var object:ScriptObject = getObject(int(params[i]));
				if (object) { object.gravityOn = true; }
			}
		}
		
		public function loopOn(params:Array):void {
			for (var i:int = 0; i < params.length; ++i) {
				var object:ScriptObject = getObject(int(params[i]));
				if (object) { objectLoop.push(object); }
			}
		}
		
		public function update():void {
			for (var n:int = 0; n < objectLoop.length; ++n) {
				objectLoop[n].update();
			}
		}
	}
}