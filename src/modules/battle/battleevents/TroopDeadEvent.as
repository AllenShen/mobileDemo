package modules.battle.battleevents
{
	import flash.events.Event;

	public class TroopDeadEvent extends Event
	{
		
		public static const TROOPDEADEVENT:String = "troopDead";
		
		public var troopIndex:int = 0;
		
		public function TroopDeadEvent(type:String,troopIndex:int)
		{
			super(type);
			this.troopIndex = troopIndex;
		}
	}
}