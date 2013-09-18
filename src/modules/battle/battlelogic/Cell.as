package modules.battle.battlelogic
{
	import defines.HeroDefines;
	
	import flash.geom.Point;
	
	import macro.BattleDisplayDefine;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.stage.BattleStage;

	/**
	 * 表示战场上一个单独格子
	 * @author SDD
	 * 
	 */
	public class Cell
	{
		
		private var _troopInfo:CellTroopInfo;
		public var index:int = 0;
		public var selectStatus:CellSelectedStatusShow;
		
		public function Cell(index:int = 0)
		{
			this.index = index;	
		}
		
		public function clearCellInfo():void
		{
			this.troopInfo = null;
			if(selectStatus)
			{
				if(selectStatus.parent)
					selectStatus.parent.removeChild(selectStatus);
				selectStatus.clearInfo();
				selectStatus = null;
			}
		}
		
		/**
		 * 兵力信息 
		 */
		public function get troopInfo():CellTroopInfo
		{
			return _troopInfo;
		}

		/**
		 * @private
		 */
		public function set troopInfo(value:CellTroopInfo):void
		{
			_troopInfo = value;
		}

		public function checkCanShowSelected(targetType:int):Boolean
		{
			var retInfo:Boolean = false;
			
			if(this.troopInfo == null)
				return retInfo;
			
			if(this.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead || this.troopInfo.logicStatus == LogicSatusDefine.lg_status_hangToDie)
				return retInfo;
			
			if(targetType == BattleDefine.Range_SingleHero)
			{
				retInfo = troopInfo.isHero;
			}
			else
			{
				retInfo = !troopInfo.isHero;
			}
			
			return retInfo;
		}
		
		public function showSelectStatus(showType:int):void
		{
			if(showType == BattleDefine.Status_NoShow)
			{
				if(selectStatus)
				{
					selectStatus.visible = false;
				}
			}
			else
			{
				initSelectedStatus();
				selectStatus.visible = true;
				selectStatus.cellSelectedStatus = showType;
			}
			if(troopInfo)
			{
				TroopDisplayFunc.showTroopSelectedEffect(troopInfo,showType);
			}
		}
		
		private function initSelectedStatus():void
		{
			if(selectStatus == null)
			{
				selectStatus = new CellSelectedStatusShow();
				var selfPos:Point = TroopDisplayFunc.getCellPos(index,isFirstSide);
				selectStatus.x = selfPos.x;
				selectStatus.y = selfPos.y;
				
				if(troopInfo && troopInfo.isHero && troopInfo.troopVisibleOnBattle)
				{
					if(troopInfo.ownerSide == BattleDefine.firstAtk)
					{
						selectStatus.x -= BattleDisplayDefine.heroDefaultBackDis;
					}
					else
					{
						selectStatus.y += BattleDisplayDefine.heroDefaultBackDis;
					}
				}
				
				BattleStage.instance.cellSelectedShowLayer.addChild(selectStatus);
			}
		}
		
		private function get isFirstSide():Boolean
		{
			var leftside:int = BattleFunc.getPowerSideCellCount(true);
			return this.index < leftside;
		}
		
	}
}