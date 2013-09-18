package modules.battle.battledefine
{
	import macro.FormationElementType;

	/**
	 * 对游戏中几种特殊类型进行判断 
	 * @author SDD
	 */
	public class SpecialTroopType
	{
		public function SpecialTroopType()
		{
		}
		
		public static const normalType:int = 0;			//没有限制，普通类型
		public static const NON_MOVE:int = 1;				//不能移动
		public static const NON_MOVE_ATTACK:int = 2;		//不能移动，不能攻击
		public static const NON_MOVE_ATTACKED:int = 3;	//不能移动，不能被攻击
		public static const NON_ATTACK:int = 4;			//不能攻击
		public static const NON_ATTACKED:int = 5;			//不能被攻击
		
		/**
		 *将slot的类型转为特殊类型 
		 * @param slotType
		 * @return 
		 * 
		 */
		public static function turnSlotTypeToSpecialType(slotType:int):int
		{
			var type:int = 0;
			switch(slotType)
			{
				case FormationElementType.ARM:
				case FormationElementType.HERO:
				case FormationElementType.NOTHING:
					type = normalType;
					break;
				case FormationElementType.ARROW_TOWER:				//不能被攻击		 箭塔
					type = NON_MOVE_ATTACKED;
					break;
				case FormationElementType.CITY_WALL:				//不能攻击                    城墙
					type = NON_MOVE_ATTACK;
					break;
			}
			return type;
		}
		
		
	}
}