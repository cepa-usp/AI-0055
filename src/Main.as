package 
{
	import BaseAssets.BaseMain;
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.SimpleGraph;
	import cepa.utils.Cronometer;
	import cepa.utils.MouseMotionData;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		//Velocidades
		private var VELOCIDADE_MONTANHONA:Number;
		private var VELOCIDADE_NUVENS:Number;
		private var VELOCIDADE_ARVORES:Number;
		private var VELOCIDADE_CARRO:Number;
		private var VELOCIDADE_CLOSE_CENARIO:Number;
		
		//Cenarios
		private var carousel:Vector.<Carousel>;
		
		//Variáveis do velocímetro
		private var startAngle:Number;
		private var startOrientation:Number;
		private var posPonteiro:Point;
		private var angulos:Array;
		public var velocidade:Number;
		private var velocidades:Array;
		private var graphTime:Number = 0.1;
		
		//Variáveis do gráfico
		private var graph:SimpleGraph;
		private var pontosGrafico:Array;
		private var timerGrafico:Timer;
		private var tempoDuracao:Number;
		
		private var animacaoIniciada:Boolean;
		private var reverse:Boolean;
		private var vMedia:Number;
		private var distancia:Number;
		private var placas:Vector.<DisplayObject>;
		private var distanciaPlaca:Number;
		
		private var novaVelocidade:Number;
		
		private var mouseMotion:MouseMotionData = MouseMotionData.instance;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			initVariables();
			
			initCarousel();
			adicionaCarro();
			initVelocimetro();
			initGrafico();
			addListeners();
			
			//initAnimation();
			
			setIndex();
			
			vLabel.background = true;
			vLabel.backgroundColor = 0xFFFFFF;
			tLabel.background = true;
			tLabel.backgroundColor = 0xFFFFFF;
		}
		
		private function setIndex():void
		{
			setChildIndex(painel, numChildren - 1);
			setChildIndex(reButton, numChildren - 1);
			setChildIndex(vLabel, numChildren - 1);
			setChildIndex(tLabel, numChildren - 1);
			setChildIndex(botoes, numChildren - 1);
		}
		
		private function initVariables():void
		{
			VELOCIDADE_MONTANHONA = 0;
			VELOCIDADE_NUVENS = 0;
			VELOCIDADE_ARVORES = 0;
			VELOCIDADE_CLOSE_CENARIO = 0;
			
			VELOCIDADE_CARRO = 0; //Velocidade da estrada.
			
			velocidade = 0;
			vMedia = 0;
			distancia = 0;
			distanciaPlaca = 0;
			
			novaVelocidade = 0;
			
			animacaoIniciada = false;
			
			reverse = false;
			
			reButton.gotoAndStop("FRENTE");
			
		}
		
		private function initCarousel():void
		{
			if (carousel == null)
			{
				carousel = new Vector.<Carousel>();
			
				var posY:Number = 450;
				
				//var viewport:Rectangle = new Rectangle(-150, 0, 550, 550);
				var viewport:Rectangle = new Rectangle(0, 0, 700, 550);
				
				var stripes:Vector.<DisplayObject> = new Vector.<DisplayObject>();
				stripes.push(new CloseScenario1());
				stripes.push(new CloseScenario1());
				stripes.push(new CloseScenario1());
				stripes.push(new CloseScenario1());
				
				// Cenário X: acostamento
				carousel[0] = new Carousel(stripes, viewport);
				//carousel[0].x = 100;
				carousel[0].y = posY;
				
				//------- Cenário 1: montanha
				
				stripes = new Vector.<DisplayObject>();
				stripes.push(new Montanhona());
				stripes.push(new Montanhona());
				stripes.push(new Montanhona());
				stripes.push(new Montanhona());
				
				carousel[1] = new Carousel(stripes, viewport);
				//carousel[1].x = 100;
				carousel[1].y = posY;
				
				//------- Cenário X: árvores
				
				stripes = new Vector.<DisplayObject>();
				stripes.push(new Arvores());
				stripes.push(new Arvores());
				stripes.push(new Arvores());
				stripes.push(new Arvores());
				
				carousel[2] = new Carousel(stripes, viewport);
				//carousel[2].x = 100;
				carousel[2].y = posY;
				
				//------- Cenário X: rodovia
				
				stripes = new Vector.<DisplayObject>();
				stripes.push(new Rodovia());
				stripes.push(new Rodovia());
				stripes.push(new Rodovia());
				stripes.push(new Rodovia());
				
				carousel[3] = new Carousel(stripes, viewport);
				carousel[3].y = posY;
				
				//------- Cenário X: nuvens
				
				//stripes = new Vector.<DisplayObject>();
				//stripes.push(new Nuvens());
				//stripes.push(new Nuvens());
				//stripes.push(new Nuvens());
				//stripes.push(new Nuvens());
				//
				//carousel[4] = new Carousel(stripes, viewport);
				//carousel[4].y = 180;
				
				//------- Cenário X: placas
				
				placas = new Vector.<DisplayObject>();
				placas.push(new Placa());
				placas.push(new Placa());
				//placas.push(new Placa());
				//placas.push(new Placa());
				//placas.push(new Placa());
				//stripes.push(new Placa());
				//stripes.push(new Placa());
				//stripes.push(new Placa());
				
				carousel[4] = new Carousel(placas, viewport, ((100 * 150) / 11.1), true);
				carousel[4].y = posY;
				
				//var placaTeste:Placa = Placa(placas[1]);
				//placaTeste.distancia.text = "0 m";
				
				addEventListener("ATUALIZA_PLACA", atualizaPlacas);
				
				//addChild(carousel[4]);
				addChild(carousel[1]);
				addChild(carousel[2]);
				addChild(carousel[0]);
				addChild(carousel[3]);
				addChild(carousel[4]);
				//addChild(carousel[5]);
				
				graphics.lineStyle(1);
				graphics.drawRect(carousel[0].x + viewport.left, carousel[0].y + viewport.top, viewport.width, viewport.height);
			}
			else
			{
				carousel[0].reset();
				carousel[1].reset();
				carousel[2].reset();
				carousel[3].reset();
				carousel[4].reset();
				//carousel[5].reset();
				
				//placaTeste = Placa(placas[1]);
				//placaTeste.distancia.text = "0 m";
			}
			atualizaPlacas(null);
		}
		
		private function atualizaPlacas(e:Event):void 
		{
			//trace(distancia);
			if (reverse) 
			{
				//distanciaPlaca -= 100;
				distanciaPlaca = (Math.floor( -distancia / 100)) * 100;
				var placaTeste:Placa = Placa(placas[placas.length - 1]);
				placaTeste.distancia.text = String(distanciaPlaca) + " m";
			}
			else
			{
				distanciaPlaca  = (Math.ceil( -distancia / 100)) * 100;
				placaTeste = Placa(placas[1]);
				placaTeste.distancia.text = String(distanciaPlaca) + " m";
			}
			
		}
		
		private function adicionaCarro():void
		{
			if (carro == null)
			{
				carro = new CarroComRodas();
				carro.x = 150;
				carro.y = 480;
				addChild(carro);
			}
		}
		
		private function initVelocimetro():void
		{
			posPonteiro = painel.velocimetro.localToGlobal(new Point(painel.velocimetro.ponteiro.x, painel.velocimetro.ponteiro.y));
			
			angulos = [ -135, -95, -50, 0, 50, 95];
			velocidades = [0, 40, 60, 80, 100, 120];
			
			//velocidade = 0;
			painel.velocimetro.ponteiro.rotation = angulos[0];
			
			painel.velocimetro.quilometragem.text = "0 m";
			
			painel.velocimetro.ponteiro.addEventListener(MouseEvent.MOUSE_DOWN, initRotation);
		}
		
		private var delta:Number = 20;
		private var min:Number = 0;
		private var max:Number = 121;
		
		private function initGrafico():void
		{
			var xMin:Number = 0;
			var xMax:Number = 20;
			var largura:Number = 660;
			var yMin:Number = -130;
			var yMax:Number = 130;
			var altura:Number = 300;
			
			if (graph != null) 
			{
				removeChild(graph);
				graph == null;
			}
			
			graph = new SimpleGraph(xMin, xMax, largura, yMin, yMax, altura);
			graph.setTicksDistance(SimpleGraph.AXIS_X, 1);
			graph.setSubticksDistance(SimpleGraph.AXIS_X, 1);
			graph.setTicksDistance(SimpleGraph.AXIS_Y, 40);
			graph.setSubticksDistance(SimpleGraph.AXIS_Y, 20);
			
			graph.addEventListener(MouseEvent.MOUSE_DOWN, initPan);
			
			graph.mouseChildren = false;
			graph.buttonMode = true;
			
			graph.x = 30;
			graph.y = 10;
			
			addChild(graph);
			
			pontosGrafico = [[0,0]];
			
			graph.addData(pontosGrafico, new DataStyle());
			
			vMedia = 0;
			var funcao = new GraphFunction(0, 200, function (x:Number) { return vMedia; } );
			var styleMedia:DataStyle = new DataStyle();
			styleMedia.color = 0x0000FF;
			graph.addFunction(funcao, styleMedia);
			graph.draw();
			
			timerGrafico = new Timer(graphTime * 1000);
			timerGrafico.addEventListener(TimerEvent.TIMER, atualizaGrafico);
			tempoDuracao = 0;
			
			//atualizaGrafico();
			
		}
		
		private var graphDown:Number;
		private var panningGraph:Boolean = false;
		private function initPan(e:MouseEvent):void 
		{
			if (tweenXGraph != null) {
				if (tweenXGraph.isPlaying) {
					tweenXGraph.stop();
					if (graph.xmin < min) {
						graph.xmin = min;
						graph.xmax = min + delta;
						graph.draw();
					}else if (graph.xmax > max) {
						graph.xmax = max;
						graph.xmin = max - delta;
						graph.draw();
					}
				}
			}
			
			graphDown = graph.pixel2x(graph.mouseX);
			panningGraph = true;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, panning);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopPan);
		}
		
		private function panning(e:MouseEvent):void 
		{
			var pan:Number = graph.pixel2x(graph.mouseX) - graphDown;
			
			graph.xmin = Math.min(Math.max(min, graph.xmin - pan), max - delta);
			graph.xmax = graph.xmin + delta;
			graph.draw();
			
			graphDown = graph.pixel2x(graph.mouseX);
		}
		
		private function stopPan(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, panning);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopPan);
			
			panningGraph = false;
			
			if (Math.abs(mouseMotion.speed.x) > 0) {
				vel = mouseMotion.speed.x / 100;
				cron.stop();
				cron.reset();
				cron.start();
				if (vel > 0) velPos = true;
				else velPos = false;
				stage.addEventListener(Event.ENTER_FRAME, continuePanning);
			}
		}
		
		private var cron:Cronometer = new Cronometer();
		private var vel:Number = 0;
		private var velPos:Boolean;
		public var posXmin:Number;
		private var tweenXGraph:Tween;
		
		private function continuePanning(e:Event):void 
		{
			var dt:Number = cron.read() / 1000;
			vel += getV(vel) * dt;
			
			if (velPos) {
				graph.xmin -= vel/10;
				graph.xmax -= vel/10;
			}else {
				graph.xmax -= vel/10;
				graph.xmin -= vel/10;
			}
			graph.draw();
			
			if (graph.xmin < min || graph.xmax > max) {
				vel = vel / 2;
			}
			
			if ((velPos && vel < 0) || (!velPos && vel > 0)) {
				stage.removeEventListener(Event.ENTER_FRAME, continuePanning);
				if (graph.xmin < min) {
					posXmin = graph.xmin;
					tweenXGraph = new Tween(this, "posXmin", None.easeOut, posXmin, min, 0.4, true);
					tweenXGraph.addEventListener(TweenEvent.MOTION_CHANGE, changeOnTweenMin, false, 0, true);
				}else if (graph.xmax > max) {
					posXmin = graph.xmax;
					tweenXGraph = new Tween(this, "posXmin", None.easeOut, posXmin, max, 0.4, true);
					tweenXGraph.addEventListener(TweenEvent.MOTION_CHANGE, changeOnTweenMax, false, 0, true);
				}
			}
		}
		
		private function changeOnTweenMin(e:TweenEvent):void 
		{
			graph.xmin = posXmin;
			graph.xmax = posXmin + delta;
			graph.draw();
		}
		
		private function changeOnTweenMax(e:TweenEvent):void 
		{
			graph.xmin = posXmin - delta;
			graph.xmax = posXmin;
			graph.draw();
		}
		
		private var A:Number = 0.5;
		
		private function getV(v:Number):Number 
		{
			return A * (v < 0 ? 1: -1);
		}
		
		private function atualizaGrafico(e:TimerEvent = null):void
		{
			if (animacaoIniciada)
			{
				//tempoDuracao++;
				tempoDuracao += graphTime;
				
				pontosGrafico.push([tempoDuracao, velocidade]);
				
				//if (tempoDuracao >= graph.xmax - 1 && !panningGraph) {
					//graph.xmax = tempoDuracao + 1;
					//graph.xmax = graph.xmax + graphTime * 2;
					//graph.xmin = graph.xmin + graphTime * 2;
				//}
				
				vMedia = calculaMedia();
				
				painel.velocimetro.quilometragem.text = String(Math.round(distancia) * -1) + " m";
				
				graph.draw();
				
				if (tempoDuracao >= 120) stopAnimation();
			}
		}
		
		private function initAnimation():void 
		{
			stage.addEventListener(Event.ENTER_FRAME, updateCenario);
			
			timerGrafico.start();
			
			animacaoIniciada = true;
		}
		
		private function addListeners():void 
		{
			reButton.addEventListener(MouseEvent.CLICK, engataTiraRe);
		}
		
		private function engataTiraRe(e:MouseEvent):void 
		{
			painel.velocimetro.ponteiro.rotation = angulos[0];
			//velocidade = 0;
			changeSpeed(0);
			painel.velocimetro.quilometragem.text = String(Math.round(distancia) * -1) + " m";
			
			if (reverse)
			{
				reverse = false;
				reButton.gotoAndStop("FRENTE");
			}
			else
			{
				reverse = true;
				reButton.gotoAndStop("RE");
			}
		}
		
		private function initRotation(e:MouseEvent):void 
		{
			//if (animacaoPausada == false)
			//{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, changingSpeed);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopChanging);
				
				startAngle = (Math.atan2(stage.mouseY - posPonteiro.y, stage.mouseX - posPonteiro.x)) * 180 / Math.PI;
				startOrientation = painel.velocimetro.ponteiro.rotation;
			//}
		}
		
		private function changingSpeed(e:MouseEvent):void 
		{
			var rotacao:Number = wrapRotation(Math.round(Math.atan2(stage.mouseY - posPonteiro.y , stage.mouseX - posPonteiro.x) * 180 / Math.PI - startAngle + startOrientation));
			
			for (var i:int = 0; i < angulos.length; i++) 
			{
				if (Math.abs(rotacao - angulos[i]) < 20 && velocidade != velocidades[i])
				{
					if (animacaoIniciada == false) {
						//animacaoIniciada = true;
						initAnimation();
					}
					
					painel.velocimetro.ponteiro.rotation = angulos[i];
					
					if (reverse) 
					{
						//velocidade = velocidades[i] * -1;
						changeSpeed(velocidades[i] * -1);
					}
					else
					{
						//velocidade = velocidades[i];
						changeSpeed(velocidades[i]);
					}
					//changeSpeed();
					break;
				}
			}
		}
		
		private var changeTween:Tween;
		private var carro:Sprite;
		
		private var v0:Number;
		private var velTo:Number;
		private var calculatingVel:Boolean = false;
		private var cronVel:Cronometer = new Cronometer();
		private var acel:Number = 5;
		
		private function changeSpeed(to:Number):void
		{
			//trace(velocidade);
			v0 = velocidade;
			velTo = to;
			if (cronVel.isRunning) cronVel.reset();
			else cronVel.start();
			
			if (!calculatingVel) {
				calculatingVel = true;
				stage.addEventListener(Event.ENTER_FRAME, calculaVel);
			}
			
			
			return;
			
			var changeSpeedTime:Number = Math.abs((to - velocidade) / acel);
			if (changeTween != null) {
				if(changeTween.isPlaying) changeTween.continueTo(to, changeSpeedTime);
				else {
					changeTween = new Tween(this, "velocidade", None.easeNone, velocidade, to, changeSpeedTime, true);
				}
			}else{
				/*
				if (changeTween.isPlaying) {
					changeTween.continueTo(to, changeSpeedTime);
				}else {
					changeTween = new Tween(this, "velocidade", None.easeNone, velocidade, to, changeSpeedTime, true);
				}
			}else{
				changeTween = new Tween(this, "velocidade", None.easeNone, velocidade, to, changeSpeedTime, true);
			}*/
			
			changeTween = new Tween(this, "velocidade", None.easeNone, velocidade, to, changeSpeedTime, true);
			}
		}
		
		private function calculaVel(e:Event):void
		{
			trace(cronVel.read());
			//trace(v0, acel, cronVel.read() / 1000);
			velocidade = v0 + acel / (cronVel.read() / 1000);
			//trace("vel: " + velocidade);
			
			if (velocidade >= velTo) {
				stage.removeEventListener(Event.ENTER_FRAME, calculaVel);
				calculatingVel = false;
			}
		}
		
		private function wrapRotation (rotation:Number) : Number
		{
			return rotation - Math.floor((rotation + 180) / 360) * 360;
		}
		
		private function stopChanging(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, changingSpeed);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopChanging);
			
			//velocidade = velocidades[angulos.indexOf(Math.round(painel.velocimetro.ponteiro.rotation))];
			//changeSpeed();
		}
		
		private function stopAnimation():void
		{
			stage.removeEventListener(Event.ENTER_FRAME, updateCenario);
			
			timerGrafico.stop();
			
			painel.velocimetro.ponteiro.rotation = angulos[0];
			
			painel.velocimetro.ponteiro.removeEventListener(MouseEvent.MOUSE_DOWN, initRotation);
		}
		
		private function calculaMedia():Number
		{
			var numCelulas:Number = pontosGrafico.length;
			var somaTotal:Number = 0;
			
			for (var i:int = 0; i < numCelulas; i++) 
			{
				somaTotal += pontosGrafico[i][1];
			}
			return (somaTotal / numCelulas);
		}
		
		override public function reset(e:MouseEvent = null):void
		{
			painel.velocimetro.ponteiro.removeEventListener(MouseEvent.MOUSE_DOWN, initRotation);
			
			stage.removeEventListener(Event.ENTER_FRAME, updateCenario);
			
			timerGrafico.reset();
			if (changeTween != null) {
				if (changeTween.isPlaying) changeTween.stop();
			}
			init();
		}
		
		private function updateCenario(e:Event) : void
		{
			VELOCIDADE_CARRO = -velocidade;
			
			//distancia += VELOCIDADE_CARRO / (8 * );
			distancia += (11.1 / 150) * VELOCIDADE_CARRO / 8;
			
			VELOCIDADE_MONTANHONA = VELOCIDADE_CARRO / 5;
			VELOCIDADE_NUVENS = VELOCIDADE_CARRO / 4;
			VELOCIDADE_ARVORES = VELOCIDADE_CARRO / 2;
			VELOCIDADE_CLOSE_CENARIO = VELOCIDADE_CARRO / 1.5;
			
			carousel[0].displace(VELOCIDADE_CLOSE_CENARIO / 5);
			carousel[1].displace(VELOCIDADE_MONTANHONA / 5);
			carousel[2].displace(VELOCIDADE_ARVORES / 5);
			carousel[3].displace(VELOCIDADE_CARRO / 8);
			carousel[4].displace(VELOCIDADE_CARRO / 8);
			//carousel[4].displace(VELOCIDADE_NUVENS / 5);
			//carousel[5].displace(VELOCIDADE_CARRO / 8);

			
		}
		
		override public function iniciaTutorial(e:MouseEvent = null):void
		{
			
		}
	}

}