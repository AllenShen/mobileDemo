package modules.battle.battledefine
{
	public class OtherStatusDefine
	{
		//一下是某个cell是否已经攻击的状态定义
		public static const hasNotAttack:int = 0;
		public static const hasAttacked:int = 1;
		public static const attackFiled:int = 2;	
		
		public static const battleIdle:int = 0;			//空闲状态
		public static const battleOn:int = 1;				//战斗正在进行
		public static const battlePrepareing:int = 2;		//战斗正在回放
		public static const battleReplying:int = 3;
		
		public static const noOffsetValue:int = 0;		//偏移值
		public static const offsetBack:int = 1;			//向后偏移一个值
		
		public function OtherStatusDefine()
		{
		}
	}
}