package modules.battle.battleevents
{
	import flash.events.Event;
	
	import modules.battle.utils.BattleEventTagFactory;
	import modules.battle.utils.BattleUtils;
	
	/**
	 * 表示chain之间动画特效播放控制的event 
	 * @author SDD
	 * 
	 */
	public class DamageArrivedEvent extends Event
	{
		
		public static const DAMAGECOMING:String = "damageComing";
		
		/**
		 * 伤害的来源 
		 */
		public var damageSource:int = 0;
		/**
		 * 伤害目标 
		 */
		public var damageTarget:int = 0;
		
		public function DamageArrivedEvent(damageSource:int,damageTarget:int)
		{
			this.damageSource = damageSource;
			this.damageTarget = damageTarget;
			super(BattleEventTagFactory.geneDamageArrivedTag(damageSource,damageTarget));
		}
	}
}