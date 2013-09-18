package modules.battle.battleevents
{
	import flash.events.Event;
	
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.utils.BattleEventTagFactory;
	import modules.battle.utils.BattleUtils;
	
	/**
	 * troop需要达成某个状态 
	 * @author SDD
	 */
	public class TroopStatusNeedEvent extends Event
	{
		
		public var targetStatus:int = 0;
		
		public function TroopStatusNeedEvent(troop:CellTroopInfo,statusNeed:int)
		{
			this.targetStatus = statusNeed;
			var eventType:String = BattleEventTagFactory.getNeedTroopStatus(troop,statusNeed);
			super(eventType);
		}
	}
}