package modules.battle.battleevents
{
	import flash.events.Event;
	
	import modules.battle.battlelogic.BattleCardObject;
	
	public class BattleCardClickedEvent extends Event
	{
		
		public static const cardUserdInTheRound:String = "cardBeUsedInTheRound";
		
		public var targetCard:BattleCardObject;
		
		public function BattleCardClickedEvent(type:String,targetCard:BattleCardObject)
		{
			this.targetCard = targetCard;
			super(type);
		}
	}
}