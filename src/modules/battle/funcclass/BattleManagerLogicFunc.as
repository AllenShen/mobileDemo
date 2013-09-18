package modules.battle.funcclass
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import defines.FormationSlotInfo;
	import defines.HeroDefines;
	import defines.UserArmInfo;
	import defines.UserHeroInfo;
	
	import eventengine.GameEventHandler;
	
	import macro.BattleCardTypeDefine;
	import macro.CommonEventTypeDefine;
	import macro.EventMacro;
	import macro.FormationElementType;
	
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.BattleValueDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battleevents.CheckAttackEvent;
	import modules.battle.battleevents.TroopDeadEvent;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.battlelogic.HangUpCombatChain;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.battlelogic.TroopMoveVerticalCheckInfo;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.stage.BattleStage;
	
	import synchronousLoader.ResourceConfig;
	
	import utils.TroopActConfig;

	/**
	 * 专门处理battlemanager具体复杂逻辑的类 
	 * @author SDD
	 */
	public class BattleManagerLogicFunc
	{
		
		private static var m_roungCheckTimer:Timer;
		private static var troopHangOutChains:Object={};
		
		public function BattleManagerLogicFunc()
		{
		}
		
		public static function sortEffection(paramA:CombatChain,paramB:CombatChain):int
		{
			if(paramA.atkTroopIndex < paramB.atkTroopIndex)				
				return -1;
			if(paramA.atkTroopIndex > paramB.atkTroopIndex)				
				return 1;
			if(paramA.isFanjiChain)
				return -1;
			if(paramB.isFanjiChain)
				return 1;
			if(paramA.chainIndex > paramB.chainIndex)
				return 1;
			return -1;
		}
		
		//检查是否可以补进
		public static function checkTroopDeadFill(troopInfo:CellTroopInfo = null,targetPowerSide:PowerSide = null):void
		{
			var powerSide:PowerSide;
			if(troopInfo != null)
			{
				powerSide = BattleFunc.getSidePowerInfoForTroop(troopInfo);
			}
			else
			{
				powerSide = targetPowerSide;
			}
			
			var moveGapInfo:Object = BattleFunc.seachFillUpTroops(powerSide);					//处理需要移动的过程
			
			var rowVerticalWithTroop:Object={};
			var hasTroopLeft:Boolean;
			for(var i:int = 0;i < powerSide.xMaxValue - 1;i++)
			{
				hasTroopLeft = BattleTargetSearcher.checkHasTroopAliveOnXValue(powerSide,i);
				if(hasTroopLeft)
				{
					rowVerticalWithTroop[i] = 1;
				}
			}
			BattleStage.instance.troopLayer.makeTroopMoveParticularGap(moveGapInfo,powerSide,troopInfo);
			var singleXValue:int = 0;
			var emptyRow:Array=[];
			for(var singleXValueKey:String in rowVerticalWithTroop)
			{
				singleXValue = int(singleXValueKey);
				hasTroopLeft = BattleTargetSearcher.checkHasTroopAliveOnXValue(powerSide,singleXValue);
				if(!hasTroopLeft)
				{
					emptyRow.push(singleXValue);
				}
			}
			if(emptyRow.length > 0)
			{
				var allTroopsOnVertical:Array=[];
				for(var singleIndex:int = 0;singleIndex < emptyRow.length;singleIndex++)
				{
					allTroopsOnVertical = allTroopsOnVertical.concat(BattleFunc.particularTroopsVertical(int(emptyRow[singleIndex]),powerSide));
				}
				var singleTroopInfo:CellTroopInfo;
				for(var singleTrooIndex:int = 0; singleTrooIndex < allTroopsOnVertical.length;singleTrooIndex++)
				{
					singleTroopInfo = allTroopsOnVertical[singleTrooIndex];
					if(singleTroopInfo == null || singleTroopInfo.logicStatus == LogicSatusDefine.lg_status_dead ||
						singleTroopInfo.attackUnit.slotType != FormationElementType.ARROW_TOWER)
						continue;
					BattleManager.instance.handlerTroopDead(new TroopDeadEvent(TroopDeadEvent.TROOPDEADEVENT,int(singleTroopInfo.troopIndex)));
				}
			}
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.refreshChoostTarget));
		}
		
		public static function makeArmSupplyWork():void					//全体加血
		{
			var allTroops:Array = BattleUnitPool.getTroopsOfSomeSide(BattleDefine.firstAtk);
			var curMaxHp:int;
			var hpAfterAdd:int;
			for(var i:int = 0;i < allTroops.length;i++)
			{
				var singleTroop:CellTroopInfo = allTroops[i];
				if(singleTroop == null || singleTroop.logicStatus == LogicSatusDefine.lg_status_dead || singleTroop.isHero || 
					!singleTroop.troopVisibleOnBattle)
				{
					continue;
				}
				curMaxHp = singleTroop.totalHpValue;
				hpAfterAdd = Math.min(singleTroop.totalHpOfSlot,curMaxHp + BattleValueDefine.armSupplyRatio * singleTroop.originalTotalHpValue);
				singleTroop.resolveDamageDisplayInfo(curMaxHp - hpAfterAdd,-1);
				TroopEffectDisplayFunc.showBattleCardEffect(singleTroop,BattleCardTypeDefine.shiBingBuChong);
			}
		}
		
		public static function battleEnterFrameHanlder(event:Event):void
		{
			BattleInfoSnap.curBattleFrame++;
			
			if(!BattleModeDefine.checkNeedServerData())
			{
				makeFaijiWaitChainWork();
				GameEventHandler.dispatchGameEvent(EventMacro.CommonEventHandler,new Event(CommonEventTypeDefine.Event_BattleStaggerFrame));
				return;
			}
			var oldDamageValue:Object = BattleInfoSnap.damageFrameHodler[BattleInfoSnap.curBattleFrame-1];
			if(oldDamageValue == null)
			{
				makeFaijiWaitChainWork();
				GameEventHandler.dispatchGameEvent(EventMacro.CommonEventHandler,new Event(CommonEventTypeDefine.Event_BattleStaggerFrame));
				return;
			}
			else
			{
				var chainInfo:Array=[];
				for(var singleChainKey:String in oldDamageValue)
				{
					if(oldDamageValue[singleChainKey] as CombatChain)
					{
						chainInfo.push(oldDamageValue[singleChainKey] as CombatChain);
					}
				}
				chainInfo.sort(BattleManagerLogicFunc.sortEffection);
				
				var i:int = 0;
				var allChainIndexInfo:Array = [];
				for(i = 0;i < chainInfo.length;i++)
				{
					var singleChainInfo2:CombatChain = chainInfo[i];
					if(singleChainInfo2 != null)
					{
						allChainIndexInfo.push(singleChainInfo2.atkTroopIndex);
					}
				}
				if(allChainIndexInfo.length > 0 && BattleManager.needTraceBattleInfo)
				{
					trace("在帧数 ",BattleInfoSnap.curBattleFrame," 执行chain伤害处理:",allChainIndexInfo);
				}
				for(i = 0;i < chainInfo.length;i++)
				{
					var singleChainInfo:CombatChain = chainInfo[i];
					if(singleChainInfo != null)
					{
						singleChainInfo.handlerDamageLogic();
					}
				}
			}
			makeFaijiWaitChainWork();
			GameEventHandler.dispatchGameEvent(EventMacro.CommonEventHandler,new Event(CommonEventTypeDefine.Event_BattleStaggerFrame));
		}
		
		public static function makeFaijiWaitChainWork():void
		{
			var allChains:Array = [];
			var chainsNeedToDelete:Array = [];
			for(var singleChainKey:String in BattleInfoSnap.needFanjiChains)
			{
				allChains.push(int(singleChainKey));
			}
			allChains.sort();
			var needToCheck:Boolean = false;
			for(var i:int = 0;i < allChains.length;i++)
			{
				needToCheck = true;
				var singleChainIndex:int = allChains[i];
				var targetChainInfo:CombatChain = BattleManager.instance.allChainInfo[singleChainIndex];
				if(targetChainInfo == null)
				{
					chainsNeedToDelete.push(singleChainIndex);
					continue;
				}
				var fanjiResult:int = targetChainInfo.makeFanjiChainWork(BattleInfoSnap.needFanjiChains[singleChainIndex]);
				if(fanjiResult == BattleDefine.fanjiChain_suc)
				{
					chainsNeedToDelete.push(singleChainIndex);
					if(BattleManager.needTraceBattleInfo)
						trace("checkCellCanAttack中成功反击成功 ",'反击者: ',targetChainInfo.atkTroopIndex,"被反击者: ",targetChainInfo.defTroopIndex," 当前帧数:",BattleInfoSnap.curBattleFrame);
				}
				if(fanjiResult == BattleDefine.fanjiChain_noNeed)
				{
					chainsNeedToDelete.push(singleChainIndex);
				}
				if(fanjiResult == BattleDefine.fanjiChain_fail)
				{
					if(BattleManager.needTraceBattleInfo)
						trace("checkCellCanAttack中成功反击失败 ",'反击者: ',targetChainInfo.atkTroopIndex,"被反击者: ",targetChainInfo.defTroopIndex," 当前帧数:",BattleInfoSnap.curBattleFrame);
				}
			}
			for(i = 0;i < chainsNeedToDelete.length;i++)
			{
				delete BattleInfoSnap.needFanjiChains[chainsNeedToDelete[i]];
			}
			if(needToCheck)
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
		}
		
		public static function clearChainsWaitsToWorkNextFrame(troopIndex:int):void
		{
			var oldDamageValue:Object = BattleInfoSnap.damageFrameHodler[BattleInfoSnap.curBattleFrame];
			if(oldDamageValue == null)
			{
				return;
			}
			for(var singleChainKey:String in oldDamageValue)
			{
				if(oldDamageValue[singleChainKey] as CombatChain)
				{
					var singleChain:CombatChain = oldDamageValue[singleChainKey] as CombatChain;
					if(singleChain && singleChain.defTroopIndex == troopIndex)
						oldDamageValue[singleChainKey] = null;
				} 
			}
		}
		
		/**
		 * 检查是否有英雄死亡导致需要补进的情形 
		 */
		public static function makeHeroDeadFill():void
		{
			var waitTime:int = 0;			//补进需要等待的时间
			
			var leftTempValue:TroopMoveVerticalCheckInfo = BattleManager.instance.pSideAtk.hasHorizonalMissTarget();
			var rightTempValue:TroopMoveVerticalCheckInfo = BattleManager.instance.pSideDef.hasHorizonalMissTarget(); 
			
			var leftSideHasDirectTarget:Boolean = leftTempValue.hastarget;
			var rightSideHasDirectTarget:Boolean = rightTempValue.hastarget;
			
			var leftTargetCrossed:Boolean = leftTempValue.targetcross;
			var rightTargetCrossed:Boolean = rightTempValue.targetcross;
			
			BattleManager.instance.startNewRound();
		}
		
		public static function addHangUpDamageChains(combatChainInfo:CombatChain):void
		{
			var hangUpObj:HangUpCombatChain = new HangUpCombatChain(combatChainInfo);
			var targetTroopIndex:int = combatChainInfo.defTroopIndex;
			var hostObj:Object;
			if(!troopHangOutChains.hasOwnProperty(targetTroopIndex))
			{
				troopHangOutChains[targetTroopIndex] ={};
			}
			hostObj = troopHangOutChains[targetTroopIndex];
			hostObj[combatChainInfo.chainIndex] = hangUpObj;
		}
		
		/**
		 * 处理某个troop移动结束触发挂起的伤害值 
		 * @param troopInfo
		 */
		public static function checkHangUpDamageChains(troopInfo:CellTroopInfo):void
		{
			if(troopInfo == null || troopInfo.logicStatus == LogicSatusDefine.lg_status_dead)
				return;
			if(!troopHangOutChains.hasOwnProperty(troopInfo.troopIndex))
				return;
			var allHangChains:Object = troopHangOutChains[troopInfo.troopIndex];
			var singleChainInfo:HangUpCombatChain;
			var allChainInfo:Array=[];
			for(var singleChainIdex:String in allHangChains)
			{
				allChainInfo.push(int(singleChainIdex));
			}
			allChainInfo.sort();
			for(var i:int = 0;i < allChainInfo.length;i++)
			{
				singleChainInfo = allHangChains[allChainInfo[i]];
				singleChainInfo.makeHangUpChainWork();
			}
		}
		
		public static function clearForSignleRound():void
		{
			troopHangOutChains ={};
		}
		
		public static function clearManagerLogic():void
		{
			if(m_roungCheckTimer)
			{
				m_roungCheckTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,BattleManager.instance.startNewRound);
				m_roungCheckTimer.stop();
				m_roungCheckTimer = null;
			}
			troopHangOutChains ={};
		}
		
		private static function getAllResourceByFormationInfo(sourceFomraion:Array):Array
		{
			var singleFormationSlot:FormationSlotInfo;
			var resNeedInfoId:Array = [];
			var contentArmInfo:UserArmInfo;
			var contentHeroInfo:UserHeroInfo;
			for(var i:int = 0;i < sourceFomraion.length;i++)
			{
				var singleLine:Array = sourceFomraion[i];
				for(var ii:int = 0;ii < singleLine.length;ii++)
				{
					singleFormationSlot = singleLine[ii];
					if(singleFormationSlot == null || singleFormationSlot.type == FormationElementType.NOTHING)
						continue;
					if(singleFormationSlot.type == FormationElementType.ARM)
					{
						contentArmInfo = singleFormationSlot.info as UserArmInfo;
						if(contentArmInfo)
							resNeedInfoId.push(contentArmInfo.effectid);
					}
					else if(singleFormationSlot.type == FormationElementType.HERO)
					{
						contentHeroInfo = singleFormationSlot.info as UserHeroInfo;
						if(contentHeroInfo)
						{
							if(contentHeroInfo.heroid != HeroDefines.userDefaultHero)
							{
								resNeedInfoId.push(contentHeroInfo.effectid);
								resNeedInfoId.push(contentHeroInfo.effectid * ResourceConfig.swfIdMapValue);
							}
						}
					}
				}
			}
			
			var allResNeedToLoad:Array = [];
			
			for(var index:int = 0;index < resNeedInfoId.length;index++)
			{
				var singleId:int = resNeedInfoId[index];
				allResNeedToLoad.push(singleId);
				allResNeedToLoad = allResNeedToLoad.concat(TroopActConfig.getAllEffectNeed(singleId));
			}
			
			allResNeedToLoad = allResNeedToLoad.concat(BattleUnitPool.tempResources);
			return allResNeedToLoad;
		}
		
		/**
		 * 获得玩家阵型所有资源 
		 * @return 
		 */
		public static function getAllResourceOfUserFormation():Array
		{
			return [];
		}
		
		/**
		 * 获得敌人阵型的所有资源
		 * @param foramationInfo
		 */
		public static function getEnemyResourceNeedToLoad(foramationInfo:Array):Array
		{
			var enemyInfo:Array = [];
			for(var i:int = 0;i < foramationInfo.length;i++)
			{
				enemyInfo = enemyInfo.concat(getAllResourceByFormationInfo(foramationInfo[i]));
			}
			return enemyInfo;
		}
		
		
	}
}