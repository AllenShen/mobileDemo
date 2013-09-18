package modules.battle.battlelogic.skillandeffect
{
	/**
	 * 技能 
	 * @author Administrator
	 * 
	 */
	public class BattleSkill
	{
		
		public var skillId:int = 0;
		
		public var skillName:String;
		public var skillLauncher:int = 0;				//技能的发起者
		
		/**
		 * 保存具体effect数据 
		 */
		public var effectContentArr:Array;
		
		public function BattleSkill()
		{
		}
		
		/**
		 * 初始化 
		 * @param data
		 * 
		 */
		public function init(data:Object):void
		{
			effectContentArr ={};
		}
		
	}
}