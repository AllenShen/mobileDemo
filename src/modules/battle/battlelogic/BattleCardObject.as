package modules.battle.battlelogic
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import caurina.transitions.Tweener;
	
	import defines.UserBattleCardInfo;
	
	import effects.BattleEffectObjBase;
	import effects.BattleResourcePool;
	
	import eventengine.GameEventHandler;
	
	import fl.controls.Label;
	
	import handlers.server.BattleHandler;
	
	import macro.BattleCardDefine;
	import macro.BattleCardTypeDefine;
	import macro.BattleDisplayDefine;
	import macro.EventMacro;
	
	import modules.battle.battleconfig.BattleEffectIdConfig;
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.EffectShowTypeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battleevents.BattleCardClickedEvent;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.utils.BattleEventTagFactory;
	
	import synchronousLoader.ResourcePool;
	
	import tools.textengine.TextEngine;
	
	import uipacket.previews.PreviewImage;
	import uipacket.previews.PreviewLabel;
	
	import utils.Utility;

	public class BattleCardObject extends Sprite
	{
		private var _canUseInTheRound:Boolean = false;				//此时是否可以选中
		
		private var _cdTimer:Timer;
		private var _curCdTime:int;
		
		private var _curStatus:int;
		
		private var _contentCard:UserBattleCardInfo;		//实际对应的card文件
		private var _contentCardArr:Array;
		
		private var cardContainer:MovieClip;		//卡片背景
		private var cardShowObj:BattleEffectObjBase;		//卡片
		private var realContianer:DisplayObjectContainer;
		private var labelContainer:DisplayObjectContainer;
		private var cardCountLabel:TextField;
		
		private var disableSprite:Sprite;
		
		public var timeCounter:TextField;
		
		private var newFormat:TextFormat = new TextFormat;
		private var newFormat1:TextFormat;
		
		public var indexInAllCards:int = 0;
		
		private var forbiddenImage:PreviewImage;
		private var _forbidden:Boolean = false;

		private var contentLabel:Label;
		private var coinsShowSprite:Sprite;
		
		public function BattleCardObject(battleCardsOfType:Array)
		{
			
			cardCountLabel = new TextField;
			
			newFormat1 = new TextFormat();
			newFormat1.color = 0xffffff;
			newFormat1.size = 12;
			newFormat1.align = TextFormatAlign.CENTER;
			
			this.buttonMode = true;
			this.curStatus = BattleCardDefine.Card_Free;
			
			this.contentCardArr = battleCardsOfType;
			this.contentCardArr.sort(sortFunction);
			
			this.contentCard = this.contentCardArr[0];
			
			cardCountLabel.width=0;
			cardCountLabel.height=0;
			cardCountLabel.autoSize=TextFieldAutoSize.LEFT;
						
			disableSprite = new Sprite;
			disableSprite.graphics.clear();
			disableSprite.graphics.lineStyle(1,0,0);
			disableSprite.graphics.beginFill(0,0);
			disableSprite.graphics.drawRect(0,0,BattleDisplayDefine.singleCardSize.x,BattleDisplayDefine.singleCardSize.y);
			disableSprite.graphics.endFill();
			this.addChild(disableSprite);
			disableSprite.visible = false;
			
			timeCounter = new TextField;
			timeCounter.x = 20;
			timeCounter.y = 35;
			timeCounter.width = 25;
			
			var newFormat:TextFormat = new TextFormat;
			timeCounter.mouseEnabled = false;
			
			disableSprite.addChild(timeCounter);
			forbiddenImage = new PreviewImage();
			forbiddenImage.visible = false;
			forbiddenImage.setResid(7000);
			this.addChild(forbiddenImage);
			
			contentLabel = new Label;
			this.addChild(contentLabel);
			contentLabel.y = -30;
			contentLabel.x = 0;
			
			contentLabel.text = TextEngine.getTextById(20081);
				
			if(contentCard.targetchoosetype == BattleCardDefine.shoudongXuanZe)
			{
				contentLabel.text = TextEngine.getTextById(20232);
			}
			
			contentLabel.visible = false;
			contentLabel.mouseEnabled = false;
			contentLabel.mouseChildren = false;
			
		}

		private function sortFunction(param1:UserBattleCardInfo,param2:UserBattleCardInfo):int
		{
			if(param1 == null || param2 == null)
				return 0;
			if(param1.quality < param2.quality)
				return 1;
			if(param1.quality >= param2.quality)
				return -1;
			return 0;
		}
		
		/**
		 * 点击处理函数 
		 * @param event
		 */
		private function cardClickHandler(event:Event):void
		{
			if(_forbidden)
			{
				this.buttonMode = false;
				nakeCardGray(true);
				return;
			}
			if(!canUseInTheRound || !BattleInfoSnap.battlecardMouseenabled || BattleInfoSnap.needLockBattleCard)
				return;
			
			if(this.cdTimeRunning)
				return;
			
			if(BattleManager.cardManager.checkParticularTypeCardCding(this.contentCard.cardtype))
				return;
			
			if(!BattleInfoSnap.gotCommandBack) 
			{
				return;
			}
			
			var isBuyAoyi:int = 0;
			
			if(this.curStatus == BattleCardDefine.Card_CDing || this.curStatus == BattleCardDefine.Card_PlayerHeroDead || 
				this.curStatus == BattleCardDefine.Card_WaintFromServer || this.curStatus == BattleCardDefine.Card_CannotWork)
				return;
			
			if(totalCardCount <= 0)
			{
				return;
			}

			var hasArmDecreased:Boolean = false;
			var hasArmToSupply:Boolean = false;
			var eStr:String = TextEngine.getTextById(715);
			var needSupplyType:Array=[];
			if(this.contentCard.cardtype == BattleCardTypeDefine.quanTiZengYuan)					//全体增援判断是否有兵力
			{
				var alltroops:Array = BattleUnitPool.getTroopsOsSomeSideOfOwner(BattleDefine.firstAtk);
				var singleTroopinfo:CellTroopInfo;
				for(var i:int = 0; i < alltroops.length;i++)
				{
					singleTroopinfo = alltroops[i] as CellTroopInfo;
					if(singleTroopinfo == null || singleTroopinfo.isHero || singleTroopinfo.logicStatus == LogicSatusDefine.lg_status_dead)
						continue;
					if(singleTroopinfo.curArmCount < singleTroopinfo.attackUnit.armcountofslot)
					{
						hasArmDecreased = true;
						if(needSupplyType.indexOf(singleTroopinfo.attackUnit.contentArmInfo.basearmid) < 0)
						{
							needSupplyType.push(singleTroopinfo.attackUnit.contentArmInfo.basearmid);
						}
					}
				}
			}
			
			this.dispatchEvent(new Event(BattleCardDefine.waitFromServerEventTag));
			
			makeCardUpWaitServerReply();				//点击后就让卡牌浮起来
			
			cardUsedCallBack();
		}
		
		public function refreshCurCount():void
		{
			cardCountLabel.text = totalCardCount.toString();
			cardCountLabel.setTextFormat(newFormat1,0,cardCountLabel.text.length);	
		}
		
		//使用卡片后的回调，需要更新当前卡片
		private function cardUsedCallBack():void
		{
			if(this.contentCard == null)
				return;
			this.dispatchEvent(new Event(BattleCardDefine.gotResultFromServer));
			
			_contentCard.count--;
			cardCountLabel.text = totalCardCount.toString();
			cardCountLabel.setTextFormat(newFormat1,0,cardCountLabel.text.length);
			
			this.dispatchEvent(new BattleCardClickedEvent(BattleCardClickedEvent.cardUserdInTheRound,this));
			makeCardUp(true);
			
			this.setStatusShowEffect(BattleCardDefine.Card_CDing);
			
			if(BattleManager.instance.battleMode == BattleModeDefine.PVP_Single)
			{
				BattleHandler.instance.onLineManager.notifyBattleCardUsed();
			}
			
			handlerPricePanelShow();
		}
		
		/**
		 * 点击后让卡牌上移，等待服务器回应
		 */
		private function makeCardUpWaitServerReply():void
		{
			Tweener.removeTweens(this);
			Tweener.addTween(this,{y:BattleDisplayDefine.cardUpPos.y,time:BattleDisplayDefine.cardUpDownTime,transition:"linear"});
		}
		
		private function makeCardUp(up:Boolean):void
		{
			if(cardShowObj == null)
			{
				return;
			}
			Tweener.removeTweens(this);
			
			var targetY:Number = 0;
			
			if(up)				//选中，等待生效，卡片上移
			{
				GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,
					BattleEventTagFactory.getBattleCardUsedEventTag(_contentCard.cardid),cardUserdHander);
				
				var realTime:int = Math.abs(targetY - this.y) / (BattleDisplayDefine.cardUpPos.y / BattleDisplayDefine.cardUpDownTime);
				
				Tweener.addTween(this,{y:targetY + BattleDisplayDefine.cardUpPos.y,time:realTime,transition:"linear"});
				if(this.contentCard.targetchoosetype == BattleCardDefine.shoudongXuanZe)
				{
					this.contentLabel.text = TextEngine.getTextById(20232);
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.showTargetSelectWarn));
				}
			}
			else				//生效，卡片归位
			{
				Tweener.addTween(this,{y:targetY,time:BattleDisplayDefine.cardUpDownTime,transition:"linear"});
				if(this.contentCard.targetchoosetype == BattleCardDefine.shoudongXuanZe)
				{
					this.contentLabel.visible = false;
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.hideTargetSelectWard));
				}
				
				BattleManager.cardManager.removeSingleCardInfo(this);
			}
		}
		
		private function refreshCardStatus(event:Event):void
		{
			if(BattleManager.cardManager.curChooseTargetCard && BattleManager.cardManager.curChooseTargetCard.usercardid == this.contentCard.usercardid)
			{
				contentLabel.visible = true;
				contentLabel.text = TextEngine.getTextById(20233);
			}
		}
		
		private function cardUserdHander(event:Event):void
		{
			GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,
				BattleEventTagFactory.getBattleCardUsedEventTag(_contentCard.cardid),cardUserdHander);
			
			if(cardContainer)
			{
				cardContainer.addEventListener(Event.ENTER_FRAME,cotainerMcEnterFrameHandler);
				cardContainer.play();
			}
			else
			{
				makeCardUp(false);
			}
		}
		
		/**
		 * 设置当前的状态 
		 * @param status
		 */
		public function setStatusShowEffect(status:int):void
		{
			if(status == this.curStatus)
				return;
			if(this.curStatus == BattleCardDefine.Card_UsedOut)
				return;
			this.curStatus = status;
			adjustButtonMode();
		}
		
		/**
		 * 初始化cdtimer 
		 * @param init
		 */
		public function initCDTImer(init:Boolean = false):void
		{
			if(_cdTimer != null)
			{
				_cdTimer.removeEventListener(TimerEvent.TIMER,cdTimerCount);
				_cdTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,cdTimerUpHander);
				_cdTimer.stop();
				_cdTimer = null;
			}
			if(contentCard == null)
				return;
			if(init)
			{
				timeCounter.visible = true;
				timeCounter.text = contentCard.cdTime.toString();
				
				newFormat.color = 0xff0000;
				newFormat.size = 18;
				newFormat.align = TextFormatAlign.CENTER;
				timeCounter.setTextFormat(newFormat,0,timeCounter.text.length);
				
				_cdTimer = new Timer(1000,contentCard.cdTime);
				_cdTimer.addEventListener(TimerEvent.TIMER,cdTimerCount);
				_cdTimer.addEventListener(TimerEvent.TIMER_COMPLETE,cdTimerUpHander);
				_cdTimer.start();
			}
			adjustButtonMode();
		}
		
		/**
		 * cd时间到 
		 * @param event
		 */
		public function cdTimerUpHander(event:TimerEvent = null):void
		{
			if(this.curStatus != BattleCardDefine.Card_PlayerHeroDead)
			{
				refreshCurContentCardInfo();
				if(totalCardCount > 0)
				{
					this.curStatus = BattleCardDefine.Card_Free;
				}
				else
				{
					this.curStatus = BattleCardDefine.Card_UsedOut;
				}
			}
			adjustButtonMode();
		}
		
		/**
		 * timer倒计时 
		 * @param event
		 */
		private function cdTimerCount(event:Event):void
		{
			var curNum:int = int(timeCounter.text);
			curNum--;
			timeCounter.text = curNum.toString();
			
			newFormat.color = 0xff0000;
			newFormat.size = 18;
			timeCounter.setTextFormat(newFormat,0,timeCounter.text.length);
			newFormat.align = TextFormatAlign.CENTER;
			
			if(curNum <= 0)
			{
				timeCounter.visible = false;
			}
		}
		
		/**
		 *  显示缺兵提示
		 */
		public function showArmLackLabel():void
		{
			if(contentCard && contentCard.cardtype == BattleCardTypeDefine.quanTiZengYuan)
			{
				contentLabel.visible = true;
			}
			else if(contentCard && contentCard.cardtype == BattleCardTypeDefine.fuhuo)
			{
				contentLabel.visible = true;
			}
			else
			{
				contentLabel.visible = false;
			}
		}
		
		/**
		 * 调整鼠标手势 
		 */
		public function adjustButtonMode():void
		{
			if(_forbidden)
			{
				this.buttonMode = false;
				nakeCardGray(true);
				return;
			}
			if(!canUseInTheRound || !BattleInfoSnap.battlecardMouseenabled || BattleInfoSnap.needLockBattleCard)
			{
				this.buttonMode = false;
				nakeCardGray(true);
				return;
			}
			if(this.curStatus == BattleCardDefine.Card_UsedOut || totalCardCount <= 0)				//如果使用完毕了，进行
			{
				handlerPricePanelShow();
			}
			if(this.curStatus == BattleCardDefine.Card_CDing || this.curStatus == BattleCardDefine.Card_PlayerHeroDead || 
				this.curStatus == BattleCardDefine.Card_WaintFromServer || this.curStatus == BattleCardDefine.Card_CannotWork)
			{
				this.buttonMode = false;
				nakeCardGray(true);
				return;
			}
			if(this.cdTimeRunning)
			{
				this.buttonMode = false;
				nakeCardGray(true);
				return;
			}
			nakeCardGray(false);
			this.buttonMode = true;
		}
		
		private function nakeCardGray(gray:Boolean):void
		{
			if(cardShowObj == null)
				return;
			if(gray)
			{
				disableSprite.visible = true;
				Utility.makeRGBColorFilter(0.4,0.4,0.4,1,cardShowObj);
			}
			else
			{
				disableSprite.visible = false;
				Utility.ClearColorFilter(cardShowObj);
			}
		}
		
		/**
		 * 清空信息 
		 */
		public function clearInfo():void
		{
			if(_contentCard)
				GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.getBattleCardUsedEventTag(_contentCard.cardid),cardUserdHander);
			GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,BattleConstString.refreshSelectingCardStatus);
			
			this.contentCard = null;
			while(contentCardArr.length)
			{
				var singleCardInfo:UserBattleCardInfo = contentCardArr.shift();
				singleCardInfo = null;
			}
			contentCardArr = null;
			
			if(cardShowObj)
			{
				if(realContianer.contains(cardShowObj))
				{
					realContianer.removeChild(cardShowObj);	
				}
				cardShowObj.isBusy = false;
				cardShowObj.removeEventListener(MouseEvent.CLICK,cardClickHandler);
			}
			if(labelContainer)
			{
				if(labelContainer.contains(cardCountLabel))
					labelContainer.removeChild(cardCountLabel);
			}
			if(cardContainer)
			{
				if(this.contains(cardContainer))
				{
					this.removeChild(cardContainer);
					cardContainer.removeEventListener(Event.ENTER_FRAME,cotainerMcEnterFrameHandler);
				}
			}
			contentLabel.visible = false;
			cardContainer = null;
			this.initCDTImer();
		}

		public function set contentCard(value:UserBattleCardInfo):void
		{
			_contentCard = value;
			if(_contentCard)
			{
				if(cardContainer == null)
				{
					cardContainer = ResourcePool.getReflectSwfById(BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_KaPianBeiJing));
				}
				if(cardContainer)
				{
					if(!this.contains(cardContainer))
						this.addChild(cardContainer);
					
					realContianer = cardContainer.getChildByName("cardframe") as DisplayObjectContainer;
					labelContainer = cardContainer.getChildByName("kapianzhangshu") as DisplayObjectContainer;;
					
					cardContainer.gotoAndStop(1);
					cardContainer.addEventListener(Event.ENTER_FRAME,cotainerMcEnterFrameHandler);
					
					if(realContianer)
					{
						cardShowObj = BattleResourcePool.getFreeResourceUnit(_contentCard.cardeffectid * 100);
						if(cardShowObj)
						{
							realContianer.addChild(cardShowObj);
							cardShowObj.addEventListener(MouseEvent.CLICK,cardClickHandler);
						}
					}
					if(labelContainer)
					{
						labelContainer.addChild(cardCountLabel);
						cardCountLabel.text = totalCardCount.toString();
						cardCountLabel.setTextFormat(newFormat1,0,cardCountLabel.text.length);
					}
				}
				handlerPricePanelShow();
			}
		}
		
		private function handlerPricePanelShow():void
		{
			if(contentCard.cardtype != BattleCardTypeDefine.AoYiKaPai)
				return;
			if(totalCardCount > 0)
				return;
		}
		
		private function cotainerMcEnterFrameHandler(event:Event):void
		{
			var tgergetMc:MovieClip = event.target as MovieClip;
			if(tgergetMc && tgergetMc.currentFrame == tgergetMc.totalFrames)
			{
				tgergetMc.gotoAndStop(1);
				makeCardUp(false);
				BattleManager.cardManager.makeSameTypeStartCD(this.contentCard.cardtype);
			}
		}

		private function refreshCurContentCardInfo():void
		{
			contentCardArr.sort(sortFunction);
			for(var i:int = 0; i < contentCardArr.length;i++)
			{
				var tempCard:UserBattleCardInfo = contentCardArr[i] as UserBattleCardInfo;
				if(tempCard && tempCard.count > 0)
				{
					this.contentCard = tempCard;
					break;
				}
			}
		}
		
		private function get totalCardCount():int
		{
			if(contentCardArr)
			{
				var allCount:int = 0;
				for each(var singleCardInfo:UserBattleCardInfo in contentCardArr)
				{
					allCount += singleCardInfo.count;
				}
				return allCount;
			}
			return 0;
		}
		
		public function get cdTimeRunning():Boolean
		{
			return _cdTimer && _cdTimer.running;
		}
		
		public function get contentCard():UserBattleCardInfo
		{
			return _contentCard;
		}
		
		public function get curStatus():int
		{
			return _curStatus;
		}

		public function set curStatus(value:int):void
		{
			_curStatus = value;
		}

		public function get curCdTime():int
		{
			return _curCdTime;
		}

		public function set curCdTime(value:int):void
		{
			_curCdTime = value;
		}

		public function get cdTimer():Timer
		{
			return _cdTimer;
		}

		public function set cdTimer(value:Timer):void
		{
			_cdTimer = value;
		}

		public function get canUseInTheRound():Boolean
		{
			return _canUseInTheRound;
		}

		public function set canUseInTheRound(value:Boolean):void
		{
			_canUseInTheRound = value;
			this.adjustButtonMode();
		}

		public function get contentCardArr():Array
		{
			return _contentCardArr;
		}

		public function set contentCardArr(value:Array):void
		{
			_contentCardArr = value;
		}

		public function get forbidden():Boolean
		{
			return _forbidden;
		}

		public function set forbidden(value:Boolean):void
		{
			_forbidden = value;
			if(_forbidden)
				forbiddenImage.visible = true;
			else
				forbiddenImage.visible = false;
			adjustButtonMode();
		}
	}
}