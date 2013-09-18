package modules.battle.showdatastructure
{
	/**
	 * 单次伤害显示信息 
	 * @author SDD
	 */
	public class SingleDamageDisplayInfo
	{
		
		/**
		 * 最终的伤害值 
		 */
		public var finalDamageValue:int;
		/**
		 * 此次攻击中各种百分比的加成
		 */
		public var percentBonus:Array=[];
		
		public var bonusRatio:Number = 0;
		
		public function SingleDamageDisplayInfo()
		{
		}
	}
}