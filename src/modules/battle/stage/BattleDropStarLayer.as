package modules.battle.stage
{
	import flash.display.Sprite;
	
	import macro.BattleDisplayDefine;
	
	import modules.battle.battlecomponent.BattleDropStarShow;
	import modules.battle.battlelogic.CellTroopInfo;

	public class BattleDropStarLayer extends Sprite
	{
		
		public static var geneDropStarProp:Number = 0.0;
		
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
		
		public function showSingleStar(troopinfo:CellTroopInfo,forceNeed:Boolean = false):void
		{
			return;
			if(troopinfo == null)
				return;
			
			if(Math.random() > geneDropStarProp && !forceNeed)
				return;
			
			var newDropStar:BattleDropStarShow = new BattleDropStarShow();
			this.addChild(newDropStar);
			
//			var pos:Point = BattleEffectPosFunc.getTroopCenterPoint(troopinfo);
			newDropStar.x = Math.random() * BattleDisplayDefine.cellWidth * troopinfo.cellsCountNeed.x  + troopinfo.x;
			newDropStar.y = Math.random() * BattleDisplayDefine.cellHeight * troopinfo.cellsCountNeed.y + troopinfo.y;
		}
		
	}

	
}