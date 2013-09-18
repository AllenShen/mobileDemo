package modules.battle.battledefine
{
	public class LogicSatusDefine
	{
		
		//以下是cell显示状态的定义
		public static const lg_status_idle:int = 0;						//空闲状态
		public static const lg_status_attack:int = 1;					//攻击中
		public static const lg_status_defend:int = 2;					//防御中
		public static const lg_status_filling:int = 5;					//在补进的过程中，此状态不可攻击
		public static const lg_status_waitForDamage:int = 6;				//等待伤害到达，此时不能攻击
		public static const lg_status_dead:int = 7;						//死亡
		
		public static const lg_status_waitForPath:int = 8;				//当前正在等待录像
		
		public static const lg_status_dazhao:int = 9;					//大招攻击
		
		public static const lg_status_waitingForNextWave:int = 10;		//等待下波进行攻击
		
		public static const lg_status_hangToDie:int = 11;				//等死,只有在奥义攻击的时候才能发生
		
		public static const lg_status_forceDead:int = 12;						//被玩家回收的兵的状态
		
		public function LogicSatusDefine()
		{
		}
	}
}