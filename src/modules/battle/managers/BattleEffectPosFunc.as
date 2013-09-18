package modules.battle.managers
{
	import flash.geom.Point;
	
	import macro.BattleDisplayDefine;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battlelogic.CellTroopInfo;

	/**
	 * 用于取得各种特效所在的位置，可能是加在troop上，可能加在场景上
	 * @author SDD
	 */
	public class BattleEffectPosFunc
	{
		public function BattleEffectPosFunc()
		{
		}
		
		/**
		 * 取得troop的中心点 
		 * @param troopInfo	troopInfo 信息
		 * @return 
		 */
		public static function getTroopCenterPoint(troopInfo:CellTroopInfo):Point
		{
			var pos:Point = new Point(0,0);
			if(troopInfo == null)
				return pos;
			
			if(troopInfo.ownerSide == BattleDefine.firstAtk)
			{
				pos.x -= ((troopInfo.cellsCountNeed.x - 2) / 2) * BattleDisplayDefine.cellWidth;
				pos.y += ((troopInfo.cellsCountNeed.y) * BattleDisplayDefine.cellHeight - (troopInfo.cellsCountNeed.y - 1) * BattleDisplayDefine.cellGapVertocal) / 2;
			}
			else
			{
				pos.x += (troopInfo.cellsCountNeed.x / 2) * BattleDisplayDefine.cellWidth;
				pos.y += ((troopInfo.cellsCountNeed.y) * BattleDisplayDefine.cellHeight - (troopInfo.cellsCountNeed.y - 1) * BattleDisplayDefine.cellGapVertocal) / 2;
			}
			
			return pos;
		}
		
		/**
		 * 获得加到脚底特效的位置 
		 * @param troop
		 */
		public static function getTroopDownPos(troop:CellTroopInfo):Point
		{
			var retPt:Point = new Point;
			if(troop.ownerSide == BattleDefine.firstAtk)
			{
				retPt.x = 0 - (troop.cellsCountNeed.x - 1) * BattleDisplayDefine.cellWidth;
				retPt.y = (troop.cellsCountNeed.y - 1) * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal);
			}
			else
			{
				retPt.x = 0;
				retPt.y = (troop.cellsCountNeed.y - 1) * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal);
			}
			return retPt;
		}
		
	}
}