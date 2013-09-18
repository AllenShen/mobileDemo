package modules.battle.utils
{
	import flash.utils.ByteArray;
	
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battlelogic.CellTroopInfo;

	/**
	 * 一些util方法 
	 * @author Administrator
	 * 
	 */
	public class BattleUtils
	{
		public function BattleUtils()
		{
		}
		
		/**
		 * 取得区间之内的一个随机数 
		 * @param start     起始阶段
		 * @param end       结束区间
		 * @return 
		 * 
		 */
		public static function getRandomValueFromRegion(start:Number,end:Number,randomValue:Number):Number
		{
			var realStart:Number = Math.min(start,end);
			var realEnd:Number = Math.max(start,end);
			
			return realStart + randomValue*(realEnd - realStart);
		}
		
		/**
		 * 获得object对象的长度 
		 * @param obj
		 * @return 
		 * 
		 */
		public static function getObjectLength(obj:Object):int
		{
			var length:int = 0;
			if(obj == null)
				return length;
			for(var key:* in obj)
			{
				length++;
			}
			return length;
		}
		
	}
}