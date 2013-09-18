package modules.battle.battlelogic
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import macro.ActionDefine;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlecomponent.NextSupplyShow;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.McStatusDefine;
	import modules.battle.battlelogic.skillandeffect.EffectOnCau;
	import modules.battle.funcclass.BattleManagerLogicFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.managers.DemoManager;

	/**
	 * 表示一个回合的数据结构 
	 * @author Administrator
	 * 
	 */
	public class SingleRound
	{
		private var chainInfoArr:Array;					//保存最后此回合中所有的chain
		
		public var allCellIndexObj:Object;					//先手方的所有cell index集合
		
		public var roundType:int = 1;			//是否是英雄回合
		
		public var isRoundEnd:Boolean = false;

		private var secureTimer:Timer;
		
		private var selfRoundIndex:int = 0;
		
		public var hasRecallHero:Boolean = false;
		
		public static var roungIndex:int = 0;
		
		public function SingleRound()
		{
			chainInfoArr =[];
			allCellIndexObj ={};
			selfRoundIndex = roungIndex++;
			
			if(selfRoundIndex <= BattleDefine.fakeRoundsAtBeginning)
			{
				//初始化阶段
				DemoManager.handleSingleStarQualified(NextSupplyShow.starSupplyTypeNone,0,1);
				if(selfRoundIndex < 3)
				DemoManager.handleSingleStarQualified(NextSupplyShow.starSupplyTypeNone,0,1);
//				if(selfRoundIndex % 2 == 0)
					DemoManager.makeEnemySupply();
			}
			else
			{
				if(selfRoundIndex % BattleDefine.autoStarIncreaseRoundGap == 0)
				{
					DemoManager.handleSingleStarQualified(NextSupplyShow.starSupplyTypeNone,0,1);
//					if(BattleInfoSnap.MaxSelfSupplyCount > 0)
//					{
//						BattleInfoSnap.MaxSelfSupplyCount--;
//						DemoManager.handleSingleStarQualified(NextSupplyShow.starSupplyTypeNone,0,1);
//						DemoManager.handleSingleStarQualified(NextSupplyShow.starSupplyTypeHP,100,1);		//增加血量球
//					}
				}
				
				if(DemoManager.curStage == 0)
				{
					if((selfRoundIndex % BattleDefine.autoEnemySupplyRoungGap == 0 && selfRoundIndex > 6) || BattleInfoSnap.canDirectCall)			//每若干回合 敌人的兵进行补进
					{
						DemoManager.makeEnemySupply();
						BattleInfoSnap.canDirectCall = false;
					}
				}
				else
				{
					if((selfRoundIndex % BattleDefine.autoEnemySupplyRoundGapFast == 0 && selfRoundIndex > 6) || BattleInfoSnap.canDirectCall)			//每若干回合 敌人的兵进行补进
					{
						DemoManager.makeEnemySupply();
						BattleInfoSnap.canDirectCall = false;
					}
				}
				
			}
		}
		
		public function initBattleSecureTimer(init:Boolean):void
		{
			if(!BattleInfoSnap.isOnBattle)
				return;
			if(BattleModeDefine.checkNeedServerData())
				return;					
			if(secureTimer != null)
			{
				secureTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,secureTimeOutHandler);
				secureTimer.stop();
				secureTimer = null;
			}
			if(init)
			{
				if(!BattleInfoSnap.isCurbattleWithWizard)
				{
					secureTimer = new Timer(BattleDefine.singleRoundSecureTime,1);
					secureTimer.addEventListener(TimerEvent.TIMER_COMPLETE,secureTimeOutHandler);
					secureTimer.start();
				}
			}
		}
		
		public function secureTimeOutHandler(event:TimerEvent):void
		{
			if(event)
				return;
			if(!BattleInfoSnap.isOnBattle)
				return;
			if(this.selfRoundIndex != roungIndex - 1)			//非当前回合
				return;
			if(!this.checkRoundIsOver())
			{
				//强制开始下一回合
				makeRoundForceEnd();
			}
			BattleManagerLogicFunc.makeHeroDeadFill();
		}
		
		public function clearRoundInfo():void
		{
			if(chainInfoArr)
			{
				while(chainInfoArr.length > 0)
				{
					var singleObj:Object = chainInfoArr.pop();
					singleObj = null;
				}
			}
			initBattleSecureTimer(false);
			allCellIndexObj = null;
		}
		
		/**
		 * 增加一个chain信息
		 * @param atkTroopIndex			攻击的chain
		 * @param defTroopIndex			被攻击的chain
		 * @param attackEffect			攻击方影响此次攻击的效果
		 * @param effectGenerated		此次攻击产生的新的效果
		 * 
		 */
		public function addChainToRound(atkTroop:CellTroopInfo,defTroop:CellTroopInfo,isOnEffect:Boolean = false,damageXiuZheng:Number = 0):CombatChain
		{
			
			if(atkTroop.logicStatus == LogicSatusDefine.lg_status_dead || defTroop.logicStatus == LogicSatusDefine.lg_status_dead)
				return null;
			
			var newChain:CombatChain = new CombatChain();
			
			newChain.atkTroopIndex = atkTroop.troopIndex;
			newChain.defTroopIndex = defTroop.troopIndex;
			
			chainInfoArr.push(newChain);
			
			newChain.chainIndex = CombatChain.curChainIndex++;					//当前chain的索引
			
			BattleManager.instance.allChainInfo[newChain.chainIndex] = newChain;
			
			if(atkTroop.chainInvolved != null)										//添加chain之间的前置后置关系   被攻击转为攻击
			{
				newChain.preChain = atkTroop.chainInvolved.chainIndex;
				atkTroop.chainInvolved.nxtChain = newChain.chainIndex;
				atkTroop.chainInvolved = null;
			}
			
			if(!isOnEffect)						//如果不是技能的攻击,增加一个默认攻击100%的伤害特效
			{
				newChain.addEffectFromAtkOrDefense(EffectOnCau.getNewEffectOnCau(SpecialEffectDefine.ShangHaiShuChuZengJia,damageXiuZheng,0,newChain.atkTroopIndex,newChain.sourceTroop),true);
				
				//获得可以对攻击产生影响的效果  非英雄攻击的情况下		(伤害输出增加)
				var attackInfluence:Array = TroopFunc.effectingAffection(atkTroop,true,atkTroop.isHero);
				var singleEffOnCau:EffectOnCau;
				for(var i:int = 0; i < attackInfluence.length;i++)
				{
					singleEffOnCau = attackInfluence[i];
					newChain.addEffectFromAtkOrDefense(singleEffOnCau,true,false);
				}
			}
			
			newChain.isSkillAtk = isOnEffect;
			
			return newChain;
		}
		
		/**
		 * 在被攻击的时候产生的效果作用的chain 
		 * @param atkTroop				攻击chain
		 * @param defTroop				被攻击chain
		 * @return 
		 */
		public function addChainWhenAttacked(atkTroop:CellTroopInfo,defTroop:CellTroopInfo):CombatChain
		{
			if(atkTroop == null || defTroop == null)
				return null;
			var newChain:CombatChain = new CombatChain();
			newChain.atkTroopIndex = atkTroop.troopIndex;
			newChain.defTroopIndex = defTroop.troopIndex;
			
			newChain.chainIndex = CombatChain.curChainIndex++;
			
			BattleManager.instance.allChainInfo[newChain.chainIndex] = newChain;
			chainInfoArr.push(newChain);
			return newChain;
		}
		
		/**
		 * 增加假的chain  此chain不能攻击  可能是因为距离不够，或者眩晕 
		 */
		public function addFakeChainToRound(atkTroop:CellTroopInfo):CombatChain
		{
			var combatChain:CombatChain = new CombatChain();
			
			combatChain.atkTroopIndex = atkTroop.troopIndex;
			
			if(atkTroop.chainInvolved != null)										//添加chain之间的前置后置关系   被攻击转为攻击
			{
				combatChain.preChain = atkTroop.chainInvolved.chainIndex;
				atkTroop.chainInvolved.nxtChain = combatChain.chainIndex;
				atkTroop.chainInvolved = null;
			}
			
			return combatChain;
		}
		
		/**
		 * 增加反击，反弹等特效 
		 * 
		 */
		public function addFightBackChain(atkTroop:CellTroopInfo,defTroop:CellTroopInfo):CombatChain
		{
			if(atkTroop.logicStatus == LogicSatusDefine.lg_status_dead || defTroop.logicStatus == LogicSatusDefine.lg_status_dead)
				return null;
			
			var newChain:CombatChain = new CombatChain();
			
			newChain.atkTroopIndex = atkTroop.troopIndex;
			newChain.defTroopIndex = defTroop.troopIndex;
			
			chainInfoArr.push(newChain);
			
			newChain.chainIndex = CombatChain.curChainIndex++;					//当前chain的索引
			
			BattleManager.instance.allChainInfo[newChain.chainIndex] = newChain;
			
			if(atkTroop.chainInvolved != null)										//添加chain之间的前置后置关系   被攻击转为攻击
			{
				newChain.preChain = atkTroop.chainInvolved.chainIndex;
				atkTroop.chainInvolved.nxtChain = newChain.chainIndex;
			}
			
			return newChain;
		}
		
		/**
		 * 检测回合是否已经结束 
		 * 此时所有的cell都至少已经开始攻击
		 * 因此只检查所有攻击是否结束
		 * @return 
		 * 
		 */
		public function checkRoundIsOver():Boolean
		{
			var over:Boolean = true;
			var firstTroopInfo:CellTroopInfo;
			var singleTroopInfo:CellTroopInfo;
			var singleChainInfo:CombatChain;
			for(var key:String in chainInfoArr)
			{
				singleChainInfo = chainInfoArr[key] as CombatChain;
				if(singleChainInfo)
				{
					//攻击方的状态需要回复
					singleTroopInfo = singleChainInfo.sourceTroop;
					
					if(singleTroopInfo.curArmCount <= 0 && singleTroopInfo.curTroopHp <= 0 && !singleTroopInfo.isHero && !singleTroopInfo.visible && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead && 
						singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_forceDead)
						singleTroopInfo.logicStatus = LogicSatusDefine.lg_status_dead;
					
					if(singleTroopInfo.troopVisibleOnBattle)
					{
						if(!singleTroopInfo.visible && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead && !singleTroopInfo.isHero && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_forceDead)
						{
							if(!BattleInfoSnap.hidedTroopOnAoYi[singleTroopInfo])
							{
								trace("may be here");
								singleTroopInfo.logicStatus = LogicSatusDefine.lg_status_dead;
								singleTroopInfo.mcStatus = McStatusDefine.mc_status_idle;
							}
						}
					}
					if(singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead && singleTroopInfo.mcStatus != McStatusDefine.mc_status_idle && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_forceDead)					//如果没有攻击完毕
					{
						over = false;
						break;
					}
					
					if(singleTroopInfo.isHero && singleTroopInfo.mcStatus != McStatusDefine.mc_status_idle && singleTroopInfo.mcStatus != McStatusDefine.mc_status_dead
						&& singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_forceDead)
					{
						over = false;
						break;
					}
					
//					TroopInitClearFunc.clearTroopListener(singleTroopInfo);
					
					//防守方的状态需要恢复
					singleTroopInfo = singleChainInfo.targettroop;
					
					if(singleTroopInfo.curArmCount <= 0 && singleTroopInfo.curTroopHp <= 0 && !singleTroopInfo.isHero && !singleTroopInfo.visible && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead
					&& singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_forceDead)
						singleTroopInfo.logicStatus = LogicSatusDefine.lg_status_dead;
					
//					if(singleTroopInfo.logicStatus == LogicSatusDefine.lg_status_waitForDamage)
//					{
//						//如果攻击方已经死亡，不再等待
//						if(singleChainInfo.sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)
//						{
//							singleTroopInfo.alldamageSource[singleChainInfo.chainIndex] = 1;
//						}
//						singleTroopInfo.setIdleStatusSecure();
//						if(singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_idle)
//						{
//							over = false;
//							break;
//						}
//					}
					if(singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead && singleTroopInfo.mcStatus != McStatusDefine.mc_status_idle && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_forceDead)					//如果没有攻击完毕
					{
						over = false;
						break;
					}
					
					if(singleTroopInfo.isHero && singleTroopInfo.mcStatus != McStatusDefine.mc_status_idle && singleTroopInfo.mcStatus != McStatusDefine.mc_status_dead && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_forceDead)
					{
						over = false;
						break;
					}
					
					if(singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_forceDead)
					{
						for(var singleChainIndex:String in singleTroopInfo.alldamageSource)
						{
							var curChainAtkOver:Boolean = false;
							var tempSingleTroopIndex:int = int(singleChainIndex);
							var tempChain:CombatChain = BattleManager.instance.allChainInfo[tempSingleTroopIndex] as CombatChain;
							if(singleTroopInfo.alldamageSource[singleChainIndex] != 1)			//此chain还没有攻击
							{
								if(tempChain.sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)			//只要攻击troop没死，那么不能认为回合结束
									curChainAtkOver = true;
								
								if(!curChainAtkOver)
								{
									over = false;
									break;
								}
							}
						}
					}
					
				}
			}
			
			if(over)
			{
				var tempFanjiChain:Object = BattleInfoSnap.needFanjiChains;
				for(var singleChainKey:String in tempFanjiChain)
				{
					over = false;
					break;
				}
			}
			
			isRoundEnd = over;

			var realOver:Boolean = over;
			var targetTroopInfo:CellTroopInfo;
			if(realOver)
			{
				for(var singleVMTroopIndex:String in BattleInfoSnap.allVerticalMovingTroops)
				{
					if(BattleInfoSnap.allVerticalMovingTroops[singleVMTroopIndex] == 0)
					{
						targetTroopInfo = BattleUnitPool.getTroopInfo(int(singleVMTroopIndex));
						if(targetTroopInfo != null)
						{
							if(targetTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead && targetTroopInfo.visible)
							{
								realOver = false;
								break;
							}
						}
					}
				}
			}
			
			if(realOver)
			{
				var curHeroMoveInfo:Object = BattleInfoSnap.moveForwardHero;
				for(var singleHeroTag:String in curHeroMoveInfo)
				{
					if(curHeroMoveInfo[singleHeroTag] == 0)
					{
						targetTroopInfo = BattleUnitPool.getTroopInfo(int(singleHeroTag));
						if(targetTroopInfo == null || targetTroopInfo.isHero)
							continue;
						if(targetTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead && !targetTroopInfo.visible)
						{
							realOver = false;
							break;
						}
					}
				}
			}
			
			return realOver;
		}
		
		public function makeRoundForceEnd():void
		{
			var singleTroopInfo:CellTroopInfo;
			var singleChainInfo:CombatChain;
			for(var key:String in chainInfoArr)
			{
				singleChainInfo = chainInfoArr[key] as CombatChain;
				if(singleChainInfo)
				{
					//攻击方的状态需要回复
					singleTroopInfo = singleChainInfo.sourceTroop;
					
					if(singleTroopInfo.curArmCount <= 0 && singleTroopInfo.curTroopHp <= 0 && !singleTroopInfo.isHero && !singleTroopInfo.visible && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead)
						singleTroopInfo.logicStatus = LogicSatusDefine.lg_status_dead;
					
					if(singleTroopInfo.troopVisibleOnBattle)
					{
						if(!singleTroopInfo.visible && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead && !singleTroopInfo.isHero)
						{
							if(!BattleInfoSnap.hidedTroopOnAoYi[singleTroopInfo])
							{
								singleTroopInfo.logicStatus = LogicSatusDefine.lg_status_dead;
								singleTroopInfo.mcStatus = McStatusDefine.mc_status_idle;
							}
						}
					}
					setSinglePlayerFree(singleTroopInfo);
					
					singleTroopInfo = singleChainInfo.targettroop;
					if(singleTroopInfo.curArmCount <= 0 && singleTroopInfo.curTroopHp <= 0 && !singleTroopInfo.isHero && !singleTroopInfo.visible && singleTroopInfo.logicStatus != LogicSatusDefine.lg_status_dead)
						singleTroopInfo.logicStatus = LogicSatusDefine.lg_status_dead;
					setSinglePlayerFree(singleTroopInfo);
				}
			}
		}
		
		private function setSinglePlayerFree(troop:CellTroopInfo):void
		{
			if(troop == null)
				return;
			if(troop.logicStatus == LogicSatusDefine.lg_status_dead || troop.logicStatus == LogicSatusDefine.lg_status_hangToDie)
				return;
			troop.logicStatus = LogicSatusDefine.lg_status_idle;
			troop.playAction(ActionDefine.Action_Idle);
		}
		
	}
}