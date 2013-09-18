package modules.battle.funcclass
{
	import macro.ArmDamageType;
	import macro.ArmType;
	import macro.DamageType;
	import macro.FormationElementType;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battledefine.BattleCaualValue;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleTypeDefine;
	import modules.battle.battledefine.RandomValueService;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.utils.BattleUtils;
	
	/**
	 * 战斗过程中的计算数值的类 
	 * @author SDD
	 */
	public class BattleCalculator
	{
		public function BattleCalculator()
		{
		}
		
		/**
		 * 获得伤害基本值 
		 * @param attackSource
		 * @param attackTarget
		 * @return 
		 * 
		 */
		private static function getBaseValue(atkTroop:CellTroopInfo,defTroop:CellTroopInfo,chain:CombatChain):Number
		{
			var retValue:Number = 0.0;
			
			if(atkTroop == null || defTroop == null)								//不存在troop信息
				return retValue;
			
			if(atkTroop.attackUnit == null)			//不存在攻击信息
				return retValue;
			
			var realDamageValue:Number = atkTroop.damageValue;
			
			if(!atkTroop.isHero)						//士兵攻击类型
			{
				if(atkTroop.attackUnit.slotType == FormationElementType.ARROW_TOWER)			//箭塔取平均值
				{
					retValue = (realDamageValue)*atkTroop.heroArmCount;
				}
				else
				{
					retValue = (realDamageValue)*atkTroop.maxArmCount;       //（我方伤害）*我方初始兵力
				}
			}
			else					//英雄攻击类型
			{
				//取得此技能的攻击力
//				var heroDamageValue:int = ChainFunc.getTotalvalueForSingleEffect(chain,SpecialEffectDefine.yingXiongJiNengShangHai,true);
				var heroDamageValue:int = atkTroop.attackUnit.contentHeroInfo.skilldamage;
				var singleAMount:int = atkTroop.attackUnit.contentHeroInfo.getArmAmount();
				retValue = heroDamageValue * singleAMount;			//（技能伤害）*英雄带兵量
			}
			
			retValue = Math.max(1,retValue);
			return retValue;
		}
		
		/**
		 *获得单次攻击的伤害值
		 * 可能为英雄攻击，可能为普通攻击 
		 * @param atkTroop
		 * @param defTroop
		 * @param chain
		 * 
		 */
		public static function getSingleDamageValue(atkTroop:CellTroopInfo,defTroop:CellTroopInfo,chain:CombatChain):int
		{
			var retValue:int;
			var baseValue:Number = getBaseValue(atkTroop,defTroop,chain);
			var factor:Number = 1.0;
			if(!atkTroop.isHero)									//士兵的攻击
			{
				if(atkTroop.attackUnit.damageType != ArmDamageType.fashu)			//非法师，物理类攻击
				{
					//(我方英雄一般攻击力/对方英雄一般防御力）*（我方英雄武力值/对方英雄武力值）
					factor = (atkTroop.heroNormalAttack / defTroop.heroNormalDefense);	
					if(isNaN(factor))
						factor = 1;
					factor = Math.min(2.0,factor);
					factor = Math.max(0.5,factor);
//					factor *= (atkTroop.wuli / defTroop.wuli);
				}
				else																	//法师
				{
					//(我方魔法攻击力/对方魔法防御力）*（我方英雄智力值/对方英雄智力值）
					factor = (atkTroop.heroMagicAttack / defTroop.heroMagicDefense);	
					if(isNaN(factor))
						factor = 1;
					factor = Math.min(3,factor);
					factor = Math.max(0.3,factor);
//					factor *= (atkTroop.zhili / defTroop.zhili);
				}
				
//				（0.8~1.2取一个随机值）*属性加成*英雄武器或其它装备效果加成*（我方英雄武力/智力值/对方英雄武力/智力值）
				factor *= BattleUtils.getRandomValueFromRegion(0.8,1.2,RandomValueService.getRandomValue(RandomValueService.RD_CAU,atkTroop.troopIndex));
			}
			else							//英雄攻击
			{
				//(我方物理（魔法）攻击力/对方物理（魔法）防御力
				if(atkTroop.isMaster)
				{
					if(atkTroop.isPlayerHero)		//玩家英雄选最大攻击力
					{
						factor = (atkTroop.maxDamageValue / defTroop.heroMagicDefense);
					}
					else
					{
						factor = (atkTroop.heroMagicAttack / defTroop.heroMagicDefense);
					}
				}
				else
				{
					if(atkTroop.isPlayerHero)		//玩家英雄选最大攻击力
					{
						factor = (atkTroop.maxDamageValue / defTroop.heroNormalDefense);
					}
					else
					{
						factor = (atkTroop.heroNormalAttack / defTroop.heroNormalDefense);
					}
				}
				factor = Math.min(4,factor);
				factor = Math.max(0.2,factor);
				
				factor *= BattleUtils.getRandomValueFromRegion(0.8,1.2,RandomValueService.getRandomValue(RandomValueService.RD_CAU,atkTroop.troopIndex));
				if(BattleManager.instance.curRound.roundType != BattleDefine.aoyiRound)
					factor *= BattleInfoSnap.getSingleHeroMorale(atkTroop) / 90;
//				factor *= (atkTroop.baqi / defTroop.baqi);
			}
			retValue = baseValue * factor;
			
			if(atkTroop.isHero)
				retValue = atkTroop.heroNormalAttack;
			else
				retValue = atkTroop.damageValue;
			
			return retValue;
		}
	}
}