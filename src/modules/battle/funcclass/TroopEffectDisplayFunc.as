package modules.battle.funcclass
{
	import flash.geom.Point;
	
	import effects.BattleEffectObjBase;
	import effects.BattleEffectObjSWF;
	import effects.BattleResourcePool;
	
	import macro.BattleCardTypeDefine;
	import macro.BattleDisplayDefine;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlecomponent.BattleEffectSwfForEffect;
	import modules.battle.battleconfig.BattleEffectIdConfig;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.EffectShowTypeDefine;
	import modules.battle.battledefine.EffectsAddedToTroopDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.battlelogic.skillandeffect.EffectOnCau;
	import modules.battle.managers.BattleEffectPosFunc;
	import modules.battle.stage.BattleStage;

	public class TroopEffectDisplayFunc
	{
		public function TroopEffectDisplayFunc()
		{
		}
		
		/**
		 * 显示单个战斗特效  被打击等 	加在场景上    加在被打击点
		 * @param troop
		 * @param resType
		 */
		public static function showSingleNormalEffect(atkTroop:CellTroopInfo,troop:CellTroopInfo,effectType:int):void
		{
			var targetMcIndex:int;
			var effectPos:Point;
			switch(effectType)
			{
				case EffectShowTypeDefine.EffectShow_BeiDaJi:
					targetMcIndex = TroopFunc.getAttackedEffect(atkTroop,false);
					effectPos = SkillEffectFunc.getEffectPos(troop,false,targetMcIndex,troop.ownerSide == BattleDefine.firstAtk,atkTroop);
					if(targetMcIndex <= 0)
						targetMcIndex = 1432;
					break;
				case EffectShowTypeDefine.EffectShow_SecondBeiDaJi:
					targetMcIndex = TroopFunc.getAttackedEffect(atkTroop,true);
					effectPos = SkillEffectFunc.getEffectPos(troop,false,targetMcIndex,troop.ownerSide == BattleDefine.firstAtk,atkTroop);
					if(targetMcIndex <= 0)
						targetMcIndex = 1432;
					break;
				case EffectShowTypeDefine.VariousEffect_XiaoBingJiNeng:
					targetMcIndex = BattleEffectIdConfig.getResIdForEffect(effectType);
					effectPos = SkillEffectFunc.getEffectPos(troop,false,targetMcIndex,troop.ownerSide == BattleDefine.firstAtk,atkTroop);
					break;
				case EffectShowTypeDefine.EffectShow_JiaShiqi:
					targetMcIndex = BattleEffectIdConfig.getResIdForEffect(effectType);
					effectPos = SkillEffectFunc.getEffectPos(troop,false,targetMcIndex,troop.ownerSide == BattleDefine.firstAtk,atkTroop);
					break;
			}
			
			var attackedEffect:BattleEffectObjBase = BattleResourcePool.getFreeResourceUnit(targetMcIndex);
			
			if(attackedEffect)
			{
				attackedEffect.playOnce = true;
				if(troop.ownerSide == BattleDefine.firstAtk)
					attackedEffect.scaleX = -1;
				else
					attackedEffect.scaleX = 1;
				attackedEffect.x = effectPos.x;
				attackedEffect.y = effectPos.y;
				BattleStage.instance.effectLayer.addChild(attackedEffect);
			}
		}
		
		/**
		 * 显示一般特效icon  闪避等			加在左上角
		 * @param resId
		 */
		public static function showSkillElementEffect(troop:CellTroopInfo,effectType:int):void
		{
			var resId:int = BattleEffectIdConfig.getResIdForEffect(effectType);
			
			var singleIcon:BattleEffectObjBase = BattleResourcePool.getFreeResourceUnit(resId);
			singleIcon.playOnce = true;
			
			singleIcon.x = (BattleDisplayDefine.cellWidth - singleIcon.width) / 2;
			singleIcon.y = 0;
			
			if(troop.ownerSide == BattleDefine.firstAtk)
			{
				singleIcon.x = (1 - troop.cellsCountNeed.x * BattleDisplayDefine.donghuaEffectPos) * BattleDisplayDefine.cellWidth;
			}
			else
			{
				singleIcon.x = (troop.cellsCountNeed.x * BattleDisplayDefine.cellWidth) * BattleDisplayDefine.donghuaEffectPos;
			}
			
			troop.componentsLayer.addChild(singleIcon);
		}
		
		/**
		 * 显示战斗卡片特效 	显示在中间
		 * @param troopInfo						troop信息
		 * @param effectType					效果类型	
		 */
		public static function showBattleCardEffect(troopInfo:CellTroopInfo,effectType:int):void
		{
			if(troopInfo == null)
				return;
			
			var targetEffectShowType:int = 0;
			switch(effectType)
			{
				case BattleCardTypeDefine.shiBingBuChong:
					targetEffectShowType = EffectShowTypeDefine.EffectShow_JiaXue;
					break;
				case BattleCardTypeDefine.quanTiZengYuan:
					targetEffectShowType = EffectShowTypeDefine.CardEffect_QuanTiZengYuan;
					break;
				case BattleCardTypeDefine.shangHaiTiGao:
					targetEffectShowType = EffectShowTypeDefine.CardEffect_ShangHaiTiGao;
					break;
				case BattleCardTypeDefine.jiNengChuFa:
				case BattleCardTypeDefine.xuanZejinengChuFa:
					targetEffectShowType = EffectShowTypeDefine.CardEffect_JiNengChuFa;
					break;
				case BattleCardTypeDefine.shiQiTiSheng:
					targetEffectShowType = EffectShowTypeDefine.CardEffect_ShiQiTiSheng;
					break;
				case BattleCardTypeDefine.PaoJi:
					targetEffectShowType = EffectShowTypeDefine.CardEffect_PaoJi;
					break;
			}	
			showEffcetOnTroopCenter(troopInfo,targetEffectShowType);
		}
		
		/**
		 * 显示加在troop中间的特效 
		 * @param troop
		 * @param resId
		 */
		public static function showEffcetOnTroopCenter(troopInfo:CellTroopInfo,targetEffectShowType:int,singleEffect:EffectOnCau = null):void
		{
			if(singleEffect)
			{
				//这是光环触发的技能
				if(singleEffect.sourceEffectObject && singleEffect.sourceEffectObject.effectDuration >= BattleDefine.guanghuangDurationOnCheck)
					return;
			}
			if(troopInfo == null)
				return;
			var resId:int = BattleEffectIdConfig.getResIdForEffect(targetEffectShowType);
			if(resId <= 0)
				return;
			var attackedEffect:BattleEffectObjBase = BattleResourcePool.getFreeResourceUnit(resId);
			if(attackedEffect)
			{
				attackedEffect.playOnce = true;
				
				var scale:int = Math.min(troopInfo.cellsCountNeed.x,troopInfo.cellsCountNeed.y);
				attackedEffect.scaleX = attackedEffect.scaleY = scale;
				
				var pos:Point = BattleEffectPosFunc.getTroopCenterPoint(troopInfo);
				pos.x += troopInfo.x;
				pos.y += troopInfo.y;
				
				attackedEffect.x = pos.x;
				attackedEffect.y = pos.y;
				BattleStage.instance.effectLayer.addChild(attackedEffect);
			}
		}
		
		/**
		 * 显示特殊特效,如冰冻等
		 * @param troopInfo						troop信息
		 * @param effectId						效果id
		 */
		public static function showSpecialEffect(troopInfo:CellTroopInfo,effect:BattleSingleEffect,show:Boolean = true):void
		{
			if(troopInfo == null || effect == null)
				return;
			var effectPos:Point = new Point;
			var targetResId:int;
			var freeUnit:BattleEffectObjSWF;
			
			var curEffect:BattleSingleEffect;
			var curObj:BattleEffectSwfForEffect = troopInfo.specialEffects[effect.effectId] as BattleEffectSwfForEffect;
			
			if(effect.effectId == SpecialEffectDefine.XuanYun)
			{
				freeUnit = getSomeParticularEffect(troopInfo,EffectsAddedToTroopDefine.bingKuai) as BattleEffectObjSWF;
				if(freeUnit == null)
				{
					targetResId = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectShow_Freeze);
					freeUnit = showEffectOnFeetDown(troopInfo,EffectsAddedToTroopDefine.bingKuai,targetResId,show) as BattleEffectObjSWF;
					if(freeUnit)
						freeUnit.stopAtLastFrame = true;
				}
			}
			else if(effect.effectId == SpecialEffectDefine.ZhongDu)
			{
				freeUnit = getSomeParticularEffect(troopInfo,EffectsAddedToTroopDefine.ranShao) as BattleEffectObjSWF;
				if(freeUnit == null)
				{
					targetResId = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectShow_RanShao);
					freeUnit = showEffectOnFeetDown(troopInfo,EffectsAddedToTroopDefine.ranShao,targetResId,show) as BattleEffectObjSWF;
				}
			}
			else if(effect.effectId == SpecialEffectDefine.shanghaiXiShou)
			{
				freeUnit = getSomeParticularEffect(troopInfo,EffectsAddedToTroopDefine.shanghaizhuanyiEffect) as BattleEffectObjSWF;
				if(freeUnit == null)
				{
					targetResId = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectShow_ShanghaiZhuanyi);
					freeUnit = showEffectOnFeetDown(troopInfo,EffectsAddedToTroopDefine.shanghaizhuanyiEffect,targetResId,show) as BattleEffectObjSWF;
				}
			}
			else if(effect.effectId == SpecialEffectDefine.baohuqiang)
			{
				freeUnit = getSomeParticularEffect(troopInfo,EffectsAddedToTroopDefine.baohuQiang) as BattleEffectObjSWF;
				if(freeUnit == null)
				{
					targetResId = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectShow_QiangBaohu);
					freeUnit = showEffectOnFeetDown(troopInfo,EffectsAddedToTroopDefine.baohuQiang,targetResId,show) as BattleEffectObjSWF;
					if(freeUnit)
						freeUnit.stopAtLastFrame = true;
				}
			}
//			else if(effect.effectId == SpecialEffectDefine.WuLiShangHaiMianYi)			//物理伤害免疫
//			{
//				if(effect.effectValue > 0)
//					return;
//				freeUnit = getSomeParticularEffect(troopInfo,EffectsAddedToTroopDefine.wulishanghaiMianyi) as BattleEffectObjSWF;
//				if(freeUnit == null)
//				{
//					targetResId = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectShow_wuliMianyi);
//					freeUnit = showEffectOnFeetDown(troopInfo,EffectsAddedToTroopDefine.wulishanghaiMianyi,targetResId,show) as BattleEffectObjSWF;
//				}
//			}
//			else if(effect.effectId == SpecialEffectDefine.MoFaShangHaiMianYi)			//魔法伤害免疫
//			{
//				if(effect.effectValue > 0)
//					return;
//				freeUnit = getSomeParticularEffect(troopInfo,EffectsAddedToTroopDefine.mofashanghaiMianyi) as BattleEffectObjSWF;
//				if(freeUnit == null)
//				{
//					targetResId = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectShow_mofaMianyi);
//					freeUnit = showEffectOnFeetDown(troopInfo,EffectsAddedToTroopDefine.mofashanghaiMianyi,targetResId,show) as BattleEffectObjSWF;
//				}
//			}
			if(curObj == null)
			{
				curObj = new BattleEffectSwfForEffect;
				curObj.contentEffect = freeUnit;
				curObj.targetEffect = effect;
				troopInfo.specialEffects[effect.effectId] = curObj;
			}
			else
			{
				curObj.contentEffect = freeUnit;
				curObj.targetEffect = effect;
			}
		}
		
		/**
		 * 显示在troop底部的特效 
		 * @param troop				troop
		 * @param effectType		effectType
		 * @param resId				resid	
		 * @param show				是否显示
		 */
		private static function showEffectOnFeetDown(troop:CellTroopInfo,effectType:String,resId:int,show:Boolean):BattleEffectObjBase
		{
			var retEffect:BattleEffectObjBase;
			if(troop == null)
				return retEffect;
			var targetEffect:BattleEffectObjBase = getSomeParticularEffect(troop,effectType);
			if(show)
			{
				if(targetEffect && troop.componentsLayer.contains(targetEffect))
				{
					troop.componentsLayer.removeChild(targetEffect);
					targetEffect.isBusy = false;
				}
				targetEffect = BattleResourcePool.getFreeResourceUnit(resId);
				if(targetEffect)
				{
					var targetScale:int = 0;
					targetScale = troop.cellsCountNeed.x;
					
					var pos:Point = BattleEffectPosFunc.getTroopDownPos(troop);
					targetEffect.x = pos.x;
					targetEffect.y = pos.y;
					
					targetEffect.scaleX = targetScale;
					
					targetEffect.scaleY = 1;
					
					if(effectType == EffectsAddedToTroopDefine.shanghaizhuanyiEffect)
					{
						targetEffect.scaleX *= troop.ownerSide == BattleDefine.firstAtk ? -1 : 1;
						targetEffect.x += targetEffect.width * troop.cellsCountNeed.x;
						
						targetEffect.scaleY = troop.cellsCountNeed.y;
					}
					else if(effectType == EffectsAddedToTroopDefine.mofashanghaiMianyi || 
						effectType == EffectsAddedToTroopDefine.wulishanghaiMianyi)
					{
						targetEffect.scaleX = troop.ownerSide == BattleDefine.firstAtk ? -1 : 1;
						if(troop.ownerSide == BattleDefine.firstAtk)
						{
							targetEffect.x = (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal) * (troop.cellsCountNeed.x - 1);
							targetEffect.x += targetEffect.width;
						}
						else
						{
							targetEffect.x += 20;
						}
						
						targetEffect.scaleY = troop.cellsCountNeed.y;
						targetEffect.y -= (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal) * (troop.cellsCountNeed.y - 1);
					}
					else if(effectType == EffectsAddedToTroopDefine.baohuQiang)
					{
						targetEffect.scaleX = troop.ownerSide == BattleDefine.firstAtk ? -1 : 1;
						if(troop.ownerSide == BattleDefine.firstAtk)
						{
//							targetEffect.x = (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal) * (troop.cellsCountNeed.x - 1);
							targetEffect.x = 0;
							targetEffect.x += targetEffect.width - 50;
						}
						else
						{
							targetEffect.x += 20;
						}
						
						targetEffect.scaleY = troop.cellsCountNeed.y;
						targetEffect.y -= (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal) * (troop.cellsCountNeed.y - 1);
					}
					
					targetEffect.isBusy = true;
					troop.componentsLayer.addChild(targetEffect);
					setParticularEffectOfTroop(troop,effectType,targetEffect);
				}
			}
			else
			{
				if(targetEffect)
				{
					targetEffect.isBusy = false;
					if(troop.componentsLayer.contains(targetEffect))
					{
						troop.componentsLayer.removeChild(targetEffect);
					}
					setParticularEffectOfTroop(troop,effectType,null);
				}
			}
			return targetEffect;
		}
		
		/**
		 * 获得单个的加在troop身上的特效 
		 * @param troopInfo
		 * @param type
		 * @return 
		 */
		public static function getSomeParticularEffect(troopInfo:CellTroopInfo,type:String):BattleEffectObjBase
		{
			if(troopInfo == null || !troopInfo.effectObjBasesAddedToTroop.hasOwnProperty(type))
				return null;
			var tempObj:BattleEffectObjBase = troopInfo.effectObjBasesAddedToTroop[type] as BattleEffectObjBase;
			if(tempObj && (troopInfo.contains(tempObj) || troopInfo.componentsLayer.contains(tempObj)))
				return tempObj;
			return null;
		}
		
		/**
		 * 设置某个troop中的单个特效 
		 * @param troopInfo
		 * @param type
		 */
		public static function setParticularEffectOfTroop(troopInfo:CellTroopInfo,type:String,effect:BattleEffectObjBase):void
		{
			if(troopInfo == null || effect == null)
				return;
			troopInfo.effectObjBasesAddedToTroop[type] = effect;
		}
		
		/**
		 * 播放奥义等待或者播放时候脚底的特效 
		 * @param troopInfo
		 * @param show
		 * @param playOnece
		 */
		public static function showAoYoBottomEffect(troopInfo:CellTroopInfo,effectType:String,show:Boolean,playOnce:Boolean = false):void
		{
			return;
			if(troopInfo == null)
				return;
			var targetResId:int = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_GuangQuan);
			if(effectType == EffectsAddedToTroopDefine.aoyiWaitEffect)
			{
				targetResId = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_GuangQuan);
			}
			else if(effectType == EffectsAddedToTroopDefine.aoyiJiaodiEffect)
			{
//				if(troopInfo.isPlayerHero)
//				{
//					targetResId = WeaponGenedEffectConfig.getAoyibottomeffect(troopInfo.avatarShowObj.avatarConfig);
//				}
//				else
//				{
//					targetResId = TroopActConfig.getAoyibottomeffect(troopInfo.mcIndex);
//				}
				return;
			}
			if(show)
			{
				var tempEffect:BattleEffectObjSWF = showEffectOnFeetDown(troopInfo,effectType,targetResId,true) as BattleEffectObjSWF;
				troopInfo.componentsLayer.addChildAt(tempEffect,0);
				tempEffect.playOnce = playOnce;
			}
			else
			{
				showEffectOnFeetDown(troopInfo,effectType,targetResId,false);
			}
		}
		
	}
}