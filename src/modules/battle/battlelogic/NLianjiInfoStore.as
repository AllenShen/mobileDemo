package modules.battle.battlelogic
{
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;

	/**
	 * 记录N连击的情形的 
	 * @author SDD
	 */
	public class NLianjiInfoStore
	{
		
		public var curIndex:int = 0;
		public var allDamageRatio:Array=[];
		public var isCirctl:Boolean = false;
		
		public function NLianjiInfoStore()
		{
		}
		
		/**
		 * 初始化信息 
		 * @param effect				对应的N连击效果
		 */
		public function initFromLianjiEffect(effect:BattleSingleEffect):void
		{
			allDamageRatio =[];
			if(effect == null || effect.effectId != SpecialEffectDefine.NLianJi)
				allDamageRatio = [0];
			var damageInfoArr:Array = effect.effectValue as Array;
			for(var i:int = 0;i < damageInfoArr.length;i++)
			{
				allDamageRatio.push(damageInfoArr[i]);
			}
		}
		
		/**
		 * 获得当前攻击的伤害系数
		 * @return 
		 */
		public function getCurAttackRatio():Number
		{
			if(curIndex < allDamageRatio.length)
				return allDamageRatio[curIndex];
			return 0;
		}
		
		/**
		 *  将不需要用到的信息删除
		 */
		public function deleteUseLessInfo():void
		{
			allDamageRatio.splice(curIndex + 1);
		}
		
		public function increaseLianjieStep():void
		{
			curIndex++;
		}
		
	}
}