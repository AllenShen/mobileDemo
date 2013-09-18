package modules.battle.battlelogic
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import animator.animatorengine.AnimatorEngine;
	import animator.animatorengine.AnimatorPlayer;
	import animator.animatorengine.AnimatorPlayerSwfBmpMix;
	import animator.resourceengine.ResType;
	
	import avatarsys.avatar.AvatarShow;
	import avatarsys.constants.AvatarDefine;
	import avatarsys.util.WeaponGenedEffectConfig;
	
	import caurina.transitions.Tweener;
	
	import defines.FormationSlotInfo;
	import defines.HeroDefines;
	
	import eventengine.GameEventHandler;
	
	import macro.ActionDefine;
	import macro.ArmDamageType;
	import macro.ArmType;
	import macro.AttackRangeDefine;
	import macro.BattleCardTypeDefine;
	import macro.BattleDisplayDefine;
	import macro.Color;
	import macro.EventMacro;
	import macro.FormationElementType;
	import macro.HeroType;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlecomponent.EffectIconSlots;
	import modules.battle.battlecomponent.HeroMoraleBar;
	import modules.battle.battlecomponent.HeroPortrait;
	import modules.battle.battlecomponent.HpBar;
	import modules.battle.battlecomponent.NextSupplyShow;
	import modules.battle.battledefine.BattleCompDefine;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleValueDefine;
	import modules.battle.battledefine.EffectShowTypeDefine;
	import modules.battle.battledefine.HeroAttackDisTypeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.McStatusDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battledefine.RandomValueService;
	import modules.battle.battledefine.SpecialTroopType;
	import modules.battle.battleevents.CheckAttackEvent;
	import modules.battle.battleevents.CheckComboEvent;
	import modules.battle.battleevents.DamageArrivedEvent;
	import modules.battle.battleevents.EffectSourceDeadEvent;
	import modules.battle.battleevents.EffectTroopNewRoundEvent;
	import modules.battle.battleevents.TroopDeadEvent;
	import modules.battle.battleevents.TroopStatusNeedEvent;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.battlelogic.skillandeffect.EffectOnCau;
	import modules.battle.funcclass.BattleCalculator;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.BattleManagerLogicFunc;
	import modules.battle.funcclass.ChainFunc;
	import modules.battle.funcclass.SkillEffectFunc;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.funcclass.TroopEffectDisplayFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.funcclass.TroopInitClearFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleScreenEffectFunc;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.managers.DemoManager;
	import modules.battle.showdatastructure.SingleDamageDisplayInfo;
	import modules.battle.stage.BattleStage;
	import modules.battle.utils.BattleEventTagFactory;
	
	import synchronousLoader.BattleResourceCopy;
	import synchronousLoader.ByteArrayFunc;
	import synchronousLoader.GameResourceManager;
	import synchronousLoader.LoadUnit;
	import synchronousLoader.ResourceConfig;
	import synchronousLoader.ResourcePool;
	
	import sysdata.Skill;
	import sysdata.SkillElement;
	
	import uipacket.previews.PreviewAnimator;
	
	import utils.BattleEffectConfig;
	import utils.TroopActConfig;
	import utils.TroopFrameConfig;
	import utils.Utility;
	
	/**
	 * cell中对应的信息,对应英雄或者士兵 包括表现层
	 * 战斗逻辑中参与计算的主要数据结构
	 * @author SDD
	 * 
	 */
	public class CellTroopInfo extends Sprite
	{
		
		public static var troopStaggerTimeOutEvent:String = "CellTroopStaggerTimeOut";
		
		private var _troopPlayerId:String = "";				//播放的playerid
		private var _avatarShowObj:AvatarShow;			//显示的avatarshow
		private var _heroShowObj:AnimatorPlayerSwfBmpMix;
		
		public var startPos:Point = new Point;				//一开始加进来的偏移量
		
		private var _mcIndex:int = -1;				//对应的动画index  用于取得帧数配置等
		
		private var _troopIndex:int;				//troop信息的index
		
		private var _mcStatus:int = 0;				//当前显示的状态，显示层   正在攻击，或者正在被攻击
		private var _logicStatus:int = 0;			//当前的逻辑状态，表示是否死亡等等
		public var isHeBing:Boolean = false;
		
		private var _occupiedCellStart:int;		//占用的格子,起点
		
		public var ownerSide:int = 0;			//是先手方还是后手方
		
		public var cellsCountNeed:Point = new Point;				//占用的格子数量，x轴和y轴方向的个数
		
		public var chainInvolved:CombatChain;			//此时所在的chain，在不同的chain中扮演不同的角色
		
		public var moraleValue:int = 0;					//士气值
		
		//以下是参与攻击计算的信息
		private var _attackUnit:AttackUnit;		//攻击的unit信息,提供所有加成后的数据  根据arm或者hero信息
		private var sourceFormationInfo:FormationSlotInfo;
		
		private var _curArmCount:int = 0;			//当前带兵量
		private var _curTroopHp:int = 0;			//当前的血量
		
		private var _effectOnAttack:Array;						//对进攻产生影响的buff
		private var _effectOnDefense:Array;						//对被进攻产生影响的buff
		private var _effectOnBothAtkDef:Array;					//对进攻，被进攻都产生影响的buff，a				
 		
		private var _kapianBufOnAttack:Array;					//对进攻产生影响的卡牌buff
		private var _kapianBufOnDefense:Array;					//被进攻时产生影响的卡牌buff	
		private var _kapianBufOnBothAtkDef:Array;				//对进攻，被进攻都产生影响的卡牌buff
		
		//此cell对应的英雄
		private var _allHeroArr:Array;
		private var _heroPropertyStore:Object={};
		
		private var _hpBar:HpBar;
		private var _moraleBar:HeroMoraleBar;
		private var _iconSlots:EffectIconSlots;
		public var selfHeroGuideArrow:PreviewAnimator;
		
		private var _effectObjBasesAddedToTroop:Object={};
		private var _specialEffects:Object={};					//此时参与计算的的effect		
		
		private var _heroDecreaseYUseTimer:Timer;
		
		private var _heroOffectValue:int = 0;				//hero troop的偏移量
		
		public var bottomLayer:Sprite;
		public var componentsLayer:Sprite;	
		public var mirrorLayer:Sprite;

		private var textshow:TextField;
		public var levelTextShow:TextField;
		public var curLevel:int = 1;
		
		public var isEffectChongdie:Boolean = false;
		
		//以下为测试用变量
		private var _waitDamageSource:int = -1;
		public var alldamageSource:Object={};
		public var beAtkCount:int = 0;
		public var needDispatchAtkEvent:Boolean = false;
		public var haveDispatchAtkEvent:Boolean = false; 
		
		private var _isTroopFanji:Boolean = false;				//当前是否在攻击				反击用
		public var isFirstOnTotalAtk:Boolean = false;			//是否为回调的第一个函数		反击用
		
		public var staggerTimer:Timer;
		public var staggerFrameCountLeft:int = 0;
		
		private var _isBusy:Boolean = false;
		
		public var slotIndex:int = 0;					//此formationslot在阵型中的索引，一维
		
		public static var globalTroopIndex:int = 0;				//全局的troopindex
		
		private var _isOnStaggerWait:Boolean = false;
		
		public var mappedHeroIndex:int = 0;
		public var curSelectedStatus:int = 0;
		
		public var supplyType:int = 0;
		public var stageBelong:int = 0;
		
		public function CellTroopInfo(troopIndex:int = 0)
		{
			this._troopIndex = troopIndex;
			_effectOnAttack =[];
			_effectOnDefense =[];
			_effectOnBothAtkDef =[];
			
			_kapianBufOnAttack =[];
			_kapianBufOnDefense =[];
			_kapianBufOnBothAtkDef =[];
			
			bottomLayer = new Sprite;
			bottomLayer.x = 0;
			bottomLayer.y = 0;
			this.addChild(bottomLayer);
			
			mirrorLayer = new Sprite;
			mirrorLayer.x = 0;
			mirrorLayer.y = 0;
			this.addChild(mirrorLayer);
			
			componentsLayer = new Sprite;
			componentsLayer.x = 0;
			componentsLayer.y = 0;
			this.addChild(componentsLayer);
			
			if(BattleManager.needDebugBattle)
			{
				this.graphics.clear();
				this.graphics.lineStyle(1,Color.redColor,1);
				this.graphics.drawRect(0,0,BattleDisplayDefine.cellWidth,BattleDisplayDefine.cellHeight);
				this.graphics.endFill();
				
				textshow = new TextField; 
				textshow.text = _troopIndex.toString();
				componentsLayer.addChild(textshow);
				textshow.textColor = 0xff00000;
			}
			
			levelTextShow = new TextField;
			levelTextShow.text = "1";
			componentsLayer.addChild(levelTextShow);
			levelTextShow.textColor = 0xff00000;
			
			levelTextShow.defaultTextFormat=new TextFormat(null,16)
			
			levelTextShow.visible = false;
			levelTextShow.x = 10;
			levelTextShow.y = 10;
		}
		
		public function set isOnStaggerWait(value:Boolean):void
		{
			_isOnStaggerWait = value;
		}

		public function setTroopIndex(troopIndex:int):void
		{
			this._troopIndex = troopIndex;	
			if(textshow)
				textshow.text = _troopIndex.toString();
		}
		
		/**
		 * 从formationSlot中初始化信息 
		 * @param info
		 */
		public function initDataFromSlot(formationInfo:FormationSlotInfo):void
		{
			if(formationInfo == null || formationInfo.type == FormationElementType.NOTHING)
				return;
			_attackUnit = new AttackUnit(formationInfo);
			this.cellsCountNeed = _attackUnit.sizeNeed;
			this.mcStatus = McStatusDefine.mc_status_idle;
			this.logicStatus = LogicSatusDefine.lg_status_idle;
			this.curArmCount = this.maxArmCount;			//初始化带兵量
			this.curTroopHp = this.maxTroopHp;				//初始化单个兵的血量
			this.supplyType = formationInfo.supplyType;
			
			if(formationInfo.type == FormationElementType.HERO)
			{
				this.cellsCountNeed = new Point(1,1);
			}
			
			this.sourceFormationInfo = formationInfo;
		}
		
		/**
		 *  初始化troop中具体的数据
		 */
		public function initTroopsStats():void
		{
			this.curArmCount = this.maxArmCount;			//初始化带兵量
			this.curTroopHp = this.maxTroopHp;				//初始化单个兵的血量
		}
		
		/**
		 * 初始化血条等可视信息 
		 */
		public function initViewInfo():void
		{
			isEffectChongdie = false;
			if(this.isHero && this.troopVisibleOnBattle)
			{
				if(this.attackUnit.contentHeroInfo != null && this.mcIndex > 0)
				{
//					if(_moraleBar == null)
//					{
//						_moraleBar = new HeroMoraleBar(this);
//						_moraleBar.y = BattleCompDefine.moraleBarOffsetY;
//						_moraleBar.x = 0;
//						componentsLayer.addChild(_moraleBar);
//						if(this.ownerSide == BattleDefine.firstAtk)
//						{
//							_moraleBar.x = BattleDisplayDefine.cellWidth - BattleCompDefine.moraleBarOffsetX - BattleCompDefine.moraleBarWidth + 15;
//						}
//						else
//						{
//							_moraleBar.x += BattleCompDefine.moraleBarOffsetX + BattleCompDefine.moraleBarWidth - 10 - 12;
//						}
//					}
//					componentsLayer.addChild(_moraleBar);
//					_moraleBar.initStatus();
//					
//					_moraleBar.visible = true;
				}
				
				_hpBar &&_hpBar.initStatus();
				_iconSlots && _iconSlots.initStatus();
			}
			else
			{
				if(_hpBar == null)
				{
					_hpBar = new HpBar(this);
					_hpBar.y = BattleCompDefine.hpBarOffsetY;
					_hpBar.x = 0;
					componentsLayer.addChild(_hpBar);
					if(this.ownerSide == BattleDefine.firstAtk)
					{
						_hpBar.x += (BattleDisplayDefine.cellWidth - BattleCompDefine.hpBarOffsetX - _hpBar.frameWidth)
					}
					else
					{
						_hpBar.x += BattleCompDefine.hpBarOffsetX;
					}
				}
				_hpBar.initStatus();
				
				if(_iconSlots == null)
				{
					_iconSlots = new EffectIconSlots(this);
					_iconSlots.x = 0;
					_iconSlots.y = -6;
					componentsLayer.addChild(_iconSlots);
				}
				_iconSlots.initStatus();
			}
			if(_hpBar)
			{
				if(BattleDefine.needShowHpBar)
				{
					_hpBar.visible = true;
				}
			}
		}
		
		/**
		 * troop鼠标事件 
		 * @param event
		 */
		public function troopMouseRollInHandler(event:MouseEvent):void
		{
			if(this.hpBar)
			{
				Tweener.removeTweens(this.hpBar);
				this.hpBar.alpha = 1;
//				this.hpBar.visible = true;
			}
		}
		
		/**
		 * 鼠标事件，移出
		 * @param event
		 */
		public function troopMouseRollOutHandler(event:MouseEvent):void
		{
			if(this.hpBar)
			{
				if(this.hpBar.isTimerRunning)
				{
					return;
				}
				else
				{
					this.hpBar.initMouseMoveOutTimer(true);
				}
			}
		}
		
		/**
		 * 增加动画某个动作播放完成的动作 			（普通逻辑）
		 * @param action				动作
		 * @param param					参数
		 * @param logital				是否为逻辑帧数
		 * @param sourceTroop			需要增加监听器的troop
		 */
		public function addMcFrameHandler(action:int,param:Array = null,logital:Boolean = false,sourceTroop:CellTroopInfo = null):void
		{
			var singleFrame:int = 0;
			var targetFrame:Array;
			var range:Point;
			if(logital)
			{
				targetFrame = TroopFunc.getActionMultipleFrames(this,action);
			}
			else
			{
				range = TroopFunc.getActionFrameRange(this,action);
				singleFrame = range.y;
			}
			
			var targetPlayerId:String = this.troopPlayerId;
			if(this.isPlayerHero)
			{
				targetPlayerId = this.avatarShowObj.getTargetPlayerId(action);
			}
			else if(this.isHero && this.heroShowObj)
			{
				targetPlayerId = this.heroShowObj.getPlayerIdByActionInfo(action);
			}
			
			if(param == null)
				param =[];
			
			var newParam:Array;
			
			var i:int = 0;
			
			var realTargetTroop:CellTroopInfo;
			if(sourceTroop == null)
			{
				realTargetTroop = this;
			}
			else
			{
				realTargetTroop = sourceTroop;
			}
			
			switch(action)
			{
				case ActionDefine.Action_Attack:							
				case ActionDefine.Action_Combo_Attack:
				case ActionDefine.Action_Dazhao:
				case ActionDefine.Action_Dazhao_Type2:
				case ActionDefine.Action_Dazhao_Type3:
				case ActionDefine.Action_AoYi:
				case ActionDefine.Action_Aoyi_Type2:
				case ActionDefine.Action_Aoyi_Type3:
					if(logital)
					{
						for(i = 0; i < targetFrame.length; i++)
						{
							singleFrame = targetFrame[i];
							newParam = [singleFrame].concat(param);
							AnimatorEngine.addHandlerForPlayer(targetPlayerId,singleFrame,realTargetTroop.onLogicAttackFrame,newParam,1);
						}
					}
					else
					{
						param.unshift(singleFrame);
						AnimatorEngine.addHandlerForPlayer(targetPlayerId,singleFrame,realTargetTroop.onTotalAttackFrame,param,1);
					}
					break;
				case ActionDefine.Action_defense:
					if(logital)
					{
						for(i = 0; i < targetFrame.length; i++)
						{
							singleFrame = targetFrame[i];
							newParam = [singleFrame].concat(param);
							AnimatorEngine.addHandlerForPlayer(targetPlayerId,singleFrame,realTargetTroop.onLogicDefenseFrame,newParam,1);
						}
					}
					else
					{
						param.unshift(singleFrame);
						AnimatorEngine.addHandlerForPlayer(targetPlayerId,singleFrame,realTargetTroop.onTotalDefenseFrame,param,1);
					}
					break;
				case ActionDefine.Action_Combo_Defense:
					break;
				case ActionDefine.Action_Dead:
					param.unshift(singleFrame);
					AnimatorEngine.addHandlerForPlayer(targetPlayerId,range.y,realTargetTroop.onHeroDeadFrame,param,1);
					break;
			}
		}
		
		/**
		 * 增加普通的事件坚挺函数 
		 * @param type
		 */
		public function addSinglePureHandler(type:int):void
		{
			var targetFrameIndex:int = 0;
			if(type == 0)
			{
				var sllFrames:Array = [];
				if(this.isPlayerHero)
				{
					sllFrames = TroopFrameConfig.getAoyiEffectFrame(this.mcIndex);
					var targetEffect:int = WeaponGenedEffectConfig.getAoYiEffect(avatarShowObj.avatarConfig);
					var logicFrames:Array = BattleEffectConfig.getAllLogiccalFrames(targetEffect);
					var avatarTargetFrame:Array = TroopFunc.getActionMultipleFrames(this,ActionDefine.Action_AoYi);
					if(avatarTargetFrame && avatarTargetFrame.length > 0)
					{
						var singleFrame:int = avatarTargetFrame[0];
						for(var index:int = 0;index < logicFrames.length;index++)
						{
							sllFrames[index] = logicFrames[index] + singleFrame;
						}
					}
				}
				else
				{
					sllFrames = TroopFrameConfig.getAoyiEffectFrame(this.mcIndex);
				}
				
				var targetPlayerId:String = this.troopPlayerId;
				if(this.isPlayerHero)
				{
					targetPlayerId = this.avatarShowObj.getTargetPlayerId(ActionDefine.Action_AoYi);
				}
				else if(this.isHero)
				{
					targetPlayerId = this.heroShowObj.getPlayerIdByActionInfo(ActionDefine.Action_AoYi);
				}
				for each(targetFrameIndex in sllFrames)
				{
					AnimatorEngine.addHandlerForPlayer(targetPlayerId,targetFrameIndex,onHeroAoyiEffectFrame,[targetFrameIndex],1);
				}
			}
		}
		
		/**
		 * 判断是否补进
		 * @param gap
		 */
		public function checkNeedFill(event:Event):void
		{
			GameEventHandler.removeListener(EventMacro.DAMAGE_WAIT_HANDELR,
				BattleEventTagFactory.getWaitForTroopBeIdleTag(this),checkNeedFill);
			//检查是否可以补进
			BattleManagerLogicFunc.checkTroopDeadFill(this);
		}
		
		/**
		 *  查看是否能够攻击 
		 *  如果能，进行攻击
		 */
		public function checkAttack():Boolean
		{
			//如果此cell已经攻击过
			if(TroopFunc.isCellAttackedInRound(this.occupiedCellStart))
			{
				return false;
			}		
//			if(isHero && this.ownerSide == BattleDefine.firstAtk)
//			{
//				if((this.attackUnit.contentHeroInfo == null || this.logicStatus == LogicSatusDefine.lg_status_dead) && !BattleInfoSnap.hasHeroRecalled)
//				{
//					var liveCount:int = BattleTargetSearcher.getTroopCountOfSomeHero(this,BattleManager.instance.pSideAtk);
//					if(liveCount > 0)
//					{
//						BattleInfoSnap.hasHeroRecalled = true;
//						FakeFormationLineMaker.makeFakeHeroTroop(this);
//						TroopDisplayFunc.initShowInfo(this);
//						this.visible = true;
//						this.alpha = 1;
//						
//						BattleStage.instance.troopLayer.addTroopToStage(this,this.ownerSide == BattleDefine.firstAtk);
//						
//						this.logicStatus = LogicSatusDefine.lg_status_idle;
//						this.mcStatus = McStatusDefine.mc_status_idle;
//						
//						BattleStage.instance.troopLayer.findHeroRecallPos(this);
//					}
//					return false;
//				}
//			}
			
			if(this.isHero && (!this.visible || this.attackUnit == null || this.attackUnit.contentHeroInfo == null))
				return false;

			isTroopFanji = false;
			isFirstOnTotalAtk = false;
			
			//标记此cell已经攻击过(不管是否真正攻击成功,也不管是否是可攻击单位)
			TroopFunc.setOccupiedCellStatus(this,OtherStatusDefine.hasAttacked);
			
			if(!this.troopVisibleOnBattle)
			{
				return false;
			}
			
			if(this.logicStatus == LogicSatusDefine.lg_status_dead)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				return false;
			}
			//此时troop已经死了，不应该有此逻辑
			if(!this.isHero && this.attackUnit.slotType != FormationElementType.ARROW_TOWER && this.totalHpValue == 0)
			{
				this.logicStatus = LogicSatusDefine.lg_status_dead;
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				return false;
			}
			
			var canAttack:Boolean = isAttackTroop;
			var isZhongdu:Boolean = false;
			var isCritical:Boolean = false;
			var isAoyi:Boolean = false;					//是否为奥义攻击
			var aoyiFeizhengdui:Object = {};
			
			var heroTargetCell:Cell;
			var aoyiTargetTroop:CellTroopInfo;
			var targetPos:Point;
			var canUseYValue:Boolean;
			var allDangQianGongjiTroops:Dictionary = new Dictionary;				//当前所有的正在攻击目标
			
			//有攻击的权利，回合增加，让此cell产生的effect回合减少
			
//			if(this.logicStatus == LogicSatusDefine.lg_status_waitForDamage)
//			{
//				if(this.waitDamageSource < 0 || this.alldamageSource == null)
//				{
//					this.logicStatus = LogicSatusDefine.lg_status_idle;					//正在等待攻击，但是没有攻击方信息
//				}
//				else 
//				{
//					var atkTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(waitDamageSource);
//					if(atkTroop == null || atkTroop.logicStatus == LogicSatusDefine.lg_status_dead)
//					{
//						this.logicStatus = LogicSatusDefine.lg_status_idle;
//					}
//				}
//				
//				trace("celltroopo",this.troopIndex,"攻击失败");
//			}
			
			canAttack = canAttack && isMcOnCanAttackStatus;
			
			var currentAttackRange:int = 0;
			var curAtkDistance:int = 0;
			
			if(!isMcOnCanAttackStatus)			//如果是因为状态不对，则当成是没有检查过,此时清空错开时间 
			{
				TroopFunc.setOccupiedCellStatus(this,OtherStatusDefine.hasNotAttack);
				return true;
			}
			
			//其他逻辑
			//查看是否能够攻击
			if(TroopFunc.hasSpecificEffect(this,SpecialEffectDefine.XuanYun))
			{
				if(BattleInfoSnap.getCurLianjiIndex(this.troopIndex) == 0)		//如果当前是第一次攻击,受到影响，否则认为本回合不受影响
				{
					canAttack = false;
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectTroopNewRoundEvent(troopIndex));
					return canAttack;
				}
			}
			
			if(TroopFunc.hasSpecificEffect(this,SpecialEffectDefine.ZhongDu))
			{
//				trace("中毒的");
				isZhongdu = true;
			}
			
			var targets:Array=[];
			var youZhengDuiMuBiao:Boolean = false;				//是否有正对目标
			var seekTargetTroopIndex:int = this.troopIndex;
			//预先判断是否存在攻击目标
			if(canAttack && !isHero)
			{
				currentAttackRange = this.attackUnit.attackRange;
				curAtkDistance = this.attackUnit.attackDistance;
				targets = BattleTargetSearcher.getTargetsForSomeRange(troopIndex,this.attackUnit.attackRange,curAtkDistance,null,currentAttackRange,allDangQianGongjiTroops);
				if(targets == null || targets.length == 0)						//没有找到目标，可能是距离不够等原因
				{
					//检查本回合是否有其他攻击
					canAttack = false;
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectTroopNewRoundEvent(troopIndex));
					
//					if(BattleManager.needTraceBattleInfo)
//						trace(troopIndex,"发动攻击失败","，当前帧数: ",BattleInfoSnap.curBattleFrame,"没有找到目标");
					//没有攻击目标，检查回合是否结束
					return canAttack;
				}
			}
			
			var heroFujiaGongjiXiuZheng:Number = 0;
			var singleSkillInfo:Skill;
			if(canAttack && isHero)
			{
				isAoyi = BattleInfoSnap.isAoYiRound;
				if(isAoyi)
				{
					if(BattleManager.aoyiManager.isCurHeroPlayAoyi(this))
					{
						singleSkillInfo = SkillEffectFunc.newSkillForAoYi(this);
					}
					else			//当前其他英雄正在进行奥义播放
					{
						TroopFunc.setOccupiedCellStatus(this,OtherStatusDefine.hasNotAttack);
						return true;
					}
				}
				else
				{
					singleSkillInfo = SkillEffectFunc.getHeroSkillOnAttack(this);
				}
				
				var atackEffect:SkillElement = SkillEffectFunc.getParticularEffect(singleSkillInfo,SpecialEffectDefine.FuJiaGongJi);
				if(atackEffect == null)
				{
					canAttack = false;
					return false;
				}
				heroFujiaGongjiXiuZheng = atackEffect.buffValue;
				currentAttackRange = atackEffect.target;
				youZhengDuiMuBiao = HeroAttackDisTypeDefine.checkRangeHasDirectTarget(currentAttackRange);
				
				if(isAoyi)
				{
					var singleTroop:CellTroopInfo = BattleTargetSearcher.getHeroInFomationCenter(this);
					seekTargetTroopIndex = singleTroop.troopIndex;
					targets = BattleTargetSearcher.getTargetsForSomeRange(seekTargetTroopIndex,currentAttackRange,100,null,currentAttackRange,allDangQianGongjiTroops);
				}
				else
				{
					targets = BattleTargetSearcher.getTargetsForSomeRange(troopIndex,currentAttackRange,100,null,currentAttackRange,allDangQianGongjiTroops);
				}
				
				if(targets == null || targets.length == 0)						//没有找到目标，可能是距离不够等原因
				{
					//检查本回合是否有其他攻击
					canAttack = false;
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectTroopNewRoundEvent(troopIndex));
					//没有攻击目标，检查回合是否结束
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
					return canAttack;
				}
				//将带有伤害输出增加的目标保存起来
			}
			
			var heroOffsetindex:int = 0;
			var heorattackRange:int = 0;
//			if(this.isHero && canAttack)
//			{
//				if(!BattleInfoSnap.isAoYiRound && this.moraleValue < BattleValueDefine.moraleGapToSkillAttack)			//士气不足
//				{
//					canAttack = false;
//				}
//			}
			if(this.isHero && canAttack)
			{
				heorattackRange = this.attackUnit.attackRange;
				heorattackRange = AttackRangeDefine.dantiGongJi;
				if(isAoyi)						
				{
					canUseYValue = true;
					heroTargetCell = BattleTargetSearcher.getHeroAoyiTargetCell(this);
					
					var tempTargetTroop:CellTroopInfo;
					if(youZhengDuiMuBiao)
					{
						tempTargetTroop = targets[0] as CellTroopInfo;
					}
					if(tempTargetTroop)
					{
						heroTargetCell = BattleTargetSearcher.getFakeHeroAoyiTargetCell(this,tempTargetTroop);
						aoyiTargetTroop = tempTargetTroop;
					}
					else
					{
						var tempCell:Cell = BattleTargetSearcher.getHeroMoveTarget(this,heorattackRange);
						aoyiTargetTroop = tempCell.troopInfo;
					}
					targetPos = BattleTargetSearcher.getRowColumnByCellIndex(heroTargetCell.index);
					BattleInfoSnap.aoyiTroopTargetCellInfo[this.troopIndex] = heroTargetCell.index;
				}
				else
				{
					heroTargetCell = BattleTargetSearcher.getHeroMoveTarget(this,heorattackRange);
					if(heroTargetCell.troopInfo)//y值偏移
						heroOffsetindex = BattleTargetSearcher.getCellYIndex(BattleUnitPool.getCellInfo(this.occupiedCellStart),heroTargetCell.troopInfo);
					else
						heroOffsetindex = 0;
					
					targetPos = BattleTargetSearcher.getRowColumnByCellIndex(heroTargetCell.troopInfo.occupiedCellStart);
					targetPos.y += heroOffsetindex;
					canUseYValue = BattleStage.instance.troopLayer.checkUserCanMoveOnYValue(targetPos.y,this.ownerSide,this.troopIndex);
				}
				if(!canUseYValue)		//如果不能攻击
				{
					TroopFunc.setOccupiedCellStatus(this,OtherStatusDefine.hasNotAttack);
					this.logicStatus = LogicSatusDefine.lg_status_waitForPath;
					//当前不能使用,增加监听器
					GameEventHandler.addListener(EventMacro.DAMAGE_WAIT_HANDELR,
						BattleEventTagFactory.getWaitForSomeYPath(targetPos.y),BattleStage.instance.troopLayer.yPathBeFree,
						[this]);
					
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectTroopNewRoundEvent(troopIndex));
					
					return true;
				}
				
			}
			
			var i:int = 0;
			var effectArr:Array;
			if(canAttack)
			{
				var singleChain:CombatChain;
				
				//处理影响战斗的数值
				
				var tempCellTroopInfo:CellTroopInfo;
				var chainsOnSingleAttack:Object={};					//默认攻击产生的chain 这部分chain，可能会受到一些技能的影响
				
				var chainsInOrder:Array=[];							//保存此次攻击产生的所有chain，按照加入顺序排序
				
				for(i = 0; i < targets.length;i++)				//检索看是否在补进
				{
					tempCellTroopInfo = targets[i] as CellTroopInfo;
					if(tempCellTroopInfo && tempCellTroopInfo.logicStatus == LogicSatusDefine.lg_status_filling)	//如果目标中有人正在补进
					{
						TroopFunc.setOccupiedCellStatus(this,OtherStatusDefine.hasNotAttack);
						canAttack = false;
						return true;
					}
				}
				
				if(BattleInfoSnap.checkAttackLianjiOver(this))					
				{
					if(RandomValueService.getRandomValue(RandomValueService.RD_BAOJI,this.troopIndex) < this.critalRate)		//暴击
					{
						isCritical = true;
						if(BattleInfoSnap.needControlBattle)
							isCritical = false;
					}	
				}
				else														//连击情形下不进行暴击判断
				{
					isCritical = BattleInfoSnap.getLianjiCritInfo(this.troopIndex);
				}
				
				var fakeCurObj:Dictionary = new Dictionary();
				
				for(i = 0; i < targets.length;i++)
				{
					tempCellTroopInfo = targets[i] as CellTroopInfo;
					if(tempCellTroopInfo)
					{
						singleChain = BattleManager.instance.curRound.addChainToRound(this,tempCellTroopInfo,false,heroFujiaGongjiXiuZheng);
						
						var existedChainInfo:CombatChain = chainsOnSingleAttack[tempCellTroopInfo.troopIndex] as CombatChain;
						if(existedChainInfo == null)						//如果当前没有此目标的chain
						{
							chainsOnSingleAttack[tempCellTroopInfo.troopIndex] = singleChain;
							chainsInOrder.push(singleChain);
							existedChainInfo = singleChain;
						}
						else
						{
							existedChainInfo.absordOtherChainInfo(singleChain);
							existedChainInfo.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,heroFujiaGongjiXiuZheng + 1,0,troopIndex,this),true);
							existedChainInfo.chainDamageTimes++;
						}
						
						var curEffFromAtk:Array = [];
						for(var ceaIndex:int = 0;ceaIndex < singleChain.effFromAtk.length;ceaIndex++)
						{
							curEffFromAtk.push(singleChain.effFromAtk[ceaIndex]);
						}
						
						//处理带有 光环N连击  吸血   伤害反弹等光环效果的buff
						for(var eindex:int = 0;eindex < curEffFromAtk.length;eindex++)
						{
							var existedEffectOnCau:EffectOnCau = curEffFromAtk[eindex];
							if(existedEffectOnCau.effectId == SpecialEffectDefine.shengmingHuiFu)
							{
								this.resolveDamageDisplayInfo(0 - this.totalHpOfSlot * existedEffectOnCau.effectValue,troopIndex);
								TroopEffectDisplayFunc.showBattleCardEffect(this,BattleCardTypeDefine.shiBingBuChong);
								continue;
							}
							if(SpecialEffectDefine.checkAddToSelfForceWhenGuanghuang(existedEffectOnCau.effectId))				//如果是作为光环技能的时候需要强制加的，也就是带有具体逻辑的buff
							{
								fakeCurObj = new Dictionary();
								fakeCurObj[tempCellTroopInfo] = 1;
								var tempGuanghuanTarget:Array = BattleTargetSearcher.getTargetsForSomeRange(seekTargetTroopIndex,existedEffectOnCau.sourceEffectObject.effectTarget,curAtkDistance,this,currentAttackRange,fakeCurObj);
								if(existedEffectOnCau.effectId == SpecialEffectDefine.NLianJi)				
								{
									BattleInfoSnap.updateTroopLianjiInfo(this.troopIndex,existedEffectOnCau.sourceEffectObject);
								}
								for(var tgtIndex:int = 0;tgtIndex < tempGuanghuanTarget.length;tgtIndex++)
								{
									var tempTroopInfo:CellTroopInfo = tempGuanghuanTarget[tgtIndex];
									if(tempTroopInfo.troopIndex == this.troopIndex)							//伤害输出增加，作用在自己身上	
									{
										singleChain = chainsOnSingleAttack[tempTroopInfo.troopIndex];
										if(!singleChain)																
										{
											singleChain = BattleManager.instance.curRound.addChainToRound(this,tempTroopInfo,true);
											chainsOnSingleAttack[this.troopIndex] = singleChain;
											chainsInOrder.push(singleChain);
										}
										singleChain.addEffectFromAtkOrDefense(existedEffectOnCau.sourceEffectObject.getCureffect(tempTroopInfo.troopIndex),true);
									}
									else
									{
										singleChain = chainsOnSingleAttack[tempTroopInfo.troopIndex];
										
										var canAdd1:Boolean = true;
										if(singleChain && existedEffectOnCau.sourceEffectObject.effectId == SpecialEffectDefine.FuJiaGongJi)
										{
											if(targets.indexOf(tempTroopInfo.troopIndex) >= 0)
											{
												canAdd1 = false;
												//直接增加伤害输出增加的修正值  effectValue
												singleChain.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,existedEffectOnCau.sourceEffectObject.effectValue,0,this.troopIndex,this),true);
											}
										}
										if(canAdd1)
										{
											if(!singleChain)																//如果这个troop没有被攻击
											{
												singleChain = BattleManager.instance.curRound.addChainToRound(this,tempTroopInfo,true);
												chainsOnSingleAttack[tempTroopInfo.troopIndex] = singleChain;
												chainsInOrder.push(singleChain);
											}
											if(existedEffectOnCau.sourceEffectObject.effectId == SpecialEffectDefine.FuJiaGongJi)				//附加攻击需要默认加上伤害输出值
											{
												//直接增加伤害输出增加的修正值  effectValue
												singleChain.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,existedEffectOnCau.sourceEffectObject.effectValue,0,this.troopIndex,this),true);
												allDangQianGongjiTroops[tempTroopInfo] = 1;		//增加当前攻击目标
											}
											else
												singleChain.addEffectFromAtkOrDefense(existedEffectOnCau.sourceEffectObject.getCureffect(tempTroopInfo.troopIndex),true);							//增加攻击效果   类型是effect
										}
									}
								}
							}
						}
						
						if(!this.isHero)		//普通单位获得攻击次数
							existedChainInfo.maxAttackTimes = TroopFunc.getUnitAttackCount(this,ActionDefine.Action_Attack);
						if(isCritical)
							existedChainInfo.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.BaoJi,1,0,this.troopIndex,this),true);
						
						allDangQianGongjiTroops[tempCellTroopInfo] = 1;
					}
				}
				
				if(isCritical)		//如果暴击，进行士气加成
				{
					this.changeHeroMorale(BattleValueDefine.Attack_Critcal);
				}
				
				//获得攻击的时候产生的效果,必须是连击中第一次攻击
				if(!this.isHero && BattleInfoSnap.getCurLianjiIndex(this.troopIndex) == 0)
					singleSkillInfo = SkillEffectFunc.getArmSkillOnAttack(this);
				
				//减少此troop发出技能的回合数
				if(BattleInfoSnap.getCurLianjiIndex(this.troopIndex) == 0)
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectTroopNewRoundEvent(troopIndex));
				
				var curLianjieRatio:Number;
				var shanghaiZengjiaEffect:Array=[];										//特殊处理伤害输出增加的效果，影响所有的chain
				var skillIdadded:Boolean = false;
				var singleEffect:BattleSingleEffect;
				var targetTroopArr:Array;
				var tt:int = 0;
				var targetTroop:CellTroopInfo;
				var tempEffectOnCau:EffectOnCau;
				if(singleSkillInfo)												//存在新的技能
				{
					var targetIndexObj:Object={};			//正对目标troopindex集合
					for(var tempCheckIndex:int = 0;tempCheckIndex < targets.length;tempCheckIndex++)
					{
						targetTroop = targets[tempCheckIndex];
						targetIndexObj[targetTroop.troopIndex] = 1;
					}
//					trace(this.troopIndex,"触发了主动技能",singleSkillInfo.skillid);
					effectArr = SkillEffectFunc.getFiltedBattleSingleEffects(singleSkillInfo);
					if(this.isHero)
					{
						for(i = 0; i < effectArr.length;i++)				//遍历当前的目标，找到伤害输出的攻击目标 
						{
							singleEffect = effectArr[i] as BattleSingleEffect;
							if(singleEffect && singleEffect.effectId == SpecialEffectDefine.ShangHaiShuChuZengJia)
							{
								if(this.isHero && singleEffect)
									continue;
								currentAttackRange = singleEffect.effectTarget;
							}
						}
					}
					var needSkipFuJiaGongji:Boolean = false;
					if(this.isHero)
					{
						needSkipFuJiaGongji = true;
					}
					for(i = 0; i < effectArr.length;i++)
					{
						singleEffect = effectArr[i];
						if(singleEffect)
						{
							//英雄不处理此逻辑			这是英雄攻击本来的基本伤害输出
							if(singleEffect.effectId == SpecialEffectDefine.ShangHaiShuChuZengJia && this.isHero && singleEffect.effectTarget == AttackRangeDefine.woFangZiJi)
								continue;
							if(singleEffect.effectId == SpecialEffectDefine.FuJiaGongJi)		//跳过第一个附加攻击，因为此effect已经取过
							{
								if(this.isHero && needSkipFuJiaGongji)
								{
									needSkipFuJiaGongji = false;
									continue;
								}
							}
							singleEffect.effectSourceTroop = this.troopIndex;
							targetTroopArr = BattleTargetSearcher.getTargetsForSomeRange(seekTargetTroopIndex,singleEffect.effectTarget,curAtkDistance,this,currentAttackRange,allDangQianGongjiTroops);
							if(singleEffect.effectId == SpecialEffectDefine.NLianJi)				
							{
								BattleInfoSnap.updateTroopLianjiInfo(this.troopIndex,singleEffect);
							}
							
							for(tt = 0; tt < targetTroopArr.length; tt++)
							{
								targetTroop = targetTroopArr[tt] as CellTroopInfo;
								if(targetTroop)
								{
									if(targetTroop.troopIndex == this.troopIndex)							//伤害输出增加，作用在自己身上	
									{
										if(singleEffect.effectId == SpecialEffectDefine.ShangHaiShuChuZengJia)
										{
											shanghaiZengjiaEffect.push(singleEffect);
										}
									
										singleChain = chainsOnSingleAttack[targetTroop.troopIndex];
										if(!singleChain)																
										{
											singleChain = BattleManager.instance.curRound.addChainToRound(this,targetTroop,true);
											chainsOnSingleAttack[this.troopIndex] = singleChain;
											chainsInOrder.push(singleChain);
										}
										singleChain.addEffectFromAtkOrDefense(singleEffect.getCureffect(targetTroop.troopIndex),true);
									}
									else
									{
										singleChain = chainsOnSingleAttack[targetTroop.troopIndex];
										
										var canAdd:Boolean = true;
										if(singleChain && singleEffect.effectId == SpecialEffectDefine.FuJiaGongJi)
										{
											if(targetIndexObj.hasOwnProperty(targetTroop.troopIndex))
											{
												canAdd = false;
												//直接增加伤害输出增加的修正值  effectValue   此时需要和1进行修正  ，提前将值修正完毕
												singleChain.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,singleEffect.effectValue + 1,0,this.troopIndex,this),true);
											}
										}
										if(canAdd)
										{
											if(!singleChain)																//如果这个troop没有被攻击
											{
												singleChain = BattleManager.instance.curRound.addChainToRound(this,targetTroop,true);
												chainsOnSingleAttack[targetTroop.troopIndex] = singleChain;
												chainsInOrder.push(singleChain);
												if(singleEffect.effectId == SpecialEffectDefine.FuJiaGongJi)
													singleChain.isFujiaGongJiChain = true;
											}
//											singleChain.addEffectFromAtkOrDefense(singleEffect.getCureffect(targetTroop.troopIndex),true);							//增加攻击效果   类型是effect
											if(singleEffect.effectId == SpecialEffectDefine.FuJiaGongJi)				//附加攻击需要默认加上伤害输出值
											{
												//如果当前是附加攻击，并且此chain中没有输出增加
												if(!singleChain.isFujiaGongJiChain && !ChainFunc.hasSomeNewGeneratedEffect(singleChain,SpecialEffectDefine.ShangHaiShuChuZengJia,false))
												{
													singleChain.isFujiaGongJiChain = true;
												}
												
												if(!allDangQianGongjiTroops[targetTroop])
												{
													allDangQianGongjiTroops[targetTroop] = 1;
													singleChain.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,singleEffect.effectValue,0,this.troopIndex,this),true);
												}
												else
												{
													singleChain.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,singleEffect.effectValue + 1,0,this.troopIndex,this),true);
												}
											}
											else
											{
												singleChain.addEffectFromAtkOrDefense(singleEffect.getCureffect(targetTroop.troopIndex),true);							//增加攻击效果   类型是effect
											}
//											allDangQianGongjiTroops[targetTroop] = 1;		//增加当前攻击目标
											if(isAoyi)
											{
												aoyiFeizhengdui[targetTroop.troopIndex] = 1;
											}
										}
									}
									if(!skillIdadded)				//保存此回合攻击方发出的技能
									{
										skillIdadded = true;
										singleChain.atkSkillId.push(singleSkillInfo.skillid);
									}
								}
							}
						}
					}
					for(i = 0;i < shanghaiZengjiaEffect.length;i++)		//特殊处理伤害输出增加情形，只对本来就有攻击的chain有效
					{
						singleEffect = shanghaiZengjiaEffect[i] as BattleSingleEffect;
						for each(singleChain in chainsOnSingleAttack)
						{
							if(SkillEffectFunc.checkCanBeEvade(singleChain))	//如果此chain带有伤害
							{
								if(singleChain.isFujiaGongJiChain)
									continue;
								tempEffectOnCau = singleEffect.getCureffect(this.troopIndex);
								tempEffectOnCau.effectDuration = 0;
								singleChain.addEffectFromAtkOrDefense(tempEffectOnCau,true);
								if(!skillIdadded)				//保存此回合攻击方发出的技能
								{
									skillIdadded = true;
									singleChain.atkSkillId.push(singleSkillInfo.skillid);
								}
							}
						}
					}
					curLianjieRatio = BattleInfoSnap.getCurLianjiValue(this.troopIndex);
					for each(singleChain in chainsOnSingleAttack)
					{
						if(SkillEffectFunc.checkCanBeEvade(singleChain) && !singleChain.isSkillAtk)	//如果此chain带有伤害
						{
							tempEffectOnCau = EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,curLianjieRatio,
							0,-1,this);
							singleChain.addEffectFromAtkOrDefense(tempEffectOnCau,true);
						}
					}
				}
				else
				{
					curLianjieRatio = BattleInfoSnap.getCurLianjiValue(this.troopIndex);
					for each(singleChain in chainsOnSingleAttack)
					{
						if(SkillEffectFunc.checkCanBeEvade(singleChain) && !singleChain.isSkillAtk)	//如果此chain带有伤害
						{
							tempEffectOnCau = EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,curLianjieRatio,
								0,-1,this);
							singleChain.addEffectFromAtkOrDefense(tempEffectOnCau,true);
						}
					}
				}
				
				if(!this.isHero)
				{
					//等待是否击中
					GameEventHandler.addListener(EventMacro.OTHER_WAIT_HANDLER,BattleEventTagFactory.waitAttackGotHit(this.troopIndex),checkHit);
					
					var bossattackeffect:int = TroopActConfig.getBossAttackEffect(this.mcIndex);
					if(bossattackeffect > 0 && singleSkillInfo != null)			//条件满足时不管类型
					{
						TroopDisplayFunc.playBossAttackEffect(this,bossattackeffect,chainsInOrder);
					}
					else if(this.attackUnit.armtype == ArmType.magic || this.attackUnit.armtype ==  ArmType.machine)
					{
						if(!TroopDisplayFunc.playMagicMachineAttackEffects(this,chainsInOrder))
						{
							return false;
						}
					}
					else
					{
						if(bossattackeffect <= 0 || singleSkillInfo == null)
						{
							for(i = 0; i < chainsInOrder.length; i++)				//按照顺序执行chain
							{
								singleChain = chainsInOrder[i];
								if(singleChain)
								{
									singleChain.makeChainWork(null,i == 0);
								}
							}
						}
						else
						{
							TroopDisplayFunc.playBossAttackEffect(this,bossattackeffect,chainsInOrder);
						}
					}
					if(skillIdadded)
						TroopEffectDisplayFunc.showSingleNormalEffect(this,this,EffectShowTypeDefine.VariousEffect_XiaoBingJiNeng);
				}
				else
				{
					if(!BattleInfoSnap.isAoYiRound)						//奥义不消耗士气
						this.changeHeroMorale(0 - this.moraleValue);
//					initTimeGapTimer(true);
					GameEventHandler.addListener(EventMacro.OTHER_WAIT_HANDLER,
						BattleEventTagFactory.heroWaitForTimeGap(this.troopIndex),decreaseYPathUseCount,[targetPos.y]);
					
					var heroEffectResId:int = 0;
					var singleEffectOnSingleTarget:int = 0;
					var effectAttacktimes:int = 1;
					if(!isAoyi)
					{
						var powerSide:PowerSide = BattleFunc.getSidePowerInfoForTroop(this);
						var disOnselfSide:int = powerSide.xMaxValue - 1;
						var targetEffectType:int = HeroAttackDisTypeDefine.getAttackTypeByDisRange(disOnselfSide,heorattackRange);
						if(youZhengDuiMuBiao)				//如果正对目标的话，选择效果波
						{
							if(this.isPlayerHero)			//是玩家英雄
							{
								heroEffectResId = WeaponGenedEffectConfig.getHeroAttackEffect(this.avatarShowObj.avatarConfig,targetEffectType);
								singleEffectOnSingleTarget = WeaponGenedEffectConfig.getHeroAttackSingleEffect(this.avatarShowObj.avatarConfig);
							}
							else
							{
								heroEffectResId = TroopActConfig.getHeroAttackEffect(this.mcIndex,targetEffectType);
								singleEffectOnSingleTarget = TroopActConfig.getHeroAttackSingleEffect(this.mcIndex);
							}
							effectAttacktimes = BattleEffectConfig.getAttackTimesOfEffect(heroEffectResId);
						}
						else
						{
							if(this.isPlayerHero)			//是玩家英雄
							{
								heroEffectResId = WeaponGenedEffectConfig.getHeroAttackEffect(this.avatarShowObj.avatarConfig,targetEffectType);
								singleEffectOnSingleTarget = WeaponGenedEffectConfig.getHeroAttackSingleEffect(this.avatarShowObj.avatarConfig);
							}
							else
							{
								heroEffectResId = TroopActConfig.getHeroAttackEffect(this.mcIndex,targetEffectType);
								singleEffectOnSingleTarget = TroopActConfig.getHeroAttackSingleEffect(this.mcIndex);
							}
							effectAttacktimes = BattleEffectConfig.getAttackTimesOfEffect(singleEffectOnSingleTarget);
						}
					}
					else
					{
						if(youZhengDuiMuBiao)
						{
							if(this.isPlayerHero)
							{
								heroEffectResId = WeaponGenedEffectConfig.getAoYiEffect(this.avatarShowObj.avatarConfig);
								singleEffectOnSingleTarget = WeaponGenedEffectConfig.getAoYiAttackSingleEffect(this.avatarShowObj.avatarConfig);
							}
							else
							{
								heroEffectResId = TroopActConfig.getAoYiEffect(this.mcIndex);
								singleEffectOnSingleTarget = TroopActConfig.getAoYiAttackSingleEffect(this.mcIndex);
							}
							effectAttacktimes = BattleEffectConfig.getAttackTimesOfEffect(heroEffectResId);
						}
						else				//奥义没有正对目标
						{
							if(this.isPlayerHero)
							{
								heroEffectResId = WeaponGenedEffectConfig.getAoYiEffect(this.avatarShowObj.avatarConfig);
								singleEffectOnSingleTarget = WeaponGenedEffectConfig.getAoYiAttackSingleEffect(this.avatarShowObj.avatarConfig);
							}
							else
							{
								heroEffectResId = TroopActConfig.getAoYiEffect(this.mcIndex);
								singleEffectOnSingleTarget = TroopActConfig.getAoYiAttackSingleEffect(this.mcIndex);
							}
							effectAttacktimes = BattleEffectConfig.getAttackTimesOfEffect(singleEffectOnSingleTarget);
						}
						
						var totalTargets:Array = [];
						var tempAoyiTarget:CellTroopInfo;
						for(var rIndex:int = 0;rIndex < targets.length;rIndex++)
						{
							tempAoyiTarget = targets[rIndex];
							if(tempAoyiTarget)
							{
								delete aoyiFeizhengdui[tempAoyiTarget.troopIndex];
								totalTargets.push(tempAoyiTarget);
							}
						}
						for(var rCheckIndex:String in aoyiFeizhengdui)
						{
							tempAoyiTarget = BattleUnitPool.getTroopInfo(int(rCheckIndex));
							if(tempAoyiTarget)
								totalTargets.push(tempAoyiTarget);
						}
						
						TroopDisplayFunc.makeUnInvolvedTroopHideOnAoYi(totalTargets,this);
						TroopDisplayFunc.makeAoyiTargetAlphaDown(totalTargets);
					}
					
					for(i = 0; i < chainsInOrder.length; i++)				//按照顺序执行chain,设置攻击次数
					{
						singleChain = chainsInOrder[i];
						if(singleChain && SkillEffectFunc.checkCanBeEvade(singleChain) && !singleChain.isSkillAtk)
						{
							singleChain.maxAttackTimes = effectAttacktimes;
						}
					}
					
					var parmas:Array = [this,heroTargetCell,chainsInOrder,heroOffsetindex,heroEffectResId,targets,youZhengDuiMuBiao,singleEffectOnSingleTarget,aoyiTargetTroop];
					if(!isAoyi)
					{
						BattleStage.instance.troopLayer.makeHeroMoveToTarget(parmas);
					}
					else
					{
						BattleStage.instance.troopLayer.makeHeroMoveToAoYiPos(parmas);
					}
				}
				
				BattleInfoSnap.increaseAttackStep(this.troopIndex);
				if(!BattleInfoSnap.checkAttackLianjiOver(this))
				{
					if(isCritical)
						BattleInfoSnap.addCrictInfo(this.troopIndex);
					TroopFunc.setOccupiedCellStatus(this,OtherStatusDefine.hasNotAttack);
				}
			}
			else					// 如果不能攻击
			{
				//减少此troop发出技能的回合数
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectTroopNewRoundEvent(troopIndex));
				
				if(isZhongdu)					//如果中毒了  需要保存中毒的效果
				{
					var fakeChain:CombatChain = BattleManager.instance.curRound.addFakeChainToRound(this);
					if(fakeChain)
					{
						//如果当前是眩晕不能攻击，加入眩晕
						if(TroopFunc.hasSpecificEffect(this,SpecialEffectDefine.XuanYun))
						{
							fakeChain.addExistedEffect(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.XuanYun,0),true);
						}
						
						//取得所有的中毒信息
						effectArr = TroopFunc.getExistedParticularEffectsForTroop(this,SpecialEffectDefine.ZhongDu,true);
						for(i = 0;i <  effectArr.length;i++)
						{
							var singleEff:EffectOnCau = effectArr[i] as EffectOnCau;
							fakeChain.addExistedEffect(singleEff,true);
						}
					}
					this.atkReactToChain(fakeChain);					//播放中毒特效
				}
				
//				GameEventHandler.dispatchGameEvent(BattleEventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				
			}
			if(BattleManager.needTraceBattleInfo)
			{
				if(canAttack)
				{
					trace(troopIndex,"发动攻击","，当前帧数: ",BattleInfoSnap.curBattleFrame);
				}
			}
			return canAttack;
		}
		
		/**
		 * 让事件进行反击 
		 * @param event
		 * @param param
		 */
		public function makeTroopFanji(event:Event = null,params:Array = null):void
		{
			//移除监听器
			if(event)
			{
				GameEventHandler.removeListener(EventMacro.DAMAGE_WAIT_HANDELR,event.type,makeTroopFanji);
			}
			if(params == null || params.length < 1)
			{
				return;
			}
			var fanjiChain:CombatChain = params.shift();
//			var fanJiResult:int = fanjiChain.makeFanjiChainWork(params);
//			if(fanJiResult == BattleDefine.fanjiChain_fail)
//			{
//				if(BattleManager.needTraceBattleInfo)
//					trace("状态不对，导致反击失败",'反击者: ',fanjiChain.atkTroopIndex," 当前帧数:",BattleInfoSnap.curBattleFrame);
//				BattleManager.instance.curWaitFanjiChain[fanjiChain.chainIndex] = params;				//保存是否进行反击
//				return;
//			}
			BattleManager.instance.curWaitFanjiChain[fanjiChain.chainIndex] = params;	
			
			return;
			if(BattleManager.needTraceBattleInfo)
			{
				if(event != null)
				{
					trace("因为事件","反击"," 当前帧数:",BattleInfoSnap.curBattleFrame,'反击者: ',
						fanjiChain.atkTroopIndex,"被反击者: ",fanjiChain.defTroopIndex);
				}
				else
				{
					trace("没有事件","反击"," 当前帧数:",BattleInfoSnap.curBattleFrame,'反击者: ',
						fanjiChain.atkTroopIndex,"被反击者: ",fanjiChain.defTroopIndex);
				}
			}
		}
		
		/**
		 * 等待判断是否命中 
		 * @param event
		 */
		private function checkHit(event:Event):void
		{
			GameEventHandler.removeListener(EventMacro.OTHER_WAIT_HANDLER,event.type,checkHit);
			if(!this.isHero)
				this.changeHeroMorale(BattleValueDefine.Attack_Morale);
		}
		
		/**
		 * 减少某个ypath上的使用情形 
		 * @param event
		 */
		public function decreaseYPathUseCount(event:Event,yValue:int):void
		{
			BattleStage.instance.troopLayer.decreaseYPathUsedCount(yValue,this.troopIndex);
		}
		
		/**
		 * 初始化时间差等待timer 
		 * @param needInit
		 */
		private function initTimeGapTimer(needInit:Boolean = true):void
		{
			if(_heroDecreaseYUseTimer)
			{
				_heroDecreaseYUseTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,heroWaitTimeUp);
				_heroDecreaseYUseTimer.stop();
				_heroDecreaseYUseTimer = null;
			}
			if(needInit)
			{
				_heroDecreaseYUseTimer = new Timer(BattleDisplayDefine.heroReleasePathTime,1);
				_heroDecreaseYUseTimer.addEventListener(TimerEvent.TIMER_COMPLETE,heroWaitTimeUp);
				_heroDecreaseYUseTimer.start();
			}
		}
		
		/**
		 * 等待时间完成 
		 * @param event
		 */
		public function heroWaitTimeUp(event:TimerEvent = null):void
		{
			GameEventHandler.dispatchGameEvent(EventMacro.OTHER_WAIT_HANDLER,
				new Event(BattleEventTagFactory.heroWaitForTimeGap(this.troopIndex)));
		}
		
		/**
		 * 播放chain中的攻击动画 
		 * @param chain
		 * 
		 */
		public function playCellAtkVedio(chain:CombatChain):void
		{
			if(isAttackTroop)
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectTroopNewRoundEvent(troopIndex));
			
			this.logicStatus = LogicSatusDefine.lg_status_attack;
			this.playAction(ActionDefine.Action_Attack);
		}
		
		/**
		 * 承受攻击
		 */
		public function bearAttack(chainInfo:CombatChain):void
		{
			if(chainInfo == null)
				return;
			if(this.attackUnit == null)
				return;
			if(this.logicStatus == LogicSatusDefine.lg_status_forceDead || this.logicStatus == LogicSatusDefine.lg_status_dead)
				return;
			
			var isFanji:Boolean = false;
			
			this.chainInvolved = chainInfo;				//从这条chain传来攻击信息
			this.beAtkCount++;
			
			var atkTroopInfo:CellTroopInfo = chainInfo.sourceTroop;
			
			var i:int = 0;
			var singleEffect:BattleSingleEffect;	
			var effectCurrentChain:Boolean = true;											//是否对此次攻击产生影响
			
//			isFanji = ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.FanJi,true);
			isFanji = chainInfo.isFanjiChain;
			
			var defenseGenedChain:Object={};			//被攻击的一方产生的被动技能效果
			var canBeEvade:Boolean = SkillEffectFunc.checkCanBeEvade(chainInfo);							//此次攻击是否带有伤害
			if(canBeEvade)																	
			{
				var hit:Boolean = true;
				var canGenerateBeiDongJiNeng:Boolean = true;
				
				if(!atkTroopInfo.isHero)		//英雄攻击是不能闪避的
				{
					var hasJueDuiMingzhong:Boolean = false;
					var effectValueArr:Array = ChainFunc.getAllEffectWorkOnTargetOrSource(chainInfo,SpecialEffectDefine.jueduiMingZhong,false);
					if(effectValueArr != null && effectValueArr.length > 0)
						hasJueDuiMingzhong = true;
					
					//只有没眩晕,绝对命中 的情形下才能判断是否可以闪避,
					if(!hasJueDuiMingzhong && !TroopFunc.hasSpecificEffect(this,SpecialEffectDefine.XuanYun))
					{
						if(!BattleInfoSnap.needControlBattle && RandomValueService.getRandomValue(RandomValueService.RD_DUOBI,this.troopIndex,chainInfo.atkTroopIndex) < this.evadeRate)				//躲避了
						{
							chainInfo.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShanBi,0,0,this.troopIndex,this),false);	
							hit = false;
						}
					}
					else
					{
						canGenerateBeiDongJiNeng = false;						//能否触发被动技能
					}
					if(TroopFunc.hasSpecificEffect(this,SpecialEffectDefine.XuanYun))
						canGenerateBeiDongJiNeng = false;
				}
				else
				{
					canGenerateBeiDongJiNeng = false;
				}
				if(chainInfo.curAtkCount > 1)			//只有第一次打击的时候才能产生被动技能触发判定
					canGenerateBeiDongJiNeng = false;
				
				if(isFanji)
					canGenerateBeiDongJiNeng = false;
				
				//命中 触发各种特效  造成伤害   
				if(hit)
				{
					if(!atkTroopInfo.isHero)
						changeHeroMorale(BattleValueDefine.Defense_Morale);
					
					GameEventHandler.dispatchGameEvent(EventMacro.OTHER_WAIT_HANDLER,
						new Event(BattleEventTagFactory.waitAttackGotHit(atkTroopInfo.troopIndex)));
					
					var defEffects:Array = TroopFunc.effectingAffection(this,false,atkTroopInfo.isHero);							//获得自己身上所有影响攻击的效果值
					for(i = 0; i < defEffects.length;i++)
					{
						chainInfo.addEffectFromAtkOrDefense(defEffects[i] as EffectOnCau,false,false);
						
						//如果在实时战斗
						while(chainInfo.needShowEffectOnAttackFrame.length > 0)
						{
							var singleEffect2:int = chainInfo.needShowEffectOnAttackFrame.pop();
							TroopEffectDisplayFunc.showSkillElementEffect(this,singleEffect2);
						}
					}
					
					var singleDefChain:CombatChain;
					
					var singleSkillInfo:Skill = SkillEffectFunc.newSkillGeneratedOnDefense(this,chainInfo,isFanji,canGenerateBeiDongJiNeng);		//被动技能
					var idAdded:Boolean = false;
					if(singleSkillInfo)													//存在新的技能
					{
						if(BattleManager.needTraceBattleInfo)
						{
							trace(this.troopIndex,"触发被动技能: ",singleSkillInfo.skillid);
						}
						var effectArr:Array = SkillEffectFunc.getFiltedBattleSingleEffects(singleSkillInfo);
						for(i = 0; i < effectArr.length;i++)
						{
							singleEffect = effectArr[i];
							if(singleEffect)
							{
								if(atkTroopInfo.isHero)
								{
									if(!BattleFunc.checkEffectCanBeUsedWhenAttackedByHero(singleEffect.effectId))
										continue;
								}
								
								singleEffect.effectSourceTroop = this.troopIndex;
									
								var targetTroopArr:Array = BattleTargetSearcher.getTargetsForSomeRange(troopIndex,singleEffect.effectTarget,0,atkTroopInfo);
								for each(var targetTroop:CellTroopInfo in targetTroopArr)
								{
									if(targetTroop && targetTroop.isAttackedTroop)
									{
										//反击技能特殊处理，只支持正对的反击
										if(singleEffect.effectId == SpecialEffectDefine.FanJi)
										{
											var targetPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(targetTroop.occupiedCellStart);
											var sourcePos:Point = BattleTargetSearcher.getRowColumnByCellIndex(this.occupiedCellStart);
											var targetMax:int = targetPos.y + targetTroop.cellsCountNeed.y - 1;
											var selfMax:int = sourcePos.y + this.cellsCountNeed.y - 1;
											var hasJiaoJi:Boolean = false;
											for(var ic:int = targetPos.y; ic <= targetMax; ic++)
											{
												if((ic > sourcePos.y || ic == sourcePos.y) && (ic < selfMax || ic == selfMax))
												{
													hasJiaoJi = true;
													break;
												}
											}
											if(!hasJiaoJi)
												continue;
										}
										
										//如果作用在自己身上
										if(this.troopIndex == targetTroop.troopIndex)
										{
											chainInfo.addEffectFromAtkOrDefense(singleEffect.getCureffect(targetTroop.troopIndex),false);
										}
										else
										{
											singleDefChain = BattleManager.instance.curRound.addChainWhenAttacked(this,targetTroop);
											if(singleDefChain)
											{
												if(!idAdded)
												{
													idAdded = true;
													singleDefChain.defSkillId.push(singleSkillInfo.skillid);
												}
												singleDefChain.preChain = chainInfo.chainIndex;
												
												var singleChainExisted:CombatChain = defenseGenedChain[targetTroop.troopIndex] as CombatChain;
												if(!defenseGenedChain.hasOwnProperty(targetTroop.troopIndex))
												{
													defenseGenedChain[targetTroop.troopIndex] = singleDefChain;
												}
												else
												{
													singleChainExisted = defenseGenedChain[targetTroop.troopIndex] as CombatChain;
												}
												
												singleDefChain.addEffectFromAtkOrDefense(singleEffect.getCureffect(targetTroop.troopIndex),true);
												if(singleEffect.effectId == SpecialEffectDefine.FanJi)			//反击默认加上伤害增加技能
												{
													singleDefChain.isFanjiChain = true;
//													trace(this.troopIndex,"反击了",targetTroop.troopIndex);
													singleDefChain.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,0,0,this.troopIndex,this),true);
												}
												else if(targetTroop.troopIndex == chainInfo.atkTroopIndex && singleEffect.effectId == SpecialEffectDefine.ShangHaiShuChuZengJia)
												{
													//被动技能中产生了伤害输出的技能，影响本次攻击
													var tempEff:EffectOnCau = singleEffect.getCureffect(targetTroop.troopIndex);
													tempEff.effectDuration = 0;
												}
												
												if(singleChainExisted)
													singleChainExisted.absordOtherChainInfo(singleDefChain);				//加入此被动技能产生的chain 
											}
										}
									}
								}
							}
						}
					}
					chainInfo.damageBaseValue = BattleCalculator.getSingleDamageValue(atkTroopInfo,this,chainInfo);		//进攻产生的基本值
				}
				else
				{
					if(!atkTroopInfo.isHero)
					{
						atkTroopInfo.changeHeroMorale(BattleValueDefine.Attack_Miss_Attack);
						changeHeroMorale(BattleValueDefine.Attack_Miss_Target);				//闪避之后士气增加
					}
				}
			}
			
			this.defReactToChain(chainInfo,defenseGenedChain);
		}
		
		/**
		 * 被攻击的troop对chain作出反应    具体数据变化
		 * 播放被攻击动画 
		 * @param chainInfo				
		 * @param defGenedEffects		被攻击方产生的效果
		 */
		public function defReactToChain(chainInfo:CombatChain,defGenedEffects:Object = null):void
		{
			if(chainInfo == null)
				return;
			
			var atkTroopInfo:CellTroopInfo = chainInfo.sourceTroop;
			var damageShowInfo:SingleDamageDisplayInfo = chainInfo.getSingleAttackDamageInfo(chainInfo.curAtkCount);	//伤害值以及影响信息
			
			var damageValue:int = 0;
			var effectArr:Array=[];					//某个类型的所有effect
			var singleEff:EffectOnCau;							//单个effect
			
			if(ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.ShanBi,true) || 
				ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.weiMingZhong,true) || 
				ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.ShangHaiShuChuZengJia,false))			//伤害增加
			{
				if(ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.ShanBi,true))
				{
					TroopEffectDisplayFunc.showSkillElementEffect(this,EffectShowTypeDefine.EffectShow_Shanbi);
				}
				else if(ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.weiMingZhong,true))
				{
					TroopEffectDisplayFunc.showSkillElementEffect(this,EffectShowTypeDefine.EffectShow_Weimingzhong);
				}
				else if(SkillEffectFunc.checkCanBeEvade(chainInfo))	//伤害增加
				{	
					//表现伤害   包括所有百分比显示的伤害             包括伤害增加 + 附加攻击
					
//					trace("troop ",this.troopIndex," chainIndex: ",chainInfo.chainIndex,"完成","攻击方:",chainInfo.atkTroopIndex);
					var realDamage:int = damageShowInfo.finalDamageValue;
					
					var selfPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(occupiedCellStart);
					var allPercent:Number = 0;
					var eIndex:int = 0;
					if(selfPos.x != 0)										//非第一排，需要检查第一排伤害吸收
					{
						if(ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.shanghaiXiShou,true))
						{
							var sourcePowerside:PowerSide = this.ownerSide == BattleDefine.firstAtk ? BattleManager.instance.pSideAtk : BattleManager.instance.pSideDef;
							var frontTroop:CellTroopInfo = BattleFunc.getTroopFrontOfSelf(selfPos.y,sourcePowerside);
							if(frontTroop)
							{
								effectArr = ChainFunc.getAllEffectWorkOnTargetOrSource(chainInfo,SpecialEffectDefine.shanghaiXiShou,true);
								for(eIndex = 0;eIndex < effectArr.length;eIndex++)
								{
									singleEff = effectArr[eIndex];
									if(singleEff == null)
										continue;
									allPercent += singleEff.effectValue;
								}
								allPercent = Math.min(allPercent,1);
								
								//第一排去承受伤害
								frontTroop.shareDamageFromMates(damageShowInfo.finalDamageValue *　allPercent,this.troopIndex);
								if(frontTroop.logicStatus == LogicSatusDefine.lg_status_dead || frontTroop.logicStatus == LogicSatusDefine.lg_status_hangToDie)
									TroopFunc.handleDeadTroopLogic(frontTroop);
								
								realDamage = damageShowInfo.finalDamageValue * (1 - allPercent);
								realDamage = Math.max(realDamage,0);
							}
						}
					}
					else
					{
						shareDamageFromMates(realDamage,chainInfo.atkTroopIndex);			//第一排直接判断是否有墙
						realDamage = 0;
					}
					
					resolveDamageDisplayInfo(realDamage,chainInfo.atkTroopIndex);
//					trace(this.troopIndex,"受到来自"+chainInfo.atkTroopIndex+"的伤害",realDamage,"当前血量:",
//						this.totalHpValue,"原始血量为:",this.originalTotalHpValue,"chain的基本伤害量为:",chainInfo.damageBaseValue,
//					"伤害值系数为:",damageShowInfo.bonusRatio);
				}
				
				if(this.logicStatus == LogicSatusDefine.lg_status_hangToDie)
				{
					if(chainInfo.curAtkCount >= chainInfo.maxAttackTimes)
					{
						this.logicStatus = LogicSatusDefine.lg_status_dead;
						TroopFunc.handleDeadTroopLogic(this);
					}
				}
				
				if(this.logicStatus != LogicSatusDefine.lg_status_dead)
				{
					if(this.logicStatus == LogicSatusDefine.lg_status_hangToDie)
					{
						TroopFunc.handleDeadTroopLogic(this);
					}
					//只有在空闲或者等待攻击的情况下才能播放攻击动画
					if(this.mcStatus != McStatusDefine.mc_status_attacking && this.mcStatus != McStatusDefine.mc_status_attack_combo)
					{
						if(this.mcStatus != McStatusDefine.mc_status_running)
						{
							if(chainInfo.curAtkCount >= chainInfo.maxAttackTimes)
								this.alldamageSource[chainInfo.chainIndex] = 1;
							
							atkTroopInfo.onLogicDefenseFrame([0,chainInfo.chainIndex,chainInfo.curAtkCount,chainInfo.maxAttackTimes]);
							atkTroopInfo.onTotalDefenseFrame([0,chainInfo.chainIndex,chainInfo.curAtkCount,chainInfo.maxAttackTimes]);
						}
						else				//当前正在补进
						{
							if(chainInfo.curAtkCount < chainInfo.maxAttackTimes)				//攻击没有完成
							{
								GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckComboEvent(BattleEventTagFactory.geneChainCheckEvent(chainInfo.chainIndex)));//发出消息是否继续攻击
							}
							else
							{
								this.alldamageSource[chainInfo.chainIndex] = 1;
							}
						}
						isEffectChongdie = !isEffectChongdie;
					}
					else
					{
						//此时troop正在攻击,不改变任何状态
//						this.logicStatus = LogicSatusDefine.lg_status_idle;
						this.alldamageSource[chainInfo.chainIndex] = 1;
						if(this.logicStatus != LogicSatusDefine.lg_status_attack)
							this.setIdleStatusSecure();
						GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneChainCheckEvent(chainInfo.chainIndex),chainInfo.checkChainComboInfo);
						GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckComboEvent(BattleEventTagFactory.geneChainCheckEvent(chainInfo.chainIndex)));//发出消息是否继续攻击
					}
					if(!isEffectChongdie)
						TroopEffectDisplayFunc.showSingleNormalEffect(chainInfo.sourceTroop,this,EffectShowTypeDefine.EffectShow_BeiDaJi);
					else
						TroopEffectDisplayFunc.showSingleNormalEffect(chainInfo.sourceTroop,this,EffectShowTypeDefine.EffectShow_SecondBeiDaJi);
					
				}
				else					//troop死亡
				{
					this.alldamageSource[chainInfo.chainIndex] = 1;
					TroopEffectDisplayFunc.showSingleNormalEffect(chainInfo.sourceTroop,this,EffectShowTypeDefine.EffectShow_BeiDaJi);
					
					//如果在不在攻击动画播放状态
					if(this.mcStatus != McStatusDefine.mc_status_attacking && this.mcStatus != McStatusDefine.mc_status_attack_combo && this.mcStatus != ActionDefine.Action_defense)
					{
						this.logicStatus = LogicSatusDefine.lg_status_defend;
						this.playAction(ActionDefine.Action_defense);
					}
					this.logicStatus = LogicSatusDefine.lg_status_dead;
					TroopFunc.handleDeadTroopLogic(this);
				}
			}
			else
			{
				//直接承受伤害，不需要依赖帧事件
				this.alldamageSource[chainInfo.chainIndex] = 1;
				if(this.logicStatus != LogicSatusDefine.lg_status_attack && this.mcStatus != McStatusDefine.mc_status_attacking)
					this.setIdleStatusSecure();
			}
			
			var oldStatus:int = this.logicStatus;
			
			if(chainInfo.curAtkCount <= 1 && ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.XiXue,true))				//吸血
			{
//				trace("吸血");
				effectArr = ChainFunc.getAllEffectWorkOnTargetOrSource(chainInfo,SpecialEffectDefine.XiXue,true);
				for(var e:int = 0; e < effectArr.length; e++)
				{
					singleEff = effectArr[e] as EffectOnCau;
					if(singleEff == null)
						continue;
					var xiXueLiang:int = damageShowInfo.finalDamageValue * singleEff.effectValue;		//吸血量
					atkTroopInfo.resolveDamageDisplayInfo(0 - xiXueLiang,chainInfo.atkTroopIndex);
//					trace(this.troopIndex,"吸血"+xiXueLiang,"当前血量:",this.totalHpValue);
					break;
				}
				TroopEffectDisplayFunc.showEffcetOnTroopCenter(atkTroopInfo,EffectShowTypeDefine.EffectShow_JiaXue);
				TroopEffectDisplayFunc.showEffcetOnTroopCenter(this,EffectShowTypeDefine.EffectShow_DiaoXue);
			}
			if(chainInfo.curAtkCount <= 1 && ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.ZengJianHP,true))		//增减HP
			{
//				trace("增减HP");
				var totalNum:int = 0;
				effectArr = ChainFunc.getAllEffectWorkOnTargetOrSource(chainInfo,SpecialEffectDefine.ZengJianHP,true);
				for each(singleEff in effectArr)
				{
					this.resolveDamageDisplayInfo(0 - singleEff.effectValue * this.totalHpValue,chainInfo.atkTroopIndex);
//					trace(this.troopIndex,"HP增减"+singleEff.effectValue * this.maxArmCount,"当前血量:",this.totalHpValue);
					totalNum += singleEff.effectValue * this.maxArmCount;
				}
				if(totalNum >= 0)
				{
					TroopEffectDisplayFunc.showEffcetOnTroopCenter(this,EffectShowTypeDefine.EffectShow_JiaXue);
				}
				else
				{
					TroopEffectDisplayFunc.showEffcetOnTroopCenter(this,EffectShowTypeDefine.EffectShow_DiaoXue);
				}
			}
			if(chainInfo.curAtkCount <= 1 && ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.ShiQiZengJia,true))		//士气增加
			{
//				trace("士气增加");
				effectArr = ChainFunc.getAllEffectWorkOnTargetOrSource(chainInfo,SpecialEffectDefine.ShiQiZengJia,true);
				for each(singleEff in effectArr)
				{
					this.changeHeroMorale(singleEff.effectValue);
				}
			}
			if(chainInfo.curAtkCount <= 1 && ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.ShangHaiFanTan,true))		//伤害反弹
			{
//				trace("伤害反弹");
				effectArr = ChainFunc.getAllEffectWorkOnTargetOrSource(chainInfo,SpecialEffectDefine.ShangHaiFanTan,true);
				var percentInfo:Number = 0;
				for each(singleEff in effectArr)
				{
					percentInfo += 1 + singleEff.effectValue;
				}
				percentInfo = Math.min(percentInfo,1);
				if(percentInfo != 0)
				{
//					this.resolveDamageDisplayInfo(0 - percentInfo * damageShowInfo.finalDamageValue,chainInfo.atkTroopIndex);
					
					chainInfo.sourceTroop.resolveDamageDisplayInfo(Math.abs(percentInfo * damageShowInfo.finalDamageValue),chainInfo.defTroopIndex);
					TroopEffectDisplayFunc.showSingleNormalEffect(this,chainInfo.sourceTroop,EffectShowTypeDefine.EffectShow_BeiDaJi);
					
					if(chainInfo.sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)
					{
						if(chainInfo.sourceTroop.logicStatus == LogicSatusDefine.lg_status_hangToDie || chainInfo.sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)
						{
							TroopFunc.handleDeadTroopLogic(chainInfo.sourceTroop);
						}
					}
					
//					trace(this.troopIndex,"伤害增加伤害","当前血量:",this.totalHpValue,"当前血量:",this.totalHpValue);
				}
			}
			
			if(BattleManager.instance.status != OtherStatusDefine.battleOn)
				return;
			
			//将攻击方所有buff加入到target
			var allAddedEffects:Array;
			allAddedEffects = chainInfo.effFromAtk;
			var singtargetTroop:CellTroopInfo;
			var singleEffectToAdd:BattleSingleEffect;
			var singleAttackGenedEffectOnCau:EffectOnCau;
			if(allAddedEffects)
			{
				for each(singleAttackGenedEffectOnCau in allAddedEffects)
				{
					if(singleAttackGenedEffectOnCau && singleAttackGenedEffectOnCau.effectDuration > 0 && singleAttackGenedEffectOnCau.effectDuration < BattleDefine.guanghuangDurationOnCheck)
					{
						singtargetTroop = BattleUnitPool.getTroopInfo(singleAttackGenedEffectOnCau.effectTarget);
						
						singleEffectToAdd = new BattleSingleEffect;
						singleEffectToAdd.effectId = singleAttackGenedEffectOnCau.effectId;
						singleEffectToAdd.effectSourceTroop = chainInfo.atkTroopIndex;
						singleEffectToAdd.effectTarget = singleAttackGenedEffectOnCau.effectTarget;
						singleEffectToAdd.effectDuration = singleAttackGenedEffectOnCau.effectDuration;
						singleEffectToAdd.effectValue = singleAttackGenedEffectOnCau.pureEffectValue;
						TroopFunc.addSingleBuff(singtargetTroop,singleEffectToAdd);
					}
				}
			}
			
			var defEffects:Array = chainInfo.effFromDef;
			if(defEffects)
			{
				for each(singleAttackGenedEffectOnCau in defEffects)
				{
					if(singleAttackGenedEffectOnCau && singleAttackGenedEffectOnCau.effectDuration > 0 )
					{
						singtargetTroop = BattleUnitPool.getTroopInfo(singleAttackGenedEffectOnCau.effectTarget);
						
						singleEffectToAdd = new BattleSingleEffect;
						singleEffectToAdd.effectId = singleAttackGenedEffectOnCau.effectId;
						singleEffectToAdd.effectSourceTroop = chainInfo.defTroopIndex;
						singleEffectToAdd.effectTarget = singleAttackGenedEffectOnCau.effectTarget;
						singleEffectToAdd.effectDuration = singleAttackGenedEffectOnCau.effectDuration;
						singleEffectToAdd.effectValue = singleAttackGenedEffectOnCau.pureEffectValue;
						TroopFunc.addSingleBuff(singtargetTroop,singleEffectToAdd);
					}
				}
			}
			
			
			//以上处理伤害的逻辑会导致troop状态变化
			
			if(this.logicStatus != LogicSatusDefine.lg_status_dead && this.logicStatus != LogicSatusDefine.lg_status_hangToDie)
			{
				if(defGenedEffects)		//处理此次攻击新产生的被动技能
				{
					var fanjiChain:CombatChain = null;
					var singleDefGenedChain:CombatChain;
				
					singleDefGenedChain = defGenedEffects[chainInfo.atkTroopIndex] as CombatChain;			//获得包含反击效果的chain信息
					if(singleDefGenedChain != null && singleDefGenedChain.targettroop.logicStatus != LogicSatusDefine.lg_status_dead
						&& singleDefGenedChain.sourceTroop.logicStatus != LogicSatusDefine.lg_status_dead)
					{
						if(ChainFunc.hasSomeNewGeneratedEffect(singleDefGenedChain,SpecialEffectDefine.FanJi,true))
						{
							fanjiChain = singleDefGenedChain;
						}
					}
					
					var waitFanjiChains:Array=[];			//等待反击动作帧数工作的chain
					for(var singleTroopIndex:String in defGenedEffects)
					{
						singleDefGenedChain = defGenedEffects[singleTroopIndex] as CombatChain;
						if(singleDefGenedChain == null || singleDefGenedChain.targettroop.logicStatus == LogicSatusDefine.lg_status_dead
							|| singleDefGenedChain.sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)
							continue;
						if(fanjiChain)
						{
							if(fanjiChain.chainIndex != singleDefGenedChain.chainIndex)
								waitFanjiChains.push(singleDefGenedChain);
						}
						else
							singleDefGenedChain.makeDefGenedChainWork();
					}
					
					//如果有反击的chain，加上监听器
					if(fanjiChain)
					{
						waitFanjiChains.unshift(fanjiChain);
						if(this.mcStatus == McStatusDefine.mc_status_idle)
						{
							fanjiChain.targettroop.makeTroopFanji(null,waitFanjiChains);
						}
						else
						{
							GameEventHandler.addListener(EventMacro.DAMAGE_WAIT_HANDELR,
								BattleEventTagFactory.waitForFanJi(troopIndex),fanjiChain.targettroop.makeTroopFanji,waitFanjiChains);
						}
					}
				}
			}
			else
			{
				if(oldStatus != LogicSatusDefine.lg_status_dead && oldStatus != LogicSatusDefine.lg_status_hangToDie)
				{
					TroopFunc.handleDeadTroopLogic(this);
				}
			}
		}
		
		/**
		 * fade结束 
		 */
		public function selfFadeOver():void
		{
			this.visible = false;
		}
		
		/**
		 * 攻击的troop对chain作出反应   播放攻击方带来的特效，攻击方中毒，增加英雄士气
		 * @param chainInfo   攻击对应的chain信息
		 */
		public function atkReactToChain(chainInfo:CombatChain):void
		{
			//如果攻击方被中毒了
			var effArr:Array;
			var singleEffectOnCau:EffectOnCau;
			if(TroopFunc.hasSpecificEffect(this,SpecialEffectDefine.ZhongDu,true))
			{
				if(BattleInfoSnap.zhongduCauInfo.hasOwnProperty(this.troopIndex))
					return;
				BattleInfoSnap.zhongduCauInfo[this.troopIndex] = 1;
				effArr = TroopFunc.getExistedParticularEffectsForTroop(this,SpecialEffectDefine.ZhongDu,true);
				for each(singleEffectOnCau in effArr)
				{
					TroopEffectDisplayFunc.showEffcetOnTroopCenter(this,EffectShowTypeDefine.EffectShow_DiaoXue);
					resolveDamageDisplayInfo(singleEffectOnCau.effectValue * this.originalTotalHpValue,this.troopIndex);
//					trace(this.troopIndex,"因为","中毒","损失血量",singleEffectOnCau.effectValue * this.originalTotalHpValue,"当前血量:",this.totalHpValue);
					chainInfo.addExistedEffect(singleEffectOnCau,true);
					if(this.logicStatus == LogicSatusDefine.lg_status_dead)
					{
						TroopFunc.makeTroopDieReally(this);
						break;
					}
				}
			}
		}
		
		/**
		 * 从队友处取得伤害值 
		 * @param damageValue
		 * @param sourceIndex
		 * @return 
		 */
		public function shareDamageFromMates(damageValue:int,sourceIndex:int):void
		{
			var realDamage:int = damageValue;
			if(TroopFunc.hasSpecificEffect(this,SpecialEffectDefine.baohuqiang,false))
			{
				var allPercent:Number = TroopFunc.getTotalValueFromExistedEffects(this,SpecialEffectDefine.baohuqiang,false);
				allPercent = Math.min(allPercent,1);
				realDamage = damageValue * (1 - allPercent);
				//播放墙被攻击动画,一部分伤害凭空消失
			}
			resolveDamageDisplayInfo(realDamage,sourceIndex);
		}
		
		/**
		 * 解析承受伤害时候的显示信息 
		 * @param damageValue
		 */
		public function resolveDamageDisplayInfo(damageValue:int,sourceIndex:int):void
		{
			var oldTotalHpValue:int = totalHpValue;
			
//			if(damageValue > 0)
//				damageValue = 1;
//			else if(damageValue < 0)
//				damageValue = -2000;
			
//			if(damageValue > 0)
//			{
//				var sourceTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(sourceIndex);
//				if(sourceTroop)
//				{
//					if(sourceTroop.isHero)
//						damageValue = 12;
//					else
//						damageValue = sourceTroop.damageValue;
//				}
//			}
			
			var valueLeft:int = Math.max(0,oldTotalHpValue - damageValue);
			
			var hpRealValueChange:int = oldTotalHpValue - valueLeft;
			
			if(valueLeft > 0)
			{
				this.curTroopHp = valueLeft % this.maxTroopHp;
				this.curArmCount = int(valueLeft / this.maxTroopHp) + 1;
				if(this.curTroopHp == 0)
				{
					this.curTroopHp = this.maxTroopHp;
					this.curArmCount -= 1;
				}
			}
			else
			{
				this.curArmCount = 0;
				this.curTroopHp = 0;
			}
			
			this.curArmCount = Math.max(this.curArmCount,0);
			this.curTroopHp = Math.max(this.curTroopHp,0);
			
			this.curArmCount = Math.min(this.curArmCount,this.maxArmCount);
			this.curTroopHp = Math.min(this.curTroopHp,this.maxTroopHp);
			
			_hpBar && _hpBar.hpChange(hpRealValueChange);
			
			if(this.curArmCount <= 0 && this.curTroopHp <= 0)
			{
				if(this.isHero)
					this.logicStatus = LogicSatusDefine.lg_status_dead;			//此troop死亡  不播放被攻击动画
				else
				{
					if(BattleInfoSnap.isAoYiRound)
					{
						this.logicStatus = LogicSatusDefine.lg_status_hangToDie;
					}
					else
					{
						this.logicStatus = LogicSatusDefine.lg_status_dead;
					}
				}
			}
			if(BattleManager.needTraceBattleInfo &&　sourceIndex　>= 0)
				trace("troop",this.troopIndex,"受到伤害来自 ",sourceIndex," 变化值:",hpRealValueChange,"当前,",totalHpValue,"/",originalTotalHpValue," 帧数：",BattleInfoSnap.curBattleFrame);
			if(BattleManager.needTraceBattleInfo && damageValue < 0)
			{
				if(sourceIndex < 0)
					trace("troop",this.troopIndex,"受到卡牌加血 "," 变化值:",hpRealValueChange,"当前,",totalHpValue,"/",originalTotalHpValue," 帧数：",BattleInfoSnap.curBattleFrame);
				else
					trace("troop",this.troopIndex,"受到加血来自 ",sourceIndex," 变化值:",hpRealValueChange,"当前,",totalHpValue,"/",originalTotalHpValue," 帧数：",BattleInfoSnap.curBattleFrame);
			}
		}
		
		/**
		 * 播放某个动作 
		 * @param type   动作类型
		 * @parma loops	 循环
		 * @param needWait	是否需要等待状态的改变	
		 * @param frameOffset			一开始偏移的帧数
		 */
		public function playAction(actionIndex:int,loops:int = 1,needWait:Boolean = false,frameOffset:int = 0,usePureSet:Boolean = false):Boolean
		{
			//此时没有动画可以播放
			if((troopPlayerId == "" || troopPlayerId == null) && this.avatarShowObj == null && this.heroShowObj == null)
				return false;
			
			var success:Boolean = true;
			var curStatausValue:int = this.mcStatus;
			var targetMcStatus:int;
			
			//是否需要错开
			var actionNeedDelay:Boolean = false;
			
			switch(actionIndex)
			{
				case ActionDefine.Action_Idle:									//空闲状态
					targetMcStatus = McStatusDefine.mc_status_idle;
					break;
				case ActionDefine.Action_Attack:									//攻击
					targetMcStatus = McStatusDefine.mc_status_attacking;
					break;
				case ActionDefine.Action_Dazhao:
				case ActionDefine.Action_Dazhao_Type2:
				case ActionDefine.Action_Dazhao_Type3:
					targetMcStatus = McStatusDefine.mc_status_attacking;
					break;
				case ActionDefine.Action_AoYi:									//攻击
				case ActionDefine.Action_Aoyi_Type2:
				case ActionDefine.Action_Aoyi_Type3:
					targetMcStatus = McStatusDefine.mc_status_attacking;
					break;
				case ActionDefine.Action_defense:									//防御
					targetMcStatus = McStatusDefine.mc_status_defending;
					break;
				case ActionDefine.Action_Combo_Attack:								//连击
					targetMcStatus = McStatusDefine.mc_status_attack_combo;
					break;
				case ActionDefine.Action_Combo_Defense:								//连击防守
					targetMcStatus = McStatusDefine.mc_status_defense_combo;
					break;
				case ActionDefine.Action_Run:									//跑动 		可能在补进，或者在跑到前方攻击
					targetMcStatus = McStatusDefine.mc_status_running;					
					break;
				case ActionDefine.Action_Dead:									//死亡的动作
					targetMcStatus = McStatusDefine.mc_status_dead;					
					break;
			}
			
//			if(targetMcStatus == McStatusDefine.mc_status_attacking)
//				trace("celltroop ",this.troopIndex,"play attack");
//			else if(targetMcStatus != McStatusDefine.mc_status_running)
//			{
//				trace("celltroop ",this.troopIndex,"play no attack");
//			}
			
			if(targetMcStatus != this.logicStatus && this.logicStatus != LogicSatusDefine.lg_status_waitForDamage)					//逻辑状态已经发生改变
			{
				if(needWait)			//监听troop状态的变化
					GameEventHandler.addListener(EventMacro.singleTroopHandlerMacro(this.troopIndex),
						BattleEventTagFactory.getNeedTroopStatus(this,targetMcStatus),targetStatusReached,[actionIndex,loops]);		//等待发出消息是否继续攻击
				success = false;
//				trace("celltroop ",this.troopIndex,"play attack 失败");
				return success;
			}
			
			if(targetMcStatus != this.logicStatus && this.logicStatus == LogicSatusDefine.lg_status_waitForDamage)
			{
				var targetFrame:Array = TroopFunc.getActionMultipleFrames(this,ActionDefine.Action_defense);
				var defendLogicFrame:int = 0;
				if(targetFrame)
					defendLogicFrame = targetFrame[0];
				if(AnimatorEngine.someplayerHasHandlerOnFrame(this.troopPlayerId,defendLogicFrame))
				{
					success = false;
//					trace("celltroop ",this.troopIndex,"play attack 失败");
					return success;
				}
			}
			
			var curPlayerId:String = this.targetPlayerId;
			
			if(targetMcStatus != this.mcStatus || AnimatorEngine.isPlayerStoped(curPlayerId))
			{
				if(this.isPlayerHero)				//如果播放的是avatar，特殊处理
				{
					this.avatarShowObj.playParticularPart(actionIndex,AvatarDefine.normalDir,loops); 
				}
				else if(this.isHero)
				{
					this.heroShowObj.playAction(actionIndex,loops);
				}
				else
				{
					if(AnimatorEngine.isPlayerStoped(curPlayerId))
					{
						AnimatorEngine.playPlayer(curPlayerId);
					}
					AnimatorEngine.showPlayer(curPlayerId,true);
					AnimatorEngine.setPlayerAction(actionIndex,curPlayerId,loops);
				}
				
				if(usePureSet)
					this.mcStatusPure = targetMcStatus;
				else
					this.mcStatus = targetMcStatus;
				
				//设置偏移量
				if(frameOffset > 0)
					AnimatorEngine.setPlayerFrameOffset(curPlayerId,frameOffset);	
				
				if(this.mcStatus == McStatusDefine.mc_status_idle && this.logicStatus == LogicSatusDefine.lg_status_idle)
				{
					GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,
						new Event(BattleEventTagFactory.getWaitForTroopBeIdleTag(this)));
				}
			}
			
			return success;
		}
		
		/**
		 * 达成某个目标之后 需要播放特定动作
		 * @param event
		 */
		private function targetStatusReached(event:TroopStatusNeedEvent,action:*):void
		{
			var param:Array = action as Array;
			var suspendAction:int = 0;
			var loops:int = -1;
			if(param && param.length > 1)
			{
				suspendAction = param[0];
				loops = param[1];
			}
			GameEventHandler.removeAllListener(EventMacro.singleTroopHandlerMacro(this.troopIndex));
			this.playAction(suspendAction,loops);
		}
		
		/*以下是各种帧事件监听函数*/
		
		/**
		 * 动画播放到这一帧数 被攻击方开始受到伤害 		逻辑开始跑	
		 * @param param
		 */
		private function onLogicAttackFrame(param:Array = null):void
		{
			if(param)
				param.shift();
//			if(param)
//				AnimatorEngine.removeHandlerForPlayer(this.troopPlayerId,param.shift(),onLogicAttackFrame);
			
			if(param.length <= 1)
			{
				if(!this.isTroopFanji)
				{
					this.setIdleStatusSecure();
				}
				isFirstOnTotalAtk = false;
				return;
			}
			
			if(this.isHero)
			{
				var playerId:String = param[2];
				if(playerId != null && playerId != "")
				{
					AnimatorEngine.showPlayer(playerId,true);
					AnimatorEngine.playPlayer(playerId,1);
				}
				else
				{
					//播放单独特效
					GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,new DamageArrivedEvent(param[0],param[1]));
				}
			}
			else
			{
//				trace("troop ",this.troopIndex," logicatkFrame");
				
				if(param.length > 2 && param[2])
					TroopEffectDisplayFunc.showSkillElementEffect(this,EffectShowTypeDefine.EffectShow_Baoji);
				//是否含有物理伤害
				var containsPhysicalDamage:Boolean = true;
				if(param.length > 3)
					containsPhysicalDamage = param[3];
				var effectPlayer:String = "";
				if(param.length > 4)
				{
					effectPlayer = param[4];
				}
				
				var otherWaitChain:Array;				//等待反击动画帧数作用的chain信息
				if(param.length > 5)
				{
					otherWaitChain = param[5] as Array;
				}
				
				if(otherWaitChain)
				{
					for each(var singleChain:CombatChain in otherWaitChain)
					{
						if(singleChain)
						{
							singleChain.makeDefGenedChainWork();
						}
					}
				}
				
				if(this._attackUnit.armtype == ArmType.archer)			//弓弩手
				{
					if(containsPhysicalDamage)
						BattleStage.instance.effectLayer.addArrowToStage(this,param[1]);
					else
						GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,new DamageArrivedEvent(param[0],param[1]));
				}
				else if(this._attackUnit.armtype == ArmType.magic || this._attackUnit.armtype == ArmType.machine)		//法师
				{
					if(effectPlayer && effectPlayer != "")
					{
						if(BattleManager.needTraceBattleInfo)
						{
							var tempPlayer:AnimatorPlayer = AnimatorEngine.getSinglePlayer(effectPlayer);
							if(tempPlayer)
							{
								trace("开始播放攻击打击动画，攻击方:",this.troopIndex,"当前帧数:",BattleInfoSnap.curBattleFrame,"动画自身帧数为:",tempPlayer.curframe);
							}
						}
						AnimatorEngine.showPlayer(effectPlayer,true);
						AnimatorEngine.playPlayer(effectPlayer,1);
					}
					else
					{
						GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,new DamageArrivedEvent(param[0],param[1]));
					}
				}
				else
				{
					if(effectPlayer && effectPlayer != "")
					{
						AnimatorEngine.showPlayer(effectPlayer,true);
						AnimatorEngine.playPlayer(effectPlayer,1);
					}
					else
						GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,new DamageArrivedEvent(param[0],param[1]));
				}
			}
			haveDispatchAtkEvent = true;
			if(!this.isTroopFanji)
			{
				this.setIdleStatusSecure();
			}
			isFirstOnTotalAtk = false;
		}
		
		/**
		 * 发出伤害到达的事件 
		 * @param atkIndex			发出方
		 * @param defIndex			目标方
		 */
		public function dispatchDamageArriveEvent(param:Array = null):void
		{
			if(param)
				param.shift();
//			if(param)
//				AnimatorEngine.removeHandlerForPlayer(this.troopPlayerId,param.shift(),dispatchDamageArriveEvent);
			
			if(param.length <= 1)
				return;
			else
			{
//				if(BattleManager.needTraceBattleInfo)
//				{
//					trace("发出伤害到达帧，","攻击方:",param[0],"防守方:",param[1],"当前帧数:",BattleInfoSnap.curBattleFrame);
//				}
				GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,new DamageArrivedEvent(param[0],param[1]));
				if(this.logicStatus != LogicSatusDefine.lg_status_dead)
				{
					this.logicStatus = LogicSatusDefine.lg_status_idle;
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				}
			}
		}
		
		/**
		 * 当动画播放到发动攻击的帧数时 
		 * @param parma  参数 包括攻击目标  所在chain的Index
		 */
		private function onTotalAttackFrame(param:Array = null):void
		{
			if(param)
				param.shift();
//			if(param)
//				AnimatorEngine.removeHandlerForPlayer(this.troopPlayerId,param.shift(),onTotalAttackFrame);
			
			if(isTroopFanji && !isFirstOnTotalAtk)
			{
				isTroopFanji = false;
				this.setIdleStatusSecure();
			}
			if(isHero)
				GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,new Event(BattleEventTagFactory.getHeroWaitGetBackTag(this)));
			if(this.logicStatus != LogicSatusDefine.lg_status_dead)
			{
				if(this.playAction(ActionDefine.Action_Idle,-1,true,0,true))
				{
					//攻击完成后检查回合是否结束
					AnimatorEngine.addCallBackForPlayerOfFrame(this.curReakPlayer,totalFrameCallBackOfAtk);
					if(isTroopFanji)
						isFirstOnTotalAtk = true;
				}
			}
			else
			{
				AnimatorEngine.addCallBackForPlayerOfFrame(this.curReakPlayer,totalFrameCallBackOfAtk);
			}
		}
		
		/**
		 *  所有的ontotalattackframe结束的回调
		 */
		private function totalFrameCallBackOfAtk():void
		{
			this.mcStatus = this.mcStatus;
			this.setIdleStatusSecure();
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
		}
		
		/**
		 * 动画播放到这一帧表示受到伤害完成 			逻辑开始跑
		 * @param param
		 */
		private function onLogicDefenseFrame(param:Array = null):void
		{
			var frameIndex:int = 0;
			if(param)
				frameIndex = param.shift();
			
			var chainIndex:int = param[0];
			var curAtkCount:int = param[1];
			var chainMaxCount:int = param[2];
			
			var chainInfo:CombatChain = BattleManager.instance.allChainInfo[chainIndex] as CombatChain;
			if(chainInfo == null)
				return;
			var defTroop:CellTroopInfo = chainInfo.targettroop;
			
			if(defTroop == null)
				return;
			
//			AnimatorEngine.removeHandlerForPlayer(defTroop.troopPlayerId,frameIndex,onLogicDefenseFrame);
			
			if(defTroop.logicStatus == LogicSatusDefine.lg_status_dead)
			{
				defTroop.alldamageSource[chainInfo.chainIndex] = 1;
				//此处逻辑应该不会跑进
				//处理troop死亡
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectSourceDeadEvent(defTroop.troopIndex));
				//troop死掉，处理  可能是掉落奖励，或者是后排兵力补进
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new TroopDeadEvent(TroopDeadEvent.TROOPDEADEVENT,defTroop.troopIndex));
			}
			else
			{
				var isAtkTroopLianjieOver:Boolean = true;
				if(chainInfo.sourceTroop)
				{
					isAtkTroopLianjieOver = BattleInfoSnap.checkAttackLianjiOver(chainInfo.sourceTroop);
				}
				if(curAtkCount < chainMaxCount)				
				{
					if(chainIndex >= 0)
					{
						//判断是否可以连击
						GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckComboEvent(BattleEventTagFactory.geneChainCheckEvent(chainIndex)));//发出消息是否继续攻击
					}
				}
				else							//如果攻击方的连击没有结束
				{
					defTroop.alldamageSource[chainInfo.chainIndex] = 1;
					if(isAtkTroopLianjieOver)
					{
						defTroop.waitDamageSource = -1;
						defTroop.setIdleStatusSecure();
					}
					else
					{
//						defTroop.logicStatus = LogicSatusDefine.lg_status_waitForDamage;	
						defTroop.waitDamageSource = chainInfo.atkTroopIndex;
//						TroopFunc.addTroopDamageSource(defTroop,chainInfo.chainIndex);
					}
				}
			}
		}
		
		/**
		 * 动画播放到被攻击特定帧数时    要检查是否有触发的被动技能
		 * @param parma
		 */
		private function onTotalDefenseFrame(param:Array = null):void
		{
			if(param)
				param.shift();
//			if(param)
//				AnimatorEngine.removeHandlerForPlayer(defTroop.troopPlayerId,param.shift(),onTotalDefenseFrame);
			
			var chainIndex:int = param[0];
			var curAtkCount:int = param[1];
			var chainMaxCount:int = param[2];
			
			var chainInfo:CombatChain = BattleManager.instance.allChainInfo[chainIndex] as CombatChain;
			if(chainInfo == null)
				return;
			var defTroop:CellTroopInfo = chainInfo.targettroop;
			if(defTroop == null)
				return;
			
			if(defTroop.logicStatus == LogicSatusDefine.lg_status_dead)
			{
				if(defTroop.isHero)
					defTroop.playAction(ActionDefine.Action_Dead,1);
			}
			else
			{
//				if(this.playAction(ActionDefine.Action_Idle,-1,true))
//				{
//					if(chainInvolved)
//					{
//						GameEventHandler.addListener(BattleEventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneChainCheckEvent(chainInvolved.chainIndex),chainInvolved.checkChainComboInfo);
//						GameEventHandler.dispatchGameEvent(BattleEventMacro.NORMAL_BATTLE_EVENT,new CheckComboEvent(BattleEventTagFactory.geneChainCheckEvent(chainInvolved.chainIndex)));//发出消息是否继续攻击
//					}
//				}
				if(curAtkCount < chainMaxCount)				//还有连击
				{
					if(chainIndex >= 0)
					{
						//判断是否可以连击
						AnimatorEngine.stopPlayer(defTroop.troopPlayerId);
					}
				}
				else
				{
					if(defTroop.logicStatus != LogicSatusDefine.lg_status_attack)
					{
						AnimatorEngine.addCallBackForPlayerOfFrame(defTroop.curReakPlayer,defTroop.totalFrameCallBackOfDef,[defTroop,chainInfo]);
//						defTroop.setIdleStatusSecure();				//看能不能设置为正常状态
//						if(defTroop.playAction(ActionDefine.Action_Idle,-1,true))
//						{
//							GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneChainCheckEvent(chainInfo.chainIndex),chainInfo.checkChainComboInfo);
//							GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckComboEvent(BattleEventTagFactory.geneChainCheckEvent(chainInfo.chainIndex)));//发出消息是否继续攻击
//						}
					}
				}
			}
		}
		
		/**
		 *  所有的ontotaldefenseframe结束的回调
		 */
		public function totalFrameCallBackOfDef(params:Array):void
		{
			var defTroop:CellTroopInfo = params[0];
			var chainInfo:CombatChain = params[1];
			defTroop.setIdleStatusSecure();				//看能不能设置为正常状态
			if(defTroop.playAction(ActionDefine.Action_Idle,-1,true))
			{
				GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneChainCheckEvent(chainInfo.chainIndex),chainInfo.checkChainComboInfo);
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckComboEvent(BattleEventTagFactory.geneChainCheckEvent(chainInfo.chainIndex)));//发出消息是否继续攻击
			}
		}
		
		/**
		 * 让自己回退到原始位置 
		 * @param event				事件
		 * @param params			参数
		 */
		public function makeHeroBackToPos(event:Event,params:Array):void
		{
			if(params == null || params.length < 3)
				return;
			var originX:Number = params[0];
			var originY:Number = params[1];
			var yValue:int = params[2];
			
			this.logicStatus = LogicSatusDefine.lg_status_filling;
			this.playAction(ActionDefine.Action_Run,-1);
			
			Tweener.addTween(this,{x:originX,y:originY,time:Utility.getFrameByTime(BattleDisplayDefine.heroBackTime),useFrames:true,
				transition:"linear",onComplete:BattleStage.instance.troopLayer.heroGetBack,onCompleteParams:[this]});
		}
		
		/**
		 * hero死亡的时候播放完成 
		 * @param param
		 */
		private function onHeroDeadFrame(param:Array = null):void
		{
			this.mcStatus = McStatusDefine.mc_status_idle;
//			if(this.heroShowObj)
//			{
//				this.heroShowObj.clearData();
//			}
			
			TroopInitClearFunc.clearTroopSimply(this,false);
//			AnimatorEngine.stopPlayer(this.troopPlayerId);
//			if(this.troopPlayerId != null && this.troopPlayerId.length > 0) 
//				AnimatorEngine.removePlayer(this.troopPlayerId);
			this.logicStatus == LogicSatusDefine.lg_status_dead;
			TroopFunc.hideParticularTroop(this,false);
			//此处可能会导致多个回合同时开始执行
//			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
		}
		
		private function onHeroAoyiEffectFrame(param:Array):void
		{
			BattleScreenEffectFunc.showScreenShake(0);
		}
		
		/**
		 * 更改英雄的士气 
		 * @param value
		 */
		public function changeHeroMorale(value:int):void
		{
			return;
			if(!BattleManager.instance.enableMorale && !BattleManager.instance.enableMoraleTemporary)
			{
				if(this.ownerSide == BattleDefine.firstAtk)			//自己方不能获得士气
					return;
			}
			if(value == 0)
				return;
			var singleTroopInfo:CellTroopInfo;
			var shiqiZengJiaValue:int = TroopFunc.getTotalValueFromExistedEffects(this,SpecialEffectDefine.shiQiEWaiZengJia);
			for(var i:int = 0; i < allHeroArr.length;i++)
			{
				singleTroopInfo = allHeroArr[i] as CellTroopInfo;
				if(singleTroopInfo)
				{
					if(shiqiZengJiaValue > 0 && value > 0)
					{
						singleTroopInfo.troopMoraleChange(value + shiqiZengJiaValue);
					}
					else
					{
						singleTroopInfo.troopMoraleChange(value);
					}
				}
			}
		}
		
		/**
		 * 士气变化 
		 * @param value
		 */
		public function troopMoraleChange(value:int):void
		{
			if(!this.troopVisibleOnBattle)
				return;
			if(!this.isHero)
				return;
			if(this.attackUnit == null &&  this.attackUnit.contentHeroInfo == null)
				return;
			
			var oldVlaue:int = this.moraleValue;
			this.moraleValue += value;
			this.moraleValue = Math.min(BattleValueDefine.maxMoraleValue,this.moraleValue);
			this.moraleValue = Math.max(0,this.moraleValue);
			
			_moraleBar && _moraleBar.moraleChanged(this.moraleValue - oldVlaue);
		}
		
		/**
		 * 单个troop异步加载完成
		 * @param event
		 */
		public function singleBackLoadAnimatorLoaded(event:Event):void
		{
			GameResourceManager.eventHandler.removeEventListener(event.type,singleBackLoadAnimatorLoaded);
			
			var singleUnit:ByteArrayFunc;
			
			var resId:int = int(event.type);
			
			var loadResourceUnit:LoadUnit = ResourceConfig.getSingleResConfigById(resId);
			
			if(!this.isHero)
			{
				if(event.type != this.mcIndex.toString())
					return;
				singleUnit = BattleResourceCopy.getFreeUnitInfo();
				if(loadResourceUnit.m_type == ResType.ANIMATOR)
					singleUnit.getTargetActionFrames(resId,-1,ResourcePool.getSourceByteArr(resId),null,singleTroopCompleteHandler,[resId,this.troopIndex]);
				else
					singleTroopCompleteHandler([resId,this.troopIndex]);
			}
			else		//hero 必然是yp   swf文件混合
			{
				if(event.type == (this.mcIndex * ResourceConfig.swfIdMapValue).toString())			//此时下载完成的是yp
				{
					singleUnit = BattleResourceCopy.getFreeUnitInfo();
					singleUnit.getTargetActionFrames(resId,-1,ResourcePool.getSourceByteArr(resId),null,singleTroopCompleteHandler,[mcIndex,this.troopIndex]);
				}
				else if(event.type == this.mcIndex.toString())			//此时下载完成的是swf
				{
					if(BattleResourceCopy.hasParticlarAnimator(this.mcIndex * ResourceConfig.swfIdMapValue))			//如果yp文件也加载初始化完成,直接初始化
					{
						TroopDisplayFunc.initShowInfo(this);
					}
				}
				else
				{
					return;
				}
			}
		}
		
		public function singleTroopCompleteHandler(param:Array):void
		{
			var resId:int = param.shift();
			var troopIndex:int = param.shift();
			if(!this.isHero)
			{
				TroopDisplayFunc.initShowInfo(this);
			}
			else
			{
				if(resId == this.mcIndex * ResourceConfig.swfIdMapValue)
				{
					if(ResourcePool.hasSomeResById(this.mcIndex))			//如果swf文件也加载完成
					{
						TroopDisplayFunc.initShowInfo(this);
					}
				}
				else
				{
					return;
				}
			}
		}
		
		/**
		 * 强制死亡
		 * 
		 */
		public function makeTroopForceDead():void
		{
			//强制死亡

			var supplyType:int = 0;
			var supplyAddValue:int = 0;
			var percent:Number = totalHpValue / originalTotalHpValue;
			if(this.attackUnit.armtype == ArmType.footman)
			{
				supplyType = NextSupplyShow.starSupplyTypeHP;
//				supplyAddValue = totalHpValue;
				supplyAddValue = totalHpValue / originalTotalHpValue * 100;
			}
			else
			{
				supplyType = NextSupplyShow.starSupplyTypeDamage;
				supplyAddValue = totalHpValue / originalTotalHpValue * 15;
			}
			
			this.curArmCount = 0;
			this.curTroopHp = 0;
			
//			_hpBar && _hpBar.hpChange(totalHpValue);
			
			this.mcStatus = McStatusDefine.mc_status_idle;
			
			this.logicStatus = LogicSatusDefine.lg_status_forceDead;
			
			if(_hpBar)
				_hpBar.visible = true;
			
			TroopFunc.handleDeadTroopLogic(this,true);
			
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
			DemoManager.handleSingleStarQualified(supplyType,supplyAddValue,percent);
		}
		
		/**
		 * 处理stagger帧数减少的逻辑 
		 * @param event
		 */
		public function handleStagerFrameDecrease(event:Event):void
		{
			if(staggerFrameCountLeft > 0)
			{
				staggerFrameCountLeft--;
				if(staggerFrameCountLeft == 0)
				{
					staggerTimeUpHandler(null);
				}
			}
		}
		
		/**
		 * 获得这个troop对应的英雄troop 
		 * @return 
		 */
		public function get allHeroArr():Array
		{
			if(_allHeroArr == null || _allHeroArr.length == 0)				//如果此时还没有找到英雄
			{
				_allHeroArr =[];
				
				if(this.isHero)
					_allHeroArr.push(this);
				else
				{
					var power:PowerSide = BattleFunc.getSidePowerInfoForTroop(this);	//对应的powerside
					var singleHeroInfo:CellTroopInfo;
					for(var i:int = 0; i < this.cellsCountNeed.y;i++)
					{
						var positon:Point = BattleTargetSearcher.getRowColumnByCellIndex(this.occupiedCellStart + i);
						singleHeroInfo = BattleFunc.getHeroTroopForIndex(positon.y,power);
						_allHeroArr.push(singleHeroInfo);
					}
				}
			}
			return _allHeroArr;
		}
		
		public function set allHeroArr(value:Array):void
		{
			_allHeroArr = value;
		}
		
		/**
		 * 判断本身是否是可以攻击的单位 
		 * @return 
		 * 
		 */
		public function get isAttackTroop():Boolean
		{
			var res:Boolean = true;
			if(_attackUnit == null)
				return false;
			if(_attackUnit.specialRoleType == SpecialTroopType.NON_ATTACK || _attackUnit.specialRoleType == SpecialTroopType.NON_MOVE_ATTACK)	//如果是不能攻击的类型
				res = false;
			if(this.attackUnit.slotType == FormationElementType.NOTHING)
				res = false;
			return res;
		}
		
		/**
		 * 判断本身是否是可以被攻击的单位 
		 * @return 
		 */
		public function get isAttackedTroop():Boolean
		{
			var res:Boolean = true;
			if(_attackUnit == null)
				return false;
			if(_attackUnit.specialRoleType == SpecialTroopType.NON_ATTACKED || _attackUnit.specialRoleType == SpecialTroopType.NON_MOVE_ATTACKED)	//如果是不能攻击的类型
				res = false;
			if(this.isHero || this.attackUnit.slotType == FormationElementType.NOTHING)
				res = false;
			return res;
		}
		
		/**
		 * 判断troop是否可以移动 
		 * @return 
		 */
		public function get isMobileTroop():Boolean
		{
			var res:Boolean = true;
			if(_attackUnit == null)
				return false;
			if(_attackUnit.specialRoleType == SpecialTroopType.NON_MOVE || _attackUnit.specialRoleType == SpecialTroopType.NON_MOVE_ATTACKED || 
				_attackUnit.specialRoleType == SpecialTroopType.NON_MOVE_ATTACK)	//如果是不能攻击的类型
				res = false;
			return res;
		}
		
		/**
		 * 当前状态是不是暂时攻击 
		 * @return 
		 */
		public function get isMcOnCanAttackStatus():Boolean
		{
			return this.mcStatus !=  McStatusDefine.mc_status_defending && 
			       this.mcStatus !=  McStatusDefine.mc_status_defense_combo &&
				   this.mcStatus !=  McStatusDefine.mc_status_attacking &&
				   this.mcStatus !=  McStatusDefine.mc_status_attack_combo &&
				   this.logicStatus !=  LogicSatusDefine.lg_status_waitForDamage &&
				   this.logicStatus !=  LogicSatusDefine.lg_status_filling &&
				   this.mcStatus !=  McStatusDefine.mc_status_running;
//			!(this.logicStatus == LogicSatusDefine.lg_status_waitForPath && this.isHero)
		}
		
		/**
		 * 获得闪避率 
		 * @return 
		 */
		public function get evadeRate():Number
		{
			var baseEvadeNum:Number = attackUnit.evadeRate;
			var increaseValue:Number = TroopFunc.getTotalValueFromExistedEffects(this,SpecialEffectDefine.ShanBiZengJia,false);
			baseEvadeNum *= (1 + increaseValue);
			return baseEvadeNum;
		}
		
		/**
		 * 获得暴击概率 
		 * @return 
		 */
		public function get critalRate():Number
		{
			if(this.isHero)
				return 0;
			var baseEvadeNum:Number = attackUnit.critRate;
			var increaseValue:Number = TroopFunc.getTotalValueFromExistedEffects(this,SpecialEffectDefine.BaoJiZengJia,true);
			baseEvadeNum *= (1 + increaseValue);
			return baseEvadeNum;
		}
		
		/**
		 * 获得命中率 
		 * @return 
		 */
		public function get hitRate():Number
		{
			return attackUnit.hitRate;
		}
		
		/**
		 * 战斗中的攻击值 (runtime加成) 
		 * @return 
		 */
		public function get damageValue():int
		{
			var baseEvadeNum:Number = _attackUnit.damageValue;
			var increaseValue:Number = TroopFunc.getTotalValueFromExistedEffects(this,SpecialEffectDefine.ShangHaiZengJia,true);
			return baseEvadeNum + increaseValue;
		}
		
		public function set damageValue(value:int):void
		{
			_attackUnit.damageValue = value;
		}
		
		/**
		 * 战斗中的抗性值 (runtime加成   停用)
		 * @return 
		 */
		public function get defenseValue():Number
		{
			return _attackUnit.defenseValue;
		}

		/**
		 * 英雄的普通攻击 (runtime加成)
		 * @return 
		 * 
		 */
		public function get heroNormalAttack():Number
		{
			if(_heroPropertyStore.hasOwnProperty("heroNormalAttack"))
				return Number(_heroPropertyStore["heroNormalAttack"]);
			var allHeroInfo:Array = this.allHeroArr;
			var curNumber:Number = 0;
			for each(var singleTroop:CellTroopInfo in allHeroInfo)
			{
				if(singleTroop)
				{
					curNumber = Math.max(curNumber,singleTroop.attackUnit.heroNormalAttack);
				}
			}
			_heroPropertyStore["heroNormalAttack"] = curNumber;
			return curNumber;
		}
		
		public function get maxDamageValue():Number
		{
			return Math.max(heroMagicAttack,heroNormalAttack);
		}
		
		/**
		 * 英雄的普通防御 (runtime加成)
		 * @return 
		 * 
		 */
		public function get heroNormalDefense():Number
		{
			if(_heroPropertyStore.hasOwnProperty("heroNormalDefense"))
				return Number(_heroPropertyStore["heroNormalDefense"]);
			var allHeroInfo:Array = this.allHeroArr;
			var curNumber:Number = 0;
			for each(var singleTroop:CellTroopInfo in allHeroInfo)
			{
				if(singleTroop)
					curNumber = Math.max(curNumber,singleTroop.attackUnit.heroNormalDefense);
			}
			_heroPropertyStore["heroNormalDefense"] = curNumber;
			return curNumber;
		}
		
		/**
		 * 英雄的普通防御 (runtime加成) 
		 * @return 
		 * 
		 */
		public function get heroMagicAttack():Number
		{
			if(_heroPropertyStore.hasOwnProperty("heroMagicAttack"))
				return Number(_heroPropertyStore["heroMagicAttack"]);
			var allHeroInfo:Array = this.allHeroArr;
			var curNumber:Number = 0;
			for each(var singleTroop:CellTroopInfo in allHeroInfo)
			{
				if(singleTroop)
					curNumber = Math.max(curNumber,singleTroop.attackUnit.heroMagicAttack);
			}
			_heroPropertyStore["heroMagicAttack"] = curNumber;
			return curNumber;
		}
		
		/**
		 * 英雄的魔法攻击 
		 * @return 
		 */
		public function get heroMagicDefense():Number
		{
			if(_heroPropertyStore.hasOwnProperty("heroMagicDefense"))
				return Number(_heroPropertyStore["heroMagicDefense"]);
			var allHeroInfo:Array = this.allHeroArr;
			var curNumber:Number = 0;
			for each(var singleTroop:CellTroopInfo in allHeroInfo)
			{
				if(singleTroop)
					curNumber = Math.max(curNumber,singleTroop.attackUnit.heroMagicDefense);
			}
			_heroPropertyStore["heroMagicDefense"] = curNumber;
			return curNumber;
		}
		
		public function get heroArmCount():int
		{
			if(_heroPropertyStore.hasOwnProperty("heroArmCount"))
				return Number(_heroPropertyStore["heroArmCount"]);
			var allHeroInfo:Array = this.allHeroArr;
			var curNumber:Number = 0;
			for each(var singleTroop:CellTroopInfo in allHeroInfo)
			{
				if(singleTroop)
					curNumber = Math.max(curNumber,singleTroop.attackUnit.contentHeroInfo.getArmAmount());
			}
			_heroPropertyStore["heroArmCount"] = curNumber;
			return curNumber;
		}
		
		public function get targetPlayerId():String
		{
			var retValue:String = this.troopPlayerId;
			if(this.isPlayerHero)
			{
				retValue = this.avatarShowObj.curPlayAnimatorId;
			}
			else if(this.isHero)
			{
				retValue = this.heroShowObj.curplayerid;
			}
			return retValue;
		}
		
		/**
		 * troop的唯一的索引，key-value 
		 * troopIndex:this
		 * @return 
		 * 
		 */
		public function get troopIndex():int					
		{
			return _troopIndex;
		}
		
		/**
		 * 是否为隐形单位 
		 * @return 
		 */
		public function get troopVisibleOnBattle():Boolean
		{
			return this.attackUnit && this.attackUnit.slotVisible == BattleDefine.normalShow;
		}
		
		/**
		 * 当前表现状态 
		 */
		public function get mcStatus():int
		{
			return _mcStatus;
		}

		/**
		 * @private
		 */
		public function set mcStatus(value:int):void
		{
			_mcStatus = value;
			if(_mcStatus == McStatusDefine.mc_status_idle && logicStatus != LogicSatusDefine.lg_status_dead)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,new Event(BattleEventTagFactory.waitForFanJi(this.troopIndex)));
			}
		}

		/**
		 * 设置mcstatus不发出事件 
		 * @param value
		 */
		public function set mcStatusPure(value:int):void
		{
			_mcStatus = value;
		}
		
		/**
		 *  攻击的unit信息
		 */
		public function get attackUnit():AttackUnit
		{
			return _attackUnit;
		}

		/**
		 * @private
		 */
		public function set attackUnit(value:AttackUnit):void
		{
			_attackUnit = value;
		}

		/**
		 *  当前带兵量
		 */
		public function get curArmCount():int
		{
			return _curArmCount;
		}

		/**
		 * @private
		 */
		public function set curArmCount(value:int):void
		{
			var oldValue:int = _curArmCount;
			_curArmCount = value;
		}

		/**
		 * 是否是副将或者英雄  
		 * @return 
		 */
		public function get isHero():Boolean
		{
			return (this.attackUnit != null && this.attackUnit.type == FormationElementType.HERO) || (this.sourceFormationInfo != null && this.sourceFormationInfo.type == FormationElementType.HERO);
		}
		
		/**
		 * 是否为默认玩家英雄
		 * @return 
		 */
		public function get isPlayerHero():Boolean
		{
			return isHero && this.attackUnit.contentHeroInfo && (this.attackUnit.contentHeroInfo.heroid == HeroDefines.userDefaultHero);
		}
		
		/**
		 * 是否为法师 
		 * @return 
		 */
		public function get isMaster():Boolean
		{
			var res:Boolean = false;
			if(attackUnit == null)
				return false;
			if(isHero)
				res = (attackUnit.heroType == HeroType.moFaLei);
			else
				res = (attackUnit.damageType == ArmDamageType.fashu);
			return res;
		}

		public function get effectOnAttack():Array
		{
			return _effectOnAttack;
		}

		public function set effectOnAttack(value:Array):void
		{
			_effectOnAttack = value;
		}

		public function get effectOnDefense():Array
		{
			return _effectOnDefense;
		}

		public function set effectOnDefense(value:Array):void
		{
			_effectOnDefense = value;
		}

		public function get effectOnBothAtkDef():Array
		{
			return _effectOnBothAtkDef;
		}

		public function set effectOnBothAtkDef(value:Array):void
		{
			_effectOnBothAtkDef = value;
		}

		public function get maxArmCount():int
		{
			if(!this.isHero)
				return this.attackUnit.curArmCount;
			return 0;
		}

		public function get maxTroopHp():int
		{
			if(!this.isHero)
			{
				var increaseValue:Number = TroopFunc.getTotalValueFromExistedEffects(this,SpecialEffectDefine.HPShangXianZengJia,true);
				if(this.attackUnit)
					return this.attackUnit.troopHp + increaseValue;
				else
					return increaseValue;
			}
			return 0;
		}

		public function set maxTroopHp(value:int):void
		{
			if(!this.isHero)
			{
				this.attackUnit.troopHp = value;
			}
		}
		
		public function get curTroopHp():int
		{
			_curTroopHp = Math.min(_curTroopHp,this.maxTroopHp);
			return _curTroopHp;
		}

		public function set curTroopHp(value:int):void
		{
			_curTroopHp = value;
		}

		/**
		 * 得到当前的总hp值
		 * @return 
		 */
		public function get totalHpValue():int
		{
			return this.curArmCount > 0 ? (this.curArmCount - 1) * this.maxTroopHp + this.curTroopHp : this.curTroopHp;   
		}
		
		/**
		 * 得到此troop初始化的所有hp值 
		 * @return 
		 */
		public function get originalTotalHpValue():int
		{
			return this.maxArmCount * this.maxTroopHp;
		}
		
		/**
		 * 得到此slot上最大的hp值 
		 * @return 
		 */
		public function get totalHpOfSlot():int
		{
			if(this.attackUnit)
				return this.attackUnit.armcountofslot * this.maxTroopHp;
			return 0;
		}

		public function get logicStatus():int
		{
			return _logicStatus;
		}

		/**
		 * 设置状态为idle,这个接口只有当troop处在攻击或者防守某个关键帧上时调用 
		 * @param SDD
		 */
		public function setIdleStatusSecure():void
		{
			if(this.logicStatus == LogicSatusDefine.lg_status_idle)
				return;
			if(this.logicStatus == LogicSatusDefine.lg_status_dead)				//死亡的不能设置
				return;
			if(this.logicStatus == LogicSatusDefine.lg_status_filling && this.mcStatus == McStatusDefine.mc_status_running)		//在补进的不能设置
				return;
			var oldLogicStatus:int = this.logicStatus;
			
			var targetFrame:Array = TroopFunc.getActionMultipleFrames(this,ActionDefine.Action_defense);
			var defendLogicFrame:int = 0;
			if(targetFrame)
				defendLogicFrame = targetFrame[0];
			
			var hasNoArriviedDamage:Boolean = false;
			for(var singleChainIndex:String in alldamageSource)
			{
				var curChainAtkOver:Boolean = false;
				var tempSingleTroopIndex:int = int(singleChainIndex);
				var tempChain:CombatChain = BattleManager.instance.allChainInfo[tempSingleTroopIndex] as CombatChain;
				if(this.alldamageSource[singleChainIndex] != 1)			//此chain还没有攻击
				{
					if(tempChain.sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)			//只要攻击troop没死，那么不能认为回合结束
						curChainAtkOver = true;
//					else
//					{
//						curChainAtkOver = tempChain.curAtkCount >= tempChain.maxAttackTimes;
//						if(!curChainAtkOver)
//						{
//							if(AnimatorEngine.someplayerHasHandlerOnFrame(this.troopPlayerId,defendLogicFrame))
//							{
//								
//							}
//						}
//					}
					
					if(!curChainAtkOver)
					{
						hasNoArriviedDamage = true;
						break;
					}
				}
				else
				{
				}
			}
			
			if(this.logicStatus != LogicSatusDefine.lg_status_forceDead)
			{
				if(hasNoArriviedDamage)
//					this.logicStatus = LogicSatusDefine.lg_status_waitForDamage;
					this.logicStatus = LogicSatusDefine.lg_status_idle;
				else
					this.logicStatus = LogicSatusDefine.lg_status_idle;
			}
		}
		
		public function setDeadForcely():void
		{
			this._logicStatus = LogicSatusDefine.lg_status_dead;
		}
		
		public function set logicStatus(value:int):void
		{
			var oldValue:int = _logicStatus;
			
			_logicStatus = value;
			
			if(oldValue == LogicSatusDefine.lg_status_forceDead && value != LogicSatusDefine.lg_status_forceDead)
			{
				return;
			}
			
			if(_logicStatus >= 0)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.singleTroopHandlerMacro(this.troopIndex),
					new TroopStatusNeedEvent(this,_logicStatus));
				
				if(this.mcStatus == McStatusDefine.mc_status_idle && _logicStatus == LogicSatusDefine.lg_status_idle)
				{
					GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,
						new Event(BattleEventTagFactory.getWaitForTroopBeIdleTag(this)));
				}
			}
			
			if(this.isHero && this.logicStatus == LogicSatusDefine.lg_status_dead)
			{	
				this.dispatchEvent(new Event(HeroPortrait.heroTroopDeadTag));
				delete BattleInfoSnap.moveForwardHero[this.troopIndex];
			}
			
			if(this.logicStatus == LogicSatusDefine.lg_status_dead && this.ownerSide == 0)
			{
				BattleInfoSnap.addDeadTroop(this.troopIndex);
			}
			
		}

		public function get heroOffectValue():int
		{
			return _heroOffectValue;
		}

		public function set heroOffectValue(value:int):void
		{
			_heroOffectValue = value;
		}

		public function get occupiedCellStart():int
		{
			return _occupiedCellStart;
		}

		public function set occupiedCellStart(value:int):void
		{
			_occupiedCellStart = value;
		}

		public function get troopPlayerId():String
		{
			return _troopPlayerId;
		}

		public function set troopPlayerId(value:String):void
		{
			_troopPlayerId = value;
		}

		public function get avatarShowObj():AvatarShow
		{
			return _avatarShowObj;
		}

		public function set avatarShowObj(value:AvatarShow):void
		{
			_avatarShowObj = value;
		}

		public function get moraleBar():HeroMoraleBar
		{
			return _moraleBar;
		}

		public function set moraleBar(value:HeroMoraleBar):void
		{
			_moraleBar = value;
		}

		public function get iconSlots():EffectIconSlots
		{
			return _iconSlots;
		}

		public function set iconSlots(value:EffectIconSlots):void
		{
			_iconSlots = value;
		}

		public function get hpBar():HpBar
		{
			return _hpBar;
		}

		public function set hpBar(value:HpBar):void
		{
			_hpBar = value;
		}
		
		public function get isOnStaggerWait():Boolean
		{
			return _isOnStaggerWait;
		}
		
		//错开timer到达
		public function staggerTimeUpHandler(event:TimerEvent = null):void
		{
			TroopFunc.initTroopStaggerTimer(this);
			this.dispatchEvent(new Event(CellTroopInfo.troopStaggerTimeOutEvent));
		}

		public function get kapianBufOnAttack():Array
		{
			return _kapianBufOnAttack;
		}

		public function set kapianBufOnAttack(value:Array):void
		{
			_kapianBufOnAttack = value;
		}

		public function get kapianBufOnDefense():Array
		{
			return _kapianBufOnDefense;
		}

		public function set kapianBufOnDefense(value:Array):void
		{
			_kapianBufOnDefense = value;
		}

		public function get kapianBufOnBothAtkDef():Array
		{
			return _kapianBufOnBothAtkDef;
		}

		public function set kapianBufOnBothAtkDef(value:Array):void
		{
			_kapianBufOnBothAtkDef = value;
		}

		public function get effectObjBasesAddedToTroop():Object
		{
			return _effectObjBasesAddedToTroop;
		}

		public function set effectObjBasesAddedToTroop(value:Object):void
		{
			_effectObjBasesAddedToTroop = value;
		}

		public function get specialEffects():Object
		{
			return _specialEffects;
		}

		public function set specialEffects(value:Object):void
		{
			_specialEffects = value;
		}

		public function get heroPropertyStore():Object
		{
			return _heroPropertyStore;
		}

		public function set heroPropertyStore(value:Object):void
		{
			_heroPropertyStore = value;
		}

		public function get isBusy():Boolean
		{
			return _isBusy;
		}

		public function set isBusy(value:Boolean):void
		{
			_isBusy = value;
			if(_isBusy)
			{
				this.addEventListener(MouseEvent.ROLL_OVER,troopMouseRollInHandler);
				this.addEventListener(MouseEvent.ROLL_OUT,troopMouseRollOutHandler);
			}
			else
			{
				if(selfHeroGuideArrow)
				{
					if(selfHeroGuideArrow.parent)
						selfHeroGuideArrow.parent.removeChild(selfHeroGuideArrow);
					selfHeroGuideArrow = null;
				}
			}
		}

		public function get mcIndex():int
		{
			return _mcIndex;
		}

		public function set mcIndex(value:int):void
		{
			_mcIndex = value;
		}

		public function get isTroopFanji():Boolean
		{
			return _isTroopFanji;
		}

		public function set isTroopFanji(value:Boolean):void
		{
			_isTroopFanji = value;
		}

		public function get waitDamageSource():int
		{
			return _waitDamageSource;
		}

		public function set waitDamageSource(value:int):void
		{
			_waitDamageSource = value;
		}

		public function get heroShowObj():AnimatorPlayerSwfBmpMix
		{
			return _heroShowObj;
		}

		public function set heroShowObj(value:AnimatorPlayerSwfBmpMix):void
		{
			_heroShowObj = value;
		}
		
		public function get curReakPlayer():String
		{
			var targetPlayerId:String = this.troopPlayerId;
			if(targetPlayerId == "" || targetPlayerId == null)
			{
				if(this.isPlayerHero)
				{
					targetPlayerId = this.avatarShowObj.curPlayAnimatorId;
				}
				else if(this.isHero)
				{
					targetPlayerId = this.heroShowObj.curplayerid;
				}
			}
			return targetPlayerId;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
		}
		
	}
}