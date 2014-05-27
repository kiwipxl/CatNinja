package editor.components {
	
	import editor.EditorUI;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class ToolTip {
		
		//tooltip variables
		public const tileinfo:Array = ["Light tile", "Spawn point of kitty", "Solid block", "Dark tile", "Very dark tile", "Spike", "Spike", 
		"Spike", "Spike", "Wall mine", "Wall mine", "Wall mine", "Wall mine", "Dirt block", "Sticky wall (Cannot wall jump on)", "Sticky wall (Cannot wall jump on)", 
		"Sticky wall (Cannot wall jump on)", "Sticky wall (Cannot wall jump on)", "Jetpack upgrade", "Gravity boost up", 
		"Gravity boost right", "Gravity boost left", "Gravity boost down", "Spring", "Spring", "Spring", "Spring", "No rotation gravity block", "No rotation gravity block", 
		"No rotation gravity block", "No rotation gravity block", "Missle shooter", "Missle Shooter", "Missle shooter", "Missle shooter", 
		"Homing missle shooter", "Homing missle shooter", "Homing missle shooter", "Homing missle shooter", "Magnet", "Magnet", "Magnet", "Magnet", 
		"Speedup upgrade", "Hallucinative downgrade", "Gravity down", "Gravity left", "Gravity right", "Gravity up", "Falling spikes up", "Falling spikes down", 
		"Falling spikes right", "Falling spikes left", "Sunspike (must be placed adjacent to block", "Flower", "Flower", "Flower", "Flower", "Grass block", "Competion block", 
		"Breakable glass", "Toxic flower", "Toxic flower", "Toxic flower", "Toxic flower", "Brick", "Checkpoint", "Laser base", "Laser base", "Laser base", "Laser base", 
		"Laser", "Laser", "Floating mine", "Floating mine", "Floating mine", "Floating mine", "Water", "Icy tile", "Icy tile", "Icy tile", "Icy tile", "Snow block", 
		"Coral", "Coral", "Coral", "Coral", "Sphere collectable", "Red block", "Green block", "Blue block", "Black block", "Yellow block", "Lava", "Lava suit"];
		public var tileinfobox:Sprite = new Sprite();
		private var tileinfotext:TextField = new TextField();
		private var infoformat:TextFormat;
		private var parent:EditorUI;
		
		public function initiate():void {
			parent = Main.mapeditor.ui;
			
			infoformat = new TextFormat();
			infoformat.align = "center";
			infoformat.font = "square";
			tileinfotext.defaultTextFormat = infoformat;
			tileinfotext.embedFonts = true;
			tileinfotext.textColor = 0xFFFFFF;
			tileinfotext.selectable = false;
			tileinfobox.addChild(tileinfotext);
			Main.universe.addChild(tileinfobox);
		}
		
		public function remove():void {
			Main.universe.removeChild(tileinfobox);
		}
		
		public function showtileinfobox(text:String, x:int, y:int):void {
			tileinfobox.graphics.clear();
			tileinfotext.htmlText = text;
			tileinfotext.width = tileinfotext.textWidth + 5;
			tileinfotext.x = 5; tileinfotext.y = 5;
			tileinfotext.defaultTextFormat = infoformat;
			tileinfobox.graphics.lineStyle(1, 0x000000);
			tileinfobox.graphics.beginFill(0x000000, .8);
			tileinfobox.graphics.drawRect(0, 0, tileinfotext.textWidth + 10, 25);
			tileinfobox.visible = true;
			tileinfobox.x = x;
			tileinfobox.y = y;
			if (x + tileinfotext.width >= 800) {
				tileinfobox.scaleX = -1;
				tileinfotext.scaleX = -1;
				tileinfotext.x = tileinfotext.width;
				tileinfobox.x -= 22;
			}else {
				tileinfobox.scaleX = 1;
				tileinfotext.scaleX = 1;
			}
			
			Main.universe.setChildIndex(tileinfobox, Main.universe.numChildren - 1);
		}
		
		public function update():void {
			if (parent.testbutton.stage && parent.testbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Tests your map", parent.testbutton.x + 25, parent.testbutton.y + 25);
			}else if (parent.testbutton.stage && parent.settingsbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Menu where you can change <font color='#6eec59'>game settings</font> and <font color='#d659e1'>publish</font> your map", 
				parent.settingsbutton.x + 25, parent.settingsbutton.y + 25);
			}else if (parent.testbutton.stage && parent.loadbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Brings up the <font color='#d659e1'>Loaded games menu</font>", parent.loadbutton.x + 25, parent.loadbutton.y + 25);
			}else if (parent.testbutton.stage && parent.savebutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("<font color='#d659e1'>Saves </font> the current map to a local save file", parent.savebutton.x + 25, parent.savebutton.y + 25);
			}else if (parent.testbutton.stage && parent.helpbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("<font color='#6eec59'>Need some help? Click here.</font>", parent.helpbutton.x + 25, parent.helpbutton.y + 25);
			}else if (parent.testbutton.stage && parent.clearbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Clears <font color='#f18686'>everything</font> on the map", parent.clearbutton.x + 25, parent.clearbutton.y + 25);
			}else if (parent.testbutton.stage && parent.roombutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Opens the room manager where you can create rooms! <font color='#6eec59'>(Shortcut: M)</font>", 
				parent.roombutton.x + 25, parent.roombutton.y + 25);
			}else if (parent.testbutton.stage && parent.sizeaddbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Makes the paintbrush larger <font color='#6eec59'>(Shortcut: +)</font>", parent.sizeaddbutton.x + 25, parent.sizeaddbutton.y + 25);
			}else if (parent.testbutton.stage && parent.sizesubtractbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Makes the paintbrush smaller <font color='#6eec59'>(Shortcut: -)</font>", parent.sizesubtractbutton.x + 25, parent.sizesubtractbutton.y + 25);
			}else if (parent.testbutton.stage && parent.emptytilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Eraser tiles (Background tiles)", parent.emptytilesbutton.x + 25, parent.emptytilesbutton.y + 10);
				if (parent.currentwindowindex != 0) { parent.opentilemenu(parent.emptytilesdata, 0); }
			}else if (parent.testbutton.stage && parent.blocktilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Solid block tiles", parent.blocktilesbutton.x + 25, parent.blocktilesbutton.y + 10);
				if (parent.currentwindowindex != 1) { parent.opentilemenu(parent.blocktilesdata, 1); }
			}else if (parent.testbutton.stage && parent.environmenttilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Action tiles", parent.environmenttilesbutton.x + 25, parent.environmenttilesbutton.y + 10);
				if (parent.currentwindowindex != 2) { parent.opentilemenu(parent.environmenttilesdata, 2); }
			}else if (parent.testbutton.stage && parent.upgradetilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Upgrade tiles", parent.upgradetilesbutton.x + 25, parent.upgradetilesbutton.y + 10);
				if (parent.currentwindowindex != 3) { parent.opentilemenu(parent.upgradetilesdata, 3); }
			}else if (parent.testbutton.stage && parent.misctilesbutton.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				showtileinfobox("Appearance tiles", parent.misctilesbutton.x + 25, parent.misctilesbutton.y + 10);
				if (parent.currentwindowindex != 4) { parent.opentilemenu(parent.misctilesdata, 4); }
			}else {
				tileinfobox.visible = false;
			}
			if (Main.mapeditor.ui.tilewindowopened && !parent.tiledatawindow.hitTestPoint(Main.universe.mouseX, Main.universe.mouseY)) {
				if (Main.universe.mouseX <= parent.tiledatawindow.x - 100 || Main.universe.mouseX >= parent.tiledatawindow.x + 100 &&
				Main.universe.mouseY <= parent.tiledatawindow.y + parent.tiledatawindow.height ||
				Main.universe.mouseY >= parent.tiledatawindow.y + parent.tiledatawindow.height + 100) {
					parent.hidetilemenu();
				}
			}
		}
	}
}