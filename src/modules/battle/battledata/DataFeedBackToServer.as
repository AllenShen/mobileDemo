package modules.battle.battledata
{
	/**
	 * 每回合结束需要向服务器反馈的本方战斗数据 
	 * @author SDD
	 */
	public class DataFeedBackToServer
	{
		
		public var moraleValue:int ={};				//当前英雄的士气值
		public var deadTroops:Object={};				//死亡的troop
		public var troopBuJin:Object={};				//次方的补进数据
			
		public function DataFeedBackToServer()
		{
		}
	}
}