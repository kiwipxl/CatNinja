package {
	
	import editor.trackmill.ui.LoginWindow;
	import editor.trackmill.ui.UIManager;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	import managers.KeyboardManager;
	import managers.Textures;
	import managers.MouseManager;
	import managers.SoundManager;
	import effects.ParticleManager;
	import effects.TrailManager;
	import maps.MapManager;
	import tools.animation.Animation;
	import environment.EnvironmentManager;
	import maps.Map;
	import maps.MapCamera;
	import entities.Player;
	import editor.Editor;
	import tools.text.Info;
	import tools.Time;
	import tools.ShakeScreen;
	import ui.Countdown;
	import ui.HighscoreScreen;
	import ui.Menu;
	import ui.MessageBox;
	import ui.Transition;
	
	/**
	 * ...
	 * @author Feffers
	 */
	[SWF(width="800", height="600", version="10.2", frameRate="60", backgroundColor="0x000000")]
	[Frame(factoryClass = "Preloader")]
	public class Main extends Sprite {
		
		//global variables
		public static var universe:Stage;
		public static var world:Sprite = new Sprite();
		public static var screen:Sprite = new Sprite();
		public static var info:Info = new Info();
		
		//manager variables
		public static var textures:Textures = new Textures();
		public static var keyboard:KeyboardManager = new KeyboardManager();
		public static var mouse:MouseManager = new MouseManager();
		public static var sound:SoundManager = new SoundManager();
		public static var time:Time = new Time();
		public static var shakescreen:ShakeScreen = new ShakeScreen();
		
		//entity variables
		public static var player:Player = new Player();
		
		//map variables
		public static var map:Map = new Map();
		public static var mapcamera:MapCamera = new MapCamera();
		public static var env:EnvironmentManager = new EnvironmentManager();
		public static var mapmanager:MapManager = new MapManager();
		
		//effect variables
		public static var particles:ParticleManager = new ParticleManager();
		public static var trail:TrailManager = new TrailManager();
		public static var animation:Animation = new Animation();
		
		//editor variables
		public static var mapeditor:Editor = new Editor();
		
		//ui variables
		public static var menu:Menu = new Menu();
		public static var messagebox:MessageBox;
		public static var highscorescreen:HighscoreScreen = new HighscoreScreen();
		public static var transition:Transition = new Transition();
		public static var countdown:Countdown = new Countdown();
		
		//other variables
		public static var targetfunction:Function;
		public static var gamepaused:Boolean = false;
		public static var testing:Boolean = false;
		public static var fadescreen:Shape = new Shape();
		public static var outoffocus:Boolean = false;
		public static var halfwidth:int = 400;
		public static var halfheight:int = 300;
		public static var collected:int = 0;
		
		public function Main(stage:Stage):void {
			universe = stage;
			universe.addChild(world);
			world.addChild(screen);
			
			textures.initiate();
			info.initiate();
			mouse.initiate();
			map.initiate();
			mapmanager.connect();
			
			fadescreen.graphics.lineStyle(1, 0x000000);
			fadescreen.graphics.beginFill(0x000000);
			fadescreen.graphics.drawRect((800 - universe.fullScreenWidth) / 2, (600 - universe.fullScreenHeight) / 2, 
																universe.fullScreenWidth, universe.fullScreenHeight);
			universe.addChild(fadescreen);
			fadescreen.visible = false;
			messagebox = new MessageBox();
			
			menu.create();
			if (mapmanager.trackmill.gamemode == "create") { sound.collectmusic(); keyboard.initiate(); mapeditor.initiate(); mapmanager.starteditor();
			}else { sound.initiatemusic(); gamepaused = true; keyboard.initiate(); Main.mapmanager.loadtrackmillmap(); }
			
			universe.addEventListener(Event.DEACTIVATE, focusout);
			universe.addEventListener(Event.ACTIVATE, focusin);
		}
		
		private function focusin(event:Event):void {
			menu.focus(false);
			menu.resume();
		}
		
		private function focusout(event:Event):void {
			menu.focus(true);
			menu.pause();
		}
	}
}