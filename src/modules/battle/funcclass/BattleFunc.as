package modules.battle.funcclass
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import defines.FormationSlotInfo;
	import defines.UserArmInfo;
	import defines.UserHeroInfo;
	
	import eventengine.GameEventHandler;
	
	import handlers.server.BattleHandler;
	
	import macro.BattleDisplayDefine;
	import macro.EventMacro;
	import macro.FormationElementType;
	import macro.SpecialEffectDefine;
	import macro.UserResourceType;
	
	import modules.battle.battledata.BDataPvpSingle;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.BattleValueDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.McStatusDefine;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.utils.BattleEventTagFactory;
	
	import synchronousLoader.ResourcePool;
	
	import sysdata.DropInfo;
	import sysdata.MapEnemyUnit;

	/**
	 * 提供简单通过功能的工具类
	 * @author SDD
	 * 
	 */
	public class BattleFunc
	{
		
		private static var maskIsShow:Boolean = false;
		
		public function BattleFunc()
		{
		}

		public static function showOnlineBattleWaitMask(bShow:Boolean):void
		{
			if(bShow == maskIsShow)
				return;
			maskIsShow = bShow;
		}
		
		public static function getPowerSideCellCount(atk:Boolean = true):int
		{
			if(atk)
				return BattleDefine.maxFormationXValue * BattleDefine.maxFormationYValue;
			else
				return BattleDefine.maxFormationXValue * BattleDefine.maxFormationYValue;
		}
		
		/**
		 * 获得某个troop对应的势力方 
		 * @param troopInfo				troop信息
		 * @param getSelf				是否取得自身信息
		 * @return 
		 */
		public static function getSidePowerInfoForTroop(troopInfo:CellTroopInfo,getSelf:Boolean = true):PowerSide
		{
			if(troopInfo == null)
				return null;
			if(troopInfo.ownerSide == BattleDefine.firstAtk)
			{
				return getSelf ? BattleManager.instance.pSideAtk : BattleManager.instance.pSideDef;
			}
			else
			{
				return getSelf ? BattleManager.instance.pSideDef : BattleManager.instance.pSideAtk;
			}
		}
		
		/**
		 * 通过cell的index获得所在方的powerside 
		 * @param cellIndex
		 * @return 所在powerside
		 */
		public static function getSidePowerInfoByCellIndex(cellIndex:int):PowerSide
		{
			var atkSideMaxCellCount:int = BattleFunc.getPowerSideCellCount();
			return 	cellIndex < atkSideMaxCellCount ? BattleManager.instance.pSideAtk : BattleManager.instance.pSideDef;
		}
		
		/**
		 * 通过cell的index获得对方powerside 
		 * @param cellIndex  cellIndex
		 * @return  对手powerside
		 * 
		 */
		public static function getOpponentPowersideByIndex(cellIndex:int):PowerSide
		{
			var atkSideMaxCellCount:int = BattleFunc.getPowerSideCellCount();
			return 	cellIndex < atkSideMaxCellCount ? BattleManager.instance.pSideDef : BattleManager.instance.pSideAtk;
		}
		
		/**
		 * 获得某个power的起始index 
		 * @param power
		 * @return 
		 * 
		 */
		public static function getPowerSideStartIndex(power:PowerSide):int
		{
			if(power == null)
				return 0;
			if(power.isFirstAtk)
			{
				return 0;
			}
			else
			{
				return BattleFunc.getPowerSideCellCount();
			}
		}
		
		/**
		 * 获得占用的格子数
		 * @param troopIndex    troop的index
		 * @return 
		 * 
		 */
		public static function getCellsOccupied(troopIndex:int):Array
		{
			var troopInfo:CellTroopInfo = BattleUnitPool.getTroopInfo(troopIndex);
			if(troopInfo == null)
				return null;
			
			var resValue:Array=[];
			
			var powerSide:PowerSide = getSidePowerInfoForTroop(troopInfo);
			for(var y:int = 0; y < troopInfo.cellsCountNeed.y;y++)
				for(var x:int = 0; x < troopInfo.cellsCountNeed.x;x++)
					resValue.push(x * BattleDefine.maxFormationYValue + y + troopInfo.occupiedCellStart);
			
			return resValue;
		}
		
		public static function getCellsOccupoedByStartCellIndex(cellIndex:int,cellSize:Point,powerSide:PowerSide):Array
		{
			var resValue:Array=[];
			
			for(var y:int = 0; y < cellSize.y;y++)
				for(var x:int = 0; x < cellSize.x;x++)
					resValue.push(x * BattleDefine.maxFormationYValue + y + cellIndex);
			
			return resValue;
		}
		
		/**
		 * 获得当前可以向前移动的troop 
		 * @param troopIndex
		 * @return 可以移动的troop
		 * 
		 */
		public static function seachFillUpTroops(powerSide:PowerSide):Object
		{
			var moveGapInfo:Object={};		//记录所有troop移动的距离
			
			if(powerSide == null)
				return moveGapInfo;
			
			var rowPos:Array=[];
			
			//保存当前的free的格子index
			//采取冒泡的方式进行冒泡
			//当一次移动都没有的时候说明填充完毕
			var freeIndexObj:Object={};				
			var allTroopIndexOnSide:Array=[];			//这一方的所有的troop信息
			
			var startIndex:int = 0;							//本阵营的启示troop索引
			var maxTroopIndex:int;							//最大的troop索引
			var leftMaxSize:int = BattleFunc.getPowerSideCellCount();
			if(powerSide.isFirstAtk)		//如果在最左边
			{
				maxTroopIndex = leftMaxSize;
				startIndex = 0;
			}
			else
			{
				startIndex = leftMaxSize;
				maxTroopIndex = leftMaxSize + BattleDefine.maxFormationXValue * BattleDefine.maxFormationYValue;
			}
			
			var tempCellInfo:Cell;
			var startBack:int = startIndex;
			while(startBack < maxTroopIndex)
			{
				tempCellInfo = BattleUnitPool.getCellInfo(startBack) as Cell;
				if(tempCellInfo)
				{
					if((tempCellInfo.troopInfo == null || tempCellInfo.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead || 
						tempCellInfo.troopInfo.logicStatus == LogicSatusDefine.lg_status_forceDead) && !BattleInfoSnap.hebingTarget.hasOwnProperty(startBack))
					{
						freeIndexObj[tempCellInfo.index] = 1;			//将空闲的cell加入到空闲列表中
					}
					//只有非英雄，非第一排，空闲状态的troop才会参与判断
					if(tempCellInfo.troopInfo && tempCellInfo.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && allTroopIndexOnSide.indexOf(tempCellInfo.troopInfo.troopIndex) == -1 
						&& tempCellInfo.troopInfo.logicStatus != LogicSatusDefine.lg_status_forceDead)
					{
						if((tempCellInfo.troopInfo.occupiedCellStart < startIndex || tempCellInfo.troopInfo.occupiedCellStart >= startIndex + BattleDefine.maxFormationYValue) && !tempCellInfo.troopInfo.isHero)			//第一排不可移动，最后一排英雄也不可移动
						{
							if(tempCellInfo.troopInfo.isMobileTroop)
								allTroopIndexOnSide.push(tempCellInfo.troopInfo.troopIndex);	
						}
					}
				}
				startBack++;
			}
			
			var t:int = 0;
			var bubbled:Boolean = true;
			var curOccupidPos:Array=[];							//当前所占的格子
			var expectedOccupidPos:Array=[];						//预期需要占领的格子
			var curQulifiedPos:Array=[];
			
			var curTroopIndex:int = 0;
			var curCehckTroop:CellTroopInfo;							//当前检查的troop信息
			while(bubbled)						//一直冒泡
			{
				bubbled = false;
				for(t = 0; t < allTroopIndexOnSide.length; t++)
				{
					curTroopIndex = allTroopIndexOnSide[t];
					curCehckTroop = BattleUnitPool.getTroopInfo(curTroopIndex);
					if(curCehckTroop == null)
						continue;
					
					if(!moveGapInfo.hasOwnProperty(curTroopIndex))
						moveGapInfo[curTroopIndex] = 0;
					curOccupidPos = getCellsOccupied(curTroopIndex);
					curOccupidPos = moveOccupiedCellForward(curOccupidPos,moveGapInfo[curTroopIndex],BattleDefine.maxFormationYValue);				//当前所占的格子空间，加上了已经移动的距离
					
					curQulifiedPos = curOccupidPos;
					
					var expectgap:int = 0;
					var expectedQulified:Boolean = true;
					var quilifiedMovePos:Array=[];
					while(expectedQulified)
					{
						expectgap++;
						expectedOccupidPos = moveOccupiedCellForward(curOccupidPos,expectgap,BattleDefine.maxFormationYValue);			//期望移动距离所占用的cell
						
						var raalPosToCheck:Array=[];
						for each(var singlePosExpect:int in expectedOccupidPos)
						{
							if(curQulifiedPos.indexOf(singlePosExpect) < 0)
								raalPosToCheck.push(singlePosExpect);
						}
						
						curQulifiedPos = expectedOccupidPos;
						
						//检查空闲cell中是否有这样的空格
						expectedQulified = checkExpectedCellIndexsAvailable(raalPosToCheck,freeIndexObj);
						
						if(expectedQulified)
						{
							if( (curCehckTroop.logicStatus == LogicSatusDefine.lg_status_idle && curCehckTroop.mcStatus == McStatusDefine.mc_status_idle) || 
								(curCehckTroop.logicStatus == LogicSatusDefine.lg_status_filling && !curCehckTroop.isHeBing) )
							{
								quilifiedMovePos = expectedOccupidPos;
							}
							else
							{
								expectedQulified = false;
								GameEventHandler.addListener(EventMacro.DAMAGE_WAIT_HANDELR,
									BattleEventTagFactory.getWaitForTroopBeIdleTag(curCehckTroop),curCehckTroop.checkNeedFill);
							}
						}
					}
					expectgap--;
					
					if(expectgap > 0)					//如果刚刚移动成功,证明有冒泡存在   改变空闲
					{
						bubbled = true;
						moveGapInfo[allTroopIndexOnSide[t]] += expectgap;				//移动的距离
						
						var it:int = 0;
						
						for(it = 0;it < curOccupidPos.length; it++)			//将之前占用的格子加入到空闲队列中
						{
							freeIndexObj[curOccupidPos[it]] = 1;
						}
						
						for(it = 0;it < quilifiedMovePos.length; it++)	//将需要占用的格子空间从空闲队列中去除
						{
							freeIndexObj[quilifiedMovePos[it]] = 0;
						}
					}
				}
			}
			
			return moveGapInfo;
		}
		
		/**
		 * 检查空闲队列中是否有足够的位置 
		 * @param expectedOccupidPos
		 * @param freeIndexObj
		 * @return 
		 */
		private static function checkExpectedCellIndexsAvailable(expectedOccupidPos:Array,freeIndexObj:Object):Boolean
		{
			var res:Boolean = true;
			
			for(var i:int = 0;i < expectedOccupidPos.length;i++)
			{
				var index:int = expectedOccupidPos[i];
				if(index < 0 || !freeIndexObj.hasOwnProperty(index) || freeIndexObj[index] == 0)					//只要有一个位置不存在，就不满足条件
				{
					res = false;
					
					break;
				}
			}
			
			return res;
		}
		
		/**
		 * 将某个troop所占的cell向前移动得到新的array 
		 * @return 
		 */
		private static function moveOccupiedCellForward(curPos:Array,gap:int,yValue:int):Array				
		{
			var singleValue:int = 0;
			var resArr:Array=[];
			for(var i:int = 0;curPos && i < curPos.length; i++)
			{
				singleValue = curPos[i] - gap * yValue;
				resArr.push(singleValue);
			}
			return resArr;
		}
		
		/**
		 * 取得某一排的cell集合 (竖直方向)
		 * @param rowIndex				竖直排数
		 * @return 
		 */
		public static function particularCellsVertical(rowIndex:int,powerSide:PowerSide):Array
		{
			var cellArray:Array=[];
				
			if(rowIndex > powerSide.xMaxValue - 1 || rowIndex < 0)		//超出最后一排，没有目标
				return cellArray;
			
			var singleIndex:int = 0;
			if(!powerSide.isFirstAtk)
			{
				singleIndex = BattleFunc.getPowerSideCellCount();
			}
			
			singleIndex += rowIndex * BattleDefine.maxFormationYValue;
			
			for(var i:int = 0; i < BattleDefine.maxFormationYValue; i++)					
			{
				cellArray.push(BattleUnitPool.getCellInfo(singleIndex++) as Cell);
			}
			
			return cellArray;
		}
		
		/**
		 * 取得某一排的troop集合  （竖直方向）
		 * @param rowIndex
		 * @param powerSide
		 * @return 
		 */
		public static function particularTroopsVertical(rowIndex:int,powerSide:PowerSide):Array
		{
			var retValue:Array=[];
			var keyChecked:Object={};
			
			var cells:Array = particularCellsVertical(rowIndex,powerSide);
			
			var singleCell:Cell;
			var singleTroop:CellTroopInfo;
			for(var i:int = 0; i < cells.length;i++)
			{
				singleCell = cells[i] as Cell;
				if(singleCell)
				{
					singleTroop = singleCell.troopInfo;
					if(singleTroop && !keyChecked.hasOwnProperty(singleTroop.troopIndex))
					{
						keyChecked[singleTroop.troopIndex] = 1;
						retValue.push(singleTroop);
					}
				}
			}
			return retValue;
		}
		
		/**
		 * 获得自己前方的troop，用于吸收伤害 
		 * @param columnIndex
		 * @param powerside
		 * @return 
		 */
		public static function getTroopFrontOfSelf(columnIndex:int,powerside:PowerSide):CellTroopInfo
		{
			var retTroop:CellTroopInfo;
			var singleIndex:int = 0;
			if(!powerside.isFirstAtk)
			{
				singleIndex = BattleFunc.getPowerSideCellCount();
			}
			singleIndex += columnIndex;
			var cellInfo:Cell = BattleUnitPool.getCellInfo(singleIndex) as Cell;
			if(cellInfo && cellInfo.troopInfo && cellInfo.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && cellInfo.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)
			{
				retTroop = cellInfo.troopInfo;
			}
			return retTroop;
		}
		
		/**
		 * 获得水平方向的某个行的cell集合 
		 * @param columnIndex       columnindex
		 * @param pwoerSide			所在powerside	
		 * @return 
		 */
		public static function particularCellsHorizonl(columnIndex:int,powerside:PowerSide,includeHero:Boolean = true):Array
		{
			var retValue:Array=[];
			
			if(powerside == null)
				return retValue;
			
			var singleIndex:int = 0;
			if(!powerside.isFirstAtk)
			{
				singleIndex = BattleFunc.getPowerSideCellCount();
			}
			
			singleIndex += columnIndex;
			var curCheckIndex:int = 0;
			var caucalXValue:int = includeHero ? powerside.xMaxValue : powerside.xMaxValue - 1;
			for(var i:int = 0; i < caucalXValue;i++)
			{
				curCheckIndex = singleIndex + i * BattleDefine.maxFormationYValue;
				retValue.push(BattleUnitPool.getCellInfo(curCheckIndex) as Cell);
			}
			return retValue;
		}
		
		/**
		 * 获得某个水平方向的行的troop集合 
		 * @param columnIndex            columnIndex
		 * @param pwoerSide				 所在的powerside	
		 * @return 
		 */
		public static function particularTroopsHorizon(columnIndex:int,pwoerSide:PowerSide,includeHero:Boolean = true):Array
		{
			var retValue:Array=[];
			var troopChecked:Object={};
			
			var cells:Array = particularCellsHorizonl(columnIndex,pwoerSide,includeHero);
			var singleCell:Cell;
			var singleTroop:CellTroopInfo;
			for(var i:int = 0; i < cells.length;i++)
			{
				singleCell = cells[i] as Cell;
				if(singleCell)
				{
					singleTroop = singleCell.troopInfo;
					if(singleTroop && !troopChecked.hasOwnProperty(singleTroop.troopIndex))
					{
						troopChecked[singleTroop.troopIndex] = 1;
						retValue.push(singleTroop);
					}
				}
			}
			return retValue;
		}
		
		/**
		 * 根据y值已经所在方向，获得英雄troop 
		 * @param yValue
		 * @param power
		 */
		public static function getHeroTroopForIndex(yValue:int,power:PowerSide):CellTroopInfo
		{
			if(power == null || yValue < 0)
				return null;
			
			var retTroop:CellTroopInfo;
			
			var startCellIndex:int = 0;
			if(!power.isFirstAtk)
				startCellIndex = BattleFunc.getPowerSideCellCount();
			
			var cellIndex:int = startCellIndex + yValue + BattleDefine.maxFormationYValue * (power.xMaxValue - 1);
			
			var cellInfo:Cell = BattleUnitPool.getCellInfo(cellIndex) as Cell;
			
			if(cellInfo)
			{
				retTroop = cellInfo.troopInfo;
			}
			
			return retTroop;
		}
		
		/**
		 *获得某个powerside的所有英雄数据 ,最后一排
		 * @param powerInfo
		 * @return 
		 */
		public static function getAllHeroInfo(powerInfo:PowerSide):Array
		{
			var retValue:Array=[];
			retValue = particularTroopsVertical(powerInfo.xMaxValue - 1,powerInfo);
			return retValue;
		}
		
		/**
		 * 获得一个回合中没有前置chain信息的chain集合 
		 */
		public static function getChainwithNoPreChains(chainArr:Array):Array
		{
			var retArr:Array=[];
			
			if(chainArr == null)
				return retArr;
			
			for(var i:int = 0; i < chainArr.length; i++)
			{
				var singleChain:CombatChain = chainArr[i] as CombatChain;
				if(singleChain && singleChain.preChain < 0)
				{
					retArr.push(singleChain.chainIndex);
				}
			}
			
			return retArr;
		}
		
		/**
		 * 查看某个效果是否可以在被英雄攻击的时候触发 
		 * @param effectId
		 */
		public static function checkEffectCanBeUsedWhenAttackedByHero(effectId:int):Boolean
		{
			var retValue:Boolean = false;
			switch(effectId)
			{
				case SpecialEffectDefine.ZhongDu:
				case SpecialEffectDefine.XuanYun:
				case SpecialEffectDefine.WuLiShangHaiMianYi:
				case SpecialEffectDefine.MoFaShangHaiMianYi:	
				case SpecialEffectDefine.HPShangXianZengJia:
					retValue = true;
					break;
			}
			return retValue;
		}
		
		/**
		 * 取得两个troop之间的距离 
		 * @param troopA
		 * @param troopB
		 * @return 
		 */
		public static function checkDistanceOfTroops(troopA:CellTroopInfo,troopB:CellTroopInfo):int
		{
			var dis:int = 0;
			if(troopA == null || troopB == null)
				return dis;
			
			var ptA:Point = BattleTargetSearcher.getRowColumnByCellIndex(troopA.occupiedCellStart);
			var ptB:Point = BattleTargetSearcher.getRowColumnByCellIndex(troopB.occupiedCellStart);
			
			if(troopA.ownerSide == troopB.ownerSide)
			{
				dis = Math.abs(ptB.x - ptA.x);
			}
			else
			{
				dis = Math.abs(ptB.x + ptA.x);
			}
			return dis;
		}
		
		/**
		 * 判断troop移动的时候额外移动的距离
		 * @param newOccuIndex
		 * @param oldOccuIndex
		 * @return 
		 */
		public static function checkMoveGapOffsetDistance(newOccuIndex:int,oldOccuIndex:int,ownerSide:int):Number
		{
			var retValue:Number = 0;
			
			if(!BattleModeDefine.checkNeedConsiderWave() || ownerSide == BattleDefine.firstAtk)
			{
				return retValue;
			}
			
			var newPt:Point = BattleTargetSearcher.getRowColumnByCellIndex(newOccuIndex);
			var oldPt:Point = BattleTargetSearcher.getRowColumnByCellIndex(oldOccuIndex);
			
			if(oldPt.x >= BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex && 
				newPt.x < BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex)			//从待机区补到战斗区
			{
				retValue = BattleDisplayDefine.zhanDouDaijiGap;
			}
			
			return retValue;
		}
		
		public static function getDropInfoByUnitId(unitId:int):Array
		{
			var retArr:Array;
			var targetFunc:Function = BattleManager.instance.dropSeekFunc;
			if(targetFunc != null)
			{
				retArr = targetFunc(unitId);
			}
			return retArr;
		}
		
		/**
		 * 根据unit id获得enemyunit 
		 * @param unitId
		 * @return 
		 */
		public static function getEnemyUnitById(unitId:int):MapEnemyUnit
		{
			return null;
		}
		
		/**
		 * 获得艺术字图像 
		 * @param number
		 * @return 
		 */
		public static function getNumberBitmap(number:int):DisplayObject
		{
			var resId:int = 2171;
			resId += number;
			var bmpInfo:Bitmap = ResourcePool.getNewBitMapFromMultipleClass(resId);
			if(bmpInfo)
				return bmpInfo;
			return null; 
		}
		
		/**
		 * 判断某个英雄是否为箭塔英雄 
		 * @param troopInfo
		 * @return 
		 */
		public static function checkHeroIsJianTaHero(troopInfo:CellTroopInfo):Boolean
		{
			if(!BattleManager.instance.battleMode == BattleModeDefine.PVP_OLCapTure)				//只有离线战斗的时候才有效
				return false;
			if(troopInfo == null || !troopInfo.isHero)
				return false;
			if(BattleInfoSnap.jianTaHeroRecord.hasOwnProperty(troopInfo.troopIndex))
			{
				var curValue:int = BattleInfoSnap.jianTaHeroRecord[troopInfo.troopIndex];
				return curValue == BattleValueDefine.isJiantaHero;
			}
			
			var targetPowerside:PowerSide = getSidePowerInfoForTroop(troopInfo);
			
			var troopPt:Point = BattleTargetSearcher.getRowColumnByCellIndex(troopInfo.occupiedCellStart);
			
			var allTroops:Array = particularTroopsHorizon(troopPt.y,targetPowerside,false);
			
			var singleTroop:CellTroopInfo;
			var retValue:Boolean = false;
			for(var i:int = 0;i < allTroops.length;i++)
			{
				singleTroop = allTroops[i] as CellTroopInfo;
				if(singleTroop == null)
					continue;
				if(singleTroop.attackUnit.slotType == FormationElementType.ARROW_TOWER)
				{
					retValue = true;
					break;
				}
			}
			
			if(retValue)
			{
				BattleInfoSnap.jianTaHeroRecord[troopInfo.troopIndex] = BattleValueDefine.isJiantaHero;
			}
			else
			{
				BattleInfoSnap.jianTaHeroRecord[troopInfo.troopIndex] = BattleValueDefine.noJiantaHero;
			}
			return retValue;
			
		}
		
		/**
		 * 防御阵型时候制造假的英雄(平均值) 
		 * @param sourceFormation
		 * @return 
		 */
		public static function makeAvarageHeroInfo(sourceFormation:Array):UserHeroInfo
		{
			return new UserHeroInfo;
		}
		
		public static function getWallArmyLeftPercent():Array
		{
			var retInfo:Array=[];
			retInfo[0] = 0;
			retInfo[1] = 0;
			var allTroops:Array = BattleUnitPool.getTroopsOfSomeSide(BattleDefine.secondAtk);
			
			var wallOriginHp:int = 0;
			var armOrigingHp:int = 0;
			var wallCurHp:int = 0;
			var armCurHp:int = 0;
			
			var singleTroop:CellTroopInfo;
			for(var i:int = 0;i < allTroops.length;i++)
			{
				singleTroop = allTroops[i];
				if(singleTroop == null || singleTroop.isHero || singleTroop.attackUnit.slotType == FormationElementType.ARROW_TOWER)
					continue;
				if(singleTroop.attackUnit.slotType == FormationElementType.CITY_WALL)
				{
					wallOriginHp += singleTroop.originalTotalHpValue;
					wallCurHp += singleTroop.totalHpValue;
				}
				else if(singleTroop.attackUnit.slotType == FormationElementType.ARM)
				{
					armOrigingHp += singleTroop.originalTotalHpValue;
					armCurHp += singleTroop.totalHpValue;
				}
			}
			
			if(wallOriginHp != 0)
			{
				retInfo[0] = wallCurHp / wallOriginHp;
			}
			if(armOrigingHp != 0)
			{
				retInfo[1] = armCurHp / armOrigingHp;
			}
			return retInfo;
		}
		
		/**
		 * 获得阵上所有兵的id信息 
		 * @return 
		 */
		public static function getAllArmidsOnBattle():Array
		{
			var retValue:Array = [];
			var allTroopsOfSide:Array = BattleUnitPool.getTroopsOfSomeSide(BattleDefine.firstAtk);
			for(var i:int = 0;i < allTroopsOfSide.length;i++)
			{
				var singleTroop:CellTroopInfo = allTroopsOfSide[i];
				if(singleTroop == null || singleTroop.isHero || singleTroop.attackUnit == null || singleTroop.logicStatus == LogicSatusDefine.lg_status_dead)
					continue;
				if(singleTroop.attackUnit.contentArmInfo.uid != GlobalData.owner.uid)
				{
					continue;
				}
				var singleArmId:int = singleTroop.attackUnit.contentArmInfo.armid;
				if(retValue.indexOf(singleArmId) < 0)
				{
					retValue.push(singleArmId);
				}
			}
			return retValue;
		}
		
		public static function updateGuildBuff(dropInfo:DropInfo):void
		{
			return;
			if(dropInfo == null)
				return;
			if(dropInfo.type == UserResourceType.EXP)
			{
				dropInfo.value =  int(dropInfo.value * (1 + BattleInfoSnap.guildRatioExp));
			}
			else if(dropInfo.type == UserResourceType.Coin)
			{
				dropInfo.value =  int(dropInfo.value * (1 + BattleInfoSnap.guildRatioCoin));
			}
		}
		
		public static function getMadeFormationWithLansquenet(sourceBattle:Array,fakeUid:int):Array
		{
			var retInfo:Array = [];
			var i:int = 0;
			for(i = 0;i < sourceBattle.length;i++)
			{
				retInfo[i] = sourceBattle[i];
			}
			for(i = 0;i < sourceBattle.length;i++)
			{
				var singleLineInfo:Array = sourceBattle[i];
				var fakeLine:Array = [];
				for(var ii:int = 0;ii < singleLineInfo.length;ii++)
				{
					var singleFormation:FormationSlotInfo = singleLineInfo[ii];
					if(singleFormation == null)
					{
						fakeLine.push(null);
					}
					else
					{
						var fakeSlotInfo:FormationSlotInfo = new FormationSlotInfo();
						fakeSlotInfo.type = singleFormation.type;
						if(singleFormation.type == FormationElementType.HERO)
						{
							var sourceHInfo:UserHeroInfo = singleFormation.info as UserHeroInfo;
							var cloneHInfo:UserHeroInfo = sourceHInfo.clone();
							cloneHInfo.uid = fakeUid;
							fakeSlotInfo.info = cloneHInfo;
						}
						else if(singleFormation.type == FormationElementType.ARM)
						{
							var sourceAInfo:UserArmInfo = singleFormation.info as UserArmInfo;
							var cloneAInfo:UserArmInfo = sourceAInfo.clone();
							cloneAInfo.uid = fakeUid;
							fakeSlotInfo.info = cloneAInfo;
							fakeSlotInfo.curnum = singleFormation.curnum;
							fakeSlotInfo.maxnum = singleFormation.maxnum;
						}
						fakeLine.push(fakeSlotInfo);
					}
				}
				retInfo.push(fakeLine);
			}
			return retInfo;
		}
		
		public static function getUserSelfSide(uid:int):int
		{
			var retSide:int = BattleDefine.firstAtk;
			if(BattleManager.instance.battleMode == BattleModeDefine.PVP_Single)
			{
				var tempData:BDataPvpSingle = BattleHandler.instance.onLineManager.curbattledata as BDataPvpSingle;
				if(tempData)
				{
					if(uid == tempData.attackuid)				//本方是攻击方
					{
						retSide = BattleDefine.firstAtk;
					}
					else
					{
						retSide = BattleDefine.secondAtk;
					}
				}
			}
			return retSide;
		}
		
		public static function getUserOpponentSide(uid:int):int
		{
			var retSide:int = BattleDefine.secondAtk;
			if(BattleManager.instance.battleMode == BattleModeDefine.PVP_Single)
			{
				var tempData:BDataPvpSingle = BattleHandler.instance.onLineManager.curbattledata as BDataPvpSingle;
				if(tempData)
				{
					if(uid == tempData.attackuid)				
					{
						retSide = BattleDefine.secondAtk;
					}
					else
					{
						retSide = BattleDefine.firstAtk;
					}
				}
			}
			return retSide;
		}
		
	}
}