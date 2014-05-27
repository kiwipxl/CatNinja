package managers {
	
	import editor.trackmill.ui.UIManager;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class SoundManager {
		
		//soundmanager variables
		public var chiptunemusic:Sound;
		public var bossmusic:Sound;
		public var oxygenmusic:Sound;
		public var aztecmusic:Sound;
		public var desertplains:Sound;
		public var forceofcold:Sound;
		public var mysteriousmystery:Sound;
		public var grasslands:Sound;
		public var microbe:Sound;
		public var bitfunk:Sound;
		
		[Embed(source = "../../lib/sound/music/menu.mp3")]
		private const menuclass:Class;
		public const menu:Sound = new menuclass();
		
		//soundeffect variables
		[Embed(source = "../../lib/sound/soundeffects/crate.mp3")] private const crateclass:Class;
		private const crate:Sound = new crateclass();
		[Embed(source = "../../lib/sound/soundeffects/crystal.mp3")] private const crystalclass:Class;
		private const crystal:Sound = new crystalclass();
		[Embed(source = "../../lib/sound/soundeffects/doublejump.mp3")] private const doublejumpclass:Class;
		private const doublejump:Sound = new doublejumpclass();
		[Embed(source = "../../lib/sound/soundeffects/explosion1.mp3")] private const explosion1class:Class;
		private const explosion1:Sound = new explosion1class();
		[Embed(source = "../../lib/sound/soundeffects/explosion2.mp3")] private const explosion2class:Class;
		private const explosion2:Sound = new explosion2class();
		[Embed(source = "../../lib/sound/soundeffects/jump.mp3")] private const jumpclass:Class;
		private const jump:Sound = new jumpclass();
		[Embed(source = "../../lib/sound/soundeffects/mine.mp3")] private const mineclass:Class;
		private const mine:Sound = new mineclass();
		[Embed(source = "../../lib/sound/soundeffects/powerup.mp3")] private const powerupclass:Class;
		private const powerup:Sound = new powerupclass();
		[Embed(source = "../../lib/sound/soundeffects/reveal.mp3")] private const revealclass:Class;
		private const reveal:Sound = new revealclass();
		[Embed(source = "../../lib/sound/soundeffects/rotate.mp3")] private const rotateclass:Class;
		private const rotate:Sound = new rotateclass();
		[Embed(source = "../../lib/sound/soundeffects/shoot.mp3")] private const shootclass:Class;
		private const shoot:Sound = new shootclass();
		[Embed(source = "../../lib/sound/soundeffects/slam.mp3")] private const slamclass:Class;
		private const slam:Sound = new slamclass();
		[Embed(source = "../../lib/sound/soundeffects/spring.mp3")] private const springclass:Class;
		private const spring:Sound = new springclass();
		[Embed(source = "../../lib/sound/soundeffects/teleport.mp3")] private const teleportclass:Class;
		private const teleport:Sound = new teleportclass();
		[Embed(source = "../../lib/sound/soundeffects/respawn.mp3")] private const respawnclass:Class;
		private const respawn:Sound = new respawnclass();
		[Embed(source = "../../lib/sound/soundeffects/buttonclick.mp3")] private const buttonclickclass:Class;
		private const buttonclick:Sound = new buttonclickclass();
		[Embed(source = "../../lib/sound/soundeffects/hit.mp3")] private const hit1class:Class;
		private const hit1:Sound = new hit1class();
		[Embed(source = "../../lib/sound/soundeffects/hit2.mp3")] private const hit2class:Class;
		private const hit2:Sound = new hit2class();
		[Embed(source = "../../lib/sound/soundeffects/beep.mp3")] private const beepclass:Class;
		private const beep:Sound = new beepclass();
		[Embed(source = "../../lib/sound/soundeffects/beep2.mp3")] private const beep2class:Class;
		private const beep2:Sound = new beep2class();
		
		//music control variables
		public var musicchannel:SoundChannel;
		public var soundtransform:SoundTransform = new SoundTransform();
		public var targetsound:Sound;
		public var fadingmusic:Boolean = false;
		private var fadein:Boolean = false;
		private var fadeout:Boolean = false;
		private var doublefade:Boolean = false;
		private var faded:Boolean = false;
		public var maxvolume:Number = .5;
		public var maxsfxvolume:Number = .5;
		public var currvolume:Number = .5;
		public var musiclist:Vector.<Sound> = new Vector.<Sound>;
		
		//soundeffect control variables
		public var sfxchannel:SoundChannel;
		private var sfxtransform:SoundTransform = new SoundTransform();
		
		public function initiatemusic():void {
			chiptunemusic = new Sound(); bossmusic = new Sound(); oxygenmusic = new Sound(); aztecmusic = new Sound();
			desertplains = new Sound(); forceofcold = new Sound(); mysteriousmystery = new Sound(); grasslands = new Sound();
			microbe = new Sound(); bitfunk = new Sound();
			musiclist.push(chiptunemusic, bossmusic, oxygenmusic, aztecmusic, desertplains, forceofcold, mysteriousmystery, grasslands, 
			microbe, bitfunk);
		}
		
		public function collectmusic():void {
			initiatemusic();
			
			var songid:int = Math.random() * musiclist.length;
			getsong(songid, true);
			Main.mapmanager.songid = songid;
			Main.mapeditor.ui.settingswindow.musicitembox.lastvaliditem = songid;
			Main.mapeditor.ui.settingswindow.musicitembox.selecteditem = songid;
			Main.mapeditor.ui.settingswindow.musicitembox.lastselecteditem = songid;
		}
		
		public function getsong(id:int, firstsong:Boolean = false, playsongwhenloaded:Boolean = false, success:Function = null, error:Function = null):void {
			if (!musiclist[id].isBuffering && musiclist[id].length == 0) {
				var songname:String = getnamefromid(id);
				var loader:URLLoader = new URLLoader();
				var req:URLRequest = new URLRequest("http://trackmill.com/cat-ninja/getmusic.php?name=" + songname);
				loader.dataFormat = URLLoaderDataFormat.TEXT;
				req.method = URLRequestMethod.POST;
				
				musiclist[id].load(req);
				if (!firstsong) {
					musiclist[id].addEventListener(Event.COMPLETE, function (event:Event):void {
						if (playsongwhenloaded) { if (musicchannel) { musicchannel.stop(); } play(2 + id); } UIManager.loadingbox.hide();
						if (success != null) { success(); }
					});
				}
				musiclist[id].addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void { streamerror(error); });
				musiclist[id].addEventListener(SecurityErrorEvent.SECURITY_ERROR,
				function (event:SecurityErrorEvent):void { streamerror(error, "A security error occured."); } );
			}
		}
		
		private function streamerror(error:Function, text:String = "Could not load song. Sorry about that"):void {
			UIManager.loadingbox.hide();
			UIManager.messagebox.show(text, "Failed to receive music");
			if (error != null) { error(); }
		}
		
		public function getnamefromid(id:int):String {
			if (id == 0) { return "chiptunemusic.mp3";
			}else if (id == 1) { return "bossmusic.mp3";
			}else if (id == 2) { return "oxygen.mp3";
			}else if (id == 3) { return "aztec.mp3";
			}else if (id == 4) { return "desertplains.mp3";
			}else if (id == 5) { return "forceofcold.mp3";
			}else if (id == 6) { return "mysteriousmystery.mp3";
			}else if (id == 7) { return "grasslands.mp3";
			}else if (id == 8) { return "microbe.mp3";
			}else if (id == 9) { return "bitfunk.mp3"; }
			return "not specified";
		}
		
		public function play(soundid:int):void {
			var prevtarget:Sound = targetsound;
			soundtransform.volume = maxvolume;
			currvolume = maxvolume;
			switch (soundid) {
				case 1:
					targetsound = menu;
					break;
				case 2:
					targetsound = chiptunemusic;
					soundtransform.volume = maxvolume;
					break;
				case 3:
					targetsound = bossmusic;
					soundtransform.volume = maxvolume - .2;
					break;
				case 4:
					targetsound = oxygenmusic;
					break;
				case 5:
					targetsound = aztecmusic;
					soundtransform.volume = maxvolume + .2;
					break;
				case 6:
					targetsound = desertplains;
					break;
				case 7:
					targetsound = forceofcold;
					break;
				case 8:
					targetsound = mysteriousmystery;
					break;
				case 9:
					targetsound = grasslands;
					break;
				case 10:
					targetsound = microbe;
					break;
				case 11:
					targetsound = bitfunk;
					break;
				default:
					targetsound = null;
					break;
			}
			currvolume = soundtransform.volume;
			
			if (musicchannel && prevtarget == targetsound || !targetsound) {
				return;
			}
			fadingmusic = true;
			faded = false;
			if (!musicchannel) {
				fadein = true;
				fadeout = false;
				doublefade = false;
				if (targetsound && targetsound.length > 0) {
					musicchannel = targetsound.play(0, 99);
				}
				soundtransform.volume = 0;
				if (musicchannel) { musicchannel.soundTransform = soundtransform; }
			}else {
				fadeout = true;
				fadein = false;
				doublefade = true;
			}
			if (targetsound == null) { fadein = false; doublefade = false; }
		}
		
		public function setvolume(volume:Number):void {
			if (musicchannel) {
				soundtransform.volume = volume;
				musicchannel.soundTransform = soundtransform;
			}
		}
		
		public function update():void {
			if (fadingmusic && targetsound != null && !targetsound.isBuffering) {
				if (fadein) {
					soundtransform.volume += .02;
					if (soundtransform.volume >= currvolume) {
						soundtransform.volume = currvolume;
						fadein = false;
						if (doublefade && !faded) {
							fadeout = true; faded = true;
							if (targetsound != null) { musicchannel = targetsound.play(0, 99); }
						}else {
							fadingmusic = false;
						}
					}
				}else {
					soundtransform.volume -= .02;
					if (soundtransform.volume <= 0) {
						soundtransform.volume = 0;
						fadeout = false;
						if (doublefade && !faded) {
							fadein = true; faded = true;
							if (targetsound != null) { musicchannel = targetsound.play(0, 99); }
						}else {
							fadingmusic = false;
						}
					}
				}
				if (musicchannel) { musicchannel.soundTransform = soundtransform; }
			}
		}
		
		public function stop(soundid:int):void {
			switch (soundid) {
				case 1:
					musicchannel.stop();
					musicchannel = null;
					break;
			}
		}
		
		public function playsfx(id:int):void {
			sfxtransform.volume = maxsfxvolume;
			switch (id) {
				case 0:
					sfxchannel = crate.play(0, 0, sfxtransform);
					break;
				case 1:
					sfxchannel = crystal.play(0, 0, sfxtransform);
					break;
				case 2:
					sfxchannel = doublejump.play(0, 0, sfxtransform);
					break;
				case 3:
					sfxchannel = explosion1.play(0, 0, sfxtransform);
					break;
				case 4:
					sfxchannel = explosion2.play(0, 0, sfxtransform);
					break;
				case 5:
					sfxchannel = jump.play(0, 0, sfxtransform);
					break;
				case 6:
					sfxchannel = mine.play(0, 0, sfxtransform);
					break;
				case 7:
					sfxchannel = powerup.play(0, 0, sfxtransform);
					break;
				case 8:
					sfxchannel = reveal.play(0, 0, sfxtransform);
					break;
				case 9:
					sfxchannel = rotate.play(0, 0, sfxtransform);
					break;
				case 10:
					sfxchannel = shoot.play(0, 0, sfxtransform);
					break;
				case 11:
					sfxchannel = slam.play(0, 0, sfxtransform);
					break;
				case 12:
					sfxchannel = spring.play(0, 0, sfxtransform);
					break;
				case 13:
					sfxtransform.volume = maxsfxvolume / 2;
					if (sfxtransform.volume < 0) { sfxtransform.volume = 0; }
					sfxchannel = teleport.play(0, 0, sfxtransform);
					break;
				case 14:
					sfxtransform.volume = maxsfxvolume - .2;
					if (sfxtransform.volume < 0) { sfxtransform.volume = 0; }
					sfxchannel = respawn.play(0, 0, sfxtransform);
					break;
				case 15:
					sfxtransform.volume = maxsfxvolume - .2;
					if (sfxtransform.volume < 0) { sfxtransform.volume = 0; }
					sfxchannel = buttonclick.play(0, 0, sfxtransform);
					break;
				case 16:
					sfxchannel = hit1.play(0, 0, sfxtransform);
					break;
				case 17:
					sfxchannel = hit2.play(0, 0, sfxtransform);
					break;
				case 18:
					sfxchannel = beep.play(0, 0, sfxtransform);
					break;
				case 19:
					sfxchannel = beep2.play(0, 0, sfxtransform);
					break;
			}
		}
	}
}