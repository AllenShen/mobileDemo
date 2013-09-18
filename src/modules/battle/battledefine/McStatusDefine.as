package modules.battle.battledefine
{
	public class McStatusDefine
	{
		
		//以下是cell显示状态的定义
		public static const mc_status_idle:int = 0;						//空闲状态
		public static const mc_status_attacking:int = 1;				//攻击中
		public static const mc_status_defending:int = 2;				//防御中
		public static const mc_status_attack_combo:int = 3;				//连击进攻中
		public static const mc_status_defense_combo:int = 4;			//连击防守中
		public static const mc_status_running:int = 5;					//在补进的过程中，此状态不可攻击
		public static const mc_status_waitForDamage:int = 6;			//等待伤害到达，此时不能攻击
		public static const mc_status_dead:int = 7;						//死亡
		
		public static const mc_status_dazhao:int = 8;
		
		public static const mc_status_waitingForNextWave:int = 10;
		
		public function McStatusDefine()
		{
		}
	}
}