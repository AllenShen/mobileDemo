package modules.battle.managers
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import animator.animatorengine.AnimatorEngine;
	
	import avatarsys.avatar.AvatarConfig;
	import avatarsys.util.WeaponGenedEffectConfig;
	
	import defines.ErrorCode;
	
	import effects.BattleResourcePool;
	
	import eventengine.GameEventHandler;
	
	import events.WizardNotifyEvent;
	
	import handlers.server.BattleHandler;
	
	import macro.BattleDisplayDefine;
	import macro.CommonEventTypeDefine;
	import macro.EventMacro;
	import macro.FormationElementType;
	
	import modules.battle.battlecomponent.DeadEnemyCycle;
	import modules.battle.battlecomponent.DeadEnemyProgressShow;
	import modules.battle.battlecomponent.HeroPortraitGroup;
	import modules.battle.battlecomponent.NextSupplyShow;
	import modules.battle.battledata.FormationRemainInfo;
	import modules.battle.battledata.ResLoadCompleteAgent;
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.BattleResultValue;
	import modules.battle.battledefine.BattleValueDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.McStatusDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battleevents.BattleStartEvent;
	import modules.battle.battleevents.CheckAttackEvent;
	import modules.battle.battleevents.CheckBattleEndEvent;
	import modules.battle.battleevents.CheckComboEvent;
	import modules.battle.battleevents.CheckRoundEndEvent;
	import modules.battle.battleevents.TroopDeadEvent;
	import modules.battle.battlelogic.BattleResult;
	import modules.battle.battlelogic.BattleTimeSecurer;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.battlelogic.SingleRound;
	import modules.battle.battlelogic.skillandeffect.EffectOnCau;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.BattleManagerLogicFunc;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.funcclass.TroopInitClearFunc;
	import modules.battle.stage.BattleStage;
	import modules.battle.stage.WaitUserShowOfRaid;
	
	import synchronousLoader.BattleResourceCopy;
	import synchronousLoader.GameResourceManager;
	import synchronousLoader.ResourcePool;
	
	import sysdata.MapEnemyUnit;
	
	import utils.TroopActConfig;

	/**
	 * 整个战斗的Manager 
	 * @author SDD
	 * 
	 */
	public class BattleManager
	{
		
		private static var _instance:BattleManager;
		
		private static var _cardManager:BattleCardManager;
		private static var _battleAoyiManager:AoYiManager;
		private static var _guanghuanManager:GuangHuanSkillManager;
		
		private var _status:int = 0;								//记录当前的状态  战斗，或者是在回放
		
		public var battleMode:int = 0;							//战斗模式
		private var _curWaveIndex:int = 0;
		private var enemyWaveData:Array=[];
		
		public var allUserHeroInfo:Array=[];
		public var pSideAtk:PowerSide;							//先手攻击的势力
		public var pSideDef:PowerSide;							//后手攻击的势力
		
		public var portraitGroupAtk:HeroPortraitGroup;
		public var portraitGroupDef:HeroPortraitGroup;
		
		private var _curRound:SingleRound;						//当前回合
		
		public var roundInfoPool:Array;						//round信息的集合
		
		private var roundVedioPool:Array;						//用于回放的round信息集合
		
		public var allChainInfo:Object={};
		
		public var curBattleResult:BattleResult = new BattleResult;						//战斗的结果
	
		private var m_battleend_callback:Function;
		private var m_seekDropInfoFunc:Function;
		
		public var enableMorale:Boolean = true;   
		public var enableMoraleTemporary:Boolean = false;
		
		private var exitTimer:Timer;
		private var exitErrorCode:int;
		
		public var executeParma:Array;
		
		public var opponentAvatarData:AvatarConfig = new AvatarConfig();			//离线pvp的时候取得的对手的avatar信息
		
		public var curWaitFanjiChain:Object={};
		
		public var curHangSkillAttackChains:Object={};
		
		public static var needDebugBattle:Boolean = false;
		public static var needTraceBattleInfo:Boolean = false;
		
		private var atksideFormation:Array;
		
		private var fakeRoundTimer:Timer;
		
		private var illeageRoundCount:int = 0;
		
		public function BattleManager()
		{
		}
		
		/**
		 *  初始化战斗全局的事件监听器
		 */
		private function initGlobalEvent():void
		{
			//处理战斗开始的情形
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleStartEvent.BATTLE_START,battleStartHandler);
			
			//检查战斗是否结束
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,CheckBattleEndEvent.BATTLE_END,checkBattleEnd);
			//检查回合是否结束
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,CheckRoundEndEvent.ROUND_END,checkRoundEnd);
			
			//处理troop死亡的情形
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,TroopDeadEvent.TROOPDEADEVENT,handlerTroopDead);
			
			//检查是否有cell能够进行攻击或者播放下一条chain
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,CheckAttackEvent.CHECK_AttackORPlay,checkNextAtkOrPlay);
		}
		
		/**
		 * 单键模式 
		 * @return 
		 */
		public static function get instance():BattleManager
		{
			if(_instance == null)
			{
				_instance = new BattleManager;
			}
			return _instance;
		}
		
		/**
		 * 获得奥义manager 
		 * @return 
		 */
		public static function get aoyiManager():AoYiManager
		{
			if(_battleAoyiManager == null)
				_battleAoyiManager = new AoYiManager;
			return _battleAoyiManager;
		}
		
		/**
		 * 取得 BattleCardManager实例
		 * @return 
		 */
		public static function get cardManager():BattleCardManager
		{
			if(_cardManager == null)
				_cardManager = new BattleCardManager;
			return _cardManager;
		}
		
		/**
		 * 获得光环的管理器 
		 * @return 
		 */
		public static function get guanghuanManager():GuangHuanSkillManager
		{
			if(_guanghuanManager == null)
				_guanghuanManager = new GuangHuanSkillManager;
			return _guanghuanManager;
		}
		
		/**
		 * 设置获得取得掉落物品的函数
		 * @param unitId
		 */
		public function setDropSeekFunc(callfunc:Function):void
		{
			m_seekDropInfoFunc = callfunc;
		}
		
		/**
		 * battle开始的接口 
		 * @param defFromationInfo
		 * @param callback
		 * @param battleMode
		 */
		public function startBattle(defFromationInfo:Array,callback:Function = null,battleMode:int = 0,atkFormation:Array = null):void
		{
			
			DemoManager.curStage = 0;
			
//			BattleInfoSnap.allResKeys = ResourcePool.getCurResCountInMemory();
//			BattleInfoSnap.allEnginePlayers = AnimatorEngine.getAllPlayerIds();
			
			BattleParamConfig.instance.recordConfig();
			
			if(this.status != OtherStatusDefine.battleIdle)				//此时战斗已经在准备了
			{
				trace("重复战斗");
				BattleFunc.showOnlineBattleWaitMask(false);
				return;
			}
			
			this.battleMode = battleMode;
			
			//有onlinemanager的情况下，要清空信息
			if(!BattleModeDefine.checkNeedServerData() && !BattleModeDefine.isDarenFuBen() && !BattleInfoSnap.isDuoqiPVE && !BattleInfoSnap.isDuoqiPvp && battleMode == BattleModeDefine.PVE_TongTianTa)
			{
//				BattleHandler.instance.onLineManager = null;
				UserOnlineManager.setCurManagerInfo(UserOnlineManager.Online_Nothing,null);
			}
			
			if(this.battleMode == BattleModeDefine.PVE_Single)
			{
				if(defFromationInfo.length > 1)
				{
					this.battleMode = BattleModeDefine.PVE_SingleMultipleWaves;
				}
			}
			else if(this.battleMode == BattleModeDefine.PVE_KuaiSuZhanDou)
			{
				if(defFromationInfo.length > 1)
				{
					this.battleMode = BattleModeDefine.PVE_KuaiSuZhanDouMulWaves;
				}
			}
			
			addEnemyWaves(defFromationInfo);
			m_battleend_callback = callback;
			
			BattleDisplayDefine.cellGapVertocal = -10;
			if(!BattleModeDefine.checkNeedServerData())
			{
				if(BattleInfoSnap.needControlBattle)
					atksideFormation = atkFormation;
				else if(atkFormation != null)
					atksideFormation = atkFormation;
				BattleDisplayDefine.cellGapVertocal = -10;
			}
			else if(battleMode == BattleModeDefine.PVE_Multi)
			{
				atksideFormation = atkFormation;
				BattleDisplayDefine.cellGapVertocal = -10;
			}
			else if(battleMode == BattleModeDefine.PVE_Raid)
			{
				atksideFormation = atkFormation;
				BattleDisplayDefine.cellGapVertocal = -20;
			}
			else
			{
				atksideFormation = atkFormation;
			}
			
			var defFromation:Array = BattleManager.instance.enemyWaveData[BattleManager.instance.curWaveIndex];
			if((defFromation == null)||(defFromation.length==0))
			{
				BattleManager.instance.exitBattle(ErrorCode.FORMATION_SELFNULL);
				BattleFunc.showOnlineBattleWaitMask(false);
				return;
			}
			if((atksideFormation == null)||(atksideFormation.length==0))
			{
				BattleManager.instance.exitBattle(ErrorCode.FORMATION_OPPONULL);
				BattleFunc.showOnlineBattleWaitMask(false);
				return;
			}
			
			GameResourceManager.isBattleLoading = true;
			
			this.status = OtherStatusDefine.battlePrepareing;
			
			BattleInfoSnap.isOnBattle = true;
			
			if(this.battleMode == BattleModeDefine.PVE_Instance)
			{
				initBattleInfo();
				BattleUnitPool.initFormationInfo(atksideFormation);
				var curArmInfo:Object = this.getRemainInfoByBaseArmId();
			}
			else
			{
				startBattleLogic();
			}
		}
		
		private function checkArmSupplyCallBack(params:Array):void
		{
			if(!BattleInfoSnap.isOnBattle)
				return;
			if(params[0] != ErrorCode.suc)
				return;
			BattleInfoSnap.armSupplyLeftTime = params[1];
			BattleInfoSnap.armSupplyBuyCount = params[4];
			BattleInfoSnap.armSupplyBeishuValue = params[5];
			BattleInfoSnap.armSupplyDropRandoms = params[6];
			
			if(params.length > 2)
				BattleInfoSnap.guildRatioCoin = params[2];
			if(params.length > 3)
				BattleInfoSnap.guildRatioCoin = params[3];
			
			BattleTimeSecurer.initSecureInfo();
			
			ResLoadCompleteAgent.setCurFuncInfo(BattleUnitPool.battleResourceLoaded,[BattleUnitPool.usedTroopInfo]);
			BattleResourceCopy.analyseResToLoad(ResLoadCompleteAgent.executeFunc);
			GameResourceManager.startLoad(ResLoadCompleteAgent.onResLoadCompleteCall,GameResourceManager.normalBack);
		}
		
		private function startBattleLogic():void
		{
			BattleFunc.showOnlineBattleWaitMask(false);
			initBattleInfo();
			BattleUnitPool.initFormationInfo(atksideFormation);
			
			ResLoadCompleteAgent.setCurFuncInfo(BattleUnitPool.battleResourceLoaded,[BattleUnitPool.usedTroopInfo]);
			BattleResourceCopy.analyseResToLoad(ResLoadCompleteAgent.executeFunc);
			
			var allResNeed:Array = FakeFormationLineMaker.getAllResNeed();
			GameResourceManager.addResIdArr(allResNeed);
			
			GameResourceManager.startLoad(ResLoadCompleteAgent.onResLoadCompleteCall,GameResourceManager.normalBack);
		}
		
		private function battleTimerMoveStep(event:Event):void
		{
			if(BattleInfoSnap.armSupplyLeftTime <= 0)			// 如果此时已经有了
			{
				BattleInfoSnap.curBattleCount = 0;
				return;
			}
			if(this.battleMode == BattleModeDefine.PVE_Instance)			//刷怪点可能要加血
			{
				BattleInfoSnap.armSupplyLeftTime--;
				BattleInfoSnap.armSupplyLeftTime = Math.max(0,BattleInfoSnap.armSupplyLeftTime);
				BattleInfoSnap.curBattleCount++;
				if(BattleStage.instance.battleBackGroundLayer)
				{
					BattleStage.instance.battleBackGroundLayer.updateTimeCountBackShowInfo();
				}
				if(BattleInfoSnap.curBattleCount % BattleValueDefine.armSupplyWorkGap == 0)
				{
					//加血
					BattleManagerLogicFunc.makeArmSupplyWork();							//armsupply作用
					BattleInfoSnap.curBattleCount = 0;
				}
				if(BattleInfoSnap.armSupplyLeftTime <= 0)
				{
					TroopDisplayFunc.showAllArmSupplyEffect(false);
				}
			}
		}
		
		/**
		 * 取得下一波的敌军数据 
		 * @param defFromationInfo
		 * 
		 */
		public function addEnemyWaves(defFromationInfo:Array):void
		{
			if(defFromationInfo != null)
			{
				var singleFormation:Array;
				for(var i:int = 0; i < defFromationInfo.length;i++)
				{
					singleFormation = defFromationInfo[i] as Array;
					if(singleFormation)
					{
						this.enemyWaveData.push(singleFormation);
					}
				}
			}
		}
		
		/**
		 * 初始化信息 
		 * 
		 */
		private function initBattleInfo():void
		{
			roundInfoPool =[];
			roundVedioPool =[];
			CombatChain.curChainIndex = 0;
			curBattleResult = new BattleResult;
			initGlobalEvent();
			BattleStage.instance.initBattleStage();
		}
		
		/**
		 * 处理整场战斗开始的情形,所有资源加载完成后的的初始化入口
		 * @param event
		 */
		private function battleStartHandler(event:BattleStartEvent):void
		{
			this.status = event.battleMode;	
			BattleInfoSnap.gotCommandBack = true;
			BattleInfoSnap.curWaitOnRoundIndex ={};
			
			var allTroops:Array = BattleUnitPool.getAllTroops();
			for each(var singleTroop:CellTroopInfo in allTroops)
			{
				if(singleTroop)
					singleTroop.initTroopsStats();
			}
			BattleStage.instance.troopLayer.makeTroopAwayFromCenter();
			
			if(BattleModeDefine.checkNeedServerData())					//如果需要跟服务器同步
			{
				BattleHandler.instance.onLineManager.battleResLoadDone();		//告诉服务器结束了
				return;
			}
			BattleInfoSnap.curSelfArmCount = this.getRemainInfoByBaseArmId();
			startBattleWithServerReply();
			
			if(BattleInfoSnap.bossbattle)
			{
				BattleStage.instance.showGreatEffectByRid(611)
			}
		}
		
		/**
		 *  真正开始战斗
		 */
		public function startBattleWithServerReply():void
		{
			if(battleMode == BattleModeDefine.PVE_Raid)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.CommonEventHandler,new Event(WaitUserShowOfRaid.Event_ShowWaitUsers));
			}
			
			var moveGapInfo:Object = BattleFunc.seachFillUpTroops(BattleManager.instance.pSideAtk);
			var moveGapInfoDef:Object = BattleFunc.seachFillUpTroops(BattleManager.instance.pSideDef);
			
			BattleStage.instance.troopLayer.makeTroopMoveToCenter(moveGapInfo,moveGapInfoDef);
			pSideAtk.refreshLastRowIndex();
			pSideDef.refreshLastRowIndex();
			
			if(this.battleMode == BattleModeDefine.PVE_Instance)
			{
				GameEventHandler.addListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_globalTimerMoveForward,battleTimerMoveStep);
			}
		}
		
		private function onFightCostEquipCallback(param:Array):void
		{
		}
		
		/**
		 * 开始下一波的战斗 
		 */
		public function startNextWave():void
		{
//			this.battleMode = BattleModeDefine.PVE_Instance;	 
			if(this.battleMode == BattleModeDefine.PVE_Instance || this.battleMode == BattleModeDefine.PVE_XiuLian || this.battleMode == BattleModeDefine.PVE_SingleMultipleWaves || 
				this.battleMode == BattleModeDefine.PVE_KuaiSuZhanDouMulWaves || BattleModeDefine.isDarenFuBen())
			{
				this.status = OtherStatusDefine.battleOn;
				startNextWaveBattleReal();
			}
			else if(this.battleMode == BattleModeDefine.PVE_Multi)
			{
				this.status = OtherStatusDefine.battleOn;
			}
			if(BattleModeDefine.isGeneralRaid)
			{
				this.status = OtherStatusDefine.battleOn;
			}
//			BattleStage.instance.troopLayer.checkNextWaveMoveToDaiJi();
		}
		
		public function startNextPlayerTeamInfo():void
		{
			if(this.battleMode == BattleModeDefine.PVE_Raid)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.CommonEventHandler, new Event(WaitUserShowOfRaid.Event_ClearShow));
				this.status = OtherStatusDefine.battleOn;
			}
		}
		
		/**
		 *  下波战斗可以开始
		 */
		public function startNextWaveBattleReal():void
		{
			if(!BattleInfoSnap.isOnBattle)
				return;
			var moveGapInfoDef:Object = BattleFunc.seachFillUpTroops(BattleManager.instance.pSideDef);
			
			curBattleResult.userLost ={};
			curBattleResult.pveEnemyLost ={};
			
			BattleInfoSnap.curWaitOnRoundIndex ={};
			BattleStage.instance.troopLayer.makeSingleWaveMoveToCenter(moveGapInfoDef);
			
			//神符耐久度磨损,刷怪的时候单波进行处理
			if(this.battleMode == BattleModeDefine.PVE_Instance)
			{
				var allArmIds:Array = BattleFunc.getAllArmidsOnBattle();
			}
		}
		
		/**
		 *  下一队战斗可以开始
		 */
		public function startNextTeamBattleReal():void
		{
			if(!BattleInfoSnap.isOnBattle)
				return;
			GameEventHandler.dispatchGameEvent(EventMacro.CommonEventHandler,new Event(WaitUserShowOfRaid.Event_ShowWaitUsers))
			var moveGapInfoAtk:Object = BattleFunc.seachFillUpTroops(BattleManager.instance.pSideAtk);
			curBattleResult.userLost ={};
			curBattleResult.pveEnemyLost ={};
			BattleInfoSnap.curWaitOnRoundIndex ={};
			BattleInfoSnap.isNextTeamMoveEnd = true;
			BattleStage.instance.troopLayer.makeAtkSideMoveToCenter(moveGapInfoAtk);
			
			//上传自己的神符耐久度
			if(this.battleMode == BattleModeDefine.PVE_Raid && !BattleInfoSnap.hasCostArm )
			{
				BattleInfoSnap.hasCostArm == true;
				var allArmIds:Array = BattleFunc.getAllArmidsOnBattle();
			}
		}
		
		/**
		 * 检查是否结束 
		 * @param event
		 */
		public function checkBattleEnd(event:CheckBattleEndEvent = null):void
		{
			var atkOver:Boolean = true;
			var defOver:Boolean = true;
			
			var atkCells:int = BattleFunc.getPowerSideCellCount();
			
			var i:int = 0;
			var singleCell:Cell;
			for(i = 0; i < atkCells; i++)
			{
				singleCell = BattleUnitPool.getCellInfo(i) as Cell;
				if(singleCell && singleCell.troopInfo != null && !singleCell.troopInfo.isHero && singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && singleCell.troopInfo.attackUnit.isOnJudgeList)
				{
					atkOver = false;
					break;
				}
			}
			
			var defCells:int = BattleFunc.getPowerSideCellCount(false);
			for(i = atkCells; i < defCells + atkCells; i++)
			{
				singleCell = BattleUnitPool.getCellInfo(i) as Cell;
				if(singleCell.troopInfo != null && !singleCell.troopInfo.isHero && singleCell.troopInfo.logicStatus != LogicSatusDefine.lg_status_dead && singleCell.troopInfo.attackUnit.isOnJudgeList )
				{
					defOver = false;
					break;
				}
			}
			
			if(!atkOver && !defOver)
				return;
			
			if(DemoManager.gapTimer && DemoManager.gapTimer.running)
				return;
			
			if(NextSupplyShow.instance.isAllStarQualified)
				return;
			
			if(defOver)
			{
				if(DemoManager.curStage < 3 || DemoManager.curStageArmCount > 0)
					return;						
			}
			
			BattleManager.instance.status = OtherStatusDefine.battleIdle;		//战斗结束，置状态
			
			if(atkOver && defOver)
			{
				curBattleResult.resultSummary = BattleResultValue.resultDraw;
			}
			else if(!atkOver && defOver)
			{
				curBattleResult.resultSummary = BattleResultValue.resultWin;
			}
			else if(atkOver && !defOver)
			{
				curBattleResult.resultSummary = BattleResultValue.resultLose;
			}
			
			curBattleResult.updateResultInfo();
			
			if(battleMode == BattleModeDefine.PVE_Instance || battleMode == BattleModeDefine.PVE_XiuLian || battleMode == BattleModeDefine.PVE_SingleMultipleWaves || 
				BattleManager.instance.battleMode == BattleModeDefine.PVE_KuaiSuZhanDouMulWaves || BattleModeDefine.isDarenFuBen() || battleMode == BattleModeDefine.PVE_TongTianTa)
			{
				if(curBattleResult.resultSummary == BattleResultValue.resultWin)
				{
					if(curWaveIndex >= enemyWaveData.length)		//没有下一波数据,直接结束
					{
						BattleInfoSnap.battleCurStatus = BattleDefine.battleEnd;
						if(!BattleModeDefine.isDarenFuBen() && battleMode != BattleModeDefine.PVE_TongTianTa)
							exitBattle();
					}
					else				//有下波数据
					{
						BattleInfoSnap.battleCurStatus = BattleDefine.battleSingleWaveEnd;
						if(battleMode == BattleModeDefine.PVE_Instance)
						{
							BattleInfoSnap.curArmLeftOfAttack = this.getRemainInfoByBaseArmId();
						}
						if(m_battleend_callback != null)
						{
							this.status = OtherStatusDefine.battleOn;
							m_battleend_callback(ErrorCode.suc,curBattleResult);
							if(battleMode == BattleModeDefine.PVE_Instance)
							{
								BattleTimeSecurer.initSecureInfo();
							}
						}
						
						//开始下一波战斗
						clearSinglePowerSide(BattleDefine.secondAtk);
						initNextWaveInfo();
						this.status = OtherStatusDefine.battleIdle;
					}
				}
				else
				{
					BattleInfoSnap.battleCurStatus = BattleDefine.battleEnd;
					if(!BattleModeDefine.isDarenFuBen())
						exitBattle();					//战斗失败，或结束，直接结束
				}
			}
			else
			{
				exitBattle();	
			}
		}
		
		public function exitBattleWhenOffLinePvp():void
		{
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance)
			{
				BattleManager.instance.curBattleResult.updateResultInfo();
			}
			BattleManager.instance.clearBattleInfo();
		}
		
		/**
		 *  退出出战斗
		 * 
		 */
		public function exitBattle(errorCode:int = 0):void
		{
			exitErrorCode = errorCode;
			this.status = OtherStatusDefine.battleIdle;
			if(exitErrorCode == ErrorCode.suc)
			{
				if(battleMode == BattleModeDefine.PVE_Instance)
				{
					BattleInfoSnap.curArmLeftOfAttack = this.getRemainInfoByBaseArmId();
				}
				initExitTimer(true);
			}
			else
				clearBattleInfo(null);
		}
		
		/**
		 * 初始化退出的timer 
		 * @param init
		 */
		private function initExitTimer(init:Boolean = true):void
		{
			if(exitTimer != null)
			{
				exitTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,clearBattleInfo);
				exitTimer.stop();
				exitTimer = null;
			}
			if(init)
			{
				exitTimer = new Timer(BattleDisplayDefine.exitTime,1);
				exitTimer.addEventListener(TimerEvent.TIMER_COMPLETE,clearBattleInfo);
				exitTimer.start();
			}
		}
		
		/**
		 *  清空战场上所有信息
		 */
		public function clearBattleInfo(event:TimerEvent = null):void
		{
			if(fakeRoundTimer != null)
			{
				fakeRoundTimer.removeEventListener(TimerEvent.TIMER,onSingleFakeRoundStart);
				fakeRoundTimer.stop();
				fakeRoundTimer = null;
			}
			
			DeadEnemyProgressShow.instance.curCount = 0;
			DeadEnemyCycle.instance.clearInfo();
			
			var needDeleteOnLineManager:Boolean = false;
			
			BattleManager.instance.enableMoraleTemporary = false;
			BattleInfoSnap.heroInfoToCallBack = null;
			BattleInfoSnap.ftipType = 0;
			
			SingleRound.roungIndex = 0;
			this.status = OtherStatusDefine.battleIdle;
			allUserHeroInfo =[];
			
			if(BattleModeDefine.checkNeedServerData())
			{
				if(curBattleResult && executeParma)
					curBattleResult.resolveInfoFromServerData(executeParma);
			}
			
			if(this.battleMode == BattleModeDefine.PVP_OLCapTure)
			{
				var leftPercent:Array = BattleFunc.getWallArmyLeftPercent();
				if(m_battleend_callback != null)
					m_battleend_callback(exitErrorCode,curBattleResult,leftPercent[0],leftPercent[1]);
			}
			else
			{
				if(m_battleend_callback != null)
					m_battleend_callback(exitErrorCode,curBattleResult);
			}
			
//			if(needDeleteOnLineManager)
//				BattleHandler.instance.onLineManager = null;				//夺旗战斗的时候不清理
			
//			if(battleMode == BattleModeDefine.PVE_Raid)
//				BattleHandler.instance.onLineManager = null;
			
			m_seekDropInfoFunc = null;
			
			executeParma = null;
			
			exitErrorCode = 0;
			_curWaveIndex = 0;
			enemyWaveData =[];
			
			initExitTimer(false);
			
//			BattleStage.instance.visible = false;
			
			BattleStage.instance.showBattle(false);
			BattleStage.instance.clearInfo();
			
			//删除所有的监听器
			GameEventHandler.removeAllListener(EventMacro.NORMAL_BATTLE_EVENT);
			GameEventHandler.removeAllListener(EventMacro.DAMAGE_WAIT_HANDELR);
			GameEventHandler.removeAllListener(EventMacro.OTHER_WAIT_HANDLER);
			
			BattleUnitPool.clearInfo();
			
			for(var singleKey:String in allChainInfo)
			{
				var singleChain:CombatChain = allChainInfo[singleKey];
				if(singleChain)
				{
					singleChain.clearChainInfo();
				}
				singleChain = null;
				allChainInfo[singleKey] = null;
			}
			allChainInfo ={};
			
			EffectOnCau.clearAllEffectInfo();
			
			if(roundInfoPool)
			{
				while(roundInfoPool.length > 0)
				{
					var singleObj:SingleRound = roundInfoPool.pop();
					singleObj.clearRoundInfo();
					singleObj = null;
				}
			}
			
			CombatChain.curChainIndex = 0;
			CellTroopInfo.globalTroopIndex = 0;
			
			//清除此次战斗用到的所有临时特效
			for each(var singlePlayer:String in TroopDisplayFunc.effectPlayerIdArr)
			{
				if(singlePlayer != null && singlePlayer != "")
					AnimatorEngine.removePlayer(singlePlayer);
			}
			TroopDisplayFunc.effectPlayerIdArr =[];
			
			if(portraitGroupAtk)
			{
				if(BattleStage.instance.troopLayer.contains(portraitGroupAtk))
					BattleStage.instance.troopLayer.removeChild(portraitGroupAtk);
				portraitGroupAtk.clearInfo();
				portraitGroupAtk = null;
			}
			
			if(portraitGroupDef)
			{
				if(BattleStage.instance.troopLayer.contains(portraitGroupDef))
					BattleStage.instance.troopLayer.removeChild(portraitGroupDef);
				portraitGroupDef.clearInfo();
				portraitGroupDef = null;
			}
			
			pSideAtk && pSideAtk.clear();
			pSideDef && pSideDef.clear();
			
			pSideAtk = null;
			pSideDef = null;
			
			m_battleend_callback = null;
			
			BattleManager.aoyiManager.clearInfo();
			BattleManager.cardManager.clearInfo();
			
			BattleInfoSnap.clearInfo();
			
			BattleResourcePool.clearInfo();
			
			opponentAvatarData = new AvatarConfig();
			
			atksideFormation =[];
			
			curHangSkillAttackChains ={};
			
			BattleManagerLogicFunc.clearManagerLogic();
			
			GameEventHandler.removeListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_globalTimerMoveForward,battleTimerMoveStep);
			
			curRound = null;
			
			GameEventHandler.dispatchGameEvent(EventMacro.CommonEventHandler, new Event(WaitUserShowOfRaid.Event_ClearShow));
			
			BattleInfoSnap.lastScenePlayMusic = -1;
			
			GameEventHandler.dispatchGameEvent(EventMacro.CommonEventHandler,new Event(BattleConstString.hideWaitForOther));
			
			ResourcePool.releaseHoldedData();			//将挂起的需要release的资源release
			
			GameResourceManager.cancelLoad();				//放弃加载
			BattleInfoSnap.isOnBattle = false;			
			
			BattleResourceCopy.clearAllCopyData();
			
			GameResourceManager.isBattleLoading = false;
			
			if(BattleModeDefine.checkNeedConsiderWave())
			{
				//波数
				ResourcePool.releaseResourceForceById(2325);
				ResourcePool.releaseResourceForceById(1412);
				ResourcePool.releaseResourceForceById(1427);
			}
			
			for(var ti:int = 0;ti < BattleUnitPool.tempResources.length;ti++)
			{
				ResourcePool.releaseResourceForceById(BattleUnitPool.tempResources[ti]);
			}
			
			for(ti = 0;ti < BattleUnitPool.resourceNeedToForceRelease.length;ti++)
			{
				ResourcePool.releaseResourceForceById(BattleUnitPool.resourceNeedToForceRelease[ti]);
			}
			
			for(ti = 0;ti < TroopActConfig.allResourceNeedToRelease.length;ti++)
			{
				ResourcePool.releaseResourceForceById(TroopActConfig.allResourceNeedToRelease[ti]);
			}
			for(ti = 0;ti < WeaponGenedEffectConfig.allResourceNeedToRelease.length;ti++)
			{
				ResourcePool.releaseResourceForceById(WeaponGenedEffectConfig.allResourceNeedToRelease[ti]);
			}
			
			TroopPool.clearTroopPool();
			
//			var curResArr:Array;
//			var ii:int;
//			curResArr = ResourcePool.getCurResCountInMemory();
//			for(ii = 0;ii < curResArr.length;ii++)
//			{
//				if(BattleInfoSnap.allResKeys.indexOf(curResArr[ii]) < 0)
//				{
//					trace(curResArr[ii]);
//				}
//			}
			
//			curResArr = AnimatorEngine.getAllPlayerIds();
//			for(ii = 0;ii < curResArr.length;ii++)
//			{
//				if(BattleInfoSnap.allEnginePlayers.indexOf(curResArr[ii]) < 0)
//				{
//					var singleTestPlayer:AnimatorPlayer = AnimatorEngine.getSinglePlayer(curResArr[ii]) as AnimatorPlayer;
//					if(singleTestPlayer is AnimatorPlayerSwf)
//					{
//						trace(curResArr[ii] + "类型为: AnimatorPlayerSwf");
//					}
//					else if(singleTestPlayer is AnimatorPlayerWithRender)
//					{
//						trace(curResArr[ii] + "类型为: AnimatorPlayerWithRender");
//					}
//					else if(singleTestPlayer is AnimatorPlayerEffectBase)
//					{
//						trace(curResArr[ii] + "类型为: AnimatorPlayerEffectBase");
//					}
//					else
//					{
//						trace(curResArr[ii] + "类型为: AnimatorPlayer");
//					}
//				}
//			}
			
			TroopActConfig.allResourceNeedToRelease = [];
			WeaponGenedEffectConfig.allResourceNeedToRelease = [];
			
			battleMode = 0;
			
			BattleTimeSecurer.clearSecureTime();
			
			DemoManager.clearInfo();
			NextSupplyShow.instance.clearInfo();
			
			BattleParamConfig.instance.initBattleParam();
		}
		
		/**
		 * 清空某一方的所有数据 
		 * @param owerSide
		 */
		public function clearSinglePowerSide(ownerSide:int):void
		{
			if(!BattleInfoSnap.isOnBattle)
				return;
			BattleUnitPool.clearSinglePowerSide(ownerSide);
			BattleStage.instance.troopLayer.clearInfo();
			if(ownerSide == BattleDefine.secondAtk)
			{
				portraitGroupDef.clearInfo();
				portraitGroupDef = null;
				pSideDef.clear();
				BattleInfoSnap.dropinfoCheckedTroops ={};
			}
			else
			{
				if(portraitGroupAtk)
					portraitGroupAtk.clearInfo();
				portraitGroupAtk = null;
				pSideAtk.clear();
			}
			pSideDef.curRow = 0;
			pSideAtk.curRow = 0;
			pSideAtk.curCheckRow = 0;
			this.opponentAvatarData = new AvatarConfig();		
		}
		
		/**
		 *  初始化下一波敌人
		 */
		public function initNextWaveInfo():void
		{
			BattleUnitPool.initSingleWaveInfo();
		}
		
		/**
		 *  初始化下一队队伍
		 */
		public function initNextTeam():void
		{
			BattleInfoSnap.canFirstAtkGuanghuangWork = false;
		}
		
		/**
		 * 检查回合是否结束 
		 * @param event
		 */
		private function checkRoundEnd(event:CheckRoundEndEvent = null):void
		{
			if(!BattleInfoSnap.isOnBattle || _curRound == null)
				return;
			var isRoundOver:Boolean = _curRound.checkRoundIsOver();
			if(isRoundOver)
			{
				BattleManagerLogicFunc.makeHeroDeadFill();
			}
		}
		
		/**
		 * 处理troop被消灭，补进的情形 
		 * @param event
		 */
		public function handlerTroopDead(event:TroopDeadEvent):void
		{
			var targetTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(event.troopIndex);
			
			BattleInfoSnap.addSingleMappedDeadTroop(targetTroop);				
			
			//清除下一帧需要work的目标为此troop的chain
			BattleManagerLogicFunc.clearChainsWaitsToWorkNextFrame(event.troopIndex);
			
			pSideAtk.refreshLastRowIndex();
			pSideDef.refreshLastRowIndex();
			
			BattleManagerLogicFunc.checkTroopDeadFill(targetTroop);			//判断补进消息
			
			if(targetTroop.ownerSide == BattleDefine.firstAtk)
			{
				var powerSide:PowerSide = BattleFunc.getSidePowerInfoForTroop(targetTroop);
				powerSide.checkHeroDead(targetTroop);					//判断英雄是否死亡
			}
			else
			{
				DeadEnemyProgressShow.instance.handleSingleEnemyDead();
				DeadEnemyCycle.instance.handleSingleEnemyDead();
			}
		}
		
		/**
		 * 检查是否能继续攻击或者继续播放记录 
		 * @param event
		 */
		private function checkNextAtkOrPlay(event:CheckAttackEvent):void
		{
			if(BattleManager.instance.status == OtherStatusDefine.battleOn)								//如果战斗正在进行
			{
				checkCellCanAttack();
			}

		}
		
		/**
		 * 检查当前回合是否有cell是否可以攻击 
		 * 如果没有，检查是否回合结束
		 */
		private function checkCellCanAttack():void
		{
			if(!BattleInfoSnap.isOnBattle)
				return;
			var cellRemain:Boolean = false;
			var needRemoveFanjiChainInfo:Array = [];
			
			var allChainsInOrder:Array = [];
			
			for(var fanjiKey:String in curWaitFanjiChain)
			{
				allChainsInOrder.push(int(fanjiKey));
			}
			
			for(var sindex:int = 0;sindex < allChainsInOrder.length;sindex++)
			{
				var fanjiChainIndex:int = allChainsInOrder[i];
				if(BattleManager.needTraceBattleInfo)
					trace("检查反击chainIndex为:",fanjiChainIndex);
				var contentChainInfo:CombatChain = allChainInfo[fanjiChainIndex];
				if(contentChainInfo)
				{
					var fanjiResult:int = contentChainInfo.simplyCheckFanjiWork();
					if(fanjiResult == BattleDefine.fanjiChain_suc)
					{
						cellRemain = true;
						needRemoveFanjiChainInfo.push(fanjiChainIndex);
						BattleInfoSnap.needFanjiChains[fanjiChainIndex] = curWaitFanjiChain[fanjiChainIndex];
//						if(BattleManager.needTraceBattleInfo)
//							trace("checkCellCanAttack中成功反击成功 ",'反击者: ',contentChainInfo.atkTroopIndex,"被反击者: ",contentChainInfo.defTroopIndex," 当前帧数:",BattleInfoSnap.curBattleFrame);
					}
					if(fanjiResult == BattleDefine.fanjiChain_noNeed)
					{
						needRemoveFanjiChainInfo.push(fanjiChainIndex);
					}
					if(fanjiResult == BattleDefine.fanjiChain_fail)
					{
//						if(BattleManager.needTraceBattleInfo)
//							trace("checkCellCanAttack中成功反击失败 ",'反击者: ',contentChainInfo.atkTroopIndex,"被反击者: ",contentChainInfo.defTroopIndex," 当前帧数:",BattleInfoSnap.curBattleFrame);
					}
				}
			}
			
			for(var i:int = 0;i < needRemoveFanjiChainInfo.length;i++)
			{
				delete curWaitFanjiChain[needRemoveFanjiChainInfo[i]];
			}
			
			if(cellRemain)				//有等待反击的chain
				return;
			
			var tempCellIndexArr:Array=[];
			
			if(_curRound != null && _curRound.allCellIndexObj)
			{
				for(var key:String in _curRound.allCellIndexObj)
				{
					if(_curRound.allCellIndexObj[key] == OtherStatusDefine.hasNotAttack)
					{
						tempCellIndexArr.push(int(key));
					}
					else
					{
						continue;
					}
				}
			}
			
			tempCellIndexArr.sort(Array.NUMERIC);
			for(i = 0; i < tempCellIndexArr.length;i++)
			{
				var cellInfo:Cell = BattleUnitPool.getCellInfo(tempCellIndexArr[i]);
				if(cellInfo)
				{
					if(_curRound.allCellIndexObj[cellInfo.index] != OtherStatusDefine.hasNotAttack)
						continue;
					var singleTroopinfo:CellTroopInfo = cellInfo.troopInfo;
					if(singleTroopinfo && singleTroopinfo.isAttackTroop && singleTroopinfo.logicStatus != LogicSatusDefine.lg_status_dead)
					{
						if(!singleTroopinfo.isHero && singleTroopinfo.attackUnit && singleTroopinfo.attackUnit.slotType != FormationElementType.ARROW_TOWER)
						{
							if(singleTroopinfo.totalHpValue <= 0)
							{
								singleTroopinfo.logicStatus = LogicSatusDefine.lg_status_dead;
								continue;
							}
						}
						else
						{
							if(!singleTroopinfo.visible)
								continue;
						}
						if(singleTroopinfo.checkAttack())
						{
							cellRemain = true;
						}
					}
				}
			}
			if(!cellRemain)				//如果没有需要攻击的cell，检查round是否已经结束
			{
				checkRoundEnd(null);
			}
		}
		
		private function danrenFubenSendCommand():void
		{
			var param:Array = [];
			param.push(BattleHandler.instance.onLineManager.curbattledata.battleid);
			param.push(GlobalData.owner.uid);
			if(this.battleMode == BattleModeDefine.PVE_DANRENFUBEN || this.battleMode == BattleModeDefine.PVE_DANRENFUBENWithLansquenet)
				param.push(BattleHandler.instance.onLineManager.roomid);
			else
				param.push(0);
			
			var deadEnemyInfo:Array = [];
			for(var ti:int = 0;ti < BattleInfoSnap.deadTroopEnemyIds.length;ti++)
			{
				var singleEnemyIndex:int = BattleInfoSnap.deadTroopEnemyIds[ti];
				deadEnemyInfo.push(singleEnemyIndex);
			}
			BattleInfoSnap.deadTroopEnemyIds = [];
			
			var needDecreaseArmInfo:int = 0;
			var armLostInfo:Object = new Object();
			if(BattleManager.instance.status == OtherStatusDefine.battleIdle)			//每一波加载完成
			{
				var oldValue:Object = BattleInfoSnap.curSelfArmCount;
				var newValue:Object = this.getRemainInfoByBaseArmId();
				for(var singleArmId:String in oldValue)
				{
					var oldArmValue:int = oldValue[singleArmId];
					var curValue:int = newValue[singleArmId];
					if(!armLostInfo.hasOwnProperty(singleArmId))
					{
						armLostInfo[singleArmId] = curValue - oldArmValue;
					}
					else
					{
						armLostInfo[singleArmId] = int(armLostInfo[singleArmId]) + curValue - oldArmValue;
					}
					armLostInfo[singleArmId] = Math.min(armLostInfo[singleArmId],0);
				}
				needDecreaseArmInfo = 1;
			}
			//发送战斗结果
			if(status == OtherStatusDefine.battleIdle)
			{
				if(BattleInfoSnap.battleCurStatus != BattleDefine.battleEnd)
				{
					//单波结束
					param.push([deadEnemyInfo,0,needDecreaseArmInfo,armLostInfo,curBattleResult.resultSummary,curWaveIndex]);
					if(this.battleMode == BattleModeDefine.PVE_TongTianTa)
					{
//						GameRaidManager.instance.curBdRaidData.curWaveIndex++;
//						var curLoop:int = GameRaidManager.instance.curBdRaidData.curFinishTimes;
//						if(curWaveIndex >= enemyWaveData.length)
//						{
//							curLoop++;
//							GameRaidManager.instance.curBdRaidData.setCurLoopTimes(curLoop);
//						}
					}
				}
				else
					param.push([deadEnemyInfo,1,needDecreaseArmInfo,armLostInfo,curBattleResult.resultSummary,curWaveIndex]);
				BattleInfoSnap.curSelfArmCount = newValue;
			}
			else
			{
				param.push([deadEnemyInfo,0,needDecreaseArmInfo,armLostInfo,0,curWaveIndex]);
			}
		}
		
		public function startFiveFakeRounds():void
		{
			if(fakeRoundTimer == null)
			{
				fakeRoundTimer = new Timer(0.5,5);
				fakeRoundTimer.addEventListener(TimerEvent.TIMER,onSingleFakeRoundStart);
				fakeRoundTimer.start();
			}
		}
		
		private function onSingleFakeRoundStart(event:TimerEvent):void
		{
			startNewRound();
		}
		
		/**
		 * 开始一个新的回合 
		 * 进行各种判断
		 */
		public function startNewRound(event:* = null):void
		{
			
			var deadTroopArr:Array = BattleInfoSnap.deadTroopsOnOneRound;
			for(var i:int = 0;i < deadTroopArr.length;i++)
			{
				var singleTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(deadTroopArr[i]);
				if(singleTroop && singleTroop.isHero && singleTroop.mcStatus == McStatusDefine.mc_status_dead)			//如果当前在播放死亡动作
					continue;
				TroopInitClearFunc.clearTroopSimply(singleTroop,false);
			}
			DemoManager.checkCombatStageChange();
			var param:Array = [];
			if(status == OtherStatusDefine.battleOn)											//此时正在进行战斗
			{
				//有引导，战斗不能
				if(BattleInfoSnap.canMoveOnRoundCount == 0)
				{
					if(BattleInfoSnap.wizardItToMoveOn > 0)
					{
						if(BattleStage.instance.daojuLayer)
						{
							BattleInfoSnap.battlecardMouseenabled = true;
						}
					}
					return;
				}
				BattleInfoSnap.isAoYiRound = false;
				if(SingleRound.roungIndex > BattleDefine.fakeRoundsAtBeginning)
				{
					BattleManager.instance.checkBattleEnd();
				}
				
				if(BattleManager.instance.status == OtherStatusDefine.battleIdle)			//单波敌人打完,或者战斗结束
				{
					return;
				}
				
				if(DemoManager.gapTimer && DemoManager.gapTimer.running)
					return;
				
				newRoundStartLogic(event);
			}
		}
		
		/**
		 *  开始下一回合的具体逻辑
		 */
		public function newRoundStartLogic(event:* = null):void
		{
			if(!BattleInfoSnap.isOnBattle)
				return;
			if(BattleManager.needTraceBattleInfo)
			{
				for(var singleTroopIndex:String in BattleInfoSnap.moveForwardHero)
				{
					if(BattleInfoSnap.moveForwardHero[singleTroopIndex] == 0)
						trace("英雄没有归位,战斗可能出现错乱,回合开始");
				}
			}
			
			if(curRound && !curRound.isRoundEnd)
				return;
			
			var newRoundInfo:SingleRound = new SingleRound();
			newRoundInfo.initBattleSecureTimer(true);
			BattleInfoSnap.oldRoundInfo = _curRound;
			if(_curRound)
				_curRound.initBattleSecureTimer(false);
			_curRound = newRoundInfo;
			roundInfoPool.push(_curRound);				//保存回合信息
			
			if(SingleRound.roungIndex <= BattleDefine.fakeRoundsAtBeginning)
				return;
			
			//双方刷新最大排值
			pSideAtk.refreshLastRowIndex();
			pSideDef.refreshLastRowIndex();
			
			var isAoyiRound:Boolean = false;
			
			if(BattleModeDefine.isPvEWithAoYi())
			{
				var aoyiRoundRecord:Object = BattleInfoSnap.enemyUnitAoyiRoundIndex;
				var allEnemyHeros:Array = pSideDef.allHeroInfoOnSide;
				for(var heroIndex:int = 0; heroIndex < allEnemyHeros.length;heroIndex++)
				{
					var singleHeroTroop:CellTroopInfo = allEnemyHeros[heroIndex];
					if(singleHeroTroop == null || singleHeroTroop.logicStatus == LogicSatusDefine.lg_status_dead)
						continue;
					if(!singleHeroTroop.troopVisibleOnBattle)
						continue;
					var enemyUnitId:int = singleHeroTroop.attackUnit.pveenemyunitid;
					var aoyiRoundIndex:int = 0;
					if(aoyiRoundRecord.hasOwnProperty(singleHeroTroop.troopIndex))
					{
						aoyiRoundIndex = aoyiRoundRecord[singleHeroTroop.troopIndex];
					}
					else
					{
						aoyiRoundRecord[singleHeroTroop.troopIndex] = 0; 
						aoyiRoundIndex = 0;
					}
					var singleUnitInfo:MapEnemyUnit = BattleFunc.getEnemyUnitById(enemyUnitId);
					if(singleUnitInfo == null)
						continue;
					var roundGap:int = SingleRound.roungIndex - aoyiRoundIndex;
					if(roundGap >= singleUnitInfo.castaoyi && singleUnitInfo.castaoyi > 0)
					{
						aoyiManager.addAoYiTroop(singleHeroTroop);
						isAoyiRound = true;
						BattleInfoSnap.enemyUnitAoyiRoundIndex[singleHeroTroop.troopIndex] = SingleRound.roungIndex;
					}
				}
			}
			
			var atkRow:int = 0;
			var defRow:int = 0;
			if(isAoyiRound)
			{
				newRoundInfo.roundType = BattleDefine.aoyiRound;
				BattleInfoSnap.isAoYiRound = true;
				atkRow = pSideAtk.xMaxValue - 1;
				defRow = pSideDef.xMaxValue - 1;
			}
			else
			{
				//记录当此需要攻击的排数
				atkRow = pSideAtk.curRow++;
				defRow = pSideDef.curRow++;
				
				pSideAtk.curRow = Math.min(pSideAtk.curRow,pSideAtk.xMaxValue);				//rowIndex不能超过最后一排 英雄排
				pSideDef.curRow = Math.min(pSideDef.curRow,pSideDef.xMaxValue);				//rowIndex不能超过最后一排 英雄排
				
				//如果都是到达最后一排，发动英雄攻击
				if(pSideAtk.curRow == pSideAtk.xMaxValue && pSideDef.curRow == pSideDef.xMaxValue)
				{
					pSideAtk.curRow = 0;
					pSideDef.curRow = 0;
				}
				
				//处理一方小兵攻击完成的情形，另一方继续攻击
				if(atkRow > pSideAtk.maxRowIndex && defRow <= pSideDef.maxRowIndex)
				{
					atkRow = -1;
					pSideAtk.curRow = pSideAtk.xMaxValue - 1;
				}
				else if(atkRow <= pSideAtk.maxRowIndex && defRow > pSideDef.maxRowIndex)
				{
					defRow = -1;
					pSideDef.curRow = pSideDef.xMaxValue - 1;
				}
				else if(atkRow > pSideAtk.maxRowIndex && defRow > pSideDef.maxRowIndex)
				{
					newRoundInfo.roundType = BattleDefine.heroRound;			//英雄攻击回合
					pSideAtk.curRow = 0;
					pSideDef.curRow = 0;
					atkRow = pSideAtk.xMaxValue - 1;
					defRow = pSideDef.xMaxValue - 1;
					BattleInfoSnap.isAoYiRound = false;
				}
			}
			
			BattleStage.instance.troopLayer.clearYUsedInfo();		//清空y方向上占用的值
			GameEventHandler.removeAllListener(EventMacro.OTHER_WAIT_HANDLER);	//清空等待时间差的所有等待函数
			GameEventHandler.removeAllListener(EventMacro.DAMAGE_WAIT_HANDELR);
			
			BattleInfoSnap.recordAllTroopSnapshot();
			this.curWaitFanjiChain ={};
			
			
			var curCardCount:int = cardManager.curWaitCard.length;
			if(BattleManager.needTraceBattleInfo)
				trace("-------------------------开始新回合--------------------------行数为:",atkRow,defRow);
			cardManager.handlerNewRoundBegin(newRoundInfo);		//攻处理卡片技能,加上各种buff
			
			BattleInfoSnap.battleContinueAtkRow = atkRow;
			BattleInfoSnap.battleContinueDefRow = defRow;
			BattleInfoSnap.continueEvent = event;
			
//			if(!BattleInfoSnap.needPauseBattle)
				makeBattleContinue();
		}
		
		public function makeBattleContinue():void
		{
			BattleInfoSnap.needPauseBattle = false;
			
			var atkResult:Boolean = makePowersideAttack(BattleInfoSnap.battleContinueAtkRow,BattleInfoSnap.battleContinueDefRow);
			
			if(!atkResult)
			{
				illeageRoundCount++;
				if(illeageRoundCount >= 3)
				{
					trace("need debug");
				}
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
			}
			else
			{
				illeageRoundCount = 0;
			}
			if(BattleInfoSnap.continueEvent)
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
			
			if(BattleInfoSnap.canMoveOnRoundCount > 0)
			{
				BattleInfoSnap.canMoveOnRoundCount--;
			}
			if(BattleInfoSnap.needCheckStuckSupply)
			{
				DemoManager.onGapTimerComplete(null);
			}
		}
		
		/**
		 * 让双方的势力进行攻击 
		 * 只会在回合开始的时候调用
		 */
		public function makePowersideAttack(atkRow:int,defRow:int):Boolean
		{
			if(status != OtherStatusDefine.battleOn)
				return false;
			//两方同时进行攻击，但是先手会有优势
			var retValue:Boolean = false;
			var atkMade:Boolean = false;
			
			this.pSideAtk.initStaggerTimeByVertical(atkRow);
			this.pSideDef.initStaggerTimeByVertical(defRow);
			
			if(BattleManager.needTraceBattleInfo)
				trace("+++++++++++++++开始产生攻击逻辑,当前帧数:",BattleInfoSnap.curBattleFrame);
			atkMade = this.pSideAtk.generateAtk(atkRow);
			if(atkMade)
			{
				retValue = true;
			}
			atkMade = this.pSideDef.generateAtk(defRow);
			if(atkMade)
				retValue = true;
			if(BattleManager.needTraceBattleInfo)
				trace("---------------结束产生攻击逻辑,当前帧数:",BattleInfoSnap.curBattleFrame);
			if(retValue)
			{
				DeadEnemyProgressShow.instance.curCount--;
			}
			return retValue;
		}
		
		/**
		 * 获得当前阵型上剩余的兵力信息 
		 * @return 
		 */
		public function getArmReaminInfo(powerSide:int):Array
		{
			BattleInfoSnap.curArmLeftCount = 0;
			var retValue:Array=[];
			var alltroops:Array = BattleUnitPool.getTroopsOfSomeSide(powerSide);
			var singleTroopInfo:CellTroopInfo;
			for(var i:int = 0; i < alltroops.length;i++)
			{
				singleTroopInfo = alltroops[i] as CellTroopInfo;
				if(singleTroopInfo == null || singleTroopInfo.isHero || singleTroopInfo.logicStatus == LogicSatusDefine.lg_status_dead)
					continue;
				if(singleTroopInfo.attackUnit.contentArmInfo == null)
					continue;
				var singleReaminInfo:FormationRemainInfo = new FormationRemainInfo(singleTroopInfo);
				retValue.push(singleReaminInfo);
				BattleInfoSnap.curArmLeftCount += singleReaminInfo.curArmCount;
			}
			return retValue;
		}
		
		/**
		 * 获得某种兵的剩余数量
		 * @return 
		 */
		public function getRemainInfoByBaseArmId():Object
		{
			var singleTroopInfo:CellTroopInfo;
			var retValue:Object={};
			var alltroops:Array = BattleUnitPool.getTroopsOfSomeSide(BattleDefine.firstAtk);
			for(var i:int = 0; i < alltroops.length;i++)
			{
				singleTroopInfo = alltroops[i] as CellTroopInfo;
				if(singleTroopInfo == null || singleTroopInfo.isHero)
					continue;
				if(this.battleMode == BattleModeDefine.PVE_DANRENFUBENWithLansquenet)
				{
					if(singleTroopInfo.attackUnit.contentArmInfo.uid != GlobalData.owner.uid)
						continue;
				}
				var baseArmId:int = singleTroopInfo.attackUnit.contentArmInfo.armid;
				if(retValue.hasOwnProperty(baseArmId))
				{
					var tempNum:int = retValue[baseArmId]; 
					retValue[baseArmId] = tempNum + singleTroopInfo.curArmCount;
				}
				else
				{
					retValue[baseArmId] = singleTroopInfo.curArmCount;
				}
			}
			return retValue;
		}
		
		public function getTotalWacesCount():int
		{
			return enemyWaveData.length;
		}
		
		public function getCurWaveEnemyInfo():Array
		{
			var retInfo:Array = enemyWaveData[_curWaveIndex];
			return retInfo;
		}
		
		public function getNextWaveEnemyInfo():Array
		{
			var nextWaveIndex:int;
			if(BattleModeDefine.isGeneralRaid)
			{
				nextWaveIndex = (_curWaveIndex + 1) % enemyWaveData.length;
				return enemyWaveData[nextWaveIndex];
			}
			else
			{
				nextWaveIndex = _curWaveIndex + 1;
				if(nextWaveIndex >= enemyWaveData.length)
					return null;
				return enemyWaveData[nextWaveIndex];
			}
			return null;
		}
		
		/**
		 * 当前计算或播放的round 
		 */
		public function get curRound():SingleRound
		{
			return _curRound;
		}

		/**
		 * @private
		 */
		public function set curRound(value:SingleRound):void
		{
			_curRound = value;
		}

		public function get status():int
		{
			return _status;
		}

		public function set status(value:int):void
		{
			_status = value;
		}

		public function get curWaveIndex():int
		{
			return _curWaveIndex;
		}

		public function set curWaveIndex(value:int):void
		{
			_curWaveIndex = value;
			if(this.battleMode != BattleModeDefine.PVE_Raid)
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleStage.newEnemyWaveBegin));
		}

		public static function get battleAoyiManager():AoYiManager
		{
			return _battleAoyiManager;
		}

		public static function set battleAoyiManager(value:AoYiManager):void
		{
			_battleAoyiManager = value;
		}
		
		public function get dropSeekFunc():Function
		{
			return m_seekDropInfoFunc;
		}
		
	}
}