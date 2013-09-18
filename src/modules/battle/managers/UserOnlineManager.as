package modules.battle.managers
{
	

	/**
	 * 管理当前战斗管理器 
	 * @author SDD
	 */
	public class UserOnlineManager
	{
		
		public static const Online_SingleInstance:String = "singleInstance";
		public static const Online_MultipleInstanceCreate:String = "multipleInstanceCreate";
		public static const Online_MultipleInstanceMember:String = "multipleInstanceMember";
		public static const Online_InstancePvP:String = "instancePvP";
		
		public static const Online_ZhengBaPvP:String = "zhengbaPvP";
		
		public static const Online_RaidTeam:String = "raidManagerTeam";
		
		public static const Online_DuoqiPvP:String = "duoqiPvp";
		
		public static const Online_Nothing:String = "nothingOnLine";
		
		public static const Online_Clear:String = "clear";
		
		public static var curOnlineManager:String = "";
		private static var exitHandler:Function;
		
		private static var curTeam:String;
		
		public function UserOnlineManager()
		{
		}
		
		public static function clearManagerInfo():void
		{
			curOnlineManager = Online_Nothing;
			exitHandler = null;
		}
		
		public static function setCurManagerInfo(targetScene:String,handlerFunc:Function):void
		{
			updateCurManagerInfo(targetScene);
			exitHandler = handlerFunc;
		}
		
		private static function updateCurManagerInfo(targetScene:String):void
		{
			if(targetScene == Online_Clear)
			{
				curOnlineManager = null;
				exitHandler = null;
			}
			else
			{
				var oldManager:String = curOnlineManager;
				curOnlineManager = targetScene;
				if(curOnlineManager != oldManager)				//如果场景发生变化需要执行上一个场景的队伍移除队伍
				{
					if(exitHandler != null)
					{
						exitHandler();
					}
				}
			}
		}
	}
}