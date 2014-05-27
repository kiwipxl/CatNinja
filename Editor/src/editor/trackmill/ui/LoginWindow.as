package  editor.trackmill.ui {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.net.navigateToURL;
	import editor.trackmill.ui.components.Button;
	
	/**
	 * ...
	 * @author Richman Stewart
	 */
	public class LoginWindow extends Sprite {
		
		//loginwindow variables
		private var playanimation:Boolean = false;
		private var scalenum:Number;
		private const scalespeed:Number = .2;
		public var loggedinfunction:Function;
		
		//ui variables
		public var base:Bitmap;
		private var basecontainer:Sprite = new Sprite();
		private var windowcontainer:Sprite = new Sprite();
		public  var backfadedscreen:Shape = new Shape();
		private var usernameinput:TextField = new TextField();
		private var passwordinput:TextField = new TextField();
		private var format:TextFormat;
		private var parentref:*;
		private var cancelbutton:Button;
		private var registerbutton:Button;
		private var loginbutton:Button;
		
		public function LoginWindow(parent:*, posx:int = 186, posy:int = 171):void {
			posx = Main.halfwidth - (Assets.loginscreen.width / 2); posy = Main.halfheight - (Assets.loginscreen.height / 2);
			backfadedscreen.graphics.beginFill(0x000000, .8);
			backfadedscreen.graphics.drawRect(0, 0, parent.stage.stageWidth, parent.stage.stageHeight);
			windowcontainer.addChild(backfadedscreen);
			
			base = new Bitmap(Assets.loginscreen);
			basecontainer.addChild(base);
			
			format = new TextFormat();
			format.size = 14;
			format.align = "left";
			format.font = "square";
			
			usernameinput.defaultTextFormat = format; usernameinput.embedFonts = true;
			usernameinput.width = 200; usernameinput.height = 20; usernameinput.x = 150; usernameinput.y = 95;
			usernameinput.multiline = false; usernameinput.wordWrap = false; usernameinput.type = TextFieldType.INPUT;
			usernameinput.textColor = 0x2846A1; usernameinput.background = true; usernameinput.backgroundColor = 0xB0C3FB;
			usernameinput.border = true; usernameinput.borderColor = 0x2846A1;
			basecontainer.addChild(usernameinput);
			usernameinput.visible = false; usernameinput.maxChars = 80;
			
			passwordinput.defaultTextFormat = format; passwordinput.embedFonts = true;
			passwordinput.width = 200; passwordinput.height = 20; passwordinput.x = 150; passwordinput.y = 140;
			passwordinput.multiline = false; passwordinput.wordWrap = false; passwordinput..type = TextFieldType.INPUT;
			passwordinput.textColor = 0x2846A1; passwordinput.background = true; passwordinput.backgroundColor = 0xB0C3FB;
			passwordinput.border = true; passwordinput.borderColor = 0x2846A1; passwordinput.displayAsPassword = true;
			basecontainer.addChild(passwordinput);
			passwordinput.visible = false; passwordinput.maxChars = 80;
			
			basecontainer.x = -base.width / 2; basecontainer.y = -base.height / 2;
			x = posx + (base.width / 2); y = posy + (base.height / 2);
			
			addChild(basecontainer);
			parentref = parent;
			
			createbuttons();
		}
		
		private function createbuttons():void {
			if (cancelbutton == null || !cancelbutton.stage) {
				cancelbutton = new Button("Cancel", x - 35, y + 95, 15, function():void {
					if (!UIManager.loadingbox.visible && !UIManager.messagebox.visible) { hide(); }
				}); basecontainer.addChild(cancelbutton);
				registerbutton = new Button("Register", x + 45, y + 95, 15, function():void {
					if (!UIManager.loadingbox.visible && !UIManager.messagebox.visible) { 
						var request:URLRequest = new URLRequest("http://trackmill.com/forums/register.php");
						navigateToURL(request, "_blank");
					}
				}); basecontainer.addChild(registerbutton);
				loginbutton = new Button("Login", x + 125, y + 95, 15, function():void {
					if (!UIManager.loadingbox.visible && !UIManager.messagebox.visible) { login(); }
				}, 1, 1.4, 1); basecontainer.addChild(loginbutton);
				parentref.addChild(cancelbutton);
				parentref.addChild(registerbutton);
				parentref.addChild(loginbutton);
				cancelbutton.visible = false; registerbutton.visible = false; loginbutton.visible = false;
			}
		}
		
		public function login():void {
			if (usernameinput.text == "") { UIManager.messagebox.show("Username must not be blank", "Error"); return;
			}else if (passwordinput.text == "") { UIManager.messagebox.show("Password must not be blank", "Error"); return; }
			
			UIManager.loadingbox.show("Logging in...");
			UIManager.trackmill.submitLogin(usernameinput.text, passwordinput.text, function(response:Object):void {
				UIManager.loadingbox.hide();
				if (response.success) {
					UIManager.messagebox.show("Success! You are now logged in as <font color='#1B3F94'>" + response.username + "</font>",
					"Successful login", true, 1,  "Ok", "", function():void { UIManager.messagebox.hide(false); hide();
					if (loggedinfunction != null) { loggedinfunction(); } }, null);
				}else {
					UIManager.messagebox.show("Username or password is incorrect", "Incorrect login details");
				}
			}, function():void {
				UIManager.loadingbox.hide();
				UIManager.messagebox.show("There was an error while connecting to the trackmill server.", "Unexpected Error");
			});
		}
		
		private function removebuttons():void {
			if (cancelbutton && cancelbutton.stage) {
				cancelbutton.removelisteners();
				parentref.removeChild(cancelbutton);
				registerbutton.removelisteners();
				parentref.removeChild(registerbutton);
				loginbutton.removelisteners();
				parentref.removeChild(loginbutton);
			}
		}
		
		public function show(animation:Boolean = true):void {
			if (!animation) { visible = false; backfadedscreen.visible = false; return; }
			if (visible) {
				addEventListener(Event.ENTER_FRAME, update);
				playanimation = true; scaleX = 0; scaleY = 0; windowcontainer.scaleX = 0; windowcontainer.scaleY = 0; scalenum = scalespeed;
				removebuttons(); cancelbutton.visible = false; registerbutton.visible = false; loginbutton.visible = false;
			}
			
			if (parentref && !stage) {
				UIManager.parent.addChild(windowcontainer);
				parentref.addChild(this);
			}
			
			playanimation = animation;
		}
		
		public function hide(animation:Boolean = true):void {
			playanimation = animation;
			if (!animation) { visible = false; backfadedscreen.visible = false; return; }
			if (visible) {
				addEventListener(Event.ENTER_FRAME, update);
				playanimation = true; scaleX = 1; scaleY = 1; windowcontainer.scaleX = 1; windowcontainer.scaleY = 1; scalenum = -scalespeed; 
				createbuttons(); cancelbutton.visible = false; registerbutton.visible = false; loginbutton.visible = false;
			}
		}
		
		public function remove():void {
			if (parentref && stage) {
				removeEventListener(Event.ENTER_FRAME, update);
				UIManager.parent.addChild(windowcontainer);
				parentref.addChild(this);
				removebuttons();
			}
		}
		
		public function update(event:Event):void {
			if (playanimation) {
				scaleX += scalenum; scaleY += scalenum;
				windowcontainer.scaleX += scalenum * 2; windowcontainer.scaleY += scalenum * 2;
				if (scalenum > 0 && scaleX >= 1 || scalenum < 0 && scaleX <= 0) {
					playanimation = false;
					if (scalenum < 0) { visible = false; backfadedscreen.visible = false; remove(); removebuttons();
					cancelbutton.visible = false; registerbutton.visible = false; loginbutton.visible = false;
					removeEventListener(Event.ENTER_FRAME, update); }
				}
				if (scalenum > 0 && scaleX >= 1) { windowcontainer.scaleX = 1; windowcontainer.scaleY = 1; scaleX = 1; scaleY = 1; createbuttons();
				usernameinput.visible = true; passwordinput.visible = true; parentref.stage.focus = usernameinput;
				removeEventListener(Event.ENTER_FRAME, update); cancelbutton.visible = true; registerbutton.visible = true; loginbutton.visible = true;
				}else if (scalenum < 0 && windowcontainer.scaleX <= 0) { windowcontainer.scaleX = 0; windowcontainer.scaleY = 0; }
			}
		}
	}
}