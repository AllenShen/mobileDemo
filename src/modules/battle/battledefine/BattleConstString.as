package modules.battle.battledefine
{
	

	/**
	 *  
	 * @author SDD
	 * 
	 */
	public class BattleConstString
	{
		
		/**
		 * 通知显示/关闭选择目标 
		 */
		public static const showTargetSelectWarn:String = "showTargetSelectWard";
		public static const hideTargetSelectWard:String = "hideTargetSelectWard";
		/**
		 * 通知兵营没有兵了
		 */
		public static const showNoArmInBarrack:String = "showNoArmInBarrack";
		
		//显示等待其他玩家的tag
		public static const showWaitForOther:String = "showWaitForOtherPlayer";
		
		//隐藏等待其他玩家的tag
		public static const hideWaitForOther:String = "hideWaitForOtherPlayer";
		
		//刷新当前的目标选择情形
		public static const refreshChoostTarget:String = "refreshChooseTargetStatus";
		
		//刷新正在选择目标的卡牌的状态
		public static const refreshSelectingCardStatus:String = "refreshSelectingCardStatus";
		
		//显示隐藏 精力不够提醒
		public static const showEnergyLackShow:String = "showEnergyLackWarn";
		public static const hideEnergyLackShow:String = "hideEnergyLackWarn"
		
		public static const troopNewRoundTag:String = "TroopNewRoundEvent_";
		
		public static const troopDeadTag:String = "sourceTroopDead_";
		
		public static const damageArrived:String = "damageArrivedFrom_";
		
		public static const chainWorkTag:String = "chainCheckEvent_";
		
		public static const troopStatusNeedTag:String = "troopStatusNeed_";
		
		public static const troopHpShow:String = "troopHpDisplay_";
		
		public static const troopWaitIdle:String = "waitTroopBeIdle_";
		
		//等待英雄回来的事件tag
		public static const heroBackWaitTag:String = "heroTroopWaitBack_";
		
		//等待y值free的情形
		public static const getYFreeTag:String = "waitYBeFree_";
		
		//等待时间差的hero
		public static const heroTroopWait:String = "heroTroopWaitTag_";
		
		//等待判断攻击是否命中
		public static const waitHitCheckTag:String = "checkTroopHit_";
		
		//判断是否为暴击
		public static const waitCheckCritcal:String = "checkAttackCritcal_";
		
		//等待反击发动
		public static const waitTroopFanji:String = "waitForTroopFanji_";
		
		//等待卡片使用
		public static const battleCardUsedTag:String = "battleCardTag_";
		
		//等待播放奥义的英雄死亡的事件
		public static const aoyiWaitHeroDeadTag:String = "aoyiWaitHeroDead_";
		
		public function BattleConstString()
		{
		}
	}
}