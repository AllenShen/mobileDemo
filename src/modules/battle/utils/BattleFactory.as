package modules.battle.utils
{
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.battlelogic.skillandeffect.EffectOnCau;
	import modules.battle.funcclass.ChainFunc;

	/**
	 * 战斗的时候使用到的工厂类 
	 * @author Administrator
	 * 
	 */
	public class BattleFactory
	{
		
		/**
		 * 根据一个 effect增加buff
		 * @param chain
		 * @return 
		 */
		public static function getBattleEffectFromChain(chain:CombatChain,effectid:int,atk:Boolean):Array
		{
			var resValue:Array=[];
			
			if(chain == null)
				return resValue;
			
			var allEffectsOfId:Array = getTotalEffectsOfSomeEffects(chain,effectid,atk);
			for each(var singleEffectOnCau:EffectOnCau in allEffectsOfId)
			{
				if(singleEffectOnCau)
				{
					var retEff:BattleSingleEffect = new BattleSingleEffect();
					retEff.effectId = effectid;
					retEff.effectValue = singleEffectOnCau.pureEffectValue;
					retEff.effectDuration = singleEffectOnCau.effectDuration;
					retEff.effectSourceTroop = chain.atkTroopIndex;
					resValue.push(retEff);
				}
			}
			return resValue;
		}
		
		/**
		 * 获得某个效果的所有effect 
		 * @param effectId
		 * @param atk
		 * @return 
		 * 
		 */
		public static function getTotalEffectsOfSomeEffects(chain:CombatChain,effectId:int,atk:Boolean = true):Array
		{
			var resValue:Array  ={};
			if(chain == null)
				return resValue;
			var targetArr:Array = atk ? chain.effFromAtk : chain.effFromDef;	
			for each(var singleEffectOnCau:EffectOnCau in targetArr)
			{
				if(singleEffectOnCau && singleEffectOnCau.effectId == effectId)
					resValue.push(singleEffectOnCau);
			}
			return resValue;
		}
		
		public function BattleFactory()
		{
		}
	}
}