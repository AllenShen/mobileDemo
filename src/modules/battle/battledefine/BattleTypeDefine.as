package modules.battle.battledefine
{
	public class BattleTypeDefine
	{
		
		//定义buff是影响攻击还是影响被攻击数值
		public static const atkBuff:int = 0;		//攻击时影响
		public static const defBuff:int = 1;		//防守时影响
		public static const bothBuff:int = 2;		//攻击防守时都影响
		
		public static const HP_Value:int = 0;				//血量
		public static const Morale_Value:int = 1;			//士气
		
		public function BattleTypeDefine()
		{
		}
	}
}