package modules.battle.managers
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	
	import defines.UserBattleCardInfo;
	
	import effects.floatingobjs.FloatingAwayManager;
	
	import eventengine.GameEventHandler;
	
	import handlers.server.BattleHandler;
	
	import macro.BattleCardDefine;
	import macro.BattleCardTypeDefine;
	import macro.BattleDisplayDefine;
	import macro.EventMacro;
	import macro.GameSizeDefine;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlecomponent.DeadEnemyCycle;
	import modules.battle.battlecomponent.DeadEnemyProgressShow;
	import modules.battle.battledata.BDataPvpSingle;
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battleevents.BattleCardClickedEvent;
	import modules.battle.battlelogic.BattleCardObject;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.SingleRound;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.stage.BattleStage;
	import modules.battle.utils.BattleEventTagFactory;
	
	import sysdata.SkillElement;
	
	import tools.textengine.TextEngine;
	
	import uipacket.previews.PreviewLabel;

	/**
	 * 卡片管理器 
	 * @author SDD
	 */
	public class BattleCardManager
	{
		
		//主将死亡的时候发出事件，禁用卡片
		public static const playerHeroDeadEvent:String = "playerUserDeadDisableCards";
		
		public var curWaitCard:Array;				//当前等待的道具卡
		
		private var _curWaitHeroCard:Array;			//当前等待的英雄卡 	奥义卡
		
		public var curWaitAoyiCard:Array;			//当前等待的奥义卡
		
		public var availableCards:Array;			//所有卡片集合
		
		public var cardEffectOnList:Object={};			//等待发生的效果，在celltroop checkattack之前需要取得
		
		public var curTarget:Object = {};
		
		public var curChooseTargetCard:UserBattleCardInfo;
		
		private var targetSelectLabel:PreviewLabel;
		
		public var legalCards:Array = [];
		
		private var allLegalCardCount:int = 0;
		
		private var deadEnemyTroopShow:Sprite;
		
		private var battleCardsParent:Sprite;
		
		private var allBattleCards:Array = [];
		
		public function BattleCardManager()
		{
			curWaitCard =[];
			curWaitHeroCard =[];
			curWaitAoyiCard =[];
			availableCards =[];	
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleConstString.showNoArmInBarrack,showNoBarrackArmWarning);
			
			battleCardsParent = new Sprite();
		}
		
		/**
		 * 查看是否为奥义回合,有风险，
		 * @return 
		 */
		public function checkIsAoyiRound():Boolean
		{
			var retInfo:Boolean = false;
			if(curWaitAoyiCard && curWaitAoyiCard.length > 0)
			{
				for(var i:int = 0;i < curWaitAoyiCard.length;i++)
				{
					var singleCardObj:UserBattleCardInfo = curWaitAoyiCard[i];
					if(singleCardObj == null)
						continue;
					var canUse:Boolean = checkIsCardIlegal(singleCardObj,false);
					if(canUse)
					{
						retInfo = true;
						break;
					}
				}
			}
			return retInfo;
		}
		
		public function handleSingleEnemyTroopDead():void
		{
			
		}
		
		/**
		 * 处理新的卡牌
		 */
		public function handleNewBattleCardGened(cardInfo:UserBattleCardInfo):void
		{
			addSingleBattleCard(cardInfo);
		}
		
		public function removeSingleCardInfo(cardInfo:BattleCardObject):void
		{
//			for(var i:int;i < allBattleCards.length;i++)
//			{
//				var singleCard:BattleCardObject = allBattleCards[i];
//				if(singleCard == cardInfo)
//				{
//					allBattleCards.splice(i,0);
//					if(singleCard.parent)
//						singleCard.parent.removeChild(singleCard);
//					singleCard.clearInfo();
//					singleCard = null;
//					break;
//				}
//			}
//			availableCards = [];
//			initCardsLogic(allBattleCards);
		}
		
		public function addSingleBattleCard(newCardInfo:UserBattleCardInfo):void
		{
			if(newCardInfo == null)
				return;
			var singleCardInfo:UserBattleCardInfo;
			var curObj:BattleCardObject = availableCards[newCardInfo.cardtype];
			if(curObj != null)
			{
				singleCardInfo = curObj.contentCardArr[0];
				if(singleCardInfo)
				{
					singleCardInfo.count++;
				}
				curObj.refreshCurCount();
			}
			else
			{
				while(availableCards.length > 0)
				{
					var singleCard:BattleCardObject = availableCards.pop() as BattleCardObject;
					if(singleCard == null)
						continue;
					if(singleCard.parent)
						singleCard.parent.removeChild(singleCard);
					singleCard.clearInfo();
					singleCard = null;
				}
				
				allBattleCards.push(newCardInfo);
				initCardsLogic(allBattleCards);
			}
		}
		
		public function initCardsLogic(info:Array):void
		{
			var singleCardInfo:UserBattleCardInfo;
			var singleCardObj:BattleCardObject;
			
			var allAvailableTypes:Array=[];
			//分类
			var cardByType:Object={};
			for(var i:int = 0;i < info.length;i++)
			{
				singleCardInfo = info[i] as UserBattleCardInfo;
				if(singleCardInfo == null)
					continue;
				
				var targetArr:Array = cardByType[singleCardInfo.cardtype];
				if(targetArr == null)
				{
					targetArr =[];
					cardByType[singleCardInfo.cardtype] = targetArr;
					allAvailableTypes.push(singleCardInfo.cardtype);
				}
				targetArr.push(singleCardInfo);
			}
			
			allLegalCardCount = 0;
			for(var singleTypeIndex:int = 0;singleTypeIndex < allAvailableTypes.length;singleTypeIndex++)
			{
				var curTypeIndex:int = allAvailableTypes[singleTypeIndex];
				singleCardObj = new BattleCardObject(cardByType[curTypeIndex]);
				singleCardObj.addEventListener(BattleCardClickedEvent.cardUserdInTheRound,cardBeUsedInTheRound);
				singleCardObj.addEventListener(BattleCardDefine.waitFromServerEventTag,cardWaitingFormServer);
				singleCardObj.addEventListener(BattleCardDefine.gotResultFromServer,cardResultFromServer);
				
				availableCards[BattleCardTypeDefine.getCardTypeIndex(curTypeIndex)] = singleCardObj;
				allLegalCardCount++;
			}
			
//			BattleStage.instance.daojuLayer.addChild(battleCardsParent);
			BattleStage.instance.addChild(battleCardsParent);
			
			//起始位置
			var startX:Number = (BattleDefine.legalBattleWidth + BattleDisplayDefine.battleCardGap - 
				allLegalCardCount*(BattleDisplayDefine.singleCardSize.x + BattleDisplayDefine.battleCardGap)) / 2;
			
			battleCardsParent.x = startX - BattleStage.instance.shakeLayer.x;
			battleCardsParent.x = startX + 150;
			battleCardsParent.y = BattleDefine.legalBattleHeight - BattleDisplayDefine.battleCardPaddingBottom - 
				BattleDisplayDefine.singleCardSize.y - BattleStage.instance.shakeLayer.y;
			
//			battleCardsParent.x = 500;
//			battleCardsParent.y = 120;
//			battleCardsParent.scaleX = 0.9;
//			battleCardsParent.scaleY = 0.9;
			
			var realIndex:int = 0;
			for(i = 0;i < availableCards.length;i++)
			{
				singleCardObj = availableCards[i] as BattleCardObject;
				if(singleCardObj == null)
					continue;
				singleCardObj.indexInAllCards = realIndex;
				singleCardObj.x = (BattleDisplayDefine.singleCardSize.x + BattleDisplayDefine.battleCardGap) * realIndex;
				battleCardsParent.addChild(singleCardObj);
				var curControlName:String = "";
				realIndex++;
			}
			
		}
		
		/**
		 *  初始化所有的card
		 */
		public function initAvailableCards(info:Array):void
		{
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleConstString.showNoArmInBarrack,showNoBarrackArmWarning);
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleConstString.showTargetSelectWarn,showTargetSelectWarn);
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleConstString.hideTargetSelectWard,hideTargetSelectWard);
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleConstString.refreshSelectingCardStatus,refreshCardStatus);
			
			if(targetSelectLabel == null)
			{
				targetSelectLabel = new PreviewLabel();
				
				targetSelectLabel.wordWrap = false;
				targetSelectLabel.autoSize = TextFieldAutoSize.CENTER;
				targetSelectLabel.mouseEnabled = false;
				
				targetSelectLabel.x = (GameSizeDefine.viewwidth - targetSelectLabel.width) / 2;
				targetSelectLabel.y = GameSizeDefine.viewheight - 140;
				targetSelectLabel.SetTextID(20311);
				targetSelectLabel.SetFont(7);
			}
			
			initCardsLogic(info);
			
			targetSelectLabel.visible = false;
			BattleStage.instance.daojuLayer.addChild(targetSelectLabel);
			
			BattleStage.instance.daojuLayer.addChild(DeadEnemyProgressShow.instance);
			DeadEnemyProgressShow.instance.visible = false;               //控制能量条显示
			
			DeadEnemyProgressShow.instance.y = BattleDefine.legalBattleHeight - 50;
			DeadEnemyProgressShow.instance.x = 150;
			
			BattleStage.instance.stage.addChild(DeadEnemyCycle.instance);

			DeadEnemyCycle.instance.y = BattleDefine.legalBattleHeight - 105;
			DeadEnemyCycle.instance.x = 400;
			DeadEnemyCycle.instance.curCount = 0;
			DeadEnemyCycle.instance.visible = true;
			
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleCardManager.playerHeroDeadEvent,playerHeroDeadHandler);
		}
		
		public function adjustCardPos():void
		{
			if(targetSelectLabel)
			{
				targetSelectLabel.x = (GameSizeDefine.viewwidth - targetSelectLabel.width) / 2;
				targetSelectLabel.y = GameSizeDefine.viewheight - 140;
			}
			
			var startX:Number = (BattleDefine.legalBattleWidth + BattleDisplayDefine.battleCardGap - 
				allLegalCardCount*(BattleDisplayDefine.singleCardSize.x + BattleDisplayDefine.battleCardGap)) / 2;
			
			battleCardsParent.x = startX - BattleStage.instance.shakeLayer.x;
			battleCardsParent.y = BattleDefine.legalBattleHeight - BattleDisplayDefine.battleCardPaddingBottom - 
				BattleDisplayDefine.singleCardSize.y - BattleStage.instance.shakeLayer.y;
		}
		
		public function getCardByInddex(cardIndex:int):BattleCardObject
		{
			for(var i:int = 0;i < availableCards.length;i++)
			{
				var singleCardObj:BattleCardObject = availableCards[i] as BattleCardObject;
				if(singleCardObj && singleCardObj.indexInAllCards == cardIndex)
					return singleCardObj;
			}
			return singleCardObj;
		}
		
		public function getCardIdByIndex(cardId:int):BattleCardObject
		{
			for(var i:int = 0;i < availableCards.length;i++)
			{
				var singleCardObj:BattleCardObject = availableCards[i] as BattleCardObject;
				if(singleCardObj && singleCardObj.contentCard.cardid == cardId)
					return singleCardObj;
			}
			return singleCardObj;
		}
		
		private function showNoBarrackArmWarning(event:Event):void
		{
			var eStr:String = TextEngine.getTextById(715);
			var singleCardInfo:BattleCardObject;
			for(var i:int = 0; i < availableCards.length;i++)
			{
				singleCardInfo = availableCards[i] as BattleCardObject;
				if(singleCardInfo == null)
					continue;
				if(singleCardInfo.contentCard.cardtype == BattleCardTypeDefine.quanTiZengYuan || singleCardInfo.contentCard.cardtype == BattleCardTypeDefine.fuhuo)
				{
					FloatingAwayManager.showFloatingObjectsOfPureText(singleCardInfo.parent,[eStr],new Point(singleCardInfo.x - 30,singleCardInfo.y));
					singleCardInfo.showArmLackLabel();
					break;
				}
			}
		}
		
		private function hideTargetSelectWard(event:Event):void
		{
			if(targetSelectLabel)
				targetSelectLabel.visible = false;
		}
		
		private function showTargetSelectWarn(event:Event):void
		{
			if(targetSelectLabel)
			{
				targetSelectLabel.visible = true;	
				targetSelectLabel.SetTextID(20311);
			}
		}
		
		private function refreshCardStatus(event:Event):void
		{
			if(targetSelectLabel)
			{
				targetSelectLabel.visible = true;	
				targetSelectLabel.SetTextID(20233);
			}
		}
		
		/**
		 * 主将死亡，禁用卡片 
		 * @param event
		 */
		private function playerHeroDeadHandler(event:Event):void
		{
			var singleCardInfo:BattleCardObject;
			for(var i:int = 0; i < availableCards.length;i++)
			{
				singleCardInfo = availableCards[i] as BattleCardObject;
				if(singleCardInfo)
				{
					singleCardInfo.curStatus = BattleCardDefine.Card_PlayerHeroDead;
					singleCardInfo.adjustButtonMode();
				}
			}
		}
		
		/**
		 * 设置所有卡片状态在等待后台返回，不可用 
		 * @param event
		 */
		private function cardWaitingFormServer(event:Event):void
		{
			var singleCardInfo:BattleCardObject;
			for(var i:int = 0; i < availableCards.length;i++)
			{
				singleCardInfo = availableCards[i] as BattleCardObject;
				if(singleCardInfo)
				{
					if(singleCardInfo.curStatus != BattleCardDefine.Card_CDing)
					{
						singleCardInfo.curStatus = BattleCardDefine.Card_WaintFromServer;
						singleCardInfo.adjustButtonMode();
					}
				}
			}
		}
		
		/**
		 *  将所有正在cd的cd时间清零
		 */
		public function clearAllCardCDInfo():void
		{
			allBattleCards = [];
			var singleCardInfo:BattleCardObject;
			for(var i:int = 0; i < availableCards.length;i++)
			{
				singleCardInfo = availableCards[i] as BattleCardObject;
				if(singleCardInfo)
				{
					if(singleCardInfo.cdTimeRunning)		
					{
						singleCardInfo.timeCounter.text = "0";
						singleCardInfo.timeCounter.visible = false;
						singleCardInfo.initCDTImer(false);
						singleCardInfo.cdTimerUpHander();
					}
				}
			}
		}
		
		/**
		 * 卡片从服务器得到返回结果 
		 * @param event
		 */
		private function cardResultFromServer(event:Event):void
		{
			var singleCardInfo:BattleCardObject;
			for(var i:int = 0; i < availableCards.length;i++)
			{
				singleCardInfo = availableCards[i] as BattleCardObject;
				if(singleCardInfo)
				{
					if(singleCardInfo.curStatus == BattleCardDefine.Card_WaintFromServer)
						singleCardInfo.curStatus = BattleCardDefine.Card_Free;
				}
			}
		}
		
		/**
		 * 本回合卡片使用 
		 * @param event
		 */
		private function cardBeUsedInTheRound(event:BattleCardClickedEvent):void
		{
			var contentCard:UserBattleCardInfo = event.targetCard.contentCard;
			if(contentCard.targetchoosetype == BattleCardDefine.morenShifang)
				this.addCardToList(event.targetCard.contentCard);
			else
			{
				curChooseTargetCard = contentCard;
				for(var index:int= 0;index < curChooseTargetCard.skill.elements.length;index++)
				{
					var singleSkillElement:SkillElement = curChooseTargetCard.skill.elements[index] as SkillElement;
					if(singleSkillElement)
					{
						var range:int = singleSkillElement.target;
						var realSide:int = BattleTargetSearcher.getRealPowerSide(range);
						var chooseType:int = BattleTargetSearcher.tureRangeToChooseRange(range);
						BattleStage.instance.userChooseLayer.showChooseInfo(realSide,chooseType);
						break;
					}
				}
			}
			var singleCardInfo:BattleCardObject;
			for(var i:int = 0; i < availableCards.length;i++)
			{
				singleCardInfo = availableCards[i] as BattleCardObject;
				if(singleCardInfo)
				{
					singleCardInfo.canUseInTheRound = false;
				}
			}
		}
		
		/**
		 *  清空信息
		 */
		public function clearInfo():void
		{
			allLegalCardCount = 0;
			legalCards = [];
			curChooseTargetCard = null;
			GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,BattleCardManager.playerHeroDeadEvent,playerHeroDeadHandler);
			
			var singleUserCard:UserBattleCardInfo;
			var allInfoArr:Array = curWaitCard.concat(curWaitHeroCard).concat(curWaitAoyiCard);
			while(allInfoArr.length > 0)
			{
				singleUserCard = allInfoArr.pop() as UserBattleCardInfo;
				if(singleUserCard)
				{
					singleUserCard = null;
				}
			}
			
			curWaitCard =[];
			curWaitHeroCard =[];
			curWaitAoyiCard =[];
			
			var singleCard:BattleCardObject;
			while(availableCards.length > 0)
			{
				singleCard = availableCards.pop() as BattleCardObject;
				if(singleCard == null)
					continue;
				if(singleCard.parent)
					singleCard.parent.removeChild(singleCard);
				singleCard.clearInfo();
				singleCard = null;
			}
			BattleInfoSnap.battlecardMouseenabled = true;
			
			if(targetSelectLabel && targetSelectLabel.parent)
				targetSelectLabel.parent.removeChild(targetSelectLabel);
			if(targetSelectLabel)
				targetSelectLabel.visible = false;
			
			allBattleCards = [];
		}
		
		public function makeCardCanWorkAtBeginning():void
		{
			var singleCardObj:BattleCardObject;
			for each(singleCardObj in availableCards)
			{
				if(singleCardObj)
				{
					singleCardObj.canUseInTheRound = true;
				}
			}
		}
		
		/**
		 * 处理新回合开始，加入卡片逻辑 
		 * @param round
		 */
		public function handlerNewRoundBegin(round:SingleRound):void
		{
			var i:int = 0;
			var singleCard:UserBattleCardInfo;
			var singleCardObj:BattleCardObject;
			if(curWaitCard.length == 0 && curWaitHeroCard.length == 0 && curWaitAoyiCard.length == 0)					//如果此时没有等待生效的卡牌
			{
				curTarget = {};
			}
			var illeageCards:Array = [];
			if(round.roundType == BattleDefine.nomalRound)
			{
				while(curWaitCard.length > 0)
				{
					singleCard = curWaitCard.pop() as UserBattleCardInfo;
					
					if(!checkIsCardIlegal(singleCard))
					{
						illeageCards.push(singleCard);
						continue;
					}
					
					singleCard && singleCard.makeCardWork();
					if(singleCard.uid == GlobalData.owner.uid)
					{
						GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,
							new Event(BattleEventTagFactory.getBattleCardUsedEventTag(singleCard.cardid)));
					}
				}
				curWaitCard = curWaitCard.concat(illeageCards);
				if(curWaitHeroCard.length == 0 && curWaitCard.length == 0 && curWaitAoyiCard.length == 0)
				{
					for each(singleCardObj in availableCards)
					{
						if(singleCardObj)
						{
							singleCardObj.canUseInTheRound = true;
						}
					}
				}
			}
			else if(round.roundType == BattleDefine.heroRound)
			{
				while(curWaitHeroCard.length > 0)
				{
					singleCard = curWaitHeroCard.pop() as UserBattleCardInfo;
					
					if(!checkIsCardIlegal(singleCard))
					{
						illeageCards.push(singleCard);
						continue;
					}
					
					singleCard && singleCard.makeCardWork();
					
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,
						new Event(BattleEventTagFactory.getBattleCardUsedEventTag(singleCard.cardid)));
				}
				curWaitHeroCard = curWaitHeroCard.concat(illeageCards);
				for each(singleCardObj in availableCards)			//英雄回合所有的卡牌不可用
				{
					if(singleCardObj)
					{
						singleCardObj.canUseInTheRound = false;
					}
				}
			}
			else if(round.roundType == BattleDefine.aoyiRound)
			{
				while(curWaitAoyiCard.length > 0)
				{
					singleCard = curWaitAoyiCard.pop() as UserBattleCardInfo;
					
					if(!checkIsCardIlegal(singleCard))
					{
						illeageCards.push(singleCard);
						continue;
					}
					
					singleCard && singleCard.makeCardWork();
					
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,
						new Event(BattleEventTagFactory.getBattleCardUsedEventTag(singleCard.cardid)));
				}
				curWaitAoyiCard = curWaitAoyiCard.concat(illeageCards);
				for each(singleCardObj in availableCards)			//英雄回合所有的卡牌不可用
				{
					if(singleCardObj)
					{
						singleCardObj.canUseInTheRound = false;
					}
				}
			}
		}
		
		public function handleAoYiHeroDead():void
		{
			var singleCard:UserBattleCardInfo;
			var singleCardObj:BattleCardObject;
			while(curWaitHeroCard.length > 0)
			{
				singleCard = curWaitHeroCard.pop() as UserBattleCardInfo;
				singleCard && singleCard.makeCardWork();
				
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,
					new Event(BattleEventTagFactory.getBattleCardUsedEventTag(singleCard.cardid)));
			}
		}
		
		public function checkIsCardIlegal(cardInfo:UserBattleCardInfo,needDeleteInfo:Boolean = true):Boolean
		{
			if(cardInfo == null)
				return false;
			if(!BattleModeDefine.checkNeedServerData())
			{
				return true;
			}
			var curRecord:Object = BattleInfoSnap.verifiedCardInfo;
			if(curRecord.hasOwnProperty(cardInfo.usercardid))
			{
				if(needDeleteInfo)
					delete curRecord[cardInfo.usercardid];
				return true;
			}
			return false;
		}
		
		/**
		 * 将选择的卡片加入到等待列表 
		 * @param cardInfo
		 */
		public function addCardToList(cardInfo:UserBattleCardInfo):void
		{
			if(cardInfo == null || cardInfo.skill == null)
				return;
			var effectArr:Array = cardInfo.skill.elements;	
			if(effectArr == null)
				return;
			var i:int = 0;
			var ii:int = 0;
			var singleSkillElement:SkillElement;
			var singleTarget:CellTroopInfo;
			var tempTargetArr:Array;
			
			if(cardInfo.worktype == i)
			{
				curWaitCard.push(cardInfo);
			}
			else if(cardInfo.worktype == BattleCardDefine.jinengKa)
			{
				curWaitHeroCard.push(cardInfo);
			}
			else if(cardInfo.worktype == BattleCardDefine.aoyiKa)
			{
				curWaitAoyiCard.push(cardInfo);
			}
			if(cardInfo.targetchoosetype != BattleCardDefine.shoudongXuanZe)				//非手动选择的需要计算技能目标
			{
				for(i = 0;i < effectArr.length;i++)
				{
					singleSkillElement = effectArr[i] as SkillElement;
					
					if(singleSkillElement)
					{
						var startIndex:int = 0;
						if(BattleManager.instance.battleMode == BattleModeDefine.PVP_Single)
						{
							var tempData:BDataPvpSingle = BattleHandler.instance.onLineManager.curbattledata as BDataPvpSingle;
							if(tempData)
							{
								if(GlobalData.owner.uid == tempData.attackuid)				//本方是攻击方
								{
									startIndex = 0;
								}
								else
								{
									var tempTroop:CellTroopInfo = BattleUnitPool.getCellFromSomeSide(BattleDefine.secondAtk);
									startIndex = tempTroop.troopIndex;
								}
							}
						}
						else if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi || BattleManager.instance.battleMode == BattleModeDefine.PVE_Raid)
						{
							startIndex = BattleUnitPool.getTroopFromSomeUser(cardInfo.uid);
						}
						tempTargetArr = BattleTargetSearcher.getTargetsForSomeRange(startIndex,singleSkillElement.target);
						
						//如果不是加血型的卡片，需要过滤重复目标
						if(cardInfo.cardtype != BattleCardTypeDefine.shiBingBuChong && cardInfo.cardtype != BattleCardTypeDefine.quanTiZengYuan)
						{
							tempTargetArr = BattleTargetSearcher.filterRepeatedTroops(tempTargetArr);
						}
						for(ii = 0; ii < tempTargetArr.length;ii++)
						{
							singleTarget = tempTargetArr[ii] as CellTroopInfo;
							if(singleTarget == null)
								continue;
							if(singleSkillElement.buffeid == SpecialEffectDefine.AoYiChuFa)
							{
								GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,
									BattleEventTagFactory.getHeroDeadTag(singleTarget.troopIndex),cardInfo.aoyiWaitHeroDead);
							}
							TroopDisplayFunc.showSmallCard(singleTarget,true);
						}
						curTarget[cardInfo.usercardid] = tempTargetArr;
						break;
					}
				}
			}
		}
		
		/**
		 * 获得某个troop等待生效的效果集合 
		 * @param troopIndex
		 * @return 
		 */
		public function getWaitEffectFromListWheckAttack(troopIndex:int):Array
		{
			var retValu:Array = cardEffectOnList[troopIndex] as Array;
			return retValu;
		}
		
		/**
		 * 让同样类型的卡片开始cd 
		 * @param type
		 */
		public function makeSameTypeStartCD(type:int):void
		{
			var singleCardObj:BattleCardObject;
			for(var i:int = 0;i < availableCards.length;i++)
			{
				singleCardObj = availableCards[i] as BattleCardObject;
				if(singleCardObj == null)
					continue;
				if(singleCardObj.contentCard.cardtype == type)
				{
					singleCardObj.initCDTImer(true);
				}
			}
		}
		
		/**
		 * 判断某种类型card是否在cd中 
		 * @param type
		 * @return 
		 */
		public function checkParticularTypeCardCding(type:int):Boolean
		{
			var retValue:Boolean = false;
			var singleCardObj:BattleCardObject;
			for(var i:int = 0;i < availableCards.length;i++)
			{
				singleCardObj = availableCards[i] as BattleCardObject;
				if(singleCardObj == null)
					continue;
				if(singleCardObj.contentCard.cardtype == type && singleCardObj.curStatus == BattleCardDefine.Card_CDing)
				{
					retValue = true;
					return retValue;
				}
			}
			return retValue;
		}
		
		/**
		 * 获得下一回合卡片的使用信息
		 * @return 
		 */
		public function getAllWaitingCardInfo():Array
		{
			var singleCardDataGroup:Array=[];
			var i:int = 0;
			var singleCardInfo:UserBattleCardInfo;
			
			var allWaitCard:Array = curWaitCard.concat(_curWaitHeroCard).concat(curWaitAoyiCard);
			
			for(i = 0;i < allWaitCard.length;i++)
			{
				singleCardInfo = allWaitCard[i] as UserBattleCardInfo;
				if(singleCardInfo == null || singleCardInfo.uid != GlobalData.owner.uid)
					continue;
				singleCardDataGroup.push(singleCardInfo.extractInfoForServer());
				singleCardDataGroup.push(getTargetTroopIndexArr(singleCardInfo.usercardid));
			}
			
			return singleCardDataGroup;
		}
		
		public function getTargetTroopIndexArr(userbattlecardId:int):Array
		{
			var troopIndexArr:Array=[];
			var targetArr:Array = curTarget[userbattlecardId] as Array;
			if(targetArr)
			{
				var singleTroopinfo:CellTroopInfo;
				for(var i:int = 0; i < targetArr.length;i++)
				{
					singleTroopinfo = targetArr[i] as CellTroopInfo;
					if(singleTroopinfo)
					{
						troopIndexArr.push(singleTroopinfo.troopIndex);
					}
				}
			}
			return troopIndexArr;
		}

		public function get curWaitHeroCard():Array
		{
			return _curWaitHeroCard;
		}

		public function set curWaitHeroCard(value:Array):void
		{
			_curWaitHeroCard = value;
		}
		
	}
}