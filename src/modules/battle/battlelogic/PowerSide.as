package modules.battle.battlelogic
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import caurina.transitions.Tweener;
	
	import defines.FormationSlotInfo;
	
	import eventengine.GameEventHandler;
	
	import macro.ActionDefine;
	import macro.BattleDisplayDefine;
	import macro.EventMacro;
	import macro.FormationElementType;
	
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.BattleValueDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battledefine.RandomValueService;
	import modules.battle.battledefine.TimeGapDefine;
	import modules.battle.battleevents.CheckAttackEvent;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.funcclass.TroopInitClearFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.stage.BattleStage;
	import modules.battle.utils.BattleEventTagFactory;

	/**
	 * 表示一方势力 
	 * @author SDD
	 */
	public class PowerSide
	{
		
		private var _yMaxValue:int = 0;				
		
		private var _xMaxValue:int = 0;				
		
		private var _curRow:int = 0;					//当前的
		
		private var _maxRowIndex:int = 0;			//保存最后一行row的index
		
		private var _status:int = 0;					//保存当前状态，是否战斗中
		
		public var isFirstAtk:Boolean;					//是否是先手
		
		public var curCheckRow:int = 0;					//当前
		
		public var shuaiGuaiCheckRowIndex:int = BattleDefine.shuaGuaiTroopLength;		//刷怪判断的最大排数
		
		private var _allHeroInfoOnSide:Array=[];
		
		public function PowerSide(first:Boolean = true)
		{
			this.isFirstAtk = first;
		}
		
		public function clear():void
		{
			curCheckRow = 0;
			_allHeroInfoOnSide =[];
		}
		
		public function get allHeroInfoOnSide():Array
		{
			if(_allHeroInfoOnSide.length <= 0)
			{
				var allTroops:Array = BattleUnitPool.getAllTroops();
				var singleTroop:CellTroopInfo;
				for(var i:int = 0; i < allTroops.length;i++)
				{
					singleTroop = allTroops[i] as CellTroopInfo;
					if(singleTroop == null)
					{
						continue;
					}
					if((singleTroop.ownerSide == BattleDefine.firstAtk) != this.isFirstAtk)
						continue;
					if(singleTroop.isHero)
					{
						_allHeroInfoOnSide.push(singleTroop);
					}
				}
			}
			return _allHeroInfoOnSide;
		}
		
		/**
		 * 让某一竖排的troop进入等待状态 
		 * @param rowIndex
		 */
		public function initStaggerTimeByVertical(rowIndex:int):void
		{
			var curRowArr:Array = BattleFunc.particularTroopsVertical(rowIndex,this);
			if(curRowArr == null || curRowArr.length == 0)
			{
				return;
			}
			
			var gapTime:int = 0;
			var randomGapValue:Number; 
			for each(var singleTroopInfo:CellTroopInfo in curRowArr)
			{
				if(singleTroopInfo == null || singleTroopInfo.isHero || !singleTroopInfo.troopVisibleOnBattle 
					|| singleTroopInfo.logicStatus == LogicSatusDefine.lg_status_dead)
					continue;
				
				randomGapValue = RandomValueService.getRandomValue(RandomValueService.RD_ATKRANDOM,singleTroopInfo.troopIndex);
				
				if(randomGapValue <= BattleValueDefine.troopHavaGapProbility)
				{
					gapTime = BattleValueDefine.troopAttackGapTime;
				}
				else
				{
					gapTime = 0;
				}
				TroopFunc.initTroopStaggerTimer(singleTroopInfo,true,gapTime);
			}
		}
		
		/**
		 * 进行攻击 ,只是在某个round开始的时候调用一次
		 */
		public function generateAtk(rowIndex:int):Boolean
		{
			var isAtkGenedSuccess:Boolean = false;
			this.curCheckRow = rowIndex;
			
			var tempTroopInfo:CellTroopInfo;
			var curRowArr:Array;
			if(BattleInfoSnap.isAoYiRound)
			{
				curRowArr = BattleManager.aoyiManager.waitTroops;
				curRowArr.sortOn("troopIndex");							//对播放的troop进行排序，保证双方播放顺序一致
			}
			else
			{
				curRowArr = BattleFunc.particularTroopsVertical(rowIndex,this);
			}
			if(curRowArr == null || curRowArr.length == 0)
			{
				return isAtkGenedSuccess;
			}
			
			var i:int = 0;
			for(i = 0; i < curRowArr.length; i++)					//这一列的每个单元进行攻击
			{
				tempTroopInfo = curRowArr[i] as CellTroopInfo;
				if(tempTroopInfo == null)
				{
					continue;
				}
				if(!tempTroopInfo.isHero && tempTroopInfo.logicStatus == LogicSatusDefine.lg_status_dead)
					continue;
				if(tempTroopInfo.checkAttack())
				{
					isAtkGenedSuccess = true;
				}
			}
			return isAtkGenedSuccess;
		}
		
		/**
		 * 判断是否有某一行没有正对目标 
		 * @return 
		 */
		public function hasHorizonalMissTarget():TroopMoveVerticalCheckInfo
		{
			var retValue:TroopMoveVerticalCheckInfo = new TroopMoveVerticalCheckInfo;
			
			var hasTarget:Boolean = false;
			var targetCrossed:Boolean = false;			//目标是否穿梭
			
			var opponentSide:PowerSide;
			if(this.isFirstAtk)
				opponentSide = BattleManager.instance.pSideDef;
			else
				opponentSide = BattleManager.instance.pSideAtk;
			
			var singleHeroInfo:CellTroopInfo;
			var selfHeroes:Array = BattleFunc.getAllHeroInfo(this);
			var singleHeroPos:Point;
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
				
				//如果此herocell没有死亡，进行判断
				singleHeroPos = BattleTargetSearcher.getRowColumnByCellIndex(singleHeroInfo.occupiedCellStart);
				hasTarget = BattleTargetSearcher.checkHasTroopAliveOnYValue(opponentSide,singleHeroPos.y,singleHeroInfo.cellsCountNeed.y);
				if(!hasTarget)
				{
					retValue.hastarget = false;
					if(!targetCrossed)
					{
						//此y值上对应的目标
						var targetCell:Cell = BattleTargetSearcher.getTargetFromSomeIndex(opponentSide,singleHeroPos.y,100);
						if(targetCell != null)
						{
							//对应目标的位置
							var targetCellPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(targetCell.index);
							
							var minYValue:int = Math.min(targetCellPos.y,singleHeroPos.y);
							var maxYValue:int = Math.max(targetCellPos.y,singleHeroPos.y);
							
							for(var yIndex:int = minYValue + 1; yIndex < maxYValue; yIndex++)
							{
								var leftCheck:Boolean = BattleTargetSearcher.checkHasTroopAliveOnYValue(this,yIndex,1);
								var rightCheck:Boolean = BattleTargetSearcher.checkHasTroopAliveOnYValue(opponentSide,yIndex,1);
								if(!leftCheck && !rightCheck)		
								{
									targetCrossed = true;
									retValue.targetcross = true;
									break;
								}
							}
							if(targetCrossed)
								break;
						}
					}
				}
				if(hasTarget)			
				{
					continue;
				}
			}
			
			return retValue;
		}
		
		/**
		 * 处理英雄死亡时候需要补进的情形 
		 * @return 补进时间
		 */
		public function responToDeadHero():int
		{
			var needTime:int = 0;
			var selfHeroes:Array = BattleFunc.getAllHeroInfo(this);
			var singleHeroInfo:CellTroopInfo;
			
			var moveGapDefine:Object={};
			
			var deadCount:int = 0;					//已经死亡的英雄数量
			var deadColumns:Array=[];
			var leftColumns:Array=[];			//未死亡的英雄column逻辑序列
			var leftHeroTroop:Array=[];		//未死亡英雄
			
			var curTotalCount:int = selfHeroes.length;						//当前横排数
			
			var realCurIndex:int = 0;
			for(var i:int = 0; i < selfHeroes.length;i++)
			{
				singleHeroInfo = selfHeroes[i] as CellTroopInfo;
				//箭塔英雄不参加判定
				if(singleHeroInfo == null || BattleFunc.checkHeroIsJianTaHero(singleHeroInfo))
					continue;
				if(singleHeroInfo && singleHeroInfo.isHero && singleHeroInfo.logicStatus == LogicSatusDefine.lg_status_dead)
				{
					realCurIndex++
					deadColumns.push(singleHeroInfo);
					deadCount += singleHeroInfo.cellsCountNeed.y;
				}
				else if(singleHeroInfo && singleHeroInfo.isHero)
				{
					leftColumns.push(realCurIndex++);		//保存英雄没有死亡的行
					leftHeroTroop.push(singleHeroInfo);
				}
			}
			
			var leftStartOIndex:int = 0;		//检查过后，整个阵型向下移动的距离 	
			if(deadCount > 0)	
			{
				if(deadCount % 2 == 0)
				{
					leftStartOIndex += deadCount / 2;
				}
				else
				{
					if(curTotalCount % 2 == 0)
						leftStartOIndex += (deadCount - 1) / 2;
					else
						leftStartOIndex += (deadCount + 1) / 2;
				}
			}
			else
			{
				return 0;
			}
			
			var curPos:Point;
			for(var l:int = 0; l < leftColumns.length;l++)
			{
				var singleColumnIndex:int = leftColumns[l];
				singleHeroInfo = leftHeroTroop[l] as CellTroopInfo;
				curPos = BattleTargetSearcher.getRowColumnByCellIndex(singleHeroInfo.occupiedCellStart);
				
				for(var testIndex:int = 0; testIndex < singleHeroInfo.cellsCountNeed.y;testIndex++)	//一个多格子英雄对应的所有横行都移动同样的距离
					moveGapDefine[curPos.y + testIndex] = l - singleColumnIndex + leftStartOIndex;
			}
			
			var allTroopMovedInfo:Object={};							//所有的troop信息，包含所有的移动距离
			var curColumnMoveGap:int;
			var singleTroopArr:Array;
			var singleTroop:CellTroopInfo;
			for(var key:String in moveGapDefine)
			{
				curColumnMoveGap = moveGapDefine[key];
				if(curColumnMoveGap == 0)
					continue;
				singleTroopArr = BattleFunc.particularTroopsHorizon(int(key),this,true);
				for each(singleTroop in singleTroopArr)
				{
					if(singleTroop && !allTroopMovedInfo.hasOwnProperty(singleTroop.troopIndex))
					{
						if(singleTroop.logicStatus == LogicSatusDefine.lg_status_dead)
							continue;
						if(!singleTroop.isHero && singleTroop.totalHpValue <= 0)
							continue;
						allTroopMovedInfo[singleTroop.troopIndex] = curColumnMoveGap;
					}
				}
			}
			
			var singleCell:Cell;
			var singleRealTroop:CellTroopInfo;
			var realOccupidArray:Array;
			
			var moved:Boolean = false;
			var at:int = 0;
			
			var heroNoMoveObj:Object={};				//不移动的hero集合
			var moveDistance:int = 0;
			
			var toBeCheck:Boolean = false;
			for(at = 0; at < selfHeroes.length;at++)
			{
				singleRealTroop = selfHeroes[at];
				if(!singleRealTroop || !singleRealTroop.isHero || singleRealTroop.logicStatus == LogicSatusDefine.lg_status_dead)
					continue;
				if(BattleFunc.checkHeroIsJianTaHero(singleRealTroop))
					continue;
				moveDistance = 0;
				if(allTroopMovedInfo.hasOwnProperty(singleRealTroop.troopIndex))
					moveDistance = int(allTroopMovedInfo[singleRealTroop.troopIndex]);
				if(moveDistance == 0)
				{
					toBeCheck = true;
					heroNoMoveObj[singleRealTroop.troopIndex] = 1;
				}
			}
			if(toBeCheck)
			{
				for(at = 0; at < selfHeroes.length;at++)
				{
					singleRealTroop = selfHeroes[at];
					if(!singleRealTroop || !singleRealTroop.isHero || singleRealTroop.logicStatus == LogicSatusDefine.lg_status_dead)
						continue;
					singleRealTroop.heroOffectValue = BattleInfoSnap.getSingleHeroOldOffsetValue(singleRealTroop);
				}
			}
			if(toBeCheck)
			{
				var quilified:Boolean = false;
				var checkIndex:int = 0;
				var curOffsetValue:int;
				var oldOffsetValue:int;
				var troopOffectBack:Object={};			//保存当前位置
				if(!quilified)					//起始部分是不补进，测试是否成功
				{
					quilified = true;
					curOffsetValue = OtherStatusDefine.noOffsetValue;
					for(checkIndex = 0;checkIndex < selfHeroes.length;checkIndex++)
					{
						singleTroop = selfHeroes[checkIndex] as CellTroopInfo;
						if(singleTroop == null || !singleTroop.isHero || singleTroop.logicStatus == LogicSatusDefine.lg_status_dead)
							continue;
						oldOffsetValue = singleTroop.heroOffectValue;
						troopOffectBack[singleTroop.troopIndex] = oldOffsetValue;
						if(curOffsetValue == OtherStatusDefine.noOffsetValue)
						{
							singleTroop.heroOffectValue = OtherStatusDefine.offsetBack;
						}
						else
						{
							singleTroop.heroOffectValue = OtherStatusDefine.noOffsetValue;
						}
						if(heroNoMoveObj.hasOwnProperty(singleTroop.troopIndex))
						{
							if(singleTroop.heroOffectValue != oldOffsetValue)
							{
								quilified = false;
								break;
							}
						}
						curOffsetValue = singleTroop.heroOffectValue;
					}
				}
				
				if(!quilified)					//起始部分是不补进，测试是否成功
				{
					
					for(var backIndex:String in troopOffectBack)					//恢复原来的
					{
						singleTroop = BattleUnitPool.getTroopInfo(int(backIndex));
						if(singleTroop)	
							singleTroop.heroOffectValue = int(troopOffectBack[backIndex]);
					}
					
					quilified = true;
					curOffsetValue = OtherStatusDefine.offsetBack;
					for(checkIndex = 0;checkIndex < selfHeroes.length;checkIndex++)
					{
						singleTroop = selfHeroes[checkIndex] as CellTroopInfo;
						if(singleTroop == null || !singleTroop.isHero || singleTroop.logicStatus == LogicSatusDefine.lg_status_dead)
							continue;
						oldOffsetValue = singleTroop.heroOffectValue;
						if(curOffsetValue == OtherStatusDefine.noOffsetValue)
						{
							singleTroop.heroOffectValue = OtherStatusDefine.offsetBack;
						}
						else
						{
							singleTroop.heroOffectValue = OtherStatusDefine.noOffsetValue;
						}
						if(heroNoMoveObj.hasOwnProperty(singleTroop.troopIndex))
						{
							if(singleTroop.heroOffectValue != oldOffsetValue)
							{
								quilified = false;
								break;
							}
						}
						curOffsetValue = singleTroop.heroOffectValue;
					}
				}
			}
			
			for(var singleIndex:String in allTroopMovedInfo)
			{
				moveDistance = int(allTroopMovedInfo[singleIndex]);
				if(moveDistance == 0)
					continue;
				singleRealTroop = BattleUnitPool.getTroopInfo(int(singleIndex));
				
				if(singleRealTroop == null || singleRealTroop.logicStatus == LogicSatusDefine.lg_status_dead)
					continue;
				if(!singleRealTroop.isHero && singleRealTroop.totalHpValue <= 0)
					continue;
				
				realOccupidArray = BattleFunc.getCellsOccupied(singleRealTroop.troopIndex);
				for(at = 0;at < realOccupidArray.length;at++)						//修改cell中保存的troop信息 
				{
					singleCell = BattleUnitPool.getCellInfo(int(realOccupidArray[at]));
					if(singleCell.troopInfo && singleCell.troopInfo.troopIndex == singleRealTroop.troopIndex)			//如果当前指向的是自己 
						singleCell.troopInfo = null;
				}
				
				var oldLogicStatus:int = singleRealTroop.logicStatus;
				singleRealTroop.logicStatus = LogicSatusDefine.lg_status_filling;
				singleRealTroop.occupiedCellStart = singleRealTroop.occupiedCellStart + moveDistance;
				
				realOccupidArray = BattleFunc.getCellsOccupied(singleRealTroop.troopIndex);
				for(at = 0;at < realOccupidArray.length;at++)						//修改cell中保存的troop信息 
				{
					singleCell = BattleUnitPool.getCellInfo(int(realOccupidArray[at]));
					singleCell.troopInfo = singleRealTroop;
				}
				
				moved = true;
				
				singleRealTroop.playAction(ActionDefine.Action_Run,-1);		//播放跑动动画
				
				BattleStage.instance.troopLayer.makeTroopVerticalFill(singleRealTroop,moveDistance);
			}
			
			//清除掉已经检查过的troop信息
			for each(var deadHeroTroop:CellTroopInfo in deadColumns)
			{
				if(deadHeroTroop)
				{
					realOccupidArray = BattleFunc.getCellsOccupied(deadHeroTroop.troopIndex);
					for(at = 0;at < realOccupidArray.length;at++)						//修改cell中保存的troop信息 
					{
						singleCell = BattleUnitPool.getCellInfo(int(realOccupidArray[at]));
						if(singleCell.troopInfo && singleCell.troopInfo.troopIndex == deadHeroTroop.troopIndex && singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead)			//如果当前指向的是自己 
							singleCell.troopInfo = null;
					}
				}
			}
			
			return moved ? TimeGapDefine.HeroDeadFillTime : 0;
		}
		
		/**
		 * 调整英雄左右位置，错落有致排列 
		 */
		public function adjustHeroPos(change:Boolean = false):void
		{
			var selfHeroes:Array = BattleFunc.getAllHeroInfo(this);
			var singleHeroTroop:CellTroopInfo;
			var curOffset:int = -1;
			var oldValue:int = 0;
			var moveGap:Point;
			for(var i:int = 0; i < selfHeroes.length;i++)
			{
				singleHeroTroop = selfHeroes[i] as CellTroopInfo;
				if(singleHeroTroop && singleHeroTroop.logicStatus != LogicSatusDefine.lg_status_dead)
				{
					oldValue = singleHeroTroop.heroOffectValue;
					if(curOffset == -1)
					{
						curOffset = singleHeroTroop.heroOffectValue;			  	
					}
					else
					{
						if(curOffset == 0)
						{
							singleHeroTroop.heroOffectValue = OtherStatusDefine.offsetBack;
						}
						else
						{
							singleHeroTroop.heroOffectValue = OtherStatusDefine.noOffsetValue;
						}
						curOffset = singleHeroTroop.heroOffectValue;
					}
					if(change)
					{
						moveGap = BattleStage.instance.troopLayer.getHeroTroopOffsetValue(singleHeroTroop,oldValue);
						singleHeroTroop.x += moveGap.x;
						
						if(isFirstAtk)
							singleHeroTroop.x -= BattleDisplayDefine.heroDefaultBackDis;
						else
							singleHeroTroop.x += BattleDisplayDefine.heroDefaultBackDis;
						
					}
				}
			}
		}
		
		/**
		 * 调整某个具体的英雄
		 * @param point
		 */
		public function getHeroTroopPosValue():Object
		{
			var retValue:Object={};
			
			var selfHeroes:Array = BattleFunc.getAllHeroInfo(this);
			var singleHeroTroop:CellTroopInfo;
			var curOffset:int = -1;
			var oldValue:int = 0;
			var moveGap:Point;
			for(var i:int = 0; i < selfHeroes.length;i++)
			{
				singleHeroTroop = selfHeroes[i] as CellTroopInfo;
				if(singleHeroTroop && singleHeroTroop.logicStatus != LogicSatusDefine.lg_status_dead)
				{
					oldValue = singleHeroTroop.heroOffectValue;
					if(curOffset == -1)
					{
						curOffset = singleHeroTroop.heroOffectValue;			  	
					}
					else
					{
						if(curOffset == 0)
						{
							singleHeroTroop.heroOffectValue = OtherStatusDefine.offsetBack;
						}
						else
						{
							singleHeroTroop.heroOffectValue = OtherStatusDefine.noOffsetValue;
						}
						curOffset = singleHeroTroop.heroOffectValue;
					}
					var singleTroopAdjustValue:Point = new Point;
					moveGap = BattleStage.instance.troopLayer.getHeroTroopOffsetValue(singleHeroTroop,oldValue);
					singleTroopAdjustValue.x += moveGap.x;
					
					if(isFirstAtk)
						singleTroopAdjustValue.x -= BattleDisplayDefine.heroDefaultBackDis;
					else
						singleTroopAdjustValue.x += BattleDisplayDefine.heroDefaultBackDis;
					
					retValue[singleHeroTroop.troopIndex] = singleTroopAdjustValue;
					
				}
			}
			
			return retValue;
		}
		
		public function get status():int
		{
			return _status;
		}

		public function set status(value:int):void
		{
			_status = value;
		}

		public function get curRow():int
		{
			return _curRow;
		}

		public function set curRow(value:int):void
		{
			_curRow = value;
		}
		
		/**
		 * 得到阵型的最后一个row Index 
		 * @return 
		 * 
		 */
		public function get maxRowIndex():int
		{
			return _maxRowIndex;
		}
		
		/**
		 * 刷新当前的最大排数 
		 */
		public function refreshLastRowIndex():void
		{
			var oldMaxRowIndex:int = _maxRowIndex;
			
			var startCal:int = xMaxValue - 2;				//不包括英雄的最后一排
			
			var hasCellOnRow:Boolean = false;
			while(!hasCellOnRow && startCal >= 0)
			{
				var cellIndexonRow:Array = BattleFunc.particularTroopsVertical(startCal,this);
				for(var i:int = 0; i < cellIndexonRow.length;i++)
				{
					var troopinfo:CellTroopInfo = cellIndexonRow[i] as CellTroopInfo;
					if(troopinfo && troopinfo.logicStatus != LogicSatusDefine.lg_status_dead && 
						troopinfo.attackUnit.slotType != FormationElementType.ARROW_TOWER)				//如果没有死亡
					{
						if(troopinfo.totalHpValue == 0 && !troopinfo.isHero)
						{
							troopinfo.logicStatus = LogicSatusDefine.lg_status_dead;
						}
						else
						{
							hasCellOnRow = true;
							break;
						}
					}
				}
				if(!hasCellOnRow)
					startCal--;
			}
			_maxRowIndex = startCal;					//更改最后一排
			if(!this.isFirstAtk)
			{
				BattleStage.instance.troopLayer.checkNextWaveMoveToDaiJi();
			}
			
			//如果是离线pvp并且有最后一排发生变化
			if(!this.isFirstAtk && BattleManager.instance.battleMode == BattleModeDefine.PVP_OLCapTure)
			{
				if(oldMaxRowIndex > _maxRowIndex)				
				{
					for(var index:int = _maxRowIndex + 1;index <= oldMaxRowIndex;index++)
					{
						checkJianTaDead(index);
					}
				}
			}
			
		}
		
		/**
		 * 检查power内是否有箭塔死亡的情形
		 * @param deadTroop
		 * @param origonalOccupiedIndex          原来占有的cell index
		 */
		public function checkJianTaDead(checkXValue:int):void
		{
			var allDeadArrowTower:Object={};
			var hasTroopLeft:Boolean = BattleTargetSearcher.checkHasTroopAliveOnXValue(this,checkXValue);
			if(!hasTroopLeft)
			{
				//这一竖排上的troop死光
				var allTroopsOnVertical:Array = BattleFunc.particularTroopsVertical(checkXValue,this);
				var singleTroop:CellTroopInfo;
				for(var index:int = 0;index < allTroopsOnVertical.length;index++)
				{
					singleTroop = allTroopsOnVertical[index];
					if(singleTroop == null || singleTroop.attackUnit.slotType != FormationElementType.ARROW_TOWER || 
						singleTroop.logicStatus == LogicSatusDefine.lg_status_dead)
						continue;
					singleTroop.logicStatus = LogicSatusDefine.lg_status_dead;
					allDeadArrowTower[singleTroop.troopIndex] = singleTroop;
					TroopFunc.hideParticularTroop(singleTroop,false);
				}
			}
		}
		
		/**
		 * 检查这一横的英雄是否死亡 
		 */
		public function checkHeroDead(troopInfo:CellTroopInfo):void
		{
			if(troopInfo == null)
				return;
			
			//将此troop对应的所有英雄设置为死亡状态
			var positon:Point = BattleTargetSearcher.getRowColumnByCellIndex(troopInfo.occupiedCellStart);
			var curYValue:int = 0;
			var cellstartIndex:int = this.isFirstAtk ? 0 : BattleFunc.getPowerSideCellCount();
			var singleCell:Cell;
			var hasArmy:Boolean;
			var curCheckCellIndex:int = 0;
			for(var yIndex:int = 0; yIndex < troopInfo.cellsCountNeed.y; yIndex++)
			{
				curYValue = positon.y + yIndex;
				
				hasArmy = false;
				for(var i:int = 0; i < this.xMaxValue - 1;i++)
				{
					curCheckCellIndex = cellstartIndex + i * BattleDefine.maxFormationYValue + curYValue;
					singleCell = BattleUnitPool.getCellInfo(curCheckCellIndex) as Cell;
					if(singleCell && singleCell.troopInfo && (singleCell.troopInfo.curArmCount > 0 || singleCell.troopInfo.curTroopHp > 0))
					{
						hasArmy = true;
						break;
					}
				}
				
				if(!hasArmy)			//如果已经没有兵了
				{
					var heroInfo:CellTroopInfo = BattleFunc.getHeroTroopForIndex(curYValue,this);
					if(heroInfo && heroInfo.attackUnit && heroInfo.attackUnit.contentHeroInfo)
					{
						var curPlayerUid:int = heroInfo.attackUnit.contentHeroInfo.uid;
						var heroPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(heroInfo.occupiedCellStart);
						var hasAliveCell:Boolean = BattleTargetSearcher.checkHasTroopAliveOnYValue(this,heroPos.y,heroInfo.cellsCountNeed.y);			//检查是否此hero对应的所有troop都死亡
						
						if(!hasAliveCell)
						{
							//死亡之后将占用的y位置释放
							GameEventHandler.dispatchGameEvent(EventMacro.OTHER_WAIT_HANDLER,new Event(BattleEventTagFactory.heroWaitForTimeGap(heroInfo.troopIndex)));
							Tweener.removeTweens(heroInfo);
							TroopInitClearFunc.clearTroopListener(heroInfo,true);
							GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,
								new Event(BattleEventTagFactory.getHeroDeadTag(heroInfo.troopIndex)));
							if(heroInfo && heroInfo.troopVisibleOnBattle && heroInfo.logicStatus != LogicSatusDefine.lg_status_dead && heroInfo.visible)
							{
								//								if(heroInfo.isPlayerHero && heroInfo.attackUnit.contentHeroInfo.uid == GlobalData.owner.uid)		//主英雄死亡，不能使用卡牌
								//									GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleCardManager.playerHeroDeadEvent));
								heroInfo.addMcFrameHandler(ActionDefine.Action_Dead);
								heroInfo.logicStatus = LogicSatusDefine.lg_status_dead;
								//检测是否结束
								GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));						
								heroInfo.playAction(ActionDefine.Action_Dead,1);
							}
							else
							{
								heroInfo.logicStatus = LogicSatusDefine.lg_status_dead;
								//检测是否结束
								GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
							}
							
							GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.refreshChoostTarget));
						}
					}
				}
			}
		}
		
		/**
		 * x上最大值，有几排 
		 */
		public function get xMaxValue():int
		{
			return _xMaxValue;
		}

		/**
		 * @private
		 */
		public function set xMaxValue(value:int):void
		{
			_xMaxValue = value;
			_maxRowIndex = _xMaxValue - 1;
		}

		/**
		 *  y轴上最大的数值，有几列
		 */
		public function get yMaxValue():int
		{
			return _yMaxValue;
		}

		/**
		 * @private
		 */
		public function set yMaxValue(value:int):void
		{
			_yMaxValue = value;
		}
		
	}
}