package modules.battle.stage
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import animator.animatorengine.AnimatorDefine;
	
	import eventengine.GameEventHandler;
	
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.controls.TextInput;
	
	import handlers.server.BattleHandler;
	
	import macro.BattleCardTypeDefine;
	import macro.BattleDisplayDefine;
	import macro.CommonEventTypeDefine;
	import macro.EventMacro;
	import macro.GameSizeDefine;
	
	import modules.battle.battlecomponent.NextSupplyShow;
	import modules.battle.battlecomponent.ShuaGuaJiangLiShow;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battleevents.CheckAttackEvent;
	import modules.battle.funcclass.BattleManagerLogicFunc;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	
	import synchronousLoader.ResourcePool;
	
	import uipacket.define.editdata.ButtonData;
	import uipacket.define.editdata.FontInfo;
	import uipacket.define.editdata.SizeInfo;
	import uipacket.previews.PreviewAnimator;
	import uipacket.previews.PreviewButton;

	/**
	 * 管理所有troop的显示的scene 
	 * @author SDD
	 */
	public class BattleStage extends Sprite
	{
		/**
		 * 新的一波敌人开始事件 
		 */
		public static const newEnemyWaveBegin:String = "newEnemyWaveBegins";
		public static const gotCoinsFormShuaiGuai:String = "getCoinsDuringShuaiGuai";
		
		private static var _instance:BattleStage; 
		
		private var _shakeLayer:Sprite;
		private var _noShakeLayer:Sprite;
		
		private var boshuZheZhao:Bitmap;
		private var boshuZheZhaoZuo:Bitmap;
		
		private var shuaguaiShow:ShuaGuaJiangLiShow;
		private var shuaGuaiShowOpponent:ShuaGuaJiangLiShow;
		
		private var _realbattleBackGroundLayer:Sprite;
		private var _battleBackGroundLayer:BattleGroundLayer;			//背景图层	
		private var _aoYiEffectLayer:Sprite;
		private var _cellSelectedShowLayer:Sprite;						//显示cell被选择的层
		private var _troopLayer:BattleTroopLayer;						//troop层
		private var _zhezhaoLayer:BattleTroopLayer;					
		private var _daojuLayer:BattleDaojuLayer;
		private var _effectLayer:BattleEffectLayer;					//效果层
		private var _userChooseLayer:BattleChooseLayer;				//玩家选择层
		
		private var testBtn:Button;
		private var troopIndexInput:TextInput;
		public var exitBattle:PreviewButton;			
		
		public var greatEffectAnimator:PreviewAnimator;
		
		private var selfMask:Sprite;
		
		private var battleParent:Sprite;
		
		public var stageInfoShow:TextField = new TextField;
		
		public var forceClearBtn:Button = new Button;
		
		public function BattleStage()
		{
			_noShakeLayer = new Sprite;
			this.addChild(_noShakeLayer);
			_noShakeLayer.graphics.clear();
			_noShakeLayer.graphics.beginFill(0,0);
			_noShakeLayer.graphics.drawRect(0,0,BattleDisplayDefine.battleMinWidth,BattleDisplayDefine.battleMinHeight);
			_noShakeLayer.graphics.endFill();
			
			_shakeLayer = new Sprite;
			this.addChild(_shakeLayer);
			
			_realbattleBackGroundLayer = new Sprite();
			
			_battleBackGroundLayer = new BattleGroundLayer;
			_aoYiEffectLayer = new Sprite;
			_cellSelectedShowLayer = new Sprite;
			_troopLayer = new BattleTroopLayer;
			_zhezhaoLayer = new BattleTroopLayer;
			_daojuLayer = new BattleDaojuLayer;
			_effectLayer = new BattleEffectLayer;
			
			_userChooseLayer = new BattleChooseLayer();
			
			_shakeLayer.addChild(_battleBackGroundLayer);
			_shakeLayer.addChild(_aoYiEffectLayer);
			_shakeLayer.addChild(_cellSelectedShowLayer);
			_shakeLayer.addChild(_troopLayer);
			_shakeLayer.addChild(_zhezhaoLayer);
			_shakeLayer.addChild(_daojuLayer);
			_shakeLayer.addChild(_effectLayer);
			
			this.addChild(_userChooseLayer);
			_userChooseLayer.visible = true;
			
			_zhezhaoLayer.mouseEnabled = false;
			_zhezhaoLayer.mouseChildren = false;
			
			_cellSelectedShowLayer.mouseEnabled = false;
			_cellSelectedShowLayer.mouseChildren = false;
			
			_aoYiEffectLayer.graphics.clear();
			_aoYiEffectLayer.graphics.beginFill(0,1);
			_aoYiEffectLayer.graphics.drawRect(0,0,GameSizeDefine.maxWidth,GameSizeDefine.maxHeight);
			_aoYiEffectLayer.graphics.endFill();
			_aoYiEffectLayer.visible = false;
			
			testBtn = new Button;
			testBtn.x = 400;
			testBtn.y = 500;
			testBtn.width = 35;
			testBtn.label = "测试";
			testBtn.buttonMode = true;
			testBtn.addEventListener(MouseEvent.CLICK,btnClicked);
			this.addChild(testBtn);
			if(BattleManager.needDebugBattle)
				testBtn.visible = true;
			else
				testBtn.visible = false;
			testBtn.visible = false;
			
			troopIndexInput = new TextInput;
			troopIndexInput.x = 80;
			troopIndexInput.y = 520;
			this.addChild(troopIndexInput);
//			troopIndexInput.visible = false;
			if(BattleManager.needDebugBattle)
				troopIndexInput.visible = true;
			else
				troopIndexInput.visible = false;
			
			exitBattle = new PreviewButton;
			
			var btnsize:SizeInfo = new SizeInfo;
			btnsize.w = 80;
			btnsize.h = 30;
			var btndata:ButtonData = new ButtonData;
			btndata.fixsize = 1;
			btndata.size = btnsize;
			btndata.stringid = 798;
			
			btndata.up = 2270;
			var newFontInfo:FontInfo = new FontInfo;
			newFontInfo.fontid = 5;
			btndata.font = newFontInfo;
			
			exitBattle.setUiData(btndata);
			exitBattle.x = BattleDefine.legalBattleWidth - 92
			exitBattle.y = BattleDefine.legalBattleHeight - 35;
			exitBattle.buttonMode = true;
			exitBattle.addEventListener(MouseEvent.CLICK,btnExitBattleCliecked);
			this.addChild(exitBattle);
			
			this.addEventListener(MouseEvent.MOUSE_OVER,onmouseOn);
			
			greatEffectAnimator = new PreviewAnimator();
			greatEffectAnimator.selfSceneType = AnimatorDefine.Battle_Player;
			this.addChild(greatEffectAnimator);
			greatEffectAnimator.mouseEnabled = false;
			greatEffectAnimator.mouseChildren = false;
			greatEffectAnimator.x = GameSizeDefine.maxWidth / 2;
			greatEffectAnimator.y = GameSizeDefine.maxHeight / 2;
			greatEffectAnimator.needadjustpos = false;
			greatEffectAnimator.needStopHandler = false;
			greatEffectAnimator.loops = 1;
			
			selfMask = new Sprite();
			selfMask.graphics.clear();
			selfMask.graphics.beginFill(0,0);
			selfMask.graphics.drawRect(0,0,GameSizeDefine.viewwidth,GameSizeDefine.viewheight);
			this.addChild(selfMask);
			selfMask.mouseEnabled = false;
			this.mask = selfMask;
			
			battleParent = new Sprite();
			battleParent.addChild(_realbattleBackGroundLayer);
			battleParent.addChild(this);
//			onscreenChange(null);
			
//			_realbattleBackGroundLayer.x = (BattleDefine.legalBattleWidth - GameSizeDefine.extreamWidth) / 2;
//			_realbattleBackGroundLayer.y = (BattleDefine.legalBattleHeight - GameSizeDefine.extreamHeight) / 2;
//			
//			shakeLayer.x = (BattleDefine.legalBattleWidth - GameSizeDefine.extreamWidth) / 2;
//			shakeLayer.y = (BattleDefine.legalBattleHeight - GameSizeDefine.extreamHeight) / 2;
			
			GameEventHandler.addListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_ScreenChanged,onscreenChange);
		}
		
		private function onscreenChange(event:Event):void
		{
			if(selfMask)
			{
				selfMask.graphics.clear();
				selfMask.graphics.beginFill(0,0);
				selfMask.graphics.drawRect(0,0,GameSizeDefine.viewwidth,GameSizeDefine.viewheight);
				this.addChild(selfMask);
				selfMask.mouseEnabled = false;
				this.mask = selfMask;
			}
			
			drawParentBack();
			
			if(exitBattle)
			{
				exitBattle.x = BattleDefine.legalBattleWidth - 92
				exitBattle.y = BattleDefine.legalBattleHeight - 35;
			}
			
			shakeLayer.x = (BattleDefine.legalBattleWidth - GameSizeDefine.extreamWidth) / 2;
			shakeLayer.y = (BattleDefine.legalBattleHeight - GameSizeDefine.extreamHeight) / 2;
			
			_realbattleBackGroundLayer.x = (BattleDefine.legalBattleWidth - GameSizeDefine.extreamWidth) / 2;
			_realbattleBackGroundLayer.y = (BattleDefine.legalBattleHeight - GameSizeDefine.extreamHeight) / 2;
			
			if(BattleManager.instance.portraitGroupAtk)
			{
				BattleManager.instance.portraitGroupAtk.x = BattleDisplayDefine.leftPortraitPos - BattleStage.instance.shakeLayer.x;
				BattleManager.instance.portraitGroupAtk.y = 0 - BattleStage.instance.shakeLayer.y;
			}
			if(BattleManager.instance.portraitGroupDef)
			{
				BattleManager.instance.portraitGroupDef.x = GameSizeDefine.viewwidth + 20;
				BattleManager.instance.portraitGroupDef.y = 0 - BattleStage.instance.shakeLayer.y;
			}
			
		}
		
		private function drawParentBack():void
		{
			battleParent.graphics.clear();
			battleParent.graphics.beginFill(0,1);
			battleParent.graphics.drawRect(0,0,GameSizeDefine.viewwidth,GameSizeDefine.viewheight);
			battleParent.graphics.endFill();
		}
		
		public function showBattle(bShow:Boolean):void
		{
			battleParent.visible = bShow;
			if(!bShow)
			{
				if(battleParent.parent)
					battleParent.parent.removeChild(battleParent);
			}
		}
		
		public function get cellSelectedShowLayer():Sprite
		{
			return _cellSelectedShowLayer;
		}

		public function set cellSelectedShowLayer(value:Sprite):void
		{
			_cellSelectedShowLayer = value;
		}

		private function onmouseOn(event:MouseEvent):void
		{

		}
		
		/**
		 *  初始化battlestace
		 */
		public function initBattleStage():void
		{
			_battleBackGroundLayer.init();
			_userChooseLayer.init();
			GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,BattleStage.newEnemyWaveBegin,nextWaveStartShowHandler);
			
			_zhezhaoLayer.visible = false;
			exitBattle.visible = false;
			
			this.addChild(NextSupplyShow.instance);
			NextSupplyShow.instance.x = 530;
			NextSupplyShow.instance.y = 200;
			
			BattleDisplayDefine.atkStartPos.y = BattleDisplayDefine.defualtYValue + (-10 - BattleDisplayDefine.cellGapVertocal) * BattleDefine.maxFormationYValue / 2;
			BattleDisplayDefine.defStartPos.y = BattleDisplayDefine.defualtYValue + (-10 - BattleDisplayDefine.cellGapVertocal) * BattleDefine.maxFormationYValue / 2;
			BattleDisplayDefine.nextWaveTroopStartPos.y = BattleDisplayDefine.defualtYValue + (-10 - BattleDisplayDefine.cellGapVertocal) * BattleDefine.maxFormationYValue / 2;
			GameEventHandler.addListener(EventMacro.CommonEventHandler, CommonEventTypeDefine.Event_BattleEnterFrame,BattleManagerLogicFunc.battleEnterFrameHanlder);
			
			if(stageInfoShow == null)
			{
				stageInfoShow = new stageInfoShow();
			}
			this.addChild(stageInfoShow);
			stageInfoShow.x = 650;
			stageInfoShow.y = 200;
			stageInfoShow.mouseEnabled = false;
			
			
			if(forceClearBtn == null)
			{
				forceClearBtn = new Button;
			}
			this.addChild(forceClearBtn);
			forceClearBtn.x = 850;
			forceClearBtn.y = 20;
			var newFormat1:TextFormat = new TextFormat();
			newFormat1.color = 0xff0000;
			newFormat1.size = 12;
			newFormat1.align = TextFormatAlign.CENTER;
			forceClearBtn.label = "卡住了？点我";
//			forceClearBtn.setTextFormat(newFormat1,0,forceClearBtn.text.length);
			forceClearBtn.addEventListener(MouseEvent.CLICK,onBtnClick);
		}
		
		private function onBtnClick(event:MouseEvent):void
		{
			if(BattleManager.instance.curRound)
				BattleManager.instance.curRound.secureTimeOutHandler(null);
		}
		
		/**
		 * 资源加载完成之后需要完成的初始化 
		 */
		public function initAfterResLoaded():void
		{
			if(shuaGuaiShowOpponent)
				shuaGuaiShowOpponent.visible = false;
			if(BattleModeDefine.checkNeedConsiderWave())
			{
				if(boshuZheZhao == null)
				{
					boshuZheZhao = ResourcePool.getResById(1412) as Bitmap;
					if(boshuZheZhao)
					{
						_zhezhaoLayer.addChild(boshuZheZhao);
						boshuZheZhao.x = GameSizeDefine.extreamWidth - boshuZheZhao.width;
						boshuZheZhao.y = (GameSizeDefine.extreamHeight - boshuZheZhao.height) / 2;
					}
				}
				
				if(boshuZheZhaoZuo == null)
				{
					boshuZheZhaoZuo = ResourcePool.getResById(1427) as Bitmap;
					if(boshuZheZhaoZuo)
					{
						_zhezhaoLayer.addChild(boshuZheZhaoZuo);
						boshuZheZhaoZuo.x = 0;
						boshuZheZhaoZuo.y = (GameSizeDefine.extreamHeight - boshuZheZhaoZuo.height) / 2;
					}
				}
				
				//单人刷怪，需要显示打到的资源
				if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance)
				{
					if(shuaguaiShow == null)
					{
						shuaguaiShow = new ShuaGuaJiangLiShow();
						shuaguaiShow.y = 120;
					}
					shuaguaiShow.x = 515;
					_zhezhaoLayer.addChild(shuaguaiShow);
					shuaguaiShow.setCurCount(0,false);
					shuaguaiShow.visible = true;
				}
				else
				{
					if(shuaguaiShow)
						shuaguaiShow.visible = false;
				}
			}
			else if(BattleInfoSnap.isDuoqiPVE)
			{
				if(shuaguaiShow == null)
				{
					shuaguaiShow = new ShuaGuaJiangLiShow();
					shuaguaiShow.y = 120;
				}
				shuaguaiShow.x = 515;
				this.addChild(shuaguaiShow);
				shuaguaiShow.setCurCount(BattleInfoSnap.allCoinsFromShuaiGua,false);
				shuaguaiShow.visible = true;
			}
			else if(BattleInfoSnap.isDuoqiPvp)
			{
				if(shuaguaiShow == null)
				{
					shuaguaiShow = new ShuaGuaJiangLiShow();
					shuaguaiShow.y = 120;
				}
				shuaguaiShow.x = 515;
				this.addChild(shuaguaiShow);
				shuaguaiShow.visible = true;
				
				if(shuaGuaiShowOpponent == null)
				{
					shuaGuaiShowOpponent = new ShuaGuaJiangLiShow();
					shuaGuaiShowOpponent.y = 120;
				}
				shuaGuaiShowOpponent.x = 655;
				this.addChild(shuaGuaiShowOpponent);
				shuaGuaiShowOpponent.visible = true;
			}
			else
			{
				if(shuaguaiShow)
					shuaguaiShow.visible = false;
				if(shuaGuaiShowOpponent)
					shuaGuaiShowOpponent.visible = false;
			}
			battleBackGroundLayer.initQiZiMc();
			daojuLayer.init();
			if(BattleInfoSnap.armSupplyLeftTime > 0)
			{
				TroopDisplayFunc.showAllArmSupplyEffect(true);
			}
		}
		
		/**
		 * 下一波数据来临 
		 * @param event
		 */
		private function nextWaveStartShowHandler(event:Event):void
		{
			daojuLayer.handleSingleWaveStart();
		}
		
		/**
		 * 刷怪获得coins，显示 
		 * @param event
		 */
		private function gotCoinsChange(event:DataEvent):void
		{
			if(shuaguaiShow)
			{
				shuaguaiShow.visible = true;
				shuaguaiShow.setCurCount(int(event.data),true);
			}
			else
			{
				if(BattleModeDefine.isGeneralRaid)
				{
					shuaguaiShow = new ShuaGuaJiangLiShow();
					shuaguaiShow.x = 515;
					shuaguaiShow.y = 120;
					_zhezhaoLayer.addChild(shuaguaiShow);
					shuaguaiShow.setCurCount(0,false);
					shuaguaiShow.visible = true;
				}
				shuaguaiShow.setCurCount(int(event.data),true);
			}
		}
		
		public function addStr(strinfo:String):void
		{
		}
		
		/**
		 * 显示大的效果 
		 * @param effectId
		 */
		public function showGreatEffectByRid(targetResId:int):void
		{
			if(targetResId < 0)
				return;
			greatEffectAnimator.x = GameSizeDefine.maxWidth / 2;
			greatEffectAnimator.y = 170;
			greatEffectAnimator.setResid(targetResId);
			greatEffectAnimator.visible = true;
			greatEffectAnimator.playAnimator(0,1);
		}
		
		/**
		 * 显示卡牌生效的大的效果
		 * @param cardType
		 */
		public function showCardWorkGreatGreatEffect(cardType:int,targetSide:int):void
		{
			greatEffectAnimator.x = GameSizeDefine.maxWidth / 2;
			greatEffectAnimator.y = GameSizeDefine.maxHeight / 2 ;
			
			greatEffectAnimator.y = 170;
			
			var targetResId:int = 0;
			switch(cardType)
			{
				case BattleCardTypeDefine.bingdong:
					targetResId = 7055;
					targetSide = -1;
					break;
				case BattleCardTypeDefine.fuhuo:
					targetResId = 7056;
					targetSide = -1;
					break;
				case BattleCardTypeDefine.fengJiNeng:
					targetResId = 7057;
					break;
				case BattleCardTypeDefine.jieFeng:
					targetResId = 7058;
					break;
			}
			if(targetResId <= 0)
				return;
			if(targetSide == BattleDefine.firstAtk)
			{
				greatEffectAnimator.x = GameSizeDefine.maxWidth / 2;
				greatEffectAnimator.x = 270;
				greatEffectAnimator.y = 250;
			}
			else if(targetSide == BattleDefine.secondAtk)
			{
				greatEffectAnimator.x = 635;
				greatEffectAnimator.y = 250;
			}
			greatEffectAnimator.setResid(targetResId);
			greatEffectAnimator.visible = true;
			greatEffectAnimator.playAnimator(0,1);
		}
		
		public function clearInfo():void
		{
			greatEffectAnimator.visible = false;
			
			if(_realbattleBackGroundLayer)
			{
				while(_realbattleBackGroundLayer.numChildren > 0)
				{
					var singleObj:DisplayObject = _realbattleBackGroundLayer.removeChildAt(0);
					singleObj = null;
				}
			}
			
			_userChooseLayer && _userChooseLayer.clearInfo();
			_battleBackGroundLayer && _battleBackGroundLayer.clearInfo();
			_troopLayer && _troopLayer.clearInfo();
			_daojuLayer && _daojuLayer.clearInfo();
			_effectLayer && _effectLayer.clearInfo();
			_zhezhaoLayer && _zhezhaoLayer.clearInfo();
			_noShakeLayer.y = 0;
			GameEventHandler.removeListener(EventMacro.CommonEventHandler, CommonEventTypeDefine.Event_BattleEnterFrame,BattleManagerLogicFunc.battleEnterFrameHanlder);
			ResourcePool.releaseResourceById(BattleInfoSnap.battleBackgroundId);				//释放背景图资源
		}
		
		private function btnClicked(event:MouseEvent):void
		{
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
		}
		
		private function btnExitBattleCliecked(event:MouseEvent):void
		{
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance)
			{
				BattleManager.instance.curBattleResult.updateResultInfo();
			}
			else if(BattleModeDefine.isGeneralRaid)
			{
				BattleInfoSnap.curOnLineManager = BattleHandler.instance.onLineManager;
				//发送推出消息，获得奖励
			}
			BattleManager.instance.clearBattleInfo();
		}
		
		/**
		 * 是否显示奥义效果层 
		 * @param show
		 */
		public function showAoYiLayer(show:Boolean):void
		{
			if(_aoYiEffectLayer == null)
				return;
			if(show)
			{
				_aoYiEffectLayer.visible = true;
			}
			else
			{
				_aoYiEffectLayer.visible = false;
			}
		}
		
		/**
		 * 获得instance 
		 * @return 
		 */
		public static function get instance():BattleStage
		{
			if(_instance == null)
			{
				_instance = new BattleStage();
			}
			return _instance;
		}

		public function get battleBackGroundLayer():BattleGroundLayer
		{
			return _battleBackGroundLayer;
		}

		public function set battleBackGroundLayer(value:BattleGroundLayer):void
		{
			_battleBackGroundLayer = value;
		}

		public function get troopLayer():BattleTroopLayer
		{
			return _troopLayer;
		}

		public function set troopLayer(value:BattleTroopLayer):void
		{
			_troopLayer = value;
		}

		public function get effectLayer():BattleEffectLayer
		{
			return _effectLayer;
		}

		public function set effectLayer(value:BattleEffectLayer):void
		{
			_effectLayer = value;
		}

		public function get daojuLayer():BattleDaojuLayer
		{
			return _daojuLayer;
		}

		public function set daojuLayer(value:BattleDaojuLayer):void
		{
			_daojuLayer = value;
		}

		public function get shakeLayer():Sprite
		{
			return _shakeLayer;
		}

		public function set shakeLayer(value:Sprite):void
		{
			_shakeLayer = value;
		}

		public function get noShakeLayer():Sprite
		{
			return _noShakeLayer;
		}

		public function get aoYiEffectLayer():Sprite
		{
			return _aoYiEffectLayer;
		}

		public function set aoYiEffectLayer(value:Sprite):void
		{
			_aoYiEffectLayer = value;
		}

		public function get zhezhaoLayer():BattleTroopLayer
		{
			return _zhezhaoLayer;
		}

		public function set zhezhaoLayer(value:BattleTroopLayer):void
		{
			_zhezhaoLayer = value;
		}

		public function get userChooseLayer():BattleChooseLayer
		{
			return _userChooseLayer;
		}

		public function set userChooseLayer(value:BattleChooseLayer):void
		{
			_userChooseLayer = value;
		}

		public function get realbattleBackGroundLayer():Sprite
		{
			return _realbattleBackGroundLayer;
		}

		public function set realbattleBackGroundLayer(value:Sprite):void
		{
			_realbattleBackGroundLayer = value;
		}

		
	}
	
}
