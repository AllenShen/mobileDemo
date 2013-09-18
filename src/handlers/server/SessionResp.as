package handlers.server
{
	import tools.textengine.TextEngine;

	/**
	 */ 
	public class SessionResp extends BaseRespHandler
	{
		public static const MOD:String = "SS";
		/** Response **/
		public static const LOGIN_RESULT:String = "SS.LOG_R";
		public static const LOGOUT_RESULT:String = "SS.EXIT_R";
		public static const PREVENT_WALLOW_NOTIME:String = "SS.PREVENTWALLOW_NT";
		public static const PREVENT_WALLOW_DURTION:String = "SS.PREVENTWALLOW_DURA";
		public static const KEEP_ALIVE_RESULT:String = "SS.KEEP_ALIVE_R";
		
		protected override function initActionHandlers():void
		{
			this.funs.put(LOGIN_RESULT, this.loginResult);
			this.funs.put(LOGOUT_RESULT, this.logoutResult);
			this.funs.put(PREVENT_WALLOW_DURTION, this.preventWallowDurtion);
			this.funs.put(KEEP_ALIVE_RESULT, this.keepAliveResult);
		}
	
		/***************** ******** ****************/
		/***************** Handlers ****************/
		/***************** ******** ****************/
		protected function loginResult(params:Array):void
		{
			var ret:String = params.shift();
			if(ret == "DL"){
				ViewManager.ShowWarning(TextEngine.getTextById(842), 0, onWarningRst);
				return;
			}else if(ret == "GMK"){
				ViewManager.ShowWarning(TextEngine.getTextById(868), 0, onWarningRst);
				return;
			}else if(ret == "UB"){
				ViewManager.ShowWarning(TextEngine.getTextById(966), 0, onWarningRst);
				return;
			}
		}
		
		private function onWarningRst(result:Boolean, param:Object=null):void
		{
			GlobalData.g_app.refreshBrowser();
		}
		
		protected function logoutResult(params:Array):void
		{
		}
		
		private function preventWallowDurtion(params:Array):void
		{
			if(params)
			{
				GlobalData.owner.wallowstate = int(params[0]);
				GlobalData.owner.incomeradix = WallowDefine.sectionInfos[GlobalData.owner.wallowstate][1];
				var nextnoticetime:int = int(params[1]);
				GlobalData.owner.onlinetime = int(params[2]);
				if(nextnoticetime > GlobalData.owner.nextnoticetime)
				{
					GlobalData.g_globalTimer.showWallowNotice();
				}
				GlobalData.owner.nextnoticetime = nextnoticetime;
				GlobalData.g_globalTimer.nextwallownoticetime = GlobalData.owner.nextnoticetime;
				GlobalData.g_globalTimer.wallownoticeshowed = false;
			}
		}
		
		private function keepAliveResult(params:Array):void
		{
			//donothing
		}
	}
}