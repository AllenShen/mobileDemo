package modules.battle.managers
{
	import effects.floatingobjs.FloatingAwayManager;
	
	import flash.geom.Point;
	
	import macro.AttackRangeDefine;
	import macro.FloatingObjectDefine;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlecomponent.SingleTroopGuanghuanBuff;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.funcclass.SkillEffectFunc;
	import modules.battle.funcclass.TroopEffectDisplayFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.stage.BattleStage;
	
	import sysdata.Skill;
	import sysdata.SkillElement;
	
	import tools.textengine.StringUtil;
	import tools.textengine.TextEngine;

	/**
	 * 卡片技能的管理器 
	 * @author SDD
	 */
	public class GuangHuanSkillManager
	{
		
		public static var allTroopGuanghuanBuff:Object = {};
		
		public function GuangHuanSkillManager()
		{
		}
		
		/**
		 *  让所有光环技能生效
		 * @param atkSide 攻击方
		 */
		public function makeAllSkillPrepared(atkSide:int = 0):void
		{
			var i:int = 0;
			var ii:int = 0;
			var tt:int = 0;
			var singleTroop:CellTroopInfo;
			var troopGuangHuanSkills:Array;
			var singleSkill:Skill;
			var effectArr:Array;
			var singleElement:SkillElement;
			var singleEffect:BattleSingleEffect;
			var targetTroopArr:Array;
			var targetTroop:CellTroopInfo;
			
			var allTroops:Array = BattleUnitPool.getAllTroops();
			for(i = 0;i < allTroops.length;i++)
			{
				singleTroop = allTroops[i] as CellTroopInfo;
				if(singleTroop == null || singleTroop.ownerSide != atkSide)
					continue;
				troopGuangHuanSkills = SkillEffectFunc.getGuanghuangSkill(singleTroop);
				if(troopGuangHuanSkills == null || troopGuangHuanSkills.length <= 0)
					continue;
				for each(singleSkill in troopGuangHuanSkills)
				{
					if(singleSkill == null)
						continue;
					effectArr = SkillEffectFunc.getFiltedBattleSingleEffects(singleSkill);
					for(ii = 0; ii < effectArr.length;ii++)
					{
						singleEffect = effectArr[ii];
						
						if(singleEffect)
						{
							//英雄不处理此逻辑			这是英雄攻击本来的基本伤害输出
							if(singleEffect.effectId == SpecialEffectDefine.ShangHaiShuChuZengJia && singleTroop.isHero)
								continue;
							singleEffect.effectSourceTroop = singleTroop.troopIndex;
							if(SpecialEffectDefine.checkAddToSelfForceWhenGuanghuang(singleEffect.effectId))
							{
								targetTroopArr = [singleTroop];
							}
							else
							{
								targetTroopArr = BattleTargetSearcher.getTargetsForSomeRange(singleTroop.troopIndex,singleEffect.effectTarget,0,singleTroop,singleEffect.effectTarget);
							}
							for(tt = 0; tt < targetTroopArr.length; tt++)
							{
								targetTroop = targetTroopArr[tt] as CellTroopInfo;
								if(targetTroop)
								{
									singleEffect.effectDuration = BattleDefine.guanghuangDuration;					//光环技能的效果持续无限回合
									TroopFunc.addSingleBuff(targetTroop,singleEffect,false);
									showGuanHuangFloatingStr(singleEffect,targetTroop);
								}
							}
						}
					}
				}
			}
			addBuffShowToStage();
		}
		
		private static function addBuffShowToStage():void
		{
			for(var singleTroopIndex:String in allTroopGuanghuanBuff)
			{
				var troopBuff:SingleTroopGuanghuanBuff = allTroopGuanghuanBuff[singleTroopIndex];
				var targetTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(int(singleTroopIndex));
				if(troopBuff && targetTroop)
				{
					BattleStage.instance.effectLayer.addGuangHuanBuff(targetTroop,troopBuff);
				}
			}
			allTroopGuanghuanBuff = {};
		}
		
		/**
		 * 为光环技能飘字 
		 * @param singleEffect
		 * @param BattleSingleEffect
		 * @param targetTroop
		 */
		public static function showGuanHuangFloatingStr(singleEffect:BattleSingleEffect,targetTroop:CellTroopInfo):void
		{
			if(singleEffect == null || targetTroop == null)
				return;
			var floatingPos:Point = new Point(targetTroop.x,targetTroop.y);
			switch(singleEffect.effectId)
			{
				case SpecialEffectDefine.WuLiShangHaiMianYi:
				case SpecialEffectDefine.MoFaShangHaiMianYi:
					if(singleEffect.effectValue < 0)
					{
//						FloatingAwayManager.showFloatingObjectsOfPureText(BattleStage.instance.effectLayer,
//							[makeGuangHuanShowStr(singleEffect.effectId,singleEffect.effectValue)],floatingPos,FloatingObjectDefine.floatingScaleType_Green);
						addSingleTroopGuangHuanBuff(targetTroop,singleEffect.effectId,singleEffect.effectValue);
					}
					else if(singleEffect.effectValue > 0)
					{
//						FloatingAwayManager.showFloatingObjectsOfPureText(BattleStage.instance.effectLayer,
//							[makeGuangHuanShowStr(singleEffect.effectId,singleEffect.effectValue)],floatingPos,FloatingObjectDefine.floatingScaleType_Red);
						addSingleTroopGuangHuanBuff(targetTroop,singleEffect.effectId,singleEffect.effectValue);
					}
					break;
				case SpecialEffectDefine.ShangHaiShuChuZengJia:
				case SpecialEffectDefine.BaoJiZengJia:
				case SpecialEffectDefine.ShanBiZengJia:
				case SpecialEffectDefine.HPShangXianZengJia:
					if(singleEffect.effectValue < 0)
					{
//						FloatingAwayManager.showFloatingObjectsOfPureText(BattleStage.instance.effectLayer,
//							[makeGuangHuanShowStr(singleEffect.effectId,singleEffect.effectValue)],floatingPos,FloatingObjectDefine.floatingScaleType_Red);
						addSingleTroopGuangHuanBuff(targetTroop,singleEffect.effectId,singleEffect.effectValue);
					}
					else if(singleEffect.effectValue > 0)
					{
//						FloatingAwayManager.showFloatingObjectsOfPureText(BattleStage.instance.effectLayer,
//							[makeGuangHuanShowStr(singleEffect.effectId,singleEffect.effectValue)],floatingPos,FloatingObjectDefine.floatingScaleType_Green);
						addSingleTroopGuangHuanBuff(targetTroop,singleEffect.effectId,singleEffect.effectValue);
					}
					break;
				case SpecialEffectDefine.shiQiEWaiZengJia:
					TroopEffectDisplayFunc.showBattleCardEffect(targetTroop,SpecialEffectDefine.shiQiEWaiZengJia);
					break;
				case  SpecialEffectDefine.ShangHaiZengJia:
					if(singleEffect.effectValue < 0)
					{
//						FloatingAwayManager.showFloatingObjectsOfPureText(BattleStage.instance.effectLayer,
//							[makeGuangHuanShowStr(singleEffect.effectId,singleEffect.effectValue)],floatingPos,FloatingObjectDefine.floatingScaleType_Red);
						addSingleTroopGuangHuanBuff(targetTroop,singleEffect.effectId,singleEffect.effectValue);
					}
					else if(singleEffect.effectValue > 0)
					{
//						FloatingAwayManager.showFloatingObjectsOfPureText(BattleStage.instance.effectLayer,
//							[makeGuangHuanShowStr(singleEffect.effectId,singleEffect.effectValue)],floatingPos,FloatingObjectDefine.floatingScaleType);
						addSingleTroopGuangHuanBuff(targetTroop,singleEffect.effectId,singleEffect.effectValue);
					}
					break;
				case SpecialEffectDefine.shiQiEWaiZengJia: 
					if(singleEffect.effectValue > 0)
					{
						addSingleTroopGuangHuanBuff(targetTroop,singleEffect.effectId,singleEffect.effectValue);
					}
				default:
					break;
			}
		}
		
		private static function addSingleTroopGuangHuanBuff(troop:CellTroopInfo,buffId:int,buffValue:Number):void
		{
			var troopBuff:SingleTroopGuanghuanBuff = allTroopGuanghuanBuff[troop.troopIndex];
			if(troopBuff == null)
			{
				troopBuff = new SingleTroopGuanghuanBuff();
				allTroopGuanghuanBuff[troop.troopIndex] = troopBuff;
			}
			troopBuff.addSingleTroopGuanghuanBuff(buffId,buffValue);
		}
		
	}
}