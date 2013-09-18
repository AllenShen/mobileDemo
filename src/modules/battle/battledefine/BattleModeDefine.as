package modules.battle.battledefine
{
	import modules.battle.managers.BattleManager;

	/**
	 * 战斗模式的定义 
	 * @author SDD
	 */
	public class BattleModeDefine
	{
		public static const PVE_Single:int = 1;		//单个玩家PVE
		public static const PVE_Instance:int = 2;	//单个玩家刷怪点刷怪
		public static const PVP_Single:int = 3;		//玩家1对1 PVP
		public static const PVE_Multi:int = 4;		//玩家组队PVE
		public static const PVP_Multi:int = 5;		//玩家组队PVP
		public static const PVE_Raid:int = 6;		//玩家组队副本
		public static const PVP_OLPK:int = 7;		//离线PK
		public static const PVP_OLCapTure:int = 8;	//抢矿之类的离线战斗
		public static const PVE_XiuLian:int = 10;	//修炼
		public static const PVE_SingleMultipleWaves:int = 11;		//带有多波的普通战斗
		public static const PVE_KuaiSuZhanDou:int = 12;				//快速战斗，任务专用
		public static const PVE_KuaiSuZhanDouMulWaves:int = 13;		//快速战斗，多波，任务专用
		public static const PVE_DANRENFUBEN:int = 14;				//单人副本
		public static const PVE_DANRENFUBENWithLansquenet:int = 15;	//带有雇佣兵的刷副本
		public static const PVE_RAIDWithLansquent:int = 16;			//带有雇佣兵的多人副本
		public static const PVE_TongTianTa:int = 17;				//通天塔，单人 
		
		public function BattleModeDefine()
		{
		}
		
		/**
		 * 是否需要和和服务器通信 
		 * @return 
		 */
		public static function checkNeedServerData():Boolean
		{
			return BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_Raid || 
				BattleManager.instance.battleMode == BattleModeDefine.PVP_Single || 
				BattleManager.instance.battleMode == BattleModeDefine.PVP_Multi;
		}
		
		/**
		 * 需要考虑到波数问题 
		 * @return 
		 */
		public static function checkNeedConsiderWave():Boolean
		{
			return BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_XiuLian || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_SingleMultipleWaves ||
				BattleManager.instance.battleMode == BattleModeDefine.PVE_KuaiSuZhanDouMulWaves || 
				isGeneralRaid || 
				BattleModeDefine.isDarenFuBen();
		}
		
		/**
		 * 是否为离线pve 
		 * @return 
		 */
		public static function isOfflinePvE():Boolean
		{
			var retValue:Boolean = false;
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance || BattleManager.instance.battleMode == BattleModeDefine.PVE_Single
			 || BattleManager.instance.battleMode == BattleModeDefine.PVE_XiuLian || BattleManager.instance.battleMode == BattleModeDefine.PVE_SingleMultipleWaves
			|| BattleManager.instance.battleMode == BattleModeDefine.PVE_KuaiSuZhanDou)
				retValue = true;
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_KuaiSuZhanDouMulWaves)
			{
				retValue = true;
			}
			return retValue;
		}
		
		public static function showFailWarning():Boolean
		{
			var retValue:Boolean = false;
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Single || BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi ||
				BattleManager.instance.battleMode == BattleModeDefine.PVE_SingleMultipleWaves || BattleModeDefine.isDarenFuBen())
				retValue = true;
			return retValue;
		}
		
		/**
		 * 是否为离线pvp 
		 * @return 
		 */
		public static function isOfflinePVP():Boolean
		{
			var retValue:Boolean = false;
			if(BattleManager.instance.battleMode == BattleModeDefine.PVP_OLPK || BattleManager.instance.battleMode == BattleModeDefine.PVP_OLCapTure)
				retValue = true;
			return retValue;
		}
		
		/**
		 * 当前是在进行pve 
		 * @return 
		 */
		public static function isGeneralPVE():Boolean
		{
			var retValue:Boolean = false;
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance || BattleManager.instance.battleMode == BattleModeDefine.PVE_Single ||
				BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi || isGeneralRaid ||
				BattleManager.instance.battleMode == BattleModeDefine.PVE_XiuLian || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_SingleMultipleWaves || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_KuaiSuZhanDouMulWaves || 
				BattleModeDefine.isDarenFuBen())
				retValue = true;
			return retValue;
		}
		
		/**
		 * 是否为存在奥义的pve战斗
		 * @return 
		 */
		public static function isPvEWithAoYi():Boolean
		{
			var retValue:Boolean = false;
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance || BattleManager.instance.battleMode == BattleModeDefine.PVE_Single ||
				BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi || isGeneralRaid || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_SingleMultipleWaves || BattleManager.instance.battleMode == BattleModeDefine.PVE_KuaiSuZhanDou || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_KuaiSuZhanDouMulWaves ||
				BattleManager.instance.battleMode == BattleModeDefine.PVE_XiuLian ||
				BattleModeDefine.isDarenFuBen())
				retValue = true;
			return retValue;
		}
		
		public static function isDarenFuBen():Boolean
		{
			return BattleManager.instance.battleMode == BattleModeDefine.PVE_DANRENFUBEN || BattleManager.instance.battleMode == BattleModeDefine.PVE_DANRENFUBENWithLansquenet;
		}
		
		public static function checkIsDarenFuben(type:int):Boolean
		{
			return type == BattleModeDefine.PVE_DANRENFUBEN || type == BattleModeDefine.PVE_DANRENFUBENWithLansquenet;
		}
		
		public static function get isGeneralRaid():Boolean
		{
			return BattleManager.instance.battleMode == BattleModeDefine.PVE_TongTianTa || BattleManager.instance.battleMode == BattleModeDefine.PVE_Raid;
		}
		
	}
}