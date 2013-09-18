package modules.battle.battleevents
{
	import flash.events.Event;
	
	import modules.battle.utils.BattleEventTagFactory;
	import modules.battle.utils.BattleUtils;
	
	/**
	 * 表示某个troop发动攻击的事件
	 * 用于减少效果的回合 
	 * @author SDD
	 * 
	 */
	public class EffectTroopNewRoundEvent extends Event
	{
		
		//进入round的troopIndex
		public var troopIndex:int = 0;
		
		public function EffectTroopNewRoundEvent(troopIndex:int)
		{
			this.troopIndex = troopIndex;
			super(BattleEventTagFactory.geneNewTroopRoundTag(troopIndex));
		}
	}
}