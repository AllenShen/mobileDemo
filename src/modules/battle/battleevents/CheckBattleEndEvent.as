package modules.battle.battleevents
{
	import flash.events.Event;
	
	public class CheckBattleEndEvent extends Event
	{
		
		public static var BATTLE_END:String = "checkBattleEndEvent";
		
		public static var BATTLE_VEDIO_END:String = "checkBattleVedioEnd";
		
		public function CheckBattleEndEvent(type:String)
		{
			super(type);
		}
	}
}