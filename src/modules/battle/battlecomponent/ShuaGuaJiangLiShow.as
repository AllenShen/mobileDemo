package modules.battle.battlecomponent
{
	import flash.display.Sprite;
	
	/**
	 * 显示 刷怪点奖励
	 * @author SDD
	 */
	public class ShuaGuaJiangLiShow extends Sprite
	{
		private var _curCount:int;
		
		public function ShuaGuaJiangLiShow()
		{
			super();
		}

		public function get curCount():int
		{
			return _curCount;
		}

		public function setCurCount(value:int,bLink:Boolean = true):void
		{
			_curCount = value;
		}
	}
}