package effects {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Particle extends Sprite {
		
		//trail variables
		public var base:Bitmap;
		public var shapebase:Shape;
		private var type:int = 0;
		public var removed:Boolean = false;
		private var speedx:Number = 0;
		private var gravity:Number = 0;
		private const FRICTION:Number = .98;
		private var onground:Boolean = false;
		private var delaytimer:int = 0;
		private var delayrate:int = 0;
		
		public function Particle(graphic:BitmapData, graphictype:int, powerx:int, gravpower:int):void {
			type = graphictype;
			if (graphictype != 0) {
				shapebase = new Shape();
				var size:int;
				var matrix:Matrix = new Matrix();
				switch (graphictype) {
					case 1:
						size = 2 + Math.random() * 4;
						matrix.createGradientBox(size, size / 10);
						shapebase.graphics.lineStyle();
						shapebase.graphics.beginGradientFill(GradientType.LINEAR, [0xFF0000, 0x940802], [1, 1], [0, 255], matrix, SpreadMethod.PAD);
						shapebase.graphics.drawRect(0, 0, size, size);
						shapebase.cacheAsBitmap = true;
						delayrate = 100 + Math.random() * 200;
						break;
					case 2:
						size = 2 + Math.random() * 8;
						matrix.createGradientBox(size, size / 10);
						shapebase.graphics.lineStyle();
						shapebase.graphics.beginGradientFill(GradientType.LINEAR, [0x006BD7, 0x58a6f4], [1, 1], [0, 255], matrix, SpreadMethod.PAD);
						shapebase.graphics.drawRect(0, 0, size, size);
						shapebase.cacheAsBitmap = true;
						delayrate = Math.random() * 100;
						break;
					case 3:
						size = 2 + Math.random() * 4;
						matrix.createGradientBox(size, size / 10);
						shapebase.graphics.lineStyle();
						shapebase.graphics.beginGradientFill(GradientType.LINEAR, [0x7028b0, 0x9856d3], [1, 1], [0, 255], matrix, SpreadMethod.PAD);
						shapebase.graphics.drawRect(0, 0, size, size);
						shapebase.cacheAsBitmap = true;
						delayrate = Math.random() * 100;
						break;
					case 4:
						size = 2 + Math.random() * 4;
						matrix.createGradientBox(size, size / 10);
						shapebase.graphics.lineStyle();
						shapebase.graphics.beginGradientFill(GradientType.LINEAR, [0xAC580D, 0x6e3a0d], [1, 1], [0, 255], matrix, SpreadMethod.PAD);
						shapebase.graphics.drawRect(0, 0, size, size);
						shapebase.cacheAsBitmap = true;
						delayrate = Math.random() * 100;
						break;
					case 5:
						size = 2 + Math.random() * 2;
						matrix.createGradientBox(size, size / 10);
						shapebase.graphics.lineStyle();
						shapebase.graphics.beginGradientFill(GradientType.LINEAR, [0x808080, 0xd9d9d9], [1, 1], [0, 255], matrix, SpreadMethod.PAD);
						shapebase.graphics.lineTo(2 + size, 2 + size);
						shapebase.graphics.lineTo( -(2 + size), 2 + size);
						shapebase.graphics.lineTo(0, 0);
						shapebase.cacheAsBitmap = true;
						delayrate = Math.random() * 100;
						break;
					case 6:
						size = 2 + Math.random() * 8;
						matrix.createGradientBox(size, size / 10);
						shapebase.graphics.lineStyle();
						shapebase.graphics.beginGradientFill(GradientType.LINEAR, [0xED7EFA, 0xCC24F7], [1, 1], [0, 255], matrix, SpreadMethod.PAD);
						shapebase.graphics.drawRect(0, 0, size, size);
						shapebase.cacheAsBitmap = true;
						delayrate = Math.random() * 100;
						break;
				}
				addChild(shapebase);
			}else {
				base = new Bitmap(graphic);
				base.x = -base.width / 2;
				base.y = -base.height / 2;
				addChild(base);
				base.cacheAsBitmap = true;
				delayrate = 100 + Math.random() * 200;
			}
			speedx = (Math.random() * powerx) - (Math.random() * powerx);
			gravity = -(Math.random() * gravpower);
		}
		
		public function update():void {
			++delaytimer;
			if (delaytimer >= delayrate) {
				alpha -= .05;
			}
			if (alpha <= 0) {
				removed = true;
			}
			
			var coordx:int = x / 20;
			var coordy:int = y / 20;
			
			if (Main.map.currentrotation == 0) {
				--coordy;
			}else if (Main.map.currentrotation == 90) {
				--coordx; --coordy;
			}else if (Main.map.currentrotation == -90) {
				--coordy;
			}
			
			gravity += .5;
			if (gravity >= 20) {
				gravity = 20;
			}
			//floor collision
			if (gravity >= 0 && !Main.map.collideDown(coordx, coordy).walkable) {
				if (speedx == 0 && gravity >= 5) {
					speedx += Math.random() * 2 - Math.random() * 2;
				}
				gravity = -gravity / 2;
				if (gravity < .5 && gravity > -.5) {
					gravity = 0;
				}
				onground = true;
			}else {
				onground = false;
			}
			if (speedx > 0 && !Main.map.collideRight(coordx, coordy).walkable && !onground) {
				speedx = 0;
			}
			if (speedx < 0 && !Main.map.collideLeft(coordx, coordy).walkable && !onground) {
				speedx = 0;
			}
			//above collision
			if (gravity < 0 && !Main.map.collideUp(coordx, coordy).walkable) {
				gravity = 0;
			}
			if (gravity > 0 && !Main.map.collideDown(coordx, coordy).walkable) {
				gravity = 0;
			}
			
			rotation += speedx;
			speedx = speedx * FRICTION;
			if (speedx < .5 && speedx > -.5) {
				speedx = 0;
			}
			switch (Main.map.currentrotation) {
				case 0:
					x += speedx; y += gravity;
					break;
				case 90:
					y -= speedx; x += gravity;
					break;
				case 180:
					x -= speedx; y -= gravity;
					break;
				case -90:
					y += speedx; x -= gravity;
					break;
			}
			
			if (y >= Main.map.mapheight - height) {
				removed = true;
			}
		}
	}
}