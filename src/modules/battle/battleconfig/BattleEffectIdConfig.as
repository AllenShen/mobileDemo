package modules.battle.battleconfig
{
	public class BattleEffectIdConfig
	{
		
		public static var infoStore:Object={};
		
		public function BattleEffectIdConfig()
		{
		}
		
		/**
		 * 初始化信息 
		 * @param xmlInfo				xml信息
		 */
		public static function init(xmlInfo:XML):void
		{
			if(xmlInfo == null)
				return;
			
			var singleXml:XML;
			var rootConfig:XMLList = xmlInfo["singleConfig"];
			for(var i:int = 0; i < rootConfig.length();i++)
			{
				singleXml = rootConfig[i] as XML;
				if(singleXml)
				{
					infoStore[singleXml.@effecttype] = singleXml.@resId;
				}
			}
		}
		
		/**
		 * 取得某种效果对应的资源文件
		 * @param effect
		 * @return 
		 */
		public static function getResIdForEffect(effect:int):int
		{
			infoStore[28] = 1472;
			return infoStore[effect];
		}
		
	}
}