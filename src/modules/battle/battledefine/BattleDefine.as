
package modules.battle.battledefine
{
	import macro.BattleDisplayDefine;
	import macro.GameSizeDefine;

	/**
	 * 战斗部分的宏定义 
	 * @author Administrator
	 * 
	 */
	public class BattleDefine
	{
		public function BattleDefine()
		{
		}
		
		//以下是攻击先后手的定义
		public static const firstAtk:int = 0;					//先手攻击
		public static const secondAtk:int = 1;				//后手攻击
		
		//攻击次数的定义
		public static const defaultAttackCount:int = 1;
		
		//最大的row数量
		public static var maxFormationYValue:int = 6;
		//最大的column数量
		public static var maxFormationXValue:int = 30;
		//单个回合保证运行完成的保证时间20秒
		public static const singleRoundSecureTime:int = 10;
		
		//是否可见
		public static const hidden:int = 0;
		public static const normalShow:int = 1;
		
		//刷怪战中troop的列数
		public static const shuaGuaiTroopLength:int = 3;
		
		//最小攻击范围
		public static const minAttackDis:int = 0;
		
		public static const battleNotEnd:int = 0;
		public static const battleSingleWaveEnd:int = 1;
		public static const battleEnd:int = 2;
		public static const formationError:int = 3;
		public static const playerTeamDead:int = 4;					//玩家一对死亡
		public static const singleLoopEnd:int = 5;					//一边循环结束
		
		/**
		 * 多人pve时进行经验系数 
		 */
		public static const PveMultipleExpRatio:Number = 1;
		
		public static const PVE_RaidRecoveryTime:int = 100;
		
		public static const nomalRound:int = 1;
		public static const heroRound:int = 2;
		public static const aoyiRound:int = 3;
		
		public static const FTip_bianqiang:int = 1;			//升级装备
		public static const FTip_tishi:int = 2;				//换装备
		
		public static const fanjiChain_suc:int = 0;
		public static const fanjiChain_fail:int = 1;
		public static const fanjiChain_noNeed:int = 2;
		
		public static const onlineBattle_PVP:int = 0;			//pvp
		public static const onlineBattle_FuBen:int = 1;			//fuben
		public static const onlineBattle_ZhengBa:int = 2;		//争霸
		public static const onlineBattle_Raid:int = 3;			//raid
		public static const onlineBattle_DarenFuben:int = 4;	//单人副本
		public static const onlineBattle_DarenFubenWithLansquenet:int = 5;
		public static const onlineBattle_TongTianTa:int = 6;
		
		public static const dajinArmSupplyPrice:int = 10;
		
		public static const RaidTeamFail_NoTeamInfo:int = 1;
		public static const RaidTeamFail_Timeount:int = 2;		//队伍超时
		public static const RaidTeamFail_TeamOffline:int = 3;
		public static const RaidTeamFail_TeamFormationOut:int = 4;
		
		public static const FailTipShowLevelMinGap:int = 13;
		public static const FailTipShowLevelMaxGap:int = 35;
		
		public static const BattleEndTipShowLevelMinGap:int=15;
		public static const BattleEndTipShowLevelMaxGap:int=35;
		
		public static const FailTipXiangqianTuoShow:int = 40;
		

		//玩家选择的目标范围定义
		public static const Range_Clear:int = 0;
		public static const Range_SingleHero:int = 1;					//单个英雄
		public static const Range_singleArm:int = 2;
		public static const Range_columnArm1:int = 3;
		public static const Range_columnArm2:int = 4;
		public static const Range_columnArm3:int = 5;

		//被选中格子的各种状态显示
		public static const Status_NoShow:int = 1;
		public static const Status_Default:int = 2;
		public static const Status_Selected:int = 3;
		
		public static const guanghuangDuration:int = 10000000;
		public static const guanghuangDurationOnCheck:int = 8000000;
		
		public static var autoStarIncreaseRoundGap:int = 8;
		
		public static var autoEnemySupplyRoungGap:int = 2;
		public static var autoEnemySupplyRoundGapFast:int = 1;
		
		public static var fakeRoundsAtBeginning:int = 5;
		
		public static var  callHeroPossibility:Number = 0.18;
		public static var callCardPossibility:Number = 0.15;
		
		public static var geneCardPossibility:Number = 0;
		
		public static var ranBattleCardGiveCount:int = 0;
		
		public static var needShowHpBar:Boolean = true;
		
		public static var initialEnterArmStar:int = 1;
		
		public static function get legalBattleWidth():int
		{
//			return Math.max(GameSizeDefine.viewwidth,BattleDisplayDefine.battleMinWidth);
			return BattleDisplayDefine.screenWidth;
		}
		
		public static function get legalBattleHeight():int
		{
//			return Math.max(GameSizeDefine.viewheight,BattleDisplayDefine.battleMinHeight);
			return BattleDisplayDefine.screenHeight;
		}
		
	}
}