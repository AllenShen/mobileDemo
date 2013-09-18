package modules.battle.managers
{
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.funcclass.TroopInitClearFunc;

	public class TroopPool
	{
		
		private static var _cellTroopPoolArr:Array=[];
		
		public static function getFreeTroop(troopIndex:int):CellTroopInfo
		{
			var retTroopInfo:CellTroopInfo;
			var singleTroopInfo:CellTroopInfo;
			for(var i:int = 0; i < _cellTroopPoolArr.length;i++)
			{
				singleTroopInfo =  _cellTroopPoolArr[i] as CellTroopInfo;
				if(singleTroopInfo && !singleTroopInfo.isBusy)
				{
					retTroopInfo = singleTroopInfo;
					retTroopInfo.setTroopIndex(troopIndex);
					retTroopInfo.isBusy = true;
					break;
				}
			}
			if(retTroopInfo == null)
			{
				retTroopInfo = new CellTroopInfo(troopIndex);
				retTroopInfo.isBusy = true;
				_cellTroopPoolArr.push(retTroopInfo);
			}
			return retTroopInfo;
		}
		
		public static function clearTroopPool():void
		{
			var singleTroopInfo:CellTroopInfo;
			for(var i:int = 0; i < _cellTroopPoolArr.length;i++)
			{
				singleTroopInfo =  _cellTroopPoolArr[i] as CellTroopInfo;
				if(singleTroopInfo && singleTroopInfo.isBusy)
				{
					TroopInitClearFunc.clearTroopInfo(singleTroopInfo,true);
				}
			}
		}

		public function TroopPool()
		{
		}
	}
}