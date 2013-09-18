package modules.battle.battledefine
{
	/**
	 * 定义不同的排索引 
	 * @author SDD
	 * 
	 */
	public class RowIndexDefine
	{
		public function RowIndexDefine()
		{
		}
		
		public static const normalMode:int = 0;			//正常状态。根据当前row的序列找到列
		public static const firstRow:int = 1;				//第一排
		public static const lastRow:int = 2;				//最后一排
		
	}
}