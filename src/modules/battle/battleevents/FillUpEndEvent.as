package modules.battle.battleevents
{
	import flash.events.Event;
	
	public class FillUpEndEvent extends Event
	{
		public static const FILLUPENDEVENT:String = "fillUpEnd";
		
		public var troopIndex:int = 0;					//移动的troopIndex
		
		public function FillUpEndEvent(type:String,troopIndex:int)
		{
			super(type);
			this.troopIndex= troopIndex;
		}
	}
}