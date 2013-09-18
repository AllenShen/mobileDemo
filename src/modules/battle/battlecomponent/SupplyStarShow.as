package modules.battle.battlecomponent
{
	import flash.display.Sprite;
	
	public class SupplyStarShow extends Sprite
	{
		
		public var allSingleStars:Array = [];
		
		public function SupplyStarShow()
		{
			super();
		}
		
		public function initStars(starsCount:int):void
		{
			var singleStar:SingleSupplyStar;
			while(allSingleStars.length > 0)
			{
				singleStar = allSingleStars.shift();
				if(singleStar == null)
					continue;
				if(singleStar.parent)
					singleStar.parent.removeChild(singleStar);
				singleStar = null;
			}
			for(var i:int = 0; i < starsCount;i++)
			{
				singleStar = new SingleSupplyStar();
				this.addChild(singleStar);
				allSingleStars.push(singleStar);
				singleStar.x = i * 45;
			}
		}
		
		public function hadnlerNewStarQuilified(type:int,addValue:int,percent:Number):void
		{
			var singleStar:SingleSupplyStar;
			for(var i:int = 0;i < allSingleStars.length;i++)
			{
				singleStar = allSingleStars[i];
				if(singleStar == null || singleStar.curSupplyState != 0)
					continue;
				singleStar.curSupplyState = type;
				singleStar.supplyValue = addValue;
				singleStar.percent = percent;
//				singleStar.handlerNewValueCome(type,addValue);
				break;
			}
			
			for(i = curQuilifiedCount;i < allSingleStars.length;i++)
			{
				singleStar = allSingleStars[i];
				if(singleStar == null)
					continue;
				
				singleStar.curSupplyState = 0;
				singleStar.supplyValue = 0;
				singleStar.percent = 1;
				
//				singleStar.handlerNewValueCome(0,0);
			}
		}
		
		public function get isAllStarsQuilified():Boolean
		{
			return curQuilifiedCount >= allSingleStars.length;
		}
		
		public function get curQuilifiedCount():int
		{
			var count:int = 0;
			var singleStar:SingleSupplyStar;
			for(var i:int = 0;i < allSingleStars.length;i++)
			{
				singleStar = allSingleStars[i];
				if(singleStar.curSupplyState != 0)
				{
					count++;
				}
			}
			return count;
		}
		
		public function clearInfo():void
		{
			var singleStar:SingleSupplyStar;
			while(allSingleStars.length > 0)
			{
				singleStar = allSingleStars.shift();
				if(singleStar == null)
					continue;
				if(singleStar.parent)
					singleStar.parent.removeChild(singleStar);
				singleStar = null;
			}
		}
	}
}