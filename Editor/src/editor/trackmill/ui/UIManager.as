package editor.trackmill.ui {
	
	import editor.trackmill.com.tools.animation.Animation;
	import editor.trackmill.TrackMill;
	import editor.trackmill.ui.components.LoadingBox;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import editor.trackmill.ui.components.MessageBox;
	
	/**
	 * ...
	 * @author Richman Stewart
	 */
	public class UIManager {
		
		//uimanager variables
		public static var parent:DisplayObjectContainer;
		public static var messagebox:MessageBox;
		public static var loadingbox:LoadingBox;
		public static var animation:Animation;
		public static var trackmill:TrackMill;
		
		public static function initiate():void {
			Assets.initiate();
			animation = new Animation();
			loadingbox = new LoadingBox();
			messagebox = new MessageBox();
		}
	}
}