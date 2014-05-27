package editor {
	
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.ui.Mouse;
	import tools.images.ColourChanger;
	import maps.MapDetails;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class MapResizer {
		
		//mapresizer variables
		public var parent:MapCreator;
		public var mapresizer:Bitmap;
		private var mapresizerdata:BitmapData;
		public var mapxoffset:int = 200;
		public var mapyoffset:int = 200;
		public var resizing:Boolean = false;
		private var x:int = 0;
		private var y:int = 0;
		
		public function checkborders():void {
			var gpx:int = (parent.tileplacer.x - parent.map.x) / 20;
			var gpy:int = (parent.tileplacer.y - parent.map.y) / 20;
			
			if (gpx == 0 || gpx == parent.gridwidth - 1) {
				Main.mapeditor.ui.cursor.bitmapData = Main.textures.resizearrowvertical;
				Main.mapeditor.ui.cursor.visible = true;
				resizing = true;
				Mouse.hide();
				parent.starttilepos.x = gpx; parent.starttilepos.y = gpy;
			}else if (gpy == 0 || gpy == parent.gridheight - 1) {
				Main.mapeditor.ui.cursor.bitmapData = Main.textures.resizearrowhorizontal;
				Main.mapeditor.ui.cursor.visible = true;
				resizing = true;
				Mouse.hide();
				parent.starttilepos.x = gpx; parent.starttilepos.y = gpy;
			}else if (Main.mapeditor.ui.cursor.visible && resizing) {
				Main.mapeditor.ui.cursor.visible = false;
				resizing = false;
				Mouse.show();
			}
			Main.mapeditor.setoverlay();
			if (mapresizer) { 
				if ( -(parent.starttilepos.x - gpx) != 0 || -(parent.starttilepos.y - gpy) != 0) {
					if (parent.starttilepos.x == 0) {
						if (parent.starttilepos.x - gpx > 0) { negResizeX(mapresizer.width / 20);
						}else { negResizeXRemove(mapresizer.width / 20); }
						resizeMap(parent.gridwidth, parent.gridheight);
					}else if (parent.starttilepos.x == parent.gridwidth - 1) {
						if (-(parent.starttilepos.x - gpx) > 0) { resizeMap(parent.gridwidth + (mapresizer.width / 20), parent.gridheight);
						}else { resizeMap(parent.gridwidth - (mapresizer.width / 20), parent.gridheight); }
					}else if (parent.starttilepos.y == 0) {
						if (parent.starttilepos.y - gpy > 0) { negResizeY(mapresizer.height / 20);
						}else { negResizeYRemove(mapresizer.height / 20); }
						resizeMap(parent.gridwidth, parent.gridheight);
					}else if (parent.starttilepos.y == parent.gridheight - 1) {
						if (-(parent.starttilepos.y - gpy) > 0) { resizeMap(parent.gridwidth, parent.gridheight + (mapresizer.height / 20));
						}else { resizeMap(parent.gridwidth, parent.gridheight - (mapresizer.height / 20)); }
					}
				}
				
				parent.gridwidth = parent.map.width / 20;
				parent.gridheight = parent.map.height / 20;
				Main.universe.removeChild(mapresizer); mapresizerdata.dispose(); mapresizer = null; mapresizerdata = null; 
				mapxoffset = 200; mapyoffset = 200;
			}
		}
		
		public function updatefilleffect():void {
			var gridx:int = parent.tileplacer.x / 20;
			var gridy:int = parent.tileplacer.y / 20;
			var gpx:int = (parent.tileplacer.x - parent.map.x) / 20;
			var gpy:int = (parent.tileplacer.y - parent.map.y) / 20;
			
			if (!Main.mapeditor.mouseIsDown && Main.mapeditor.ctrlKeyDown) {
				checkborders();
			}else if (resizing && Main.mapeditor.ctrlKeyDown) {
				if (parent.starttilepos.x == 0) {
					filleffect((parent.starttilepos.x - gpx) * 20, (parent.starttilepos.x * 20) + parent.map.x, parent.map.y);
					if (parent.starttilepos.x - gpx > 0) { mapxoffset += (parent.starttilepos.x - gpx) * 20; }
				}else if (parent.starttilepos.x == parent.gridwidth - 1) {
					filleffect((parent.starttilepos.x - gpx) * 20, (parent.starttilepos.x * 20) + parent.map.x + 20, parent.map.y, false);
					if (parent.starttilepos.x - gpx < 0) { mapxoffset -= (parent.starttilepos.x - gpx) * 20; }
				}else if (parent.starttilepos.y == 0) {
					filleffect((parent.starttilepos.y - gpy) * 20, parent.map.x, (parent.starttilepos.y * 20) + parent.map.y, true, false);
					if (parent.starttilepos.y - gpy > 0) { mapyoffset += (parent.starttilepos.y - gpy) * 20; }
				}else if (parent.starttilepos.y == parent.gridheight - 1) {
					filleffect((parent.starttilepos.y - gpy) * 20, parent.map.x, (parent.starttilepos.y * 20) + parent.map.y + 20, false, false);
					if (parent.starttilepos.y - gpy < 0) { mapyoffset -= (parent.starttilepos.y - gpy) * 20; }
				}
			}
		}
		
		private function filleffect(distance:int, mapx:int, mapy:int, gt:Boolean = true, xfill:Boolean = true):void {
			if (distance != 0) {
				if (!mapresizer || mapresizer) {
					var width:int = parent.map.width;
					var height:int = parent.map.height;
					
					if (mapresizer) { mapresizerdata.dispose(); }
					if (parent.starttilepos.x == 0 && Math.abs(distance) > width - 800 && distance < 0) { distance = -(width - 800);
					}else if (parent.starttilepos.x == parent.gridwidth - 1 && distance > width - 800 && distance > 0) { distance = width - 800;
					}else if (parent.starttilepos.y == parent.gridheight - 1 && distance > height - 600 && distance > 0) { distance = height - 600;
					}else if (parent.starttilepos.y == 0 && Math.abs(distance) > height - 600 && distance < 0) { distance = -(height - 600); }
					
					if (parent.starttilepos.x == 0 && distance + width  > parent.MAXWIDTH * 20) { distance = (parent.MAXWIDTH * 20) - width ;
					}else if (parent.starttilepos.x == parent.gridwidth - 1 && -distance + width  > parent.MAXWIDTH * 20) { distance = -(parent.MAXWIDTH * 20) + width;
					}else if (parent.starttilepos.y == parent.gridheight - 1 && -distance + height > parent.MAXHEIGHT * 20) { distance = -(parent.MAXHEIGHT * 20) + height;
					}else if (parent.starttilepos.y == 0 && distance + height > parent.MAXHEIGHT * 20) { distance = (parent.MAXHEIGHT * 20) - height; }
					
					if (distance != 0) {
						if (xfill) { mapresizerdata = new BitmapData(Math.abs(distance), height, false, 0);
						}else { mapresizerdata = new BitmapData(width, Math.abs(distance), false, 0); }
						
						for (var ypos:int = 0; ypos < int(mapresizerdata.height / 20); ++ypos) {
							for (var xpos:int = 0; xpos < int(mapresizerdata.width / 20); ++xpos) {
								parent.drawDataByType(0, xpos, ypos, mapresizerdata);
							}
						}
						if (!mapresizer) { mapresizer = new Bitmap(mapresizerdata); Main.universe.addChild(mapresizer); Main.mapeditor.setoverlay(); }
						mapresizer.bitmapData = mapresizerdata;
						mapresizer.x = mapx; mapresizer.y = mapy;
						
						if (distance > 0) {
							mapresizer.transform.colorTransform = parent.greentransformheavy;
							if (xfill) { mapresizer.x -= Math.abs(distance);
							}else { mapresizer.y -= Math.abs(distance); }
							if (!gt) { mapresizer.transform.colorTransform = parent.redtransformheavy; }
						}else {
							mapresizer.transform.colorTransform = parent.redtransformheavy;
							if (!gt) { mapresizer.transform.colorTransform = parent.greentransformheavy; }
						}
					}
				}
			}
		}
		
		public function resizeMap(w:int, h:int, forceresize:Boolean = false):void {
			if (w < 40 && !forceresize || h < 30 && !forceresize || w > parent.MAXWIDTH || h > parent.MAXHEIGHT) { return; }
			var x:int = 0; var y:int = 0;
			Main.universe.removeChild(parent.map);
			parent.map.bitmapData.dispose();
			parent.map = new Bitmap();
			parent.mapdata = new BitmapData(w * 20, h * 20, true, 0);
			var oldgrid:Array = parent.grid.concat();
			var oldbgtiles:Array = parent.backgroundtiles.concat();
			parent.grid.length = 0;
			parent.backgroundtiles.length = 0;
			Main.mapeditor.mapcreator.details.finishtiles = 0;
			
			//display map
			for (x = 0; x < w; ++x) {
				for (y = 0; y < h; ++y) {
					var type:int;
					var bgtype:int;
					if (x >= parent.gridwidth) {
						type = 0;
						bgtype = 0;
					}else {
						type = oldgrid[y * parent.gridwidth + x];
						bgtype = oldbgtiles[y * parent.gridwidth + x];
						if (type == 58) { ++Main.mapeditor.mapcreator.details.finishtiles; }
					}
					parent.drawDataByType(type, x, y, parent.mapdata, true, false, 20, 20, false, bgtype);
					parent.grid[y * w + x] = type;
					parent.backgroundtiles[y * w + x] = bgtype;
				}
			}
			oldgrid.length = 0;
			oldbgtiles.length = 0;
			
			parent.gridwidth = w; parent.gridheight = h;
			
			parent.map.bitmapData = parent.mapdata; //apply data to graphical display object
			Main.universe.addChild(parent.map); //add the map to the display stage
			
			parent.colourchanger.container = parent.map;
			
			Main.mapeditor.setoverlay();
			
			parent.map.x = Main.mapeditor.mapx; parent.map.y = Main.mapeditor.mapy;
			Main.mapeditor.mapx = 0; Main.mapeditor.mapy = 0;
		}
		
		public function negResizeX(w:int):void {
			var rowx:int = 0;
			if (w < 0) {
				negResizeXRemove(Math.abs(w));
				return;
			}
			
			if (parent.gridwidth + w < 40) { return; }
			
			for (y = 0; y < w; ++y) {
				for (x = 0; x < parent.gridheight; ++x) {
					parent.grid.splice(rowx * parent.gridwidth + x, 0, 0);
					parent.backgroundtiles.splice(rowx * parent.gridwidth + x, 0, 0);
					++rowx;
				}
				rowx = -1;
				++parent.gridwidth;
			}
		}
		
		public function negResizeXRemove(w:int):void {
			if (parent.gridwidth + w < 40) { return; }
			
			var newgrid:Array = [];
			var newbggrid:Array = [];
			for (y = 0; y < parent.gridheight; ++y) {
				for (x = w; x < parent.gridwidth; ++x) {
					newgrid.push(parent.grid[y * parent.gridwidth + x]);
					newbggrid.push(parent.backgroundtiles[y * parent.gridwidth + x]);
				}
			}
			parent.gridwidth -= w;
			parent.grid = newgrid;
			parent.backgroundtiles = newbggrid;
		}
		
		public function negResizeY(h:int):void {
			var rowy:int = 0;
			if (h < 0) {
				negResizeYRemove(Math.abs(h));
				return;
			}
			
			if (parent.gridheight + h  < 30) { return; }
			
			for (x = 0; x < h; ++x) {
				for (y = 0; y < parent.gridwidth; ++y) {
					parent.grid.splice(x * parent.gridwidth + y, 0, 0);
					parent.backgroundtiles.splice(x * parent.gridwidth + y, 0, 0);
				}
				++parent.gridheight;
			}
		}
		
		public function negResizeYRemove(h:int):void {
			if (parent.gridheight + h < 30) { return; }
			
			var newgrid:Array = [];
			var newbggrid:Array = [];
			for (x = h; x < parent.gridheight; ++x) {
				for (y = 0; y < parent.gridwidth; ++y) {
					newgrid.push(parent.grid[x * parent.gridwidth + y]);
					newbggrid.push(parent.backgroundtiles[x * parent.gridwidth + y]);
				}
			}
			parent.gridheight -= h;
			parent.grid = newgrid;
			parent.backgroundtiles = newbggrid;
		}
		
		public function flipx():void {
			var newgrid:Array = [];
			for (var y:int = 0; y < parent.gridheight; ++y) {
				var temp:Array = [];
				for (var x:int = 0; x < parent.gridwidth; ++x) {
					temp[x] = parent.grid[y * parent.gridwidth + x];
				}
				for (var i:int = parent.gridwidth - 1; i > -1; --i) {
					newgrid.push(temp[i]);
				}
			}
			parent.grid = newgrid;
			parent.refreshMap();
		}
	}
}