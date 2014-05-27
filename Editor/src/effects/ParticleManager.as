package effects {
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class ParticleManager {
		
		//particlemanager variables
		public var particles:Vector.<Particle> = new Vector.<Particle>;
		public const MAXPARTICLES:int = 100;
		
		public function create(x:int, y:int, amount:int = 5, powerx:int = 15, gravpower:int = 15, graphictype:int = 1, orLoadFrom:Array = null):void {
			var index:int = 0;
			var graphicdata:BitmapData;
			for (var n:int = 0; n < amount; ++n) {
				if (orLoadFrom) {
					graphicdata = orLoadFrom[index];
					++index;
					if (index >= orLoadFrom.length) {
						index = 0;
					}
				}
				var particle:Particle = new Particle(graphicdata, graphictype, powerx, gravpower);
				particle.x = x;
				particle.y = y;
				Main.screen.addChild(particle);
				particles.push(particle);
				
				if (particles.length >= MAXPARTICLES) {
					Main.screen.removeChild(particles[0]);
					particles.splice(0, 1);
				}
			}
		}
		
		public function update():void {
			for (var n:int = 0; n < particles.length; ++n) {
				particles[n].update();
				if (particles[n].removed) {
					Main.screen.removeChild(particles[n]);
					particles.splice(n, 1);
				}
			}
		}
		
		public function removeAll():void {
			for (var n:int = 0; n < particles.length; ++n) {
				Main.screen.removeChild(particles[n]);
			}
			particles.length = 0;
		}
	}
}