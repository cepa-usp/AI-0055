package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class Carousel extends Sprite {
		
		//--------------------------------------------------------------
		// Membros públicos (interface)
		//--------------------------------------------------------------
		
		private var disparaEventos:Boolean;
		
		/**
		 * Cria um carrossel horizontal de imagens.
		 * @param	pieces Vetor contendo as imagens (<code>DisplayObject</code>) do carrossel.
		 * @param	viewport A área visível do carrossel.
		 * @param	distance A distância entre duas imagens consecutivas do carrossel. Se este parâmetro não for dado, as imagens serão posicionadas
		 * uma após a outra, sem espaço entre elas.
		 */
		public function Carousel (pieces:Vector.<DisplayObject>, viewport:Rectangle, distance:Number = -1, event:Boolean = false)
		{
			init(pieces, viewport, distance, event);
			reset();
		}
		
		/**
		 * Aplica um deslocamento ao carrossel.
		 * @param	dx Deslocamento, em pixels. Valores positivos representam deslocamentos para a direita; valores negativos, para a esquerda.
		 */
		public function displace (dx:Number) : void
		{
			//if (Math.abs(dx) >= 1)
			//{
				var dO:DisplayObject;
				var i:int;
				
				// Desloca todo o carrossel
				for each (dO in pieces)
				{
					dO.x += dx;
				}
				
				if (dx < 0)
				{
					for (i = 0; i < pieces.length; i++)
					{
						if (pieces[i].x < -pieces[i].width)
						{
							var d:Number = offsets.splice(0, 1)[0];
							offsets.push(d);
							
							dO = pieces.splice(0, 1)[0];
							var last:int = pieces.length - 1;
							dO.x = pieces[last].x + offsets[last];
							pieces.push(dO);
							
							if (disparaEventos) dispatchEvent(new Event("ATUALIZA_PLACA", true));
						}
						else break;
					}
				}
				else if(dx > 0)
				{
					for (i = pieces.length - 1; i >= 0; i--)
					{
						if (pieces[i].x - pieces[i].width/2 > viewport.width)
						{
							d = offsets.pop();
							offsets.splice(0, 0, d);
							
							dO = pieces.pop();
							dO.x = pieces[0].x - d;//dO.width;
							pieces.splice(0, 0, dO);
							
							if (disparaEventos) dispatchEvent(new Event("ATUALIZA_PLACA", true));
						}
						else break;
					}
				}
			//}
			//else
			//{
				//trace("AVISO: o menor deslocamento possível, em módulo, é 1 pixel.");
			//}
		}
		
		/**
		 * Reinicia o carrossel.
		 */
		public function reset () : void
		{
			pieces[0].x = viewport.left - (carrousselWidth - viewport.width) / 2;
			
			for (var i:int = 1; i < pieces.length; i++)
			{
				pieces[i].x = pieces[i - 1].x + offsets[i - 1];
			}
		}
		
		//--------------------------------------------------------------
		// Membros privados
		//--------------------------------------------------------------
		
		private var offsets:Vector.<Number>;
		private var pieces:Vector.<DisplayObject>;;
		private var viewport:Rectangle;
		private var carrousselWidth:Number;
		
		private function init (pieces:Vector.<DisplayObject>, viewport:Rectangle, distance:Number = -1, eventos:Boolean = false) : void
		{
			
			//scrollRect = viewport;
			
			this.pieces = pieces;
			// TODO: Avaliar se a viewport e as figuras podem ser usadas
			this.viewport = viewport;
			
			disparaEventos = eventos;
			
			carrousselWidth = 0;
			var i:int;
			
			offsets = new Vector.<Number>();			
			if (distance > 0)
			{
				for (i = 0; i < pieces.length; i++)
				{
					offsets[i] = distance;
					carrousselWidth += offsets[i];
					addChild(pieces[i]);
				}
			}
			else
			{
				for (i = 0; i < pieces.length; i++)
				{
					offsets[i] = pieces[i].width;
					carrousselWidth += offsets[i];
					addChild(pieces[i]);
				}
			}
			
			trace(carrousselWidth);
		}
	}
}