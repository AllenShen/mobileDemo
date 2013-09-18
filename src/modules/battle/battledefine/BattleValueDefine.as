package modules.battle.battledefine
{
	/**
	 * 战斗时候使用到的具体数值 
	 * @author SDD
	 */
	public class BattleValueDefine
	{
		
		public static const moraleGapToSkillAttack:int = 80;			//触发英雄技能攻击的士气阀值
		public static const maxMoraleValue:int = 160;					//最大士气值	
		
		public static const Attack_Morale:int = 15;				//普通攻击带来的士气
		public static const Defense_Morale:int = 8;			//被击中士气变化
		public static const Attack_Critcal:int = 30;			//暴击士气
		public static const Attack_Miss_Attack:int = 0;			//攻击方没有击中，士气值
		public static const Attack_Miss_Target:int = 16;		//攻击方未命中，被攻击方士气值变化
		
		public static const ExtraMoraleGained:int = 5;
		public static const ExtraUserLevelGap:int = 15;		
		
		public static const MaxCardCanUse:int = 8;				//最大可以用的卡片数量
		
		public static const isJiantaHero:int = 0;				//是箭塔英雄
		public static const noJiantaHero:int = 1;				//不是箭塔英雄
		
		public static const troopHavaGapProbility:Number = 0.4;			//有错开时间的概率
		public static const troopAttackGapTime:int = 3;		//troop错开攻击的时间		帧数
		
		public static const singleArmSupplyPrice:int = 1;		
		public static const armSupplyWorkGap:int = 30;
		
		public static const armSupplyRatio:Number = 0.1;
		
		public static const nonFuJiaAttackEffect:int = 1415;
		
		public function BattleValueDefine()
		{
		}
	}
}