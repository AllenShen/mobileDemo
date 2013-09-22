package modules.battle.managers
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import avatarsys.avatar.AvatarConfig;
	
	import defines.UserHeroInfo;
	
	import eventengine.GameEventHandler;
	
	import interfaces.IOnlineBattleManager;
	
	import macro.ArmType;
	import macro.EventMacro;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.battlelogic.NLianjiInfoStore;
	import modules.battle.battlelogic.SingleRound;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.funcclass.BattleManagerLogicFunc;
	import modules.battle.stage.BattleStage;
	
	import sysdata.MapEnemySeq;
	import sysdata.MapEnemyUnit;
	import sysdata.instance.InstanceCollectionInfo;

	/**
	 * 保存战斗过程中的临时信息
	 * @author Administrator
	 */
	public class BattleInfoSnap
	{
		//保存hero的偏移量信息
		private static var heroOffsetInfo:Object={};
		//troop攻击范围记录
		private static var troopAttackRangeObj:Object={};
		//被隐藏的troop信息
		private static var _hidedTroopOnAoYi:Dictionary = new Dictionary;
		public static var alphaDownTroops:Dictionary = new Dictionary;
		
		//此时下波敌人是否已经在待机区
		public static var isNextWaveOnDaiJiQu:Boolean = false;
		//此回合是否有奥义信息
		public static var isAoYiRound:Boolean = false;
		//记录此回合中英雄的士气值
		public static var heroMoraleInfo:Object={};
		//多波攻击时候是否含有可适英雄
		public static var hasVisibleHeroOnWave:Boolean = false;
		//记录各单位n连击的情形
		public static var nLianjieSnapInfo:Array=[];	
		//本回合中死亡的troop
		public static var deadTroopsOnOneRound:Array=[];
		//本回合中死亡的pveenemyid
		public static var deadTroopEnemyIds:Array = [];
		
		//本回合中使用到的随机值
		public static var usedRandomTagInRound:Object={};
		//是否已经得到返回的消息
		private static var _gotCommandBack:Boolean = true;
		//回合开始之前的所有的troop兵力信息
		public static var allTroopArmCountBeforeRound:Object={};
		//回合开始之前，进行奥义攻击的troop的targetcell位置
		public static var aoyiTroopTargetCellInfo:Object={};
		//处理过掉落奖励的troop集合
		public static var dropinfoCheckedTroops:Object={};
		//在刷怪的过程中记录战斗是否停止
		public static var isBattleEnd:Boolean = false;
		//记录敌人英雄最近施放奥义的回合index
		public static var enemyUnitAoyiRoundIndex:Object={};
		//兵营补给信息
		public static var armySupplyInfo:Object = {};
		public static var curRebornTroops:Object = {};
		//当前阵上的主英雄
		private static var _curMainHero:UserHeroInfo;
		//背景图
		public static var battleBackgroundId:int = 14001;
		//总的波数
		public static var maxWaveCount:int = 99;
		//还能走下去的回合数
		private static var _canMoveOnRoundCount:int = -1;
		//需要继续的引导id
		public static var wizardItToMoveOn:int = 0;
		//需要跳转到的玩家英雄信息
		public static var heroInfoToCallBack:UserHeroInfo;
		//跳转类型
		public static var ftipType:int = 0;
		//记录箭塔英雄信息
		public static var jianTaHeroRecord:Object={};
		//战斗是否需要累计伤害
		public static var needAccumulateDamage:Boolean = false;
		//当前等待的roundindex信息
		public static var curWaitOnRoundIndex:Object={};
		
		public static var oldRoundInfo:SingleRound;		
		
		//主动技能是否触发记录
		public static var zhudongjinengChuFaInfo:Object={};
		//被动技能触发记录
		public static var beidongjinengChuFaInfo:Object={};
		
		//当前战斗的frame
		public static var curBattleFrame:int = 0;
		//上一帧的所有伤害缓存
		public static var damageFrameHodler:Dictionary = new Dictionary();
		//卡牌是否鼠标可以点击
		public static var battlecardMouseenabled:Boolean = true;
		//记录是否已经计算过
		public static var zhongduCauInfo:Object={};
		
		//刷怪点获得的所有金币
		private static var _allCoinsFromShuaiGua:int = 0;
		
		//是否需要控制战斗
		public static var needControlBattle:Boolean = false;
		
		//是否关闭卡牌使用
		public static var needLockBattleCard:Boolean = false;
		
		//引导点击是否为路径
		public static var showDaJin:Boolean = false;
		
		//armsupply剩余的时间
		public static var armSupplyLeftTime:int = 0; 
		public static var armSupplyBuyCount:int = 0;
		public static var armSupplyBeishuValue:int = 0;
		public static var armSupplyDropRandoms:Array = [];
		
		//战斗的计数
		public static var curBattleCount:int = 0;
		
		public static var troopsHaveBeenSimplyCleared:Object={};				//已经被简单clear过的troop
		
		public static var allMovingTroops:Object={};
		public static var allVerticalMovingTroops:Object={};					//当前在进行
		
		public static var curArmLeftOfAttack:Object={};
		
		/**
		 *  向前移动的hero是否回来
		 */
		public static var moveForwardHero:Object={};	
		
		//向后台请求过的回合信息
		public static var askedRoundIndexInfo:Object={};
		//攻击方是否能够发动光环技能
		public static var canFirstAtkGuanghuangWork:Boolean = false;
			
		public static var curWaveofRaid:int = 0;					//raid中对应的波数
		
		public static var isNextTeamMoveEnd:Boolean = false;
		
		//副本里面敌人的个数
		public static var playerCountOfFuBen:int = 1;
		
		public static var isDuoqiPVE:Boolean = false;
		public static var isDuoqiPvp:Boolean = false;
		
		//记录每回合自己的兵力信息
		public static var curSelfArmCount:Object = {}; 
		
		public static var battleCurStatus:int = 0;
		
		public static var lastScenePlayMusic:int = 0;
		
		public static var curArmLeftCount:int = 0;
		
		public static var isRecovering:Boolean = false;
		
		public static var isOnBattle:Boolean = false;			//判断是否在战斗
		
		public static var hasCostArm:Boolean = false;
		
		public static var curOnLineManager:IOnlineBattleManager;
		
		public static var isWizardPast:Boolean = false;
		
		public static var allResKeys:Array;
		
		public static var allBattleEffets:Array = [];
		
		public static var allEnginePlayers:Array = [];
		
		public static var firstCardClickCount:int = 0;
		
		public static var verifiedCardInfo:Object = {};
		
		public static var guildRatioCoin:Number = 0;
		
		public static var guildRatioExp:Number = 0;
		
		public static var needFanjiChains:Object = {};
		
		public static var allUserAvatarInfo:Object = {};
		
		public static var heroMappedTroops:Object = {};
		public static var rebornedTroops:Array = [];
		public static var movingRebornTroops:Object = {};
		
		public static var battleContinueAtkRow:int = 0;
		public static var battleContinueDefRow:int = 0;
		public static var continueEvent:Event = null;
		public static var needPauseBattle:Boolean = false;
		
		public static var deadTroopList:Object = new Object();
		
		public static var isDaJinOutOfEnergy:Boolean = false;
		
		public static var wavegapTimeCount:int = 0;
		
		//是否boss战
		public static var bossbattle:Boolean = false;
		
		public static var xiulianSourceData:InstanceCollectionInfo;
		
		public static var curServerCommuIndex:int = 0;
		
		public static var isCurbattleWithWizard:Boolean = false;
		
		public static var curForceDeadTroops:Array = [];
		
		public static var usedSupplyTypes:Object = {};
		
		public static var MaxEnemySupplyCount:int = 50;
		public static var MaxSelfSupplyCount:int = 20;
		public static var hasHeroRecalled:Boolean = false;
		
		public static var canDirectCall:Boolean = false;
		
		public static var heroCalledCount:int = 0;
		
		public static var needCheckStuckSupply:Boolean = false;
		
		public static var hebingTarget:Object = new Object();
		
		public static var quanTiGongJiRound = 0; 
		
		public function BattleInfoSnap()
		{
		}
		
		/**
		 * 初始化avatar信息 
		 * @param obj
		 */
		public static function initUserAvatarInfo(obj:Object):void
		{
			for(var singleUid:String in obj)
			{
				var singleAvatarInfo:Array = obj[singleUid];
				var realAvataInfo:AvatarConfig = new AvatarConfig();
				realAvataInfo.loadPlayerAvatarInfo(singleAvatarInfo);
				allUserAvatarInfo[singleUid] = realAvataInfo;
			}
		}
		
		/**
		 * 获得单个avatar信息
		 * @param uid
		 */
		public static function getSingleUserAvatarInfo(uid:int):AvatarConfig
		{
			{
				if(allUserAvatarInfo[uid])
					return allUserAvatarInfo[uid];
			}
			return new AvatarConfig();
		}
		
		/**
		 * 保存当前所有英雄的偏移量
		 */
		public static function recordAllTroopSnapshot():void
		{
//			hebingTarget = {};
			hasHeroRecalled = false;
			needFanjiChains = {};
			allVerticalMovingTroops ={};
			moveForwardHero ={};
			BattleManagerLogicFunc.clearForSignleRound();
			zhongduCauInfo ={};
			heroOffsetInfo ={};
			heroMoraleInfo ={};
			nLianjieSnapInfo =[];
			deadTroopsOnOneRound = [];
			curRebornTroops = {};
			deadTroopEnemyIds = [];
			usedRandomTagInRound ={};
			allTroopArmCountBeforeRound ={};
			aoyiTroopTargetCellInfo ={};
			
			zhudongjinengChuFaInfo ={};
			beidongjinengChuFaInfo ={};
			
			damageFrameHodler = new Dictionary();
			curBattleFrame = 0;
			
			var i:int = 0;
			var singleTroop:CellTroopInfo;
			
			var allTroops:Array = BattleUnitPool.getAllTroops();
			for(i = 0; i < allTroops.length; i++)
			{
				singleTroop = allTroops[i] as CellTroopInfo;
				if(!singleTroop || singleTroop.logicStatus == LogicSatusDefine.lg_status_dead)
					continue;
				singleTroop.alldamageSource ={};
				singleTroop.beAtkCount = 0;
				if(!singleTroop.isHero)
				{
					allTroopArmCountBeforeRound[singleTroop.troopIndex] = singleTroop.curArmCount;
				}
				else
				{
					heroOffsetInfo[singleTroop.troopIndex] = singleTroop.heroOffectValue;
					heroMoraleInfo[singleTroop.troopIndex] = singleTroop.moraleValue;
				}
				singleTroop.needDispatchAtkEvent = false;
				singleTroop.haveDispatchAtkEvent = false;
			}
		}
		
		public static function addSingleDamgeInfo(chainInfo:CombatChain):void
		{
			var curFrameDamageInfo:Object = damageFrameHodler[curBattleFrame];
			if(curFrameDamageInfo == null)
			{
				curFrameDamageInfo ={};
				damageFrameHodler[curBattleFrame] = curFrameDamageInfo;
			}
			var targetTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(chainInfo.defTroopIndex);
			if(targetTroop && targetTroop.logicStatus != LogicSatusDefine.lg_status_dead && targetTroop.logicStatus != LogicSatusDefine.lg_status_waitingForNextWave)		
			{	
				curFrameDamageInfo[chainInfo.chainIndex] = chainInfo;
//				if(BattleManager.needTraceBattleInfo)
//				{
//					trace("在",curBattleFrame,"帧 ","插入待处理chain信息",chainInfo.atkTroopIndex);
//				}
			}
		}
		
		/**
		 * 获得本回合内troop的兵力变化次数 
		 * @return 
		 */
		public static function getArmChangeInfo():Object
		{
			var retValue:Object={};
			var i:int = 0;
			var singleTroop:CellTroopInfo;
			var oldCount:int = 0;
			var changeCount:int = 0;
			
			var allTroops:Array = BattleUnitPool.getAllTroops();
			for(i = 0; i < allTroops.length; i++)
			{
				singleTroop = allTroops[i] as CellTroopInfo;
				if(!singleTroop)
					continue;
				if(!singleTroop.isHero)
				{
//					oldCount = allTroopArmCountBeforeRound[singleTroop.troopIndex];
//					changeCount = singleTroop.curArmCount - oldCount;
//					if(changeCount != 0)
//					{
//						retValue[singleTroop.troopIndex] = changeCount;
//					}
					retValue[singleTroop.troopIndex] = singleTroop.curArmCount;
				}
			}
			return retValue;
		}
		
		/**
		 * 增加死亡的troop信息
		 * @param troopIndex
		 */
		public static function addDeadTroop(troopIndex:int):void
		{
			if(deadTroopsOnOneRound == null)
				return;
			if(deadTroopsOnOneRound.indexOf(troopIndex) < 0)
				deadTroopsOnOneRound.push(troopIndex);
			var targetTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(troopIndex);
			if(BattleModeDefine.isDarenFuBen() || BattleManager.instance.battleMode == BattleModeDefine.PVE_TongTianTa)
			{
				if(targetTroop && targetTroop.attackUnit && targetTroop.ownerSide == BattleDefine.secondAtk)
				{
					if(deadTroopEnemyIds.indexOf(targetTroop.attackUnit.pveenemyunitid) < 0)
					{
						deadTroopEnemyIds.push(targetTroop.attackUnit.pveenemyunitid);
					}
				}
			}
		}
		
		/**
		 * 增加暴击信息 
		 * @param troopIndex
		 */
		public static function addCrictInfo(troopIndex:int):void
		{
			var targetLianjieInfo:NLianjiInfoStore = nLianjieSnapInfo[troopIndex]; 
			if(targetLianjieInfo == null)
				return;
			targetLianjieInfo.isCirctl = true;
		}
		
		/**
		 * 判断某个在连击的troop是否处于暴击状态 
		 * @param troopIndex
		 */
		public static function getLianjiCritInfo(troopIndex:int):Boolean
		{
			var targetLianjieInfo:NLianjiInfoStore = nLianjieSnapInfo[troopIndex]; 
			if(targetLianjieInfo == null)
				return false;
			return targetLianjieInfo.isCirctl;
		}
		
		/**
		 *  删除后续的连击信息
		 * @param troopIndex				troopIndex
		 */
		public static function deleteUselessLianjiInfo(troopIndex:int):void
		{
			var targetLianjieInfo:NLianjiInfoStore = nLianjieSnapInfo[troopIndex]; 
			if(targetLianjieInfo == null)
				return;
			targetLianjieInfo.deleteUseLessInfo();
		}
		
		/**
		 * 获得当前连击的攻击index 
		 * @param troopIndex
		 * @return 
		 */
		public static function getCurLianjiIndex(troopIndex:int):int
		{
			var targetLianjieInfo:NLianjiInfoStore = nLianjieSnapInfo[troopIndex]; 
			if(targetLianjieInfo == null)
				return 0;
			return targetLianjieInfo.curIndex;
		}
		
		/**
		 * 获得当前连击的数值 
		 * @param troopIndex
		 * @return 
		 */
		public static function getCurLianjiValue(troopIndex:int):Number
		{
			var targetLianjieInfo:NLianjiInfoStore = nLianjieSnapInfo[troopIndex]; 
			if(targetLianjieInfo == null)
				return 0;
			return targetLianjieInfo.getCurAttackRatio();
		}
		
		/**
		 * 检查是否已经结束连击
		 * @parma	attackIndex
		 */
		public static function checkAttackLianjiOver(troopInfo:CellTroopInfo):Boolean
		{
			if(troopInfo == null || troopInfo.logicStatus == LogicSatusDefine.lg_status_dead)
				return true;
			var targetLianjieInfo:NLianjiInfoStore = nLianjieSnapInfo[troopInfo.troopIndex];
			if(targetLianjieInfo == null)
				return true;
			return targetLianjieInfo.curIndex >= targetLianjieInfo.allDamageRatio.length;
		}
		
		/**
		 *  增加
		 *  @param	troopIndex			攻击的troop
		 */
		public static function increaseAttackStep(troopIndex:int):void
		{
			var targetLianjieInfo:NLianjiInfoStore = nLianjieSnapInfo[troopIndex];
			if(targetLianjieInfo == null)
				return;
			targetLianjieInfo.increaseLianjieStep();
		}
		
		/**
		 * 更新信息 
		 * @param upateInfo
		 */
		public static function updateTroopLianjiInfo(troopIndex:int,upateInfo:BattleSingleEffect):void
		{
			var newLianjieInfo:NLianjiInfoStore = new NLianjiInfoStore;
			newLianjieInfo.initFromLianjiEffect(upateInfo);
			nLianjieSnapInfo[troopIndex] = newLianjieInfo;
		}
		
		/**
		 * 某个英雄troop的老值 
		 * @param hero
		 * @return 
		 */
		public static function getSingleHeroOldOffsetValue(hero:CellTroopInfo):int
		{
			return int(heroOffsetInfo[hero.troopIndex]);
		}
		
		/**
		 *  某个英雄士气值
		 * @param hero
		 * @return 
		 */
		public static function getSingleHeroMorale(hero:CellTroopInfo):int
		{
			return int(heroMoraleInfo[hero.troopIndex]);
		}
		
		/**
		 * 记录troop的攻击距离 
		 * @param troop
		 */
		public static function recordTroopAttackDistance(troop:CellTroopInfo):void
		{
			troopAttackRangeObj[troop.troopIndex] = troop.attackUnit.attackDistance;
		}
		
		/**
		 * 获得troop的真实攻击范围 
		 * @param troop
		 * @return 
		 */
		public static function getTroopRealAttackDistance(troop:CellTroopInfo):int
		{
			if(troopAttackRangeObj.hasOwnProperty(troop.troopIndex))
				return int(troopAttackRangeObj[troop.troopIndex]);
			else
			{
				return troop.attackUnit.attackDistance;
			}
		}
		
		/**
		 * 清空临时信息 
		 */
		public static function clearInfo():void
		{
			quanTiGongJiRound = 0;
			hebingTarget = {};
			needCheckStuckSupply = false;
			heroCalledCount = 0;
			canDirectCall = false;
			MaxSelfSupplyCount = 20;
			MaxEnemySupplyCount = 50;
			usedSupplyTypes = {};
			curForceDeadTroops = [];
			isCurbattleWithWizard = false;
			curServerCommuIndex = 0;
			isDaJinOutOfEnergy = false;
			deadTroopList = {};
			battleContinueAtkRow = 0;
			battleContinueDefRow = 0;
			continueEvent = null;
			needPauseBattle = false;
			
			movingRebornTroops = {};
			rebornedTroops = [];
			heroMappedTroops = {};
			allUserAvatarInfo = {};
			needFanjiChains = {};
			guildRatioCoin = 0;
			guildRatioExp = 0;
			verifiedCardInfo = {};
			firstCardClickCount = 0;
			isWizardPast = false;
			isBattleEnd = false;
			deadTroopEnemyIds = [];
			isRecovering = false;
			curSelfArmCount = new Object();
			curSelfArmCount = null;
			isDuoqiPVE = false;
			isDuoqiPvp = false;
			isNextTeamMoveEnd = false;
			curWaveofRaid = 0;
			canFirstAtkGuanghuangWork = false;
			alphaDownTroops = new Dictionary();
			askedRoundIndexInfo ={};
			allVerticalMovingTroops ={};
			moveForwardHero ={};
			curArmLeftOfAttack ={};
			allMovingTroops ={};
			troopsHaveBeenSimplyCleared ={};
			curBattleCount = 0;
			allCoinsFromShuaiGua = 0;
			wizardItToMoveOn = 0;
			canMoveOnRoundCount = -1;
			curMainHero = null;
			heroOffsetInfo ={};
			troopAttackRangeObj ={};
			hidedTroopOnAoYi = new Dictionary;
			isNextWaveOnDaiJiQu = false;
			heroMoraleInfo ={};
			hasVisibleHeroOnWave = false;
			nLianjieSnapInfo =[];
			gotCommandBack = true;
			deadTroopsOnOneRound = [];
			aoyiTroopTargetCellInfo ={};
			dropinfoCheckedTroops ={};
			enemyUnitAoyiRoundIndex ={};
			armySupplyInfo ={};
			curRebornTroops = {};
			jianTaHeroRecord ={};
			BattleInfoSnap.curWaitOnRoundIndex ={};
			zhudongjinengChuFaInfo ={};
			beidongjinengChuFaInfo ={};
			curBattleFrame = 0;
			damageFrameHodler = new Dictionary();
			zhongduCauInfo ={};
			needControlBattle = false;
			armSupplyLeftTime = 0;
			needLockBattleCard = false;
			hasCostArm = false;
			bossbattle = false;
			xiulianSourceData = null;
		}
		
		public static function getMapUnitInfoById(id:int):MapEnemyUnit
		{
			if(xiulianSourceData != null)
			{
				for(var i:int=0; i< xiulianSourceData.enemyseqs.length; i++)
				{
					var enemyseq:MapEnemySeq = xiulianSourceData.enemyseqs[i] as MapEnemySeq;
					var retInfo:MapEnemyUnit = enemyseq.getEnemyUnit(id);
					if(retInfo)
						return retInfo;
				}
			}
			return null;
		}

		public static function get hidedTroopOnAoYi():Dictionary
		{
			return _hidedTroopOnAoYi;
		}

		public static function set hidedTroopOnAoYi(value:Dictionary):void
		{
			_hidedTroopOnAoYi = value;
		}

		public static function get canMoveOnRoundCount():int
		{
			return _canMoveOnRoundCount;
		}

		public static function set canMoveOnRoundCount(value:int):void
		{
			_canMoveOnRoundCount = value;
		}

		public static function get gotCommandBack():Boolean
		{
			return _gotCommandBack;
		}

		public static function set gotCommandBack(value:Boolean):void
		{
			_gotCommandBack = value;
		}

		public static function get allCoinsFromShuaiGua():int
		{
			return _allCoinsFromShuaiGua;
		}

		public static function set allCoinsFromShuaiGua(value:int):void
		{
			var oldValue:int = _allCoinsFromShuaiGua;
			_allCoinsFromShuaiGua = value;
			if(oldValue != value)
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new DataEvent(BattleStage.gotCoinsFormShuaiGuai,false,false,_allCoinsFromShuaiGua.toString()));
		}

		public static function get curMainHero():UserHeroInfo
		{
			if(_curMainHero)
				return _curMainHero;
			else
			{
				return _curMainHero;
			}
		}

		public static function set curMainHero(value:UserHeroInfo):void
		{
			_curMainHero = value;
		}

		/**
		 * 增加单个死亡的troop 
		 * @param troopInfo
		 * @return 
		 */
		public static function addSingleMappedDeadTroop(troopInfo:CellTroopInfo):void
		{
			if(troopInfo == null)
				return;
			if(troopInfo.cellsCountNeed.y > 1)
				return;
			if(troopInfo.isHero)
				return;
			if(troopInfo.attackUnit.armtype == ArmType.machine)				//机械类不能复活
				return;
			var heroInfo:Array = troopInfo.allHeroArr;
			var heroTroop:CellTroopInfo;
			for(var i:int = 0;i < heroInfo.length;i++)
			{
				heroTroop = heroInfo[i];
				break;
			}
			if(heroTroop == null)
				return;
			var contentTroops:Array = [];
			if(!heroMappedTroops.hasOwnProperty(heroTroop.troopIndex))
			{
				heroMappedTroops[heroTroop.troopIndex] = contentTroops;
			}
			else
			{
				contentTroops = heroMappedTroops[heroTroop.troopIndex];
			}
			
			var containede:Boolean = false;
			var singleTroop:CellTroopInfo;
			for(var checkIndex:int = 0;checkIndex < contentTroops.length;checkIndex++)
			{
				singleTroop = contentTroops[checkIndex];
				if(singleTroop && singleTroop.troopIndex == troopInfo.troopIndex)
				{
					containede = true;
					break;
				}
			}
			if(!containede)
			{
				contentTroops.push(troopInfo);
			}
			troopInfo.mappedHeroIndex = heroTroop.troopIndex;
			BattleInfoSnap.deadTroopList[troopInfo.troopIndex] = 1;
		}
		
		/**
		 * 获得某个英雄对应的死亡的troop信息 
		 * @param troopIndex
		 * @return 
		 */
		public static function getDeadTroopsOfHero(troopIndex:int):Array
		{
			return heroMappedTroops[troopIndex];
		}
		
	}
}