package modules.battle.battlelogic
{
	/**
	 * 战斗时候的关系类型以及具体数据 
	 * @author SDD
	 */
	public class RelationDes
	{
		/**
		 * 关系id 
		 */
		public var relationId:int = 0;
		/**
		 * 关系影响进攻方的值
		 */
		public var relationValue:Number = 0;
		
		public function RelationDes()
		{
			this.relationId = 0;
			this.relationValue = 0;
		}
	}
}