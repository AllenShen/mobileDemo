package modules.battle.managers
{
	import flash.geom.Point;
	
	import modules.battle.battledefine.BattleModeDefine;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.TroopFilterTypeDefine;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.funcclass.BattleFunc;

	public class BattleTroopCellFinder
	{
		
		/**
		 * 获得某个power的所有cell 
		 * @param power
		 * @return 
		 */
		public static function getAllCellForPowerSide(power:PowerSide,filterCondition:int = 0):Array
		{
			var retValue:Array=[];
			
			var oppoStartIndex:int = BattleFunc.getPowerSideStartIndex(power);
			var oppoCellCount:int = BattleFunc.getPowerSideCellCount(power.isFirstAtk);
			
			var singleCell:Cell;
			var i:int = 0;
			var cellPos:Point;
			for(i = oppoStartIndex;i < oppoStartIndex + oppoCellCount;i++)
			{
				singleCell = BattleUnitPool.getCellInfo(i);
				if(singleCell && singleCell.troopInfo && singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead)
				{
					//对待机区的兵直接过滤
					if(BattleModeDefine.checkNeedConsiderWave() && !power.isFirstAtk)
					{
						cellPos = BattleTargetSearcher.getRowColumnByCellIndex(singleCell.index);
						if(cellPos.x >= BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex)
							continue;
					}
					if(TroopFilterTypeDefine.filterCell(singleCell,filterCondition))
					{
						retValue.push(singleCell);
					}
				}
			}
			return retValue;
		}
		
		/**
		 * 获得某个power的所有troop
		 * @param power
		 * @param filterCondition	过滤条件
		 * @return 
		 */
		public static function getAllTroopForPowerSide(power:PowerSide,filterCondition:int = 0):Array
		{
			var retValue:Array=[];
			
			var oppoStartIndex:int = BattleFunc.getPowerSideStartIndex(power);
			var oppoCellCount:int = BattleFunc.getPowerSideCellCount(power.isFirstAtk);
			var checkedTroopIndex:Object={};
			
			var singleCell:Cell;
			var i:int = 0;
			for(i = oppoStartIndex;i < oppoStartIndex + oppoCellCount;i++)
			{
				singleCell = BattleUnitPool.getCellInfo(i);
				if(singleCell && singleCell.troopInfo && singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead 
					&& checkedTroopIndex.hasOwnProperty(singleCell.troopInfo.troopIndex))
				{
					if(TroopFilterTypeDefine.filterCell(singleCell,filterCondition))
					{
						checkedTroopIndex[singleCell.troopInfo.troopIndex] = 1;
						retValue.push(singleCell.troopInfo);
					}
				}
			}
			
			return retValue;
		}
		
		public function BattleTroopCellFinder()
		{
		}
	}
}