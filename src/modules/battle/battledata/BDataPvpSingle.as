package modules.battle.battledata
{
	public class BDataPvpSingle extends BattleData
	{
		public var attackuid:int;
		public var defenduid:int;
		
		public function BDataPvpSingle()
		{
			super();
		}
		
		public function setBattleData(uid:int, data:Array):void
		{
			if(uid == attackuid)
			{
				attacksidedata = data;
			}
			else if(uid == defenduid)
			{
				defendsidedata = data;
			}
		}
	}
}