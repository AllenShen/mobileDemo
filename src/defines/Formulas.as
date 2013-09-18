package defines
{
	import macro.EquipmentType;
	import macro.WuXingType;

	/**
	 * 一些计算公式
	 * 
	 * @author fangc
	 */
	public class Formulas
	{
		public function Formulas()
		{
		}
		
		/**
		 * 根据英雄天性点计算加成后的五行属性
		 * 
		 * @param tianxing 天性点
		 * @param wuxingdian 五行值
		 * 
		 * @return 加成后的五行值
		 */
		public static function countHeroWuXing(tianxing:int, wuxingdian:Number):int
		{
			var radix:Number = 1;
			switch(tianxing){
				case 3:
					radix = 2.5;
					break;
				case 2:
					radix = 2;
					break;
				case 1:
					radix = 1.5;
					break;
				case 0:
				default:
					radix = 1;
					break;
			}
			var ret:int = Math.floor(radix*wuxingdian);
			return ret;
		}
		
		/**
		 * 根据五行属性计算英雄的武智霸
		 * 
		 * @param wuxingType 五行属性
		 * @param wuxingdian 该属性的五行值
		 * 
		 * @return 计算后的武智霸的数组
		 */
		public static function countHeroWuZhiBa(wuxingType:int, wuxingdian:int):Array
		{
			var wuli:int = 0;
			var zhili:int = 0;
			var baqi:int = 0;
			
			switch(wuxingType){
				case WuXingType.jin:
					wuli = wuxingdian*2;
					break;
				case WuXingType.mu:
					wuli = wuxingdian;
					baqi = wuxingdian;
					break;
				case WuXingType.shui:
					zhili = wuxingdian*2;
					break;
				case WuXingType.huo:
					zhili = wuxingdian;
					baqi = wuxingdian;
					break;
				case WuXingType.tu:
					baqi = wuxingdian*2;
					break;
			}
			
			return [wuli, zhili, baqi];
		}
		
	}
}
