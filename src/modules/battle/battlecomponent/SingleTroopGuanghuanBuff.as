package modules.battle.battlecomponent
{
	import caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class SingleTroopGuanghuanBuff extends Sprite
	{
		
		private var index:int = 0;
		private var allBuffContianer:Object = {};
		
		private var contentTimer:Timer;
		
		public function SingleTroopGuanghuanBuff()
		{
			super();
		}
		
		/**
		 * 增加一个troop的光环buff 
		 * @param troopIndex
		 * @param buffType
		 * @param value
		 */
		public function addSingleTroopGuanghuanBuff(buffType:int,value:Number):void
		{
			var singleBuffShow:SingleGuanghuangBuff = allBuffContianer[buffType] as SingleGuanghuangBuff;
			if(singleBuffShow == null)
			{
				singleBuffShow = new SingleGuanghuangBuff();
				singleBuffShow.effectId = buffType;
				this.addChild(singleBuffShow);
				singleBuffShow.x = 0;
				singleBuffShow.y = index * 23;
				index++;
				allBuffContianer[buffType] = singleBuffShow;
			}
			singleBuffShow.value += value;
		}
		
		public function startCountBack():void
		{
			contentTimer = new Timer(2000,1);
			contentTimer.addEventListener(TimerEvent.TIMER_COMPLETE,timercomplete);
			contentTimer.start();
		}
		
		private function timercomplete(event:TimerEvent):void
		{
			Tweener.addTween(this,{alpha:0,time:1,transition:"linear",onComplete:clearInfo});
		}
		
		public function get realHeight():int
		{
			return index * 17 + 10;
		}
		
		private function clearInfo():void
		{
			if(this.parent)
				this.parent.removeChild(this);
			for(var singleKey:String in allBuffContianer)
			{
				var singleBuffShow:SingleGuanghuangBuff = allBuffContianer[singleKey];
				if(singleBuffShow && singleBuffShow.parent)
					singleBuffShow.parent.removeChild(singleBuffShow);
				singleBuffShow = null;
			}
		}
		
	}
}