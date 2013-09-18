package interfaces
{
	import modules.battle.battledata.BattleData;

	public interface IOnlineBattleManager
	{
		
		function handleServerAskAskFormation(param:Array):void;
		
		function acceptOtherPlayerFormation(params:Array):void;
		
		function battleStartHandler(params:Array):void;
		
		function battleSingleWaveStartHnalder(params:Array):void;
		
		function startNewRoundHandler(params:Array):void;
		
		function pveFormationErrorHandler(params:Array):void;
		
		function handlerPlayerBeSetOffline(params:Array):void;
		
		function battleResLoadDone():void;
		
		function notifyBattleCardUsed():void;
		
		function get curbattledata():BattleData;
		
		function get roomid():int;
		
		function get roomtypeid():int;
	}
}