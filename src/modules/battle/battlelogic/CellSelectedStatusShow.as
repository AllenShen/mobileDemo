package modules.battle.battlelogic
{
	import flash.display.Sprite;
	
	import macro.BattleDisplayDefine;
	
	import modules.battle.battledefine.BattleDefine;
	
	public class CellSelectedStatusShow extends Sprite
	{
		
		private var _cellSelectedStatus:int;
		
		public function CellSelectedStatusShow()
		{
			super();
		}
		
		public function get cellSelectedStatus():int
		{
			return _cellSelectedStatus;
		}

		public function set cellSelectedStatus(value:int):void
		{
			_cellSelectedStatus = value;
			if(_cellSelectedStatus == BattleDefine.Status_NoShow)
			{
				this.visible = false;
			}
			if(_cellSelectedStatus == BattleDefine.Status_Default)
			{
				this.visible = true;
//				this.graphics.clear();
//				this.graphics.beginFill(0,0.5);
//				this.graphics.drawRect(0,0,BattleDisplayDefine.cellWidth,BattleDisplayDefine.cellHeight);
//				this.graphics.endFill();
			}
			else if(_cellSelectedStatus == BattleDefine.Status_Selected)
			{
				this.visible = true;
//				this.graphics.clear();
//				this.graphics.beginFill(0xff0000,0.5);
//				this.graphics.drawRect(0,0,BattleDisplayDefine.cellWidth,BattleDisplayDefine.cellHeight);
//				this.graphics.endFill();
			}
		}
		
		public function clearInfo():void
		{
			
		}
		
	}
}