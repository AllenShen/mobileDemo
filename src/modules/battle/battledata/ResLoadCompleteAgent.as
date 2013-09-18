package modules.battle.battledata
{
	import eventengine.GameEventHandler;
	
	import macro.EventMacro;
	
	import synchronousLoader.BattleResourceCopy;
	import synchronousLoader.LoadManEvent;
	
	import tools.textengine.TextEngine;

	public class ResLoadCompleteAgent
	{
		
		public static var curCallBack:Function;
		public static var curCallBackParam:Array;
		
		public function ResLoadCompleteAgent()
		{
		}
		
		public static function setCurFuncInfo(funcInfo:Function,funcParam:Array):void
		{
			curCallBack = funcInfo;
			curCallBackParam = funcParam;
		}
		
		public static function onResLoadCompleteCall(param:Array = null):void
		{
			trace("加载战斗资源完成");
			
			GameEventHandler.dispatchGameEvent(EventMacro.LOAD_EVENT,new LoadManEvent(LoadManEvent.LOAD_START,""));		//显示加载条
			GameEventHandler.dispatchGameEvent(EventMacro.LOAD_EVENT,new LoadManEvent(LoadManEvent.LOAD_SETINITSTATUS,"",0,0,0,0,TextEngine.getTextById(940)));		//显示加载条
			BattleResourceCopy.makeAnimatorFrameComplete();
		}
		
		public static function executeFunc():void
		{
			if(curCallBack != null)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.LOAD_EVENT,new LoadManEvent(LoadManEvent.LOAD_COMPLETE,""));		//显示加载条
				if(curCallBackParam != null)
				{
					curCallBack(curCallBackParam);
				}
				else
				{
					curCallBack();
				}
			}
//			if(BattleInfoSnap.isOnBattle && BattleManager.instance.battleMode == BattleModeDefine.PVE_Single || BattleManager.instance.battleMode == BattleModeDefine.PVE_SingleMultipleWaves)
//			{
//				var bgScen:BattlegroundScene = ViewManager.getBattlegroundScene();
//				if(bgScen)
//				{
//					bgScen.setVisible(false);
//				}
//			}
		}
		
	}
}