package handlers.server
{
	import flash.events.Event;
	
	import animator.animatorengine.AnimatorEngine;
	
	import defines.ErrorCode;
	
	import eventengine.GameEventHandler;
	
	import interfaces.IOnlineBattleManager;
	
	import macro.EventMacro;
	
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battlelogic.SingleRound;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	
	import synchronousLoader.GameResourceManager;
	
	public class BattleHandler extends BaseRespHandler
	{
		public static const MOD:String = "BAT";
		
		//兵力补充系列
		public static const ARMSUPPLY_CHECKTIMELEFT:String = MOD + ".PlayerGetArmSupplyTimeLeft";
		public static const ARMSUPPLY_CHECKTIMELEFT_R:String = MOD + ".PlayerGetArmSupplyTimeLeft_R";
		public static const ARMSUPPLY_BUYSUPPORT:String = MOD + ".buyArmSupplyInfo";
		public static const ARMSUPPLY_BUYSUPPORT_R:String = MOD + ".buyArmSupplyInfo_R";
		
		/**服务器要求取阵型信息 from server **/
		public static const ASK_FOR_FORMATION:String = MOD + ".AskForFormationData";
		/**上传自己的阵型   to server **/
		public static const SUBMIT_SELF_FORMATION:String = MOD + ".SubmitSelfFormation";
		/**通知其他玩家的信息   from server **/
		public static const NOTIFY_FORMATIONDATA:String = MOD + ".AcceptOtherFormation"; 
		/**资源加载完成  to server **/
		public static const PLAYER_BATTLE_READY:String = MOD+".PlayerBattleReady";
		/** 战斗开始 fromserver **/
		public static const BATTLE_START:String = MOD + ".BATTLESTART";
		/** 玩家被设置为不在线 */
		public static const BATTLE_BE_SET_OFFLINE_HANDLE:String = MOD + ".playerBeSetOfflineOnBattle";
		
		//单个回合开始系列
		public static const PLAYER_BATTLE_ROUNDEND:String = MOD+".PlayerSingleRoundEnd";	
		public static const PLAYER_BATTLE_STARTROUND:String = MOD+".PlayerSingleRoundEnd_R";
		
		//重回服务端
		public static const URGE_PLAYER_RECONNECT:String = MOD + ".UrgePlayerToConnect";
		public static const PLAYER_RECONNECTTOCONTROLLER:String = MOD + ".ReconnecToController";
		
		//下一波开始
		public static const SINGLE_WAVE_START:String = MOD + ".WAVESTART";
		public static const INITFORMATIONERROR:String = MOD + ".initialFormationError";
		
		//卡片系列
		public static const BATTLECARD_USED:String = MOD + ".BattleCardUsed";
		public static const BATTLECARD_USENOTIFY:String = MOD + ".PowersideCardUseNotify";
		public static const BATTLECARD_USENOTIFY_R:String = MOD + ".PowersideCardUseNotify_Reply";
		public static const BATTLECARD_QUANTIZENGYUAN:String = MOD + ".QuantiZengYuanKouBing";
		
		public static const PLAYER_SINGLEWAVE_RESLOADED:String = MOD + ".PveMSingleWaveLoaded";
		public static const PLAYER_PVE_OPENCOLLECTIONREWARD:String = MOD+".OpenCollectionReward";
		
		//错误异常系列
		public static const PLAYER_FORMATIONERROR:String = MOD + ".PlayerFormationIllegal";	
		public static const PLAYER_BESETOFFLINE:String = MOD + ".playerBeSetOffline";
		public static const BATTLE_ERROROCCURED:String = MOD + ".battleErrorEccoured";
		public static const BATTLE_OTHERFORMATIONSUBMITFAILED:String = MOD + ".otherFormationSubmitFail";
		public static const BATTLE_JIASUQIUSED:String = MOD + ".BattleJiaSuQiUsed";
		
		public static const PLAYER_EXITRAIDBATTLE:String = MOD + ".PlayerExitRaidBattle";		
		
		public static const GUILD_GETBUFF:String = MOD + ".PlayerGetGuildCoinBUff";
		public static const GUILD_GETBUFF_R:String = MOD + ".PlayerGetGuildCoinBUff_R";
		
		private var _onlineManager:IOnlineBattleManager = null;
		
		private static var _instance:BattleHandler;
		
		public function BattleHandler()
		{
			super();
		}
		
		public static function get instance():BattleHandler
		{
			if(_instance == null)
			{
				_instance = new BattleHandler();
			}
			return _instance;
		}
		
		protected override function initActionHandlers():void
		{
			this.funs.put(ASK_FOR_FORMATION,handleServerFormationAsk);
			this.funs.put(NOTIFY_FORMATIONDATA, acceptFormationData);//获得对方阵型数据
			
			this.funs.put(BATTLE_START, battleStartHandler);				//战斗开始
			this.funs.put(PLAYER_BATTLE_STARTROUND, roundEndRespondHandler);//回合结束服务端返回值
			
			this.funs.put(BATTLECARD_USENOTIFY_R,opponentUsedBattleCard);
			
			this.funs.put(SINGLE_WAVE_START,onNotifySingleWaveLoaded);
			this.funs.put(PLAYER_FORMATIONERROR,onFormationError);
			this.funs.put(PLAYER_BESETOFFLINE,onPlayerBeSetOffline);
			this.funs.put(BATTLE_ERROROCCURED,onBattleErrorOccured);
			
			this.funs.put(BATTLE_BE_SET_OFFLINE_HANDLE,onPlayerBeSetOfflineOnBattle);
			this.funs.put(BATTLE_OTHERFORMATIONSUBMITFAILED,onOtherFormationSubmitFailed);
			
			this.funs.put(BATTLE_JIASUQIUSED,onJiasuUseHandler);
			this.funs.put(URGE_PLAYER_RECONNECT,urgePlayerReconnect);
		}
		
		private function handleServerFormationAsk(params:Array):void
		{
			if(_onlineManager)
			{
				BattleFunc.showOnlineBattleWaitMask(true);
				if(GameResourceManager.isLoading)
				{
					GameResourceManager.cancelLoad();
				}
				_onlineManager.handleServerAskAskFormation(params);
			}
		}
		
		/**
		 * 获得对手的阵型数据 
		 * @param params
		 */
		private function acceptFormationData(params:Array):void
		{
			if(_onlineManager)
			{
				_onlineManager.acceptOtherPlayerFormation(params);
				BattleFunc.showOnlineBattleWaitMask(false);
			}
		}
		
		/**
		 *  战斗开始
		 */
		private function battleStartHandler(params:Array):void
		{
			if(_onlineManager)
			{
				_onlineManager.battleStartHandler(params);
			}
			GameEventHandler.dispatchGameEvent(EventMacro.CommonEventHandler,new Event(BattleConstString.hideWaitForOther));
		}
		
		/**
		 * 单波的数据加载完成 
		 * @param params
		 */
		private function onNotifySingleWaveLoaded(params:Array):void
		{
			_onlineManager && _onlineManager.battleSingleWaveStartHnalder(params);
		}
		
		/**
		 * 回合结束服务器返回后的处理 
		 * @param params
		 */
		public function roundEndRespondHandler(params:Array):void
		{
			_onlineManager && _onlineManager.startNewRoundHandler(params);
		}
		
		/**
		 * 处理对方使用卡片的通知
		 * @param params
		 */
		private function opponentUsedBattleCard(params:Array):void
		{
			if(params == null)
				return;
		}
		
		protected function onFormationError(params:Array):void
		{
			_onlineManager && _onlineManager.pveFormationErrorHandler(params);
		}
		
		private function onPlayerBeSetOfflineOnBattle(params:Array):void
		{
			if(_onlineManager)
			{
				_onlineManager.handlerPlayerBeSetOffline(params);
			}
			BattleInfoSnap.curOnLineManager = null;
		}
		
		//设置playeroffline
		protected function onPlayerBeSetOffline(params:Array):void
		{
			
			//此阶段可能在加载，放弃加载
			if(GameResourceManager.isLoading)
			{
				GameResourceManager.cancelLoad();
			}
			
			BattleManager.instance.exitBattle(ErrorCode.suc);
			BattleFunc.showOnlineBattleWaitMask(false);
		}
		
		private function onOtherFormationSubmitFailed(params:Array):void
		{
			GameResourceManager.cancelLoad();
			BattleManager.instance.exitBattle(ErrorCode.suc);
			BattleFunc.showOnlineBattleWaitMask(false);
		}
		
		//处理加速器使用处理
		private function onJiasuUseHandler(params:Array):void
		{
			if(BattleManager.instance.battleMode != BattleModeDefine.PVE_Instance)
				return;
			if(!BattleInfoSnap.isOnBattle)
				return;
			BattleManager.instance.exitBattle();
			AnimatorEngine.stopEngine();
		}
		
		private function urgePlayerReconnect(param:Array):void
		{
			if(param != null && param.length > 0)
			{
				BattleInfoSnap.curServerCommuIndex = param[0];
			}
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_Raid||
				BattleManager.instance.battleMode == BattleModeDefine.PVP_Single)
			{
				//真正在线的战斗，重新连接
				
				if(onLineManager == null)
					return;
				
				var paramsBack:Array = [];
				paramsBack.push(BattleHandler.instance.onLineManager.curbattledata.battleid);
				paramsBack.push(GlobalData.owner.uid);
				paramsBack.push(onLineManager.roomid);
				
				var usedRandomTagArr:Array=[];
				for(var singleUsedTag:String in BattleInfoSnap.usedRandomTagInRound)
				{
					usedRandomTagArr.push(singleUsedTag);
				}
				
				var commonData:Array = [
					BattleInfoSnap.deadTroopsOnOneRound,
					usedRandomTagArr,
					null,
					BattleInfoSnap.getArmChangeInfo(),
					BattleInfoSnap.armySupplyInfo[GlobalData.owner.uid],
					SingleRound.roungIndex,
					BattleInfoSnap.curRebornTroops,BattleInfoSnap.curServerCommuIndex];
				
				paramsBack.push(commonData);
				
				//重新发送本回合数据
			}
		}
		
		private function callBackFunc(result:Boolean, param:Object=null):void
		{
		}
		
		/**
		 * 战斗出错
		 * @param params
		 */
		protected function onBattleErrorOccured(params:Array):void
		{
			BattleManager.instance.exitBattle(ErrorCode.suc);
		}
		
		public function set onLineManager(value:IOnlineBattleManager):void
		{
			_onlineManager = value;
		}
		
		public function get onLineManager():IOnlineBattleManager
		{
			return _onlineManager;
		}
		
	}
}


