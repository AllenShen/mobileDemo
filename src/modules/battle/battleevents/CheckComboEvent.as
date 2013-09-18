package modules.battle.battleevents
{
	import flash.events.Event;
	
	/**
	 * 一次简单的攻击完成，判断chain中是否有连击存在 
	 * @author Administrator
	 * 
	 */
	public class CheckComboEvent extends Event
	{
		
		/**
		 * 是否有连击产生 
		 */
		public static const CheckChainCombo:String = "CHECK_COMBO_EXIST";
		
		public function CheckComboEvent(type:String)
		{
			super(type);
		}
	}
}