package modules.battle.battlecomponent
{
	import flash.events.Event;
	
	import effects.BattleEffectObjSWF;
	
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	
	/**
	 * 带有相应effect的战斗swf效果 
	 * @author SDD
	 */
	public class BattleEffectSwfForEffect
	{
		private var _contentEffect:BattleEffectObjSWF;				//具体用于显示的swf
		private var _targetEffect:BattleSingleEffect;				//对应的effect
		
		public function BattleEffectSwfForEffect()
		{

		}

		/**
		 * effect回合结束处理函数 
		 * @param event
		 */
		private function effectDurationOverHandler(event:Event):void
		{
			_targetEffect.removeEventListener(BattleSingleEffect.effectDurationOver,effectDurationOverHandler);
			if(_contentEffect)
			{
				_contentEffect.isBusy = false;
				if(_contentEffect.parent)
					_contentEffect.parent.removeChild(_contentEffect);
			}
		}
		
		public function clearInfo():void
		{
			effectDurationOverHandler(null);
		}
		
		public function get targetEffect():BattleSingleEffect
		{
			return _targetEffect;
		}

		public function set targetEffect(value:BattleSingleEffect):void
		{
			if(_targetEffect != null)
			{
				if(value)
				{
					if(_targetEffect.effectDuration <= value.effectDuration)
					{
						_targetEffect.removeEventListener(BattleSingleEffect.effectDurationOver,effectDurationOverHandler);
						_targetEffect = value;
						if(_targetEffect.effectDuration > 0)
							_targetEffect.addEventListener(BattleSingleEffect.effectDurationOver,effectDurationOverHandler);
					}
				}
				else
				{
					_targetEffect.removeEventListener(BattleSingleEffect.effectDurationOver,effectDurationOverHandler);
					_targetEffect = null;
				}
			}
			else
			{
				_targetEffect = value;
				if(_targetEffect && _targetEffect.effectDuration > 0)
					_targetEffect.addEventListener(BattleSingleEffect.effectDurationOver,effectDurationOverHandler);
			}
		}

		public function get contentEffect():BattleEffectObjSWF
		{
			return _contentEffect;
		}

		public function set contentEffect(value:BattleEffectObjSWF):void
		{
			_contentEffect = value;
		}

	}
}