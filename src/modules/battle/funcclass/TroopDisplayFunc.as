 package modules.battle.funcclass
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import animator.animatorengine.AnimatorData;
	import animator.animatorengine.AnimatorDefine;
	import animator.animatorengine.AnimatorEngine;
	import animator.animatorengine.AnimatorPlayerSwfBmpMix;
	import animator.resourceengine.ResType;
	
	import effects.BattleEffectObjBase;
	import effects.BattleResourcePool;
	
	import macro.ActionDefine;
	import macro.ArmType;
	import macro.BattleDisplayDefine;
	
	import modules.battle.battleconfig.BattleEffectIdConfig;
	import modules.battle.battledefine.BattleCompDefine;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.BattleValueDefine;
	import modules.battle.battledefine.EffectShowTypeDefine;
	import modules.battle.battledefine.EffectsAddedToTroopDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.managers.BattleEffectPosFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.stage.BattleStage;
	
	import synchronousLoader.BattleResourceCopy;
	import synchronousLoader.GameResourceManager;
	import synchronousLoader.LoadUnit;
	import synchronousLoader.ResourceConfig;
	import synchronousLoader.ResourcePool;
	
	import uipacket.previews.PreviewAnimator;
	
	import utils.BattleEffectConfig;
	import utils.TroopActConfig;
	import utils.TroopFrameConfig;

	public class TroopDisplayFunc
	{
		
		public static var effectPlayerIdArr:Array=[];
		
		public function TroopDisplayFunc()
		{
		}
		
		/**
		 * 播放英雄攻击时候的特效 
		 * @param sourceTroop
		 * @param targetTroop
		 * @param chainInfo
		 * @param heroEffectResId
		 * @param normalTargets
		 * @param hasZhengDuiMuBiao
		 */
		public static function playHeroAttackEffect(sourceTroop:CellTroopInfo,targetTroop:CellTroopInfo,chainInfo:Array,heroEffectResId:int,
													normalTargets:Array,hasZhengDuiMuBiao:Boolean,singleEffectResId:int,targetCell:Cell):void
		{
			var zhengduimubiaoChain:Array=[];
			var feiZhengDuiMuBiaoChain:Array=[];				//完全不在非正对目标列表中的目标
			var skillChainArr:Array=[];
			
			var firstOne:Boolean = true;
			var allLogicFrame:Array;
			var singleFrame:int = 0;
			var effectObj:BattleEffectObjBase;
			var effectPos:Point;
			var actionArr:Array;
			
			var targetObj:Object={};
			for each(var singleTarget:CellTroopInfo in normalTargets)
			{
				if(singleTarget)
				{
					targetObj[singleTarget.troopIndex] = 1;
				}
			}
			
			var singleChain:CombatChain;
			for(var i:int = 0; i < chainInfo.length;i++)
			{
				singleChain = chainInfo[i] as CombatChain;
				if(singleChain == null)
					continue;
				if(targetObj.hasOwnProperty(singleChain.defTroopIndex))
				{
					if(hasZhengDuiMuBiao)
					{
						zhengduimubiaoChain.push(singleChain);
					}
					else
					{
						feiZhengDuiMuBiaoChain.push(singleChain);
					}
				}
				else
				{
					if(SkillEffectFunc.checkCanBeEvade(singleChain))
					{
						feiZhengDuiMuBiaoChain.push(singleChain);
					}
					else
					{
						skillChainArr.push(singleChain);
					}
				}
//				if(singleChain.isSkillAtk && !targetObj.hasOwnProperty(singleChain.defTroopIndex))						//此时必然不是附加攻击的目标
//				{
//					skillChainArr.push(singleChain);
//					continue;
//				}
			}
			
			var tempPlayerId:String = "";
			
			var hasAddDamageDispatchFrame:Boolean = false;
			firstOne = true;
			if(hasZhengDuiMuBiao)			//有波的情形，只有一个chain会播放此波
			{
				if(heroEffectResId > 0)
				{
					effectObj = BattleResourcePool.getFreeResourceUnit(heroEffectResId);
					if(effectObj == null)
						return;
					
					effectObj.playOnce = true;
					
					effectPos = TroopFunc.getTroopBasePos(targetTroop); 
					
					actionArr = BattleEffectConfig.getTotalActionForRes(heroEffectResId);
					TroopFunc.adjustEffectPosOnY(targetTroop,effectPos,targetCell);
					tempPlayerId = AnimatorEngine.addPlayOnceBattleEffectPlayer(ResourceConfig.getPureUrlById(heroEffectResId),
						effectObj,actionArr,BattleStage.instance.effectLayer,effectPos.x,effectPos.y,0,-1,false,AnimatorDefine.Battle_Player);
					
					tempPlayerId = addPalyOnceEffectFunc(effectObj,BattleStage.instance.effectLayer,effectPos.x,effectPos.y);
					
					if(tempPlayerId)
					{
						AnimatorEngine.setPlayerMirror(tempPlayerId,sourceTroop.ownerSide == BattleDefine.firstAtk);
						AnimatorEngine.showPlayer(tempPlayerId,false);
						AnimatorEngine.stopPlayer(tempPlayerId);
						
						effectPlayerIdArr.push(tempPlayerId);
					}
				}
				
				allLogicFrame = BattleEffectConfig.getAllLogiccalFrames(heroEffectResId);
				
				for(i = 0;i < zhengduimubiaoChain.length;i++)
				{
					singleChain = zhengduimubiaoChain[i] as CombatChain;
					
//					if(singleChain.isSkillAtk)
//						continue;
					
					for each(singleFrame in allLogicFrame)
					{
						AnimatorEngine.addHandlerForPlayer(tempPlayerId,singleFrame,sourceTroop.dispatchDamageArriveEvent,
							[singleFrame,singleChain.atkTroopIndex,singleChain.defTroopIndex],1);
					}
					if(firstOne)
					{
						if(BattleManager.aoyiManager.isHeroGonnaPlayAoYi(sourceTroop))
						{
							BattleManager.aoyiManager.showAoYiEffect(sourceTroop);
							singleChain.makeChainWork(null,true,tempPlayerId,true);
						}
						else
						{
							singleChain.makeChainWork(null,true,tempPlayerId,false);
						}
						firstOne = false;
						hasAddDamageDispatchFrame = true;
					}
					else
					{
						if(BattleManager.aoyiManager.isHeroGonnaPlayAoYi(sourceTroop))
						{
							singleChain.makeChainWork(null,false,tempPlayerId,true);
						}
						else
						{
							singleChain.makeChainWork(null,false,tempPlayerId,false);
						}
					}
				}
			}
			
			//不在正对目标的chain中，即没有正对目标
			firstOne = true;
			allLogicFrame = BattleEffectConfig.getAllLogiccalFrames(singleEffectResId);
			for(i = 0;i < feiZhengDuiMuBiaoChain.length;i++)				
			{
				singleChain = feiZhengDuiMuBiaoChain[i] as CombatChain;
				
//				if(singleChain.isSkillAtk)
//					continue;
				
				effectObj = BattleResourcePool.getFreeResourceUnit(singleEffectResId);
				if(effectObj == null)
					continue;
				
				effectObj.playOnce = true;
				
				effectPos = SkillEffectFunc.getEffectPos(singleChain.targettroop,false,singleEffectResId,false,singleChain.sourceTroop);
				
				TroopFunc.adjustEffectPosOnY(singleChain.targettroop,effectPos);
				actionArr = BattleEffectConfig.getTotalActionForRes(singleEffectResId);
				tempPlayerId = AnimatorEngine.addPlayOnceBattleEffectPlayer(ResourceConfig.getPureUrlById(singleEffectResId),
					effectObj,actionArr,BattleStage.instance.effectLayer,effectPos.x,effectPos.y,0,-1,false,AnimatorDefine.Battle_Player);
				
				tempPlayerId = addPalyOnceEffectFunc(effectObj,BattleStage.instance.effectLayer,effectPos.x,effectPos.y);
				
				if(singleChain.targettroop.ownerSide == BattleDefine.firstAtk)
					effectObj.scaleX = -1;
				
				if(tempPlayerId)
				{
					AnimatorEngine.showPlayer(tempPlayerId,false);
					AnimatorEngine.stopPlayer(tempPlayerId);
					
					effectPlayerIdArr.push(tempPlayerId);
				}
				
				for each(singleFrame in allLogicFrame)		
				{
					AnimatorEngine.addHandlerForPlayer(tempPlayerId,singleFrame,sourceTroop.dispatchDamageArriveEvent,
						[singleFrame,singleChain.atkTroopIndex,singleChain.defTroopIndex],1);
				}
				if(BattleManager.aoyiManager.isHeroGonnaPlayAoYi(sourceTroop))
					singleChain.makeChainWork(null,firstOne,tempPlayerId,true);			//每个chain都需要播放效果
				else
					singleChain.makeChainWork(null,firstOne,tempPlayerId,false);			//每个chain都需要播放效果
				sourceTroop.addMcFrameHandler(ActionDefine.Action_Dazhao,[singleChain.atkTroopIndex,singleChain.defTroopIndex,tempPlayerId],true);
			}
			
			allLogicFrame = BattleEffectConfig.getAllLogiccalFrames(BattleValueDefine.nonFuJiaAttackEffect);
			for each(singleChain in skillChainArr)
			{
				effectObj = BattleResourcePool.getFreeResourceUnit(BattleValueDefine.nonFuJiaAttackEffect);
				if(effectObj == null)
					continue;
				effectObj.playOnce = true;
				
				effectPos = SkillEffectFunc.getEffectPos(singleChain.targettroop,false,singleEffectResId,false,singleChain.sourceTroop);
				
				TroopFunc.adjustEffectPosOnY(singleChain.targettroop,effectPos,targetCell);
				tempPlayerId = AnimatorEngine.addPlayOnceBattleEffectPlayer(ResourceConfig.getPureUrlById(BattleValueDefine.nonFuJiaAttackEffect),
					effectObj,actionArr,BattleStage.instance.effectLayer,effectPos.x,effectPos.y,0,-1,false,AnimatorDefine.Battle_Player);
				
				tempPlayerId = addPalyOnceEffectFunc(effectObj,BattleStage.instance.effectLayer,effectPos.x,effectPos.y);
				
				if(singleChain.targettroop.ownerSide == BattleDefine.firstAtk)
					effectObj.scaleX = -1;
				
				for each(singleFrame in allLogicFrame)
				{
					AnimatorEngine.addHandlerForPlayer(tempPlayerId,singleFrame,sourceTroop.dispatchDamageArriveEvent,
						[singleFrame,singleChain.atkTroopIndex,singleChain.defTroopIndex],1);
				}
				
				singleChain.makeChainWork(null,false,tempPlayerId);
			}
		}
		
		/**
		 * 播放法师攻击的特效 
		 * @param sourceTroop
		 * @param targetTroop
		 */
		public static function playMagicMachineAttackEffects(sourceTroop:CellTroopInfo,chainInfo:Array):Boolean
		{
			var targetEffectResId:int;
			if(sourceTroop.attackUnit.armtype == ArmType.magic)
			{
				targetEffectResId = TroopActConfig.getMagicEffect(sourceTroop.mcIndex);
			}
			else
			{
				targetEffectResId = TroopActConfig.getMachineEffect(sourceTroop.mcIndex)
			} 
			if(targetEffectResId <= 0)
			{
				trace(sourceTroop.mcIndex,"找不到魔法攻击特效,troopIndex为:",sourceTroop.troopIndex);
				return false;
			}
			
			var firstOne:Boolean = true;
			
			var allLogicFrame:Array = BattleEffectConfig.getAllLogiccalFrames(targetEffectResId);
			
			var singleChainInfo:CombatChain;
			for(var i:int = 0; i < chainInfo.length;i++)
			{
				singleChainInfo = chainInfo[i];
				if(singleChainInfo == null)
					continue;
				var containsDamage:Boolean = SkillEffectFunc.checkCanBeEvade(singleChainInfo);
				if(!singleChainInfo.isSkillAtk || containsDamage)			//每个简单的普通攻击播放简单特效  对于包含伤害的值也播放特效
				{
					var effectObj:BattleEffectObjBase = BattleResourcePool.getFreeResourceUnit(targetEffectResId);
					if(effectObj == null)
						continue;
					
					effectObj.playOnce = true;
					
					var effectPos:Point = SkillEffectFunc.getEffectPos(singleChainInfo.targettroop,false,targetEffectResId,false,singleChainInfo.sourceTroop);
					
					var actionArr:Array = BattleEffectConfig.getTotalActionForRes(targetEffectResId);
					TroopFunc.adjustEffectPosOnY(singleChainInfo.targettroop,effectPos);
					var tempPlayerId:String = AnimatorEngine.addPlayOnceBattleEffectPlayer(ResourceConfig.getPureUrlById(targetEffectResId),
						effectObj,actionArr,BattleStage.instance.effectLayer,effectPos.x,effectPos.y,0,-1,false,AnimatorDefine.Battle_Player);

					tempPlayerId = addPalyOnceEffectFunc(effectObj,BattleStage.instance.effectLayer,effectPos.x,effectPos.y);
					
					if(singleChainInfo.targettroop.ownerSide == BattleDefine.firstAtk)
						effectObj.scaleX = -1;
					if(tempPlayerId)
					{
						AnimatorEngine.showPlayer(tempPlayerId,false);
						AnimatorEngine.stopPlayer(tempPlayerId);
						
						effectPlayerIdArr.push(tempPlayerId);
					}
					
					for each(var singleFrame:int in allLogicFrame)
					{
						AnimatorEngine.addHandlerForPlayer(tempPlayerId,singleFrame,sourceTroop.dispatchDamageArriveEvent,
							[singleFrame,singleChainInfo.atkTroopIndex,singleChainInfo.defTroopIndex],1);
					}
					singleChainInfo.makeChainWork(null,firstOne,tempPlayerId);
					if(firstOne)	
					{
						firstOne = false;				//处理如果有暴击情形
					}
				}
				else
				{
					singleChainInfo.makeChainWork(null,false);
				}
			}
			return true;
		}
		
		/**
		 * 播放boss攻击效果  (小兵发动技能攻击效果)
		 */
		public static function playBossAttackEffect(sourceTroop:CellTroopInfo,effectid:int,chainInfo:Array):void
		{
			var firstOne:Boolean = true;
			
			var allLogicFrame:Array = BattleEffectConfig.getAllLogiccalFrames(effectid);
			
			var singleChainInfo:CombatChain;
			var tempPlayerId:String = "";
			for(var i:int = 0; i < chainInfo.length;i++)
			{
				singleChainInfo = chainInfo[i];
				if(singleChainInfo == null)
					continue;
				if(SkillEffectFunc.checkCanBeEvade(singleChainInfo))			//每个简单的普通攻击播放简单特效
				{
					singleChainInfo.maxAttackTimes = BattleEffectConfig.getAttackTimesOfEffect(effectid);
					
					if(firstOne)
					{
						var effectObj:BattleEffectObjBase = BattleResourcePool.getFreeResourceUnit(effectid);
						if(effectObj == null)
							continue;
						
						effectObj.playOnce = true;
						
						var effectPos:Point = SkillEffectFunc.getEffectPos(singleChainInfo.targettroop,false,effectid,false,singleChainInfo.sourceTroop);
						
						var actionArr:Array = BattleEffectConfig.getTotalActionForRes(effectid);
						TroopFunc.adjustEffectPosOnY(singleChainInfo.targettroop,effectPos);
						tempPlayerId = AnimatorEngine.addPlayOnceBattleEffectPlayer(ResourceConfig.getPureUrlById(effectid),
							effectObj,actionArr,BattleStage.instance.effectLayer,effectPos.x,effectPos.y,0,-1,false,AnimatorDefine.Battle_Player);
						
						tempPlayerId = addPalyOnceEffectFunc(effectObj,BattleStage.instance.effectLayer,effectPos.x,effectPos.y);
						
						if(tempPlayerId && tempPlayerId != "")
						{
							AnimatorEngine.showPlayer(tempPlayerId,false);
							AnimatorEngine.stopPlayer(tempPlayerId);
							effectPlayerIdArr.push(tempPlayerId);
						}
						singleChainInfo.makeChainWork(null,firstOne,tempPlayerId,false,false,true);
					}
					else
					{
						singleChainInfo.makeChainWork(null,firstOne,"",false,false,true);
					}
					
					for each(var singleFrame:int in allLogicFrame)
					{
						AnimatorEngine.addHandlerForPlayer(tempPlayerId,singleFrame,sourceTroop.dispatchDamageArriveEvent,
							[singleFrame,singleChainInfo.atkTroopIndex,singleChainInfo.defTroopIndex],1);
					}
					
					if(firstOne)	
					{
						firstOne = false;				//处理如果有暴击情形
					}
				}
				else
				{
					singleChainInfo.makeChainWork(null,false,"",false,false,true,true);
				}
			}
		}
		
		/**
		 * 获得某个troop对应的资源路径ID 
		 * @param troopInfo				对应的troop信息
		 */
		private static function addMcToTroop(troopInfo:CellTroopInfo):void
		{
			if(troopInfo == null || troopInfo.attackUnit == null)
				return;
			
			var resStr:String;
			var tempUnit:LoadUnit;
			
			var showAvatar:Boolean = false;
			var showHero:Boolean = false;
			
			if(troopInfo.isHero)
			{
				if(!troopInfo.troopVisibleOnBattle)
				{
					troopInfo.visible = false;
					return;
				}
				
				if(troopInfo.isPlayerHero)		//如果是玩家自己的英雄
				{
					showAvatar = true;
				}
				else if(troopInfo.isHero)
				{
					showHero = true;
					tempUnit = ResourceConfig.getSingleResConfigById(troopInfo.attackUnit.effectid);
				}
				else
				{
					tempUnit = ResourceConfig.getSingleResConfigById(troopInfo.attackUnit.effectid);
					if(tempUnit)
						resStr = tempUnit.m_path;
				}
			}
			else
			{
				tempUnit = ResourceConfig.getSingleResConfigById(troopInfo.attackUnit.effectid);
				if(tempUnit)
					resStr = tempUnit.m_path;
			}
			
			var offsetValue:Point;
			
			showAvatar = false;
			
			if(showHero)
			{
				if(tempUnit == null)
					return;
				offsetValue = TroopActConfig.getStartPos(tempUnit.id);
				if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi || BattleManager.instance.battleMode == BattleModeDefine.PVE_Raid 
				|| BattleModeDefine.isDarenFuBen())
				{
					offsetValue.y -= (troopInfo.cellsCountNeed.y - 1) * (-10 - BattleDisplayDefine.cellGapVertocal);
				}
				troopInfo.startPos = offsetValue;
				
				troopInfo.mcIndex = tempUnit.id;
				if(troopInfo.heroShowObj == null)
				{
					troopInfo.heroShowObj = new AnimatorPlayerSwfBmpMix();
					troopInfo.heroShowObj.selfSceneType = AnimatorDefine.Battle_Player;
					troopInfo.heroShowObj.isUseInBattle = true;
				}
				else
				{
					troopInfo.heroShowObj.clearData(false);
				}
				troopInfo.heroShowObj.initCompleteData(troopInfo.mcIndex,troopInfo.mirrorLayer);
			}
			else
			{
				if(tempUnit == null)
					return;
				
				offsetValue = TroopActConfig.getStartPos(tempUnit.id);
				if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi || BattleModeDefine.isDarenFuBen() || BattleModeDefine.isGeneralRaid)
				{
					offsetValue.y -= (troopInfo.cellsCountNeed.y - 1) * (-10 - BattleDisplayDefine.cellGapVertocal);
				}
				troopInfo.startPos = offsetValue;
				if(tempUnit.m_type == ResType.ANIMATOR)
				{
					if(ResourcePool.hasSomeRes(resStr))
					{
						troopInfo.mcIndex = tempUnit.id;
						
						var animatorData:AnimatorData = BattleResourceCopy.getSingleAnimaorInfo(resStr);
						troopInfo.troopPlayerId = AnimatorEngine.addPlayerByCopyData(troopInfo.mirrorLayer,resStr,offsetValue.x,offsetValue.y,ActionDefine.Action_Idle,-1,true,AnimatorDefine.Battle_Player);
					}
				}
				else if(tempUnit.m_type == ResType.REFLECT_SWF)
				{
					var normalSwf:MovieClip = ResourcePool.getReflectSwf(tempUnit.m_path);
					var singleConfig:Array = TroopFrameConfig.getTotalActionForRes(int(tempUnit.id));
					troopInfo.mcIndex = int(tempUnit.id);
					troopInfo.troopPlayerId = AnimatorEngine.addSwfPlayer(normalSwf,singleConfig,troopInfo.mirrorLayer,offsetValue.x,offsetValue.y,ActionDefine.Action_Idle,-1,true,AnimatorDefine.Battle_Player);
				}
			}
			
			if(showAvatar)					//avatar镜像正好相反
			{
				if(troopInfo.ownerSide == BattleDefine.secondAtk)
				{
					troopInfo.mirrorLayer.scaleX = -1;
					troopInfo.mirrorLayer.x = BattleDisplayDefine.cellWidth;
				}
			}
			else
			{
				if(troopInfo.ownerSide == BattleDefine.firstAtk)
				{
					troopInfo.mirrorLayer.scaleX = -1;
					troopInfo.mirrorLayer.x = BattleDisplayDefine.cellWidth;
				}
			}
			
		}
		
		/**
		 * 初始化显示信息 
		 * @param troopInfo
		 */
		public static function initShowInfo(troopInfo:CellTroopInfo):void
		{
			if(troopInfo == null)
				return;
			if(troopInfo.mirrorLayer.numChildren > 0)			//理论上这一步不会走到
			{
				TroopInitClearFunc.clearTroopCharacterShowInfo(troopInfo);
			}
			addMcToTroop(troopInfo);
			troopInfo.initViewInfo();
			GameResourceManager.eventHandler.removeEventListener(troopInfo.mcIndex.toString(),troopInfo.singleBackLoadAnimatorLoaded);
			if(troopInfo.isHero)
			{
				GameResourceManager.eventHandler.removeEventListener((troopInfo.mcIndex * ResourceConfig.swfIdMapValue).toString(),troopInfo.singleBackLoadAnimatorLoaded);
			}
		}
		
		/**
		 * 显示长时间显示的icon
		 * @param troop
		 * @param resType
		 */
		public static function showContinuousEffectIcons(troop:CellTroopInfo,effect:BattleSingleEffect):void
		{
			if(troop == null || troop.isHero)					//hero troop不能增加buff
				return;
			troop.iconSlots.addnewEffectIcon(effect);
		}
		
		public static function showAllArmSupplyEffect(show:Boolean):void
		{
			return;
			var allTroops:Array = BattleUnitPool.getTroopsOfSomeSide(BattleDefine.firstAtk);
			for(var i:int = 0;i < allTroops.length;i++)
			{
				var singleTroop:CellTroopInfo = allTroops[i];
				if(singleTroop == null)
				{
					continue;
				}
				if(show)
				{
					if(singleTroop.logicStatus == LogicSatusDefine.lg_status_dead)
						continue;
					TroopDisplayFunc.showArmSupplyeInfo(singleTroop,true);
				}
				else
				{
					TroopDisplayFunc.showArmSupplyeInfo(singleTroop,false);
				}
			}
		}
		
		/**
		 *  显示小卡片
		 * @param troop					troop
		 * @param show					是否显示
		 */
		public static function showSmallCard(troop:CellTroopInfo,show:Boolean):void
		{
			if(troop == null)
				return;
			var targetEffect:BattleEffectObjBase = TroopEffectDisplayFunc.getSomeParticularEffect(troop,EffectsAddedToTroopDefine.waitCardEffect);
			if(show)
			{
				if(targetEffect && troop.bottomLayer.contains(targetEffect))
				{
					troop.bottomLayer.removeChild(targetEffect);
					targetEffect.isBusy = false;
				}
				targetEffect = BattleResourcePool.getFreeResourceUnit(BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_XiaoKaPian));
				if(targetEffect)
				{
					var targetScale:int = 0;
					targetScale = troop.cellsCountNeed.x;
					
					var pos:Point = BattleEffectPosFunc.getTroopDownPos(troop);
					targetEffect.x = pos.x;
					targetEffect.y = pos.y;
					
					targetEffect.scaleX = targetScale;
					targetEffect.scaleY = 1;
					targetEffect.isBusy = true;
					troop.bottomLayer.addChildAt(targetEffect,0);
					TroopEffectDisplayFunc.setParticularEffectOfTroop(troop,EffectsAddedToTroopDefine.waitCardEffect,targetEffect);
				}
			}
			else
			{
				if(targetEffect)
				{
					targetEffect.isBusy = false;
					if(troop.bottomLayer.contains(targetEffect))
					{
						troop.bottomLayer.removeChild(targetEffect);
					}
				}
			}
		}
		
		/**
		 * 显示脚底下armsupply的效果 
		 * @param troop
		 * @param show
		 */
		public static function showArmSupplyeInfo(troop:CellTroopInfo,show:Boolean):void
		{
			if(troop == null)
				return;
			var targetEffect:BattleEffectObjBase = TroopEffectDisplayFunc.getSomeParticularEffect(troop,EffectsAddedToTroopDefine.waitCardEffect);
			if(show)
			{
				if(targetEffect && troop.contains(targetEffect))
				{
					troop.removeChild(targetEffect);
					targetEffect.isBusy = false;
				}
				targetEffect = BattleResourcePool.getFreeResourceUnit(BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_ArmSupply));
				if(targetEffect)
				{
					var targetScale:int = 0;
					targetScale = troop.cellsCountNeed.x;
					
					var pos:Point = BattleEffectPosFunc.getTroopDownPos(troop);
					targetEffect.x = pos.x;
					targetEffect.y = pos.y;
					
					targetEffect.scaleX = targetScale;
					targetEffect.scaleY = 1;
					targetEffect.isBusy = true;
					troop.addChildAt(targetEffect,0);
					TroopEffectDisplayFunc.setParticularEffectOfTroop(troop,EffectsAddedToTroopDefine.waitCardEffect,targetEffect);
				}
			}
			else
			{
				if(targetEffect)
				{
					targetEffect.isBusy = false;
					if(troop.contains(targetEffect))
					{
						troop.removeChild(targetEffect);
					}
				}
			}
		}
		
		/**
		 * 播放奥义时，隐藏不相干的troop 
		 * @param atkSide
		 * @param show
		 */
		public static function makeUnInvolvedTroopHideOnAoYi(targets:Array,atkTroop:CellTroopInfo):void
		{
			if(targets == null || targets.length <= 0)
				return;
			var troopObj:Object={};
			var singleTroop:CellTroopInfo;
			for each(singleTroop in targets)
			{
				if(singleTroop == null)
					continue;
				troopObj[singleTroop.troopIndex] = singleTroop;
			}
			troopObj[atkTroop.troopIndex] = atkTroop;
			BattleInfoSnap.hidedTroopOnAoYi = new Dictionary;
			var allTroopinfo:Array = BattleUnitPool.getAllTroops();
			for each(singleTroop in allTroopinfo)
			{
				if(singleTroop == null)
					continue;
				if(!troopObj.hasOwnProperty(singleTroop.troopIndex))
				{
					if(singleTroop.visible)
					{
						BattleInfoSnap.hidedTroopOnAoYi[singleTroop] = 1;
						singleTroop.visible = false;
					}
				}
			}
			var nextWaveObj:Object = BattleUnitPool.nextWaveTroopPoolInfo;
			if(nextWaveObj)
			{
				for each(singleTroop in nextWaveObj)
				{
					if(singleTroop == null)
						continue;
					if(singleTroop.isHero && !singleTroop.troopVisibleOnBattle)
						continue;
					if(singleTroop.visible)
					{
						BattleInfoSnap.hidedTroopOnAoYi[singleTroop] = 1;
						singleTroop.visible = false;
					}
				}
			}
		}
		
		/**
		 * 降低alpha 
		 * @param targets
		 */
		public static function makeAoyiTargetAlphaDown(targets:Array):void
		{
//			return;
			BattleInfoSnap.alphaDownTroops = new Dictionary; 
			var troopInfo:CellTroopInfo;
			for(var i:int = 0;i < targets.length;i++)
			{
				troopInfo = targets[i] as CellTroopInfo;
				if(troopInfo == null)
					continue;
				BattleInfoSnap.alphaDownTroops[troopInfo] = 1;
				troopInfo.alpha = BattleDisplayDefine.troopAlphaBeAoYiAttacked;
			}
		}
		
		/**
		 *  恢复alpha值
		 */
		public static function remumeTargetAlpha():void
		{
//			return;
			var targetObj:Object = BattleInfoSnap.alphaDownTroops;
			var singleTroop:CellTroopInfo;
			for(var singleIndex:* in targetObj)
			{
				singleTroop = singleIndex as CellTroopInfo;
				if(singleTroop)
				{
					singleTroop.alpha = 1;
				}
			}
		}
		
		/**
		 * 让在奥义阶段播放被隐藏的troop恢复
		 */
		public static function resumeTroopHideOnAoYi():void
		{
			if(BattleInfoSnap.hidedTroopOnAoYi != null)
			{
				var targetObj:Object = BattleInfoSnap.hidedTroopOnAoYi;
				var singleTroop:CellTroopInfo;
				for(var singleIndex:* in targetObj)
				{
					singleTroop = singleIndex as CellTroopInfo;
					if(singleTroop)
					{
						if(!singleTroop.isHero && !singleTroop.troopVisibleOnBattle)
							continue;
						if(singleTroop.logicStatus != LogicSatusDefine.lg_status_dead)
							singleTroop.visible = true;
					}
				}
			}
			BattleInfoSnap.hidedTroopOnAoYi = new Dictionary;
		}
		
		public static function showSelfHeroGuideArrow(troopInfo:CellTroopInfo):void
		{
			if(troopInfo.selfHeroGuideArrow == null)
			{
				troopInfo.selfHeroGuideArrow = new PreviewAnimator();
				troopInfo.selfHeroGuideArrow.selfSceneType = AnimatorDefine.Battle_Player;
			}
			if(troopInfo.selfHeroGuideArrow)
			{
				troopInfo.selfHeroGuideArrow.y = BattleCompDefine.selfHeroGuideY;
				if(troopInfo.ownerSide == BattleDefine.firstAtk)
				{
					troopInfo.selfHeroGuideArrow.x = BattleCompDefine.selfHeroGuideX;
				}
				else
				{
					troopInfo.selfHeroGuideArrow.x = BattleCompDefine.seleHeroGuideXDefenseSide;
				}
				
				troopInfo.componentsLayer.addChild(troopInfo.selfHeroGuideArrow);
				troopInfo.selfHeroGuideArrow.setResid(2344);
			}
		}
		
		public static function addPalyOnceEffectFunc(effectObj:BattleEffectObjBase,parent:DisplayObjectContainer,posX:Number,eposY:Number):String
		{
			var tempPlayerId:String = effectObj.playerId;
			parent.addChild(effectObj);
			effectObj.x = posX;
			effectObj.y = eposY;
			return tempPlayerId;
		}
		
		/**
		 * 获得单个cell的位置 
		 * @param cellIndex
		 * @param isAtk
		 * @return 
		 */
		public static function getCellPos(cellIndex:int,isAtk:Boolean):Point
		{
			var realPositon:Point = new Point(0,0);
			var cellIndexPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(cellIndex);
			var displayIndexOnScene:Point = new Point(cellIndexPos.x,cellIndexPos.y);
			if(isAtk)
			{
				realPositon.x = BattleDisplayDefine.atkStartPos.x;
				realPositon.y = BattleDisplayDefine.atkStartPos.y;
				
				realPositon.x -= displayIndexOnScene.x * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
				realPositon.y += (displayIndexOnScene.y) * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal);
			}
			else
			{
				realPositon.x = BattleDisplayDefine.defStartPos.x;
				realPositon.y = BattleDisplayDefine.defStartPos.y;
				
				realPositon.x += displayIndexOnScene.x * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
				realPositon.y += (displayIndexOnScene.y) * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal);
			}
			return realPositon;
		}
		
		public static function showTroopSelectedEffect(troop:CellTroopInfo,showType:int):void
		{
			if(troop == null)
				return;
			if(showType == troop.curSelectedStatus)
				return;
			troop.curSelectedStatus = showType;
			if(showType == BattleDefine.Status_NoShow)
			{
				troop.graphics.clear();
			}
			else if(showType == BattleDefine.Status_Selected)
			{
				troop.graphics.clear();
				troop.graphics.lineStyle(1,0x00ff00,1);
				troop.graphics.beginFill(0x00ff00,0.3);
				if(troop.ownerSide == BattleDefine.secondAtk)
				{
					troop.graphics.drawRoundRect(0,0,troop.cellsCountNeed.x * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal),
						troop.cellsCountNeed.y * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal),5,5);
				}
				else
				{
					troop.graphics.drawRoundRect(0 - ((troop.cellsCountNeed.x - 1) * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal)),0,
						troop.cellsCountNeed.x * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal),
						troop.cellsCountNeed.y * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal),5,5);
				}
			}
			else if(showType == BattleDefine.Status_Default)
			{
				troop.graphics.clear();
				troop.graphics.lineStyle(1,0xffffff,1);
				troop.graphics.beginFill(0xffffff,0.3);
				if(troop.ownerSide == BattleDefine.secondAtk)
				{
					troop.graphics.drawRoundRect(0,0,troop.cellsCountNeed.x * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal),
						troop.cellsCountNeed.y * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal),5,5);
				}
				else
				{
					troop.graphics.drawRoundRect(0 - ((troop.cellsCountNeed.x - 1) * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal)),0,
						troop.cellsCountNeed.x * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal),
						troop.cellsCountNeed.y * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal),5,5);
				}
				
				troop.graphics.clear();
			}
			
			troop.graphics.endFill();
		}
		
	}
}