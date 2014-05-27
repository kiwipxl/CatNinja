package tools.text {
	
	import entities.ScriptObject;
	import flash.display.Sprite;
	import maps.TeleporterNode;
	
	/**
	 * ...
	 * @author Feffers
	 */
	public class GlitchInterpreter {
		
		//glitchinterpreter variables
		public var data:Vector.<GlitchScript>;
		private var scriptcount:int = 0;
		
		public function load(events:Array):void {
			data = new Vector.<GlitchScript>;
			Main.time.timers.length = 0;
			
			for (var n:int = 0; n < events.length; ++n) {
				var script:GlitchScript = new GlitchScript();
				var scriptdata:String = events[n];
				scriptdata = scriptdata.replace("$(ap)", "\'");
				script.data = scriptdata.split("\n");
				script.id = scriptcount;
				++scriptcount;
				data.push(script);
				interperate(n, "", true);
			}
		}
		
		public function interperate(page:int = 0, str:String = "", runNextLine:Boolean = true):void {
			var line:int = 0;
			if (str == "") {
				var string:String = "";
				if (page < data.length && data[page].line < data[page].data.length) {
					line = data[page].line;
					string = data[page].data[data[page].line];
					++data[page].line;
				}else {
					return;
				}
			}else {
				string = str;
			}
			
			//functions
			var params:Array = [];
			if (string.length >= 5 && string.substring(0, 5) == "talk(") {
				params = getParameters(string.substring(5, find(string, ")")), 2);
				if (params.length >= 3) {
					params[1]  = params[1].replace(/"/gi, "");
					if (params.length >= 4) {
						Main.speech.talk(params[0], params[1], params[2], Boolean(params[3]));
					}else {
						Main.speech.talk(params[0], params[1], params[2]);
					}
				}
			}else if (string.length >= 11 && string.substring(0, 11) == "pausecamera") {
				Main.mapcamera.paused = true;
			}else if (string.length >= 12 && string.substring(0, 12) == "stopmovement") {
				Main.player.stopMovement = true;
				Main.player.rotation = 0;
			}else if (string.length >= 6 && string.substring(0, 6) == "pause(") {
				params = getParameters(string.substring(6, find(string, ")")), 1);
				if (params.length >= 1) {
					Main.time.runFunctionIn(int(params[0]), interperate, false, page);
					return;
				}
			}else if (string.length >= 9 && string.substring(0, 9) == "setspawn(") {
				params = getParameters(string.substring(9, find(string, ")")), 2);
				if (params.length >= 2) {
					Main.player.spawnx = int(params[0]) * 20;
					Main.player.spawny = int(params[1]) * 20;
				}
			}else if (string.length >= 4 && string.substring(0, 4) == "die(") {
				Main.player.die();
			}else if (string.length >= 8 && string.substring(0, 8) == "setroom(") {
				params = getParameters(string.substring(8, find(string, ")")), 1);
				if (params.length >= 1) {
					var room:String = params[0].substring(1, params[0].length - 1);
					Main.map.changeRoom(room);
				}
			}else if (string.length >= 9 && string.substring(0, 9) == "function(") {
				params = getParameters(string.substring(9, find(string, ")")), 1);
				if (params.length >= 1) {
					gotoLine("endfunction", page, 0);
					return;
				}
			}else if (string.length >= 5 && string.substring(0, 5) == "goto(") {
				params = getParameters(string.substring(5, find(string, ")")), 1);
				if (params.length >= 1) {
					if (data.length > 0) {
						for (var p:int = 0; p < 9; ++p) {
							if (data.length > p) {
								var pageline:int = data[p].line; data[p].line = 0;
								if (!gotoLine(params[0], p, 1)) {
									data[p].line = pageline;
								}
							}else {
								break;
							}
						}
					}
					return;
				}
			}else if (string.length >= 12 && string.substring(0, 12) == "settypepath(") {
				params = getParameters(string.substring(12, find(string, ")")), 6);
				if (params.length >= 6) {
					var fromx:int = params[0]; var fromy:int = params[1];
					var tox:int = params[2]; var toy:int = params[3];
					var x:int = fromx; var y:int = fromy;
					for (var g:int = 0; g < (tox - fromx) + (toy - fromy) + 1; ++g) {
						Main.map.changeTile(x, y, params[4], null, null, true, Boolean(params[3]));
						if (x != tox) { ++x; } else if (y != toy) { ++y; }
					}
				}
			}else if (string.length >= 8 && string.substring(0, 8) == "settype(") {
				params = getParameters(string.substring(8, find(string, ")")), 4);
				if (params.length >= 4) {
					Main.map.changeTile(params[0], params[1], params[2], null, null, true, Boolean(params[3]));
				}
			}else if (string.length >= 12 && string.substring(0, 12) == "createlaser(") {
				params = getParameters(string.substring(12, find(string, ")")), 5);
				if (params.length >= 5) {
					Main.env.createLaser(params[0], params[1], params[2], params[3], params[4]);
				}
			}else if (string.length >= 13 && string.substring(0, 13) == "createobject(") {
				params = getParameters(string.substring(13, find(string, ")")), 3);
				if (params.length >= 3) {
					Main.objectmanager.create(params[0], params[1], params[2], params[3]);
				}
			}else if (string.length >= 6 && string.substring(0, 6) == "scale(") {
				params = getParameters(string.substring(6, find(string, ")")), 2);
				if (params.length >= 2) {
					Main.objectmanager.scale(params[0], params[1], params[2]);
				}
			}else if (string.length >= 10 && string.substring(0, 10) == "movecamera") {
				params = getParameters(string.substring(11, find(string, ")")), 2);
				if (params.length >= 2) {
					Main.mapcamera.moveTo(params[0], params[1], true);
				}
			}else if (string.length >= 12 && string.substring(0, 12) == "resumecamera") {
				Main.mapcamera.paused = false;
			}else if (string.length >= 14 && string.substring(0, 14) == "resumemovement") {
				Main.player.stopMovement = false;
			}else if (string.length >= 5 && string.substring(0, 5) == "walk(") {
				params = getParameters(string.substring(5, find(string, ")")), 1);
				if (params.length >= 1) {
					Main.objectmanager.walk(params[0], params[1]);
				}
			}else if (string.length >= 6 && string.substring(0, 6) == "shake(") {
				params = getParameters(string.substring(6, find(string, ")")), 1);
				if (params.length >= 2) {
					Main.shakescreen.shake(params[0], params[1]);
				}
			}else if (string.length >= 11 && string.substring(0, 11) == "addgravity(") {
				params = getParameters(string.substring(11, find(string, ")")), 1);
				if (params.length >= 1) {
					Main.objectmanager.gravityOn(params);
				}
			}else if (string.length >= 12 && string.substring(0, 12) == "loopobjects(") {
				params = getParameters(string.substring(12, find(string, ")")), 1);
				if (params.length >= 1) {
					Main.objectmanager.loopOn(params);
				}
			}else if (string.length >= 5 && string.substring(0, 5) == "jump(") {
				params = getParameters(string.substring(5, find(string, ")")), 2);
				if (params.length >= 2) {
					Main.objectmanager.jump(params[0], params[1]);
				}
			}else if (string.length >= 13 && string.substring(0, 13) == "darkenscreen(") {
				params = getParameters(string.substring(13, find(string, ")")), 1);
				if (params.length >= 1) {
					Main.map.griddisplay.alpha = params[0];
				}
			}else if (string.length >= 10 && string.substring(0, 10) == "playmusic(") {
				params = getParameters(string.substring(10, find(string, ")")), 1);
				if (params.length >= 1) {
					Main.sound.play(params[0]);
				}
			}else if (string.length >= 10 && string.substring(0, 10) == "playsound(") {
				params = getParameters(string.substring(10, find(string, ")")), 1);
				if (params.length >= 1) {
					Main.sound.playsfx(params[0]);
				}
			}else if (string.length >= 10 && string.substring(0, 10) == "stopmusic(") {
				params = getParameters(string.substring(10, find(string, ")")), 1);
				if (params.length >= 1) {
					Main.sound.stop(params[0]);
				}
			}else if (string.length >= 13 && string.substring(0, 13) == "updatescreen(") {
				params = getParameters(string.substring(13, find(string, ")")), 2);
				if (params.length >= 2) {
					params[1]  = params[1].replace(/"/gi, "");
					params[1] = params[1].replace("${com}", ",");
					params[1] = params[1].replace("${app}", "'");
					if (params.length >= 3) {
						Main.env.screenmanager.updateScreen(params[0], params[1], int(params[2]));
					}else {
						Main.env.screenmanager.updateScreen(params[0], params[1]);
					}
				}
			}else if (string.length >= 10 && string.substring(0, 10) == "resetlevel") {
				Main.map.redrawLevel();
			}else if (string.length >= 9 && string.substring(0, 9) == "teleport(") {
				params = getParameters(string.substring(9, find(string, ")")), 4);
				if (params.length >= 4) {
					var node:TeleporterNode = new TeleporterNode();
					node.startpoint.x = params[0]; node.startpoint.y = params[1];
					node.endpoint.x = params[2]; node.endpoint.y = params[3];
					Main.map.teleporternodes.push(node);
				}
			}else if (string.length >= 11 && string.substring(0, 11) == "createtext(") {
				params = getParameters(string.substring(11, find(string, ")")), 5);
				if (params.length >= 5) {
					Main.text.createtext(params[0], params[1], params[2], params[3], params[4], 
					Boolean(Number(params[5])), params[6]);
				}
			}else if (string.length >= 10 && string.substring(0, 10) == "runscript(") {
				params = getParameters(string.substring(10, find(string, ")")), 1);
				if (params.length >= 1) {
					var pg:int = int(params[0]) - 1;
					if (pg < data.length) {
						data[pg].line = 0;
						interperate(pg);
					}
				}
			}
			
			//if functions
			if (string.length >= 3 && string.substring(0, 3) == "if ") {
				params = getParameters(string.substring(4, find(string, ")")), 3, " ");
				if (params.length >= 3) {
					var correct:int = 0;
					var requireall:Boolean = false;
					var required:int = 0;
					for (var n:int = 0; n < params.length; n += 3) {
						var num1:String = setValue(params[n]);
						var num2:String = setValue(params[n + 2]);
						
						switch (params[n+ 1]) {
							case "equals":
								if (num1 == num2) { ++correct; }
								break;
							case "doesnotequal":
								if (num1 != num2) { ++correct; }
								break;
							case "isgreaterthan":
								if (int(num1) > int(num2)) { ++correct; }
								break;
							case "islessthan":
								if (int(num1) < int(num2)) { ++correct; }
								break;
							case "isgreaterthan=":
								if (int(num1) >= int(num2)) { ++correct; }
								break;
							case "islessthan=":
								if (int(num1) <= int(num2)) { ++correct; }
								break;
						}
						++required;
						
						if (params.length >= 3 && params[n + 3] == "and") {
							++n;
							requireall = true;
						}else if (params.length >= 3 && params[n + 3] == "or") {
							++n;
							requireall = false;
						}
					}
					if (correct >= required && requireall || correct >= 1 && !requireall) {
						interperate(page, "", true); return;
					}else {
						gotoLine("elseif", page);
						gotoLine("endif", page);
					}
					return;
				}
			}else if (string.length >= 5 && string.substring(0, 5) == "else ") {
				interperate(page, "", true);
				return;
			}else if (string.length >= 5 && string.substring(0, 5) == "endif") {
				interperate(page, "", true);
				return;
			}else if (string.length >= 4 && string.substring(0, 4) == "exit") {
				data[page].line = 999;
				Main.time.timers.length = 0;
				return;
			}else if (string.length >= 9 && string.substring(0, 9) == "startboss") {
				Main.boss.create();
			}else if (string.length >= 10 && string.substring(0, 10) == "removeboss") {
				Main.boss.remove();
			}
			
			//loop functions
			if (string.length >= 5 && string.substring(0, 5) == "loop(") {
				params = getParameters(string.substring(5, find(string, ")")), 1);
				if (params.length >= 1) {
					data[page].loopAt = line;
					Main.time.runFunctionIn(int(params[0]), function():void {
						interperate(page, "", true);
					}, true);
					return;
				}
			}else if (string.length >= 7 && string.substring(0, 7) == "endloop") {
				data[page].line = data[page].loopAt + 1;
				return;
			}
			
			if (runNextLine) { interperate(page, "", true); }
		}
		
		//returns all parameters in a function
		private function getParameters(from:String, requiredarguments:int = -1, seperator:String = ","):Array {
			var params:Array = from.split(seperator);
			
			if (params.length < requiredarguments && requiredarguments != -1) {
				return [];
			}
			
			return params;
		}
		
		//finds a character in a string ignoring special characters in quotation marks
		private function find(findin:String, tofind:String):int {
			for (var n:int = 0; n < findin.length; ++n) {
				var char:String = findin.charAt(n);
				if (char != "\"" && char == tofind) {
					return n;
				}
			}
			return 0;
		}
		
		private function gotoLine(line:String, page:int, add:int = 0):Boolean {
			for (var n:int = data[page].line; n < data[page].data.length; ++n) {
				var newline:String = data[page].data[n];
				if (newline.indexOf(line) != -1) {
					data[page].line = n + add;
					interperate(page, "", true);
					return true;
				}
			}
			return false;
		}
		
		private function setValue(value:String):String {
			switch (value) {
				case "x":
					return Main.player.x.toString();
				case "y":
					return Main.player.y.toString();
				case "coordx":
					return (Main.player.x / 20).toString();
				case "coordy":
					return (Main.player.y / 20).toString();
			}
			return value;
		}
	}
}