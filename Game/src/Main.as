package {
	
	import editor.Editor;
	import effects.ParticleManager;
	import effects.TrailManager;
	import entities.Boss;
	import environment.EnvironmentManager;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.media.SoundMixer;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import managers.KeyboardManager;
	import managers.MouseManager;
	import managers.ScriptObjectManager;
	import managers.SoundManager;
	import managers.Textures;
	import entities.Player;
	import maps.Map;
	import maps.MapCamera;
	import tools.animation.Animation;
	import tools.ShakeScreen;
	import tools.text.Info;
	import tools.text.TextManager;
	import tools.Time;
	import tools.text.GlitchInterpreter;
	import ui.Menu;
	import ui.Speech;
	
	/**
	 * ...
	 * @author Feffers
	 */
	[Frame(factoryClass = "Preloader")]
	[SWF(width="800", height="600", version="10.2", frameRate="60", backgroundColor="0x000000")]
	public class Main extends Sprite {
		
		//manager variables
		public static var universe:Stage;
		public static var screen:Sprite;
		public static var world:Sprite;
		
		//map variables
		public static var map:Map = new Map();
		public static var mapcamera:MapCamera = new MapCamera();
		
		//manager variables
		public static var textures:Textures = new Textures();
		public static var mouse:MouseManager = new MouseManager();
		public static var keyboard:KeyboardManager = new KeyboardManager();
		public static var sound:SoundManager = new SoundManager();
		public static var env:EnvironmentManager = new EnvironmentManager();
		public static var objectmanager:ScriptObjectManager = new ScriptObjectManager();
		
		//editor variables
		public static var mapeditor:Editor = new Editor();
		
		//effects variables
		public static var trail:TrailManager = new TrailManager();
		public static var particles:ParticleManager = new ParticleManager();
		
		//entity variables
		public static var player:Player = new Player();
		public static var boss:Boss = new Boss();
		
		//tool variables
		public static var info:Info = new Info();
		public static var time:Time = new Time();
		public static var interpreter:GlitchInterpreter = new GlitchInterpreter();
		public static var animation:Animation = new Animation();
		public static var shakescreen:ShakeScreen = new ShakeScreen();
		public static var text:TextManager = new TextManager();
		
		//ui variables
		public static var speech:Speech = new Speech();
		public static var menu:Menu = new Menu();
		private var conmenu:ContextMenu;
		private var coneditbutton:ContextMenuItem;
		
		//other variables
		public static var startGame:Function;
		public static var fullscreened:Boolean = false;
		public static var pausegame:Boolean = false;
		public static var gamepaused:Boolean = false;
		public static var pdeaths:int = 0;
		public static var collected:int = 0;
		public static var collectedpositions:Array = [];
		private const allowedwebsites:Array = ["fgl.com",
		"http://www.flashgamelicense.com",
		"flashgamelicense.com",
		"https://www.flashgamelicense.com.",
		"www.flashgamelicense.com",
		"http://www.trackmill.com",
		"www.trackmill.com"];
		private const published:Boolean = false;
		
		//screen variables
		public static var fadescreen:Shape = new Shape();
		public static var targetfunction:Function;
		public static var fadingscreen:Boolean = false;
		public static var fadein:Boolean = false;
		public static var fadeout:Boolean = false;
		public static var doublefade:Boolean = false;
		public static var faded:Boolean = false;
		public static var fadespeed:Number = 0;
		
		public function Main(stage:Stage = null):void {
			universe = stage;
			
			if (stage) { start();
			}else { addEventListener(Event.ADDED_TO_STAGE, start); }
		}
		
		private function start(event:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, start);
			
			screen = new Sprite();
			world = new Sprite();
			world.addChild(screen);
			universe.addChild(world);
			startGame = load;
			universe.focus = null;
			
			fadescreen.graphics.lineStyle(1, 0x000000);
			fadescreen.graphics.beginFill(0x000000);
			fadescreen.graphics.drawRect((800 - universe.fullScreenWidth) / 2, (600 - universe.fullScreenHeight) / 2, 
																universe.fullScreenWidth, universe.fullScreenHeight);
			universe.addChild(fadescreen);
			fadescreen.visible = false;
			
			keyboard.initiate();
			mouse.initiate();
			trail.initiate();
			particles.initiate();
			info.initiate();
			time.initiate();
			textures.initiate();
		}
		
		public function load():void {
			//sitelock
			for (var i:int = 0; i < allowedwebsites.length; ++i) {
				if (universe.loaderInfo.url.indexOf(allowedwebsites[i]) != -1 || !published) {
					//initiateEditor();
					initiateGame();
					return;
				}
			}
			//game is not on right website
			text.createtext("<font color='#CA7BF4' size='80'>Sorry</font><br>" +
			"<font color='#FFFFFF' size='25'>this game is not available on this website</font>", 0, 200);
		}
		
		private function initiateEditor():void {
			mapeditor.create();
		}
		
		private function initiateGame():void {
			fadescreen.visible = true;
			map.initiate();
			map.create(-1);
			player.create();
			menu.create();
			
			fadingscreen = true;
			doublefade = false;
			fadeout = true;
			faded = false;
			fadespeed = .001;
			
			addEventListener(Event.ENTER_FRAME, update);
			universe.addEventListener(Event.DEACTIVATE, focusout);
			universe.addEventListener(Event.ACTIVATE, focusin);
		}

		private function focusin(event:Event):void {
			Main.menu.resume();
		}

		private function focusout(event:Event):void {
			Main.menu.pause();
		}
		
		private function update(event:Event):void {
			if (!gamepaused) {
				if (!pausegame) {
					map.update();
					info.update();
					speech.update();
					shakescreen.update();
					mapcamera.update();
					objectmanager.update();
					sound.update();
					text.update();
					
					if (boss.created) { boss.update(); }
					
					if (!map.rotating) {
						time.update();
						trail.update();
						env.update();
						particles.update();
						if (!player.dead) {
							player.update();
						}
					}
					mapcamera.moveTo(player.x + 10, player.y + 10);
				}
				
				if (fadingscreen) {
					if (fadein) {
						fadescreen.alpha += fadespeed;
						if (fadescreen.alpha >= 1) {
							fadescreen.alpha = 1;
							fadein = false;
							if (doublefade && !faded) {
								fadeout = true; faded = true;
								if (targetfunction != null) { targetfunction(); targetfunction = null; }
							}else {
								fadingscreen = false;
							}
						}
					}else {
						fadescreen.alpha -= fadespeed;
						if (fadescreen.alpha <= 0) {
							fadescreen.alpha = 0;
							fadescreen.visible = false;
							fadeout = false;
							if (doublefade && !faded) {
								fadein = true; faded = true;
								if (targetfunction != null) { targetfunction(); targetfunction = null; }
							}else {
								fadingscreen = false;
							}
						}
					}
				}
			}
		}
	}
}