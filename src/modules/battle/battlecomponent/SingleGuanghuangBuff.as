package modules.battle.battlecomponent
{
	import flash.display.Sprite;
	
	import macro.SpecialEffectDefine;
	
	import tools.textengine.StringUtil;
	import tools.textengine.TextEngine;
	
	import uipacket.previews.PreviewImage;
	import uipacket.previews.PreviewLabel;

	public class SingleGuanghuangBuff extends Sprite
	{
		
		private var iconShow:PreviewImage;
		private var valueShow:PreviewLabel;
		
		private var _effectId:int;
		private var _value:Number = 0;
		
		public function SingleGuanghuangBuff()
		{
			this.iconShow = new PreviewImage();
			this.valueShow = new PreviewLabel();
			this.addChild(iconShow);
			this.addChild(valueShow);
			valueShow.x = 20;
		}
		
		public function get effectId():int
		{
			return _effectId;
		}

		public function set effectId(value:int):void
		{
			_effectId = value;
		}

		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = value;
			var retValue:String = "";
			var fontId:int = 45;
			switch(_effectId)
			{
				case SpecialEffectDefine.WuLiShangHaiMianYi:
					if(value < 0)
					{
						fontId = 45;
						retValue =  StringUtil.substitute(TextEngine.getTextById(20235),int((0 - value) * 100).toString());
						iconShow.setResid(1487);
					}
					else if(value > 0)
					{
						fontId = 46;
						iconShow.setResid(1488);	
						retValue =  StringUtil.substitute(TextEngine.getTextById(20236),(value * 100).toString());
					}
					break;
				case SpecialEffectDefine.MoFaShangHaiMianYi:
					if(value < 0)
					{
						fontId = 45;
						iconShow.setResid(1485);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20235),int((0 - value) * 100).toString());
					}
					else if(value > 0)
					{
						fontId = 46;
						iconShow.setResid(1486);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20235),int(value * 100).toString());
					}
					break;
				case SpecialEffectDefine.ShangHaiShuChuZengJia:
					if(value > 0)
					{
						fontId = 45;
						iconShow.setResid(1484);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20235),int(value * 100).toString());
					}
					else if(value < 0)
					{
						fontId = 46;
						iconShow.setResid(1483);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20235),int((0 - value) * 100).toString());
					}
					break;
				case SpecialEffectDefine.BaoJiZengJia:
					if(value > 0)
					{
						fontId = 45;
						iconShow.setResid(1481);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20235),int(value * 100).toString());
					}
					else if(value < 0)
					{
						fontId = 46;
						iconShow.setResid(1490);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20236),int((0 - value) * 100).toString());
					}
					break;
				case SpecialEffectDefine.ShanBiZengJia:
					if(value > 0)
					{
						fontId = 45;
						iconShow.setResid(1482);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20235),int(value * 100).toString());
					}
					else if(value < 0)
					{
						fontId = 46;
						iconShow.setResid(1491);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20236),int((0 - value) * 100).toString());
					}
					break;
				case SpecialEffectDefine.HPShangXianZengJia:			//文字
					if(value > 0)
					{
						fontId = 45;
						iconShow.setResid(1489);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20237),int(value).toString());
					}
					else if(value < 0)
					{
						fontId = 46;
						iconShow.setResid(1492);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20238),int((0 - value)).toString());
					}
					break;
				case SpecialEffectDefine.ShangHaiZengJia:				//文字
					if(value > 0)
					{
						fontId = 45;
						iconShow.setResid(1484);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20237),int(value).toString());
					}
					else if(value < 0)
					{
						fontId = 46;
						iconShow.setResid(1483);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20237),int((0 - value)).toString());
					}
					break;
				case SpecialEffectDefine.shiQiEWaiZengJia:
					if(value > 0)
					{
						fontId = 45;
						iconShow.setResid(1496);
						retValue =  StringUtil.substitute(TextEngine.getTextById(20237),int(value).toString());
					}
					break;
			}
			valueShow.SetText(retValue);
			valueShow.SetFont(fontId);
		}

	}
}