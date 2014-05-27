package tools {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Collision {
		
		//collision variables
		private static const sides:Array = [1, 0, 0, 1, -1, 0, 0, -1];
		
		public static function inRadius(startx:int, starty:int, x1:int, y1:int, radius:int = 1):Boolean {
			for (var c:int = 0; c < radius; ++c) {
				var lastx:int = -1 - c;
				var lasty:int = -1 - c;
				for (var u:int = 0; u < sides.length; u += 2) {
					var posx:int = lastx;
					var posy:int = lasty;
					for (var p:int = 0; p < (c + 1) * 2; ++p) {
						var blockx:int = startx + posx;
						var blocky:int = starty + posy;
						if (blockx > 0 && blockx < Main.map.gridwidth && blocky > 0 && blocky < Main.map.gridheight) {
							if (!Main.map.grid[blocky * Main.map.gridwidth + blockx].walkable) {
								if (blockx != Main.player.coordx || blocky != Main.player.coordy) {
									posx += sides[u]; posy += sides[u + 1]; lastx = posx; lasty = posy;
									continue;
								}
							}
							posx += sides[u]; posy += sides[u + 1]; lastx = posx; lasty = posy;
							if (x1 == blockx && y1 == blocky) {
								return true;
							}
						}else {
							return false;
						}
					}
				}
			}
			return false;
		}
	}
}