package modules.battle.battlecomponent
{
	import flash.display.Sprite;

	public class SingleSupplyStar extends Sprite
	{
		
		private static const needFillCount:int = 100;
		public var supplyValue:int = 0;
		
		private var maskSp:Sprite;
		private var _statusShowSprite:Sprite;
		private var _curSupplyState:int = 0;
		private var _percent:Number = 1;
		
		
		private static const size:int = 20;
		
		public function SingleSupplyStar()
		{
			_statusShowSprite = new Sprite();
			this.addChild(_statusShowSprite);
			
			this.graphics.clear();
			this.graphics.beginFill(0xffffff,1);
			this.graphics.drawCircle(size,size,size);
			this.graphics.endFill();
			
			maskSp = new Sprite();
			maskSp.graphics.clear();
			maskSp.graphics.beginFill(1,1);
			maskSp.graphics.drawRect(0,0,size * 2,size * 2);
			maskSp.graphics.endFill();
			_statusShowSprite.mask = maskSp;
			this.addChild(maskSp);
			
			this.curSupplyState = 0;
		}
		
		public function get percent():Number
		{
			return _percent;
		}

		public function set percent(value:Number):void
		{
			_percent = value;
			
			maskSp.graphics.clear();
			maskSp.graphics.beginFill(0,0);
			maskSp.graphics.drawRect(0,size * 2 * (1 - _percent),size * 2,size * _percent * 2);
			maskSp.graphics.endFill();
		}

		public function handlerNewValueCome(type:int,value:int):void
		{
			curSupplyState = type;
			if(_curSupplyState == NextSupplyShow.starSupplyTypeNone)
			{
				supplyValue = needFillCount;
			}
			else
			{
				supplyValue += value;
			}
			if(this.supplyValue >= needFillCount)
			{
				supplyValue = needFillCount;
				this.percent = supplyValue / needFillCount;
			}
		}
		
		public function get curSupplyState():int
		{
			return _curSupplyState;
		}

		public function set curSupplyState(value:int):void
		{
			_curSupplyState = value;
			_statusShowSprite.graphics.clear();
			if(this._curSupplyState == 0)
			{
				_statusShowSprite.graphics.beginFill(0xffffff,1);
			}
			else
			{
				if(_curSupplyState == NextSupplyShow.starSupplyTypeNone)
					_statusShowSprite.graphics.beginFill(0x000000,0.6);
				else if(_curSupplyState == NextSupplyShow.starSupplyTypeDamage)
					_statusShowSprite.graphics.beginFill(0x0000ff,1);
				else if(_curSupplyState == NextSupplyShow.starSupplyTypeHP)
					_statusShowSprite.graphics.beginFill(0xff0000,1);
			}
			_statusShowSprite.graphics.drawCircle(size,size,size);
			_statusShowSprite.graphics.endFill();
		}

	}
}