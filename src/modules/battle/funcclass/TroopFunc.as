package modules.battle.funcclass
{
	import flash.geom.Point;
	
	import avatarsys.avatar.AvatarConfig;
	import avatarsys.util.AvatarFrameConfig;
	import avatarsys.util.WeaponGenedEffectConfig;
	
	import caurina.transitions.Tweener;
	
	import eventengine.GameEventHandler;
	
	import macro.ArmType;
	import macro.BattleDisplayDefine;
	import macro.CommonEventTypeDefine;
	import macro.EventMacro;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.BattleTypeDefine;
	import modules.battle.battledefine.EffectShowTypeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battleevents.EffectSourceDeadEvent;
	import modules.battle.battleevents.TroopDeadEvent;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.battlelogic.skillandeffect.EffectOnCau;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.BattleUnitPool;
	
	import utils.BattleEffectConfig;
	import utils.TroopActConfig;
	import utils.TroopFrameConfig;
	import utils.Utility;

	/**
	 * TroopFunc   主要是各种寻找 
	 * @author SDD
	 */
	public class TroopFunc
	{
		public function TroopFunc()
		{
		}
		
		/**
		 * 过滤所有的效果，将所有回合到头的效果过滤掉 
		 */
		public static function filterAllEffect(troop:CellTroopInfo,isAtk:Boolean = true):void
		{
			var key:String;
			var singleEffect:BattleSingleEffect;
			var needClearKey:Array = [];
			if(isAtk)
			{
				for(key in troop.effectOnAttack)
				{
					singleEffect = troop.effectOnAttack[key] as BattleSingleEffect;
					if(singleEffect == null || singleEffect.effectDuration <= 0)
						needClearKey.push(key);
				}
				
				while(needClearKey.length > 0)
				{
					delete troop.effectOnAttack[needClearKey.shift()];
				}
				
				for(key in troop.kapianBufOnAttack)
				{
					singleEffect = troop.kapianBufOnAttack[key] as BattleSingleEffect;
					if(singleEffect == null || singleEffect.effectDuration <= 0)
						needClearKey.push(key);
				}
				
				while(needClearKey.length > 0)
				{
					delete troop.kapianBufOnAttack[needClearKey.shift()];
				}
			}
			else
			{
				for(key in troop.effectOnDefense)
				{
					singleEffect = troop.effectOnDefense[key] as BattleSingleEffect;
					if(singleEffect == null || singleEffect.effectDuration <= 0)
						needClearKey.push(key);
				}
				while(needClearKey.length > 0)
				{
					delete troop.effectOnDefense[needClearKey.shift()];
				}
				for(key in troop.kapianBufOnDefense)
				{
					singleEffect = troop.kapianBufOnDefense[key] as BattleSingleEffect;
					if(singleEffect == null || singleEffect.effectDuration <= 0)
						needClearKey.push(key);
				}
				while(needClearKey.length > 0)
				{
					delete troop.kapianBufOnDefense[needClearKey.shift()];
				}
			}
			for(key in troop.effectOnBothAtkDef)
			{
				singleEffect = troop.effectOnBothAtkDef[key] as BattleSingleEffect;
				if(singleEffect == null || singleEffect.effectDuration <= 0)
					needClearKey.push(key);
			}
			while(needClearKey.length > 0)
			{
				delete troop.effectOnBothAtkDef[needClearKey.shift()];
			}
			for(key in troop.kapianBufOnBothAtkDef)
			{
				singleEffect = troop.kapianBufOnBothAtkDef[key] as BattleSingleEffect;
				if(singleEffect == null || singleEffect.effectDuration <= 0)
					needClearKey.push(key);
			}
			while(needClearKey.length > 0)
			{
				delete troop.kapianBufOnBothAtkDef[needClearKey.shift()];
			}
		}
		
		/**
		 * 获得进攻时候或者防守时 产生影响的效果 (影响类)
		 * @return  技能的集合
		 */
		public static function effectingAffection(troop:CellTroopInfo,isOnAttack:Boolean,isHeroAtk:Boolean):Array
		{
			filterAllEffect(troop,isOnAttack);
			
			var retValue:Array=[];
			
			if(troop.isHero && isOnAttack)				//如果是英雄攻击
			{
				return retValue;
			}
			
			var targetObj:Array = isOnAttack ? troop.effectOnAttack.concat(troop.kapianBufOnAttack) : troop.effectOnDefense.concat(troop.kapianBufOnDefense);
			
			targetObj = targetObj.concat(troop.effectOnBothAtkDef);
			targetObj = targetObj.concat(troop.kapianBufOnBothAtkDef);
			
			var singleEffect:BattleSingleEffect;
			var singleEccectOnCau:EffectOnCau;
			for each(singleEffect in targetObj)
			{
				if(singleEffect)
				{
					singleEccectOnCau = singleEffect.getCureffect(troop.troopIndex);
					singleEccectOnCau.effectDuration = 0;
					retValue.push(singleEccectOnCau);
				}
			}
			
			if(isHeroAtk)						//如果是英雄攻击
			{
				for(var i:int = 0; i < retValue.length;i++)
				{
					singleEccectOnCau = retValue[i] as EffectOnCau;
					if(!BattleFunc.checkEffectCanBeUsedWhenAttackedByHero(singleEccectOnCau.effectId))				//将不能在英雄攻击的时候生效的effect删除
						delete retValue[i];
				}
			}
			
			return retValue;
		}
		
		/**
		 * 检测当前troop上是否含有某个特有的效果buf			比如是否被眩晕，是否中毒 
		 * @param effectId     效果ID
		 * @param isOnAtk	       是否是进行攻击
		 * @return 
		 */
		public static function hasSpecificEffect(troop:CellTroopInfo,effectId:int,isOnAtk:Boolean = true):Boolean
		{
			var retValue:Boolean = false;
			
			var targetObj:Array = isOnAtk ? troop.effectOnAttack.concat(troop.kapianBufOnAttack) : troop.effectOnDefense.concat(troop.kapianBufOnDefense);
			targetObj = targetObj.concat(troop.effectOnBothAtkDef);
			targetObj = targetObj.concat(troop.kapianBufOnBothAtkDef);
			
			var singleEffect:BattleSingleEffect;
			for(var i:int = 0; i < targetObj.length;i++)
			{
				singleEffect = targetObj[i] as BattleSingleEffect;
				if(singleEffect && singleEffect.effectId == effectId && singleEffect.effectDuration > 0 && singleEffect.handlerCheckExist())
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 获得某个已经存在effectId的所有效果 
		 * @param effectId
		 * @param isOnAtk
		 * @return 
		 */
		public static function getExistedParticularEffectsForTroop(troop:CellTroopInfo,effectId:int,isOnAtk:Boolean = true):Array
		{
			var resArr:Array=[];
			
			var targetObj:Array = isOnAtk ? troop.effectOnAttack.concat(troop.kapianBufOnAttack) : troop.effectOnDefense.concat(troop.kapianBufOnDefense);
			targetObj = targetObj.concat(troop.effectOnBothAtkDef);
			targetObj = targetObj.concat(troop.kapianBufOnBothAtkDef);
			
			var singleEffect:BattleSingleEffect;
			var singleEffectOnCau:EffectOnCau;
			for(var i:int = 0; i < targetObj.length;i++)
			{
				singleEffect = targetObj[i] as BattleSingleEffect;
				if(singleEffect && singleEffect.effectId == effectId && singleEffect.effectDuration > 0)
				{
					singleEffectOnCau = singleEffect.getCureffect(troop.troopIndex);
					singleEffectOnCau.effectDuration = 0;
					resArr.push(singleEffectOnCau);
				}
			}
			return resArr;
		}
		
		/**
		 * 取得某个troop上类型的所有效果此时的作用总值 
		 * @param troop					troop
		 * @param effectId				id
		 * @param isOnAtk				是否攻击
		 * @return 
		 */
		public static function getTotalValueFromExistedEffects(troop:CellTroopInfo,effectId:int,isOnAtk:Boolean = true):Number
		{
			var retValue:Number = 0;
			var effectArr:Array = getExistedParticularEffectsForTroop(troop,effectId,isOnAtk);
			for each(var singleEff:EffectOnCau in effectArr)
			{
				if(singleEff)
				{
					retValue += singleEff.effectValue;
				}
			}
			return retValue;
		}
		
		/**
		 * 向cell增加buff信息 
		 * @param troop					troop信息	
		 * @param buffInfo				buff信息
		 * @param fromKaPian			是否来自卡片
		 */
		public static function addSingleBuff(troop:CellTroopInfo,buffInfo:BattleSingleEffect,fromKaPian:Boolean = false):void
		{
			if(buffInfo == null)
				return;
			if(buffInfo.effectDuration <= 0)
				return;
			if(troop == null || troop.logicStatus == LogicSatusDefine.lg_status_dead)
				return;
			
			var sourceTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(buffInfo.effectSourceTroop);
			if(sourceTroop == null || sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead)
				return;
			
			var bufType:int = SkillEffectFunc.checkbufType(buffInfo.effectId);
			
			buffInfo.addEventListner();
			
			if(!fromKaPian)					//来自普通技能的buff
			{
				if(bufType == BattleTypeDefine.atkBuff)
				{
					troop.effectOnAttack.push(buffInfo);
				}
				else if(bufType == BattleTypeDefine.defBuff)
				{
					troop.effectOnDefense.push(buffInfo);
				}
				else
				{
					troop.effectOnBothAtkDef.push(buffInfo);
				}
				TroopDisplayFunc.showContinuousEffectIcons(troop,buffInfo);
			}
			else							//来自卡片的buff
			{
				if(bufType == BattleTypeDefine.atkBuff)
				{
					troop.kapianBufOnAttack.push(buffInfo);
				}
				else if(bufType == BattleTypeDefine.defBuff)
				{
					troop.kapianBufOnDefense.push(buffInfo);
				}
				else
				{
					troop.kapianBufOnBothAtkDef.push(buffInfo);
				}
			}
			//对于中毒眩晕等特殊效果，播放特殊效果
			if(SpecialEffectDefine.XuanYun == buffInfo.effectId)
			{
				TroopEffectDisplayFunc.showSpecialEffect(troop,buffInfo);
			}
			else if(SpecialEffectDefine.ZhongDu == buffInfo.effectId)
			{
				TroopEffectDisplayFunc.showSpecialEffect(troop,buffInfo);
			}
			else if(SpecialEffectDefine.shanghaiXiShou == buffInfo.effectId)				//伤害吸收
			{
				TroopEffectDisplayFunc.showSpecialEffect(troop,buffInfo);
			}
			else if(SpecialEffectDefine.baohuqiang == buffInfo.effectId)				//伤害吸收
			{
				TroopEffectDisplayFunc.showSpecialEffect(troop,buffInfo);
			}
			else if(SpecialEffectDefine.shiQiEWaiZengJia == buffInfo.effectId && buffInfo.effectDuration > 0)
			{
				TroopEffectDisplayFunc.showEffcetOnTroopCenter(troop,EffectShowTypeDefine.CardEffect_ShiQiTiSheng);
			}
//			else if(SpecialEffectDefine.WuLiShangHaiMianYi == buffInfo.effectId)
//			{
//				TroopEffectDisplayFunc.showSpecialEffect(troop,buffInfo);
//			}
//			else if(SpecialEffectDefine.MoFaShangHaiMianYi == buffInfo.effectId)
//			{
//				TroopEffectDisplayFunc.showSpecialEffect(troop,buffInfo);
//			}
			
			if(buffInfo.effectValue > 0 && SpecialEffectDefine.ShangHaiShuChuZengJia == buffInfo.effectId)
				TroopEffectDisplayFunc.showEffcetOnTroopCenter(troop,EffectShowTypeDefine.CardEffect_ShangHaiTiGao,buffInfo.getCureffect(troop.troopIndex));
		}
		
		/**
		 * 设置占用的cell数据 ,只设置当前列(竖直)列的
		 * @param troop
		 * @param status
		 */
		public static function setOccupiedCellStatus(troop:CellTroopInfo,status:int):void
		{ 
			var cellIndexArr:Array = BattleFunc.getCellsOccupied(troop.troopIndex);
			var tempPoint:Point;
			var curCheckRow:int = 0;
			if(troop.ownerSide == BattleDefine.firstAtk)
				curCheckRow = BattleManager.instance.pSideAtk.curCheckRow;
			else
				curCheckRow = BattleManager.instance.pSideDef.curCheckRow;
			if(cellIndexArr)
			{
				for(var i:int = 0; i < cellIndexArr.length; i++)
				{
					tempPoint = BattleTargetSearcher.getRowColumnByCellIndex(cellIndexArr[i]);
//					if(tempPoint.x == curCheckRow)
					{
						BattleManager.instance.curRound.allCellIndexObj[cellIndexArr[i]] = status;		//将此回合包含的所有cell标记为已经攻击
					}
				}
			}
		}
		
		/**
		 * 判断某个cell是否已经在回合中攻击过 
		 * @param cellIndex
		 * @return 
		 */
		public static function isCellAttackedInRound(cellIndex:int):Boolean
		{
			var tempInfoStore:Object = BattleManager.instance.curRound.allCellIndexObj;
			return tempInfoStore[cellIndex] == OtherStatusDefine.hasAttacked;
		}
		
		/**
		 * 将某个troop隐藏		死亡的时候 
		 * @param troop
		 */
		public static function hideParticularTroop(troop:CellTroopInfo,isForceDie:Boolean):void
		{
			if(troop == null)
				return;
			if(!troop.isHero)
			{
				if(isForceDie)
					Tweener.addTween(troop,{alpha:0,time:Utility.getFrameByTime(BattleDisplayDefine.troopDeadFadeDurationOfForce),useFrames:true,transition:"linear",onComplete:troop.selfFadeOver});
				else
					Tweener.addTween(troop,{alpha:0,time:Utility.getFrameByTime(BattleDisplayDefine.troopDeadFadeDuration),useFrames:true,transition:"linear",onComplete:troop.selfFadeOver});
			}
			else
			{
				if(isForceDie)
					Tweener.addTween(troop,{alpha:0,time:Utility.getFrameByTime(BattleDisplayDefine.troopDeadFadeDurationOfForce),useFrames:true,transition:"linear",onComplete:troop.selfFadeOver});
				else
					Tweener.addTween(troop,{alpha:0,time:Utility.getFrameByTime(BattleDisplayDefine.troopDeadFadeDuration),useFrames:true,transition:"linear",onComplete:troop.selfFadeOver});
			}
		}
		
		public static function handleDeadTroopLogic(troop:CellTroopInfo,isForce:Boolean = false):void
		{
			if(troop == null)
				return;
			if(troop.isHero || troop.logicStatus != LogicSatusDefine.lg_status_hangToDie)
			{
				hideParticularTroop(troop,isForce);
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectSourceDeadEvent(troop.troopIndex));
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new TroopDeadEvent(TroopDeadEvent.TROOPDEADEVENT,troop.troopIndex));
				return;
			}
			makeTroopDieReally(troop);
		}
		
		/**
		 * 让troop真正的死亡 
		 * @param troop
		 */
		public static function makeTroopDieReally(troop:CellTroopInfo):void
		{
			if(troop == null)
				return;
			hideParticularTroop(troop,false);
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new EffectSourceDeadEvent(troop.troopIndex));
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new TroopDeadEvent(TroopDeadEvent.TROOPDEADEVENT,troop.troopIndex));
		}
		
		/**
		 * 获得某个troop所有的
		 * @param	troop	troop信息
		 * @return 
		 */
		public static function getAllSkillsOfTroop(troop:CellTroopInfo):Array
		{
			var allTroopInfo:Array=[];
			
			if(troop == null)
				return allTroopInfo;
			
			if(troop.isHero)
			{
				if(troop.attackUnit && troop.attackUnit.contentHeroInfo)
				{
					allTroopInfo = troop.attackUnit.contentHeroInfo.unlockskills;
					if(allTroopInfo == null)
						allTroopInfo =[];
				}
			}
			else
			{
				if(troop.attackUnit.contentArmInfo.skill1obj)
					allTroopInfo.push(troop.attackUnit.contentArmInfo.skill1obj);
				if(troop.attackUnit.contentArmInfo.skill2obj)
					allTroopInfo.push(troop.attackUnit.contentArmInfo.skill2obj);
				if(troop.attackUnit.contentArmInfo.skill3obj)
					allTroopInfo.push(troop.attackUnit.contentArmInfo.skill3obj);
			}
			return allTroopInfo;
		}
		
		/**
		 * 获得某个logicframe的个数				英雄大招攻击攻击多次 
		 * @param troop							troop信息
		 * @param action						动作
		 * @return 
		 */
		public static function getUnitAttackCount(troop:CellTroopInfo,action:int):int
		{
			var count:int = 0;
			var effectId:int = 0;
			
			if(troop.attackUnit.armtype == ArmType.magic)		//法师可能有多次攻击,通过特效文件来获得
			{
				effectId = TroopActConfig.getMagicEffect(troop.mcIndex);
				count = BattleEffectConfig.getAttackTimesOfEffect(effectId);
			}
			else if(troop.attackUnit.armtype == ArmType.machine)
			{
				effectId = TroopActConfig.getMachineEffect(troop.mcIndex);
				count = BattleEffectConfig.getAttackTimesOfEffect(effectId);
			}
			else
			{
				count = 1;
			}
			return count;
		}
		
		/**
		 * 获得某个troop的某个动作的所有帧数 带连击
		 * @param troop
		 * @param action
		 * @return 
		 */
		public static function getActionMultipleFrames(troop:CellTroopInfo,action:int):Array
		{
			var retValue:Array;
			if(troop.isPlayerHero)
			{
				var weaponType:int = WeaponGenedEffectConfig.getWeaponType(troop.avatarShowObj.avatarConfig.weapon);
				retValue = AvatarFrameConfig.getLogicActionFrames(troop.avatarShowObj.roleName,action,weaponType,troop.avatarShowObj.avatarConfig.mount);
			}
			else
			{
				retValue = TroopFrameConfig.getActionFrames(troop.mcIndex,action);
			}
			return retValue;
		}
		
		/**
		 * 获得某个troop动作的 实际帧数范围
		 * @param troop
		 * @param action
		 * @return 
		 */
		public static function getActionFrameRange(troop:CellTroopInfo,action:int):Point
		{
			var retPoint:Point = new Point;
			if(troop.isPlayerHero)
			{
				var weaponType:int = WeaponGenedEffectConfig.getWeaponType(troop.avatarShowObj.avatarConfig.weapon);
				retPoint = AvatarFrameConfig.getFrameRange(troop.avatarShowObj.roleName,action,weaponType,troop.avatarShowObj.avatarConfig.mount);
			}
			else
			{
				retPoint = TroopFrameConfig.getFrameRange(troop.mcIndex,action);
			}
			return retPoint;
		}
		
		/**
		 * 获得某个troop攻击时，被攻击方播放的被打特效id 
		 * @param troop
		 * @param chongdie
		 * @return 
		 */
		public static function getAttackedEffect(troop:CellTroopInfo,chongdie:Boolean):int
		{
			if(troop.isPlayerHero)
			{
				var retValue:int;
				if(!chongdie)
					retValue = WeaponGenedEffectConfig.getNormalAttackedEffect(troop.avatarShowObj.avatarConfig);
				else
					retValue = WeaponGenedEffectConfig.getSecondAttackEffect(troop.avatarShowObj.avatarConfig);
				return retValue;
			}
			else
			{
				if(!chongdie)
					return TroopActConfig.getNormalAttackEffect(troop.mcIndex);
				else
					return TroopActConfig.getSecondAttackEffect(troop.mcIndex);
			}
		}
		
		/**
		 *  
		 * @param troop
		 * @return 
		 */
		public static function getMissileEffect(troop:CellTroopInfo):int
		{
			var retValue:int = 0;
			if(troop == null)
				return retValue;
			if(troop.isPlayerHero)						//如果是avatar显示
			{
				retValue = WeaponGenedEffectConfig.getMissile(troop.avatarShowObj.avatarConfig);
			}
			else										//普通小兵 英雄
			{
				retValue = TroopActConfig.getMissile(troop.mcIndex);
			}
			return retValue;
		}
		
		/**
		 * 显示或隐藏士气条 
		 * @param troop
		 * @param show
		 */
		public static function showMoraleBar(troop:CellTroopInfo,show:Boolean):void
		{
			if(troop == null || !troop.isHero || troop.moraleBar == null)
			{
				return;
			}
			troop.moraleBar.visible = show;
			if(show)
			{
				if(BattleManager.instance.enableMorale || BattleManager.instance.enableMoraleTemporary || troop.ownerSide == BattleDefine.secondAtk)
				{
					troop.moraleBar.visible = true;
				}
				else
				{
					troop.moraleBar.visible = false;
				}
			}
		}
		
		/**
		 * 得到troop的基准位置 
		 * @param troopInfo					troop信息
		 * @return 
		 */
		public static function getTroopBasePos(troopInfo:CellTroopInfo):Point
		{
			if(troopInfo == null)
				return new Point(0,0);
			if(troopInfo.ownerSide == BattleDefine.firstAtk)
				return new Point(troopInfo.x + BattleDisplayDefine.cellWidth,troopInfo.y);
			else
				return new Point(troopInfo.x,troopInfo.y);
		}
		
		/**
		 * 初始化错开时间 
		 * @param troopInof
		 * @param init
		 */
		public static function initTroopStaggerTimer(troopInofo:CellTroopInfo,init:Boolean = false,time:int = 0):void
		{
			return;
			if(troopInofo == null)
				return;
			troopInofo.staggerFrameCountLeft = 0;
			GameEventHandler.removeListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_BattleStaggerFrame,troopInofo.handleStagerFrameDecrease);
			troopInofo.isOnStaggerWait = false;
			if(init)
			{
				if(time > 0)
				{
					troopInofo.isOnStaggerWait = true;
					troopInofo.staggerFrameCountLeft = time;
					GameEventHandler.addListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_BattleStaggerFrame,troopInofo.handleStagerFrameDecrease);
					
					if(BattleManager.needTraceBattleInfo)
					{
						trace(troopInofo.troopIndex," 错开进攻时间");
					}
				}
			}
		}
		
		/**
		 * 调整位置，取得该troop的中心位置 
		 * @param curPosition
		 * @return 
		 */
		public static function adjustEffectPosOnY(troop:CellTroopInfo,curPosition:Point,targetCell:Cell = null):void
		{
			if(troop != null && targetCell != null)
			{
				var targetCellPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(targetCell.index);
				var troopPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(troop.occupiedCellStart);
				curPosition.y += (targetCellPos.y - troopPos.y)* (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal);
			}
		}
		
		/**
		 * 更新 某个troop的source
		 * @param troop
		 * @param sourceIndex
		 */
		public static function addTroopDamageSource(troop:CellTroopInfo,chainIndex:int):void
		{
			if(troop == null)
				return;
			if(troop.alldamageSource.hasOwnProperty(chainIndex))
				return;
			troop.alldamageSource[chainIndex] = 0;
		}
		
		public static function isPlayerSelfTroop(troopInfo:CellTroopInfo):Boolean
		{
			if(troopInfo && troopInfo.attackUnit)
			{
				if(troopInfo.isHero)
				{
					if(troopInfo.attackUnit.contentHeroInfo)
						return troopInfo.attackUnit.contentHeroInfo.uid == GlobalData.owner.uid;		
					else
						return false;
				}
				else
				{
					return troopInfo.attackUnit.contentArmInfo.uid == GlobalData.owner.uid;
				}
			}
			return false;
		}
		
		public static function isSelfTroopInfo(troopInfo:CellTroopInfo,sourceTroop:CellTroopInfo):Boolean
		{
			if(troopInfo.ownerSide != BattleDefine.firstAtk)
				return true;
			var targetUid:int = 0;
			if(troopInfo.isHero)
			{
				targetUid = troopInfo.attackUnit.contentHeroInfo.uid;
			}
			else
			{
				targetUid = troopInfo.attackUnit.contentArmInfo.uid;
			}
			
			var sourceUid:int = 0;
			if(sourceTroop.isHero)
			{
				if(sourceTroop.ownerSide == BattleDefine.firstAtk)
					sourceUid = 0;
				else
				{
					sourceUid = 1;
				}
			}
			else
			{
				sourceUid = sourceTroop.attackUnit.contentArmInfo.uid;
			}
			
			return sourceUid == targetUid;
		}
		
		public static function getTroopAvatarConfigInfo(troopInfo:CellTroopInfo,isFirst:Boolean):AvatarConfig
		{
			var retConfig:AvatarConfig = new AvatarConfig;
			if(!BattleModeDefine.checkNeedServerData())
			{
				if(BattleManager.instance.battleMode == BattleModeDefine.PVE_DANRENFUBENWithLansquenet)
				{
					if(troopInfo.attackUnit.contentHeroInfo.uid != GlobalData.owner.uid)
						retConfig = BattleInfoSnap.getSingleUserAvatarInfo(troopInfo.attackUnit.contentHeroInfo.uid);
				}
				else
				{
				}
			}
			else
			{
				retConfig = BattleInfoSnap.getSingleUserAvatarInfo(troopInfo.attackUnit.contentHeroInfo.uid);
			}
			return retConfig;
		}
		
		/**
		 * 获得某个troop可以被补充的兵力值 
		 * @param troopInfo
		 * @return 
		 */
		public static function getTroopSuppleyNeed(troopInfo:CellTroopInfo):Array
		{
			var retValue:Array=[];
			
			retValue[0] = 0;
			retValue[1] = 0;
			if(troopInfo == null || troopInfo.isHero)
				return retValue;
			
			retValue[0] = troopInfo.attackUnit.contentArmInfo.basearmid;
			retValue[1] = troopInfo.attackUnit.armcountofslot - troopInfo.curArmCount;
			
			return retValue;
		}
		
		/**
		 * 清除所有的减益处效果 
		 * @param troop
		 */
		public static function clearDecreaseBuff(troop:CellTroopInfo):void
		{
			if(troop == null || troop.isHero)
				return;
			var targetObj:Array = [];
			targetObj = targetObj.concat(troop.effectOnAttack,troop.kapianBufOnAttack,troop.effectOnDefense,troop.kapianBufOnDefense);
			targetObj = targetObj.concat(troop.effectOnBothAtkDef);
			targetObj = targetObj.concat(troop.kapianBufOnBothAtkDef);
			
			var singleEffect:BattleSingleEffect;
			for(var i:int = 0; i < targetObj.length;i++)
			{
				singleEffect = targetObj[i] as BattleSingleEffect;
				if(singleEffect == null || singleEffect.effectDuration <= 0)
				{
					continue;
				}
				var needClear:Boolean = false;
				switch(singleEffect.effectId)
				{
					case SpecialEffectDefine.WuLiShangHaiMianYi:
					case SpecialEffectDefine.MoFaShangHaiMianYi:
						if(singleEffect.effectValue > 0)
							needClear = true;
						break;
					case SpecialEffectDefine.ShangHaiShuChuZengJia:
					case SpecialEffectDefine.BaoJiZengJia:
					case SpecialEffectDefine.ShanBiZengJia:
					case SpecialEffectDefine.ShangHaiZengJia:
						if(singleEffect.effectValue < 0)
							needClear = true;
						break;
					case SpecialEffectDefine.ZhongDu:
					case SpecialEffectDefine.XuanYun:
						needClear = true;
						break;
					default:
						break;
				}
				if(needClear)
					singleEffect.effectDuration = 0;
			}
			
			filterAllEffect(troop,true);
			filterAllEffect(troop,false);
		}
		
	}
}