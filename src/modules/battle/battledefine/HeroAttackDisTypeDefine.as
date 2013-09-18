package modules.battle.battledefine
{
	import macro.AttackRangeDefine;

	/**
	 * 英雄攻击的各种距离定义 
	 * @author SDD
	 * 
	 */
	public class HeroAttackDisTypeDefine
	{
		//距离为2的各种攻击
		public static const dis2_type1:int = 1;				//单个目标
		//距离为3的各种攻击
		public static const dis3_type1:int = 6;				//单个目标
		//距离为4的各种攻击
		public static const dis4_type1:int = 11;				//单个目标
		
		/**
		 * 获得攻击对应的类型 
		 * @param dis
		 * @param range
		 * @return 
		 */
		public static function getAttackTypeByDisRange(dis:int,range:int):int
		{
			var target:int = 1;
			if(dis == 2)
			{
				if(checkRangeHasDirectTarget(range))
					target = dis2_type1;
			}
			else if(dis == 3)
			{
				if(checkRangeHasDirectTarget(range))
					target = dis3_type1;
			}
			else if(dis == 4)
			{
				if(checkRangeHasDirectTarget(range))
					target = dis4_type1;
			}
			return target;
		}
		
		/**
		 * 判断攻击范围是否包含正对目标 
		 * @param range
		 * @return 
		 */
		public static function checkRangeHasDirectTarget(range:int):Boolean
		{
			var retValue:Boolean = false;
			switch(range)
			{
				case AttackRangeDefine.dantiGongJi:
				case AttackRangeDefine.duotiGongJi1:
				case AttackRangeDefine.duotiGongJi2:
				case AttackRangeDefine.duotiGongJi3:
				case AttackRangeDefine.duotiGongJi4:
				case AttackRangeDefine.duotiGongJi5:
				case AttackRangeDefine.duotiGongJi6:
				case AttackRangeDefine.duotiGongJi7:
				case AttackRangeDefine.duotiGongJi8:
				case AttackRangeDefine.duotiGongJi9:
				case AttackRangeDefine.duotiGongJi10:
				case AttackRangeDefine.duotiGongJi11:
					retValue = true;
					break;
				default:
					break;
			}
			return retValue;
		}
		
		public function HeroAttackDisTypeDefine()
		{
		}
	}
}