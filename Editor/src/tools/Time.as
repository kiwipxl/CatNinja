package tools {
	
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Time {
		
		//time variables
		public var timers:Vector.<TimeCounter> = new Vector.<TimeCounter>;
		
		public function runFunctionIn(ms:int, func:Function, repeat:Boolean = false, ...rest):TimeCounter {
			var time:TimeCounter = new TimeCounter();
			time.runat = ms;
			time.call = func;
			time.timer = getTimer();
			time.repeat = repeat;
			time.args = rest;
			timers.push(time);
			return time;
		}
		
		public function remove(timer:TimeCounter):void {
			for (var n:int = 0; n < timers.length; ++n) {
				if (timers[n] == timer) {
					timers.splice(n, 1);
					return;
				}
			}
		}
		
		public function removeall():void {
			timers.length = 0;
		}
		
		public function update():void {
			for (var n:int = 0; n < timers.length; ++n) {
				if ((getTimer() - timers[n].timer) >= timers[n].runat) {
					if (timers[n].args.length == 0) {
						timers[n].call();
					}else {
						timers[n].call(timers[n].args);
					}
					if (timers.length <= 0) { return; }
					if (!timers[n].repeat) {
						timers.splice(n, 1);
					}else {
						timers[n].timer = getTimer();
					}
				}
			}
		}
	}
}