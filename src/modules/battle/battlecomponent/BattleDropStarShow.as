package modules.battle.battlecomponent
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.battle.managers.DemoManager;
	
	public class BattleDropStarShow extends Sprite
	{
		public function BattleDropStarShow()
		{
			super();
			this.graphics.clear();
			this.graphics.beginFill(0xff0000,1);
			this.graphics.drawCircle(0,0,20);
			this.graphics.endFill();
			
			this.addEventListener(MouseEvent.CLICK,onMouseevent);
		}
		
		private function onMouseevent(event:MouseEvent):void
		{
			DemoManager.handleSingleStarQualified(NextSupplyShow.starSupplyTypeNone,0,1);
			this.visible = false;
			if(this.parent)
				this.parent.removeChild(this);
		}
		
	}
}