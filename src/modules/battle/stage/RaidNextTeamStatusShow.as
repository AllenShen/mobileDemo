package modules.battle.stage
{
	import flash.display.Sprite;
	
	import uipacket.previews.PreviewImage;
	
	public class RaidNextTeamStatusShow extends Sprite
	{
		private var playerShow1:SingleWaitPlayerShow = new SingleWaitPlayerShow;
		private var playerShow2:SingleWaitPlayerShow = new SingleWaitPlayerShow;
		
		private var allPlayers:Array = [];
		
		private var maskImage:PreviewImage;
		
		public function RaidNextTeamStatusShow()
		{
			super();
			allPlayers = [playerShow1,playerShow2];
			
			this.addChild(playerShow1);
			this.addChild(playerShow2);
			playerShow2.x = 72;
			
			maskImage = new PreviewImage();
			this.addChild(maskImage);
			maskImage.x = 32;
			maskImage.y = 20;
			maskImage.setResid(2356);
		}
		
		public function showMask(bShow:Boolean):void
		{
			playerShow1.showHeroMask(true);
			playerShow2.showHeroMask(true);
			maskImage.visible = true;
		}
		
		public function clearInfo():void
		{
		}
		
	}
}