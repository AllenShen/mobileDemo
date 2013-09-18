package modules.battle.battleevents
{
	import flash.events.Event;
	
	import modules.battle.utils.BattleEventTagFactory;
	import modules.battle.utils.BattleUtils;

	/**
	 * 处理effect中sourceTroop死亡的事件 
	 * @author Administrator
	 */
	public class EffectSourceDeadEvent extends Event
	{
		
		/**
		 * troopIndex 
		 */
		public var troopIndex:int = 0;
		
		public function EffectSourceDeadEvent(index:int)
		{
			this.troopIndex = index;
			super(BattleEventTagFactory.geneTroopDeadTag(index));
		}
	}
}