package modules.battle.battlelogic
{
	public class HangUpCombatChain
	{
		
		public var chainIndex:int = 0;
		
		public var combatChain:CombatChain;
		
		public function HangUpCombatChain(combatchain:CombatChain)
		{
			this.combatChain = combatchain;
			this.chainIndex = combatchain.chainIndex;
		}
		
		public function makeHangUpChainWork():void
		{
			if(combatChain == null)
			{
				combatChain.handlerDamageLogic();
			}
		}
		
	}
}