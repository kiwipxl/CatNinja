package managers {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.Font;
	import flash.utils.ByteArray;
	import tools.other.fzip.FZip;
	import tools.images.PixelModifier;
	import tools.other.fzip.FZipFile;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class Textures {
		
		//texturemanager variables
		//tile variables
		[Embed(source = "../../lib/tiles/groundtile.png")]
		private const groundtileclass:Class;
		private const groundtiledata:Bitmap = new groundtileclass();
		public var groundtile:BitmapData;
		
		[Embed(source = "../../lib/tiles/darkgroundtile.png")]
		private const darkgroundtileclass:Class;
		private const darkgroundtiledata:Bitmap = new darkgroundtileclass();
		public var darkgroundtile:BitmapData;
		
		[Embed(source = "../../lib/tiles/middarkgroundtile.png")]
		private const middarkgroundtileclass:Class;
		private const middarkgroundtiledata:Bitmap = new middarkgroundtileclass();
		public var middarkgroundtile:BitmapData;
		
		[Embed(source = "../../lib/tiles/groundtilecorner.png")]
		private const groundtilecornerclass:Class;
		private const groundtilecornerdata:Bitmap = new groundtilecornerclass();
		public var groundtilecornerupleft:BitmapData;
		public var groundtilecornerupright:BitmapData;
		public var groundtilecornerdownleft:BitmapData;
		public var groundtilecornerdownright:BitmapData;
		
		[Embed(source = "../../lib/tiles/gridtile.png")]
		private const gridtileclass:Class;
		private const gridtiledata:Bitmap = new gridtileclass();
		public var gridtile:BitmapData;
		
		[Embed(source = "../../lib/tiles/glass.png")]
		private const glassclass:Class;
		private const glassdata:Bitmap = new glassclass();
		public var glass:BitmapData;
		
		[Embed(source = "../../lib/tiles/dirt.png")]
		private const dirtclass:Class;
		private const dirtdata:Bitmap = new dirtclass();
		public var dirtblocks:Array;
		
		[Embed(source = "../../lib/tiles/screen.png")]
		private const screenclass:Class;
		private const screendata:Bitmap = new screenclass();
		public var screen:BitmapData;
		
		[Embed(source = "../../lib/tiles/stickygroundtile.png")]
		private const stickygroundtileclass:Class;
		private const stickygroundtiledata:Bitmap = new stickygroundtileclass();
		public var stickygroundtileleft:BitmapData;
		public var stickygroundtileright:BitmapData;
		public var stickygroundtileup:BitmapData;
		public var stickygroundtiledown:BitmapData;
		
		[Embed(source = "../../lib/tiles/jetpack.png")]
		private const jetpackclass:Class;
		private const jetpackdata:Bitmap = new jetpackclass();
		public var jetpack:BitmapData;
		
		[Embed(source = "../../lib/tiles/speedup.png")]
		private const speedupclass:Class;
		private const speedupdata:Bitmap = new speedupclass();
		public var speedup:BitmapData;
		
		[Embed(source = "../../lib/tiles/hallucinate.png")]
		private const hallucinateclass:Class;
		private const hallucinatedata:Bitmap = new hallucinateclass();
		public var hallucinate:BitmapData;
		
		//entity variables
		public var characterparts:Array;
		
		[Embed(source = "../../lib/entities/characteridle.png")]
		private const characteridleclass:Class;
		private const characteridledata:Bitmap = new characteridleclass();
		public var characteridle:BitmapData;
		
		[Embed(source = "../../lib/entities/characteridle2.png")]
		private const characteridle2class:Class;
		private const characteridle2data:Bitmap = new characteridle2class();
		public var characteridle2:BitmapData;
		
		[Embed(source = "../../lib/entities/characterwalk1.png")]
		private const characterwalk1class:Class;
		private const characterwalk1data:Bitmap = new characterwalk1class();
		public var characterwalk1:BitmapData;
		
		[Embed(source = "../../lib/entities/characterwalk2.png")]
		private const characterwalk2class:Class;
		private const characterwalk2data:Bitmap = new characterwalk2class();
		public var characterwalk2:BitmapData;
		
		[Embed(source = "../../lib/entities/characterwallslide.png")]
		private const characterwallslideclass:Class;
		private const characterwallslidedata:Bitmap = new characterwallslideclass();
		public var characterwallslide:BitmapData;
		
		[Embed(source = "../../lib/entities/characterjump.png")]
		private const characterjumpclass:Class;
		private const characterjumpdata:Bitmap = new characterjumpclass();
		public var characterjump:BitmapData;
		
		[Embed(source = "../../lib/entities/characterduck.png")]
		private const characterduckclass:Class;
		private const characterduckdata:Bitmap = new characterduckclass();
		public var characterduck:BitmapData;
		
		[Embed(source = "../../lib/entities/characterroll.png")]
		private const characterrollclass:Class;
		private const characterrolldata:Bitmap = new characterrollclass();
		public var characterroll:BitmapData;
		
		[Embed(source = "../../lib/entities/jetpackaddon.png")]
		private const jetpackaddonclass:Class;
		private const jetpackaddondata:Bitmap = new jetpackaddonclass();
		public var jetpackaddon:BitmapData;
		
		//level variables
		public var levels:Array = [];
		public var menus:Array = [];
		private var ziptimer:int = 0;
		
		[Embed(source = "../../lib/maps/levels.zip",mimeType="application/octet-stream")]
		private const levelsclass:Class;
		public const levelsdata:ByteArray = new levelsclass();
		private var levelszip:FZip;
		
		//environment variables
		[Embed(source = "../../lib/environment/spike.png")]
		private const spikeclass:Class;
		private const spikedata:Bitmap = new spikeclass();
		public var spikeup:BitmapData;
		public var spikedown:BitmapData;
		public var spikeright:BitmapData;
		public var spikeleft:BitmapData;
		
		[Embed(source = "../../lib/environment/fallspike.png")]
		private const fallspikeclass:Class;
		private const fallspikedata:Bitmap = new fallspikeclass();
		public var fallspikeup:BitmapData;
		public var fallspikedown:BitmapData;
		public var fallspikeright:BitmapData;
		public var fallspikeleft:BitmapData;
		
		[Embed(source = "../../lib/environment/spikecorner.png")]
		private const spikecornerclass:Class;
		private const spikecornerdata:Bitmap = new spikecornerclass();
		public var spikecornerup:BitmapData;
		public var spikecornerdown:BitmapData;
		public var spikecornerright:BitmapData;
		public var spikecornerleft:BitmapData;
		
		[Embed(source = "../../lib/environment/spikeblood.png")]
		private const spikebloodclass:Class;
		private const spikeblooddata:Bitmap = new spikebloodclass();
		public var spikebloodup:BitmapData;
		public var spikeblooddown:BitmapData;
		public var spikebloodright:BitmapData;
		public var spikebloodleft:BitmapData;
		
		[Embed(source = "../../lib/environment/checkpointon.png")]
		private const checkpointonclass:Class;
		private const checkpointondata:Bitmap = new checkpointonclass();
		public var checkpointon:BitmapData;
		
		[Embed(source = "../../lib/environment/checkpointoff.png")]
		private const checkpointoffclass:Class;
		private const checkpointoffdata:Bitmap = new checkpointoffclass();
		public var checkpointoff:BitmapData;
		
		[Embed(source = "../../lib/environment/mineblinkon.png")]
		private const mineblinkonclass:Class;
		private const mineblinkondata:Bitmap = new mineblinkonclass();
		public var mineblinkon:BitmapData;
		public var mineblinkonup:BitmapData;
		public var mineblinkonright:BitmapData;
		public var mineblinkonleft:BitmapData;
		
		[Embed(source = "../../lib/environment/mineblinkoff.png")]
		private const mineblinkoffclass:Class;
		private const mineblinkoffdata:Bitmap = new mineblinkoffclass();
		public var mineblinkoff:BitmapData;
		public var mineblinkoffup:BitmapData;
		public var mineblinkoffright:BitmapData;
		public var mineblinkoffleft:BitmapData;
		
		[Embed(source = "../../lib/environment/mineoff.png")]
		private const mineoffclass:Class;
		private const mineoffdata:Bitmap = new mineoffclass();
		public var mineoff:BitmapData;
		public var mineoffup:BitmapData;
		public var mineoffright:BitmapData;
		public var mineoffleft:BitmapData;
		
		[Embed(source = "../../lib/environment/lasermachine.png")]
		private const lasermachineclass:Class;
		private const lasermachinedata:Bitmap = new lasermachineclass();
		public var lasermachine:BitmapData;
		public var lasermachineright:BitmapData;
		public var lasermachineleft:BitmapData;
		public var lasermachineup:BitmapData;
		
		[Embed(source = "../../lib/environment/lasermachineoff.png")]
		private const lasermachineoffclass:Class;
		private const lasermachineoffdata:Bitmap = new lasermachineoffclass();
		public var lasermachineoff:BitmapData;
		public var lasermachineoffright:BitmapData;
		public var lasermachineoffleft:BitmapData;
		public var lasermachineoffup:BitmapData;
		
		[Embed(source = "../../lib/environment/laser.png")]
		private const laserclass:Class;
		private const laserdata:Bitmap = new laserclass();
		public var laser:BitmapData;
		public var laserup:BitmapData;
		
		[Embed(source = "../../lib/environment/button.png")]
		private const buttonclass:Class;
		private const buttondata:Bitmap = new buttonclass();
		public var button:BitmapData;
		public var buttonright:BitmapData;
		public var buttonleft:BitmapData;
		public var buttonup:BitmapData;
		
		[Embed(source = "../../lib/environment/buttonpress.png")]
		private const buttonpressclass:Class;
		private const buttonpressdata:Bitmap = new buttonpressclass();
		public var buttonpress:BitmapData;
		public var buttonpressright:BitmapData;
		public var buttonpressleft:BitmapData;
		public var buttonpressup:BitmapData;
		
		[Embed(source = "../../lib/environment/gravityblock.png")]
		private const gravityblockclass:Class;
		private const gravityblockdata:Bitmap = new gravityblockclass();
		public var gravityblock:BitmapData;
		public var gravityblockright:BitmapData;
		public var gravityblockleft:BitmapData;
		public var gravityblockup:BitmapData;
		
		[Embed(source = "../../lib/environment/gravitychanger.png")]
		private const gravitychangerclass:Class;
		private const gravitychangerdata:Bitmap = new gravitychangerclass();
		public var gravitychanger:BitmapData;
		public var gravitychangerright:BitmapData;
		public var gravitychangerleft:BitmapData;
		public var gravitychangerup:BitmapData;
		
		[Embed(source = "../../lib/environment/crate.png")]
		private const crateclass:Class;
		private const cratedata:Bitmap = new crateclass();
		public var crate:BitmapData;
		
		[Embed(source = "../../lib/environment/boost.png")]
		private const boostclass:Class;
		private const boostdata:Bitmap = new boostclass();
		public var boostdown:BitmapData;
		public var boostright:BitmapData;
		public var boostleft:BitmapData;
		public var boostup:BitmapData;
		
		[Embed(source = "../../lib/environment/spring.png")]
		private const springclass:Class;
		private const springdata:Bitmap = new springclass();
		public var springdown:BitmapData;
		public var springright:BitmapData;
		public var springleft:BitmapData;
		public var springup:BitmapData;
		
		[Embed(source = "../../lib/environment/teleporter.png")]
		private const teleporterclass:Class;
		private const teleporterdata:Bitmap = new teleporterclass();
		public var teleporterdown:BitmapData;
		public var teleporterright:BitmapData;
		public var teleporterleft:BitmapData;
		public var teleporterup:BitmapData;
		
		[Embed(source = "../../lib/environment/shieldshooter.png")]
		private const shieldshooterclass:Class;
		public const shieldshooterdata:Bitmap = new shieldshooterclass();
		public var shieldshooter:Array;
		public var shieldshooterright:Array;
		public var shieldshooterleft:Array;
		public var shieldshooterup:Array;
		
		[Embed(source = "../../lib/environment/homingshooter.png")]
		private const homingshooterclass:Class;
		public const homingshooterdata:Bitmap = new homingshooterclass();
		public var homingshooter:Array;
		public var homingshooterright:Array;
		public var homingshooterleft:Array;
		public var homingshooterup:Array;
		
		[Embed(source = "../../lib/environment/magnet.png")]
		private const magnetclass:Class;
		private const magnetdata:Bitmap = new magnetclass();
		public var magnetdown:BitmapData;
		public var magnetright:BitmapData;
		public var magnetleft:BitmapData;
		public var magnetup:BitmapData;
		
		[Embed(source = "../../lib/environment/sphere.png")]
		private const sphereclass:Class;
		private const spheredata:Bitmap = new sphereclass();
		private var sphere:BitmapData;
		public var spheres:Array = [];
		
		[Embed(source = "../../lib/environment/sunspike.png")]
		private const sunspikeclass:Class;
		private const sunspikedata:Bitmap = new sunspikeclass();
		public var sunspike:BitmapData;
		
		[Embed(source = "../../lib/environment/jailcell.png")]
		private const jailcellclass:Class;
		private const jailcelldata:Bitmap = new jailcellclass();
		public var jailcell:BitmapData;
		
		[Embed(source = "../../lib/environment/bomb.png")]
		private const bombclass:Class;
		private const bombdata:Bitmap = new bombclass();
		public var bomb:BitmapData;
		
		[Embed(source = "../../lib/environment/bigsphere.png")]
		private const bigsphereclass:Class;
		private const bigspheredata:Bitmap = new bigsphereclass();
		public var bigspheres:Array;
		
		//ui variables
		[Embed(source = "../../lib/ui/messagebox.png")]
		private const messageboxclass:Class;
		private const messageboxdata:Bitmap = new messageboxclass();
		public var messagebox:BitmapData;
		
		public function initiate():void {
			//tiles
			groundtile = groundtiledata.bitmapData;
			darkgroundtile = darkgroundtiledata.bitmapData;
			middarkgroundtile = middarkgroundtiledata.bitmapData;
			gridtile = gridtiledata.bitmapData;
			glass = glassdata.bitmapData;
			dirtblocks = PixelModifier.cutSheet(dirtdata.bitmapData, 20, 20);
			screen = screendata.bitmapData;
			//sticky tiles
			stickygroundtileleft = stickygroundtiledata.bitmapData;
			stickygroundtileright = PixelModifier.flip(stickygroundtiledata.bitmapData, -1, 1);
			stickygroundtiledown = PixelModifier.rotate(stickygroundtiledata.bitmapData, -90);
			stickygroundtileup = PixelModifier.rotate(stickygroundtiledata.bitmapData, 90);
			//corner ground tiles
			groundtilecornerupleft = groundtilecornerdata.bitmapData;
			groundtilecornerupright = PixelModifier.flip(groundtilecornerdata.bitmapData, -1, 1);
			groundtilecornerdownleft = PixelModifier.rotate(groundtilecornerdata.bitmapData, -90);
			groundtilecornerdownright = PixelModifier.flip(groundtilecornerdata.bitmapData, -1, -1);
			jetpack = jetpackdata.bitmapData;
			speedup = speedupdata.bitmapData;
			hallucinate = hallucinatedata.bitmapData;
			
			//entities
			characteridle = characteridledata.bitmapData;
			characteridle2 = characteridle2data.bitmapData;
			characterwalk1 = characterwalk1data.bitmapData;
			characterwalk2 = characterwalk2data.bitmapData;
			characterwallslide = characterwallslidedata.bitmapData;
			characterjump = characterjumpdata.bitmapData;
			characterduck = characterduckdata.bitmapData;
			characterroll = characterrolldata.bitmapData;
			jetpackaddon = jetpackaddondata.bitmapData;
			characterparts = PixelModifier.breakData(characteridle, 5);
			
			//environment
			//spike
			spikeup = spikedata.bitmapData;
			spikedown = PixelModifier.flip(spikedata.bitmapData, 1, -1);
			spikeright = PixelModifier.rotate(spikedata.bitmapData, 90);
			spikeleft = PixelModifier.rotate(spikedata.bitmapData, -90);
			//blood
			spikebloodup = spikeblooddata.bitmapData;
			spikeblooddown = PixelModifier.flip(spikeblooddata.bitmapData, 1, -1);
			spikebloodright = PixelModifier.rotate(spikeblooddata.bitmapData, 90);
			spikebloodleft = PixelModifier.rotate(spikeblooddata.bitmapData, -90);
			//corner
			spikecornerup = spikecornerdata.bitmapData;
			spikecornerdown = PixelModifier.flip(spikecornerdata.bitmapData, 1, -1);
			spikecornerright = PixelModifier.rotate(spikecornerdata.bitmapData, 90);
			spikecornerleft = PixelModifier.rotate(spikecornerdata.bitmapData, -90);
			//fallspike
			fallspikeup = fallspikedata.bitmapData;
			fallspikedown = PixelModifier.flip(fallspikedata.bitmapData, 1, -1);
			fallspikeright = PixelModifier.rotate(fallspikedata.bitmapData, 90);
			fallspikeleft = PixelModifier.rotate(fallspikedata.bitmapData, -90);
			//checkpoint
			checkpointon = checkpointondata.bitmapData;
			checkpointoff = checkpointoffdata.bitmapData;
			//mine
			mineblinkon = mineblinkondata.bitmapData;
			mineblinkoff = mineblinkoffdata.bitmapData;
			mineoff = mineoffdata.bitmapData;
			mineblinkonup = PixelModifier.flip(mineblinkondata.bitmapData, 1, -1);
			mineblinkoffup = PixelModifier.flip(mineblinkoffdata.bitmapData, 1, -1);
			mineoffup = PixelModifier.flip(mineoffdata.bitmapData, 1, -1);
			mineblinkonright = PixelModifier.rotate(mineblinkondata.bitmapData, -90);
			mineblinkoffright = PixelModifier.rotate(mineblinkoffdata.bitmapData, -90);
			mineoffright = PixelModifier.rotate(mineoffdata.bitmapData, -90);
			mineblinkonleft = PixelModifier.rotate(mineblinkondata.bitmapData, 90);
			mineblinkoffleft = PixelModifier.rotate(mineblinkoffdata.bitmapData, 90);
			mineoffleft = PixelModifier.rotate(mineoffdata.bitmapData, 90);
			//laser
			lasermachine = lasermachinedata.bitmapData;
			lasermachineright = PixelModifier.rotate(lasermachinedata.bitmapData, -90);
			lasermachineleft = PixelModifier.rotate(lasermachinedata.bitmapData, 90);
			lasermachineup = PixelModifier.flip(lasermachinedata.bitmapData, 1, -1);
			lasermachineoff = lasermachineoffdata.bitmapData;
			lasermachineoffright = PixelModifier.rotate(lasermachineoffdata.bitmapData, -90);
			lasermachineoffleft = PixelModifier.rotate(lasermachineoffdata.bitmapData, 90);
			lasermachineoffup = PixelModifier.flip(lasermachineoffdata.bitmapData, 1, -1);
			laser = laserdata.bitmapData;
			laserup = PixelModifier.rotate(laserdata.bitmapData, 90);
			//button
			button = buttondata.bitmapData;
			buttonright = PixelModifier.rotate(buttondata.bitmapData, 90);
			buttonleft = PixelModifier.rotate(buttondata.bitmapData, -90);
			buttonup = PixelModifier.flip(buttondata.bitmapData, 1, -1);
			buttonpress = buttonpressdata.bitmapData;
			buttonpressright = PixelModifier.rotate(buttonpressdata.bitmapData, 90);
			buttonpressleft = PixelModifier.rotate(buttonpressdata.bitmapData, -90);
			buttonpressup = PixelModifier.flip(buttonpressdata.bitmapData, 1, -1);
			//gravityblock
			gravityblock = gravityblockdata.bitmapData;
			gravityblockright = PixelModifier.rotate(gravityblockdata.bitmapData, 90);
			gravityblockleft = PixelModifier.rotate(gravityblockdata.bitmapData, -90);
			gravityblockup = PixelModifier.flip(gravityblockdata.bitmapData, 1, -1);
			//gravitychanger
			gravitychanger = gravitychangerdata.bitmapData;
			gravitychangerright = PixelModifier.rotate(gravitychangerdata.bitmapData, 90);
			gravitychangerleft = PixelModifier.rotate(gravitychangerdata.bitmapData, -90);
			gravitychangerup = PixelModifier.flip(gravitychangerdata.bitmapData, 1, -1);
			//boost
			boostdown = boostdata.bitmapData;
			boostright = PixelModifier.rotate(boostdata.bitmapData, -90);
			boostleft = PixelModifier.rotate(boostdata.bitmapData, 90);
			boostup = PixelModifier.flip(boostdata.bitmapData, 1, -1);
			crate = cratedata.bitmapData;
			sunspike = sunspikedata.bitmapData;
			jailcell = jailcelldata.bitmapData;
			bomb = bombdata.bitmapData;
			//spring
			springdown = springdata.bitmapData;
			springright = PixelModifier.rotate(springdata.bitmapData, 90);
			springleft = PixelModifier.rotate(springdata.bitmapData, -90);
			springup = PixelModifier.flip(springdata.bitmapData, 1, -1);
			//teleporter
			teleporterdown = teleporterdata.bitmapData;
			teleporterright = PixelModifier.rotate(teleporterdata.bitmapData, 90);
			teleporterleft = PixelModifier.rotate(teleporterdata.bitmapData, -90);
			teleporterup = PixelModifier.flip(teleporterdata.bitmapData, 1, -1);
			//shieldshooter
			shieldshooter = PixelModifier.cutSheet(shieldshooterdata.bitmapData, 20, 20);
			shieldshooterright = PixelModifier.cutSheet(PixelModifier.flip(PixelModifier.rotate(shieldshooterdata.bitmapData, -90), 1, -1), 20, 20);
			shieldshooterleft = PixelModifier.cutSheet(PixelModifier.flip(PixelModifier.rotate(shieldshooterdata.bitmapData, -90), -1, -1), 20, 20);
			shieldshooterup = PixelModifier.cutSheet(PixelModifier.flip(shieldshooterdata.bitmapData, 1, -1), 20, 20);
			//homingshooter
			homingshooter = PixelModifier.cutSheet(homingshooterdata.bitmapData, 20, 20);
			homingshooterright = PixelModifier.cutSheet(PixelModifier.flip(PixelModifier.rotate(homingshooterdata.bitmapData, -90), 1, -1), 20, 20);
			homingshooterleft = PixelModifier.cutSheet(PixelModifier.flip(PixelModifier.rotate(homingshooterdata.bitmapData, -90), -1, -1), 20, 20);
			homingshooterup = PixelModifier.cutSheet(PixelModifier.flip(homingshooterdata.bitmapData, 1, -1), 20, 20);
			//magnet
			magnetdown = magnetdata.bitmapData;
			magnetright = PixelModifier.rotate(magnetdata.bitmapData, 90);
			magnetleft = PixelModifier.rotate(magnetdata.bitmapData, -90);
			magnetup = PixelModifier.flip(magnetdata.bitmapData, 1, -1);
			//spheres
			spheres = PixelModifier.cutSheet(spheredata.bitmapData, 20, 20);
			bigspheres = PixelModifier.cutSheet(bigspheredata.bitmapData, 167, 163);
			
			//user interface
			messagebox = messageboxdata.bitmapData;
			
			//levels
			ziptimer = getTimer();
			levelszip = new FZip();
			levelszip.addEventListener(Event.COMPLETE, loadedZip);
			levelszip.loadBytes(levelsdata);
		}
		
		private function loadedZip(event:Event):void {
			var counter:int = 1;
			while (true) {
				var file:FZipFile = levelszip.getFileByName("level" + counter + ".xml");
				if (file) {
					levels.push(file.getContentAsString());
					++counter;
				}else {
					counter = 1;
					file = levelszip.getFileByName("menu" + counter + ".xml");
					menus.push(file.getContentAsString());
					break;
				}
			}
			trace("Loaded " + levels.length + " levels in " + (getTimer() - ziptimer) + " ms");
			Main.startGame();
		}
	}
}