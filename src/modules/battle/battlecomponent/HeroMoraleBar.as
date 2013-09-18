package modules.battle.battlecomponent
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import modules.battle.battledefine.BattleValueDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	
	import synchronousLoader.ResourcePool;

	/**
	 * 显示副将，英雄的士气值 
	 * @author SDD
	 */
	public class HeroMoraleBar extends TroopComponentBase
	{
		private var moraleMc:MovieClip;
		private var frameToStop:int = 1;		
		private var totalFrame:int = 40;
		
		private var targetAllValue:int;
		
		private var _curGapTotalMoraleValue:int = 0;
		private var _curMoraleValue:int = 0;
		
		public function HeroMoraleBar(cellInfo:CellTroopInfo)
		{
			super(cellInfo);
			
			if(cellInfo == null)
				return;
		}
		
		/**
		 * 初始化 
		 */
		public function initStatus():void
		{
			_curMoraleValue = 0;
			targetAllValue = 0;
			this.visible = true;
			if(moraleMc == null)
			{
				moraleMc = ResourcePool.getReflectSwfById(15007);
			}
			if(moraleMc)
			{
				this.addChild(moraleMc);
				moraleMc.gotoAndStop(1);
				moraleMc.addEventListener(Event.ENTER_FRAME,moraleEnterFrameHandler);
			}
		}
		
		private function moraleEnterFrameHandler(event:Event):void
		{
			if(frameToStop == moraleMc.currentFrame)
			{
				moraleMc.stop();
			}
		}
		
		/**
		 * hp发生变化
		 * @param hpValue			变化值
		 * @param decrease			是否减少
		 */
		public function moraleChanged(moraleChangeValue:int):void
		{
			if(moraleChangeValue == 0)
			{
				return;
			}
			if(moraleChangeValue < 0)
			{
				if(moraleMc)
					moraleMc.gotoAndStop(1);
			}
			frameToStop = int((dataSource.moraleValue / BattleValueDefine.maxMoraleValue) * totalFrame);
			frameToStop = Math.min(frameToStop,totalFrame);
			frameToStop = Math.max(frameToStop,1);
			
			targetAllValue = dataSource.moraleValue;
			makeMove();
		}

		/**
		 * 进行变化 
		 */
		private function makeMove():void
		{
			if(moraleMc)
			{
				if(frameToStop == moraleMc.currentFrame)
					return;
				moraleMc.play();
			}
		}
		
		override public function clearInfo():void
		{
			super.clearInfo();
			if(moraleMc)
			{
				if(moraleMc.parent)
					moraleMc.parent.removeChild(moraleMc);
				moraleMc.removeEventListener(Event.ENTER_FRAME,moraleEnterFrameHandler);
				ResourcePool.releaseResourceById(15007,true);
			}
			moraleMc = null;
		}

	}
}