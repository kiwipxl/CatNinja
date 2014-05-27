package maps {
	
	import editor.trackmill.TrackMill;
	import editor.trackmill.ui.Assets;
	import editor.trackmill.ui.UIManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import ui.Button;
	import flash.utils.getTimer;
	import editor.trackmill.com.adobe.PNGEncoder;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class MapManager {
		
		//mapmanager variables
		public var backbutton:Button;
		public var rooms:Vector.<MapDetails> = new Vector.<MapDetails>;
		public var currentmapdetails:MapDetails;
		public var originalmapdetails:MapDetails;
		public var spawnmapdetails:MapDetails;
		private var destrotate:int = 0;
		public var trackmill:TrackMill;
		private var parseerror:int = -1;
		public var songid:int = 0;
		public var mapsaveddata:String = "";
		private var localsavesearch:int = 0;
		private var infotext:TextField;
		public var fullscreenbutton:Button;
		public var helpmessagesasked:int = 0;
		
		//game time variables
		public var gametimertext:TextField;
		private var gametimecounter:int = 0;
		public var minutecounter:int = 0;
		public var secondcounter:int = 0;
		public var mscounter:int = 0;
		private var interval:int = 1;
		private var maxinterval:int = 59;
		private var maxmsinterval:int = 950;
		private var maxms:int = 0;
		private var maxsecond:int = 0;
		public var timeroff:Boolean = false;
		private var destminutes:int = 0;
		private var destseconds:int = 0;
		public var lasttimer:int = 0;
		public var starttimer:int = 0;
		public var idletimer:int = 0;
		private var starttimerms:int;
		public var starttimeseconds:int;
		private var minuteoffset:int;
		private var secondoffset:int;
		public var completiontime:Number;
		private var minutecompletiontime:int;
		
		//fadescreen variables
		private var fadescreen:Shape = new Shape();
		private var fadespeed:Number = .1;
		private var fadein:Boolean = false;
		private var fadeout:Boolean = false;
		private var doublefade:Boolean = false;
		private var faded:Boolean = false;
		private var targetfadefunction:Function;
		private var fadingscreen:Boolean = false;
		
		public function connect():void {
			trackmill = new TrackMill(Main.universe, "cat-ninja");
			Main.universe.addEventListener(Event.RESIZE, updatefullscreenui);
		}
		
		private function encodetiles(tiles:Array):String {
			var string:String = "";
			var occurringtype:int = -2;
			var count:int = 0;
			for (var n:int = 0; n < tiles.length; ++n) {
				if (occurringtype == -2 && n + 2 < tiles.length && tiles[n + 1] == tiles[n] && tiles[n + 2] == tiles[n]) {
					string += tiles[n] + "%";
					occurringtype = tiles[n];
					count = 1;
				}else if (occurringtype != -2) {
					++count;
					if (tiles[n + 1] != occurringtype || n >= tiles.length - 1) { string += count + ","; occurringtype = -2; count = 0; }
				}else {
					string += tiles[n] + ",";
				}
			}
			return string;
		}
		
		private function decode(tiles:String, id:int):Array {
			var temp:Array = [];
			var occurringtype:int = -2;
			var countto:int = 0;
			
			try {
				while (true) {
					if (tiles.indexOf(",") != -1) {
						var data:String = tiles.substring(0, tiles.indexOf(","));
						if (data.indexOf("undefined") != -1) { tiles = tiles.substring(tiles.indexOf(",") + 1, tiles.length); continue; }
						
						if (data.indexOf("%") != -1) {
							occurringtype = parseInt(tiles.substring(0, tiles.indexOf("%")));
							tiles = tiles.substring(tiles.indexOf("%") + 1, tiles.length);
							countto = parseInt(tiles.substring(0, tiles.indexOf(",")));
							
							for (var n:int = 0; n < countto; ++n) {
								temp.push(occurringtype);
							}
							tiles = tiles.substring(tiles.indexOf(",") + 1, tiles.length);
						}else {
							temp.push(parseInt(data));
							tiles = tiles.substring(tiles.indexOf(",") + 1, tiles.length);
						}
					}else {
						break;
					}
				}
			}catch (error:Error) {
				parseerror = 9001;
			}
			
			return temp;
		}
		
		private function decodelevelcode(levelcode:String):void {
			Main.mapeditor.roommanager.initiate();
			rooms = Main.mapeditor.roommanager.rooms;
			var count:int = 0;
			var index:int = 0;
			
			try {
				while (true) {
					if (levelcode.indexOf("[") != -1) {
						var room:MapDetails = new MapDetails();
						room.blank = false;
						levelcode = levelcode.substring(1, levelcode.length);
						index = 0;
						var maxindex:int = 0;
						while (true) {
							var id:int = levelcode.indexOf("|");
							if (id != -1) {
								var data:String = levelcode.substring(0, id);
								
								if (index == 0) { maxindex = parseInt(data);
								}else if (index == 1) { room.width = parseInt(data);
								}else if (index == 2) { room.height = parseInt(data);
								}else if (index == 3) { room.index = parseInt(data);
								}else if (index == 4) { room.gridx = parseInt(data);
								}else if (index == 5) { room.gridy = parseInt(data);
								}else if (index == 6) { room.finishtiles = parseInt(data);
								}else if (index == 7) { Main.map.playerpoint.x = parseInt(data) * 20;
								}else if (index == 8) { Main.map.playerpoint.y = parseInt(data) * 20;
								}else if (index == 9) { if (parseInt(data) == 1) { originalmapdetails = room; }
								}else if (index == 10) { room.timemode = parseInt(data);
								}else if (index == 11) { room.timeseconds = parseInt(data);
								}else if (index == 12) { room.timeminutes = parseInt(data);
								}else if (index == 13) { songid = parseInt(data);
								}else if (index == 14) { room.tiles = decode(data, 0);
								}else if (index == 15) { room.backgroundtiles = decode(data, 1); }
								
								if (index == 6 && Main.map.playerpoint.x < 0 || index == 7 && Main.map.playerpoint.y < 0) { parseerror = 9002; }
								
								levelcode = levelcode.substring(id + 1, levelcode.length);
								++index;
								
								if (index == maxindex) {
									++count;
									for (var n:int = 0; n < rooms.length; ++n) {
										if (rooms[n].gridx == room.gridx && rooms[n].gridy == room.gridy) {
											rooms[n] = room;
											break;
										}
									}
									break;
								}
							}else {
								break;
							}
						}
					}else {
						if (count == 0) { parseerror = 9000; }
						return;
					}
					levelcode = levelcode.substring(levelcode.indexOf("]") + 1, levelcode.length);
				}
			}catch (error:Error) {
				parseerror = error.errorID;
				return;
			}
			if (levelcode.indexOf("undefined") != -1) {
				parseerror = 9004;
			}
		}
		
		public function submitscore(scoredisplay:String, score:Number):void {
			Main.transition.show(function():void {
				removegame();
				Main.highscorescreen.create(scoredisplay);
				
				trackmill.submitScore( { score:score, score:"DESC" }, function(response:Object):void {
					if (response.success) {
						Main.highscorescreen.submittedscore(response.rank, false);
					}else {
						Main.highscorescreen.submittedscore(response.rank, true);
					}
				}, function():void {
					Main.highscorescreen.submittedscore(0, true);
				});
			});
		}
		
		public function loadsavededitorgame(mapid:int, mapname:String, mapdescription:String, maptags:String, leveldata:String, 
		timemode:int, timeseconds:int, timeminutes:int, finishtiles:int):void {
			rooms = Main.mapeditor.roommanager.rooms;
			for (var n:int = 0; n < rooms.length; ++n) {
				rooms[n].blank = true;
			}
			UIManager.messagebox.hide();
			decodelevelcode(leveldata);
			
			if (!originalmapdetails) { parseerror = 9003; }
			if (parseerror == -1) {
				Main.mapeditor.overwrite = true;
				Main.mapeditor.mapcreator.charroom = originalmapdetails;
				originalmapdetails.timemode = timemode; originalmapdetails.timeseconds = timeseconds; originalmapdetails.timeminutes = timeminutes;
				originalmapdetails.finishtiles = finishtiles;
				
				Main.mapeditor.mapid = mapid;
				Main.mapeditor.ui.settingswindow.mapname = mapname;
				Main.mapeditor.ui.settingswindow.mapdescription = mapdescription;
				Main.mapeditor.ui.settingswindow.maptags = maptags;
				Main.mapeditor.ui.settingswindow.goalitembox.lastselecteditem = timemode;
				Main.mapeditor.ui.settingswindow.goalitembox.lastvaliditem = timemode;
				Main.mapeditor.ui.settingswindow.goalitembox.selecteditem = timemode;
				Main.mapeditor.ui.settingswindow.musicitembox.lastselecteditem = songid;
				Main.mapeditor.ui.settingswindow.musicitembox.lastvaliditem = songid;
				Main.mapeditor.ui.settingswindow.musicitembox.selecteditem = songid;
				Main.mapeditor.ui.settingswindow.secondinterval = timeseconds;
				Main.mapeditor.ui.settingswindow.minuteinterval = timeminutes;
				Main.sound.getsong(songid, true, false);
				Main.mapeditor.roommanager.switchrooms(originalmapdetails);
				UIManager.messagebox.show("Map successfully loaded");
				localsavesearch = 0;
			}else {
				if (localsavesearch * 3 >= Main.mapeditor.savedmaps.length) {
					localsavesearch = 0;
					UIManager.messagebox.show(mapname + " could not be parsed (error: " + parseerror + ")." +
					"There are no saved games left to attempt to parse. Your map has been saved however the editor will clear now.", "Parsing issue", true, 1, "Continue", "",
					function():void { Main.mapeditor.savemap(); Main.mapeditor.exitMap(); starteditor(); 
					Main.mapeditor.loaddetails(originalmapdetails);
					Main.mapeditor.mapcreator.mapresizer.resizeMap(originalmapdetails.width, originalmapdetails.height, true);
					Main.testing = false;
					UIManager.messagebox.hide(); 
					}, null);
				}else {
					var savedmaps:Array = Main.mapeditor.savedmaps;
					var id:int = localsavesearch * 3;
					UIManager.messagebox.show(mapname + " could not be parsed (error: " + parseerror + ")." +
					"Attempting to load saved game: " + savedmaps[id][1], "Parsing issue", true, 1, "Continue", "", function():void {
						loadsavededitorgame(savedmaps[id][0], savedmaps[id][1], savedmaps[id][2], savedmaps[id][3], savedmaps[id + 2], 
						savedmaps[id][4].timemode, savedmaps[id][4].timeseconds, savedmaps[id][4].timeminutes, savedmaps[id][4].finishtiles);
					}, null);
					++localsavesearch;
				}
			}
		}
		
		public function startloadedgame(event:Event = null):void {
			if (!Main.transition.created && !Main.highscorescreen.container.stage) {
				if (!Main.map.map || !Main.map.map.stage) {
					if (!UIManager.messagebox.stage) {
						Main.universe.removeEventListener(MouseEvent.CLICK, startloadedgame);
						UIManager.messagebox.show("Map loaded! Click play or press enter to continue.", "Play now!", true, 1, "Play", "", function():void {
							Main.transition.show(function():void {
								Main.gamepaused = false;
								Main.messagebox.hide();
								Main.messagebox.visible = false;
								UIManager.loadingbox.hide();
								UIManager.messagebox.hide();
								startgame(rooms, originalmapdetails);
							});
						}, null);
					}
				}
			}
		}
		
		public function loadtrackmillmap():void {
			UIManager.loadingbox.show("Getting map data...");
			trackmill.loadLevel(function (response:Object):void {
				if (response.success && response.levelcode) {
					rooms = Main.mapeditor.roommanager.rooms;
					UIManager.messagebox.hide();
					decodelevelcode(response.levelcode);
					
					if (!originalmapdetails) { parseerror = 9003; }
					if (parseerror == -1) {
						UIManager.loadingbox.show("Getting music... click anywhere to skip", true, 10);
						Main.sound.getsong(songid, false, true, startloadedgame, startloadedgame);
						Main.universe.addEventListener(MouseEvent.CLICK, startloadedgame);
					}else {
						UIManager.messagebox.show("Map id (" + trackmill.levelid + ") could not be parsed (error: " + parseerror + ")." +
						"Try contacting the developer so this issue can be solved.", "Parsing issue", true, 0, "", "", null, null);
					}
				}else {
					UIManager.messagebox.show("The map could not be retrieved. The trackmill servers may be down right now.", "Error",
					true, 0, "", "", null, null);
				}
			}, ["name", "description", "creator", "id", "levelcode", "drawbytes"], function():void {
				UIManager.messagebox.show("Could not connect to trackmill. Check your internet connection and try again.", "Error",
				true, 0, "", "", null, null);
			});
		}
		
		public function publishmap(loadingtext:String = "Publishing...", saving:Boolean = false, callback:Function = null, imgwidth:int = 240, imgheight:int = 240):void {
			Main.mapeditor.savedetails();
			if (!saving) {
				var finishtiles:int = 0;
				for (var n:int = 0; n < Main.mapeditor.roommanager.rooms.length; ++n) {
					finishtiles += Main.mapeditor.roommanager.rooms[n].finishtiles;
				}
				
				if (Main.mapeditor.mapcreator.currentcharpos.x == -1 && Main.mapeditor.mapcreator.currentcharpos.y == -1) {
					Main.messagebox.show("Must set kitty starting position <font color='#88de71'>(The kitty starting tile in the eraser menu)</font>");
					return;
				}else if (Main.mapeditor.mapcreator.details.timemode != 3 && finishtiles == 0) {
					Main.messagebox.show("You can't publish your map without having any completion tiles! " +
					"<font color='#88de71'>(They can be found in the tiles menu)</font>");
					return;
				}
			}
			Main.messagebox.hide(false);
			UIManager.loadingbox.show(loadingtext);
			Main.mapeditor.roommanager.openroommenu(false);
			Main.mapeditor.roommanager.closeroommenu();
			Main.mapeditor.savedetails();
			Main.mapeditor.setoverlay();
			Main.mapeditor.ui.tooltip.tileinfobox.visible = false;
			
			try {
				var data:String = "";
				for each (var room:MapDetails in Main.mapeditor.roommanager.rooms) {
					if (!room.blank) {
						var compressedtiles:String = encodetiles(room.tiles.concat());
						var compressedbackgroundtiles:String = encodetiles(room.backgroundtiles.concat());
						
						var maxindex:int = 16;
						data += "[" + maxindex + "|" + room.width + "|" + room.height + "|" + room.index + "|" + room.gridx + "|" + room.gridy + "|" + 
						room.finishtiles + "|" + Main.mapeditor.mapcreator.currentcharpos.x + "|" + Main.mapeditor.mapcreator.currentcharpos.y + "|";
						if (room == Main.mapeditor.mapcreator.charroom) { data += "1" } else { data += "0"; }
						data += "|" + room.timemode + "|" + room.timeseconds + "|" + room.timeminutes + "|" + songid;
						data += "|" + compressedtiles + "|" + compressedbackgroundtiles + "|" + "]";
						
						compressedtiles = "";
						compressedbackgroundtiles = "";
					}
				}
				mapsaveddata = data;
			}catch (error:Error) {
				UIManager.messagebox.show("An error occurred while parsing the map data", "Parsing error");
				return;
			}
			
			try {
				var image:BitmapData = new BitmapData(600, 600, false, 0);
				if (Main.mapeditor.roommanager.currentroom != Main.mapeditor.mapcreator.charroom) {
					var lastroom:MapDetails = Main.mapeditor.roommanager.currentroom;
					Main.mapeditor.roommanager.switchrooms(Main.mapeditor.mapcreator.charroom);
					getscreenshot(image);
					Main.mapeditor.roommanager.switchrooms(lastroom);
				}else {
					getscreenshot(image);
				}
				trackmill.createThumbnailFromData(image, imgwidth, imgheight);
				if (callback == null) { callback = serverresponse; }
				if (!saving) {
					UIManager.messagebox.show("Are you sure you want to publish your map? You will not be allowed to modify the published map after it's published.", 
					"Are you sure?", true, 2, "No", "Yes", null, function():void {
						UIManager.messagebox.hide();
						UIManager.loadingbox.show(loadingtext);
						mapsaveddata = "";
						trackmill.submitLevel( { name:Main.mapeditor.ui.settingswindow.mapname, description:Main.mapeditor.ui.settingswindow.mapdescription, 
						tags:Main.mapeditor.ui.settingswindow.maptags, levelCode:data}, callback, function():void {
							UIManager.messagebox.show("Error: Could not connect to the server.", "Error");
						});
					});
				}else {
					callback();
				}
				image = null;
			}catch (error:Error) {
				UIManager.messagebox.show("There was an error connecting to the trackmill server or taking a screenshot. Error id: " + 
				error.errorID + "," + error.message, "Error");
			}
		}
		
		private function getscreenshot(image:BitmapData):void {
			var width:int = Main.mapeditor.mapcreator.map.width; var height:int = Main.mapeditor.mapcreator.map.height; 
			var x:int = Main.mapeditor.mapcreator.currentcharpos.x * 20; var y:int = Main.mapeditor.mapcreator.currentcharpos.y * 20;
			var negx:int = 300; if (x - 300 < 0) { negx = x;
			}else if (x + 300 > Main.mapeditor.mapcreator.map.width) { negx = 300 + (300 - ((Main.mapeditor.mapcreator.map.width) - x)); }
			var negy:int = 300; if (y - 300 < 0) { negy = y;
			}else if (y + 300 > Main.mapeditor.mapcreator.map.height) { negy = 300 + (300 - ((Main.mapeditor.mapcreator.map.height) - y)); }
			
			image.copyPixels(Main.mapeditor.mapcreator.map.bitmapData, new Rectangle(x - negx, y - negy, 600, 600), new Point(0, 0));
			image.colorTransform(image.rect, Main.mapeditor.mapcreator.colourchanger.transform);
		}
		
		private function serverresponse(response:Object):void {
			UIManager.loadingbox.hide();
			if (response.success) {
				System.setClipboard("http://www.trackmill.com/cat-ninja/maps/" + response.levelid);
				UIManager.messagebox.show("Successfully published map! Copied url to clipboard. Just paste it in the address bar.", "Success!");
			}else {
				if (response.error == 0) { UIManager.messagebox.show("Unable to connect to the trackmill server. Trackmill may be down.", "Error");
				}else if (response.error == 1) { trackmill.createlogin(publishmap);
				UIManager.messagebox.show("You are not logged in to trackmill. Please login to continue.", "Login");
				}else if (response.error == 2) { UIManager.messagebox.show("Game data missing", "Error");
				}else if (response.error == 3) { UIManager.messagebox.show("Invalid game id. Unable to publish successfully.", "Error");
				}else if (response.error == "A") { UIManager.messagebox.show("Map name missing", "Error");
				}else if (response.error == "B") { UIManager.messagebox.show("Map description missing", "Error");
				}else if (response.error == "C") { UIManager.messagebox.show("Map data missing", "Error");
				}else { UIManager.messagebox.show("Well that's weird. An unknown error has occurred.", "Error"); }
			}
		}
		
		public function resetgame(remove:Boolean = true):void {
			if (!Main.transition.created && !fadingscreen) {
				Main.transition.show(function():void {
					UIManager.messagebox.hide();
					if (remove) { removegame(); }
					Main.map.resettedgame = true;
					startgame(rooms, originalmapdetails);
				});
			}
		}
		
		public function startgame(roomdetails:Vector.<MapDetails>, startingroom:MapDetails):void {
			var mapdetails:MapDetails = startingroom;
			originalmapdetails = startingroom;
			spawnmapdetails = originalmapdetails;
			currentmapdetails = mapdetails;
			rooms = roomdetails.concat();
			Main.map.resettedgame = true;
			Main.map.create(mapdetails);
			Main.player.create();
			Main.testing = true;
			Main.universe.focus = null;
			Main.menu.showpause();
			Main.collected = 0;
			Main.map.setRotation(0);
			
			if (trackmill.gamemode == "create") {
				backbutton = new Button("Back", 0, 0, 1, function():void {
					endtesting();
				}, 15)
				backbutton.start();
				Main.universe.addChild(backbutton);
			}
			
			gametimertext = new TextField();
			var format:TextFormat = new TextFormat();
			format.font = "square";
			format.align = "center";
			format.size = 60;
			gametimertext.embedFonts = true;
			gametimertext.defaultTextFormat = format;
			gametimertext.textColor = 0xFFFFFF;
			gametimertext.width = 300;
			gametimertext.height = 150;
			gametimertext.x = (Main.halfwidth) - 150;
			gametimertext.y = 20;
			gametimertext.selectable = false; gametimertext.multiline = false; gametimertext.wordWrap = false;
			Main.universe.addChild(gametimertext);
			Main.sound.play(2 + songid);
			
			format.align = "right";
			format.size = 12;
			infotext = new TextField();
			infotext.embedFonts = true;
			infotext.defaultTextFormat = format;
			infotext.textColor = 0xFFFFFF;
			infotext.width = 200;
			infotext.height = 200;
			infotext.x = Main.universe.stageWidth - 210;
			infotext.y = Main.universe.stageHeight - 90;
			infotext.filters = [new GlowFilter(0x000000, 1, 2, 2, 4)];
			infotext.selectable = false; infotext.multiline = true; infotext.wordWrap = true;
			updateinfotext();
			Main.universe.addChild(infotext);
			
			Main.universe.addEventListener(Event.ENTER_FRAME, update);
			
			fadescreen.graphics.clear();
			fadescreen.graphics.lineStyle(1, 0x000000);
			fadescreen.graphics.beginFill(0x000000);
			fadescreen.graphics.drawRect(0, 0, 800, 600);
			fadescreen.visible = false;
			fadescreen.alpha = 0;
			Main.universe.addChild(fadescreen);
			
			createfullscreenbutton(5);
			Main.gamepaused = true;
			Main.countdown.start(function():void {
				lasttimer = getTimer();
				starttimer = getTimer();
				starttimerms = getTimer();
				starttimeseconds = getTimer();
				idletimer = 0;
				configuretimer();
				updatetime();
			})
		}
		
		public function updateinfotext():void {
			var spheretext:String = String(Main.collected);
			if (originalmapdetails.timemode == 3) {
				spheretext += "/" + originalmapdetails.timeseconds;
				if (Main.collected >= originalmapdetails.timeseconds) {
					completedmap();
				}
			}
			
			infotext.htmlText = "<font color='#BE1842' size='20'>" + Main.player.respawns + "</font> Deaths<br>" + 
			"<font color='#ED9AEB' size='20'>" + spheretext + "</font> Spheres collected<br>" + 
			"Press <font color='#4976ED' size='20'>R</font> to respawn<br>" + "Press <font color='#CF4EDE' size='20'>U</font> to reset<br>";
		}
		
		public function completedmap(onlycalculate:Boolean = false):void {
			if (Main.player.dead) { return; }
			Main.player.allowrespawn = false;
			Main.player.die();
			Main.time.runFunctionIn(50, function():void {
			Main.particles.create(Main.player.x + ((Math.random() * 400) - (Math.random() * 400)),
											Main.player.y + ((Math.random() * 300) - (Math.random() * 300)), 5, 15, 25, Math.random() * 7, null);
			}, true);
			Main.time.runFunctionIn(140, function():void {
				Main.sound.playsfx(4);
			}, true);
			Main.shakescreen.shake(10, 10);
			timeroff = true;
			updatetime();
			
			minutecompletiontime = ((minutecounter * 60) * 1000);
			completiontime = (secondcounter * (1000 / 60) * 60) + mscounter;
			if (originalmapdetails.timemode == 1) {
				minutecompletiontime = ((originalmapdetails.timeminutes * 60) * 1000) - minutecompletiontime;
				completiontime = ((originalmapdetails.timeseconds * (1000 / 60) * 60)) - completiontime;
			}
			
			if (!onlycalculate) { 
				Main.time.runFunctionIn(1500, function():void {
					var timetext:String = createtimetext();
					if (trackmill.gamemode == "play") {
						submitscore(timetext, minutecompletiontime + completiontime);
					}else {
						Main.gamepaused = true;
						timetext = "<font color='#B44FD5'>" + timetext + "!</font>";
						UIManager.messagebox.show("You beat your map in " + timetext, "Complete!", true, 2, "Back", "Reset", 
						endtesting, resetgame);
					}
				});
			}
		}
		
		private function createtimetext():String {
			var timetext:String = "<font size='40'>";
			if (minutecompletiontime >= 60000) {
				var seconds:String = String((int((completiontime / 1000) * 100) / 100));
				if (int(seconds) < 10) { seconds = "0" + seconds; }
				timetext += (int(((minutecompletiontime / 60) / 1000) * 100) / 100) + ":" + seconds + 
				" </font><font size='15'>minutes</font>";
			}else {
				timetext += int((completiontime / 1000) * 100) / 100 + " </font><font size='15'>seconds</font>";
			}
			return timetext;
		}
		
		private function createfullscreenbutton(x:int):void {
			if (!fullscreenbutton) {
				fullscreenbutton = new Button("", x, Main.universe.stageHeight - 32, 1, function():void {
					if (Main.map.map && Main.map.map.stage || 
					Main.mapeditor.created && !Main.mapeditor.ui.pausewindow.visible &&!Main.mapeditor.ui.settingswindow.showingsettings) {
						if (Main.universe.displayState == StageDisplayState.NORMAL) {
							fullscreenon();
						}else {
							fullscreenoff();
						}
					}
				}, 15, 30, Main.textures.fullscreenbutton, true, -1);
				Main.universe.addChild(fullscreenbutton);
			}
		}
		
		private function configuretimer():void {
			gametimertext.visible = true;
			if (originalmapdetails.timemode == 1) { countdown(true);
				if (originalmapdetails.timeminutes == 0 && originalmapdetails.timeseconds == 0) {
					interval = 0; secondcounter = 0; minutecounter = 0; mscounter = 0; gametimertext.text = "00:00"; timeroff = true;
					minuteoffset = 0; secondoffset = 0;
				}else {
					if (originalmapdetails.timeminutes != 0) { destminutes = originalmapdetails.timeminutes; }
					if (originalmapdetails.timeseconds != 0) { destseconds = originalmapdetails.timeseconds; }
					if (destminutes >= 30) { destminutes = 30; }
					minuteoffset = 3600000 - (destminutes * 1000 * 60);
					secondoffset = 60000 - (destseconds * 1000);
				}
			}else if (originalmapdetails.timemode == 0 || originalmapdetails.timemode == 2 || originalmapdetails.timemode == 3) {
			countdown(false); minutecounter = 0; secondcounter = 0; minuteoffset = 0; secondoffset = 0; }
			if (originalmapdetails.timemode == 2 || originalmapdetails.timemode == 3) { gametimertext.visible = false; }
		}
		
		private function countdown(down:Boolean = false):void {
			if (down) {
				interval = 1;
				maxsecond = 60;
				maxinterval = 0;
				maxmsinterval = 0;
				maxms = 1000;
				mscounter = 0;
				destminutes = 0;
				destseconds = 0;
			}else {
				interval = -1;
				maxsecond = 0;
				maxinterval = 60;
				maxmsinterval = 1000;
				maxms = 0;
				minutecounter = 0;
				secondcounter = 0;
				mscounter = 0;
			}
			timeroff = false;
		}
		
		public function calculatetimer():void {
			minutecounter = maxsecond - (Math.ceil(((getTimer() - starttimer) + minuteoffset - idletimer) / 1000) / 61) * interval;
			secondcounter = maxsecond - (int((getTimer() - starttimeseconds) + secondoffset - idletimer) / 1000) * interval;
			mscounter = maxms - (getTimer() - starttimerms) * interval;
		}
		
		public function updatetime():void {
			var m:String = ""; var s:String = ""; var ms:String = "";
			
			var lastsecond:int = secondcounter;
			calculatetimer();
			ms = int(mscounter / 10).toString();
			var lastms:int = mscounter;
			
			if (mscounter >= maxmsinterval && interval == -1 || mscounter <= 0 && interval == 1) { starttimerms = getTimer(); mscounter = maxms; }
			if (interval == -1 && secondcounter >= maxinterval && secondcounter <= maxinterval || 
			interval == 1 && secondcounter >= maxinterval && secondcounter <= maxinterval && lastms <= 0 && lastsecond <= 0) {
			if (interval == 1) { secondoffset = 0; minuteoffset += 60000; }
			starttimeseconds = getTimer() - idletimer; secondcounter = maxinterval; }
			if (secondcounter < 10) { s = "0" + secondcounter.toString(); }else { s = secondcounter.toString(); }
			if (minutecounter < 10) { m = "0" + minutecounter.toString(); }else { m = minutecounter.toString(); }
			
			if (minutecounter <= 0 && secondcounter <= 0 && lastsecond <= 0 && lastms <= 0 && interval == 1 ||
				minutecounter >= 29 && secondcounter >= 59 && mscounter <= 0 && interval == -1) {
				Main.player.allowrespawn = false; Main.player.die();
				var message:String = "The timer ran out!";
				if (interval == -1 && minutecounter >= 29) { message = "The timer went too far! Did you really wait 30 minutes and 59 seconds or was that just a bug?"; }
				interval = 0; secondcounter = 0; mscounter = 0; s = "00"; m = "00"; ms = "00"; timeroff = true;
				Main.messagebox.show(message, 1, -1, -1, "Reset", "Give up", function():void {
					resetgame();
					Main.messagebox.hide();
					configuretimer();
					Main.player.allowrespawn = true;
					Main.player.respawn();
				}, null);
			}
			
			calculatetimer();
			
			if (minutecounter < 0 || secondcounter < 0) { gametimertext.visible = false; }else { gametimertext.visible = true; }
			
			if (destminutes >= 1 || minutecounter >= 1) { gametimertext.text = m + ":" + s + ":" + ms;
			}else { gametimertext.text = s + ":" + ms; }
			
			var transform:ColorTransform = Main.map.colourchanger.transform;
			gametimertext.textColor =  (transform.blueMultiplier * 150) << 16 | (transform.greenMultiplier * 150) << 8 | (transform.redMultiplier * 150);
			lasttimer = getTimer();
		}
		
		private function updatefullscreenui(event:Event = null):void {
			if (Main.mapeditor.created && Main.universe.displayState == StageDisplayState.NORMAL) {
				Main.mapeditor.ui.settingswindow.hidesettings(false);
				if (Main.mapeditor.roommanager.roommenushown) { Main.mapeditor.roommanager.closeroommenu(); }
				if (Main.mapeditor.ui.savedgamelist.stage) { Main.mapeditor.ui.savedgamelist.hide(); }
				if (Main.menu.instructionpage && Main.menu.instructionpage.stage) { Main.menu.hidehelp(); }
			}
			
			Main.halfwidth = Main.universe.stageWidth / 2; Main.halfheight = Main.universe.stageHeight / 2;
			Main.menu.navbar.x = Main.universe.stageWidth - 25;
			
			if (Main.mapeditor.created) {
				if (Main.mapeditor.ui.currenttilebox) {
					Main.mapeditor.ui.currenttilebox.y = Main.universe.stageHeight - 32;
					Main.mapeditor.ui.currentroomtext.x = Main.universe.stageWidth - 260; Main.mapeditor.ui.currentroomtext.y = Main.universe.stageHeight - 30;
				}
				Main.mapeditor.ui.pausewindow.width = Main.universe.stageWidth; Main.mapeditor.ui.pausewindow.height = Main.universe.stageHeight;
				
				if (Main.mapeditor.ui.settingswindow.settingswindow.stage) {
					Main.mapeditor.ui.settingswindow.settingsbox.x = Main.halfwidth - (Main.mapeditor.ui.settingswindow.settingsbox.width / 2);
					Main.mapeditor.ui.settingswindow.settingsbox.y = Main.halfheight - (Main.mapeditor.ui.settingswindow.settingsbox.height / 2);
				}
				if (Main.mapeditor.roommanager.roommenushown) {
					Main.mapeditor.roommanager.removebutton.y = Main.universe.stageHeight - 26;
					Main.mapeditor.roommanager.drawbackground();
					Main.mapeditor.roommanager.arrows.x = Main.halfwidth; Main.mapeditor.roommanager.arrows.y = Main.halfheight;
				}
				if (Main.mapeditor.ui.savedgamelist.visible) {
					Main.mapeditor.ui.savedgamelist.backgroundbox.x = Main.halfwidth - (Main.mapeditor.ui.savedgamelist.backgroundbox.width / 2);
					Main.mapeditor.ui.savedgamelist.backgroundbox.y = Main.halfheight - (Main.mapeditor.ui.savedgamelist.backgroundbox.height / 2);
					Main.mapeditor.ui.savedgamelist.background.x = Main.halfwidth - (Main.mapeditor.ui.savedgamelist.background.width / 2);
					Main.mapeditor.ui.savedgamelist.background.y = Main.halfheight - (Main.mapeditor.ui.savedgamelist.background.height / 2);
				}
			}else if (Main.highscorescreen.container.stage) {
				Main.highscorescreen.container.x = Main.halfwidth - 400; Main.highscorescreen.container.y = Main.halfheight - 300;
				if (Main.highscorescreen.container.stage) {
					Main.highscorescreen.removebackground();
				}
			}else {
				infotext.x = Main.universe.stageWidth - 210; infotext.y = Main.universe.stageHeight - 90;
				gametimertext.x = Main.halfwidth - 150;
			}
			if (fullscreenbutton && fullscreenbutton.stage) { fullscreenbutton.x = 5; fullscreenbutton.y = Main.universe.stageHeight - 32; }
			if (Main.mapeditor.created) { fullscreenbutton.x = 40; }
			if (trackmill.loginwindow && trackmill.loginwindow.visible) {
				trackmill.loginwindow.x = Main.halfwidth - (Assets.loginscreen.width /  2); trackmill.loginwindow.y = Main.halfheight - (Assets.loginscreen.height / 2);
				trackmill.loginwindow.backfadedscreen.width = Main.universe.stageWidth; trackmill.loginwindow.backfadedscreen.height = Main.universe.stageHeight;
			}
			if (UIManager.messagebox.visible) {
				UIManager.messagebox.bgfadedscreen.width = Main.universe.stageWidth; UIManager.messagebox.bgfadedscreen.height = Main.universe.stageHeight;
				UIManager.messagebox.x = Main.halfwidth + (Assets.loginmessage.width - UIManager.messagebox.base.width) / 2;
				UIManager.messagebox.y = Main.halfheight + (Assets.loginmessage.height - UIManager.messagebox.base.height) / 2;
				UIManager.messagebox.bgfadedscreen.x = -Main.halfwidth; UIManager.messagebox.bgfadedscreen.y = -Main.halfheight;
				UIManager.messagebox.windowcontainer.x = Main.halfwidth; UIManager.messagebox.windowcontainer.y = Main.halfheight;
			}
			if (UIManager.loadingbox.visible) {
				UIManager.loadingbox.bgfadedscreen.width = Main.universe.stageWidth; UIManager.messagebox.bgfadedscreen.height = Main.universe.stageHeight;
				UIManager.loadingbox.x = Main.halfwidth + (Assets.loginmessage.width - UIManager.messagebox.base.width) / 2;
				UIManager.loadingbox.y = Main.halfheight + (Assets.loginmessage.height - UIManager.loadingbox.base.height) / 2;
				UIManager.loadingbox.bgfadedscreen.x = -Main.halfwidth; UIManager.loadingbox.bgfadedscreen.y = -Main.halfheight;
				UIManager.loadingbox.windowcontainer.x = Main.halfwidth; UIManager.loadingbox.windowcontainer.y = Main.halfheight;
			}
			if (Main.messagebox.visible) {
				Main.messagebox.pausewindow.width = Main.universe.stageWidth; Main.messagebox.pausewindow.height = Main.universe.stageHeight;
				Main.messagebox.x = Main.halfwidth + (Assets.loginmessage.width - Main.messagebox.base.width) / 2;
				Main.messagebox.y = Main.halfheight + (Assets.loginmessage.height - Main.messagebox.base.height) / 2;
				Main.messagebox.pausewindow.x = -Main.halfwidth; Main.messagebox.pausewindow.y = -Main.halfheight;
				Main.messagebox.windowcontainer.x = Main.halfwidth; Main.messagebox.windowcontainer.y = Main.halfheight;
			}
		}
		
		public function fullscreenon():void {
			if (!Main.gamepaused) {
				Main.gamepaused = true;
				Main.messagebox.show("Are you sure you want to go fullscreen? <font color='#FCA0CA'> If you have a slow computer this mode could significantly " +
				"slow down the game.</font>", 2, -1, -1, "No", "Let's go", function():void {
					Main.gamepaused = false;
					Main.messagebox.hide();
				}, function():void {
					Main.gamepaused = false;
					Main.messagebox.hide();
					Main.universe.scaleMode = StageScaleMode.NO_SCALE;
					Main.universe.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				});
			}
		}
		
		public function fullscreenoff():void {
			Main.halfwidth = Main.universe.stageWidth; Main.halfheight = Main.universe.stageHeight;
			Main.universe.displayState = StageDisplayState.NORMAL;
		}
		
		public function starteditor():void {
			Main.mapeditor.create();
			Main.universe.focus = null;
			Main.mouse.mouseIsDown = false;
			Main.menu.hidepause();
			
			createfullscreenbutton(40);
			
			if (helpmessagesasked <= 2) {
				Main.mapeditor.mapcreator.update();
				Main.menu.showhelp();
				++helpmessagesasked;
				Main.mapeditor.sharedobject.data.helpmessagesasked = helpmessagesasked;
				Main.mapeditor.sharedobject.flush();
			}
		}
		
		public function removegame():void {
			Main.messagebox.hide(false);
			Main.player.respawngame(true);
			if (Main.gamepaused) { Main.menu.resume(); }
			Main.player.remove();
			Main.map.remove();
			Main.player.remove();
			Main.universe.removeEventListener(Event.ENTER_FRAME, update);
			Main.menu.hidepause();
			Main.time.removeall();
			Main.countdown.remove();
			
			fadescreen.graphics.clear();
			Main.universe.removeChild(fadescreen);
			if (trackmill.gamemode == "create") {
				backbutton.removelisteners();
				Main.universe.removeChild(backbutton);
				backbutton = null;
			}
			if (fullscreenbutton) {
				fullscreenbutton.removelisteners(); Main.universe.removeChild(fullscreenbutton); fullscreenbutton = null;
			}
			Main.universe.removeChild(infotext);
			infotext = null;
			Main.universe.removeChild(gametimertext);
			gametimecounter = 0;
			minutecounter = 0; secondcounter = 0; mscounter = 0;
			Main.universe.focus = null;
			Main.mouse.mouseIsDown = false;
			Main.player.allowrespawn = true;
			Main.time.removeall();
			Main.testing = false;
			Main.gamepaused = false;
		}
		
		public function endtesting():void {
			Main.transition.show(function():void {
				UIManager.messagebox.hide();
				removegame();
				rooms.length = 0;
				
				Main.mapeditor.mapcreator.details = originalmapdetails;
				Main.mapeditor.roommanager.currentroom = originalmapdetails;
				starteditor();
				
				Main.mapeditor.loaddetails(originalmapdetails);
				Main.mapeditor.mapcreator.mapresizer.resizeMap(originalmapdetails.width, originalmapdetails.height, true);
				Main.testing = false;
			});
		}
		
		public function update(event:Event):void {
			Main.sound.update();
			if (Main.transition.created) { return; }
			Main.messagebox.update();
			if (!Main.gamepaused) {
				if (!timeroff) { updatetime(); }
				if (originalmapdetails.timemode == 2) { gametimertext.visible = false; }
				Main.map.update();
				Main.shakescreen.update();
				Main.mapcamera.update();
				
				if (!Main.map.rotating) {
					Main.trail.update();
					Main.env.update();
					Main.particles.update();
					if (!Main.player.dead) {
						Main.player.update();
					}
					Main.time.update();
				}
				Main.mapcamera.moveTo(Main.player.x + 10, Main.player.y + 10);
			}else {
				Main.countdown.update();
			}
			
			if (fadingscreen) {
				if (fadein) {
					fadescreen.alpha += fadespeed;
					if (fadescreen.alpha >= 1) {
						fadescreen.alpha = 1;
						fadein = false;
						if (doublefade && !faded) {
							fadeout = true; faded = true;
							if (targetfadefunction != null) { targetfadefunction(); targetfadefunction = null; }
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
							if (targetfadefunction != null) { targetfadefunction(); targetfadefunction = null; }
						}else {
							fadingscreen = false;
						}
					}
				}
			}
		}
		
		public function moverooms(dx:int, dy:int):void {
			var found:Boolean = false;
			for (var n:int = 0; n < rooms.length; ++n) {
				if (!rooms[n].blank && rooms[n].gridx == currentmapdetails.gridx + dx && rooms[n].gridy == currentmapdetails.gridy + dy) {
					found = true;
					destrotate = Main.map.destrotate;
					Main.gamepaused = true; fadein = true; doublefade = true; faded = false; fadingscreen = true; fadescreen.alpha = 0; fadescreen.visible = true;
					Main.universe.setChildIndex(fadescreen, Main.universe.numChildren - 1);
					
					targetfadefunction = function():void {
						Main.map.remove();
						currentmapdetails = rooms[n];
						Main.map.create(currentmapdetails);
						
						var px:int = 0; var py:int = Main.player.y;
						if (dx == -1 && dy == 0) { px = (rooms[n].width * 20) - 30;
						}else if (dx == 0 && dy == 1) { px = Main.player.x - 10; py = 0;
						}else if (dx == 0 && dy == -1) { px = Main.player.x - 10; py = (rooms[n].height * 20) - 40; }
						
						if (px >= rooms[n].width * 20) { px = (rooms[n].width * 20) - 40;
						}else if (py >= rooms[n].height * 20) { py = (rooms[n].height * 20) - 40; }
						
						Main.map.playerpoint.x = px; Main.map.playerpoint.y = py;
						
						Main.map.destrotate = destrotate;
						Main.map.destrotate = destrotate;
						Main.world.rotation = destrotate;
						Main.player.rotation = destrotate;
						Main.map.rotating = false;
						
						Main.mapcamera.moveTo(Main.map.playerpoint.x, Main.map.playerpoint.y, true);
						Main.player.reset();
						Main.gamepaused = false;
						
						if (!Main.map.grid[int(Main.map.playerpoint.y / 20) * Main.map.gridwidth + int(Main.map.playerpoint.x / 20)].walkable) {
							Main.player.die();
						}
					}
					break;
				}
			}
			if (!found) { Main.player.die(); }
		}
		
		public function gotoroom(map:MapDetails):void {
			Main.gamepaused = true; fadein = true; doublefade = true; faded = false; fadingscreen = true; fadescreen.alpha = 0; fadescreen.visible = true;
			Main.universe.setChildIndex(fadescreen, Main.universe.numChildren - 1);
			targetfadefunction = function():void {
				Main.map.remove();
				currentmapdetails = map;
				Main.map.create(map);
				Main.player.respawngame();
				Main.gamepaused = false;
			}
		}
	}
}