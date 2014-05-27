package ui {
	
	import entities.ScriptObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Menu {
		
		//menu variables
		private var musicpausebutton:Button;
		private var soundpausebutton:Button;
		private var pausebutton:Button;
		private var exitbutton:Button;
		public var navbar:Sprite;
		private var lastsfxvolume:Number = 0;
		private var lastmusicvolume:Number = 0;
		public var musicpaused:Boolean = false;
		public var pausewindow:Shape = new Shape();
		private var musicturnedoff:Boolean = false;
		private var soundturnedoff:Boolean = false;
		public var exitedmap:Boolean = false;
		
		public function create():void {
			navbar = new Sprite();
			navbar.graphics.beginFill(0x000000, .5);
			navbar.graphics.drawRect(0, 0, 25, 126);
			navbar.x = 775; navbar.y = 0;
			Main.universe.addChild(navbar);
			
			musicpausebutton = new Button("", 3, 8, 1, togglemusic);
			soundpausebutton = new Button("", 3, 38, 3, togglesound);
			pausebutton = new Button("", 3, 68, 5, togglepause);
			exitbutton = new Button("", 3, 98, 6, exitclick);
			
			navbar.addChild(musicpausebutton);
			navbar.addChild(soundpausebutton);
			navbar.addChild(pausebutton);
			navbar.addChild(exitbutton);
			
			musicpausebutton.start(musicpausebutton);
			soundpausebutton.start(soundpausebutton);
			pausebutton.start(pausebutton);
			exitbutton.start(exitbutton);

			pausewindow.graphics.beginFill(0x000000, .4);
			pausewindow.graphics.drawRect(0, 0, 800, 600);
			Main.universe.addChild(pausewindow);
			pausewindow.visible = false;
		}
		
		public function togglemusic():void {
			if (musicpausebutton.button.bitmapData == Preloader.musicbutton) {
				musicoff();
			}else {
				musicon();
			}
		}

		private function musicoff():void {
			if (Main.sound.maxvolume != 0) {
				musicpausebutton.button.bitmapData = Preloader.musicbuttonoff;
				lastmusicvolume = Main.sound.maxvolume;
				Main.sound.maxvolume = 0;
				Main.sound.soundtransform.volume = 0;
				Main.sound.musicchannel.soundTransform = Main.sound.soundtransform;
				musicpaused = true;
			}
		}

		private function musicon():void {
			if (Main.sound.maxvolume == 0) {
				if (Main.sound.targetsound != null) {
					musicpausebutton.button.bitmapData = Preloader.musicbutton;
					Main.sound.maxvolume = lastmusicvolume;
					Main.sound.soundtransform.volume = lastmusicvolume;
					Main.sound.musicchannel.soundTransform = Main.sound.soundtransform;
				}
				musicpaused = false;
			}
		}

		private function soundoff():void {
			if (Main.sound.maxsfxvolume != 0) {
				soundpausebutton.button.bitmapData = Preloader.soundbuttonoff;
				lastsfxvolume = Main.sound.maxsfxvolume;
				Main.sound.maxsfxvolume = 0;
			}
		}

		private function soundon():void {
			if (Main.sound.maxsfxvolume == 0) {
				soundpausebutton.button.bitmapData = Preloader.soundbutton;
				Main.sound.maxsfxvolume = lastsfxvolume;
			}
		}
		
		public function togglesound():void {
			if (soundpausebutton.button.bitmapData == Preloader.soundbutton) {
				soundoff();
			}else {
				soundon();
			}
		}
		
		public function changepausegraphics():void {
			if (!Main.gamepaused) {
				Main.universe.setChildIndex(pausewindow, Main.universe.numChildren - 1);
				pausebutton.button.bitmapData = Preloader.playbuttonui;
				pausewindow.visible = true;
				if (Main.sound.maxvolume != 0) {
					musicoff();
					musicturnedoff = false;
				}else {
					musicturnedoff = true;
				}
				if (Main.sound.maxsfxvolume != 0) {
					soundoff();
					soundturnedoff = false;
				}else {
					soundturnedoff = true;
				}
			}else {
				pausebutton.button.bitmapData = Preloader.pausebuttonui;
				pausewindow.visible = false;
				if (!musicturnedoff) {
					musicon();
				}
				if (!soundturnedoff) {
					soundon();
				}
			}
		}
		
		public function togglepause():void {
			changepausegraphics();
			Main.gamepaused = (Main.gamepaused) ? false : true;
		}

		public function pause():void {
			if (!Main.gamepaused) {
				changepausegraphics();
				Main.gamepaused = true;
			}
		}

		public function resume():void {
			if (Main.gamepaused) {
				changepausegraphics();
				Main.gamepaused = false;
			}
		}
		
		public function exitclick():void {
			if (Main.map.currentLevel != -1 && !Main.player.dead && !Main.map.rotating && Main.map.currentLevel <= 27) {
				exitedmap = true;
				Main.map.playerpoints[8] = -1;
				Main.map.savedx = Main.player.x;
				Main.map.savedy = Main.player.y;
				Main.map.saveddestrotation = Main.map.destrotate;
				Main.map.savedworldrotation = Main.world.rotation;
				Main.map.moveDown();
			}
		}
	}
}