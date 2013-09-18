package modules.battle.stage
{
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	
	import uipacket.previews.PreviewImage;
	import uipacket.previews.PreviewLabel;
	
	public class SingleWaitPlayerShow extends Sprite
	{
		
		private var heroportraitBackImage:PreviewImage;
		private var heroportrait:PreviewImage;
		private var heroNameBackImage:PreviewImage;
		private var heroName:PreviewLabel;
		
		private var heroMask:PreviewImage;
		
		public function SingleWaitPlayerShow()
		{
			heroportraitBackImage = new PreviewImage();
			heroMask = new PreviewImage();
			heroMask.visible = false;
			heroMask.setResid(2358);
			
			heroNameBackImage = new PreviewImage();
			heroportrait = new PreviewImage();
			heroName = new PreviewLabel();
			
			heroportrait.x = 9;
			heroportrait.y = 4;
			heroportrait.setwidth = 65;
			heroportrait.setheight = 55;
			heroportrait.scale = true;
			
			this.addChild(heroportraitBackImage);
			this.addChild(heroportrait);
			this.addChild(heroNameBackImage);
			this.addChild(heroName);
			
			heroportraitBackImage.setResid(2197);
			heroNameBackImage.setResid(2198);
			heroNameBackImage.x = 4;
			heroNameBackImage.y = 53;
			
			heroName.width = 100;
			heroName.height = 30;
			heroName.wordWrap = false;
			heroName.autoSize = TextFieldAutoSize.CENTER;	
			heroName.SetFont(27);
			heroName.x = -10;
			heroName.y = 59;
			heroName.SetText("");
			
			super();
			
			this.addChild(heroMask);
		}

		public function showHeroMask(bshow:Boolean):void
		{
			heroMask.visible = bshow;
		}
		
		private function clearInfo():void
		{
			heroportrait.ClearImg();
			heroName.SetText("");
		}
		
	}
}