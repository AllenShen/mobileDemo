package modules.battle.battledata
{
	

	public class BattleData
	{
		public var battleid:int;
		public var battletype:int;
		
		public var attacksidedata:* = null;
		public var defendsidedata:* = null;
		
		public function BattleData()
		{
		}
		
		public function checkDataReady():Boolean
		{
			if(attacksidedata != null && defendsidedata != null)
				return true;
			else
				return false;
		}
		
		/**
		 * 更新信息，主要存储当前在阵上的英雄信息
		 */
		public function initInfo():void
		{
			
		}
	}
}