package modules.battle.managers
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import handlers.server.BattleHandler;
	
	import macro.AttackRangeDefine;
	import macro.FormationElementType;
	
	import modules.battle.battledata.BDataPvpSingle;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.HeroAttackDisTypeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.RandomValueService;
	import modules.battle.battledefine.TroopFilterTypeDefine;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.TroopFunc;
	
	/**
	 * 处理战斗中目标的寻找 
	 * @author Administrator
	 */
	public class BattleTargetSearcher
	{
		
		private static var posotionArr:Object={};							//保存位置信息
		
		public function BattleTargetSearcher()
		{
			
		}
		
		/**
		 * 获得某种攻击方式的目标 
		 * @param sourceIndex   发出攻击的troop
		 * @param attackRange	攻击方式
		 * @param attackDistance 攻击距离
		 * @return 目标集合
		 */
		public static function getTargetsForSomeRange(sourceIndex:int,attackRange:int,attackDistance:int = 0,atkTroop:CellTroopInfo = null,
													  curAttackRange:int = 0,curAttackTroops:Dictionary = null):Array
		{
			var retValue:Array=[];
			var targetTroopInfo:Array=[];			//返回值
			
			var sourceTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(sourceIndex) as CellTroopInfo;
			if(sourceTroop == null)
				return retValue;
			
			if(attackRange == AttackRangeDefine.zijiZhunBeiGongJi)
			{
				if(curAttackTroops)
				{
					for(var singleKey:* in curAttackTroops)
					{
						var singleTarget:CellTroopInfo = singleKey as CellTroopInfo;
						retValue.push(singleTarget);
					}
					return retValue;
				}
			}
			
			var firstRowCells:Array=[];
			
			var halfCount:int = sourceTroop.cellsCountNeed.y / 2;
			var upDirIndex:int = 0;
			var downDirIndex:int = 0;
			if(sourceTroop.cellsCountNeed.y % 2 != 0)			
			{
				firstRowCells.push(sourceTroop.occupiedCellStart + sourceTroop.cellsCountNeed.y / 2);
				downDirIndex = sourceTroop.cellsCountNeed.y / 2 + 2;
			}
			else
			{
				downDirIndex = sourceTroop.cellsCountNeed.y / 2 + 1;
			}
			upDirIndex = sourceTroop.cellsCountNeed.y / 2;
			for(var checkIndex:int = 0; checkIndex < halfCount; checkIndex++)
			{
				if(upDirIndex - checkIndex >= 1)
				{
					firstRowCells.push(sourceTroop.occupiedCellStart + upDirIndex - checkIndex - 1);
				}
				if(downDirIndex - checkIndex <= 1)
				{
					firstRowCells.push(sourceTroop.occupiedCellStart + downDirIndex + checkIndex - 1);
				}
			}
			
			var sourcePowerside:PowerSide = BattleFunc.getSidePowerInfoForTroop(sourceTroop);
			var opponentPowerSide:PowerSide = BattleFunc.getSidePowerInfoForTroop(sourceTroop,false);
			
			var needCompare:Boolean = false;
			switch(attackRange)
			{
				case AttackRangeDefine.dantiGongJi:
				case AttackRangeDefine.duotiGongJi1:
				case AttackRangeDefine.duotiGongJi2:
				case AttackRangeDefine.duotiGongJi3:
				case AttackRangeDefine.duotiGongJi4:
				case AttackRangeDefine.duotiGongJi5:
				case AttackRangeDefine.duotiGongJi6:
				case AttackRangeDefine.duotiGongJi7:
				case AttackRangeDefine.duotiGongJi8:
				case AttackRangeDefine.duotiGongJi9:
				case AttackRangeDefine.duotiGongJi10:
				case AttackRangeDefine.duotiGongJi11:
					needCompare = true;
					break;
			}
			
			if(sourceTroop.isHero)
				attackDistance = 100;				//英雄没有攻击距离限制
			
			if(!sourceTroop.isHero)
			{
				var needLimitRange:Boolean = AttackRangeDefine.checkNeedLimitRange(attackRange);
				if(needLimitRange)
				{
					attackDistance = Math.min(attackDistance,AttackRangeDefine.Attack_Range_Limit);
				}
			}
			
			var targetCell:Cell;
			
			var sourcePos:Point;
			var targetPoint:Point = new Point;
			var targetCellPos:Point;
			var tempYDisValue:int = 0;
			
			sourcePos = getRowColumnByCellIndex(sourceTroop.occupiedCellStart);
			
			if(needCompare)			//需要对多个cell找到的目标进行比较
			{
				var targetArrFound:Array=[];
				var oldTargetCell:Cell;
				var oldCellPos:Point;
				var curYGapvalue:int = 0;
				var index:int = 0;
				
				for(index = 0; index < firstRowCells.length; index++)
				{
					var attackDistanceRemain:int = attackDistance;
					sourcePos = getRowColumnByCellIndex(firstRowCells[index]);
					
					if(isDistanceNeeded(attackRange))				//如果攻击范围不够
					{
						if(sourcePos.x > attackDistanceRemain)
							return retValue;
						attackDistanceRemain -= sourcePos.x;
					}
					
					var tempMaxDistanceRemain:int = attackDistanceRemain;			//找到这个cell对应的目标
					targetCell = getTargetFromSomeIndex(opponentPowerSide,sourcePos.y,attackDistanceRemain);
					targetArrFound.push(targetCell);
					
					if(targetCell)
					{
						targetCellPos = getRowColumnByCellIndex(targetCell.index);
						tempYDisValue = Math.abs(targetCellPos.y - sourcePos.y);
						if(tempYDisValue != 0)
							continue;
						if(oldTargetCell == null)
						{
							oldTargetCell = targetCell;
							oldCellPos = targetCellPos;
						}
						else
						{
							if(oldCellPos.x > targetCellPos.x)		//所有正对目标中，选择距离最短的那个
							{
								oldTargetCell = targetCell;
								oldCellPos = targetCellPos;
								curYGapvalue = tempYDisValue;
							}
						}
					}
				}
				
				if(oldTargetCell == null)			//没有正对目标
				{
					for(index = 0; index < targetArrFound.length;index++)
					{
						targetCell = targetArrFound[index];
						if(targetCell)
						{
							targetCellPos = getRowColumnByCellIndex(targetCell.index);
							sourcePos = getRowColumnByCellIndex(firstRowCells[index]);
							tempYDisValue = Math.abs(targetCellPos.y - sourcePos.y);
							if(oldTargetCell == null)
							{
								oldTargetCell = targetCell;
								oldCellPos = targetCellPos;
								curYGapvalue = tempYDisValue;
							}
							else
							{
								if(targetCellPos.x < oldCellPos.x)				//取距离近的
								{
									oldTargetCell = targetCell;
									oldCellPos = targetCellPos;
									curYGapvalue = tempYDisValue;
								}
								else if(targetCellPos.x == oldCellPos.x)		//距离相等的时候，取y方向偏移小的
								{
									if(tempYDisValue < curYGapvalue)
									{
										oldTargetCell = targetCell;
										oldCellPos = targetCellPos;
										curYGapvalue = tempYDisValue;
									}
								}
							}
						}
					}
				}
				
				targetCell = oldTargetCell;
				if(targetCell == null)
				{
					return retValue;
				}
				targetPoint = getRowColumnByCellIndex(targetCell.index);
			}
			
			var oppoStartIndex:int;
			var selfStartIndex:int;
			var maxCount:int;
			var i:int = 0;
			
			var allCellOnSelfSide:Array;
			var realLastIndexRow:int = 0;
			
			switch(attackRange)
			{
				case AttackRangeDefine.dantiGongJi:
					retValue.push(targetCell);
					break;
				case AttackRangeDefine.duotiGongJi1:
				case AttackRangeDefine.duotiGongJi2:
				case AttackRangeDefine.duotiGongJi3:
				case AttackRangeDefine.duotiGongJi4:
				case AttackRangeDefine.duotiGongJi5:
				case AttackRangeDefine.duotiGongJi6:
				case AttackRangeDefine.duotiGongJi7:
				case AttackRangeDefine.duotiGongJi8:
				case AttackRangeDefine.duotiGongJi9:
				case AttackRangeDefine.duotiGongJi10:
				case AttackRangeDefine.duotiGongJi11:
					retValue.push(targetCell);
					retValue = retValue.concat(getMultiTarget(opponentPowerSide,getRowColumnByCellIndex(targetCell.index),attackRange));
					break;
				case AttackRangeDefine.diFangGongJiZiJi:
					targetTroopInfo.push(atkTroop);					//发动攻击的troop
					break;
				case AttackRangeDefine.zijiZhunBeiGongJi:
					break;
				case AttackRangeDefine.diFangSuiJi:						//敌方随机攻击
					retValue = retValue.concat(getRandomAttackTarget(opponentPowerSide,1,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJi2:					//2个随机目标
					retValue = retValue.concat(getRandomAttackTarget(opponentPowerSide,2,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJi3:					//3个随机目标
					retValue = retValue.concat(getRandomAttackTarget(opponentPowerSide,3,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJi4:					//3个随机目标
					retValue = retValue.concat(getRandomAttackTarget(opponentPowerSide,4,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJi5:					//3个随机目标
					retValue = retValue.concat(getRandomAttackTarget(opponentPowerSide,5,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJi6:					//3个随机目标
					retValue = retValue.concat(getRandomAttackTarget(opponentPowerSide,6,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJi7:					//3个随机目标
					retValue = retValue.concat(getRandomAttackTarget(opponentPowerSide,7,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJi8:					//3个随机目标
					retValue = retValue.concat(getRandomAttackTarget(opponentPowerSide,8,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangTongLie:					//敌方同列,水平方向
					retValue = retValue.concat(BattleFunc.particularCellsHorizonl(targetPoint.y,opponentPowerSide,false));
					break;
				case AttackRangeDefine.diFangQuanTi:					//敌方全体
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(opponentPowerSide,TroopFilterTypeDefine.canBeAttacked);
					break;
				case AttackRangeDefine.diFangDiYiPai:					//敌方第一排
					retValue = retValue.concat(BattleFunc.particularCellsVertical(0,opponentPowerSide));
					break;
				case AttackRangeDefine.diFangDiErPai:					//敌方第二排
					retValue = retValue.concat(BattleFunc.particularCellsVertical(1,opponentPowerSide));
					break;
				case AttackRangeDefine.diFangDiSanPai:					//敌方第二排
					retValue = retValue.concat(BattleFunc.particularCellsVertical(2,opponentPowerSide));
					break;
				case AttackRangeDefine.diFangZuiHouPai:					//敌方最后排
					if(BattleModeDefine.checkNeedConsiderWave() && !opponentPowerSide.isFirstAtk)
					{
						realLastIndexRow = Math.min(opponentPowerSide.maxRowIndex,BattleDefine.shuaGuaiTroopLength - 1);
					}
					else
					{
						realLastIndexRow = opponentPowerSide.maxRowIndex;
					}
					retValue = retValue.concat(BattleFunc.particularCellsVertical(realLastIndexRow,opponentPowerSide));
					break;
				case AttackRangeDefine.diFangSuoYouZhongDu:					//敌方所有中毒单位
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(opponentPowerSide,TroopFilterTypeDefine.beizhongdu);
					break;
				case AttackRangeDefine.diFangSuoYouXuanYun:					//敌方所有眩晕单位
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(opponentPowerSide,TroopFilterTypeDefine.beixuanyun);
					break;
				case AttackRangeDefine.woFangZiJi:					//我方自己
					retValue.push(BattleUnitPool.getCellInfo(sourceTroop.occupiedCellStart));
					break;
				case AttackRangeDefine.woFangTongLie:					//我方同列	水平方向
					retValue = retValue.concat(BattleFunc.particularCellsHorizonl(sourcePos.y,sourcePowerside,false));
					break;
				case AttackRangeDefine.woFangTongPai:					//我方同列  数值方向
					retValue = retValue.concat(BattleFunc.particularCellsVertical(sourcePos.x,sourcePowerside));
					break;
				case AttackRangeDefine.woFangSuiJi:				//我方随机
					retValue = retValue.concat(getRandomAttackTarget(sourcePowerside,1,TroopFilterTypeDefine.canAttack,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJi2:				//我方随机
					retValue = retValue.concat(getRandomAttackTarget(sourcePowerside,2,TroopFilterTypeDefine.canAttack,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJi3:				//我方随机
					retValue = retValue.concat(getRandomAttackTarget(sourcePowerside,3,TroopFilterTypeDefine.canAttack,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJi4:				//我方随机
					retValue = retValue.concat(getRandomAttackTarget(sourcePowerside,4,TroopFilterTypeDefine.canAttack,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJi5:				//我方随机
					retValue = retValue.concat(getRandomAttackTarget(sourcePowerside,5,TroopFilterTypeDefine.canAttack,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJi6:				//我方随机
					retValue = retValue.concat(getRandomAttackTarget(sourcePowerside,6,TroopFilterTypeDefine.canAttack,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJi7:				//我方随机
					retValue = retValue.concat(getRandomAttackTarget(sourcePowerside,7,TroopFilterTypeDefine.canAttack,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJi8:				//我方随机
					retValue = retValue.concat(getRandomAttackTarget(sourcePowerside,8,TroopFilterTypeDefine.canAttack,sourceTroop));
					break;
				case AttackRangeDefine.woFangDiYiPai:				//我方第一排
					retValue = retValue.concat(BattleFunc.particularCellsVertical(0,sourcePowerside));
					break;
				case AttackRangeDefine.woFangDiErPai:				//我方第二排
					retValue = retValue.concat(BattleFunc.particularCellsVertical(1,sourcePowerside));
					break;
				case AttackRangeDefine.woFangDiSanPai:				//我方第三排
					retValue = retValue.concat(BattleFunc.particularCellsVertical(2,sourcePowerside));
					break;
				case AttackRangeDefine.woFangZuiHouPai:				//我方最后排
					if(BattleModeDefine.checkNeedConsiderWave() && !sourcePowerside.isFirstAtk)
					{
						realLastIndexRow = Math.min(sourcePowerside.maxRowIndex,BattleDefine.shuaGuaiTroopLength - 1);
					}
					else
					{
						realLastIndexRow = sourcePowerside.maxRowIndex;
					}
					retValue = retValue.concat(BattleFunc.particularCellsVertical(realLastIndexRow,sourcePowerside));
					break;
				case AttackRangeDefine.woFangQuanTi:				//我方全体
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(sourcePowerside,TroopFilterTypeDefine.canBeAttacked);
					break;
				case AttackRangeDefine.woFangSuoYouBuBing:			//我方所有步兵
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(sourcePowerside,TroopFilterTypeDefine.footman);
					break;
				case AttackRangeDefine.woFangSuoYouNuBing:			//我方所有弩兵
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(sourcePowerside,TroopFilterTypeDefine.archer);
					break;
				case AttackRangeDefine.woFangSuoYouFaShi:			//我方所有法师
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(sourcePowerside,TroopFilterTypeDefine.magic);
					break;
				case AttackRangeDefine.woFangSuoYouJiXie:			//我方所有机械单位
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(sourcePowerside,TroopFilterTypeDefine.machine);
					break;
				case AttackRangeDefine.woFangSuoYouXuanYun:			//我方所有机械单位
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(sourcePowerside,TroopFilterTypeDefine.beixuanyun);
					break;
				case AttackRangeDefine.woFangSuoYouZhongDu:			//我方所有机械单位
					allCellOnSelfSide = BattleTroopCellFinder.getAllCellForPowerSide(sourcePowerside,TroopFilterTypeDefine.beizhongdu);
					break;
				case AttackRangeDefine.woFangDuiYingYingXiong:		//我方对应英雄
					targetTroopInfo = targetTroopInfo.concat(sourceTroop.allHeroArr);
					break;
				case AttackRangeDefine.woFangSuoYouYingXiong:		//我方所有英雄
					retValue = retValue.concat(BattleFunc.particularCellsVertical(sourcePowerside.xMaxValue - 1,sourcePowerside));
					break;
				case AttackRangeDefine.diFangSuoYouYingXiong:		//对方所有英雄
					retValue = retValue.concat(BattleFunc.particularCellsVertical(sourcePowerside.xMaxValue - 1,opponentPowerSide));
					break;
				case AttackRangeDefine.woFangSuiJiYingXiong:		//我方随机英雄
					retValue = retValue.concat(getRandomAttackTarget(sourcePowerside,1,TroopFilterTypeDefine.isHero,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJiYingXiong:		//敌方随机英雄
					retValue = retValue.concat(getRandomAttackTarget(opponentPowerSide,1,TroopFilterTypeDefine.isHero,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJiCell1:			//我方随机格子1
					retValue = retValue.concat(getRandomCellTarget(sourcePowerside,1,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJiCell2:			//我方随机格子2
					retValue = retValue.concat(getRandomCellTarget(sourcePowerside,2,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJiCell3:			//我方随机格子3
					retValue = retValue.concat(getRandomCellTarget(sourcePowerside,3,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJiCell4:			//我方随机格子4
					retValue = retValue.concat(getRandomCellTarget(sourcePowerside,4,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.woFangSuiJiCell5:			//我方随机格子5
					retValue = retValue.concat(getRandomCellTarget(sourcePowerside,5,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJiCell1:			//敌方随机格子1
					retValue = retValue.concat(getRandomCellTarget(opponentPowerSide,1,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJiCell2:			//敌方随机格子2
					retValue = retValue.concat(getRandomCellTarget(opponentPowerSide,2,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJiCell3:			//敌方随机格子3	
					retValue = retValue.concat(getRandomCellTarget(opponentPowerSide,3,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJiCell4:			//敌方随机格子4
					retValue = retValue.concat(getRandomCellTarget(opponentPowerSide,4,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.diFangSuiJiCell5:			//敌方随机格子5
					retValue = retValue.concat(getRandomCellTarget(opponentPowerSide,5,TroopFilterTypeDefine.canBeAttacked,sourceTroop));
					break;
				case AttackRangeDefine.woFangDiYiPaiAll:
					retValue = retValue.concat(BattleFunc.particularCellsVertical(0,sourcePowerside));
					break;
				case AttackRangeDefine.wofangDiyiPaiDanwei:
					retValue = retValue.concat(BattleFunc.particularCellsVertical(0,sourcePowerside));
					break;
				case AttackRangeDefine.wofangDiyiPaiDanweiAll:
					retValue = retValue.concat(BattleFunc.particularCellsVertical(0,sourcePowerside));
					break;
				case AttackRangeDefine.feiDiyiPai:
					for(var verticalIndex:int = 1;verticalIndex <= sourcePowerside.maxRowIndex;verticalIndex++)
						retValue = retValue.concat(BattleFunc.particularCellsVertical(verticalIndex,sourcePowerside));
					break;
				case AttackRangeDefine.heroMappedArmLineOne:
					retValue = getCellOfTheHero(sourcePos,sourcePowerside,0);
					break;
				case AttackRangeDefine.heroMappedArmLineTwo:
					retValue = getCellOfTheHero(sourcePos,sourcePowerside,1);
					break;
				case AttackRangeDefine.heroMappedArmLineThree:
					retValue = getCellOfTheHero(sourcePos,sourcePowerside,2);
					break;
				case AttackRangeDefine.heroMappedArmLineFour:
					retValue = getCellOfTheHero(sourcePos,sourcePowerside,3);
					break;
					
			}
			
			var allretValue:Array = retValue.concat(allCellOnSelfSide);
			
			var checkedTroopRecord:Object = {};
			
			if(attackRange == AttackRangeDefine.wofangDiyiPaiDanwei || attackRange == AttackRangeDefine.wofangDiyiPaiDanweiAll)
			{
				var curTempCells:Array = [];
				var ctObject:Object = {};
				for(var ctc:int = 0;ctc < allretValue.length;ctc++)
				{
					var ctCell:Cell = allretValue[ctc];
					if(ctCell == null || ctCell.troopInfo == null)
						continue;
					if(ctObject.hasOwnProperty(ctCell.troopInfo.troopIndex))
						continue;
					ctObject[ctCell.troopInfo.troopIndex] = 1;
					curTempCells.push(ctCell);
				}
				allretValue = curTempCells;
			}
			
			//将目标中的cell转为具体的troop信息
			var checkCell:Cell;
			for(var ci:int = 0; ci < allretValue.length;ci++)
			{
				checkCell = allretValue[ci] as Cell;
				if(checkCell && checkCell.troopInfo && checkCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && 
					(checkCell.troopInfo.isHero || (checkCell.troopInfo.isAttackedTroop && !checkCell.troopInfo.isHero)) &&
					checkCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)			//troop要是可以被攻击的
				{
					if(attackRange == AttackRangeDefine.feiDiyiPai)
					{
						if(checkedTroopRecord[checkCell.troopInfo.troopIndex])
							continue;
						else
							checkedTroopRecord[checkCell.troopInfo.troopIndex] = 1;
					}
					if(sourceTroop.ownerSide == BattleDefine.firstAtk)
					{
						if(attackRange == AttackRangeDefine.woFangDiYiPaiAll || attackRange == AttackRangeDefine.wofangDiyiPaiDanweiAll)
						{
							targetTroopInfo.push(checkCell.troopInfo);
						}
						else
						{
							if(TroopFunc.isSelfTroopInfo(checkCell.troopInfo,sourceTroop))
								targetTroopInfo.push(checkCell.troopInfo);
						}
					}
					else 
					{
						targetTroopInfo.push(checkCell.troopInfo);
					}
				}
			}
			return targetTroopInfo;
		}
		
		/**
		 * 将重复的troop过滤掉 
		 * @param allretValue
		 * @return 
		 */
		public static function filterRepeatedTroops(allretValue:Array):Array
		{
			var checkRecord:Object={};
			var retTroopArr:Array=[];
			var singleTroop:CellTroopInfo;
			
			for(var ci:int = 0; ci < allretValue.length;ci++)
			{
				singleTroop = allretValue[ci] as CellTroopInfo;
				if(singleTroop && singleTroop.logicStatus != LogicSatusDefine.lg_status_dead &&
					!checkRecord.hasOwnProperty(singleTroop.troopIndex) && singleTroop.logicStatus != LogicSatusDefine.lg_status_hangToDie)
				{
					retTroopArr.push(singleTroop);
					checkRecord[singleTroop.troopIndex] = 1;
				}
			}
			
			return retTroopArr;
		}
		
		/**
		 * 获得某个阵型随机目标
		 * @param		power		
		 * @param		count
		 * @return 
		 */
		private static function getRandomAttackTarget(power:PowerSide,count:int,checkCondition:int,sourceTroop:CellTroopInfo ):Array
		{
			var oppoStartIndex:int = BattleFunc.getPowerSideStartIndex(power);
			var oppoCellCount:int = BattleFunc.getPowerSideCellCount(power.isFirstAtk);
			var allCellQuilified:Array=[];
			
			var checkedTroopIndex:Object={};
			var singleCell:Cell;
			var i:int = 0;
			
			var sourceCheckedTroopIndex:Object = {};
			
			for(i = oppoStartIndex;i < oppoStartIndex + oppoCellCount;i++)
			{
				singleCell = BattleUnitPool.getCellInfo(i);
				if(singleCell && singleCell.troopInfo && 
					singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && 
					singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)
				{
					//保证不会达到待机区以及以外的位置
					if(BattleModeDefine.checkNeedConsiderWave() && !power.isFirstAtk)
					{
						var cellPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(singleCell.index);
						if(cellPos.x > BattleDefine.shuaGuaiTroopLength - 1)
							continue;
					}
					
					var quilified:Boolean = TroopFilterTypeDefine.filterCell(singleCell,checkCondition);
					if(!quilified)
						continue;
					if(sourceTroop.ownerSide == BattleDefine.firstAtk)
						quilified = TroopFunc.isSelfTroopInfo(singleCell.troopInfo,sourceTroop);
					if(quilified)
					{
						if(sourceCheckedTroopIndex.hasOwnProperty(singleCell.troopInfo.troopIndex))			//不能有重复的格子
							continue;
						sourceCheckedTroopIndex[singleCell.troopInfo.troopIndex] = 1;
						allCellQuilified.push(singleCell.index);
					}
				}
			}
			
			var realQuilified:int = Math.min(allCellQuilified.length,count);
			var retArr:Array=[];
			
			var useRandomIndex:int = 0;
			var tempRandomValue:Number;
			var fakeRandomINdex:int = 0;
			
			var quilifiedCount:int = 0;
			
			while(quilifiedCount < realQuilified)
			{
				var guessIndex:int = 0;
				if(useRandomIndex++ < 3)			//随机值没有去完
				{
					var randomTag:int = RandomValueService.RD_SUIJI1;
					if(useRandomIndex == 1)
						randomTag = RandomValueService.RD_SUIJI1;
					else if(useRandomIndex == 2)
						randomTag = RandomValueService.RD_SUIJI2;
					else
						randomTag = RandomValueService.RD_SUIJI3;
					tempRandomValue = RandomValueService.getRandomValue(randomTag,sourceTroop.troopIndex);
					guessIndex = tempRandomValue * allCellQuilified.length;
				}
				else								//随机值用完
				{
					guessIndex = fakeRandomINdex++;
				}
				if(guessIndex >= allCellQuilified.length)
					break;
				if(retArr.indexOf(allCellQuilified[guessIndex]) < 0)
				{
					singleCell = BattleUnitPool.getCellInfo(allCellQuilified[guessIndex]);
					if(singleCell.troopInfo)
					{
						//按照troop进行过滤
						if(checkedTroopIndex.hasOwnProperty(singleCell.troopInfo.troopIndex))
							continue;
						checkedTroopIndex[singleCell.troopInfo.troopIndex] = 1;
						var allCellsOfTroop:Array = BattleFunc.getCellsOccupied(singleCell.troopInfo.troopIndex);
						for(var cIndex:int = 0;cIndex < allCellsOfTroop.length;cIndex++)
						{
							var singleRealCell:Cell = BattleUnitPool.getCellInfo(allCellsOfTroop[cIndex]);
							if(singleCell)
							{
								retArr.push(singleRealCell.index);
							}
						}
					}
					else						
						retArr.push(allCellQuilified[guessIndex]);
					quilifiedCount++;
				}
			}
			
			var retCellArr:Array=[];
			for each(var singleCellIndex:int in retArr)
			{
				retCellArr.push(BattleUnitPool.getCellInfo(singleCellIndex));
			}
			
			return retCellArr;
		}
		
		/**
		 * 随机n个格子 
		 * @return 
		 */
		private static function getRandomCellTarget(power:PowerSide,count:int,checkCondition:int,sourceTroop:CellTroopInfo ):Array
		{
			var oppoStartIndex:int = BattleFunc.getPowerSideStartIndex(power);
			var oppoCellCount:int = BattleFunc.getPowerSideCellCount(power.isFirstAtk);
			var allCellQuilified:Array=[];
			
			var singleCell:Cell;
			var i:int = 0;
			
			for(i = oppoStartIndex;i < oppoStartIndex + oppoCellCount;i++)
			{
				singleCell = BattleUnitPool.getCellInfo(i);
				if(singleCell && singleCell.troopInfo && 
					singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && 
					singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)
				{
					//保证不会达到待机区以及以外的位置
					if(BattleModeDefine.checkNeedConsiderWave() && !power.isFirstAtk)
					{
						var cellPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(singleCell.index);
						if(cellPos.x > BattleDefine.shuaGuaiTroopLength - 1)
							continue;
					}
					
					var quilified:Boolean = TroopFilterTypeDefine.filterCell(singleCell,checkCondition);
					if(!quilified)
						continue;
					if(sourceTroop.ownerSide == BattleDefine.firstAtk)
						quilified = TroopFunc.isSelfTroopInfo(singleCell.troopInfo,sourceTroop);
					if(quilified)
					{
						allCellQuilified.push(singleCell.index);
					}
				}
			}
			
			var realQuilified:int = Math.min(allCellQuilified.length,count);
			var retArr:Array=[];
			
			var useRandomIndex:int = 0;
			var tempRandomValue:Number;
			var fakeRandomINdex:int = 0;
			
			while(retArr.length < realQuilified)
			{
				var guessIndex:int = 0;
				if(useRandomIndex++ < 3)			//随机值没有去完
				{
					var randomTag:int = RandomValueService.RD_SUIJI1;
					if(useRandomIndex == 1)
						randomTag = RandomValueService.RD_SUIJI1;
					else if(useRandomIndex == 2)
						randomTag = RandomValueService.RD_SUIJI2;
					else
						randomTag = RandomValueService.RD_SUIJI3;
					tempRandomValue = RandomValueService.getRandomValue(randomTag,sourceTroop.troopIndex);
					guessIndex = tempRandomValue * allCellQuilified.length;
				}
				else								//随机值用完
				{
					guessIndex = fakeRandomINdex++;
				}
				if(guessIndex >= allCellQuilified.length)
					break;
				if(retArr.indexOf(allCellQuilified[guessIndex]) < 0)
				{
					singleCell = BattleUnitPool.getCellInfo(allCellQuilified[guessIndex]);
					retArr.push(allCellQuilified[guessIndex]);
				}
			}
			
			var retCellArr:Array=[];
			for each(var singleCellIndex:int in retArr)
			{
				retCellArr.push(BattleUnitPool.getCellInfo(singleCellIndex));
			}
			
			return retCellArr;
		}
		
		private static function getCellOfTheHero(sourcePos:Point,sourcePowerside:PowerSide,lineIndex:int):Array
		{
			var retInfo:Array = [];
			var cellsHorizon:Array = BattleFunc.particularCellsHorizonl(sourcePos.y,sourcePowerside,false);
			var singleCell:Cell;
			for(var i:int = 0;i < cellsHorizon.length;i++)
			{
				singleCell = cellsHorizon[i];
				if(singleCell == null)
					continue;
				var curPos:Point = getRowColumnByCellIndex(singleCell.index);
				if(curPos.x == lineIndex)
				{
					retInfo = [singleCell];
					break;
				}
			}
			return retInfo;
		}
		
		public static function getTroopOccupiedCellCount(sourceTroop:CellTroopInfo,sourcePowerside:PowerSide):int
		{
			var count:int = 0;
			var sourcePos:Point = getRowColumnByCellIndex(sourceTroop.occupiedCellStart);
			var cellsHorizon:Array = BattleFunc.particularCellsHorizonl(sourcePos.y,sourcePowerside,false);
			var singleCell:Cell;
			var recordObj:Object = {};
			for(var i:int = 0;i < cellsHorizon.length;i++)
			{
				singleCell = cellsHorizon[i];
				if(singleCell == null || singleCell.troopInfo == null)
					continue;
				if(singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead || singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_hangToDie)
					continue;
				if(singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_forceDead)
					continue;
				if(recordObj[singleCell.troopInfo.troopIndex])
					continue;
				recordObj[singleCell.troopInfo.troopIndex] = 1;
				count += singleCell.troopInfo.cellsCountNeed.x;
			}
			
			return count;
		}
		
		public static function getTroopCountOfSomeHero(sourceTroop:CellTroopInfo,sourcePowerside:PowerSide):int
		{
			var count:int = 0;
			var sourcePos:Point = getRowColumnByCellIndex(sourceTroop.occupiedCellStart);
			var cellsHorizon:Array = BattleFunc.particularCellsHorizonl(sourcePos.y,sourcePowerside,false);
			var singleCell:Cell;
			var recordObj:Object = {};
			for(var i:int = 0;i < cellsHorizon.length;i++)
			{
				singleCell = cellsHorizon[i];
				if(singleCell == null || singleCell.troopInfo == null)
					continue;
				if(singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead || singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_hangToDie)
					continue;
				if(singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_forceDead)
					continue;
				if(recordObj[singleCell.troopInfo.troopIndex])
					continue;
				recordObj[singleCell.troopInfo.troopIndex] = 1;
				count++;
			}
			
			return count;
		}
		
		/**
		 * 对取得的多个目标进行排序 
		 * @param objA
		 * @param ibjB
		 */
		private static function sortTargetPositions(objA:Cell,objB:Cell):int
		{
			if(objA == null || objB == null)
				return 1;
			var posA:Point = posotionArr[objA.index] as Point;
			var posB:Point = posotionArr[objB.index] as Point;
			if(posA.x < posB.x)																//x的值更小
				return -1;
			else if(posA.x > posB.x)
				return 1;
			else
			{
				return 0;
			}
		}
		
		
		/**
		 * 获得某一排中对应的目标cell 
		 * @param targetArr
		 * @param sourceTroopIndex
		 * @return 
		 */
		public static function getTargetFromSomeIndex(powerSide:PowerSide,yValue:int,distance:int):Cell
		{
			var singleCell:Cell;
			
			var curYValue:int = yValue;
			
			var upOffersetValue:int = yValue;
			var downOffetValue:int = yValue;
			
			var changeTag:int = 1;
			
			var findOnSingleDistance:Boolean = false;
			while(1)
			{
				singleCell = getCellOnYValueByDistance(powerSide,curYValue,distance);
				if(singleCell && singleCell.troopInfo && singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && 
					singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)
				{
					break;
				}
				if(upOffersetValue < 0 && downOffetValue >= BattleDefine.maxFormationYValue)					//两边到头，没有取到目标
					break;
				if(changeTag == 1)								//上次变化时向上取
				{
					if(downOffetValue >= BattleDefine.maxFormationYValue)//下方已经到头					
					{
						upOffersetValue--;
						curYValue = upOffersetValue;
					}
					else
					{
						downOffetValue++;
						changeTag = (changeTag + 1) % 2;
						curYValue = downOffetValue;
					}
				}
				else					//上次变化是向下取
				{
					if(upOffersetValue < 0)				//上方已经到头
					{
						downOffetValue++;
						curYValue = downOffetValue;
					}
					else
					{
						upOffersetValue--;
						changeTag = (changeTag + 1) % 2;
						curYValue = upOffersetValue;
					}
				}
			}
			
			return singleCell;
		}
		
		
		/**
		 * hero需要移动的目标cell
		 * @return 
		 */
		public static function getHeroMoveTarget(sourceTroop:CellTroopInfo,attackRange:int):Cell
		{
			if(sourceTroop == null)
				return null;
			
			var sourcePos:Point;
			var sourcePowerside:PowerSide = BattleFunc.getSidePowerInfoForTroop(sourceTroop);
			var opponentPowerSide:PowerSide = BattleFunc.getSidePowerInfoForTroop(sourceTroop,false);
			var targetCell:Cell;
			
			var hasZhengDui:Boolean = HeroAttackDisTypeDefine.checkRangeHasDirectTarget(attackRange);
			if(!hasZhengDui)						//此攻击方式没有正对目标
			{
				sourcePos = getRowColumnByCellIndex(sourceTroop.occupiedCellStart);		
				targetCell = getTargetFromSomeIndex(sourcePowerside,sourcePos.y,0);
				return targetCell;
			}
			
			var firstRowCells:Array=[];
			for(var yCount:int = 0; yCount < sourceTroop.cellsCountNeed.y;yCount++)
			{
				firstRowCells.push(sourceTroop.occupiedCellStart + yCount);
			}
			
			var oldTargetCell:Cell;
			var targetCellPos:Point;
			var oldCellPos:Point;
			var tempYDisValue:int = 0;
			var targetArrFound:Array=[];
			var curYGapvalue:int = 0;
			var index:int = 0;
			
			for(index = 0; index < firstRowCells.length; index++)
			{
				sourcePos = getRowColumnByCellIndex(firstRowCells[index]);
				
				var tempMaxDistanceRemain:int = 100;			//找到这个cell对应的目标的距离
				targetCell = getTargetFromSomeIndex(opponentPowerSide,sourcePos.y,tempMaxDistanceRemain);
				targetArrFound.push(targetCell);
				if(targetCell)
				{
					targetCellPos = getRowColumnByCellIndex(targetCell.index);
					tempYDisValue = Math.abs(targetCellPos.y - sourcePos.y);
					if(tempYDisValue != 0)
						continue;
					if(oldTargetCell == null)
					{
						oldTargetCell = targetCell;
						oldCellPos = targetCellPos;
					}
					else
					{
						if(oldCellPos.x > targetCellPos.x)		//所有正对目标中，选择距离最短的那个
						{
							oldTargetCell = targetCell;
							oldCellPos = targetCellPos;
							curYGapvalue = tempYDisValue;
						}
					}
				}
			}
			
			if(oldTargetCell == null)			
			{
				for(index = 0; index < targetArrFound.length;index++)
				{
					targetCell = targetArrFound[index];
					if(targetCell)
					{
						targetCellPos = getRowColumnByCellIndex(targetCell.index);
						sourcePos = getRowColumnByCellIndex(firstRowCells[index]);
						tempYDisValue = Math.abs(targetCellPos.y - sourcePos.y);
						if(oldTargetCell == null)
						{
							oldTargetCell = targetCell;
							oldCellPos = targetCellPos;
							curYGapvalue = tempYDisValue;
						}
						else
						{
							if(targetCellPos.x < oldCellPos.x)				//取距离近的
							{
								oldTargetCell = targetCell;
								oldCellPos = targetCellPos;
								curYGapvalue = tempYDisValue;
							}
							else if(targetCellPos.x == oldCellPos.x)		//距离相等的时候，取y方向偏移小的
							{
								if(tempYDisValue < curYGapvalue)
								{
									oldTargetCell = targetCell;
									oldCellPos = targetCellPos;
									curYGapvalue = tempYDisValue;
								}
							}
						}
					}
				}
			}
			
			return oldTargetCell;
		}
		
		/**
		 * 获得某个y值在某个范围内对应的cell集合 
		 * @param powerside  参与判断的势力
		 * @param yvalue	 y值	
		 * @param distance   范围值
		 */
		public static function getCellOnYValueByDistance(powerSide:PowerSide,yvalue:int,distance:int):Cell
		{
			var retCell:Cell;
			
			if(yvalue < 0 || yvalue >= BattleDefine.maxFormationYValue)
				return retCell;
			
			var singleIndex:int = 0;
			if(!powerSide.isFirstAtk)
			{
				singleIndex = BattleFunc.getPowerSideCellCount();
			}
			
			singleIndex += yvalue;
			
			var curCheckIndex:int = 0;
			
			var maxDistance:int = Math.min(distance,powerSide.xMaxValue - 1);
			for(var i:int = 0; i <= maxDistance; i++)					
			{
				curCheckIndex = singleIndex + i * BattleDefine.maxFormationYValue;
				
				retCell = BattleUnitPool.getCellInfo(curCheckIndex) as Cell;
				if(retCell && retCell.troopInfo && retCell.troopInfo.isAttackedTroop && retCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && 
					retCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie)
					return retCell;
			}
			return null;
		}
		
		/**
		 * 是否需要攻击范围判断 
		 * @return 
		 * 
		 */
		private static function isDistanceNeeded(attackRange:int):Boolean
		{
			var ret:Boolean = false;
			switch(attackRange)
			{
				case AttackRangeDefine.dantiGongJi:
				case AttackRangeDefine.duotiGongJi1:
				case AttackRangeDefine.duotiGongJi2:
				case AttackRangeDefine.duotiGongJi3:
				case AttackRangeDefine.duotiGongJi4:
				case AttackRangeDefine.duotiGongJi5:
				case AttackRangeDefine.duotiGongJi6:
				case AttackRangeDefine.duotiGongJi7:
				case AttackRangeDefine.duotiGongJi8:
				case AttackRangeDefine.duotiGongJi9:
				case AttackRangeDefine.duotiGongJi10:
				case AttackRangeDefine.duotiGongJi11:
					ret = true;
					break;
			}
			return ret;
		}
		
		/**
		 * 根据某个基本的cell找到多个攻击的目标 
		 * @param baseCell						基本的cell
		 * @param index							攻击范围
		 * @return 
		 * 
		 */
		private static function getMultiTarget(targetPowerSide:PowerSide,basePos:Point,range:int):Array
		{
			var startIndex:int = BattleFunc.getPowerSideStartIndex(targetPowerSide);
			var retValue:Array=[];
			
			var ptArr:Array=[];
			
			switch(range)
			{
				case AttackRangeDefine.duotiGongJi1:
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					break;
				case AttackRangeDefine.duotiGongJi2:
					ptArr.push(new Point(basePos.x,basePos.y + 1));
					break;
				case AttackRangeDefine.duotiGongJi3:
					ptArr.push(new Point(basePos.x,basePos.y - 1));
					ptArr.push(new Point(basePos.x,basePos.y + 1));
					break;
				case AttackRangeDefine.duotiGongJi4:
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					ptArr.push(new Point(basePos.x + 2,basePos.y));
					break;
				case AttackRangeDefine.duotiGongJi5:
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					ptArr.push(new Point(basePos.x,basePos.y + 1));
					break;
				case AttackRangeDefine.duotiGongJi6:
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					ptArr.push(new Point(basePos.x,basePos.y + 1));
					ptArr.push(new Point(basePos.x,basePos.y - 1));
					break;
				case AttackRangeDefine.duotiGongJi7:
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					ptArr.push(new Point(basePos.x,basePos.y + 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y + 1));
					break;
				case AttackRangeDefine.duotiGongJi8:
					ptArr.push(new Point(basePos.x,basePos.y - 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y - 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					ptArr.push(new Point(basePos.x,basePos.y + 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y + 1));
					break;
				case AttackRangeDefine.duotiGongJi9:
					ptArr.push(new Point(basePos.x + 1,basePos.y - 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					ptArr.push(new Point(basePos.x + 1,basePos.y + 1));
					break;
				case AttackRangeDefine.duotiGongJi10:
					ptArr.push(new Point(basePos.x,basePos.y - 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y - 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					ptArr.push(new Point(basePos.x,basePos.y + 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y + 1));
					ptArr.push(new Point(basePos.x + 2,basePos.y - 1));
					ptArr.push(new Point(basePos.x + 2,basePos.y));
					ptArr.push(new Point(basePos.x + 2,basePos.y + 1));
					break;
				case AttackRangeDefine.duotiGongJi11:
					ptArr.push(new Point(basePos.x + 1,basePos.y - 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					ptArr.push(new Point(basePos.x + 1,basePos.y + 1));
					ptArr.push(new Point(basePos.x + 1,basePos.y));
					break;
			}
			
			var singlePt:Point;
			var singleCell:Cell;
			var singleCheckObj:Object={};
			for(var i:int = 0; i < ptArr.length;i++)
			{
				singlePt = ptArr[i] as Point;
				
				singlePt.x = Math.min(singlePt.x,BattleDefine.maxFormationXValue - 2);
				singlePt.y = Math.min(singlePt.y,BattleDefine.maxFormationYValue - 1);
				
				singlePt.x = Math.max(singlePt.x,0);
				singlePt.y = Math.max(singlePt.y,0);
				
				singleCell = getCellByRowColumn(targetPowerSide,singlePt);
				if(singleCell && !singleCheckObj.hasOwnProperty(singleCell.index))
				{
					singleCheckObj[singleCell.index] = 1;
					if(singleCell && singleCell.troopInfo && singleCell.troopInfo.isHero)
						continue;
					retValue.push(singleCell);
				}
			}
			return retValue;
		}
		
		/**
		 * 获得某个cell在阵营里面是第几排第几列 
		 * @return 
		 */
		public static function getRowColumnByCellIndex(sourceIndex:int):Point
		{
			var retValue:Point = new Point;
			var atkSideMaxCellCount:int = BattleFunc.getPowerSideCellCount();
			
			if(sourceIndex < atkSideMaxCellCount)
			{
				retValue.x = int(sourceIndex / BattleDefine.maxFormationYValue);
				retValue.y = int(sourceIndex % BattleDefine.maxFormationYValue);
			}
			else
			{
				sourceIndex -= atkSideMaxCellCount;
				retValue.x = int(sourceIndex / BattleDefine.maxFormationYValue);
				retValue.y = int(sourceIndex % BattleDefine.maxFormationYValue);
			}
			return retValue;
		}
		
		/**
		 * 通过起始位置以及所在位置获得对应的cell
		 * @param startIndex
		 * @param pos
		 * @return 
		 */
		public static function getCellByRowColumn(targetPowerside:PowerSide,pos:Point):Cell
		{
			var startIndex:int = targetPowerside.isFirstAtk ? 0 : BattleFunc.getPowerSideCellCount();
			return BattleUnitPool.getCellInfo(startIndex + BattleDefine.maxFormationYValue * pos.x + pos.y) as Cell;
		}
		
		/**
		 * 得到此cell咋troop动画上竖直方向的index 
		 * @param cell
		 * @param troop
		 * @return 
		 */
		public static function getCellYIndex(cell:Cell,troop:CellTroopInfo):int
		{
			var index:int = 0;
			if(cell == null || troop == null || troop.cellsCountNeed.y <= 1)
				return index;
			
			var cellPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(cell.index);
			var startPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(troop.occupiedCellStart);
			
			index = cellPos.y - startPos.y;
			
			index = Math.max(index,0);
			
			return index;
		}
		
		/**
		 * 判断某些y值上对应的横排是否死亡 
		 * @param powerSide
		 * @param yValue
		 * @return 
		 */
		public static function checkHasTroopAliveOnYValue(powerSide:PowerSide,yValue:int,occupiedYCount:int):Boolean
		{
			var retValue:Boolean = false;
			if(yValue < 0 || yValue > BattleDefine.maxFormationYValue)
				return retValue;
			var curYValue:int = 0;
			var cellstartIndex:int = powerSide.isFirstAtk ? 0 : BattleFunc.getPowerSideCellCount();
			var singleCell:Cell;
			var curCheckCellIndex:int = 0;
			for(var yIndex:int = 0; yIndex < occupiedYCount; yIndex++)
			{
				curYValue = yValue + yIndex;
				for(var i:int = 0; i < powerSide.xMaxValue;i++)
				{
					curCheckCellIndex = cellstartIndex + i * BattleDefine.maxFormationYValue + curYValue;
					singleCell = BattleUnitPool.getCellInfo(curCheckCellIndex) as Cell;
					if(singleCell && singleCell.troopInfo && singleCell.troopInfo.troopVisibleOnBattle && !singleCell.troopInfo.isHero && (singleCell.troopInfo.curArmCount > 0 || singleCell.troopInfo.curTroopHp > 0))
					{
						retValue = true;
						break;
					}
				}
				if(retValue)
					break;
			}
			return retValue;
		}
		
		public static function checkHasTroopAliveOnXValue(powerSide:PowerSide,xValue:int):Boolean
		{
			var retValue:Boolean = false;
			if(xValue < 0 || xValue > BattleDefine.maxFormationXValue)
				return retValue;
			var curXValue:int = 0;
			var cellstartIndex:int = powerSide.isFirstAtk ? 0 : BattleFunc.getPowerSideCellCount();
			var singleCell:Cell;
			var curCheckCellIndex:int = 0;
			curXValue = (xValue) * BattleDefine.maxFormationYValue;
			for(var i:int = 0; i < powerSide.yMaxValue;i++)
			{
				curCheckCellIndex = cellstartIndex + i + curXValue;
				singleCell = BattleUnitPool.getCellInfo(curCheckCellIndex) as Cell;
				if(singleCell && singleCell.troopInfo && singleCell.troopInfo.troopVisibleOnBattle && 
					!singleCell.troopInfo.isHero && (singleCell.troopInfo.curArmCount > 0 || 
						singleCell.troopInfo.curTroopHp > 0) && singleCell.troopInfo.attackUnit.slotType != FormationElementType.ARROW_TOWER)
				{
					retValue = true;
					break;
				}
			}
			return retValue;
		}
		
		/**
		 * 获得播放奥义的时候英雄移动的目标cell 
		 * @param sourceTroop
		 * @return 
		 */
		public static function getHeroAoyiTargetCell(sourceTroop:CellTroopInfo):Cell
		{
			var retCell:Cell;
			var targetCellIndex:int = 0;
			if(sourceTroop.ownerSide != BattleDefine.firstAtk)
			{
				var leftCellCount:int = BattleFunc.getPowerSideCellCount();
				targetCellIndex += leftCellCount;
			}
			targetCellIndex += BattleDefine.maxFormationYValue;
			if(BattleDefine.maxFormationYValue % 2 == 0)
				targetCellIndex += BattleDefine.maxFormationYValue / 2 - 1;
			else
				targetCellIndex += BattleDefine.maxFormationYValue / 2;
			retCell = BattleUnitPool.getCellInfo(targetCellIndex);
			return retCell; 
		}
		
		public static function getFakeHeroAoyiTargetCell(sourceTroop:CellTroopInfo,singleTarget:CellTroopInfo):Cell
		{
			var retCell:Cell;
			var targetCellIndex:int = 0;
			if(sourceTroop.ownerSide != BattleDefine.firstAtk)
			{
				var leftCellCount:int = BattleFunc.getPowerSideCellCount();
				targetCellIndex += leftCellCount;
			}
			targetCellIndex += BattleDefine.maxFormationYValue;
			var targetpos:Point = BattleTargetSearcher.getRowColumnByCellIndex(singleTarget.occupiedCellStart);
			targetCellIndex += targetpos.y;
			retCell = BattleUnitPool.getCellInfo(targetCellIndex);
			return retCell;
		}
		
		/**
		 * 获得某一阵型方的中间的英雄信息
		 * @param sourceTroop
		 * @return 
		 */
		public static function getHeroInFomationCenter(sourceTroop:CellTroopInfo):CellTroopInfo
		{
			var targetPside:PowerSide;
			if(sourceTroop.ownerSide == BattleDefine.firstAtk)
			{
				targetPside = BattleManager.instance.pSideAtk;
			}
			else
			{
				targetPside = BattleManager.instance.pSideDef;
			}
			
			var targetYValue:int = 0;
			
			if(BattleDefine.maxFormationYValue % 2 == 0)
				targetYValue = BattleDefine.maxFormationYValue / 2 - 1;
			else
				targetYValue = BattleDefine.maxFormationYValue / 2;
			
			var targetHeroInfo:CellTroopInfo = BattleFunc.getHeroTroopForIndex(targetYValue,targetPside);
			return targetHeroInfo;
		}
		
		public static function getRealPowerSide(range:int):int
		{
			var retSide:int = 0;
			var needNiZhuan:Boolean = false;
			var allSides:Array = [BattleDefine.firstAtk,BattleDefine.secondAtk];
			switch(range)
			{
				case AttackRangeDefine.difangMouDanwei:
				case AttackRangeDefine.difangMouYipai:
				case AttackRangeDefine.difangMouLiangPai:
				case AttackRangeDefine.difangMouSanPai:
				case AttackRangeDefine.difangMouYingXiong:	
					needNiZhuan = !needNiZhuan;
					break;
			}
			if(BattleManager.instance.battleMode == BattleModeDefine.PVP_Single)
			{
				var tempData:BDataPvpSingle = BattleHandler.instance.onLineManager.curbattledata as BDataPvpSingle;
				if(tempData)
				{
					if(GlobalData.owner.uid == tempData.attackuid)				//本方是攻击方
					{
						needNiZhuan = needNiZhuan;
					}
					else
					{
						needNiZhuan = !needNiZhuan;
					}
				}
			}
			retSide = needNiZhuan ? BattleDefine.secondAtk : BattleDefine.firstAtk;
			return retSide;
		}
		
		public static function tureRangeToChooseRange(range:int):int
		{
			var retRange:int = 0;
			
			switch(range)
			{
				case AttackRangeDefine.wofangMouDanwei:
				case AttackRangeDefine.difangMouDanwei:
					retRange = BattleDefine.Range_singleArm;
					break;
				case AttackRangeDefine.wofangYipai:
				case AttackRangeDefine.difangMouYipai:	
					retRange = BattleDefine.Range_columnArm1;
					break;
				case AttackRangeDefine.wofangLiangPai:
				case AttackRangeDefine.difangMouLiangPai:	
					retRange = BattleDefine.Range_columnArm2;
					break;
				case AttackRangeDefine.wofangSanPai:
				case AttackRangeDefine.difangMouSanPai:
					retRange = BattleDefine.Range_columnArm3;
					break;
				case AttackRangeDefine.wofangMouYingXiong:
				case AttackRangeDefine.difangMouYingXiong:	
					retRange = BattleDefine.Range_SingleHero;
					break;
				
				
			}
			
			return retRange;
		}
		
	}
}