package modules.battle.battleevents
{
	import flash.events.Event;
	
	public class CheckAttackEvent extends Event
	{
		
		/**
		 * 检查是否有cell能继续攻击 
		 */
		public static const CHECK_AttackORPlay:String = "checkCellAttackPlay";
		
		public function CheckAttackEvent(type:String)
		{
			super(type);
		}
	}
}