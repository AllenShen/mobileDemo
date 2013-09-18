package modules.battle.funcclass
{
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.battlelogic.skillandeffect.EffectOnCau;

	/**
	 * Chain的功能类 
	 * @author SDD
	 */
	public class ChainFunc
	{
		public function ChainFunc()
		{
		}
		
		/**
		 * 取得chain中作用于攻击方，或者作用于防守方的所有effect 
		 * @param chain
		 * @param effectId
		 * @param atk
		 * @return 
		 */
		public static function getAllEffectWorkOnTargetOrSource(chain:CombatChain,effectId:int,onTarget:Boolean):Array
		{
			var resArray:Array=[];
			if(chain == null)
				return resArray;
			var targetArr:Array = chain.effFromAtk.concat(chain.effFromDef);
			for each(var singleEffectOnCau:EffectOnCau in targetArr)
			{
				if(singleEffectOnCau && singleEffectOnCau.effectId == effectId)
				{
					if(onTarget)
					{
						if(singleEffectOnCau.effectTarget == chain.defTroopIndex)
							resArray.push(singleEffectOnCau);
					}
					else
					{
						if(singleEffectOnCau.effectTarget == chain.atkTroopIndex)
							resArray.push(singleEffectOnCau);
					}
				}
			}
			return resArray;
		}
		
		/**
		 * 判断是否有某个类型的效果存在于这个chain内    (新产生的)
		 * @param effect
		 * @param atk
		 */
		public static function hasSomeNewGeneratedEffect(chain:CombatChain,effectId:int,onTarget:Boolean):Boolean
		{
			var targetArr:Array = chain.effFromAtk.concat(chain.effFromDef);
			for each(var singleEffectOnCau:EffectOnCau in targetArr)
			{
				if(singleEffectOnCau && singleEffectOnCau.effectId == effectId)
				{
					if(onTarget)
					{
						if(singleEffectOnCau.effectTarget == chain.defTroopIndex)
							return true;
					}
					else
					{
						if(singleEffectOnCau.effectTarget == chain.atkTroopIndex)
							return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * 获得某个效果的总的值        (不包括N连击)    比如所有抗性增加的抗性
		 * @return 值
		 */
		public static function getTotalvalueForSingleEffect(chain:CombatChain,effectId:int,onTarget:Boolean = true):Number
		{
			if(effectId == SpecialEffectDefine.NLianJi)
				return 0;
			var resValue:Number;
			var allValues:Array = ChainFunc.getAllEffectWorkOnTargetOrSource(chain,effectId,onTarget);
			for(var i:int = 0; i < allValues.length;i++)
			{
				resValue += allValues[i];
			}
			return resValue;
		}
		
		/**
		 * 获得chain中所有的效果 
		 * @param chain
		 * @param atk
		 * @return 
		 */
		public static function getAllEffectsOfChain(chain:CombatChain):Array
		{
			var targetArr:Array = chain.effFromAtk.concat(chain.effFromDef);
			return targetArr;
		}
		
		/**
		 * 攻击方   或者防守方 当时是否被某个 
		 * @param effect    id
		 * @param atk		是否是攻击	
		 * @return 			
		 * 
		 */
		public static function hasSomeExistedEffect(chain:CombatChain,effect:int,atk:Boolean):Boolean
		{
			var targetArr:Array = atk ? chain.existedEffOnAttak : chain.existedEffOnDef;
			for each(var singleEffectCau:EffectOnCau in targetArr)
			{
				if(singleEffectCau && singleEffectCau.effectId == effect)
					return true;
			}
			return false;
		}
		
		/**
		 * 获得已经存在的效果 
		 * @param chain				chain信息
		 * @param effectId			effeciId
		 * @param atk				是否为攻击
		 * @return 
		 */
		public static function getExistedEffect(chain:CombatChain,effectId:int,atk:Boolean):Array
		{
			var resValue:Array=[];
			var targetArr:Array = atk ? chain.existedEffOnAttak : chain.existedEffOnDef;
			
			for each(var singleEff:EffectOnCau in targetArr)
			{
				if(singleEff && singleEff.effectId == effectId)
				{
					targetArr.push(singleEff);
				}
			}
			return resValue;
		}
		
	}
}