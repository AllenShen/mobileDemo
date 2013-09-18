package modules.battle.stage
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import caurina.transitions.Tweener;
	
	import defines.UserBattleCardInfo;
	
	import eventengine.GameEventHandler;
	
	import macro.ActionDefine;
	import macro.ArmType;
	import macro.AttackRangeDefine;
	import macro.BattleCardTypeDefine;
	import macro.BattleDisplayDefine;
	import macro.EventMacro;
	import macro.FormationElementType;
	import macro.GameSizeDefine;
	
	import modules.battle.battlecomponent.DeadEnemyCycle;
	import modules.battle.battlecomponent.NextSupplyShow;
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.McStatusDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battleevents.CheckAttackEvent;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.BattleManagerLogicFunc;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.funcclass.TroopEffectDisplayFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.funcclass.TroopInitClearFunc;
	import modules.battle.managers.AoYiManager;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.managers.DemoManager;
	import modules.battle.utils.BattleEventTagFactory;
	
	import utils.Utility;
	
	/**
	 * troop层 
	 * @author SDD
	 */
	public class BattleTroopLayer extends Sprite
	{
		
		private var normalayer:Sprite;
		private var heroLayer:Sprite;
		private var yPathUseStatus:Object;					//当前的y值路线使用情形
		
		private var leftSideFill:Object;
		private var rightSideFill:Object;
		
		//记录第一排troop就绪的信息
		private var firstRowTroopReadyObj:Object={};
		
		public function BattleTroopLayer()
		{
			yPathUseStatus ={};
			heroLayer = new Sprite;
			normalayer = new Sprite;
			this.addChild(normalayer);
			this.addChild(heroLayer);
			super();
		}
		
		public function getTroopPosNeed(troopInfo:CellTroopInfo,isAtk:Boolean = true):Point
		{
			var realPositon:Point = new Point(0,0);
			if(troopInfo == null)
				return realPositon;
			
			troopInfo.ownerSide = isAtk ? BattleDefine.firstAtk : BattleDefine.secondAtk;
			
			var cellIndexPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(troopInfo.occupiedCellStart);
			
			//在scene上显示index			攻击方需要转换
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
			
			if(BattleModeDefine.checkNeedConsiderWave())
			{
				if(!isAtk && cellIndexPos.x >= BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex)
				{
					realPositon.x += BattleDisplayDefine.zhanDouDaijiGap;
					
					BattleInfoSnap.recordTroopAttackDistance(troopInfo);
					troopInfo.attackUnit.attackDistance = BattleDefine.minAttackDis;
				}
			}
			
			return realPositon;
		}
		
		/**
		 * 将某个troop加入到舞台之中 
		 * @param troopInfo
		 * @param isAtk		是否为攻击类型
		 * 
		 */
		public function addTroopToStage(troopInfo:CellTroopInfo,isAtk:Boolean = true):void
		{
			var realPositon:Point = getTroopPosNeed(troopInfo,isAtk);
			
			troopInfo.x = realPositon.x;
			troopInfo.y = realPositon.y;
			
			if(troopInfo.isHero)
				heroLayer.addChild(troopInfo);
			else
				normalayer.addChild(troopInfo);
		}
		
		/**
		 * 将下一波的troop加到战场上 
		 * @param waveInfo
		 */
		public function addNextWaveTroopToStage(singleTroop:CellTroopInfo):void
		{
			if(singleTroop == null)
				return;
			var i:int = 0;
			var cellIndexPos:Point;
			var displayIndexOnScene:Point;
			var realPositon:Point = new Point(0,0);
			singleTroop.ownerSide = BattleDefine.secondAtk;
			cellIndexPos = BattleTargetSearcher.getRowColumnByCellIndex(singleTroop.occupiedCellStart);
			displayIndexOnScene = new Point(cellIndexPos.x,cellIndexPos.y);
			
			realPositon.x = BattleDisplayDefine.nextWaveTroopStartPos.x;
			realPositon.y = BattleDisplayDefine.nextWaveTroopStartPos.y;
			
			realPositon.x += displayIndexOnScene.x * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
			realPositon.y += (displayIndexOnScene.y) * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal);
			
			singleTroop.x = realPositon.x;
			singleTroop.y = realPositon.y;
			
			if(singleTroop.isHero)
				heroLayer.addChild(singleTroop);
			else
				normalayer.addChild(singleTroop);
		}
		
		/**
		 *  检查是否可以让下一波数据向前推进到待机区是否为空
		 */
		public function checkNextWaveMoveToDaiJi():void
		{
			if(BattleInfoSnap.isNextWaveOnDaiJiQu)
				return;
			if(!BattleModeDefine.checkNeedConsiderWave())
				return;
			if(BattleUnitPool.nextWaveTroopInfo == null || BattleUnitPool.nextWaveTroopInfo.length < 0)
			{
				return;
			}
			if(!BattleInfoSnap.hasVisibleHeroOnWave)
			{
				if(BattleManager.instance.pSideDef.maxRowIndex >= BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex)
				{
					return;
				}
			}
			BattleInfoSnap.isNextWaveOnDaiJiQu = true;
			var targetX:int;
			var duration:Number;
			var gapDistance:int = BattleDisplayDefine.nextWaveTroopStartPos.x - BattleDisplayDefine.defStartPos.x;
			gapDistance -= BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
			gapDistance -= BattleDisplayDefine.zhanDouDaijiGap;
			if(BattleInfoSnap.hasVisibleHeroOnWave)
			{
				gapDistance -= BattleDisplayDefine.zhanDouGapWithVisibleHero;
			}
			var singleTroop:CellTroopInfo;
			for each(singleTroop in BattleUnitPool.nextWaveTroopInfo)
			{
				if(singleTroop == null)
					continue;
				targetX = singleTroop.x - gapDistance;
				singleTroop.logicStatus = LogicSatusDefine.lg_status_filling;
				singleTroop.playAction(ActionDefine.Action_Run,-1);
				duration = getTroopMoveDuration(gapDistance);
				Tweener.addTween(singleTroop,{x:targetX,time:Utility.getFrameByTime(duration),useFrames:true,transition:"linear",onComplete:nextWaveSingelTroopMoveToDaiJi,onCompleteParams:[singleTroop]});
			}	
		}
		
		/**
		 * 单个troop移动到待机区 
		 * @param singleTroop
		 */
		private function nextWaveSingelTroopMoveToDaiJi(singleTroop:CellTroopInfo):void
		{
			if(singleTroop)
			{
				singleTroop.logicStatus = LogicSatusDefine.lg_status_idle;
				singleTroop.playAction(ActionDefine.Action_Idle,-1);
				singleTroop.logicStatus = LogicSatusDefine.lg_status_waitingForNextWave;
			}
		}
		
		public function findHeroRecallPos(heroTroop:CellTroopInfo):void
		{
			if(heroTroop == null)
			{
				return;
			}
			var realPos:Point = new Point(heroTroop.x,heroTroop.y);
			if(heroTroop.ownerSide == BattleDefine.firstAtk)
			{
				heroTroop.x = 0 - 100;
			}
			else
			{
				heroTroop.x = realPos.x + 100;
			}
			
			var duration:Number = getTroopMoveDuratonOfReborn(Math.abs(heroTroop.x - realPos.x));
			
			heroTroop.logicStatus = LogicSatusDefine.lg_status_filling;
			heroTroop.mcStatus = McStatusDefine.mc_status_running;
			
			heroTroop.playAction(ActionDefine.Action_Run);
			
			Tweener.addTween(heroTroop,{x:realPos.x,time:Utility.getFrameByTime(duration),useFrames:true,
				transition:"linear",onComplete:onSingleHeroMoveEnd,onCompleteParams:[heroTroop,realPos]});
			
		}
		
		private function onSingleHeroMoveEnd(heroTroop:CellTroopInfo,targetPos:Point):void
		{
			heroTroop.x = targetPos.x;
			heroTroop.y = targetPos.y;
			
			if(heroTroop.logicStatus != LogicSatusDefine.lg_status_dead)
			{
				heroTroop.logicStatus = LogicSatusDefine.lg_status_idle;
				heroTroop.mcStatus = McStatusDefine.mc_status_idle;
				heroTroop.playAction(ActionDefine.Action_Idle);
			}
		}
		
		public function findSupplyPosition(targetHero:CellTroopInfo,supplyCellTroop:CellTroopInfo):Boolean
		{
			if(targetHero == null)
			{
				return false;
			}
			
			var sourceSide:PowerSide;
			if(targetHero.ownerSide == BattleDefine.firstAtk)
				sourceSide = BattleManager.instance.pSideAtk;
			else
				sourceSide = BattleManager.instance.pSideDef;
			
			var heroPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(targetHero.occupiedCellStart);
			
			var curLineCells:Array = BattleFunc.particularCellsHorizonl(heroPos.y,sourceSide,false);
			for(var checkIndex:int = 0;checkIndex < curLineCells.length;checkIndex++)				//找到目标位置
			{
				var tempCell:Cell = curLineCells[checkIndex];
				if(tempCell.troopInfo != null && tempCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && tempCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)
				{
					continue;
				}
				
				var at:int = 0;
				var singleOccupidCell:Cell;
				var oldOccupiedArr:Array = BattleFunc.getCellsOccupied(supplyCellTroop.troopIndex);
				for(at = 0;at < oldOccupiedArr.length;at++)
				{
					singleOccupidCell = BattleUnitPool.getCellInfo(oldOccupiedArr[at]);
					if(singleOccupidCell)
					{
						if(singleOccupidCell.troopInfo && singleOccupidCell.troopInfo.troopIndex == supplyCellTroop.troopIndex)
							singleOccupidCell.troopInfo = null;
					}
				}
				
				supplyCellTroop.occupiedCellStart = tempCell.index;
				
				var realOccupidArray:Array = BattleFunc.getCellsOccupied(supplyCellTroop.troopIndex);
				for(at = 0;at < realOccupidArray.length;at++)
				{
					singleOccupidCell = BattleUnitPool.getCellInfo(realOccupidArray[at]);
					singleOccupidCell.troopInfo = supplyCellTroop;
				}
				
				var curGap:int = 0;
				
				var realPositon:Point = TroopDisplayFunc.getCellPos(tempCell.index,sourceSide.isFirstAtk); 
				if(sourceSide.isFirstAtk)
				{
					curGap = realPositon.x + BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal;
				}
				else
				{
					curGap = GameSizeDefine.maxWidth - realPositon.x;
				}
				var awayGap:int = Math.max(awayGap,curGap);
				BattleStage.instance.troopLayer.addTroopToStage(supplyCellTroop,supplyCellTroop.ownerSide == BattleDefine.firstAtk);
				supplyCellTroop.y = realPositon.y;
				supplyCellTroop.x = realPositon.x;
				
				if(sourceSide.isFirstAtk)
					supplyCellTroop.x = supplyCellTroop.x - awayGap;
				else
					supplyCellTroop.x = supplyCellTroop.x + awayGap;
				
				break;
			}
			
			var testPos:int = supplyCellTroop.x * supplyCellTroop.y;
			if(testPos == 0)
				return false;
			
			TroopInitClearFunc.initTroopSimply(supplyCellTroop);
			
			var targetPostion:Point = TroopDisplayFunc.getCellPos(supplyCellTroop.occupiedCellStart,supplyCellTroop.ownerSide == BattleDefine.firstAtk);
			supplyCellTroop.logicStatus = LogicSatusDefine.lg_status_filling;
			supplyCellTroop.playAction(ActionDefine.Action_Run,-1);
			
			var duration:Number = getTroopMoveDuratonOfReborn(Math.abs(targetPostion.x - supplyCellTroop.x));
			
			BattleInfoSnap.needPauseBattle = true;
			
			//动态调整层级
			var allCells:Array;
			var singleCell:Cell;
			var index:int = 0;
			var i:int = 0;
			for(index = 0;index < BattleDefine.maxFormationYValue;index++)
			{
				allCells = BattleFunc.particularCellsHorizonl(index,BattleManager.instance.pSideAtk,true);
				for(i = 0;i < allCells.length;i++)
				{
					singleCell = allCells[i];
					if(singleCell && singleCell.troopInfo && singleCell.troopInfo.parent)
						singleCell.troopInfo.parent.addChild(singleCell.troopInfo);
				}
			}
			
			Tweener.addTween(supplyCellTroop,{x:targetPostion.x,time:Utility.getFrameByTime(duration),useFrames:true,
				transition:"linear",onComplete:onSingleSupplyTroopMoveEnd,onCompleteParams:[supplyCellTroop]});
			
			return true;
		}
		
		private function onSingleSupplyTroopMoveEnd(targetTroop:CellTroopInfo):void
		{
			if(targetTroop == null)
				return;
			if(targetTroop.logicStatus == LogicSatusDefine.lg_status_dead || targetTroop.logicStatus == LogicSatusDefine.lg_status_hangToDie)
				return;
			
			targetTroop.logicStatus = LogicSatusDefine.lg_status_idle; 
			targetTroop.playAction(ActionDefine.Action_Idle,-1);
			
			checkHeBingAfterSupply(targetTroop);
			
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
			BattleStage.instance.userChooseLayer.searchType = BattleStage.instance.userChooseLayer.searchType;
			BattleManagerLogicFunc.checkTroopDeadFill(null,BattleManager.instance.pSideAtk);
		}
		
		private function checkHeBingLogic(targetTroop:CellTroopInfo):int
		{
			var needHeBing:int = -1;
			return needHeBing;
			if(targetTroop.ownerSide == BattleDefine.secondAtk)
				return needHeBing;
			
			var troopPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(targetTroop.occupiedCellStart);
			if(troopPos.x == 0)
				needHeBing = -1;
			else
			{
				var curOccupied:int = targetTroop.occupiedCellStart;
				needHeBing = curOccupied - targetTroop.cellsCountNeed.x * BattleDefine.maxFormationYValue;
				var curCell:Cell = BattleUnitPool.getCellInfo(needHeBing);
				if(curCell == null)
				{
					needHeBing = -1;
				}
				else
				{
					var frontTroop:CellTroopInfo = curCell.troopInfo;
					if(frontTroop == null)
						needHeBing = -1;
					else if(frontTroop.occupiedCellStart != needHeBing)
						needHeBing = -1;
					
					if(needHeBing >= 0)
					{
						if(frontTroop.logicStatus == LogicSatusDefine.lg_status_dead || frontTroop.logicStatus == LogicSatusDefine.lg_status_hangToDie ||
							frontTroop.logicStatus == LogicSatusDefine.lg_status_forceDead)
							needHeBing = -1;
					}
					
					if(needHeBing >= 0)
					{
						if(frontTroop.supplyType != targetTroop.supplyType)
							needHeBing = -1;
						if(frontTroop.ownerSide != targetTroop.ownerSide)
							needHeBing = -1;
						if(frontTroop.mcIndex != targetTroop.mcIndex)
							needHeBing = -1;
					}
					
				}
			}
			
			return needHeBing;
		}
		
		private function findHebingOnSameLine(cellInfo:Cell):int
		{
			var needHeBing:int = -1;
			var troopPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(cellInfo.index);
			if(troopPos.x == 0)
				needHeBing = -1;
			else
			{
				for(var i:int = troopPos.x - 1;i >= 0;i--)
				{
					var checkCellInfo:Cell = BattleTargetSearcher.getCellByRowColumn(BattleManager.instance.pSideAtk,new Point(i,troopPos.y));
					if(checkCellInfo == null || checkCellInfo.troopInfo == null || checkCellInfo.troopInfo.mcIndex != cellInfo.troopInfo.mcIndex)
						continue;
					if(checkCellInfo.troopInfo.occupiedCellStart != checkCellInfo.index)
						continue;
					needHeBing = checkCellInfo.index;
					break;
				}
			}
			return needHeBing;
		}
		
		private function onHebingMoveComplete(isSupply:Boolean ,targetTroop:CellTroopInfo,cellInFront:int = -1):void
		{
			var sourceSide:PowerSide = targetTroop.ownerSide == BattleDefine.firstAtk ? BattleManager.instance.pSideAtk : BattleManager.instance.pSideDef;
			if(cellInFront < 0)
				cellInFront = checkHeBingLogic(targetTroop);		//将自己的数据 累加到原本位置
			
			targetTroop.isHeBing = false;
			
			delete BattleInfoSnap.hebingTarget[cellInFront];
			
			var at:int = 0;
			var singleOccupidCell:Cell
			var oldCell:Cell = BattleUnitPool.getCellInfo(cellInFront);
			var	oldTroop:CellTroopInfo = oldCell.troopInfo;
			if(oldTroop && oldTroop.logicStatus != LogicSatusDefine.lg_status_dead && oldTroop.logicStatus != LogicSatusDefine.lg_status_hangToDie
				&& oldTroop.logicStatus != LogicSatusDefine.lg_status_forceDead)
			{
				targetTroop.curArmCount = 0;
				targetTroop.curTroopHp = 0;
				
				if(oldTroop.attackUnit.armtype == ArmType.footman)
				{
					oldTroop.maxTroopHp = oldTroop.maxTroopHp + targetTroop.maxTroopHp;
					oldTroop.resolveDamageDisplayInfo(oldTroop.totalHpValue - oldTroop.maxTroopHp,0);
					oldTroop.damageValue += targetTroop.damageValue * 0.5;
				}
				else
				{
					oldTroop.maxTroopHp = oldTroop.maxTroopHp + targetTroop.maxTroopHp * 0.5;
					oldTroop.resolveDamageDisplayInfo(oldTroop.totalHpValue - oldTroop.maxTroopHp,0);
					oldTroop.damageValue += targetTroop.damageValue;
				}
				
				targetTroop.hpBar && targetTroop.hpBar.hpChange(targetTroop.totalHpValue);
				targetTroop.mcStatus = McStatusDefine.mc_status_idle;
				targetTroop.logicStatus = LogicSatusDefine.lg_status_dead;
				
				TroopFunc.handleDeadTroopLogic(targetTroop);
				
				//合并效果
				TroopEffectDisplayFunc.showBattleCardEffect(oldTroop,BattleCardTypeDefine.quanTiZengYuan);
				
				var startsNeed:int = NextSupplyShow.getStarCountNeed(oldTroop.supplyType);
//				for(var i:int = 0;i < startsNeed * 2;i++)
//					DeadEnemyCycle.instance.handleSelfArmCycled();
				
				for(var i:int = 0;i < startsNeed;i++)
					DemoManager.handleSingleStarQualified(NextSupplyShow.starSupplyTypeNone,0,1);
				
				oldTroop.curLevel++;
				oldTroop.levelTextShow.text = oldTroop.curLevel.toString();
				oldTroop.levelTextShow.visible = true;
			}
			else				//当前位置troop已死  直接替换
			{
				var oldOccupiedArr:Array = BattleFunc.getCellsOccupied(targetTroop.troopIndex);
				for(at = 0;at < oldOccupiedArr.length;at++)
				{
					singleOccupidCell = BattleUnitPool.getCellInfo(oldOccupiedArr[at]);
					if(singleOccupidCell.troopInfo && singleOccupidCell.troopInfo.troopIndex == targetTroop.troopIndex)
						singleOccupidCell.troopInfo = null;
				}
				
				targetTroop.occupiedCellStart = cellInFront;
				
				targetTroop.logicStatus = LogicSatusDefine.lg_status_idle;
				targetTroop.playAction(ActionDefine.Action_Idle,-1);
				
				oldOccupiedArr = BattleFunc.getCellsOccupoedByStartCellIndex(cellInFront,targetTroop.cellsCountNeed,sourceSide);
				for(at = 0;at < oldOccupiedArr.length;at++)
				{
					singleOccupidCell = BattleUnitPool.getCellInfo(oldOccupiedArr[at]);
					singleOccupidCell.troopInfo = targetTroop;
				}
			}
			
			if(isSupply)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				//重绘底部阴影
				BattleStage.instance.userChooseLayer.searchType = BattleStage.instance.userChooseLayer.searchType;
				BattleManagerLogicFunc.checkTroopDeadFill(null,BattleManager.instance.pSideAtk);
			}
			else
			{
				
			}
		}
		
		private function checkHeBingAfterSupply(targetTroop:CellTroopInfo):void
		{
			var cellInFront:int = checkHeBingLogic(targetTroop);
			
			targetTroop.logicStatus = LogicSatusDefine.lg_status_idle;
			targetTroop.playAction(ActionDefine.Action_Idle,-1);
			
			if(cellInFront >= 0)
			{
				var targetPostion:Point = TroopDisplayFunc.getCellPos(cellInFront,targetTroop.ownerSide == BattleDefine.firstAtk);
				targetTroop.logicStatus = LogicSatusDefine.lg_status_filling;
				targetTroop.playAction(ActionDefine.Action_Run,-1);
				var duration:Number = getTroopMoveDuratonOfReborn(Math.abs(targetPostion.x - targetTroop.x));
				Tweener.addTween(targetTroop,{x:targetPostion.x,time:Utility.getFrameByTime(duration),useFrames:true,
					transition:"linear",onComplete:onHebingMoveComplete,onCompleteParams:[true,targetTroop]});
			}
			else
			{
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				//重绘底部阴影
				BattleStage.instance.userChooseLayer.searchType = BattleStage.instance.userChooseLayer.searchType;
				BattleManagerLogicFunc.checkTroopDeadFill(null,BattleManager.instance.pSideAtk);
			}
		}
		
		/**
		 * 补进结束后检查是否合并
		 * @param sourceTroop
		 */
		private function checkHeBingAfterBuJin(targetTroop:CellTroopInfo):void
		{
			var cellInFront:int = checkHeBingLogic(targetTroop);
			
			if(cellInFront >= 0)
			{
				var targetPostion:Point = TroopDisplayFunc.getCellPos(cellInFront,targetTroop.ownerSide == BattleDefine.firstAtk);
				targetTroop.logicStatus = LogicSatusDefine.lg_status_filling;
				targetTroop.playAction(ActionDefine.Action_Run,-1);
				var duration:Number = getTroopMoveDuratonOfReborn(Math.abs(targetPostion.x - targetTroop.x));
				Tweener.addTween(targetTroop,{x:targetPostion.x,time:Utility.getFrameByTime(duration),useFrames:true,
					transition:"linear",onComplete:onHebingMoveComplete,onCompleteParams:[false,targetTroop]});
			}
			else
			{
				BattleManagerLogicFunc.checkHangUpDamageChains(targetTroop);
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.refreshChoostTarget));
			}
		}
		
		public function checkHeBingOnSameLine(targetTroop:Cell):void
		{
			if(targetTroop == null || targetTroop.troopInfo.mcStatus == McStatusDefine.mc_status_attacking || targetTroop.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead)
				return;
			var cellInFront:int = findHebingOnSameLine(targetTroop);
			if(cellInFront < 0)
				return;
			var targetPostion:Point = TroopDisplayFunc.getCellPos(cellInFront,targetTroop.troopInfo.ownerSide == BattleDefine.firstAtk);
			targetTroop.troopInfo.logicStatus = LogicSatusDefine.lg_status_filling;
			targetTroop.troopInfo.playAction(ActionDefine.Action_Run,-1);
			var duration:Number = getTroopMoveDuratonOfReborn(Math.abs(targetPostion.x - targetTroop.troopInfo.x));
			targetTroop.troopInfo.isHeBing = true;
			BattleInfoSnap.hebingTarget[cellInFront] = 1;
			Tweener.addTween(targetTroop.troopInfo,{x:targetPostion.x,time:Utility.getFrameByTime(duration),useFrames:true,
				transition:"linear",onComplete:onHebingMoveComplete,onCompleteParams:[false,targetTroop.troopInfo,cellInFront]});
		}
		
		/**
		 * 找到重生的troop对应的新位置 
		 * @param sourceSide
		 */
		public function findRebornTroopPosition(sourceSide:PowerSide):void
		{
			var awayGap:int = 0;
			var newDeadTroops:Object = new Object();
			var troopInfoStore:Object = BattleInfoSnap.heroMappedTroops;
			var allDeadTroops:Array = [];
			var tempTroop:CellTroopInfo;
			var realPositon:Point = new Point();
			var displayIndexOnScene:Point = new Point();
			var singleHeroDeadTroops:Array;
			for(var singleHeroIndex:String in troopInfoStore)
			{
				var targetHero:CellTroopInfo = BattleUnitPool.getTroopInfo(int(singleHeroIndex));
				if(targetHero == null || targetHero.logicStatus == LogicSatusDefine.lg_status_dead || targetHero.logicStatus == LogicSatusDefine.lg_status_hangToDie)
				{
					continue;
				}
				var heroPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(targetHero.occupiedCellStart);
				var curLineCells:Array = BattleFunc.particularCellsHorizonl(heroPos.y,sourceSide,false);
				allDeadTroops = troopInfoStore[singleHeroIndex];
				for(var i:int = 0;i < allDeadTroops.length;i++)
				{
					tempTroop = allDeadTroops[i];
					if(tempTroop == null)
						continue;
					if(tempTroop.logicStatus == LogicSatusDefine.lg_status_dead)
					{
						if(!newDeadTroops.hasOwnProperty(singleHeroIndex))
							newDeadTroops[singleHeroIndex] = [];
						singleHeroDeadTroops = newDeadTroops[singleHeroIndex];
						singleHeroDeadTroops.push(tempTroop);
						continue;
					}
					var allQualified:Boolean = true;
					for(var checkIndex:int = 0;checkIndex < curLineCells.length;checkIndex++)
					{
						var tempCell:Cell = curLineCells[checkIndex];
						if(tempCell.troopInfo != null && tempCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && tempCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)
						{
							if(!BattleInfoSnap.deadTroopList[tempCell.troopInfo.troopIndex])
							{
								continue;
							}
						}
						
						for(var allCheck:int = 1;allCheck < tempTroop.cellsCountNeed.x;allCheck++)
						{
							var nextCell:Cell = curLineCells[checkIndex + allCheck];
							if(tempCell.troopInfo != null && tempCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && tempCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)
							{
								if(!BattleInfoSnap.deadTroopList[tempCell.troopInfo.troopIndex])
								{
									allQualified = false;
									break;
								}
							}
						}
						
						if(!allQualified)
							break;					//不满足直接跳出
						
						var at:int = 0;
						var singleOccupidCell:Cell;
						var oldOccupiedArr:Array = BattleFunc.getCellsOccupied(tempTroop.troopIndex);
						for(at = 0;at < oldOccupiedArr.length;at++)
						{
							singleOccupidCell = BattleUnitPool.getCellInfo(oldOccupiedArr[at]);
							if(singleOccupidCell.troopInfo && singleOccupidCell.troopInfo.troopIndex == tempTroop.troopIndex)
								singleOccupidCell.troopInfo = null;
						}
						
						tempTroop.occupiedCellStart = tempCell.index;
						
						var realOccupidArray:Array = BattleFunc.getCellsOccupied(tempTroop.troopIndex);
						for(at = 0;at < realOccupidArray.length;at++)
						{
							singleOccupidCell = BattleUnitPool.getCellInfo(realOccupidArray[at]);
							singleOccupidCell.troopInfo = tempTroop;
						}
						
						displayIndexOnScene = BattleTargetSearcher.getRowColumnByCellIndex(tempCell.index);
						
						var curGap:int = 0;
						
						realPositon = TroopDisplayFunc.getCellPos(tempCell.index,sourceSide.isFirstAtk); 
						if(sourceSide.isFirstAtk)
						{
							curGap = realPositon.x + BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal;
						}
						else
						{
							curGap = GameSizeDefine.maxWidth - realPositon.x;
						}
						awayGap = Math.max(awayGap,curGap);
						BattleInfoSnap.rebornedTroops.push(tempTroop);
						BattleStage.instance.troopLayer.addTroopToStage(tempTroop,tempTroop.ownerSide == BattleDefine.firstAtk);
						tempTroop.y = realPositon.y;
						tempTroop.x = realPositon.x;
						
						delete BattleInfoSnap.deadTroopList[tempTroop.troopIndex];
						break;
					}
					if(!allQualified)
					{
						if(!newDeadTroops.hasOwnProperty(singleHeroIndex))
							newDeadTroops[singleHeroIndex] = [];
						singleHeroDeadTroops = newDeadTroops[singleHeroIndex];
						singleHeroDeadTroops.push(tempTroop);
					}
				}
			}
			BattleInfoSnap.heroMappedTroops = newDeadTroops;
			
			var checkedRecord:Object = {};
			for(var rebornIndex:int = 0;rebornIndex < BattleInfoSnap.rebornedTroops.length;rebornIndex++)
			{
				tempTroop = BattleInfoSnap.rebornedTroops[rebornIndex];
				if(tempTroop)
				{
					if(checkedRecord[tempTroop.troopIndex])
					{
						trace("here may be error");
						continue;
					}
					checkedRecord[tempTroop.troopIndex] = 1;
					if(tempTroop.ownerSide == BattleDefine.firstAtk)
					{
						tempTroop.x = tempTroop.x - awayGap;
					}
					else
					{
						tempTroop.x = tempTroop.x + awayGap;
					}
				}
			}
			
			makeRebornedTroopMakeToCenter();
		}
		
		/**
		 *  让重生的troop跑入战场
		 */
		public function makeRebornedTroopMakeToCenter():void
		{
			BattleInfoSnap.movingRebornTroops = {};
			var tempTroop:CellTroopInfo;
			
			if(BattleInfoSnap.rebornedTroops.length > 0)
			{
				BattleStage.instance.showCardWorkGreatGreatEffect(BattleCardTypeDefine.fuhuo,-1);
			}
			
			while(BattleInfoSnap.rebornedTroops.length > 0)
			{
				tempTroop = BattleInfoSnap.rebornedTroops.shift();
				tempTroop.visible = true;
				tempTroop.alpha = 1;
				
				TroopInitClearFunc.initTroopSimply(tempTroop);
				BattleInfoSnap.curRebornTroops[tempTroop.troopIndex] = tempTroop.curArmCount;
				
				var targetPostion:Point = TroopDisplayFunc.getCellPos(tempTroop.occupiedCellStart,tempTroop.ownerSide == BattleDefine.firstAtk);
				BattleInfoSnap.movingRebornTroops[tempTroop.troopIndex] = 1;
				tempTroop.logicStatus = LogicSatusDefine.lg_status_filling;
				tempTroop.playAction(ActionDefine.Action_Run,-1);
				
				var duration:Number = getTroopMoveDuratonOfReborn(Math.abs(targetPostion.x - tempTroop.x));
				
				BattleInfoSnap.needPauseBattle = true;
				
				Tweener.addTween(tempTroop,{x:targetPostion.x,time:Utility.getFrameByTime(duration),useFrames:true,
					transition:"linear",onComplete:onSingleRebornTroopMoveEnd,onCompleteParams:[tempTroop]});
			}
		}
		
		private function onSingleRebornTroopMoveEnd(targetTroop:CellTroopInfo):void
		{
			delete BattleInfoSnap.movingRebornTroops[targetTroop.troopIndex];
			targetTroop.logicStatus = LogicSatusDefine.lg_status_idle; 
			targetTroop.playAction(ActionDefine.Action_Idle,-1);
			var hasMovingLeft:Boolean = false;
			for(var singleTroopIndex:String in BattleInfoSnap.movingRebornTroops)
			{
				hasMovingLeft = true;
				break;
			}
			if(!hasMovingLeft)
			{
				//让战斗继续
//				BattleManager.instance.makeBattleContinue();
				
				//动态调整层级
				var allCells:Array;
				var singleCell:Cell;
				var index:int = 0;
				var i:int = 0;
				for(index = 0;index < BattleDefine.maxFormationYValue;index++)
				{
					allCells = BattleFunc.particularCellsHorizonl(index,BattleManager.instance.pSideAtk,true);
					for(i = 0;i < allCells.length;i++)
					{
						singleCell = allCells[i];
						if(singleCell && singleCell.troopInfo && singleCell.troopInfo.parent)
							singleCell.troopInfo.parent.addChild(singleCell.troopInfo);
					}
				}
				for(index = 0;index < BattleDefine.maxFormationYValue;index++)
				{
					allCells = BattleFunc.particularCellsHorizonl(index,BattleManager.instance.pSideDef,true);
					for(i = 0;i < allCells.length;i++)
					{
						singleCell = allCells[i];
						if(singleCell && singleCell.troopInfo && singleCell.troopInfo.parent)
							singleCell.troopInfo.parent.addChild(singleCell.troopInfo);
					}
				}
				
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
			}
		}
		
		/**
		 *  让troop远离中心
		 */
		public function makeTroopAwayFromCenter(targetSide:int = -1):void
		{
			var allTroopArr:Array = BattleUnitPool.getAllTroops();
			for each(var singleTroop:CellTroopInfo in allTroopArr)
			{
				if(singleTroop == null || !singleTroop.isMobileTroop)
					continue;
				if(targetSide >= 0)
				{
					if(targetSide != singleTroop.ownerSide)
						continue;
				}
				if(singleTroop.ownerSide == BattleDefine.firstAtk)
				{
					singleTroop.x -= BattleDisplayDefine.moveToCenterGap;
				}
				else
				{
					singleTroop.x += BattleDisplayDefine.moveToCenterGap;
				}
			}
		}
		
		/**
		 * 让两边的troop向中间移动
		 * @param leftSideFillGap			左边一开始要补进的距离
		 * @param rightSideFillGap			右边一开始要补进的距离
		 */
		public function makeTroopMoveToCenter(leftSideFillGap:Object,rightSideFillGap:Object):void
		{
			firstRowTroopReadyObj ={};
			var allTroopArr:Array = BattleUnitPool.getAllTroops();
			
			leftSideFill = leftSideFillGap;
			rightSideFill = rightSideFillGap;
			if(leftSideFill == null)
				leftSideFill ={};
			if(rightSideFill == null)
				rightSideFill ={};
			
			for each(var singleTroop:CellTroopInfo in allTroopArr)
			{
				if(singleTroop == null || !singleTroop.isMobileTroop)
					continue;
				if(singleTroop.ownerSide == BattleDefine.firstAtk)
				{
					singleTroop.logicStatus = LogicSatusDefine.lg_status_filling;
					singleTroop.playAction(ActionDefine.Action_Run,-1);
					Tweener.addTween(singleTroop,{x:singleTroop.x + BattleDisplayDefine.moveToCenterGap,
						time:Utility.getFrameByTime(BattleDisplayDefine.moveToCenterDuration),useFrames:true,
						transition:"linear",onComplete:singleTroopCenterMoveEnd,onCompleteParams:[singleTroop]});
					firstRowTroopReadyObj[singleTroop.troopIndex] = 0;
				}
				else
				{
					singleTroop.logicStatus = LogicSatusDefine.lg_status_filling;
					singleTroop.playAction(ActionDefine.Action_Run,-1);
					Tweener.addTween(singleTroop,{x:singleTroop.x - BattleDisplayDefine.moveToCenterGap,
						time:Utility.getFrameByTime(BattleDisplayDefine.moveToCenterDuration),useFrames:true,
						transition:"linear",onComplete:singleTroopCenterMoveEnd,onCompleteParams:[singleTroop]});
					firstRowTroopReadyObj[singleTroop.troopIndex] = 0;
				}
			}
		}
		
		public function makeAtkSideMoveToCenter(leftSideFillGap:Object):void
		{
			firstRowTroopReadyObj ={};
			
			leftSideFill = leftSideFillGap;
			if(leftSideFill == null)
				leftSideFill ={};
			
			var allTroopArr:Array = BattleUnitPool.getTroopsOfSomeSide(BattleDefine.firstAtk);
			var offsetInfo:Object = BattleManager.instance.pSideAtk.getHeroTroopPosValue();
			
			for each(var singleTroop:CellTroopInfo in allTroopArr)
			{
				if(singleTroop == null)
					continue;
				singleTroop.logicStatus = LogicSatusDefine.lg_status_filling;
				singleTroop.playAction(ActionDefine.Action_Run,-1);
				
				Tweener.addTween(singleTroop,{x:singleTroop.x + BattleDisplayDefine.moveToCenterGap,time:Utility.getFrameByTime(BattleDisplayDefine.moveToCenterDuration),useFrames:true,
					transition:"linear",onComplete:singleTroopCenterMoveEnd,onCompleteParams:[singleTroop]});
				firstRowTroopReadyObj[singleTroop.troopIndex] = 0;
			}
		}
		
		/**
		 * 让单波敌人向中间移动 
		 * @param rightSideFillGap
		 */
		public function makeSingleWaveMoveToCenter(rightSideFillGap:Object):void
		{
			firstRowTroopReadyObj ={};
			var allTroopArr:Array = BattleUnitPool.getTroopsOfSomeSide(BattleDefine.secondAtk);
			
			rightSideFill = rightSideFillGap;
			leftSideFill ={};
			if(rightSideFill == null)
				rightSideFill ={};
			
			var offsetInfo:Object = BattleManager.instance.pSideDef.getHeroTroopPosValue();
			
			for each(var singleTroop:CellTroopInfo in allTroopArr)
			{
				if(singleTroop == null)
					continue;
				singleTroop.logicStatus = LogicSatusDefine.lg_status_filling;
				singleTroop.playAction(ActionDefine.Action_Run,-1);
				
				var realPositon:Point = getTroopPosNeed(singleTroop,false);
				var tempPt:Point = offsetInfo[singleTroop.troopIndex] as Point;
				if(tempPt)
				{
					realPositon.x += tempPt.x;
					realPositon.y += tempPt.y;
				}
				
				Tweener.addTween(singleTroop,{x:realPositon.x,y:realPositon.y,time:Utility.getFrameByTime(BattleDisplayDefine.nextWaveMoveToCenterDuration),useFrames:true,
					transition:"linear",onComplete:singleTroopCenterMoveEnd,onCompleteParams:[singleTroop]});
				firstRowTroopReadyObj[singleTroop.troopIndex] = 0;
			}
		}
		
		/**
		 *  让某个power的troop执行具体的补进
		 */
		public function makeTroopMoveParticularGap(moveGapInfo:Object,powerSide:PowerSide,troopInfo:CellTroopInfo = null):void
		{
			for(var key:String in moveGapInfo)					//所有的troop可以移动的距离
			{
				var singleTroopInfo:CellTroopInfo = BattleUnitPool.getTroopInfo(int(key));
				if(singleTroopInfo == null)
					continue;
				BattleStage.instance.troopLayer.makeSingleTroopFill(singleTroopInfo,int(moveGapInfo[key]),powerSide,troopInfo);
			}
		}
		
		/**
		 * 让某个单个troop补进 
		 */
		public function makeSingleTroopFill(singleTroopInfo:CellTroopInfo,gap:int,powerSide:PowerSide,troopInfo:CellTroopInfo = null):void
		{
			if(singleTroopInfo && gap > 0)
			{
				var oldOccupied:int = singleTroopInfo.occupiedCellStart;
				
				var singleCell:Cell;
				var realOccupidArray:Array = BattleFunc.getCellsOccupied(singleTroopInfo.troopIndex);
				for(var at:int = 0;at < realOccupidArray.length;at++)						//修改cell中保存的troop信息 
				{
					singleCell = BattleUnitPool.getCellInfo(int(realOccupidArray[at]));
					if(singleCell.troopInfo && singleCell.troopInfo.troopIndex == singleTroopInfo.troopIndex)			//如果当前指向的是自己 
						singleCell.troopInfo = null;
				}
				
				singleTroopInfo.logicStatus = LogicSatusDefine.lg_status_filling;
				
				singleTroopInfo.playAction(ActionDefine.Action_Run,-1);							//设置状态当前是在填补的过程中
				
				singleTroopInfo.occupiedCellStart = singleTroopInfo.occupiedCellStart - gap * BattleDefine.maxFormationYValue;
				if(troopInfo)
					singleTroopInfo.chainInvolved = troopInfo.chainInvolved;				//将补进的troop的chain设置为导致troop死亡的Chain
				
				realOccupidArray = BattleFunc.getCellsOccupied(singleTroopInfo.troopIndex);
				for(at = 0;at < realOccupidArray.length;at++)						//修改cell中保存的troop信息 
				{
					singleCell = BattleUnitPool.getCellInfo(int(realOccupidArray[at]));
					singleCell.troopInfo = singleTroopInfo;
				}
				
				if(singleTroopInfo.mcStatus == McStatusDefine.mc_status_running)
					makeTroopFill(singleTroopInfo,gap,oldOccupied);			//进行移动
			}
		}
		
		private function singleTroopCenterMoveEnd(troop:CellTroopInfo):void
		{
			if(troop == null)
				return;
			var canStartRound:Boolean = true;
			var troopIndexValue:int;
			if(troop.ownerSide == BattleDefine.firstAtk)
			{
				firstRowTroopReadyObj[troop.troopIndex] = 1;
				if(leftSideFill == null || !leftSideFill.hasOwnProperty(troop.troopIndex) || leftSideFill[troop.troopIndex] <= 0)
				{
					troop.logicStatus = LogicSatusDefine.lg_status_idle; 
					troop.playAction(ActionDefine.Action_Idle,-1);
				}
				else
				{
					makeSingleTroopFill(troop,leftSideFill[troop.troopIndex],BattleManager.instance.pSideAtk,null);
				}
				for each(troopIndexValue in firstRowTroopReadyObj)
				{
					if(troopIndexValue == 0)
					{
						canStartRound = false;
						break;
					}
				}
				if(canStartRound)
				{
					makeBattleBeginAfterOnCenter();
				}
			}
			else
			{
				firstRowTroopReadyObj[troop.troopIndex] = 1;
				if(rightSideFill == null || !rightSideFill.hasOwnProperty(troop.troopIndex) || rightSideFill[troop.troopIndex] <= 0)
				{
					troop.logicStatus = LogicSatusDefine.lg_status_idle;
					troop.playAction(ActionDefine.Action_Idle,-1);
				}
				else
				{
					makeSingleTroopFill(troop,rightSideFill[troop.troopIndex],BattleManager.instance.pSideDef,null);
				}
				
				for each(troopIndexValue in firstRowTroopReadyObj)
				{
					if(troopIndexValue == 0)
					{
						canStartRound = false;
						break;
					}
				}
				if(canStartRound)
				{
					makeBattleBeginAfterOnCenter();
				}
			}
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.refreshChoostTarget));
		}
		
		/**
		 *  双方跑到中间之后开始战斗
		 */
		private function makeBattleBeginAfterOnCenter():void
		{
			BattleManager.instance.status = OtherStatusDefine.battleOn;
			
			//攻击方的技能第一波的时候初始化
			if(!BattleInfoSnap.canFirstAtkGuanghuangWork)
			{
				BattleManager.guanghuanManager.makeAllSkillPrepared(BattleDefine.firstAtk);				//让所有的光环技能开始作用
			}
			if(!BattleInfoSnap.isNextTeamMoveEnd)					//防止被攻击方重复发动光环效果
			{
				//被攻击方的技能一直初始化
				BattleManager.guanghuanManager.makeAllSkillPrepared(BattleDefine.secondAtk);	
				filterDefenseInfoWhenOLCapTure();
			}
			
			BattleInfoSnap.canFirstAtkGuanghuangWork = true;
			BattleInfoSnap.isNextTeamMoveEnd = false;
			
			NextSupplyShow.instance.showSingleSupplyInfo();
			BattleManager.instance.startNewRound();
			
			for(var i:int = 0;i < BattleDefine.ranBattleCardGiveCount;i++)
				BattleManager.cardManager.handleNewBattleCardGened(UserBattleCardInfo.makeOneFakeCardInfo());
			
			BattleStage.instance.userChooseLayer.showChooseInfo(BattleDefine.firstAtk,BattleDefine.Range_singleArm);
			
			showSelfHeoGuide();
		}
		
		private function showSelfHeoGuide():void
		{
			if(BattleManager.instance.battleMode != BattleModeDefine.PVE_Multi && BattleManager.instance.battleMode != BattleModeDefine.PVE_DANRENFUBENWithLansquenet && 
				BattleManager.instance.battleMode != BattleModeDefine.PVP_Single && BattleManager.instance.battleMode != BattleModeDefine.PVE_Raid)
				return;
			
			var allHeroes:Array = BattleManager.instance.pSideAtk.allHeroInfoOnSide;
			var singleTroop:CellTroopInfo;
			for(var i:int = 0;i < allHeroes.length;i++)
			{
				singleTroop = allHeroes[i];
				if(singleTroop && singleTroop.isHero && singleTroop.attackUnit.contentHeroInfo.uid == GlobalData.owner.uid)
				{
					TroopDisplayFunc.showSelfHeroGuideArrow(singleTroop);
				}
			}
			
			//pvp阶段需要检查另一方英雄
			if(BattleManager.instance.battleMode == BattleModeDefine.PVP_Single)
			{
				allHeroes = BattleManager.instance.pSideDef.allHeroInfoOnSide;
				for(i = 0;i < allHeroes.length;i++)
				{
					singleTroop = allHeroes[i];
					if(singleTroop && singleTroop.isHero && singleTroop.attackUnit.contentHeroInfo.uid == GlobalData.owner.uid)
					{
						TroopDisplayFunc.showSelfHeroGuideArrow(singleTroop);
					}
				}
			}
		}
		
		private function filterDefenseInfoWhenOLCapTure():void
		{
			if(BattleManager.instance.battleMode != BattleModeDefine.PVP_OLCapTure)
			{
				return;
			}
			var singleHeroInfo:CellTroopInfo;
			var selfHeroes:Array = BattleFunc.getAllHeroInfo(BattleManager.instance.pSideDef);
			var singleHeroPos:Point;
			var hasTarget:Boolean = false;
			for(var i:int = 0; i < selfHeroes.length;i++)
			{
				singleHeroInfo = selfHeroes[i] as CellTroopInfo;
				if(singleHeroInfo == null)
					continue;
				if(singleHeroInfo && singleHeroInfo.isHero && singleHeroInfo.logicStatus == LogicSatusDefine.lg_status_dead)				
				{
					continue;
				}
				if(BattleFunc.checkHeroIsJianTaHero(singleHeroInfo))		//箭塔英雄不参与计算
					continue;
				singleHeroPos = BattleTargetSearcher.getRowColumnByCellIndex(singleHeroInfo.occupiedCellStart);
				hasTarget = BattleTargetSearcher.checkHasTroopAliveOnYValue(BattleManager.instance.pSideDef,singleHeroPos.y,singleHeroInfo.cellsCountNeed.y);
				if(!hasTarget)
				{
					singleHeroInfo.logicStatus = LogicSatusDefine.lg_status_dead;
				}
			}
		}
		
		/**
		 * 移动troop，让troop移动填充 移动完成之后发出消息处理
		 * @param troops						troop信息
		 * @param gap							移动距离
		 */
		public function makeTroopFill(troopInfo:CellTroopInfo,gap:int,oldOccupied:int):void
		{
			if(troopInfo == null)
				return;
			
			var distanceNeed:int = gap * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
			
			var targetPos:int = 0;
			
			var fillOffsetValue:Number = BattleFunc.checkMoveGapOffsetDistance(troopInfo.occupiedCellStart,oldOccupied,troopInfo.ownerSide);
			distanceNeed += fillOffsetValue;
			
			if(fillOffsetValue != 0)
			{
				troopInfo.attackUnit.attackDistance = BattleInfoSnap.getTroopRealAttackDistance(troopInfo);
			}
			
			if(troopInfo.ownerSide != BattleDefine.firstAtk)
			{
				distanceNeed = 0 - distanceNeed;
			}
			
			var targetX:Number = troopInfo.x + distanceNeed;
			var targetY:Number = troopInfo.y + 0;
			
			var result:Array = Tweener.getTweensWithValue(troopInfo);
			if(result && result.length > 0)
			{
				var xLeft:Number = 0;
				var yLeft:Number = 0;
				
				for each(var singleTempTween:Object in result)
				{
					if(singleTempTween)
					{
						if(singleTempTween.hasOwnProperty("x"))
						{
							xLeft = Number(singleTempTween["x"]);
							targetX += xLeft - troopInfo.x;
						}
						if(singleTempTween.hasOwnProperty("y"))
						{
							yLeft = Number(singleTempTween["y"]);
							targetY += yLeft - troopInfo.y;
						}
					}
				}
				Tweener.removeTweens(troopInfo);
			}
			
			var duration:Number = getTroopMoveDuration(Math.abs(targetX - troopInfo.x));
			
			Tweener.addTween(troopInfo,{x:targetX,y:targetY,time:Utility.getFrameByTime(duration),useFrames:true,transition:"linear",onComplete:singleTroopMovedDone,onCompleteParams:[troopInfo]});
			BattleInfoSnap.allMovingTroops[troopInfo.troopIndex] = 1;
		}
		
		/**
		 * 获得troopfill的时候需要的时间 
		 * @parma distanceNeed		需要移动距离
		 * @return 
		 */
		private function getTroopMoveDuration(distanceNeed:Number):Number
		{
			var retValue:Number = BattleDisplayDefine.troopMoveUnit * distanceNeed / BattleDisplayDefine.troopMoveDisPerUnit;
			return retValue;
		}
		
		private function getTroopMoveDuratonOfReborn(distanceNeed:Number):Number
		{
			var retValue:Number = BattleDisplayDefine.troopMoveUnit * distanceNeed / BattleDisplayDefine.troopMoveDisPerUnitOfReborn;
			return retValue;
		}
		
		/**
		 * @param troopIndex	需要移动的troop
		 * @param gap			移动的距离
		 */
		public function makeTroopVerticalFill(targetTroop:CellTroopInfo,gap:int):void
		{
			if(gap == 0)
				return;
			if(targetTroop == null || targetTroop.logicStatus == LogicSatusDefine.lg_status_dead)
				return;	
			
			var moveGap:Point = new Point(0,0);
			
			if(targetTroop.isHero)
			{
				var oldValue:int = BattleInfoSnap.getSingleHeroOldOffsetValue(targetTroop);
				if(oldValue != targetTroop.heroOffectValue)
				{
					moveGap = getHeroTroopOffsetValue(targetTroop,oldValue);
				}
			}
			
			var distanceNeed:int = gap * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal);
			
			var xLeft:Number = 0;
			var yLeft:Number = 0;
			var result:Array = Tweener.getTweensWithValue(targetTroop);
			
			var targetX:Number = targetTroop.x + moveGap.x;
			var targetY:Number = targetTroop.y + distanceNeed;
			
			for each(var singleTempTween:Object in result)
			{
				if(singleTempTween)
				{
					if(singleTempTween.hasOwnProperty("x"))
					{
						xLeft = Number(singleTempTween["x"]);
						targetX += xLeft - targetTroop.x;
					}
					if(singleTempTween.hasOwnProperty("y"))
					{
						yLeft = Number(singleTempTween["y"]);
						targetY += yLeft - targetTroop.y;
					}
				}
			}
			Tweener.removeTweens(targetTroop);
			
			BattleInfoSnap.allVerticalMovingTroops[targetTroop.troopIndex] = 1;
			BattleInfoSnap.allMovingTroops[targetTroop.troopIndex] = 1;
			
			Tweener.addTween(targetTroop,{x:targetX,y:targetY,time:Utility.getFrameByTime(BattleDisplayDefine.troopFillDurationVertical),useFrames:true,transition:"linear",onComplete:singleTroopMovedDone,onCompleteParams:[targetTroop,false]});
		}
		
		/**
		 * 单个troop移动完成  
		 */
		private function singleTroopMovedDone(troopInfo:CellTroopInfo,isHorizon:Boolean = true):void
		{
			if(BattleManager.instance.status != OtherStatusDefine.battleOn)
				return;
			if(troopInfo)
			{
				if(BattleInfoSnap.allMovingTroops.hasOwnProperty(troopInfo.troopIndex))
				{
					delete BattleInfoSnap.allMovingTroops[troopInfo.troopIndex];
				}
//				else
//				{
//					trace("may be error");
//				}
				var isTroopDead:Boolean = false;
				if(troopInfo.attackUnit.slotType != FormationElementType.ARROW_TOWER)
				{
					if(!troopInfo.isHero && troopInfo.totalHpValue == 0)
					{
						troopInfo.logicStatus = LogicSatusDefine.lg_status_dead;
						troopInfo.mcStatus = McStatusDefine.mc_status_idle;
						isTroopDead = true;
					}
					else if(troopInfo.isHero && !troopInfo.visible && troopInfo.troopVisibleOnBattle)
					{
						troopInfo.logicStatus = LogicSatusDefine.lg_status_dead;
						troopInfo.mcStatus = McStatusDefine.mc_status_idle;
						isTroopDead = true;
					}
				}
				if(isTroopDead)
				{
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				}
				else
				{
					troopInfo.logicStatus = LogicSatusDefine.lg_status_idle;
					troopInfo.playAction(ActionDefine.Action_Idle,-1);
					
					checkHeBingAfterBuJin(troopInfo);
					return;
					
					BattleManagerLogicFunc.checkHangUpDamageChains(troopInfo);
					if(isHorizon)
					{
						GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
					}
					else
					{
						delete BattleInfoSnap.allVerticalMovingTroops[troopInfo.troopIndex];
						var canCheckRoundStart:Boolean =  true;
						for(var singleMovingTroopIndex:String in BattleInfoSnap.allVerticalMovingTroops)
						{
							if(BattleInfoSnap.allVerticalMovingTroops[singleMovingTroopIndex] == 0)
							{
								canCheckRoundStart = false;
								break;
							}
						}
						if(canCheckRoundStart)
						{
							GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
						}
					}
				}
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.refreshChoostTarget));
			}
		}
		
		/**
		 * 判断某个y值是否可以用 
		 * @param yValue 			y值
		 * @return side				所在阵营
		 */
		public function checkUserCanMoveOnYValue(yValue:int,side:int,troopIndex:int):Boolean
		{
			var used:Boolean = true;
			
			var sameSide:Boolean = true;
			var singleUsedInfo:PosUsedCount;
			for(var singleYValue:String in yPathUseStatus)			//如果不是一方的
			{
				singleUsedInfo = yPathUseStatus[singleYValue];
				if(singleUsedInfo)
				{
					if(singleUsedInfo.usedSide != side && singleUsedInfo.curUsedCount > 0)
					{
						sameSide = false;
					}
				}
			}
			
			if(!sameSide)
			{
				return false;
			}
			
			if(!yPathUseStatus.hasOwnProperty(yValue))
			{
				singleUsedInfo = new PosUsedCount();
				singleUsedInfo.usedSide = side;
				yPathUseStatus[yValue] = singleUsedInfo;
			}
			else
			{
				singleUsedInfo = yPathUseStatus[yValue] as PosUsedCount;
				if(singleUsedInfo.usedSide == -1)
				{
					singleUsedInfo.usedSide = side;
				}
			}
			
			if(singleUsedInfo.usedSide == side)
			{
				singleUsedInfo.addUsedTroopindex(troopIndex);
			}
			else
			{
				used = false;
			}
			
			return used;
		}
		
		/**
		 * 清空y值使用的信息 
		 */
		public function clearYUsedInfo():void
		{
			yPathUseStatus ={};
		}
		
		/**
		 * 减少在某个y值上的使用值 
		 * @param yValue
		 */
		public function decreaseYPathUsedCount(yValue:int,troopIndex:int):void
		{
			var singleUsedInfo:PosUsedCount;
			singleUsedInfo = yPathUseStatus[yValue] as PosUsedCount;
			
			var hasYUseInfoLeft:Boolean = false;
			if(singleUsedInfo)
			{
				singleUsedInfo.removeUsedTroopIndex(troopIndex);
				if(singleUsedInfo.curUsedCount <= 0)
				{
					singleUsedInfo.removeAllCaptured();
					singleUsedInfo.usedSide = -1;
				}
			}
			var singleYvalue:String;
			for(singleYvalue in yPathUseStatus)
			{
				singleUsedInfo = yPathUseStatus[singleYvalue];
				if(singleUsedInfo && singleUsedInfo.usedSide >= 0)
				{
					hasYUseInfoLeft = true;
					break;
				}
			}
			if(!hasYUseInfoLeft)
			{
				for(singleYvalue in yPathUseStatus)
				{
					GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,
						new Event(BattleEventTagFactory.getWaitForSomeYPath(int(singleYvalue))));
				}
			}
		}
		
		/**
		 * y值变为free 
		 * @param event
		 * @param parmas
		 */
		public function yPathBeFree(event:Event,parmas:Array):void
		{
			GameEventHandler.removeListener(EventMacro.DAMAGE_WAIT_HANDELR,event.type,yPathBeFree);
			
			if(parmas == null || parmas.length < 1)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				return;
			}
			
			var sourceTroop:CellTroopInfo = parmas[0];
			
			if(sourceTroop == null || !sourceTroop.isHero || sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				return;
			}
			
			if(sourceTroop.logicStatus == LogicSatusDefine.lg_status_waitForPath)		
				sourceTroop.logicStatus = LogicSatusDefine.lg_status_idle;
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
		}
		
		/**
		 * 将副将移动到目的地进行攻击
		 * @param sourceTroop			发动攻击的副将
		 * @param targetCell			跑向的位置
		 * @param chainInfoArr			chain信息
		 * @param offsetValue			y方向上的便宜
		 * @param effectresId			
		 * @param normalTargets			
		 */
		public function makeHeroMoveToTarget(parmas:Array):void
		{
			var sourceTroop:CellTroopInfo = parmas[0];
			var targetCell:Cell = parmas[1];
			var chainInfoArr:Array = parmas[2];
			var offsetValue:int = parmas[3];
			var effectresId:int = parmas[4];
			var normalTargets:Array = parmas[5];
			var hasZhengDuiMuBiao:Boolean  = parmas[6];
			var singleTargetEffect:int = parmas[7];
//			if(singleTargetEffect == 0)
//				singleTargetEffect = 1433;
			
			var targetTroop:CellTroopInfo = targetCell.troopInfo;
			if(sourceTroop == null || targetTroop == null)
				return;
			
			//是否为攻击方
			var isAtk:Boolean = sourceTroop.ownerSide == BattleDefine.firstAtk;
			
			var targetPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(targetTroop.occupiedCellStart);
			targetPos.y += offsetValue;
			
			targetPos.x = 0;
			var sourcePos:Point = BattleTargetSearcher.getRowColumnByCellIndex(sourceTroop.occupiedCellStart);
			var moveGap:Point = getGapOfTroop(sourcePos,targetPos,isAtk,sourceTroop);
			
			sourceTroop.logicStatus = LogicSatusDefine.lg_status_filling;
			sourceTroop.playAction(ActionDefine.Action_Run,-1);
			
//			moveGap.x = 0;
			var moveTime:Number = getHeroMoveTime(moveGap);
			
			TroopFunc.showMoraleBar(sourceTroop,false);
			
			BattleInfoSnap.moveForwardHero[sourceTroop.troopIndex] = 0;
			
			Tweener.addTween(sourceTroop,{x:sourceTroop.x+moveGap.x,y:sourceTroop.y+moveGap.y,time:Utility.getFrameByTime(moveTime),useFrames:true,transition:"linear",onComplete:heroReachedTarget,
				onCompleteParams:[sourceTroop.x,sourceTroop.y,sourceTroop,chainInfoArr,targetPos.y,targetTroop,effectresId,normalTargets,hasZhengDuiMuBiao,
					singleTargetEffect,targetCell]});
		}
		
		/**
		 * 让hero移动的施放奥义的位置 
		 * @param sourceTroop
		 * @param targetCell
		 * @param chainInfoArr
		 * @param offsetValue
		 * @param effectid
		 * @param normalTargets
		 */
		public function makeHeroMoveToAoYiPos(parmas:Array):void
		{
			var sourceTroop:CellTroopInfo = parmas[0];
			var targetCell:Cell = parmas[1];
			var chainInfoArr:Array = parmas[2];
			var offsetValue:int = parmas[3];
			var effectid:int = parmas[4];
			var normalTargets:Array = parmas[5];
			var hasZhengDuiMuBiao:Boolean  = parmas[6];
			var singleTargetEffect:int = parmas[7];
			var aoyiTargetTroop:CellTroopInfo = parmas[8];
			
			if(sourceTroop == null || targetCell == null)
				return;
			
			var sourceTroopPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(sourceTroop.occupiedCellStart);
			var targetTroopPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(targetCell.index);
			targetTroopPos.y += offsetValue;
			var disGap:Point = new Point(targetTroopPos.x - sourceTroopPos.x,targetTroopPos.y - sourceTroopPos.y);
			disGap.x = disGap.x * (BattleDisplayDefine.cellGapHorizonal + BattleDisplayDefine.cellWidth);
			disGap.y = disGap.y * (BattleDisplayDefine.cellGapVertocal + BattleDisplayDefine.cellHeight);
			if(sourceTroop.ownerSide == BattleDefine.firstAtk)
			{
				disGap.x = 0 - disGap.x;
			}
			
			sourceTroop.logicStatus = LogicSatusDefine.lg_status_filling;
			sourceTroop.playAction(ActionDefine.Action_Run,-1);
			
			var moveTime:Number = getHeroMoveTime(disGap);
			TroopFunc.showMoraleBar(sourceTroop,false);
			
			Tweener.addTween(sourceTroop,{x:sourceTroop.x+disGap.x,y:sourceTroop.y+disGap.y,time:Utility.getFrameByTime(moveTime),useFrames:true,transition:"linear",onComplete:heroReachedTarget,
				onCompleteParams:[sourceTroop.x,sourceTroop.y,sourceTroop,chainInfoArr,targetTroopPos.y,aoyiTargetTroop,effectid,normalTargets,hasZhengDuiMuBiao,
					singleTargetEffect,targetCell]});
			BattleStage.instance.showAoYiLayer(true);
		}
		
		/**
		 * 英雄移动到攻击目标之后  
		 * @param originX					起始的位置x
		 * @param originY					起始的位置y
		 * @param sourceTroop				起始troop
		 * @param targetTroop				目标troop
		 */
		private function heroReachedTarget(originX:Number,originY:Number,sourceTroop:CellTroopInfo,chainInfoArr:Array,yValue:int,
					targetTroop:CellTroopInfo,effectresId:int,normalTargets:Array,hasZhengDuiMuBiao:Boolean,singleEffect:int,targetCell:Cell):void
		{
			TroopDisplayFunc.playHeroAttackEffect(sourceTroop,targetTroop,chainInfoArr,effectresId,normalTargets,hasZhengDuiMuBiao,singleEffect,targetCell);
			
			//增加监听器，让英雄回到初始位置
			GameEventHandler.addListener(EventMacro.DAMAGE_WAIT_HANDELR,BattleEventTagFactory.getHeroWaitGetBackTag(sourceTroop),
				sourceTroop.makeHeroBackToPos,[originX,originY,yValue]);
		}
		
		/**
		 * hero归位 
		 * @param sourceTroop
		 */
		public function heroGetBack(sourceTroop:CellTroopInfo):void
		{
			sourceTroop.heroWaitTimeUp();
			//如果此troop当前正在播放奥义
			if(BattleManager.aoyiManager.curWaitHero && BattleManager.aoyiManager.curWaitHero.troopIndex == sourceTroop.troopIndex)
			{
				BattleManager.aoyiManager.curWaitHero = null;
			}
			
			BattleInfoSnap.moveForwardHero[sourceTroop.troopIndex] = 1;
			
			sourceTroop.logicStatus = LogicSatusDefine.lg_status_idle;
			sourceTroop.playAction(ActionDefine.Action_Idle,-1);
			TroopFunc.showMoraleBar(sourceTroop,true);
			
			//隐藏
			AoYiManager.hideAoyiBackEffect();
			TroopDisplayFunc.resumeTroopHideOnAoYi();
			TroopDisplayFunc.remumeTargetAlpha();
			BattleStage.instance.showAoYiLayer(false);
			
			//troop归位后判断是否继续攻击
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
		}
		
		/**
		 * 获得hero移动到目标所需的时间
		 * @return 
		 */
		private function getHeroMoveTime(moveGap:Point):Number
		{
			if(moveGap == null)
				return 0;
			var dis:Number = Point.distance(moveGap,new Point(0,0));
			return dis / BattleDisplayDefine.heroMoveSpeed * BattleDisplayDefine.moveTimeUnit;
		}
		
		/**
		 * 获得两个troopPoint之间的距离 	
		 * @return 
		 */
		public function getGapOfTroop(sourcePos:Point,targetPos:Point,atk:Boolean,troopInfo:CellTroopInfo):Point
		{
			var offsetValue:int = troopInfo.heroOffectValue;
			var difGap:Point = new Point(targetPos.x + sourcePos.x,targetPos.y - sourcePos.y);
			
			difGap.x = Math.abs(difGap.x);
			difGap.x -= BattleDisplayDefine.heroMoveUnitGap;
			
			//修改
			var powerSide:PowerSide = atk ? BattleManager.instance.pSideAtk : BattleManager.instance.pSideDef;
			var cellPt:Point = BattleTargetSearcher.getRowColumnByCellIndex(troopInfo.occupiedCellStart);
			var maxValue:int = getMaxXValueOfHero(powerSide,troopInfo,targetPos.y);
			
			maxValue = Math.max(maxValue,BattleDisplayDefine.minCellCountLeftForHero);
			
			difGap.x = powerSide.xMaxValue - maxValue - 1;
			
			if(offsetValue == OtherStatusDefine.offsetBack)
				difGap.x += BattleDisplayDefine.heroStagDis;
			difGap.x *= atk ? 1 : -1;
			
			difGap.x = difGap.x * (BattleDisplayDefine.cellGapHorizonal + BattleDisplayDefine.cellWidth);
			difGap.y = difGap.y * (BattleDisplayDefine.cellGapVertocal + BattleDisplayDefine.cellHeight);
			
			atk ?  difGap.x += BattleDisplayDefine.heroDefaultBackDis : difGap.x -= BattleDisplayDefine.heroDefaultBackDis;
			
			return difGap;
		}
		
		/**
		 * 获得某个hero对应的最大的x值
		 * @param troop				相应的troop
		 * @param yValue			y值
		 * @return 
		 */
		public function getMaxXValueOfHero(targetPowerSide:PowerSide,troop:CellTroopInfo,yValue:int):int
		{
			var retValue:int = 0;
			var curValue:int = 0;			
			
			if(troop == null || targetPowerSide == null)
				return 0;
			
			for(var i:int = 0; i < troop.cellsCountNeed.y; i++)
			{
				curValue = getMaxValueOfYValue(targetPowerSide,yValue + i);
				retValue = Math.max(retValue,curValue);
			}
			return retValue;
		}
		
		/**
		 * 获得某个点对应的最大x值 
		 * @param power
		 * @param yValue		y值
		 * @return 
		 */
		private function getMaxValueOfYValue(power:PowerSide,yValue:int):int
		{
			var retValue:int = 0;
			var startIndex:int = BattleFunc.getPowerSideStartIndex(power);
			
			var curCell:Cell = BattleUnitPool.getCellInfo(startIndex + yValue);
			while(1)
			{
				if(curCell == null || curCell.troopInfo == null || curCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead || curCell.troopInfo.isHero)
					break;
				retValue++;
				curCell = BattleUnitPool.getCellInfo(startIndex + yValue + BattleDefine.maxFormationYValue * retValue);
			}
			
			return retValue;
		}
		
		/**
		 * 获得hero偏移的量 
		 * @param heroTroop
		 * @return 
		 */
		public function getHeroTroopOffsetValue(heroTroop:CellTroopInfo,oldValue:int):Point
		{
			var moveGap:Point = new Point;
			if(heroTroop == null || !heroTroop.isHero || heroTroop.heroOffectValue == oldValue)
			{
				return moveGap;
			}
			
			if(heroTroop.ownerSide == BattleDefine.firstAtk)
			{
				if(heroTroop.heroOffectValue == OtherStatusDefine.noOffsetValue)			//变成无补进
				{
					moveGap.x = BattleDisplayDefine.heroStagDis * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
					moveGap.y = 0;
				}
				else
				{
					moveGap.x = 0 - BattleDisplayDefine.heroStagDis * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
					moveGap.y = 0;
				}
			}
			else
			{
				if(heroTroop.heroOffectValue == OtherStatusDefine.noOffsetValue)			//变成无补进
				{
					moveGap.x = 0 - BattleDisplayDefine.heroStagDis * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
					moveGap.y = 0;
				}
				else
				{
					moveGap.x = BattleDisplayDefine.heroStagDis * (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
					moveGap.y = 0;
				}
			}
			return moveGap;
		}
		
		public function clearInfo():void
		{
			rightSideFill ={};
			leftSideFill ={};
			yPathUseStatus ={};
			firstRowTroopReadyObj ={};
		}
		
	}
}

class PosUsedCount
{
	//当前被使用的side
	public var usedSide:int = -1;		
	
	public var curOccupidTroop:Array=[];
	
	public function PosUsedCount()
	{
		curOccupidTroop =[];
	}
	
	/**
	 * 当前已经使用的count 
	 */
	public function get curUsedCount():int
	{
		return curOccupidTroop.length;
	}
	
	public function addUsedTroopindex(tIndex:int):void
	{
		if(curOccupidTroop.indexOf(tIndex) == -1)
		{
			curOccupidTroop.push(tIndex);
		}
	}
	
	public function removeUsedTroopIndex(tIndex:int):void
	{
		var curIndex:int = curOccupidTroop.indexOf(tIndex);
		if(curIndex >= 0)
		{
			curOccupidTroop.splice(curIndex,1);
		}
	}
	
	public function removeAllCaptured():void
	{
		curOccupidTroop =[];
	}
	
}