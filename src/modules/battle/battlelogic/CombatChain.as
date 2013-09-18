package modules.battle.battlelogic
{
	import eventengine.GameEventHandler;
	
	import flash.events.Event;
	import flash.media.ID3Info;
	
	import macro.ActionDefine;
	import macro.ArmType;
	import macro.BattleCardTypeDefine;
	import macro.EventMacro;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battledefine.*;
	import modules.battle.battleevents.CheckAttackEvent;
	import modules.battle.battleevents.CheckComboEvent;
	import modules.battle.battleevents.DamageArrivedEvent;
	import modules.battle.battleevents.EffectSourceDeadEvent;
	import modules.battle.battleevents.TroopDeadEvent;
	import modules.battle.battlelogic.skillandeffect.EffectOnCau;
	import modules.battle.funcclass.BattleManagerLogicFunc;
	import modules.battle.funcclass.ChainFunc;
	import modules.battle.funcclass.SkillEffectFunc;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.funcclass.TroopEffectDisplayFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.showdatastructure.SingleDamageDisplayInfo;
	import modules.battle.utils.BattleEventTagFactory;
	import modules.battle.utils.BattleUtils;

	/**
	 * 战斗时候的最小回合 
	 * @author SDD
	 * 
	 */
	public class CombatChain
	{
		private var _atkTroopIndex:int;				//攻击的troop索引
		
		private var _defTroopIndex:int;				//被攻击单位
		
		private var _chainIndex:int = 1;				//此chain的ID
		
		public var preChain:int = -1;				//前置的chain
		
		public var nxtChain:int = -1;				//后置的chain
		
		public var curAtkCount:int = 0;			//当前攻击是第几次
		private var _maxAttackTimes:int = BattleDefine.defaultAttackCount;				//获得最多攻击次数  主要处理N连击的情形
		
		private var _targettroop:CellTroopInfo;
		private var _sourceTroop:CellTroopInfo;
		
		public static var curChainIndex:int = 0;
		
		/**
		 * 此次回合中产生的攻击/加成的基础值
		 */
		public var damageBaseValue:Number = 1;		
		
		/**
		 * 此次攻击中，攻击方对伤害/加成数值产生影响的效果以及相应的值    产生的新的影响
		 * 即 主动技能 的特效
		 */
		public var effFromAtk:Array=[];			
		
		/**
		 * 此次攻击中，被攻击方对伤害/加成数值产生影响的效果以及相应的值         产生的新的影响
		 * 即 被动技能 
		 */
		public var effFromDef:Array=[];
		
		/**
		 * 此次攻击的时候攻击方附带的效果 加在身上的buff
		 */
		public var existedEffOnAttak:Array=[];
		
		/**
		 * 此次攻击的时候被供给方附带的效果  加在身上的buff
		 */
		public var existedEffOnDef:Array=[];
		
		/**
		 * 此chain中对应的攻击方发动的技能ID (为了显示)
		 */
		public var atkSkillId:Array=[];
		/**
		 * 此chain中对应的被攻击方发动的技能ID (为了显示)
		 */
		public var defSkillId:Array=[];
		
		/**
		 * 需要在攻击帧数播放的特效 
		 */
		public var needShowEffectOnAttackFrame:Array=[];
		
		/**
		 * 是否是技能攻击产生的chain
		 */
		public var isSkillAtk:Boolean = false;
		//是否为反击chain
		public var isFanjiChain:Boolean = false;
		public var isFujiaGongJiChain:Boolean = false;
		
		public var chainDamageTimes:int = 1;
		
		private var chainWorkParmas:Array=[];
		
		public function CombatChain()
		{
			
		}
		
		public function clearChainInfo():void
		{
			if(sourceTroop)
				sourceTroop.removeEventListener(CellTroopInfo.troopStaggerTimeOutEvent,makeChainWorkLogicAfterStagger);
			_targettroop = null;
			_sourceTroop = null;
			
			var allNeedClearInfo:Array = effFromAtk.concat(effFromDef).concat(existedEffOnAttak).concat(existedEffOnDef);
			while(allNeedClearInfo.length > 0)
			{
				var singleEffect:EffectOnCau = allNeedClearInfo.pop();
				if(singleEffect)
				{
					singleEffect.clearInfo();
				}
				singleEffect = null;
			}
		}
		
		/**
		 * 洗后另一个chain中的所有信息 
		 * @param chainInfo						需要被吸收的chain
		 */
		public function absordOtherChainInfo(chainInfo:CombatChain):void
		{
			if(chainInfo == null)
				return;
			var singleObj:Object;
			for each(singleObj in chainInfo.effFromAtk)
			{
				this.effFromAtk.push(singleObj);
			}
			for each(singleObj in chainInfo.effFromDef)
			{
				this.effFromDef.push(effFromDef);
			}
			for each(singleObj in chainInfo.existedEffOnAttak)
			{
				this.existedEffOnAttak.push(singleObj);
			}
			for each(singleObj in chainInfo.existedEffOnDef)
			{
				this.existedEffOnDef.push(singleObj);
			}
			for each(singleObj in chainInfo.atkSkillId)
			{
				this.atkSkillId.push(singleObj);
			}
			for each(singleObj in chainInfo.defSkillId)
			{
				this.defSkillId.push(singleObj);
			}
			for each(singleObj in chainInfo.needShowEffectOnAttackFrame)
			{
				this.needShowEffectOnAttackFrame.push(singleObj);
			}
			if(chainInfo.isFanjiChain)
			{
				this.isFanjiChain = true;
			}
		}
		
		/**
		 * 让chain继续work或者播放vedio 
		 * @param event
		 * @return 
		 * 
		 */
		public function checkChainComboInfo(event:CheckComboEvent = null):void
		{
			if(BattleManager.instance.status == OtherStatusDefine.battleOn)
			{
				makeChainWork(event);					//如果是在战斗  让chain继续攻击
			}
		}
		
		private function makeChainWorkLogic(event:CheckComboEvent = null,isFirstOne:Boolean = false,effectPlayerId:String = "",isAoyi:Boolean = false,
											isZhengdui:Boolean = false,specialAction:Boolean = false,needAddListenForce:Boolean = false):void
		{
			//发起方已经死亡，需要立即结束此chain信息
			if(this.sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)
			{
				this.maxAttackTimes = this.curAtkCount;
				this.targettroop.alldamageSource[this.chainIndex] = 1;
//				if(this.targettroop.logicStatus == LogicSatusDefine.lg_status_waitForDamage)
				{
					this.targettroop.setIdleStatusSecure();
				}
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				return;
			}
			//目标已经死亡
			if(this.targettroop.logicStatus == LogicSatusDefine.lg_status_dead)
			{
				this.maxAttackTimes = this.curAtkCount;
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				return;
			}
			
			var containsDamage:Boolean = SkillEffectFunc.checkCanBeEvade(this);
			if(curAtkCount > 0)
			{
				sourceTroop.logicStatus = LogicSatusDefine.lg_status_attack;
				sourceTroop.playAction(ActionDefine.Action_Combo_Attack);
			}
			else
			{
				var teragetAction:int;
				if(sourceTroop.isHero)
				{
					//						sourceTroop.logicStatus = LogicSatusDefine.lg_status_dazhao;
					//						sourceTroop.playAction(ActionDefine.Action_Dazhao);
					//						//增加troop的监听函数  当播放到攻击动作最大帧时候触发
					//						sourceTroop.addMcFrameHandler(ActionDefine.Action_Dazhao,[atkTroopIndex,defTroopIndex,false]);
					//						sourceTroop.addMcFrameHandler(ActionDefine.Action_Dazhao,[atkTroopIndex,defTroopIndex,false],true);
					if(!isAoyi)
					{
						teragetAction = ActionDefine.Action_Dazhao;
					}
					else
					{
						teragetAction = ActionDefine.Action_AoYi;
					}
					
					sourceTroop.logicStatus = LogicSatusDefine.lg_status_attack;
					sourceTroop.playAction(teragetAction);
					//增加troop的监听函数  当播放到攻击动作最大帧时候触发
					
					sourceTroop.addMcFrameHandler(teragetAction,[atkTroopIndex,defTroopIndex]);
					if(!isSkillAtk)			//带有攻击伤害的chain只会播放一次效果,伤害的触发依赖效果
					{
						if(isFirstOne)
						{
							sourceTroop.addMcFrameHandler(teragetAction,[atkTroopIndex,defTroopIndex,effectPlayerId],true);
						}
					}
					else
					{
						sourceTroop.addMcFrameHandler(teragetAction,[atkTroopIndex,defTroopIndex,effectPlayerId,null,isSkillAtk],true);
					}
				}
				else
				{
					if(!specialAction)
						teragetAction = ActionDefine.Action_Attack;
					else
						teragetAction = ActionDefine.Action_Dazhao;
					
					var isBaoji:Boolean = false;
					if(isFirstOne && ChainFunc.hasSomeNewGeneratedEffect(this,SpecialEffectDefine.BaoJi,false))
					{
						isBaoji = true;
					}
					
					sourceTroop.logicStatus = LogicSatusDefine.lg_status_attack;
					sourceTroop.playAction(teragetAction);
					sourceTroop.needDispatchAtkEvent = true;
					//增加troop的监听函数  当播放到攻击动作最大帧时候触发
					
					sourceTroop.addMcFrameHandler(teragetAction,[atkTroopIndex,defTroopIndex]);
					if(isFirstOne)
					{
						sourceTroop.addMcFrameHandler(teragetAction,[atkTroopIndex,defTroopIndex,isBaoji,containsDamage,effectPlayerId],true);
					}
					else if(teragetAction == ActionDefine.Action_Attack)
					{
						sourceTroop.addMcFrameHandler(teragetAction,[atkTroopIndex,defTroopIndex,isBaoji,containsDamage,effectPlayerId],true);
					}
					else if(needAddListenForce)
					{
						sourceTroop.addMcFrameHandler(teragetAction,[atkTroopIndex,defTroopIndex,isBaoji,containsDamage,effectPlayerId],true);
					}
				}
			}
			
			GameEventHandler.addListener(EventMacro.DAMAGE_WAIT_HANDELR,BattleEventTagFactory.geneTroopDeadTag(this.atkTroopIndex),sourceAtkTroopDeadEventHandler);
			sourceTroop.atkReactToChain(this);
			curAtkCount++;
			if(sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)			//死亡之后改变最大攻击次数
			{
				this.maxAttackTimes = curAtkCount;
			}
			GameEventHandler.addListener(EventMacro.DAMAGE_WAIT_HANDELR,BattleEventTagFactory.geneDamageArrivedTag(atkTroopIndex,defTroopIndex),handlerArrivedDamage);
		}
		
		/**
		 * 攻击的troop死亡的处理函数 
		 * @param event
		 */
		private function sourceAtkTroopDeadEventHandler(event:Event):void
		{
			GameEventHandler.removeListener(EventMacro.DAMAGE_WAIT_HANDELR,event.type,sourceAtkTroopDeadEventHandler);
			this.maxAttackTimes = curAtkCount;
			GameEventHandler.removeListener(EventMacro.DAMAGE_WAIT_HANDELR,BattleEventTagFactory.geneDamageArrivedTag(atkTroopIndex,defTroopIndex),handlerArrivedDamage);
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
		}
		
		private function makeChainWorkLogicAfterStagger(event:Event):void
		{
			if(sourceTroop)
				sourceTroop.removeEventListener(CellTroopInfo.troopStaggerTimeOutEvent,makeChainWorkLogicAfterStagger);
			if(BattleManager.needTraceBattleInfo)
			{
				trace("stagger time时间到，chain开始执行攻击逻辑",this.atkTroopIndex,this.defTroopIndex,"当前帧数: ",BattleInfoSnap.curBattleFrame);
			}
			makeChainWorkLogic(chainWorkParmas[0],chainWorkParmas[1],chainWorkParmas[2],chainWorkParmas[3],chainWorkParmas[4],chainWorkParmas[5],chainWorkParmas[6]);	
		}
		
		/**
		 * 让chain发生作用 		包括连击判断逻辑
		 */
		public function makeChainWork(event:CheckComboEvent = null,isFirstOne:Boolean = false,effectPlayerId:String = "",isAoyi:Boolean = false,
									  isZhengdui:Boolean = false,specialAction:Boolean = false,needForceAddListen:Boolean = false):void
		{
			//解除连击消息监听函数
			if(event)
				GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneChainCheckEvent(chainIndex),checkChainComboInfo);
			
			if(curAtkCount >= maxAttackTimes)				//如果当前已经攻击完成 
			{
				if(sourceTroop)
					sourceTroop.removeEventListener(CellTroopInfo.troopStaggerTimeOutEvent,makeChainWorkLogicAfterStagger);
				//设置两方状态
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));//发出消息是否继续攻击
			}
			else
			{
				if(targettroop.logicStatus != LogicSatusDefine.lg_status_filling || targettroop.mcStatus != McStatusDefine.mc_status_running)
				{
					//设置两方的状态
//					targettroop.logicStatus = LogicSatusDefine.lg_status_waitForDamage;	
				}
				targettroop.waitDamageSource = atkTroopIndex;
				TroopFunc.addTroopDamageSource(targettroop,chainIndex);
				
				if(sourceTroop.isOnStaggerWait)			//需要等待错开时间
				{
					chainWorkParmas = [event,isFirstOne,effectPlayerId,isAoyi,isZhengdui,specialAction,needForceAddListen];
					sourceTroop.addEventListener(CellTroopInfo.troopStaggerTimeOutEvent,makeChainWorkLogicAfterStagger,false,0,true);
					return;
				}
				
				makeChainWorkLogic(event,isFirstOne,effectPlayerId,isAoyi,isZhengdui,specialAction,needForceAddListen);
			}
		}
		
		/**
		 *  让产生的被动技能chain
		 */
		public function makeDefGenedChainWork():void
		{
			targettroop.defReactToChain(this);
			if(targettroop.logicStatus == LogicSatusDefine.lg_status_hangToDie || targettroop.logicStatus == LogicSatusDefine.lg_status_dead)
			{
				TroopFunc.handleDeadTroopLogic(targettroop);
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
			}
		}
		
		/**
		 * 检查是否能够进行反击 
		 * @return 
		 */
		public function simplyCheckFanjiWork():int
		{
			if(sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead || targettroop.logicStatus == LogicSatusDefine.lg_status_dead)
				return BattleDefine.fanjiChain_noNeed;
			
			if(targettroop.logicStatus == LogicSatusDefine.lg_status_filling || sourceTroop.logicStatus != LogicSatusDefine.lg_status_idle)
				return BattleDefine.fanjiChain_fail;
			
			//此时不能在攻击
			if(sourceTroop.logicStatus == LogicSatusDefine.lg_status_attack || sourceTroop.mcStatus == McStatusDefine.mc_status_attacking)
			{
				return BattleDefine.fanjiChain_fail;
			}
			return BattleDefine.fanjiChain_suc;
		}
		
		/**
		 * 运行反击技能chain 
		 * @param waitChains
		 * @return 是否有攻击
		 */
		public function makeFanjiChainWork(waitChains:Array):int
		{ 
			if(sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead || targettroop.logicStatus == LogicSatusDefine.lg_status_dead)
				return BattleDefine.fanjiChain_noNeed;
			
			if(targettroop.logicStatus == LogicSatusDefine.lg_status_filling || sourceTroop.logicStatus != LogicSatusDefine.lg_status_idle)
				return BattleDefine.fanjiChain_fail;
			
			//此时不能在攻击
			if(sourceTroop.logicStatus == LogicSatusDefine.lg_status_attack || sourceTroop.mcStatus == McStatusDefine.mc_status_attacking)
			{
				return BattleDefine.fanjiChain_fail;
			}
			
			//设置两方的状态
			targettroop.logicStatus = LogicSatusDefine.lg_status_waitForDamage;
			targettroop.waitDamageSource = atkTroopIndex;
			TroopFunc.addTroopDamageSource(targettroop,this.chainIndex);
			
			sourceTroop.isTroopFanji = true;
			sourceTroop.logicStatus = LogicSatusDefine.lg_status_attack;
			sourceTroop.playAction(ActionDefine.Action_Attack);
			sourceTroop.addMcFrameHandler(ActionDefine.Action_Attack,[atkTroopIndex,defTroopIndex,false]);
			sourceTroop.addMcFrameHandler(ActionDefine.Action_Attack,[atkTroopIndex,defTroopIndex,false,true,"",waitChains],true);
			
			curAtkCount++;
			GameEventHandler.addListener(EventMacro.DAMAGE_WAIT_HANDELR,BattleEventTagFactory.geneDamageArrivedTag(atkTroopIndex,defTroopIndex),handlerArrivedDamage);
			return BattleDefine.fanjiChain_suc;
		}
		
		/**
		 * 处理到达的伤害
		 * @param event
		 */
		public function handlerArrivedDamage(event:DamageArrivedEvent):void
		{
			//移除监听器
			if(event)
				GameEventHandler.removeListener(EventMacro.DAMAGE_WAIT_HANDELR,event.type,handlerArrivedDamage);
			GameEventHandler.removeListener(EventMacro.DAMAGE_WAIT_HANDELR,BattleEventTagFactory.geneTroopDeadTag(this.atkTroopIndex),sourceAtkTroopDeadEventHandler);
			if(BattleModeDefine.checkNeedServerData())
			{
				BattleInfoSnap.addSingleDamgeInfo(this);
			}
			else
			{
				handlerDamageLogic();
			}
		}
		
		public function handlerDamageLogic():void
		{
			
			//判断是否可以发动多次攻击
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneChainCheckEvent(chainIndex),checkChainComboInfo);    //监听是否继续攻击
			
			if(this.targettroop.troopIndex != defTroopIndex)
			{
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				return;			//攻击错乱
			}
			
			//目标此时在补进，应该是技能产生的非正对目标在补进造成,不会存在复杂逻辑情形
//			if(targettroop.logicStatus == LogicSatusDefine.lg_status_filling && targettroop.mcStatus == McStatusDefine.mc_status_running)
//			{
//				BattleManagerLogicFunc.addHangUpDamageChains(this);
//				return;
//				trace("容错开始");
//			}
			
			//如果在实时战斗
			while(needShowEffectOnAttackFrame.length > 0)
			{
				var singleEffect:int = needShowEffectOnAttackFrame.pop();
				TroopEffectDisplayFunc.showSkillElementEffect(this.targettroop,singleEffect);
			}
			if(this.sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)
			{
				BattleInfoSnap.deleteUselessLianjiInfo(atkTroopIndex);				//死亡的troop要将剩余的连击信息删除
				if(this.curAtkCount > 1)
				{
					targettroop.bearAttack(this);								//承受此次攻击  内容可能是 伤害 或者 可能是加成
					if(targettroop && targettroop.logicStatus == LogicSatusDefine.lg_status_dead)		//如果此cell死亡
					{
						maxAttackTimes = this.curAtkCount;
						GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
					}
				}
				else
				{
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				}
			}
			else
			{
				targettroop.bearAttack(this);								//承受此次攻击  内容可能是 伤害 或者 可能是加成
				if(targettroop && targettroop.logicStatus == LogicSatusDefine.lg_status_dead)		//如果此cell死亡
				{
					this.maxAttackTimes = this.curAtkCount;
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckAttackEvent(CheckAttackEvent.CHECK_AttackORPlay));
				}
			}
		}
		
		/**
		 * 清空攻击产生的效果，因为被闪避 
		 */
		public function clearAtkSideEffect():void
		{
			effFromAtk =[];
		}
		
		/**
		 * 增加影响此次攻击数值的所有效果			(主动/被动)(新触发/存在的buff)
		 * @param effectInfo   
		 * @param atk						是否来自攻击方
		 * @param newGened					是否为新生成的	
		 */
		public function addEffectFromAtkOrDefense(effectInfo:EffectOnCau,atk:Boolean,newGened:Boolean = true):void
		{
			if(effectInfo)
			{
				if(effectInfo.effectId == SpecialEffectDefine.ShangHaiZengJia || 
					effectInfo.effectId == SpecialEffectDefine.ShanBiZengJia || 
					effectInfo.effectId == SpecialEffectDefine.BaoJiZengJia)				//数据型buff已经处理，不需要记录
					return;
				
				if(effectInfo.effectId == SpecialEffectDefine.XuanYun)		//眩晕效果，特殊处理，值本身是概率
				{
					if(RandomValueService.getRandomValue(RandomValueService.RD_XUANYUN,this.defTroopIndex,this.atkTroopIndex) >= effectInfo.effectValue)
						return;
				}
				
				//处理弹出icon等情形
				if(atk)
				{
					if(newGened)
					{
						if(effectInfo.effectId == SpecialEffectDefine.WuLiShangHaiMianYi && effectInfo.effectValue > 0)		//物理破甲
						{
							needShowEffectOnAttackFrame.push(EffectShowTypeDefine.EffectShow_WuliPoJia);
						}
						else if(effectInfo.effectId == SpecialEffectDefine.WuLiShangHaiMianYi && effectInfo.effectValue < 0)		//物理免疫提升
						{
							needShowEffectOnAttackFrame.push(EffectShowTypeDefine.EffectShow_WuliFangYuTiSheng);
						}
						else if(effectInfo.effectId == SpecialEffectDefine.MoFaShangHaiMianYi && effectInfo.effectValue > 0)	//魔法破甲
						{
							needShowEffectOnAttackFrame.push(EffectShowTypeDefine.EffectShow_MoFaPoJia);
						}
						else if(effectInfo.effectId == SpecialEffectDefine.MoFaShangHaiMianYi && effectInfo.effectValue < 0)	//魔法防御提升
						{
							needShowEffectOnAttackFrame.push(EffectShowTypeDefine.EffectShow_MoFaFangYuTiSheng);
						}
						else if(effectInfo.effectId == SpecialEffectDefine.ShangHaiShuChuZengJia && effectInfo.effectValue < 0 && 
							effectInfo.effectDuration > 0 && effectInfo.effectTarget != this.atkTroopIndex)		//衰弱
						{
							needShowEffectOnAttackFrame.push(EffectShowTypeDefine.EffectShow_ShuaiRuo);
						}
					}
				}
				else
				{
					if(!this.sourceTroop.isMaster && effectInfo.effectId == SpecialEffectDefine.WuLiShangHaiMianYi && effectInfo.effectValue < 0)			//物理防御提升
					{
						needShowEffectOnAttackFrame.push(EffectShowTypeDefine.EffectShow_WuliFangYuTiSheng);
					}
					else if(this.sourceTroop.isMaster && effectInfo.effectId == SpecialEffectDefine.MoFaShangHaiMianYi && effectInfo.effectValue < 0)	//魔法防御提升
					{
						needShowEffectOnAttackFrame.push(EffectShowTypeDefine.EffectShow_MoFaFangYuTiSheng);
					}
//					else if(effectInfo.effectId == SpecialEffectDefine.MoFaShangHaiMianYi) 
//					{
//						
//					}
				}
				
				var targetArr:Array = atk ? effFromAtk : effFromDef;
				targetArr.push(effectInfo);
			}
		}
		
		/**
		 * 增加此次攻击时候，双方身上起作用的buff 中毒等
		 * @param effectInfo				effect信息
		 * @param isAtk						是否为攻击
		 */
		public function addExistedEffect(effectInfo:EffectOnCau,isAtk:Boolean):void
		{
			var targetArr:Array = isAtk ? existedEffOnAttak : existedEffOnDef;
			if(targetArr)
				targetArr.push(effectInfo);
		}
		
		/**
		 * 获得一次单次攻击产生的伤害值     可以为N连击中的一个   (实际攻击加上所有影响因素，不包括增减HP)
		 * @param atkCount				第几次
		 * @return 						伤害值
		 */
		public function getSingleAttackDamageInfo(atkCount:int = 1):SingleDamageDisplayInfo
		{
			var resInfo:SingleDamageDisplayInfo = new SingleDamageDisplayInfo;
			
			//伤害加成值
			var realDamageFactor:Number = 1;
			
			var effectValueArr:Array;
			var i:int = 0;
			var singleEffect:EffectOnCau;
			
			//伤害输出增加增加的效果  只有对攻击方作用的才会改变伤害值     作用在攻击方身上
			effectValueArr = ChainFunc.getAllEffectWorkOnTargetOrSource(this,SpecialEffectDefine.ShangHaiShuChuZengJia,false);
			for(i = 0;i < effectValueArr.length;i++)
			{
				singleEffect = effectValueArr[i];
				realDamageFactor += singleEffect.effectValue;
				resInfo.percentBonus.push(singleEffect.effectValue);
				if(this.curAtkCount == 1)							//只有第一次计算伤害的时候才适用
				{
					if(singleEffect.effectValue > 0)					//伤害输出提升效果
					{
						TroopEffectDisplayFunc.showEffcetOnTroopCenter(sourceTroop,EffectShowTypeDefine.CardEffect_ShangHaiTiGao,singleEffect);
					}
					else if(singleEffect.effectValue < 0)												//伤害输出降低效果	衰弱
					{
						if(singleEffect.sourceTroopIndex != singleEffect.effectTarget)				//如果不是自己挂自己的话
							TroopEffectDisplayFunc.showSkillElementEffect(sourceTroop,EffectShowTypeDefine.EffectShow_ShuaiRuo);
					}
				}
			}
			
			//物理伤害免疫的效果      作用在目标上
			effectValueArr = ChainFunc.getAllEffectWorkOnTargetOrSource(this,SpecialEffectDefine.WuLiShangHaiMianYi,true);
			if(this.sourceTroop.isMaster)					//法师类过滤
				effectValueArr =[];
			for(i = 0;i < effectValueArr.length;i++)
			{
				singleEffect = effectValueArr[i];
				if(this.sourceTroop.isHero)
					realDamageFactor += singleEffect.effectValue / this.maxAttackTimes;
				else
					realDamageFactor += singleEffect.effectValue;
				resInfo.percentBonus.push(singleEffect.effectValue);
			}
			
			//魔法伤害免疫的效果	    作用在目标上
			effectValueArr = ChainFunc.getAllEffectWorkOnTargetOrSource(this,SpecialEffectDefine.MoFaShangHaiMianYi,true);
			if(!this.sourceTroop.isMaster)					//非法师类过滤
				effectValueArr =[];
			for(i = 0;i < effectValueArr.length;i++)
			{
				singleEffect = effectValueArr[i];
				if(this.sourceTroop.isHero)
					realDamageFactor += singleEffect.effectValue / this.maxAttackTimes;
				else
					realDamageFactor += singleEffect.effectValue;
				resInfo.percentBonus.push(singleEffect.effectValue);
			}
			
			//附加攻击的效果      作用在攻击方身上
			effectValueArr = ChainFunc.getAllEffectWorkOnTargetOrSource(this,SpecialEffectDefine.FuJiaGongJi,true);
			for(i = 0;i < effectValueArr.length;i++)
			{
				singleEffect = effectValueArr[i];
				realDamageFactor += singleEffect.effectValue;
				resInfo.percentBonus.push(singleEffect.effectValue);
			}
			
			//暴击  作用在攻击方身上
			effectValueArr = ChainFunc.getAllEffectWorkOnTargetOrSource(this,SpecialEffectDefine.BaoJi,false);
			for(i = 0;i < effectValueArr.length;i++)
			{
				realDamageFactor *= 3;
				resInfo.percentBonus.push(1);
				break;
			}
			
			//反击  作用在攻击方身上
			effectValueArr = ChainFunc.getAllEffectWorkOnTargetOrSource(this,SpecialEffectDefine.FanJi,true);
			for(i = 0;i < effectValueArr.length;i++)
			{
				singleEffect = effectValueArr[i];
				realDamageFactor += singleEffect.effectValue;
				resInfo.percentBonus.push(singleEffect.effectValue);
				break;
			}
			
			resInfo.finalDamageValue = damageBaseValue * realDamageFactor;
			resInfo.finalDamageValue = Math.max(resInfo.finalDamageValue,2);
			resInfo.bonusRatio = realDamageFactor;
			return resInfo;
		}
		
		public function get atkTroopIndex():int
		{
			return _atkTroopIndex;
		}
		
		public function set atkTroopIndex(value:int):void
		{
			_atkTroopIndex = value;
			if(_atkTroopIndex >= 0)
				sourceTroop = BattleUnitPool.getTroopInfo(_atkTroopIndex) as CellTroopInfo;
			else
				sourceTroop = null;
		}
		
		public function get defTroopIndex():int
		{
			return _defTroopIndex;
		}

		public function set defTroopIndex(value:int):void
		{
			_defTroopIndex = value;
			if(_defTroopIndex >= 0)
				targettroop = BattleUnitPool.getTroopInfo(_defTroopIndex) as CellTroopInfo;
			else
				targettroop = null;
		}

		public function get chainIndex():int
		{
			return _chainIndex;
		}

		public function set chainIndex(value:int):void
		{
			_chainIndex = value;
		}

		public function get targettroop():CellTroopInfo
		{
			return _targettroop;
		}

		public function get sourceTroop():CellTroopInfo
		{
			return _sourceTroop;
		}

		public function set targettroop(value:CellTroopInfo):void
		{
			_targettroop = value;
		}

		public function set sourceTroop(value:CellTroopInfo):void
		{
			_sourceTroop = value;
		}

		public function get maxAttackTimes():int
		{
			return _maxAttackTimes;
		}

		public function set maxAttackTimes(value:int):void
		{
			_maxAttackTimes = value;
		}


	}
}