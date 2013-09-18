package modules.battle.managers
{
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import defines.UserBattleCardInfo;
	
	import eventengine.GameEventHandler;
	
	import macro.AttackRangeDefine;
	import macro.BattleCardTypeDefine;
	import macro.EventMacro;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlecomponent.DeadEnemyCycle;
	import modules.battle.battlecomponent.DeadEnemyProgressShow;
	import modules.battle.battlecomponent.NextSupplyShow;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.McStatusDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battleevents.CheckAttackEvent;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.funcclass.TroopEffectDisplayFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.stage.BattleStage;
	
	import sysdata.SkillElement;

	public class DemoManager
	{
		
		public static var usedArmIds:Object = {};
		public static var usedHeroIds:Array = [];
		
		public static var enemyUsedArmIds:Object = {};
		
		private static var starsWhenTimeRuning:Array = [];
		public static var gapTimer:Timer;
		
		
		private static var _curStage:int = 0;
		public static var curStageArmCount:int = 0;
		public static var armIndexInStage:int = 0;
		public static var curStageArmtypes:Array = [];
		
		public function DemoManager()
		{
		}
		
		public static function addSingleArmId(type:int,armResId:int):void
		{
			var curIdArr:Array = usedArmIds[type];
			if(curIdArr == null)
			{
				curIdArr = [];
				usedArmIds[type] = curIdArr;
			}
			
			if(curIdArr.indexOf(armResId) < 0)
				curIdArr.push(armResId);
		}
		
		public static function addSingleHeroId(heroId:int):void
		{
			if(usedHeroIds.indexOf(heroId) < 0)
				usedHeroIds.push(heroId);
		}
		
		public static function getSingleRandomId(supplyType:int):int
		{
			var allIds:Array = usedArmIds[supplyType];
			return allIds[int(allIds.length * Math.random())];
		}
		
		public static function getSingleRandomIdByEnemyType(supplyType:int):int
		{
			var allIds:Array = enemyUsedArmIds[supplyType];
			return allIds[int(allIds.length * Math.random())];
		}
		
		/**
		 * 处理troop被回收的情形
		 * @param sourceTroops
		 */
		public static function handleTroopBeCycled(sourceTroops:Array):void
		{
			if(sourceTroops == null || sourceTroops.length <= 0)
			{
				return;
			}
			var singleTroop:CellTroopInfo;
			for(var i:int = 0;i < sourceTroops.length;i++)
			{
				singleTroop = sourceTroops[i];
				if(singleTroop == null)
					continue;
				
				BattleInfoSnap.curForceDeadTroops.push(singleTroop);
				
//				if(Math.random() <= BattleDefine.geneCardPossibility)	
//				{
//					TroopEffectDisplayFunc.showBattleCardEffect(singleTroop,BattleCardTypeDefine.PaoJi);
//					BattleManager.cardManager.handleNewBattleCardGened(UserBattleCardInfo.makeOneFakeCardInfo());
//				}
				
				singleTroop.makeTroopForceDead();
				
//				DeadEnemyProgressShow.instance.handleSingleEnemyDead();
				DeadEnemyCycle.instance.handleSelfArmCycled();
			}
		}
		
		/**
		 * 处理troop索取某个资源，血量之类的
		 * @param sourceTroops
		 */
		public static function handleTroopAsk(sourceTroops:Array):void
		{
			if(sourceTroops == null || sourceTroops.length <= 0)
			{
				return;
			}
			var singleTroop:CellTroopInfo;
			for(var i:int = 0;i < sourceTroops.length;i++)	
			{
				singleTroop = sourceTroops[i];
				if(singleTroop == null)
					continue;
				
				var supplyeInfo:Array = NextSupplyShow.instance.getSingleHpSupplyInfo();
				if(supplyeInfo == null || supplyeInfo.length <= 0)
					continue;
				if(supplyeInfo[0] == NextSupplyShow.starSupplyTypeHP)
				{
					singleTroop.resolveDamageDisplayInfo(0-supplyeInfo[1],-1);
				}
			}
		}
		
		public static function makeEnemySupply():void
		{
//			if(BattleInfoSnap.MaxEnemySupplyCount <= 0)
//				return;
//			BattleInfoSnap.MaxEnemySupplyCount--;
			makeNextArmSupply(BattleDefine.secondAtk,0,0,0,false);
		}
		
		public static function handleSingleStarQualified(type:int,addValue:int,percent:Number):void
		{
			if(gapTimer && gapTimer.running)
			{
				starsWhenTimeRuning.push(type,addValue,percent);
				return;
			}
			NextSupplyShow.instance.handlerSingleStarQuilified(type,addValue,percent);
			if(NextSupplyShow.instance.isAllStarQualified)
			{
				if(BattleInfoSnap.MaxSelfSupplyCount > 0)
				{
					BattleInfoSnap.MaxSelfSupplyCount--;
					if(gapTimer == null)
					{
						gapTimer = new Timer(500,1);
						gapTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onGapTimerComplete);
						gapTimer.start();
					}
				}
				else if(NextSupplyShow.instance.supplyArmType == 1)
				{
					if(gapTimer == null)
					{
						gapTimer = new Timer(500,1);
						gapTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onGapTimerComplete);
						gapTimer.start();
					}
				}
			}
		}
		
		public static function onGapTimerComplete(event:TimerEvent):void
		{
			if(gapTimer && event)
			{
				gapTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onGapTimerComplete);
				gapTimer = null;
			}
			
			if(event == null && NextSupplyShow.instance.supplyArmType == 2)
			{
				BattleInfoSnap.needCheckStuckSupply = false;
				return;
			}
			
			var addResult:Boolean = makeNextArmSupply(BattleDefine.firstAtk,NextSupplyShow.instance.supplyArmType,
				NextSupplyShow.instance.supplyeArmResId,NextSupplyShow.instance.curSupplyType,false);
			
			if(!addResult)
			{
				//需要等待
				BattleInfoSnap.needCheckStuckSupply = true;
				return;
			}
			
			BattleInfoSnap.needCheckStuckSupply = false;
			
			var singleTroop:CellTroopInfo;
			while(BattleInfoSnap.curForceDeadTroops.length > 0)
			{
				singleTroop = BattleInfoSnap.curForceDeadTroops.shift();
				singleTroop.setDeadForcely();
				singleTroop = null;
			}
			NextSupplyShow.instance.showSingleSupplyInfo();
			
			while(starsWhenTimeRuning.length > 0)
			{
				NextSupplyShow.instance.handlerSingleStarQuilified(starsWhenTimeRuning.shift(),starsWhenTimeRuning.shift(),starsWhenTimeRuning.shift());
				if(NextSupplyShow.instance.isAllStarQualified)
				{
					if(gapTimer == null)
					{
						gapTimer = new Timer(0.5,1);
						gapTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onGapTimerComplete);
						gapTimer.start();
					}
					break;
				}
			}
			
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
		}
		
		/**
		 * 补进下一个
		 */
		public static function makeNextArmSupply(side:int,armType:int,resId:int,supplyType:int,forceDirect:Boolean,forceaddHero:Boolean = false):Boolean
		{
			
			if(BattleManager.instance.status != OtherStatusDefine.battleOn)
				return false;
			
			var i:int = 0;
			var hasReboredTroop:Boolean = false;
			
			var sourceSide:PowerSide;
			if(side == BattleDefine.firstAtk)
				sourceSide = BattleManager.instance.pSideAtk;
			else
				sourceSide = BattleManager.instance.pSideDef;
			
			var allDeadTroopsCanAlive:Array = [];
			var hasArmSupplyRecord:Object = {};
			
			var curMinLiveCount:int = -1;
			var liveTroopCountRecord:Array = [];
			
			var herotroops:Array = sourceSide.allHeroInfoOnSide;
			var realHeroes:Array = [];
			var singleTroop:CellTroopInfo;
			//渠道当前最小的活着的troop个数
			for(var hIndex:int = 0;hIndex < herotroops.length;hIndex++)
			{
				singleTroop = herotroops[hIndex];
//				if(singleTroop.logicStatus != LogicSatusDefine.lg_status_dead && singleTroop.logicStatus != LogicSatusDefine.lg_status_hangToDie)
				{
					realHeroes.push(singleTroop);
					var liveCount:int = BattleTargetSearcher.getTroopOccupiedCellCount(singleTroop,sourceSide);
					if(curMinLiveCount < 0 || curMinLiveCount > liveCount)
					{
						curMinLiveCount = liveCount;
						liveTroopCountRecord = [];
					}
					if(curMinLiveCount < liveCount)
						continue;
					if(curMinLiveCount == liveCount)
						liveTroopCountRecord.push(singleTroop);
				}
			}
			
			if(side == BattleDefine.secondAtk)
			{
				if(DemoManager.curStageArmCount <= 0)
					return false;
			}
			
			if(side == BattleDefine.firstAtk)
			{
				if((NextSupplyShow.instance.supplyHeroOrArm == 1 && !forceDirect) || forceaddHero)
				{
					var mcIndex:int = 0;
					var findPos:Boolean = false;
					for(var index:int = 0;index < herotroops.length;index++)
					{
						singleTroop = herotroops[index];
						if(singleTroop == null)
							continue;
						if((singleTroop.attackUnit.contentHeroInfo == null || singleTroop.logicStatus == LogicSatusDefine.lg_status_dead) && !BattleInfoSnap.hasHeroRecalled)
						{
							liveCount = BattleTargetSearcher.getTroopCountOfSomeHero(singleTroop,BattleManager.instance.pSideAtk);
							if(liveCount >= 0)
							{
								BattleInfoSnap.hasHeroRecalled = true;
								FakeFormationLineMaker.makeFakeHeroTroop(singleTroop);
								TroopDisplayFunc.initShowInfo(singleTroop);
								singleTroop.visible = true;
								singleTroop.alpha = 1;
								
								BattleStage.instance.troopLayer.addTroopToStage(singleTroop,singleTroop.ownerSide == BattleDefine.firstAtk);
								
								singleTroop.logicStatus = LogicSatusDefine.lg_status_idle;
								singleTroop.mcStatus = McStatusDefine.mc_status_idle;
								
								BattleStage.instance.troopLayer.findHeroRecallPos(singleTroop);
								
								var targetArr:Array = [];
								var singleTarget:CellTroopInfo;
								
								BattleInfoSnap.heroCalledCount++;
								mcIndex = singleTroop.mcIndex;
								findPos = true;
								break;
							}
						}
					}
					var oldValie:int = NextSupplyShow.instance.supplyHeroOrArm;
					NextSupplyShow.instance.supplyHeroOrArm = 0;
					switch(mcIndex)
					{
						case 1305:
							targetArr = BattleTargetSearcher.getTargetsForSomeRange(0,AttackRangeDefine.woFangDiYiPai);
							for(i = 0; i < targetArr.length;i++)
							{
								singleTarget = targetArr[i] as CellTroopInfo;
								if(singleTarget == null || singleTarget.logicStatus == LogicSatusDefine.lg_status_dead || singleTarget.logicStatus == LogicSatusDefine.lg_status_hangToDie)
									continue;
								var hpAfterAdd:int = Math.min(singleTarget.totalHpOfSlot,singleTarget.totalHpValue + singleTarget.maxTroopHp);	
								var changedValue:int = hpAfterAdd - singleTarget.totalHpValue;
								singleTarget.resolveDamageDisplayInfo(0 - changedValue,-1);
								TroopEffectDisplayFunc.showBattleCardEffect(singleTarget,BattleCardTypeDefine.shiBingBuChong);
							}
							break;
						case 1306:		//貂蝉带兵过来
							var totalCount:int = 0;
							var totalstartCount:int = 3;
							while(totalstartCount > 0)
							{
								index = int(NextSupplyShow.allSupplyTypes.length * Math.random());
								var tempSupplyType:int = NextSupplyShow.allSupplyTypes[index]; 
								var starsCount:int = NextSupplyShow.getStarCountNeed(tempSupplyType);
								if(totalstartCount < starsCount)
									continue;
								totalstartCount -= starsCount;
								
								var supplyArmType:int = NextSupplyShow.gettargetArmTypeBySupplytype(tempSupplyType);
								var supplyeArmResId:int = DemoManager.getSingleRandomId(tempSupplyType);
								
								DemoManager.makeNextArmSupply(BattleDefine.firstAtk,supplyArmType,supplyeArmResId,tempSupplyType,true);		
							}
							break;
						case 1309:					
							targetArr = BattleTargetSearcher.getTargetsForSomeRange(0,AttackRangeDefine.woFangDiYiPai);
							for(i = 0; i < targetArr.length;i++)
							{
								singleTarget = targetArr[i] as CellTroopInfo;var singleEffect:BattleSingleEffect = new BattleSingleEffect()
								singleEffect.effectDuration = 5;
								singleEffect.effectId = SpecialEffectDefine.baohuqiang;
								singleEffect.effectValue = 1;
								singleEffect.effectSourceTroop = singleTarget.troopIndex;
								TroopFunc.addSingleBuff(singleTarget,singleEffect,true);
							}
							break;
					}
					if(forceaddHero || !findPos)
					{
						NextSupplyShow.instance.supplyHeroOrArm = oldValie;
					}
					return findPos;
				}
				else if(NextSupplyShow.instance.supplyHeroOrArm == 2 && !forceDirect)
				{
					NextSupplyShow.instance.supplyHeroOrArm = 0;
					BattleManager.cardManager.addCardToList(NextSupplyShow.instance.supplyCardId);
					return true;
				}
			}
			
			var supplyCellTroop:CellTroopInfo = FakeFormationLineMaker.makeFakeSupplyTroop(side,armType,resId,supplyType,true);			//获得补充的celltroop信息
			if(side == BattleDefine.secondAtk)
			{
				supplyCellTroop.stageBelong = DemoManager.curStage;
				DemoManager.curStageArmCount--;
			}
			else if(NextSupplyShow.instance.supplyHeroOrArm == 0)
			{
				BattleManager.cardManager.handleNewBattleCardGened(NextSupplyShow.instance.genedBattleCardInfo);
			}
			
			var needSupplyTarget:CellTroopInfo;
			if(supplyCellTroop.cellsCountNeed.x == 1 && supplyCellTroop.cellsCountNeed.y == 1)
			{
				needSupplyTarget = liveTroopCountRecord[int(liveTroopCountRecord.length * Math.random())];
			}
			else
			{
				var curMinSupplyIndex:int = -1;
				var minHeroCellTroop:CellTroopInfo = null;
				
				for(i = 0; i < herotroops.length;i++)
				{
					singleTroop = herotroops[i];
					
					var sourcePos:Point = BattleTargetSearcher.getRowColumnByCellIndex(singleTroop.occupiedCellStart);
					var cellsHorizon:Array = BattleFunc.particularCellsHorizonl(sourcePos.y,sourceSide,false);
					var singleCell:Cell;
					var recordObj:Object = {};
					
					var quilfiedCellIndex:int = -1;
					var qualified:Boolean = false;
					
					for(var ii:int = 0;ii < cellsHorizon.length;ii++)
					{
						qualified = true;
						singleCell = cellsHorizon[ii];
						var oldOccupiedArr:Array = BattleFunc.getCellsOccupoedByStartCellIndex(singleCell.index,supplyCellTroop.cellsCountNeed,sourceSide);
						for(var at:int = 0;at < oldOccupiedArr.length;at++)
						{
							var singleOccupidCell:Cell = BattleUnitPool.getCellInfo(oldOccupiedArr[at]);
							if(singleOccupidCell.troopInfo && singleOccupidCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && singleOccupidCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)
							{
								qualified = false;
								break;
							}
							var pos:Point = BattleTargetSearcher.getRowColumnByCellIndex(oldOccupiedArr[at]);
							if(pos.y >= 4)
							{
								qualified = false;
								break;
							}
							quilfiedCellIndex = ii;
						}
						if(qualified)
							break;
					}
					
					if(qualified)
					{
						if(curMinSupplyIndex < 0 || quilfiedCellIndex < curMinSupplyIndex )
						{
							curMinSupplyIndex = quilfiedCellIndex;
							minHeroCellTroop = singleTroop;
						}
					}
					
				}
				needSupplyTarget = minHeroCellTroop;
			}
			
			if(needSupplyTarget == null)
				return false;
			
			//开始补进supply
			return BattleStage.instance.troopLayer.findSupplyPosition(needSupplyTarget,supplyCellTroop);
		}
		
		/**
		 * 检查回合是否结束
		 */
		public static function checkCombatStageChange():void
		{
			if(DemoManager.curStageArmCount > 0)
				return;
			var allDeftroops:Array = [];
			var allTroops:Array = BattleUnitPool.getAllTroops();
			var singleTroop:CellTroopInfo;
			var allCountOfSomeStage:Object = {};
			allCountOfSomeStage[0] = 0;
			allCountOfSomeStage[1] = 0;
			allCountOfSomeStage[2] = 0;
			allCountOfSomeStage[3] = 0;
			for(var i:int = 0;i < allTroops.length;i++)
			{
				singleTroop = allTroops[i];
				if(singleTroop == null || singleTroop.ownerSide == BattleDefine.firstAtk || singleTroop.isHero)
					continue;
				if(singleTroop.logicStatus == LogicSatusDefine.lg_status_dead || singleTroop.logicStatus == LogicSatusDefine.lg_status_hangToDie ||
					singleTroop.logicStatus == LogicSatusDefine.lg_status_forceDead || !singleTroop.visible || (singleTroop.mcIndex <= 0) || (singleTroop.troopPlayerId == null || singleTroop.troopPlayerId == ""))
					continue;
				if(singleTroop.occupiedCellStart < 0)
					continue;
				allDeftroops.push(singleTroop);
				allCountOfSomeStage[singleTroop.stageBelong] = allCountOfSomeStage[singleTroop.stageBelong] + 1;
			}
			if(DemoManager.curStage == 0)
			{
				if(allCountOfSomeStage[0] <= 4)
				{
					DemoManager.curStage = 1;
				}
			}
			else if(DemoManager.curStage == 1)
			{
				if(allCountOfSomeStage[1] <= 4)
				{
					DemoManager.curStage = 2;
				}
			}
			else if(DemoManager.curStage == 2)
			{
				if(allCountOfSomeStage[2] <= 0)
				{
					DemoManager.curStage = 3;
				}
			}
		}
		
		public static function getNextEnemySupplyType():int
		{
			var curIndex:int = armIndexInStage++;
			armIndexInStage = armIndexInStage % curStageArmtypes.length;
			return curStageArmtypes[curIndex];
		}
		
		public static function clearInfo():void
		{
			curStage = -1;
			usedArmIds = [];
			usedHeroIds = [];
		}

		public static function get curStage():int
		{
			return _curStage;
		}

		public static function set curStage(value:int):void
		{
			_curStage = value;
			armIndexInStage = 0;
			if(_curStage >= 0)
			{
				BattleInfoSnap.canDirectCall = true;
				curStageArmCount = NextSupplyShow.combagtStageCount[_curStage];
				curStageArmtypes = NextSupplyShow.combatStageSupplyDefine[_curStage];
				
				if(BattleStage.instance.stageInfoShow)
				{
					var newFormat1:TextFormat = new TextFormat();
					newFormat1.color = 0xffffff;
					newFormat1.size = 22;
					newFormat1.align = TextFormatAlign.CENTER;
					
					var textToShow:String = "第" + (_curStage + 1).toString() + "回合";
					BattleStage.instance.stageInfoShow.text = textToShow;
					
					BattleStage.instance.stageInfoShow.setTextFormat(newFormat1,0,BattleStage.instance.stageInfoShow.text.length);
				}
			}
		}
		
	}
}