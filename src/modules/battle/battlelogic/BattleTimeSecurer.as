package modules.battle.battlelogic
{
	import eventengine.GameEventHandler;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import macro.CommonEventTypeDefine;
	import macro.EventMacro;
	
	import modules.battle.managers.BattleInfoSnap;

	public class BattleTimeSecurer
	{
		private static var timerInfo:Timer
		
		/**
		 * 初始化记录两拨怪之间的时间
		 */
		public static function initSecureInfo():void
		{
			BattleInfoSnap.wavegapTimeCount =  0;
			GameEventHandler.addListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_globalTimerMoveForward,onTimerSteped);
		}
		
		private static function onTimerSteped(event:Event):void
		{
			BattleInfoSnap.wavegapTimeCount++;
		}
		
		public static function clearSecureTime():void
		{
			GameEventHandler.removeListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_globalTimerMoveForward,onTimerSteped);
		}
		
		public function BattleTimeSecurer()
		{
		}
	}
}