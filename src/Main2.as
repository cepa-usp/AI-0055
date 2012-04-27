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
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main2 extends BaseMain
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
		//private var timerGrafico:Timer;
		//private var tempoDuracao:Number;
		private var tempoDuracao:Cronometer = new Cronometer();
		private var tempoDistancia:Cronometer = new Cronometer();
		
		private var animacaoIniciada:Boolean;
		private var reverse:Boolean;
		private var vMedia:Number;
		private var distancia:Number;
		private var placas:Vector.<DisplayObject>;
		private var distanciaPlaca:Number;
		
		private var labelFunc:TextField;
		
		private var novaVelocidade:Number;
		
		private var mouseMotion:MouseMotionData = MouseMotionData.instance;
		
		public function Main2() 
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
			
			labelFunc.y = graph.y2pixel(0) + graph.y - labelFunc.height - 2;
			
			//initAnimation();
			
			setIndex();
			
			vLabel.background = true;
			vLabel.backgroundColor = 0xFFFFFF;
			tLabel.background = true;
			tLabel.backgroundColor = 0xFFFFFF;
			
			iniciaTutorial();
		}
		
		private function setIndex():void
		{
			setChildIndex(painel, numChildren - 1);
			setChildIndex(reButton, numChildren - 1);
			setChildIndex(vLabel, numChildren - 1);
			setChildIndex(labelFunc, numChildren - 1);
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
			v0 = 0;
			velTo = 0;
			vMedia = 0;
			distancia = 0;
			distanciaPlaca = 0;
			velInVelocimeter = 0;
			
			novaVelocidade = 0;
			
			animacaoIniciada = false;
			calculatingVel = false;
			
			reverse = false;
			
			tempoDuracao.stop();
			tempoDuracao.reset();
			
			tempoDistancia.stop();
			tempoDistancia.reset();
			
			reButton.gotoAndStop("FRENTE");
			reButton.buttonMode = true;
			painel.velocimetro.ponteiro.buttonMode = true;
			
			if (ghost != null) {
				ghost.visible = false;
			}
			
			if (labelFunc == null) {
				labelFunc = new TextField();
				labelFunc.defaultTextFormat = new TextFormat("arial", 12, 0x000000);
				addChild(labelFunc);
				labelFunc.x = 630;
				labelFunc.text = "v. média";
				labelFunc.height = labelFunc.textHeight + 2;
				labelFunc.width = labelFunc.textWidth + 4;
				labelFunc.background = true;
				labelFunc.backgroundColor = 0xFFFFFF;
			}
			
			if(graph != null) labelFunc.y = graph.y2pixel(0) + graph.y - labelFunc.height - 2;
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
				placas.push(new Placa());
				placas.push(new Placa());
				//placas.push(new Placa());
				//stripes.push(new Placa());
				//stripes.push(new Placa());
				//stripes.push(new Placa());
				
				carousel[4] = new Carousel(placas, viewport, 1000, true);
				//carousel[4] = new Carousel(placas, viewport, ((100 * 150) / 11.1), true);
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
			
			carousel[4].displace(-75); //Deslocamento para chegar a placa beeem na frente do carro.
			atualizaPlacas(null);
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
			
			angulos = [ -141, -102, -63, -23, 16, 55, 94];
			velocidades = [0, 20, 40, 60, 80, 100, 120];
			
			painel.velocimetro.ponteiro.rotation = angulos[0];
			
			painel.velocimetro.quilometragem.text = "0 m";
			
			painel.velocimetro./*ponteiro.*/addEventListener(MouseEvent.MOUSE_DOWN, initRotation);
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
			
			//timerGrafico = new Timer(graphTime * 1000);
			//timerGrafico.addEventListener(TimerEvent.TIMER, atualizaGrafico);
			//tempoDuracao = 0;
			
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
		
		private function initAnimation():void 
		{
			stage.addEventListener(Event.ENTER_FRAME, updateCenario);
			
			//timerGrafico.start();
			tempoDuracao.start();
			tempoDistancia.start();
			
			
			animacaoIniciada = true;
		}
		
		private function addListeners():void 
		{
			reButton.addEventListener(MouseEvent.CLICK, engataTiraRe);
		}
		
		private function engataTiraRe(e:MouseEvent):void 
		{
			if(velocidade != 0){
				painel.velocimetro.ponteiro.rotation = angulos[0];
				//velocidade = 0;
				velInVelocimeter = 0;
				if (ghost == null) {
					ghost = new Ponteiro();
					painel.velocimetro.addChild(ghost);
					ghost.alpha = 0.5;
					ghost.scaleY = 0.43;
					painel.velocimetro.setChildIndex(ghost, painel.velocimetro.getChildIndex(painel.velocimetro.ponteiro) - 1);
				}
				ghost.rotation = angulos[0];
				ghost.visible = true;
				changeSpeed(0);
				painel.velocimetro.quilometragem.text = String(Math.round(distancia) * -1) + " m";
			}
			
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
		
		private var ghost:MovieClip;
		private function initRotation(e:MouseEvent):void 
		{
			if(e.target == painel.velocimetro.ponteiro){
				if (ghost == null) {
					ghost = new Ponteiro();
					painel.velocimetro.addChild(ghost);
					ghost.alpha = 0.5;
					ghost.scaleY = 0.43;
					painel.velocimetro.setChildIndex(ghost, painel.velocimetro.getChildIndex(painel.velocimetro.ponteiro) - 1);
				}
				
				ghost.rotation = painel.velocimetro.ponteiro.rotation;
				ghost.visible = true;
				
				//if (animacaoPausada == false)
				//{
					stage.addEventListener(MouseEvent.MOUSE_MOVE, changingSpeed);
					stage.addEventListener(MouseEvent.MOUSE_UP, stopChanging);
					
					startAngle = (Math.atan2(stage.mouseY - posPonteiro.y, stage.mouseX - posPonteiro.x)) * 180 / Math.PI;
					startOrientation = painel.velocimetro.ponteiro.rotation;
				//}
			}else {
				var rotacao:Number = wrapRotation(Math.round(Math.atan2(stage.mouseY - posPonteiro.y , stage.mouseX - posPonteiro.x) * 180 / Math.PI) + 90);
				
				for (var i:int = 0; i < angulos.length; i++) 
				{
					if (Math.abs(rotacao - angulos[i]) < 20 && velInVelocimeter != velocidades[i])
					{
						velInVelocimeter = velocidades[i];
						
						if (animacaoIniciada == false) initAnimation();
						
						if (ghost == null) {
							ghost = new Ponteiro();
							painel.velocimetro.addChild(ghost);
							ghost.alpha = 0.5;
							ghost.scaleY = 0.43;
							painel.velocimetro.setChildIndex(ghost, painel.velocimetro.getChildIndex(painel.velocimetro.ponteiro) - 1);
						}
						ghost.visible = true;
						ghost.rotation = angulos[i];
						
						if (reverse) changeSpeed(velocidades[i] * -1);
						else changeSpeed(velocidades[i]);
						
						break;
					}
				}
			}
		}
		
		private var velInVelocimeter:Number = 0;
		private function changingSpeed(e:MouseEvent):void 
		{
			var rotacao:Number = wrapRotation(Math.round(Math.atan2(stage.mouseY - posPonteiro.y , stage.mouseX - posPonteiro.x) * 180 / Math.PI - startAngle + startOrientation));
			
			for (var i:int = 0; i < angulos.length; i++) 
			{
				if (Math.abs(rotacao - angulos[i]) < 20 && velInVelocimeter != velocidades[i])
				{
					velInVelocimeter = velocidades[i];
					if (animacaoIniciada == false) {
						//animacaoIniciada = true;
						initAnimation();
					}
					
					//painel.velocimetro.ponteiro.rotation = angulos[i];
					ghost.rotation = angulos[i];
					
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
		
		//private var changeTween:Tween;
		private var carro:Sprite;
		
		private var v0:Number;
		private var velTo:Number;
		private var calculatingVel:Boolean = false;
		private var cronVel:Cronometer = new Cronometer();
		private var acel:Number = 5;// m/s*s
		
		private function changeSpeed(to:Number):void
		{
			cronVel.reset();
			cronVel.start();
			
			v0 = velocidade;
			velTo = to;
			
			if (velocidade >= 0) {
				if (to > velocidade) acel = Math.abs(acel);
				else acel = -Math.abs(acel);
			}else {
				if (to < velocidade) acel = -Math.abs(acel);
				else acel = Math.abs(acel);
			}
			
			if (!calculatingVel) {
				calculatingVel = true;
				stage.addEventListener(Event.ENTER_FRAME, calculaVel);
			}
			
		}
		
		private function calculaVel(e:Event):void
		{
			var time:Number = cronVel.read() / 1000;
			velocidade = v0 + ( acel * time * 3.6); // * 3.6: m/s -> km/h
			
			if(acel > 0){
				if (velocidade >= velTo) {
					stage.removeEventListener(Event.ENTER_FRAME, calculaVel);
					calculatingVel = false;
					velocidade = velTo;
					ghost.visible = false;
				}
			}else {
				if (velocidade <= velTo) {
					stage.removeEventListener(Event.ENTER_FRAME, calculaVel);
					calculatingVel = false;
					velocidade = velTo;
					ghost.visible = false;
				}
			}
			
			var angle:Number = -141 + Math.abs(velocidade) * ((94 + 141)/120);
			painel.velocimetro.ponteiro.rotation = angle;
		}
		
		private function wrapRotation (rotation:Number) : Number
		{
			return rotation - Math.floor((rotation + 180) / 360) * 360;
		}
		
		private function stopChanging(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, changingSpeed);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopChanging);
			
			//ghost.visible = false;
		}
		
		private function stopAnimation():void
		{
			stage.removeEventListener(Event.ENTER_FRAME, updateCenario);
			
			tempoDuracao.stop();
			tempoDuracao.reset();
			
			tempoDistancia.stop();
			tempoDistancia.reset();
			
			painel.velocimetro.ponteiro.rotation = angulos[0];
			painel.velocimetro./*ponteiro.*/removeEventListener(MouseEvent.MOUSE_DOWN, initRotation);
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
			painel.velocimetro./*ponteiro.*/removeEventListener(MouseEvent.MOUSE_DOWN, initRotation);
			stage.removeEventListener(Event.ENTER_FRAME, updateCenario);
			stage.removeEventListener(Event.ENTER_FRAME, calculaVel);
			init();
		}
		
		private var pixToMeter:Number = 1000 / 100; //1000 pixels = 100m
		private function updateCenario(e:Event) : void
		{
			VELOCIDADE_CARRO = -velocidade;
			
			//distancia += VELOCIDADE_CARRO / (8 * );
			var dist:Number = (tempoDistancia.read() / 1000) * VELOCIDADE_CARRO / 3.6; //deslocamento em m
			distancia += dist;
			tempoDistancia.reset();
			//distancia += (11.1 / 150) * VELOCIDADE_CARRO / 8;
			
			VELOCIDADE_MONTANHONA = dist * pixToMeter / 5;
			VELOCIDADE_NUVENS = dist * pixToMeter / 4;
			VELOCIDADE_ARVORES = dist * pixToMeter / 2;
			VELOCIDADE_CLOSE_CENARIO = dist * pixToMeter / 1.5;
			
			carousel[0].displace(VELOCIDADE_CLOSE_CENARIO);
			carousel[1].displace(VELOCIDADE_MONTANHONA);
			carousel[2].displace(VELOCIDADE_ARVORES);
			carousel[3].displace(dist * pixToMeter);
			carousel[4].displace(dist * pixToMeter);
			
			//carousel[4].displace(VELOCIDADE_CARRO / 8);
			//carousel[4].displace(VELOCIDADE_NUVENS / 5);
			//carousel[5].displace(VELOCIDADE_CARRO / 8);
			
			atualizaGrafico();
		}
		
		private function atualizaGrafico():void
		{
			pontosGrafico.push([tempoDuracao.read() / 1000, velocidade]);
			
			vMedia = calculaMedia();
			labelFunc.y = graph.y2pixel(vMedia) + graph.y - labelFunc.height - 2;
			painel.velocimetro.quilometragem.text = String(Math.round(distancia) * -1) + " m";
			graph.draw();
			
			if (tempoDuracao.read() / 1000 >= 120) {
				stopAnimation();
				balao.setText("A animação pára após dois minutos. Pressione \"reiniciar\" para recomeçar.", CaixaTexto.RIGHT, CaixaTexto.LAST);
				balao.setPosition(655, 434);
			}
		}
		
		private function atualizaPlacas(e:Event):void 
		{
			if (!animacaoIniciada) {
				distanciaPlaca = 0;
			}else{
				if(velocidade < 0)
				{
					distanciaPlaca -= 100;
				}
				else
				{
					distanciaPlaca += 100;
				}
			}
			var placaTeste:Placa = Placa(placas[1]);
			placaTeste.distancia.text = String(distanciaPlaca) + " m";
		}
		
		
		//---------------- Tutorial -----------------------
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array = ["Clique sobre a velocidade desejada e o carro acelerará CONSTANTEMENTE até atingí-la.", 
										  "Uma vez iniciada a viagem, a velocidade INSTANTÂNEA do carro é indicada em vermelho no gráfico.",
										  "A velocidade MÉDIA, por sua vez, é indicada em azul.",
										  "Arraste o gráfico para a direita ou para esquerda para ver outras regiões dele.",
										  "Diferentemente do odômetro usual, este aqui indica a POSIÇÃO do carro com relação ao zero (placa inicial).",
										  "Escolha a marcha a ré para fazer o carro desenvolver velocidade negativa."];
		
		override public function iniciaTutorial(e:MouseEvent = null):void{
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(426, 429),
								new Point(20 , 158),
								new Point(235 , 158),
								new Point(220 , 140),
								new Point(482 , 441),
								new Point(597 , 345)];
								
				tutoBaloonPos = [[CaixaTexto.RIGHT, CaixaTexto.CENTER],
								[CaixaTexto.LEFT, CaixaTexto.CENTER],
								[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								["", ""],
								[CaixaTexto.BOTTON, CaixaTexto.LAST],
								[CaixaTexto.BOTTON, CaixaTexto.LAST]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
	}

}