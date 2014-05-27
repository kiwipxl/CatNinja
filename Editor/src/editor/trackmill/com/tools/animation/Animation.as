package editor.trackmill.com.tools.animation {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Animation {
		
		public function create(base:Bitmap, frames:Array, framespeed:int = 1, addstates:Boolean = false):AnimateControl {
			var control:AnimateControl = new AnimateControl();
			control.base = base;
			control.frames = frames;
			control.framespeed = framespeed;
			control.states = addstates;
			return control;
		}
	}
}