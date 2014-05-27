package ui {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class HighscoreScreen {
		
		//highscorescreen variables
		public var container:Sprite = new Sprite();
		private var background:Bitmap;
		private var runtimetext:TextField;
		private var highscoreinfo:TextField;
		private var scoresinfo:TextField;
		private var submitscoresinfo:TextField;
		private var textformat:TextFormat;
		private var tryagainbutton:Button;
		private var highlightbox:Shape = new Shape();
		public var username:String = "";
		public var usernames:Array = [];
		public var rank:int = 0;
		public var simplebg:Shape = new Shape();
		private var simplebgdata:BitmapData;
		private var colourtransform:ColorTransform = new ColorTransform();
		
		public function create(timetext:String):void {
			if (Main.universe.stageWidth > 800 || Main.universe.stageHeight > 600) { drawbackground(); }
			background = new Bitmap(Main.textures.highscorescreen);
			container.addChild(background);
			
			textformat = new TextFormat();
			textformat.font = "square";
			textformat.size = 20;
			textformat.align = "center";
			runtimetext = new TextField();
			runtimetext.embedFonts = true;
			runtimetext.defaultTextFormat = textformat;
			runtimetext.width = 240; runtimetext.height = 100;
			runtimetext.x = 50; runtimetext.y = 40;
			runtimetext.selectable = false; runtimetext.multiline = false; runtimetext.wordWrap = false;
			runtimetext.textColor = 0xFFFFFF;
			runtimetext.filters = [new BevelFilter(4, 45, 0xFFFFFF, .6, 0x000000, .2, 4, 4, 1, 2), new DropShadowFilter(4, 50, 0x000000, .8, 6, 6, 1, 2)];
			runtimetext.htmlText = timetext;
			container.addChild(runtimetext);
			
			highlightbox.graphics.clear();
			highlightbox.graphics.beginBitmapFill(Main.textures.simplebackground);
			highlightbox.graphics.drawRect(0, 0, 650, 35);
			highlightbox.transform.colorTransform = new ColorTransform(1, 1, 2);
			highlightbox.alpha = .25;
			container.addChild(highlightbox);
			highlightbox.visible = false;
			
			highscoreinfo = new TextField();
			highscoreinfo.embedFonts = true;
			highscoreinfo.defaultTextFormat = textformat;
			highscoreinfo.width = 600;
			highscoreinfo.height = 400;
			highscoreinfo.x = 100;
			highscoreinfo.y = 150;
			highscoreinfo.selectable = false; highscoreinfo.multiline = true; highscoreinfo.wordWrap = false;
			highscoreinfo.textColor = 0xFFFFFF;
			highscoreinfo.filters = [new BevelFilter(4, 45, 0xFFFFFF, .6, 0x000000, .2, 4, 4, 1, 2), new DropShadowFilter(4, 50, 0x000000, .8, 6, 6, 1, 2)];
			highscoreinfo.text = "Receiving highscores...";
			container.addChild(highscoreinfo);
			
			scoresinfo = new TextField();
			scoresinfo.embedFonts = true;
			scoresinfo.defaultTextFormat = textformat;
			scoresinfo.width = 250;
			scoresinfo.height = 400;
			scoresinfo.x = 450;
			scoresinfo.y = 150;
			scoresinfo.selectable = false; scoresinfo.multiline = true; scoresinfo.wordWrap = false;
			scoresinfo.textColor = 0xFFFFFF;
			scoresinfo.filters = [new BevelFilter(4, 45, 0xFFFFFF, .6, 0x000000, .2, 4, 4, 1, 2), new DropShadowFilter(4, 50, 0x000000, .8, 6, 6, 1, 2)];
			scoresinfo.text = "";
			container.addChild(scoresinfo);
			
			submitscoresinfo = new TextField();
			textformat.size = 14;
			submitscoresinfo.embedFonts = true;
			submitscoresinfo.defaultTextFormat = textformat;
			submitscoresinfo.width = 240;
			submitscoresinfo.height = 20;
			submitscoresinfo.x = 50;
			submitscoresinfo.y = 90;
			submitscoresinfo.selectable = false; submitscoresinfo.multiline = false; submitscoresinfo.wordWrap = false;
			submitscoresinfo.textColor = 0xEC48A7;
			submitscoresinfo.filters = [new BevelFilter(4, 45, 0xFFFFFF, .6, 0x000000, .2, 4, 4, 1, 2), new DropShadowFilter(4, 50, 0x000000, .8, 6, 6, 1, 2)];
			submitscoresinfo.text = "Submitting score...";
			container.addChild(submitscoresinfo);
			
			tryagainbutton = new Button("Try again!", 620, 520, 0, tryagain, 20);
			tryagainbutton.transform.colorTransform = new ColorTransform(1, 2, 2);
			container.addChild(tryagainbutton);
			
			container.x = Main.halfwidth - 400; container.y = Main.halfheight - 300;
			Main.universe.addChild(container);
			
			refreshscores();
			if (username == "") { getusername(); }
		}
		
		private function drawbackground():void {
			simplebg.graphics.beginBitmapFill(Main.textures.middarkgroundtile);
			simplebg.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			
			simplebgdata = new BitmapData(40, 40, true, 0);
			var simplebgalpha:BitmapData = new BitmapData(40, 40, true, 0xFFFFFF + (50 << 24));
			simplebgdata.copyPixels(Main.textures.simplebackground, simplebgdata.rect, new Point(), simplebgalpha, null, true);
			simplebg.graphics.beginBitmapFill(simplebgdata);
			simplebg.graphics.drawRect(0, 0, Main.universe.stageWidth, Main.universe.stageHeight);
			simplebg.filters = [new BlurFilter(12, 12, 2)];
			
			colourtransform.redMultiplier = 1 + Math.random() * 1;
			colourtransform.greenMultiplier = 1 + Math.random() * 1;
			colourtransform.blueMultiplier = 1 + Math.random() * 1;
			simplebg.transform.colorTransform = colourtransform;
			
			simplebgalpha.dispose(); simplebgalpha = null;
			Main.universe.addChild(simplebg);
		}
		
		public function remove():void {
			usernames.length = 0;
			highlightbox.graphics.clear(); container.removeChild(highlightbox);
			tryagainbutton.removelisteners(); container.removeChild(tryagainbutton); tryagainbutton = null;
			container.removeChild(scoresinfo); scoresinfo.text = "";
			container.removeChild(submitscoresinfo); submitscoresinfo.text = "";
			container.removeChild(highscoreinfo); highscoreinfo.text = "";
			container.removeChild(runtimetext); runtimetext.text = "";
			container.removeChild(background);
			Main.universe.removeChild(container);
			
			removebackground();
		}
		
		public function removebackground():void {
			if (simplebg.stage) {
				Main.universe.removeChild(simplebg); simplebg.filters.length = 0;
				simplebgdata.dispose(); simplebgdata = null;
			}
		}
		
		private function tryagain():void {
			remove();
			Main.mapmanager.resetgame(false);
		}
		
		private function refreshscores():void {
			highlightbox.visible = false;
			usernames.length = 0;
			Main.mapmanager.trackmill.getHighscores(10, "DESC", function(response:Object):void {
				if (response.success) {
					var scores:Array = response.scores;
					highscoreinfo.text = "";
					scoresinfo.text = "";
					textformat.align = "left"; highscoreinfo.defaultTextFormat = textformat;
					if (scores.length > 1) {  textformat.align = "left"; highscoreinfo.defaultTextFormat = textformat; }
					for (var n:int = 0; n < scores.length; ++n) {
						usernames.push(scores[n].username);
						
						textformat.size = 20;
						textformat.align = "left";
						highscoreinfo.appendText((n + 1) + ".     " + scores[n].username + "\n\n");
						textformat.color = 0xE4B55C; highscoreinfo.setTextFormat(textformat, highscoreinfo.length - (scores[n].username.length + 2), highscoreinfo.length);
						textformat.size = 15; highscoreinfo.setTextFormat(textformat, highscoreinfo.length - 2, highscoreinfo.length);
						
						textformat.color = 0xE87DF0;
						textformat.align = "right";
						textformat.size = 20;
						var score:Number = scores[n].score / 1000;
						var text:String = "";
						var scoretext:String = "";
						if (score >= 60) {
							score = score / 60;
							
							var decimals:Number = Number("." + String(score).split( "." )[1]);
							var seconds:String = String(int(int((decimals * 60) * 10) / 10));
							if (int(seconds) < 10) { seconds = "0" + seconds; }
							var seconddecimals:Number = Number("." + String(decimals * 60).split( "." )[1]);
							var ms:Number = Math.round(seconddecimals * 100) / 100;
							score = (int(score * 10) / 10);
							scoretext = int(score) + ":" + seconds + "." + String(ms).split( "." )[1];
							text = scoretext + " minutes";
						}else { scoretext = String(score); text = score + " seconds"; }
						
						scoresinfo.appendText(text + "\n\n");
						scoresinfo.setTextFormat(textformat, scoresinfo.length - (text.length + 2), scoresinfo.length);
						textformat.color = 0xB550EB; textformat.size = 15;
						scoresinfo.setTextFormat(textformat, scoresinfo.length - (text.length - scoretext.length + 1), scoresinfo.length);
						textformat.size = 15; scoresinfo.setTextFormat(textformat, scoresinfo.length - 2, scoresinfo.length);
						textformat.color = 0xFFFFFF;
						if (n >= 9) { break; }
					}
					showhighlightbox();
					if (scores.length <= 0) { highscoreinfo.text = "There are no highscores here. Be the first!"; }
				}else {
					highscoreinfo.text = "There was an error while collecting the highscores";
				}
			}, function():void {
				highscoreinfo.text = "There was an error while collecting the highscores";
			});
		}
		
		public function submittedscore(returnedrank:int, error:Boolean):void {
			if (!error) {
				rank = returnedrank;
				highscoreinfo.text = "Refreshing new scores...";
				scoresinfo.text = "";
				textformat.align = "center";
				highscoreinfo.defaultTextFormat = textformat;
				refreshscores();
				submitscoresinfo.text = "Submitted score! You are rank " + rank + "!";
			}else {
				submitscoresinfo.text = "Could not submit score";
			}
		}
		
		private function getusername():void {
			Main.mapmanager.trackmill.loginStatus(function (response:Object):void {
				if (response.username) {
					username = response.username.toLowerCase();
					showhighlightbox();
				}
			});
		}
		
		private function showhighlightbox():void {
			for (var n:int = 0; n < usernames.length; ++n) {
				if (username == usernames[n].toLowerCase()) {
					highlightbox.x = 75; highlightbox.y = 144 + (n * (highscoreinfo.textHeight / usernames.length));
					highlightbox.visible = true;
					break;
				}
			}
		}
	}
}