package modules.battle.stage
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import defines.ErrorCode;
	
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.BattleValueDefine;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	
	import synchronousLoader.ResourcePool;
	
	import tools.textengine.StringUtil;
	import tools.textengine.TextEngine;
	
	import uipacket.define.editdata.ButtonData;
	import uipacket.define.editdata.FontInfo;
	import uipacket.define.editdata.SizeInfo;
	import uipacket.previews.PreviewButton;
	import uipacket.previews.PreviewImage;
	import uipacket.previews.PreviewLabel;
	import uipacket.previews.PreviewWnd;
	
	/**
	 * 背景层
	 * @author SDD
	 */
	public class BattleGroundLayer extends Sprite
	{
		
		private var dikuangImage:PreviewImage = new PreviewImage;
		private var qiziMc:MovieClip;
		
		private var btnArmSupply:PreviewButton = new PreviewButton;
		
		private var countDownLabel:PreviewLabel;
		private var _tooltip:PreviewWnd;
		
		public function BattleGroundLayer()
		{
			super();
			
			var btnsize:SizeInfo = new SizeInfo;
			btnsize.w = 80;
			btnsize.h = 30;
			var btndata:ButtonData = new ButtonData;
			btndata.fixsize = 1;
			btndata.size = btnsize;
			btndata.up = 2270;
			btndata.stringid = 799;
			
			var newFontInfo:FontInfo = new FontInfo;
			newFontInfo.fontid = 5;
			btndata.font = newFontInfo;
			
			btnArmSupply.setUiData(btndata);
			btnArmSupply.buttonMode = true;
		}
		
		public function init():void
		{
			if(!BattleStage.instance.daojuLayer.contains(btnArmSupply))
			{
				BattleStage.instance.daojuLayer.addChild(btnArmSupply);
				btnArmSupply.x = 400;
				btnArmSupply.y = 151;
				btnArmSupply.addEventListener(MouseEvent.CLICK,addSupplyClick);
				btnArmSupply.addEventListener(MouseEvent.MOUSE_OVER,showArmSupplyTip);
				btnArmSupply.addEventListener(MouseEvent.MOUSE_OUT,hideArmSupplyTip);
			}
			if(!this.contains(dikuangImage))
			{
				this.addChild(dikuangImage);
				dikuangImage.x = 478;
				dikuangImage.y = 91;
			}
			dikuangImage.visible = false;
		}
		
		/**
		 * 初始化旗子动画信息
		 */
		public function initQiZiMc():void
		{
			if(BattleManager.instance.battleMode != BattleModeDefine.PVE_Instance)
			{
				if(btnArmSupply)
					btnArmSupply.visible = false;
				if(qiziMc)
					qiziMc.visible = false;
				dikuangImage.visible = false;
				return;
			}
			if(BattleInfoSnap.armSupplyLeftTime > 0)
			{
				if(qiziMc == null)
				{
					qiziMc = ResourcePool.getReflectSwfById(15002);
					if(qiziMc)
					{
						qiziMc.x = 450;
						qiziMc.y = 235;
						qiziMc.gotoAndStop(qiziMc.totalFrames);
						qiziMc.addEventListener(MouseEvent.MOUSE_OVER,showArmSupplyTip);
						qiziMc.addEventListener(MouseEvent.MOUSE_OUT,hideArmSupplyTip);
					}
				}
				if(qiziMc)
				{
					qiziMc.visible = true;
					this.addChild(qiziMc);
					
					if(countDownLabel == null)
					{
						countDownLabel = new PreviewLabel();
						countDownLabel.width = 120;
						countDownLabel.height = 50;
						countDownLabel.SetFont(39);
					}
					if(countDownLabel)
					{
						var dContainer:DisplayObjectContainer = qiziMc.getChildByName("shijian") as DisplayObjectContainer;
						if(dContainer)
						{
							countDownLabel.visible = true;
							dContainer.addChild(countDownLabel);
							countDownLabel.y = -2;
						}
					}
				}
				dikuangImage.setResid(15005);
				dikuangImage.visible = true;
				btnArmSupply.visible = false;
			}
			else
			{
				if(qiziMc)
					qiziMc.visible = false;
				if(countDownLabel)
					countDownLabel.visible = false;
				dikuangImage.visible = false;
				btnArmSupply.visible = true;
				
				var btndata:ButtonData = new ButtonData;
				var btnsize:SizeInfo = new SizeInfo;
				btnsize.w = 80;
				btnsize.h = 30;
				btndata.fixsize = 1;
				btndata.size = btnsize;
				btndata.up = 2270;
				if(BattleInfoSnap.armSupplyBuyCount <= 1)				//第一次显示的时候
				{
					btndata.stringid = 906;
				}
				else
				{
					btndata.stringid = 799;
				}
				var newFontInfo:FontInfo = new FontInfo;
				newFontInfo.fontid = 5;
				btndata.font = newFontInfo;
				btnArmSupply.setUiData(btndata);
			}
		}
		
		/**
		 * 播放旗子动画
		 */
		public function playQiziMovie():void
		{
			if(qiziMc)
			{
				qiziMc.play();
			}
		}
		
		public function updateTimeCountBackShowInfo():void
		{
			if(BattleInfoSnap.armSupplyLeftTime <= 0)
			{
				initQiZiMc();
			}
		}
		
		private function showArmSupplyTip(event:MouseEvent):void
		{
			var msg:String;
			if(BattleInfoSnap.armSupplyBuyCount <= 1)			//第一次购买
			{
				msg = StringUtil.substitute(TextEngine.getTextById(3458), BattleValueDefine.armSupplyWorkGap,
					BattleValueDefine.armSupplyRatio * 100);
			}
			else
			{
				msg = StringUtil.substitute(TextEngine.getTextById(3454), BattleValueDefine.armSupplyWorkGap,
					BattleValueDefine.armSupplyRatio * 100);
			}
			
			if(_tooltip)
				_tooltip.visible = true;
		}
		
		private function hideArmSupplyTip(event:MouseEvent):void
		{
			if(_tooltip)
				_tooltip.visible = false;
		}
		
		private function addSupplyClick(event:MouseEvent):void
		{
		}
		
		private function armSupplyBuyCallBack(param:Array):void
		{
			var ret:int = param.shift();
			if(ret == ErrorCode.suc)
			{
				btnArmSupply.visible = false;
				BattleInfoSnap.armSupplyLeftTime = param.shift();
				BattleInfoSnap.armSupplyBuyCount = param.shift();
				
				TroopDisplayFunc.showAllArmSupplyEffect(true);
				this.initQiZiMc();
				this.playQiziMovie();
			}
			else
			{
				ErrorCode.ShowValueErroCode(param[0]);
			}
		}
		
		public function clearInfo():void
		{
			if(qiziMc)
				qiziMc.visible = false;
			if(btnArmSupply)
				btnArmSupply.visible = false;
			if(_tooltip)
				_tooltip.visible = false;
			
			var singleObj:Object;
			while(this.numChildren > 0)
			{
				singleObj = this.removeChildAt(0);
				singleObj = null;
			}
		}
		
	}
}