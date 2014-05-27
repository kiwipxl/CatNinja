package ui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Transition {
		
		//transition variables
		public var created:Boolean = false;
		private var delaytimer:int = 0;
		private var scalenum:Number = 0;
		private var scaledest:int = 0;
		private var completefunc:Function;
		private var delayrate:int = 40;
		
		//ui variables
		private var transitioncontainer:Sprite;
		private var transition:Sprite;
		private var background:Shape;
		private var backgrounddata:BitmapData;
		private var colourtransform:ColorTransform = new ColorTransform();
		private var smallwheelcontainer:Sprite;
		private var smallwheel:Bitmap;
		private var bigwheelcontainer:Sprite;
		private var bigwheel:Bitmap;
		
		public function show(completefunction:Function, inititalscale:Number = 0, rate:int = 40):void {
			if (created) { return; }
			
			delayrate = rate;
			completefunc = completefunction;
			transitioncontainer = new Sprite();
			transition = new Sprite();
			Main.universe.addChild(transitioncontainer);
			transitioncontainer.addChild(transition);
			
			background = new Shape();
			drawbackground();
			transition.addChild(background);
			
			bigwheelcontainer = new Sprite();
			transition.addChild(bigwheelcontainer);
			bigwheel = new Bitmap(Main.textures.spikywheel);
			bigwheel.filters = [new GlowFilter(0xFFFFFF, 1, 6, 6, 2, 1, false, false)];
			bigwheelcontainer.addChild(bigwheel);
			bigwheelcontainer.x = Main.halfwidth; bigwheelcontainer.y = Main.halfheight;
			bigwheel.x = -(bigwheel.width / 2); bigwheel.y = -(bigwheel.height / 2);
			
			smallwheelcontainer = new Sprite();
			transition.addChild(smallwheelcontainer);
			smallwheel = new Bitmap(Main.textures.spikywheel);
			smallwheel.scaleX = .6; smallwheel.scaleY = .6;
			smallwheel.filters = [new GlowFilter(0xFFFFFF, 1, 6, 6, 2, 1, false, false)];
			smallwheelcontainer.x = Main.halfwidth; smallwheelcontainer.y = Main.halfheight;
			smallwheel.x = -(smallwheel.width / 2); smallwheel.y = -(smallwheel.height / 2);
			smallwheelcontainer.addChild(smallwheel);
			bigwheel.transform.colorTransform = colourtransform;
			smallwheel.transform.colorTransform = colourtransform;
			
			transitioncontainer.scaleX = inititalscale; transitioncontainer.scaleY = inititalscale;
			transitioncontainer.x = Main.halfwidth; transitioncontainer.y = Main.halfheight;
			transition.x = -(transition.width / 2); transition.y = -(transition.height / 2);
			
			created = true;
			scalenum = .4;
			scaledest = 1;
			transition.addEventListener(Event.ENTER_FRAME, update);
			Main.sound.playsfx(16);
		}
		
		private function remove():void {
			Main.universe.removeChild(transitioncontainer);
			transition.removeChild(background);
			transition.removeChild(bigwheelcontainer);
			transition.removeChild(smallwheelcontainer);
			bigwheelcontainer.removeChild(bigwheel);
			smallwheelcontainer.removeChild(smallwheel);
			transition.removeEventListener(Event.ENTER_FRAME, update);
			colourtransform = null;
			background = null;
			backgrounddata.dispose();
			backgrounddata = null;
			smallwheel = null;
			bigwheel = null;
			transition = null;
			transitioncontainer = null;
			created = false;
			completefunc = null;
			Main.sound.playsfx(17);
		}
		
		private function drawbackground():void {
			background.graphics.beginBitmapFill(Main.textures.middarkgroundtile);
			background.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			
			backgrounddata = new BitmapData(40, 40, true, 0);
			var backgroundalpha:BitmapData = new BitmapData(40, 40, true, 0xFFFFFF + (50 << 24));
			backgrounddata.copyPixels(Main.textures.simplebackground, backgrounddata.rect, new Point(), backgroundalpha, null, true);
			background.graphics.beginBitmapFill(backgrounddata);
			background.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			background.filters = [new BlurFilter(2, 2, 2)];
			
			colourtransform = new ColorTransform();
			colourtransform.redMultiplier = 1 + Math.random() * 1;
			colourtransform.greenMultiplier = 1 + Math.random() * 1;
			colourtransform.blueMultiplier = 1 + Math.random() * 1;
			background.transform.colorTransform = colourtransform;
			
			backgroundalpha.dispose(); backgroundalpha = null;
		}
		
		private function update(event:Event):void {
			++delaytimer;
			if (delaytimer <= delayrate) {
				transitioncontainer.scaleX += scalenum; transitioncontainer.scaleY += scalenum;
				if (transitioncontainer.scaleX >= scaledest && scalenum > 0 || transitioncontainer.scaleX <= scaledest && scalenum < 0) {
					transitioncontainer.scaleX = scaledest; transitioncontainer.scaleY = scaledest;
					bigwheelcontainer.rotation += 2;
					smallwheelcontainer.rotation -= 2;
					if (scalenum < 0) { if (scalenum < 0) { remove(); return; } }
				}
			}else {
				scalenum = -.1;
				scaledest = 0;
				delaytimer = 0;
				if (completefunc != null) { completefunc(); completefunc = null; }
			}
			Main.universe.setChildIndex(transitioncontainer, Main.universe.numChildren - 1);
		}
	}
}