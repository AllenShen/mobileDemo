package modules.battle.stage
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import eventengine.GameEventHandler;
	
	import macro.CommonEventTypeDefine;
	import macro.EventMacro;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.managers.BattleInfoSnap;
	
	import uipacket.previews.PreviewImage;
	import uipacket.previews.PreviewLabel;

	public class WaitUserShowOfRaid extends Sprite
	{
		
		public static var Event_ShowWaitUsers:String = "ShowWaitUsers";
		public static var Event_ClearShow:String = "clearWaitUsersShow";
		
		private var _curRecoveryCount:int = 0;
		
		private var _raidShowInfo:RaidNextTeamStatusShow = new RaidNextTeamStatusShow();
		
		private var countDownBackImage:PreviewImage = new PreviewImage();
		private var countDownNum:PreviewLabel = new PreviewLabel();
		
		public function WaitUserShowOfRaid()
		{
			GameEventHandler.addListener(EventMacro.CommonEventHandler,Event_ShowWaitUsers,handleUserShow);
			GameEventHandler.addListener(EventMacro.CommonEventHandler,Event_ClearShow,clearInfo);
			
			this.addChild(_raidShowInfo);
			_raidShowInfo.x = 0;
			_raidShowInfo.visible = true;
			
			addChild(countDownBackImage);
			countDownBackImage.x = 12;
			countDownBackImage.y = 82;
			countDownBackImage.setResid(2357);
			countDownBackImage.visible = false;
			
//			this.addChild(statusShow);
//			statusShow.SetFont(7);
//			statusShow.x = 210;
//			statusShow.y = 38;
//			statusShow.SetTextID(864);
//			statusShow.height = 40;
//			statusShow.width = 100;
//			statusShow.visible = false;
			
			this.addChild(countDownNum);
			countDownNum.SetFont(21);
			countDownNum.x = 90;
			countDownNum.y = 82;
			countDownNum.SetText("0");
			countDownNum.height = 40;
			countDownNum.width = 100;
			countDownNum.visible = false;
		}
		
		//timer时间增加
		private function timerStepHandler(event:Event):void
		{
			curRecoveryCount--;
//			if(curRecoveryCount <= 0)
//			{
//				statusShow.SetTextID(865);
//			}
		}
		
		public function handleUserShow(event:Event):void
		{
			
			GameEventHandler.addListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_globalTimerMoveForward,timerStepHandler);
			
			if(BattleInfoSnap.isRecovering)
			{
				showMask(true);
//				statusShow.SetTextID(864);
				curRecoveryCount = BattleDefine.PVE_RaidRecoveryTime;
			}
			else
			{
				showMask(false);
//				statusShow.SetTextID(865);
			}
		}
		
		public function showMask(bShow:Boolean):void
		{
			countDownNum.visible = bShow;
			countDownNum.SetText("100");
			countDownBackImage.visible = bShow;
			_raidShowInfo.showMask(bShow);
		}
		
		public function clearInfo(event:Event):void
		{
//			statusShow.visible = false;
			GameEventHandler.removeListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_globalTimerMoveForward,timerStepHandler);
			_raidShowInfo.clearInfo();
			countDownNum.SetText("");
//			statusShow.SetTextID(864);
			showMask(false);
		}

		public function get curRecoveryCount():int
		{
			return _curRecoveryCount;
		}

		public function set curRecoveryCount(value:int):void
		{
			_curRecoveryCount = value;
			countDownNum.SetText(curRecoveryCount.toString());
			if(_curRecoveryCount <= 0)
			{
				showMask(false);
			}
		}

	}
}