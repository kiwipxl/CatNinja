package ui {
	
	import entities.ScriptObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Speech {
		
		//speech variables
		public var speechboxes:Vector.<SpeechBox> = new Vector.<SpeechBox>;
		
		public function talk(objectid:int, message:String, hidein:int, follow:Boolean = false):void {
			var object:ScriptObject = Main.objectmanager.getObject(objectid);
			if (!object && objectid != -1) { return; }
			
			var box:SpeechBox = new SpeechBox(message);
			Main.screen.addChild(box);
			
			if (objectid == -1) {
				box.followPlayer = Main.player;
			}else {
				box.followPlayer = object;
			}
			box.updatePosition();
			box.following = follow;
			
			speechboxes.push(box);
			Main.time.runFunctionIn(hidein, box.remove);
		}
		
		public function update():void {
			for (var n:int = 0; n < speechboxes.length; ++n) {
				speechboxes[n].update();
			}
		}
		
		public function removeAll():void {
			for (var n:int = 0; n < speechboxes.length; ++n) {
				Main.screen.removeChild(speechboxes[n]);
			}
			speechboxes.length = 0;
		}
		
		public function remove(speechbox:SpeechBox):void {
			for (var n:int = 0; n < speechboxes.length; ++n) {
				if (speechboxes[n] == speechbox) {
					Main.screen.removeChild(speechboxes[n]);
					speechboxes.splice(n, 1);
					return;
				}
			}
		}
	}
}