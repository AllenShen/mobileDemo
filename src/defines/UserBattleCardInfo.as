package defines
{
	import flash.events.Event;
	
	import eventengine.GameEventHandler;
	
	import macro.AttackRangeDefine;
	import macro.BattleCardDefine;
	import macro.BattleCardTypeDefine;
	import macro.EventMacro;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battlecomponent.NextSupplyShow;
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.McStatusDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.SkillEffectFunc;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.funcclass.TroopEffectDisplayFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleScreenEffectFunc;
	import modules.battle.managers.DemoManager;
	import modules.battle.stage.BattleStage;
	
	import sysdata.Skill;
	import sysdata.SkillElement;

	public class UserBattleCardInfo
	{
		public var usercardid:int;
		
		public var uid:int = 0;
		
		public var count:int = 0;			//数量
		
		public var cardid:int = 0;	
		
		public var name:String;				//名字	
		
		public var carddes:String;			//描述			
		
		public var cardtype:int = 0;				//类型
		
		public var worktype:int = 0;			//作用类型
		
		public var quality:int = 0;				//品质
		
		public var skill:Skill;					//对应的技能(效果集合)
		
		public var targetchoosetype:int;			//目标选择方式
		
		public var cdTime:int = 0;				//cd时间
		
		public var moraledeplete:int = 0;			//士气消耗
		
		public var wuxingshuxing:int= 0;			//五行属性
		
		public var sellprice:int;						//卖出价格
		public var sellpricetype:int;				//保留字段
		
		public var unlocklevel:int;				//解锁等级
		
		public var cardeffectid:int;			//显示效果id
		
		public function UserBattleCardInfo()
		{
			
		}
		
		/**
		 * 抽取出信息传给服务端 
		 * @return 
		 */
		public function extractInfoForServer():Array
		{
			var retValue:Array=[];
			retValue.push(usercardid);
			retValue.push(uid);
			retValue.push(cardid);
			retValue.push(cardtype);
			retValue.push(worktype);
			retValue.push(skill.skillid);
			retValue.push(cardeffectid);
			return retValue;
		}
		
		/**
		 * 英雄死亡,相应的卡片状态要置 
		 * @param event
		 */
		public function aoyiWaitHeroDead(event:Event):void
		{
			BattleManager.cardManager.handleAoYiHeroDead();
		}
		
		public static function makeSingleHeroCard():UserBattleCardInfo
		{
			var retInfo:UserBattleCardInfo = new UserBattleCardInfo();
			
			retInfo.count = 1;
			retInfo.worktype = BattleCardDefine.daojuKa;
			retInfo.cardtype = BattleCardTypeDefine.heroCard;
			retInfo.cdTime = 20;
			retInfo.cardeffectid = 7013;
			retInfo.targetchoosetype = BattleCardDefine.morenShifang;
			
			retInfo.skill = new Skill();
//			var singleElement:SkillElement = new SkillElement();
//			singleElement.buffeid = SpecialEffectDefine.baohuqiang;
//			singleElement.buffTime = 5;
//			singleElement.buffValue = 1;
//			singleElement.target = AttackRangeDefine.woFangDiYiPai;
//			retInfo.skill.elements.push(singleElement);
			
			return retInfo;
		}
		
		public static function makeOneFakeCardInfo():UserBattleCardInfo
		{
			var retInfo:UserBattleCardInfo = new UserBattleCardInfo();
			
			retInfo.count = 1;
			retInfo.worktype = BattleCardDefine.daojuKa;
			
			var randomValue:Number = Math.random();
			
			var contentSkill:Skill = new Skill;
			var singleElement:SkillElement = new SkillElement;
			contentSkill.elements = [singleElement];
			retInfo.skill = contentSkill;;
			retInfo.targetchoosetype = BattleCardDefine.morenShifang;
			
			if(randomValue < 0.25)
			{
				retInfo.cardtype = BattleCardTypeDefine.baohuqiang;
				retInfo.cardeffectid = 7020;
				
				singleElement.buffeid = SpecialEffectDefine.baohuqiang;
				singleElement.buffTime = 4;
				singleElement.buffValue = 1;
				singleElement.target = AttackRangeDefine.woFangDiYiPai;
				retInfo.cdTime = 1;
			}
			else if(randomValue < 0.50)
			{
				retInfo.cardtype = BattleCardTypeDefine.budian;
				retInfo.cardeffectid = 7014;
				
				singleElement.buffeid = SpecialEffectDefine.dianshuZengJia;
				singleElement.buffTime = 1;
				singleElement.buffValue = 3;
				singleElement.target = AttackRangeDefine.woFangQuanTi;
				retInfo.cdTime = 1;
			}
			else if(randomValue < 0.75)
			{
				retInfo.cardtype = BattleCardTypeDefine.baojiChu;
				retInfo.cardeffectid = 7001;
				
				singleElement.buffeid = SpecialEffectDefine.BaoJi;
				singleElement.buffTime = 3;
				singleElement.buffValue = 1;
				singleElement.target = AttackRangeDefine.woFangQuanTi;
				retInfo.cdTime = 1;
			}
			else
			{
				retInfo.cardtype = BattleCardTypeDefine.shiBingBuChong;
				retInfo.cardeffectid = 7010;
				
				singleElement.buffeid = SpecialEffectDefine.bingLiBuChong;
				singleElement.buffTime = 0;
				singleElement.buffValue = 1;
				singleElement.target = AttackRangeDefine.woFangDiYiPai;
				retInfo.cdTime = 1;
			}

		
			return retInfo;
		}
		
		public function makeCardWork():void
		{
			if(BattleManager.instance.status == OtherStatusDefine.battleIdle)
				return;
	
			var effectArr:Array = SkillEffectFunc.getFiltedBattleSingleEffects(skill);
			var singleEffect:BattleSingleEffect;
			var curSingleEffect:BattleSingleEffect;
			var index:int = 0;
			var i:int = 0;
			
			var singleTarget:CellTroopInfo;
			
			var curTargetObj:Object = BattleManager.cardManager.curTarget;
			var targetArr:Array = curTargetObj[usercardid];
			
			var troopAskArmInfo:Object={};
			var singleRet:Array;
			var curSupplyInfo:Object;
			var singleArmType:String;
			var singleBaseArmId:int;
			var totalValue:int;
			var needCount:int;
			var armId:int;
			var suppleNumber:int;
			var hpAfterAdd:int;
			var usedArmSupplyCount:Object = {};
			var hasArmToSupply:Boolean = true;
			var hasArmSupplyRecord:Object = {};
			if(this.cardtype == BattleCardTypeDefine.quanTiZengYuan)			//全体增援需要额外判断
			{
				//记录所有的兵种是否都有兵补充
				hasArmSupplyRecord = {};
				for(i = 0; i < targetArr.length;i++)
				{
					singleTarget = targetArr[i] as CellTroopInfo;
					if(singleTarget == null || singleTarget.logicStatus == LogicSatusDefine.lg_status_dead)
						continue;
					singleRet = TroopFunc.getTroopSuppleyNeed(singleTarget);
					if(singleRet[0] > 0)
					{
						totalValue = singleRet[1];
						if(totalValue <= 0)
							continue;
						if(troopAskArmInfo.hasOwnProperty(singleRet[0]))
						{
							totalValue = troopAskArmInfo[singleRet[0]] + singleRet[1];
						}
						troopAskArmInfo[singleRet[0]] = totalValue;
						hasArmSupplyRecord[singleRet[0]] = 1;
					}
				}
				curSupplyInfo = BattleInfoSnap.armySupplyInfo[this.uid];
				if(curSupplyInfo == null)
					curSupplyInfo = new Object();
				for(singleArmType in troopAskArmInfo)
				{
					singleBaseArmId = int(singleArmType);
					if(BattleInfoSnap.isDuoqiPvp || BattleInfoSnap.isDuoqiPVE)
						troopAskArmInfo[singleArmType] = troopAskArmInfo[singleArmType];
					else
						troopAskArmInfo[singleArmType] = Math.min(troopAskArmInfo[singleArmType],curSupplyInfo[singleBaseArmId]);
					if(troopAskArmInfo[singleArmType] > 0)
					{
						delete hasArmSupplyRecord[singleArmType];
					}
				}
				hasArmToSupply = true;
				for(var singleArmKey:String in hasArmSupplyRecord)			//只要有一种兵没有了，就提示缺兵 
				{
					hasArmToSupply = false;
					break;
				}
				if(!hasArmToSupply)			//没有兵可以补充
				{
					if(this.uid == GlobalData.owner.uid)
						GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.showNoArmInBarrack));
				}
			}
			else if(this.cardtype == BattleCardTypeDefine.fuhuo)					//复活死亡单位
			{
				var hasReboredTroop:Boolean = false;
				var sourceSide:PowerSide = BattleManager.instance.pSideAtk;
				var allDeadTroopsCanAlive:Array = [];
				hasArmSupplyRecord = {};
				
				var sideIndex:int = BattleFunc.getUserSelfSide(this.uid);
				sourceSide = sideIndex == BattleDefine.firstAtk ? BattleManager.instance.pSideAtk : BattleManager.instance.pSideDef;
				
				var herotroops:Array = sourceSide.allHeroInfoOnSide;
				var realHeroes:Array = [];
				var singleTroop:CellTroopInfo;
				for(var hIndex:int = 0;hIndex < herotroops.length;hIndex++)
				{
					singleTroop = herotroops[hIndex];
					if(singleTroop.logicStatus != LogicSatusDefine.lg_status_dead && singleTroop.logicStatus != LogicSatusDefine.lg_status_hangToDie)
					{
						realHeroes.push(singleTroop);
					}
				}
				for(hIndex = 0;hIndex < realHeroes.length;hIndex++)
				{
					singleTroop = realHeroes[hIndex];
					var deadTroops:Array = BattleInfoSnap.getDeadTroopsOfHero(singleTroop.troopIndex);
					if(deadTroops == null)
						continue;
					for(i = 0;i < deadTroops.length;i++)
					{
						singleTarget = deadTroops[i];
						allDeadTroopsCanAlive.push(singleTarget);
					}
				}
				for(i = 0;i < allDeadTroopsCanAlive.length;i++)
				{
					singleTarget = allDeadTroopsCanAlive[i];
					needCount = singleTarget.attackUnit.armcountofslot - singleTarget.curArmCount;
					
					hpAfterAdd = singleTarget.originalTotalHpValue;
					singleTarget.resolveDamageDisplayInfo(singleTarget.totalHpValue - hpAfterAdd,-1);
					
					singleTarget.logicStatus = LogicSatusDefine.lg_status_idle;
					singleTarget.mcStatus = McStatusDefine.mc_status_idle;
					hasReboredTroop = true;
					
				}
				if(hasReboredTroop)					//战斗进程需要暂停，直到死亡的troop补进完毕
				{
					BattleStage.instance.troopLayer.findRebornTroopPosition(sourceSide);
				}
			}
			else if(this.cardtype == BattleCardTypeDefine.budian)
			{
				trace("补点");
				var totalCount:int = 0;
				var singleElement:SkillElement = this.skill.elements[0];
				var totalstartCount:int = singleElement.buffValue;
				while(totalstartCount > 0)
				{
					index = int(NextSupplyShow.allSupplyTypes.length * Math.random());
					var curSupplyType:int = NextSupplyShow.allSupplyTypes[index]; 
					var starsCount:int = NextSupplyShow.getStarCountNeed(curSupplyType);
					
					if(totalstartCount < starsCount)
						continue;
					
					totalstartCount -= starsCount;
					
					var supplyArmType:int = NextSupplyShow.gettargetArmTypeBySupplytype(curSupplyType);
					var supplyeArmResId:int = DemoManager.getSingleRandomId(curSupplyType);
					
					DemoManager.makeNextArmSupply(BattleDefine.firstAtk,supplyArmType,supplyeArmResId,curSupplyType,true);		//
				}
				return;
			}	
			else if(this.cardtype == BattleCardTypeDefine.heroCard)
			{
				DemoManager.makeNextArmSupply(BattleDefine.firstAtk,0,0,0,false,true);
				return;
			}
			usedArmSupplyCount = {};
			
			var hasTargetWork:Boolean = false;
			var singleTargetUid:int = 0;
			
			if(effectArr == null)
				return;
			
			for(index = 0;index < effectArr.length;index++)
			{
				curSingleEffect = effectArr[index] as BattleSingleEffect;
				for(i = 0; i < targetArr.length;i++)
				{
					singleTarget = targetArr[i] as CellTroopInfo;
					TroopDisplayFunc.showSmallCard(singleTarget,false);
					if(singleTarget == null || singleTarget.logicStatus == LogicSatusDefine.lg_status_dead || singleTarget.logicStatus == LogicSatusDefine.lg_status_hangToDie)
						continue;
					hasTargetWork = true;
					if(!singleTarget.isHero)
						singleTargetUid = singleTarget.attackUnit.contentArmInfo.uid;
					
					singleEffect = curSingleEffect.getEffectCopy();
					singleEffect.effectSourceTroop = singleTarget.troopIndex;
					if(singleEffect.effectId == SpecialEffectDefine.bingLiBuChong)
					{
						var curMaxHp:int = singleTarget.totalHpValue;
						
						hpAfterAdd = curMaxHp;
						if(this.cardtype == BattleCardTypeDefine.quanTiZengYuan)
						{
							needCount = singleTarget.attackUnit.armcountofslot - singleTarget.curArmCount;
							armId = singleTarget.attackUnit.contentArmInfo.basearmid;
							suppleNumber = troopAskArmInfo[armId];
							needCount = Math.min(suppleNumber,needCount);
							if(needCount > 0)
							{
								troopAskArmInfo[armId] = suppleNumber - needCount;
								hpAfterAdd = Math.min(singleTarget.totalHpOfSlot,singleTarget.totalHpValue + needCount * singleTarget.maxTroopHp);
								
								if(usedArmSupplyCount.hasOwnProperty(armId))
									usedArmSupplyCount[armId] += needCount;
								else
									usedArmSupplyCount[armId] = needCount;
							}
						}
						else
						{
							hpAfterAdd = Math.min(singleTarget.totalHpOfSlot,curMaxHp + singleEffect.effectValue * singleTarget.maxTroopHp);							
						}
						
						var changedValue:int = hpAfterAdd - curMaxHp;
						singleTarget.resolveDamageDisplayInfo(0 - changedValue,-1);
						
						if(singleTarget.logicStatus == LogicSatusDefine.lg_status_hangToDie || singleTarget.logicStatus == LogicSatusDefine.lg_status_dead)
						{
							TroopFunc.handleDeadTroopLogic(singleTarget);
						}
					}
					else if(singleEffect.effectId == SpecialEffectDefine.AoYiChuFa)
					{
						BattleManager.aoyiManager.addAoYiTroop(singleTarget);
					}
					else if(singleEffect.effectId == SpecialEffectDefine.jiefeng)				//解封技能直接去除减益效果
					{
						TroopFunc.clearDecreaseBuff(singleTarget);
					}
					else if(singleEffect.effectId == SpecialEffectDefine.ShangHaiZengJia)
					{
						var oldValue:Number = singleEffect.effectValue;
						var newValue:Number = oldValue / singleTarget.attackUnit.damageValue;
						singleEffect.effectValue = newValue;
					}
					else if(singleTarget.isHero && singleEffect.effectId == SpecialEffectDefine.ShiQiZengJia && singleEffect.effectDuration <= 0)
					{
						singleTarget.changeHeroMorale(singleEffect.effectValue);
					}
					else
					{
						TroopFunc.addSingleBuff(singleTarget,singleEffect,true);
					}
					if(this.cardtype != BattleCardTypeDefine.shiQiTiSheng)
						TroopEffectDisplayFunc.showBattleCardEffect(singleTarget,this.cardtype);
				}
			}
			
			//全体增援以及复活需要扣除兵力
			if(this.cardtype == BattleCardTypeDefine.quanTiZengYuan)
			{
				if(BattleInfoSnap.isDuoqiPVE || BattleInfoSnap.isDuoqiPvp)
					return;
				for(var singleArmIdKey:String in usedArmSupplyCount)
				{
					usedArmSupplyCount[singleArmIdKey] = 0 - Math.abs(usedArmSupplyCount[singleArmIdKey]);
				}
			}
			
			if(this.cardtype == BattleCardTypeDefine.baohuqiang)
			{
				BattleScreenEffectFunc.showScreenShake(1);
			}
			
			//显示冰冻成功    封印以及解封的效果
			if(hasTargetWork)
			{
				var targetSide:int = BattleFunc.getUserSelfSide(singleTargetUid);
				if(this.cardtype == BattleCardTypeDefine.bingdong)
				{
					BattleStage.instance.showCardWorkGreatGreatEffect(cardtype,targetSide);
				}
				else if(this.cardtype == BattleCardTypeDefine.fengJiNeng)
				{
					targetSide = BattleFunc.getUserOpponentSide(singleTargetUid);
					BattleStage.instance.showCardWorkGreatGreatEffect(cardtype,targetSide);
				}
				else if(this.cardtype == BattleCardTypeDefine.jieFeng)
				{
					BattleStage.instance.showCardWorkGreatGreatEffect(cardtype,targetSide);
				}
			}
		}
		
	}
}