package modules.battle.stage
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import modules.battle.battlecomponent.BattleDropStarShow;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.managers.BattleEffectPosFunc;
	import macro.BattleDisplayDefine;

	public class BattleDropStarLayer extends Sprite
	{
		
		public function BattleDropStarLayer()
		{
		}
		
		public function initSelf():void
		{
				
		}
		
		public function clearInfo():void
		{
			while(this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
		
		public function showSingleStar(troopinfo:CellTroopInfo):void
		{
			if(troopinfo == null)
				return;
			var newDropStar:BattleDropStarShow = new BattleDropStarShow();
			this.addChild(newDropStar);
			
//			var pos:Point = BattleEffectPosFunc.getTroopCenterPoint(troopinfo);
			newDropStar.x = Math.random() * BattleDisplayDefine.cellWidth * troopinfo.cellsCountNeed.x  + troopinfo.x;
			newDropStar.y = Math.random() * BattleDisplayDefine.cellHeight * troopinfo.cellsCountNeed.y + troopinfo.y;
		}
		
	}

	
}