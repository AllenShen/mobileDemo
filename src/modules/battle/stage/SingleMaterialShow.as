package modules.battle.stage
{
	import defines.UserMaterialInfo;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import uipacket.previews.PreviewImage;
	import uipacket.previews.PreviewLabel;

	public class SingleMaterialShow extends Sprite
	{
		
		private var backImage:PreviewImage;
		private var contentPreviewInamge:PreviewImage = new PreviewImage;
		private var numCountShow:PreviewLabel = new PreviewLabel;
		
		private var _content:UserMaterialInfo;
		
		public function SingleMaterialShow()
		{
			backImage = new PreviewImage();
			backImage.setResid(2264);
			this.addChild(backImage);
			backImage.width = 70;
			backImage.height = 30;
			
			this.addChild(contentPreviewInamge);
			contentPreviewInamge.x = 0;
			contentPreviewInamge.y = -5;
			contentPreviewInamge.scaleX = 0.6;
			contentPreviewInamge.scaleY = 0.6;
			
			this.addChild(numCountShow);
			numCountShow.x = 35;
			numCountShow.y = 5;
			numCountShow.SetFont(15);
			numCountShow.SetText("0");
		}

		public function clearInfo():void
		{
			content = null;
			if(backImage)
			{
				backImage.ClearImg(true);
			}
			backImage = null;
			if(contentPreviewInamge)
			{
				contentPreviewInamge.ClearImg(true);
			}
			contentPreviewInamge = null;
			numCountShow = null;
			while(this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
		
		public function get content():UserMaterialInfo
		{
			return _content;
		}

		public function set content(value:UserMaterialInfo):void
		{
			_content = value;
			
			if(_content)
			{
				contentPreviewInamge.setResid(value.sysMaterialInfo.effectid);
				numCountShow.StartBlin(value.num.toString());
//				numCountShow.SetText();
			}
		}

	}
}