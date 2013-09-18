package modules.battle.utils
{
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battlelogic.CellTroopInfo;

	/**
	 * 生成战斗时候的各种事件的type 
	 * @author SDD
	 */
	public class BattleEventTagFactory
	{
		public function BattleEventTagFactory()
		{
		}
		
		/**
		 * 获得Troop在新回合攻击时候产生的eventName 
		 * @param troopIndex
		 * @return 
		 * 
		 */
		public static function geneNewTroopRoundTag(troopIndex:int):String
		{
			return BattleConstString.troopNewRoundTag + troopIndex.toString();
		}
		
		/**
		 * 获得troop死亡的情形 
		 * @param troopIndex
		 * @return 
		 * 
		 */
		public static function geneTroopDeadTag(troopIndex:int):String
		{
			return BattleConstString.troopDeadTag + troopIndex.toString();
		}
		
		/**
		 * 获得到达事件的TAG 
		 * @param troopIndex
		 * @return 
		 * 
		 */
		public static function geneDamageArrivedTag(troopIndex:int,defTroopIndex:int):String
		{
			return BattleConstString.damageArrived + troopIndex.toString() + "_" + defTroopIndex;
		}
		
		/**
		 * 获得chain检查时间的tag 
		 * @param chainIndex
		 * @return 
		 */
		public static function geneChainCheckEvent(chainIndex:int):String
		{
			return BattleConstString.chainWorkTag + chainIndex.toString();
		}
		
		/**
		 * 获得某个troop需要的logicstatus 
		 * @param troop							troop
		 * @param targetStatus					status
		 * @param targetAction					挂起的动作类型 
		 * @return 
		 */
		public static function getNeedTroopStatus(troop:CellTroopInfo,targetStatus:int):String
		{
			return BattleConstString.troopStatusNeedTag + troop.troopIndex.toString() + "_" + targetStatus.toString();
		}
		
		/**
		 * 生成某个troop中hp显示隐藏的信息 
		 * @param troop
		 * @return 
		 * 
		 */
		public static function getHpShowEventTag(troop:CellTroopInfo):String
		{
			return BattleConstString.troopHpShow + troop.troopIndex.toString();
		}
		
		/**
		 * 获得等待troop变成空闲的状态的tag 
		 * @param troop			troop信息
		 * @return 
		 */
		public static function getWaitForTroopBeIdleTag(troop:CellTroopInfo):String
		{
			return BattleConstString.troopWaitIdle + troop.troopIndex.toString();
		}
		
		/**
		 * 获得hero要返回等待的事件tag
		 * @param troop
		 * @return 
		 */
		public static function getHeroWaitGetBackTag(troop:CellTroopInfo):String
		{
			return BattleConstString.heroBackWaitTag + troop.troopIndex.toString();
		}
		
		/**
		 * 获得等待某个y值变成空闲的tag
		 * @param yValue
		 * @return 
		 */
		public static function getWaitForSomeYPath(yValue:int):String
		{
			return BattleConstString.getYFreeTag + yValue.toString();
		}

		/**
		 * hero单位等待时间差的tag 
		 * @param troopIndex
		 * @return 
		 */
		public static function heroWaitForTimeGap(troopIndex:int):String
		{
			return BattleConstString.heroTroopWait + troopIndex.toString();
		}
		
		/**
		 * 等待发出的攻击是否击中目标
		 * @param sourceTroopIndex
		 * @return 
		 */
		public static function waitAttackGotHit(sourceTroopIndex:int):String
		{
			return BattleConstString.waitHitCheckTag + sourceTroopIndex.toString();
		}
		
		/**
		 * 是否暴击
		 * @param sourceTroopIndex
		 * @return 
		 */
		public static function waitAttackCritical(sourceTroopIndex:int):String
		{
			return BattleConstString.waitCheckCritcal + sourceTroopIndex.toString();
		}
		
		/**
		 * 等待反击的发动 
		 * @param sourceTroopIndex					攻击方
		 * @param targetIndex						目标方	
		 * @return 	
		 */
		public static function waitForFanJi(sourceTroopIndex:int):String
		{
			return BattleConstString.waitTroopFanji + sourceTroopIndex.toString();
		}
		
		/**
		 * 获得等待卡片使用的tag 
		 * @param battleCardId
		 * @return 
		 */
		public static function getBattleCardUsedEventTag(battleCardId:int):String
		{
			return BattleConstString.battleCardUsedTag + battleCardId.toString();
		}
		
		/**
		 * 获得英雄死亡的tag
		 * @param sourceTroopIndex
		 * @return 
		 */
		public static function getHeroDeadTag(sourceTroopIndex:int):String
		{
			return BattleConstString.aoyiWaitHeroDeadTag + sourceTroopIndex.toString();
		}
		
	}
}