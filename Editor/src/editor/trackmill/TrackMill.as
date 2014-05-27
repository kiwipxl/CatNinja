package editor.trackmill {
	
	import editor.trackmill.com.adobe.Base64Encoder;
	import editor.trackmill.com.adobe.serialization.json.JSONDecoder;
	import editor.trackmill.ui.Assets;
	import editor.trackmill.ui.LoginWindow;
	import editor.trackmill.ui.UIManager;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.geom.Matrix;
	import flash.net.URLLoaderDataFormat;
	import editor.trackmill.com.adobe.PNGEncoder;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	public class TrackMill {
		
		//trackmill variables
		public var gamemode:String;
		public var gameidref:String;
		public var levelid:int = 49;
		public var screenshot:String;
		public var errorcallback:Function;
		public var parent:DisplayObjectContainer;
		private var base64encoder:Base64Encoder = new Base64Encoder();
		
		//ui variables
		public var loginwindow:LoginWindow;
		
		/**
		 * Initiates the trackmill constructor and collects all flashvars necessary
		 */
		public function TrackMill(displayobject:DisplayObjectContainer, gameid:String, options:Object = null) {
			if (displayobject.stage) { parent = displayobject.stage; } else { parent = displayobject; }
			UIManager.parent = parent;
			UIManager.trackmill = this;
			
			//get mode
			gamemode = displayobject.loaderInfo.parameters["mode"];
			if (!gamemode) { gamemode = "create"; }
			gamemode = gamemode.toLowerCase();
			//all gamemodes from here are converted to lowercase to prevent errors with unknown game mode
			
			//gets level id
			levelid = displayobject.loaderInfo.parameters["lid"];
			gameidref = gameid;
			UIManager.initiate();
			
			if (options) { gamemode = options.mode; levelid = int(options.lid); }
		}
		
		/**
		 * Submits a level to the trackmill server
		 */
		public function submitLevel(options:Object, successfunc:Function, errfunc:Function = null):void {
			var variables:URLVariables = new URLVariables();
			for (var s:String in options) {
				variables[s] = options[s];
			}
			variables.gameid = gameidref;
			if (screenshot) { variables.screenShot = screenshot; }
			makerequest("http://trackmill.com/api/?v=1.4.2&action=submitLevel", receiveLoad, successfunc, errfunc, null, variables);
			
			function receiveLoad(event:Event):void {
				event.target.removeEventListener(Event.COMPLETE, receiveLoad); event.target.removeEventListener(IOErrorEvent.IO_ERROR, senderror);
				
				trace(event.target.data);
				var result:Object = new Object();
				var returnArray:Array = String(event.target.data).split("\n");
				if (returnArray[0] == "0") {
					result.success = false;
					result.error = returnArray[1];
					senderror();
				}else {
					result.success = true;
					result.username = returnArray[1];
					result.levelid =  returnArray[2];
				}
				successfunc(result);
			}
		}
		
		/**
		 * Logins to the trackmill server
		 */
		public function submitLogin(username:String, password:String, successfunc:Function, errfunc:Function = null):void {
			var variables:URLVariables = new URLVariables();
			variables.username = username;
			variables.password = password;
			makerequest("http://trackmill.com/api/?v=1.4.0&action=submitLogin", receiveLoad, successfunc, errfunc, null, variables);
			
			function receiveLoad(event:Event):void {
				event.target.removeEventListener(Event.COMPLETE, receiveLoad); event.target.removeEventListener(IOErrorEvent.IO_ERROR, senderror);
				
				var result:Object = new Object();
				var returnArray:Array = String(event.target.data).split("\n");
				if(returnArray[0] == "0") {
					result.success = false;
					result.error = returnArray[1];
				}else{
					result.success = true;
					result.username = returnArray[1];
					result.userid = returnArray[2];
				}
				successfunc(result);
			}
		}
		
		/**
		 * Makes a request to the trackmill sevrer to check whether the current user is logged in
		 */
		public function loginStatus(successfunc:Function, errfunc:Function = null):void {
			makerequest("http://trackmill.com/api/?v=1.4.0&action=loginStatus", receiveLoad, successfunc, errfunc);
			
			function receiveLoad(event:Event):void {
				event.target.removeEventListener(Event.COMPLETE, receiveLoad); event.target.removeEventListener(IOErrorEvent.IO_ERROR, senderror);
				
				var result:Object = new Object();
				var returnArray:Array = String(event.target.data).split("\n");
				if(returnArray[0] == "0"){
					result.loggedin = false;
				}else{
					result.loggedin = true;
					result.username = returnArray[1];
					result.userid = returnArray[2];
				}
				successfunc(result);
			}
		}
		
		/**
		 * Submits a score to the trackmill server
		 */
		public function submitScore(info:Object, successfunc:Function, errfunc:Function = null):void {
			var variables:URLVariables = new URLVariables();
			variables.gameid = gameidref;
			variables.lid = levelid;
			variables.score = info.score;
			variables.sort = info.sort;
			makerequest("http://trackmill.com/api/?v=1.4.2&action=submitScore", receiveLoad, successfunc, errfunc, null, variables);
			
			function receiveLoad(event:Event):void {
				event.target.removeEventListener(Event.COMPLETE, receiveLoad); event.target.removeEventListener(IOErrorEvent.IO_ERROR, senderror);
				
				var result:Object = new Object();
				var returnArray:Array = new Array();
				returnArray = String(event.target.data).split("\n");
				if(returnArray[0] == "0"){
					result.success = false;
					result.error = returnArray[1];
				}else{
					result.success = true;
					result.rank = returnArray[1];
					
				}
				successfunc(result);
			}
		}
		
		/**
		 * Loads a level from trackmill using the local level id
		 */
		public function loadLevel(successfunc:Function, options:Array, errfunc:Function = null):void {
			var variables:URLVariables = new URLVariables();
			options.sort();
			variables.gameid = gameidref;
			variables.lid = levelid;
			makerequest("http://trackmill.com/api/?v=1.4.2&action=loadLevel", receiveLoad, successfunc, errfunc, options, variables);
			
			function receiveLoad(event:Event):void {
				event.target.removeEventListener(Event.COMPLETE, receiveLoad); event.target.removeEventListener(IOErrorEvent.IO_ERROR, senderror);
				
				var result:Object = new Object();
				var returnArray:Array = String(event.target.data).split("\n");
				if (returnArray[0] == "0") {
					result.success = false;
					result.error = returnArray[1];
				}else{
					result.success = true;
					for (var i:int = 0; i < options.length; i++) {
						result[String(options[i])] =  returnArray[i+1];
					}
				}
				successfunc(result);
			}
		}
		
		/**
		 * Loads a level from trackmill using the local level id
		 */
		public function getHighscores(count:int, order:String, successfunc:Function, errfunc:Function = null):void {
			makerequest("http://trackmill.com/api/?v=1.4.2&action=topScores&gameid=" + 
			gameidref + "&lid=" + levelid + "&count=" + count + "&rand=" + new Date().getTime(), receiveLoad, successfunc, errfunc); //to prevent caching
			
			function receiveLoad(event:Event):void {
				event.target.removeEventListener(Event.COMPLETE, receiveLoad); event.target.removeEventListener(IOErrorEvent.IO_ERROR, senderror);
				
				var result:Object = new Object();
				if (!event.target.data || event.target.data.length <= 4) {
					result.success = false;
					result.error = 0;
				}else {
					result.success = true;
					result.scores = new JSONDecoder(String(event.target.data), false).getValue();
					if (!result.scores) { result.success = false; result.error = 0; }
				}
				successfunc(result);
			}
		}
		
		/**
		 * Posts a url request with options and variables and returns the result from the trackmill server
		 */
		private function makerequest(url:String, completefunc:Function, successfunc:Function, errfunc:Function, options:Array = null, variables:URLVariables = null):void {
			var loader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest(url);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			req.method = URLRequestMethod.POST;
			
			if (options && variables) {
				for each (var s:String in options) {
					variables[s] = s;
				}
			}
			if (variables) { req.data = variables; }
			
			loader.load(req);
            loader.addEventListener(Event.COMPLETE, completefunc);
			errorcallback = errfunc; loader.addEventListener(IOErrorEvent.IO_ERROR, senderror);
		}
		
		/**
		 * Creates and displays the login window
		 */
		public function createlogin(loginfunction:Function):void {
			loginwindow = new LoginWindow(parent, (parent.stage.stageWidth / 2) - (Assets.loginscreen.width / 2),
			(parent.stage.stageHeight / 2) - (Assets.loginscreen.height / 2));
			loginwindow.show();
			loginwindow.loggedinfunction = loginfunction;
		}
		
		private function senderror(error:IOErrorEvent = null):void {
			if (errorcallback != null) { errorcallback(); errorcallback = null; }
		}
		
		/**
		 * Encodes a bytearray using adobe's base64 encoder and returns a string
		 */
		public function encodeByteArray(data:ByteArray):String {
			base64encoder.encodeBytes(data);
			var result:String = base64encoder.toString();
			base64encoder.reset();
			return result;
		}
		
		/**
		 * Creates and resizes a bitmap image to 240x240 pixels as a thumbnail and stores it in a screenshot variable
		 */
		public function createThumbnailFromData(data:BitmapData, width:int = 240, height:int = 240, 
		TLx:int = -1, TLy:int = -1, BRx:int = -1, BRy:int = -1):void {
			createThumbnail(data, null, width, height, TLx, TLy, BRx, BRy);
		}
		
		/**
		 * Creates and resizes a display object to 240x240 pixels as a thumbnail and stores it in a screenshot variable
		 */
		public function createThumbnailFromObject(displayobject:DisplayObjectContainer, width:int = 240, height:int = 240, 
		TLx:int = -1, TLy:int = -1, BRx:int = -1, BRy:int = -1):void {
			createThumbnail(null, displayobject, width, height, TLx, TLy, BRx, BRy);
		}
		
		private function createThumbnail(data:BitmapData, displayobject:DisplayObjectContainer, width:int, height:int, TLx:int, TLy:int, BRx:int, BRy:int):void {
			var obj:* = data; if (displayobject) { obj = displayobject; }
			if (TLx == -1) TLx = 0;
			if (TLy == -1) TLy = 0;
			if (BRx == -1) BRx = obj.width;
			if (BRy == -1) BRy = obj.height;
			var SSwidth:int = BRx - TLx; var SSHeight:int = BRy - TLy;
			
			//creates and resizes a screenshot to 240x240 pixels
			var gamearea:BitmapData = new BitmapData(width, height);
			gamearea.draw(obj, new Matrix(width / obj.width, 0, 0, height / obj.height, -TLx, -TLy));
			screenshot = encodeByteArray(PNGEncoder.encode(gamearea));
			//clears the screenshot to save memory
			gamearea.dispose(); gamearea = null; obj = null;
			if (data) { data.dispose(); }
		}
	}
}