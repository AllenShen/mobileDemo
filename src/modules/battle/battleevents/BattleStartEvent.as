package modules.battle.battleevents
{
	import flash.events.Event;

	public class BattleStartEvent extends Event
	{
		
		public static const BATTLE_START:String = "battleStart";
		
		public var battleMode:int = 0;					//开始的模式
		
		public function BattleStartEvent(type:String,mode:int)
		{
			super(type);
			this.battleMode = mode;
		}
	}
}