package modules.battle.battledefine
{
	public class TypeDefine
	{
		
		//以下是兵种类型的定义
//		public static const Infantry:int = 0;					//步兵
//		public static const Archers:int = 1;					//弓箭手
//		public static const Master:int = 2;					//法师
//		public static const Mechanism:int = 3;				//机械单位
//		public static const Other:int = 4;					//其他种类
		
		//定义buff是影响攻击还是影响被攻击数值
		public static const atkBuff:int = 0;		//攻击时影响
		public static const defBuff:int = 1;		//防守时影响
		public static const bothBuff:int = 2;		//攻击防守时都影响
		
		public function TypeDefine()
		{
		}
	}
}