package modules.battle.battleevents
{
	import flash.events.Event;
	
	public class CheckRoundEndEvent extends Event
	{
		
		public static const ROUND_END:String = "checkRoundEnd";
		
		public function CheckRoundEndEvent(type:String)
		{
			super(type);
		}
	}
}