package ui {
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Menu {
		
		//menu variables
		private var musicpausebutton:Button;
		private var soundpausebutton:Button;
		private var pausebutton:Button;
		public var navbar:Sprite;
		private var lastsfxvolume:Number = 0;
		private var lastmusicvolume:Number = 0;
		public var musicpaused:Boolean = false;
		public var pausewindow:Shape = new Shape();
		private var musicturnedoff:Boolean = false;
		private var soundturnedoff:Boolean = false;
		public var exitedmap:Boolean = false;
		
		//instruction page variables
		public var instructionpage:Bitmap;
		private var page:int = 0;
		private var nextbutton:Button;
		private var prevbutton:Button;
		private var closebutton:Button;
		
		public function create():void {
			navbar = new Sprite();
			navbar.graphics.beginFill(0x000000, .5);
			navbar.graphics.drawRect(0, 0, 25, 95);
			navbar.x = 775; navbar.y = 0;
			Main.universe.addChild(navbar);
			
			musicpausebutton = new Button("", 3, 8, 2, togglemusic);
			soundpausebutton = new Button("", 3, 38, 4, togglesound);
			pausebutton = new Button("", 3, 68, 6, togglepause);
			
			navbar.addChild(musicpausebutton);
			navbar.addChild(soundpausebutton);
			navbar.addChild(pausebutton);
			
			musicpausebutton.start();
			soundpausebutton.start();
			pausebutton.start();
			
			pausewindow.graphics.beginFill(0x000000, .4);
			pausewindow.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			pausewindow.graphics.lineStyle(1, 0xBCBCBC, .5);
			pausewindow.graphics.beginFill(0xBCBCBC, .5);
			pausewindow.graphics.drawRect((Main.universe.stageWidth / 2) - 180, (Main.universe.stageHeight / 2) - 150, 80, 300);
			pausewindow.graphics.drawRect((Main.universe.stageWidth / 2) + 100, (Main.universe.stageHeight / 2) - 150, 80, 300);
			Main.universe.addChild(pausewindow);
			pausewindow.visible = false;
		}
		
		public function hidepause():void {
			navbar.graphics.clear();
			navbar.graphics.beginFill(0x000000, .5);
			navbar.graphics.drawRect(0, 0, 25, 65);
			navbar.x = Main.universe.stageWidth - 25; navbar.y = 0;
			
			if (pausebutton.stage) { navbar.removeChild(pausebutton); }
		}
		
		public function showpause():void {
			navbar.graphics.clear();
			navbar.graphics.beginFill(0x000000, .5);
			navbar.graphics.drawRect(0, 0, 25, 95);
			navbar.x = Main.universe.stageWidth - 25; navbar.y = 0;
			
			if (!pausebutton.stage) { navbar.addChild(pausebutton); }
		}
		
		public function togglemusic():void {
			if (Main.sound.fadingmusic) { return; }
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
				if (Main.sound.musicchannel) { Main.sound.musicchannel.soundTransform = Main.sound.soundtransform; }
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
			if (Main.sound.fadingmusic) { return; }
			if (Main.sound.maxsfxvolume != 0) {
				soundpausebutton.button.bitmapData = Preloader.soundbuttonoff;
				lastsfxvolume = Main.sound.maxsfxvolume;
				Main.sound.maxsfxvolume = 0;
			}
		}
		
		private function soundon():void {
			if (Main.sound.fadingmusic) { return; }
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
			if (Main.countdown.created) { return; }
			changepausegraphics();
			Main.gamepaused = (Main.gamepaused) ? false : true;
			focus(Main.gamepaused);
		}
		
		public function pause():void {
			if (Main.countdown.created) { return; }
			if (!Main.gamepaused) {
				changepausegraphics(); Main.gamepaused = true;
			}
		}
		
		public function resume():void {
			if (Main.gamepaused) {
				changepausegraphics(); Main.gamepaused = false;
			}
		}
		
		public function focus(out:Boolean):void {
			if (Main.outoffocus && out) {
				if (!Main.countdown.created) { Main.mapmanager.lasttimer = getTimer(); }
				Main.outoffocus = false;
			}else if (!Main.outoffocus && !out) {
				if (!Main.countdown.created) {
					Main.mapmanager.idletimer += getTimer() - Main.mapmanager.lasttimer;
					Main.mapmanager.lasttimer = getTimer();
					Main.mapmanager.calculatetimer();
				}
				Main.outoffocus = true;
			}
		}
		
		public function showhelp():void {
			instructionpage = new Bitmap(Main.textures.instructionspage1);
			
			Main.mapeditor.ui.pausewindow.visible = true;
			Main.mapeditor.ui.settingswindow.showingsettings = true;
			Main.universe.addChild(instructionpage);
			instructionpage.x = Main.halfwidth - (instructionpage.width / 2);
			instructionpage.y = Main.halfheight - (instructionpage.height / 2);
			
			prevbutton = new Button("Previous", instructionpage.x + 15, instructionpage.y + instructionpage.height - 42, 1, function():void {
				--page; updatepage();
			}, 15);
			closebutton = new Button("Close", instructionpage.x + (instructionpage.width / 2) - 35, instructionpage.y + instructionpage.height - 42, 1, hidehelp, 15);
			nextbutton = new Button("Next", instructionpage.x + instructionpage.width - 90, instructionpage.y + instructionpage.height - 42, 1, function():void {
				++page; updatepage();
			}, 15);
			Main.universe.addChild(prevbutton);
			Main.universe.addChild(closebutton);
			Main.universe.addChild(nextbutton);
			
			updatepage();
		}
		
		public function hidehelp():void {
			Main.mapeditor.ui.pausewindow.visible = false;
			Main.mapeditor.ui.settingswindow.showingsettings = false;
			Main.universe.removeChild(instructionpage);
			
			prevbutton.removelisteners();
			closebutton.removelisteners();
			nextbutton.removelisteners();
			Main.universe.removeChild(prevbutton);
			Main.universe.removeChild(closebutton);
			Main.universe.removeChild(nextbutton);
			prevbutton = null;
			closebutton = null;
			nextbutton = null;
			Main.universe.focus = null;
		}
		
		public function updatepage():void {
			if (page == 0 || page == 3) {
				page = 0;
				instructionpage.bitmapData = Main.textures.instructionspage1;
			}else if (page == 1) {
				page = 1;
				instructionpage.bitmapData = Main.textures.instructionspage2;
			}else if (page == 2 || page == -1) {
				page = 2;
				instructionpage.bitmapData = Main.textures.instructionspage3;
			}
		}
	}
}