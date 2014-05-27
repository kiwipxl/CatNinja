package managers {
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class SoundManager {
		
		//soundmanager variables
		[Embed(source = "../../lib/sound/music/game.mp3")]
		private const gameclass:Class;
		public const game:Sound = new gameclass();
		
		[Embed(source = "../../lib/sound/music/menu.mp3")]
		private const menuclass:Class;
		public const menu:Sound = new menuclass();
		
		[Embed(source = "../../lib/sound/music/boss.mp3")]
		private const bossclass:Class;
		public const boss:Sound = new bossclass();
		
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
		
		//music control variables
		public var musicchannel:SoundChannel;
		public var soundtransform:SoundTransform = new SoundTransform();
		public var targetsound:Sound;
		private var fadingmusic:Boolean = false;
		private var fadein:Boolean = false;
		private var fadeout:Boolean = false;
		private var doublefade:Boolean = false;
		private var faded:Boolean = false;
		public var maxvolume:Number = .5;
		public var maxsfxvolume:Number = .5;
		public var hsound:Boolean = false;
		
		//soundeffect control variables
		public var sfxchannel:SoundChannel;
		private var sfxtransform:SoundTransform = new SoundTransform();
		
		public function play(soundid:int):void {
			var prevtarget:Sound = targetsound;
			switch (soundid) {
				case 1:
					targetsound = game;
					break;
				case 2:
					targetsound = menu;
					break;
				case 3:
					targetsound = boss;
					break;
				default:
					targetsound = null;
					break;
			}
			if (prevtarget == targetsound) {
				return;
			}
			fadingmusic = true;
			faded = false;
			if (!musicchannel) {
				fadein = true;
				fadeout = false;
				doublefade = false;
				musicchannel = targetsound.play(0, 99);
				soundtransform.volume = 0;
				musicchannel.soundTransform = soundtransform;
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
			if (fadingmusic) {
				if (fadein) {
					soundtransform.volume += .02;
					if (soundtransform.volume >= maxvolume) {
						soundtransform.volume = maxvolume;
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
				musicchannel.soundTransform = soundtransform;
			}
			if (hsound && musicchannel && !Main.menu.musicpaused) {
				soundtransform.volume += (Math.random() * 2 - Math.random() * 2) / 10;
				if (soundtransform.volume < maxvolume - .4) { soundtransform.volume = maxvolume - .4;
				}else if (soundtransform.volume > maxvolume + .2) { soundtransform.volume = maxvolume + .2; }
				musicchannel.soundTransform = soundtransform;
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
			}
		}
	}
}