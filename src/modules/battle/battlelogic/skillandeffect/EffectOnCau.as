package modules.battle.battlelogic.skillandeffect
{
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.managers.BattleUnitPool;

	/**
	 * 计算时候的效果技能数据结构，只是有用数据的拷贝 
	 * @author SDD
	 */
	public class EffectOnCau
	{
		
		public var effectId:int = 0;
		private var _effectValue:* = 0;
		public var effectDuration:int = 0;
		private var _effectTarget:int = 0;		
		private var targetTroopInfo:CellTroopInfo;
		
		private var _sourceTroopIndex:int;
		private var _sourceTroopInfo:CellTroopInfo;
		
		private static var allEffectValue:Array=[];
		
		public var sourceEffectObject:BattleSingleEffect;
		
		public static function clearAllEffectInfo():void
		{
			while(allEffectValue.length > 0)
			{
				var singleInfo:EffectOnCau = allEffectValue.pop();
				if(singleInfo)
					singleInfo.clearInfo();
				singleInfo = null;
			}
		}
		
		public static function getNewEffectOnCau(effectId:int,effectValue:* = 0,effectDuration:* = 0,effectTarget:int = -1,sourceTroop:CellTroopInfo = null):EffectOnCau
		{
			var retValue:EffectOnCau = new EffectOnCau(effectId,effectValue,effectDuration,effectTarget,sourceTroop);
			allEffectValue.push(retValue);
			return retValue;
		}
		
		public function EffectOnCau(effectId:int,effectValue:* = 0,effectDuration:* = 0,effectTarget:int = -1,sourceTroop:CellTroopInfo = null)
		{
			this.effectId = effectId;
			this.effectValue = effectValue;
			this.effectDuration = effectDuration;
			this.effectTarget = effectTarget;
			if(sourceTroop)
				this.sourceTroopIndex = sourceTroop.troopIndex;
		}
		
		public function clearInfo():void
		{
			targetTroopInfo = null;
			_sourceTroopInfo = null;
			sourceEffectObject = null;
		}
		
		public function get effectTarget():int
		{
			return _effectTarget;
		}

		public function set effectTarget(value:int):void
		{
			_effectTarget = value;
			if(_effectTarget >= 0)
			{
				targetTroopInfo = BattleUnitPool.getTroopInfo(_effectTarget);
			}
			else
			{
				targetTroopInfo = null;
			}
		}

		public function get effectValue():*
		{
			if(sourceTroopInfo && targetTroopInfo)
			{
				var ratio:Number = 1.0;
				if(effectId == SpecialEffectDefine.XiXue || effectId == SpecialEffectDefine.NLianJi || 
					effectId == SpecialEffectDefine.FuJiaGongJi || effectId == SpecialEffectDefine.FanJi || 
					effectId == SpecialEffectDefine.ShangHaiFanTan || effectId == SpecialEffectDefine.ShiQiZengJia || 
					effectId == SpecialEffectDefine.shiQiEWaiZengJia)
				{
					ratio = 1;
				}
				else
				{
					if(!sourceTroopInfo.isHero)
					{
						ratio = sourceTroopInfo.maxArmCount / targetTroopInfo.maxArmCount;
					}
					else
					{
						ratio = sourceTroopInfo.attackUnit.contentHeroInfo.getArmAmount() / targetTroopInfo.maxArmCount;
					}
					if(isNaN(ratio))
						ratio = 1;
					if(targetTroopInfo.troopIndex != _sourceTroopIndex)
						ratio /= (targetTroopInfo.cellsCountNeed.x * targetTroopInfo.cellsCountNeed.y);
				}
				if(sourceTroopInfo.troopIndex != targetTroopInfo.troopIndex)
					return _effectValue * ratio;
			}
			return _effectValue;
		}

		public function get pureEffectValue():*
		{
			return _effectValue;
		}
		
		public function set effectValue(value:*):void
		{
			_effectValue = value;
		}

		public function get sourceTroopIndex():int
		{
			return _sourceTroopIndex;
		}

		public function set sourceTroopIndex(value:int):void
		{
			_sourceTroopIndex = value;
			if(_sourceTroopIndex >= 0)
			{
				_sourceTroopInfo = BattleUnitPool.getTroopInfo(_sourceTroopIndex);
			}
			else
			{
				_sourceTroopInfo = null;
			}
		}

		public function get sourceTroopInfo():CellTroopInfo
		{
			return _sourceTroopInfo;
		}
		
	}
}