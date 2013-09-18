package modules.battle.battledata
{
	import modules.battle.battlelogic.CellTroopInfo;

	public class FormationRemainInfo
	{
		public var fIndex:int = 0;
		public var curArmCount:int = 0;
		
		public function FormationRemainInfo(troopInfo:CellTroopInfo)
		{
			this.fIndex = troopInfo.slotIndex;
			this.curArmCount = troopInfo.curArmCount;
		}
	}
}