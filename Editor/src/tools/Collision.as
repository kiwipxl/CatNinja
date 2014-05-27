package tools {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import maps.Node;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Collision {
		
		//collision variables
		private static const sides:Array = [1, 0, 0, 1, -1, 0, 0, -1];
		
		public static function inRadius(startx:int, starty:int, x1:int, y1:int, radius:int = 1):Boolean {
			if (startx == x1 && starty == y1) { return true; }
			
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
							var node:Node = Main.map.grid[blocky * Main.map.gridwidth + blockx];
							if (c <= radius - 2 || Math.random() * 1 >= .5) {
								if (blocky != starty + 1 || blockx != startx) {
									if (Main.map.grid[(blocky - 1) * Main.map.gridwidth + blockx].type != 6 || Main.map.currentrotation != 0) {
										if (node.type == 8 || node.type >= 57 && node.type <= 61) {
											Main.particles.create(blockx * 20, blocky * 20, 2, 15, 15, Math.random() * 7, null);
											if (node.type == 8) {
												for (var t:int = 0; t < Main.env.dirts.length; ++t) {
													if (Main.env.dirts[t].coordx == blockx && Main.env.dirts[t].coordy == blocky) {
														Main.env.dirts[t].breakDirt();
														break;
													}
												}
											}else if (node.type >= 57 && node.type <= 60) {
												for (var d:int = 0; d < Main.env.flowers.length; ++d) {
													if (Main.env.flowers[d].coordx == blockx && Main.env.flowers[d].coordy == blocky) {
														Main.env.flowers[d].breakflower();
														break;
													}
												}
											}else {
												Main.map.mapdata.fillRect(new Rectangle(blockx * 20, blocky * 20, 20, 20), 0);
												Main.map.grid[blocky * Main.map.gridwidth + blockx].walkable = true;
											}
										}
									}
								}
							}
							
							if (!node.walkable) {
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