package modules.battle.battlecomponent
{
	import flash.display.Sprite;
	
	import modules.battle.battlelogic.CellTroopInfo;

	public class TroopComponentBase extends Sprite
	{
		private var _dataSource:CellTroopInfo;
		
		public function TroopComponentBase(troop:CellTroopInfo)
		{
			this.dataSource = troop;
		}
		
		public function get dataSource():CellTroopInfo
		{
			return _dataSource;
		}
		
		public function set dataSource(value:CellTroopInfo):void
		{
			_dataSource = value;
		}
		
		public function clearInfo():void
		{
			this.dataSource = null;
		}
		
	}
}