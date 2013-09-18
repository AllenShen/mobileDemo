package modules.battle.battledefine
{
	import flash.events.Event;
	
	import macro.ArmType;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlelogic.Cell;
	import modules.battle.funcclass.TroopFunc;

	public class TroopFilterTypeDefine
	{
		
		public static const noFilter:int = 0;
		public static const canAttack:int = 1;			//是否可以攻击
		public static const canBeAttacked:int = 2;		//可以被攻击
		public static const footman:int = 3;			//步兵
		public static const archer:int = 4;				//弓箭兵
		public static const magic:int = 5;				//要是法师
		public static const machine:int = 6;			//机械单位
		public static const beixuanyun:int = 7;			//眩晕
		public static const beizhongdu:int = 8;			//中毒
		public static const onCurBattle:int = 9;		//在当前的战斗中
		public static const isHero:int = 10;
		
		/**
		 * 过滤某个cell是否满足条件 
		 * @param cell			cell
		 * @param condition		条件
		 * @return 
		 */
		public static function filterCell(singleCell:Cell,checkCondition:int):Boolean
		{
			var quilified:Boolean = true;
			if(singleCell == null || singleCell.troopInfo == null)
				return false;
			
			if(checkCondition != TroopFilterTypeDefine.isHero && singleCell.troopInfo.isHero)
			{
				return false;
			}
			
			if(checkCondition != 0)
			{
				switch(checkCondition)
				{
					case TroopFilterTypeDefine.canAttack:
						if(!singleCell.troopInfo.isAttackTroop)
							quilified = false;
						break;
					case TroopFilterTypeDefine.canBeAttacked:
						if(!singleCell.troopInfo.isAttackedTroop)
							quilified = false;
						break;
					case TroopFilterTypeDefine.footman:
						if(singleCell.troopInfo.attackUnit.armtype != ArmType.footman)
							quilified = false;
						break;
					case TroopFilterTypeDefine.archer:
						if(singleCell.troopInfo.attackUnit.armtype != ArmType.archer)
							quilified = false;
						break;
					case TroopFilterTypeDefine.magic:
						if(singleCell.troopInfo.attackUnit.armtype != ArmType.magic)
							quilified = false;
						break;
					case TroopFilterTypeDefine.machine:
						if(singleCell.troopInfo.attackUnit.armtype != ArmType.machine)
							quilified = false;
						break;
					case TroopFilterTypeDefine.beixuanyun:
						if(!TroopFunc.hasSpecificEffect(singleCell.troopInfo,SpecialEffectDefine.XuanYun))
							quilified = false;
						break;
					case TroopFilterTypeDefine.beizhongdu:
						if(!TroopFunc.hasSpecificEffect(singleCell.troopInfo,SpecialEffectDefine.ZhongDu))
							quilified = false;
						break;
					case TroopFilterTypeDefine.onCurBattle:
						if(singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_waitingForNextWave)
							quilified = false;
						break;
					case TroopFilterTypeDefine.isHero:
						if(!singleCell.troopInfo.isHero)
							quilified = false;
						break;
				}
			}
			
			return quilified;
		}
		
		public function TroopFilterTypeDefine()
		{
		}
	}
}