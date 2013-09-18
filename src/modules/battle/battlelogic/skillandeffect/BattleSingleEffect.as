package modules.battle.battlelogic.skillandeffect
{
	import eventengine.GameEventHandler;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import macro.EventMacro;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battleevents.EffectSourceDeadEvent;
	import modules.battle.battleevents.EffectTroopNewRoundEvent;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.funcclass.TroopEffectDisplayFunc;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.utils.BattleEventTagFactory;
	import modules.battle.utils.BattleUtils;
	
	import sysdata.SkillElement;

	/**
	 * 战斗过程中用到的特效数据结果 
	 * @author SDD
	 */
	public class BattleSingleEffect extends EventDispatcher
	{
		
		public var effectId:int = 0;								//效果类型
		private var _effectValue:*;									//效果数值
		private var _effectDuration:int = 0;						//效果持续回合
		public var effectTarget:int = 0;							//效果目标troop 攻击方式
		
		private var _effectSourceTroop:int = -1;							//发起此效果的troop
		
		//事件类型
		public static const effectDurationOver:String = "effectDurationOver";
		
		public function BattleSingleEffect(elementInfo:SkillElement = null)
		{
			if(elementInfo)
			{
				this.effectId = elementInfo.buffeid;
				this.effectDuration = elementInfo.buffTime;
				this.effectTarget = elementInfo.target;
				this.effectValue = elementInfo.buffValue;
			}
		}
		
		public function handlerCheckExist():Boolean
		{
			if(checkEffectLeagel())
				return true;
			else
			{
				effectDuration = 0;
				return false;
			}
		}
		
		private function checkEffectLeagel():Boolean
		{
			var retInfo:Boolean = true;
			if(_effectSourceTroop >= 0)
			{
				var sourceTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(_effectSourceTroop);
				if(sourceTroop == null || sourceTroop.logicStatus == LogicSatusDefine.lg_status_dead ||
					sourceTroop.logicStatus == LogicSatusDefine.lg_status_hangToDie)
					retInfo = false;
			}
			return retInfo;
		}
		
		/**
		 * 得到当前的效果对象
		 */
		public function getCureffect(targetTroopIndex:int):EffectOnCau
		{
			if(!checkEffectLeagel())
			{
				retValue = new EffectOnCau(SpecialEffectDefine.WuLiShangHaiMianYi);
				retValue.effectValue = 0;
				retValue.effectDuration = 0;
				retValue.effectTarget = targetTroopIndex;
				retValue.sourceTroopIndex = targetTroopIndex;
				retValue.sourceEffectObject = this;
				
				effectDuration = 0;
				return retValue;
			}
			var retValue:EffectOnCau = EffectOnCau.getNewEffectOnCau(effectId);
			retValue.effectValue = effectValue;
			retValue.effectDuration = effectDuration;
			retValue.effectTarget = targetTroopIndex;
			retValue.sourceTroopIndex = effectSourceTroop;
			retValue.sourceEffectObject = this;
			return retValue;
		}
		
		/**
		 * 获得数据拷贝 
		 * @return 
		 */
		public function getEffectCopy():BattleSingleEffect
		{
			var retValue:BattleSingleEffect = new BattleSingleEffect;
			retValue.effectId = this.effectId;
			retValue.effectDuration = this._effectDuration;
			retValue.effectTarget = this.effectTarget;
			if(this._effectValue is Array)
			{
				var tempArr:Array = this._effectValue as Array;
				var retArr:Array=[];
				for(var i:int = 0; i < tempArr.length;i++)
				{
					retArr.push(tempArr[i]);
				}
				retValue.effectValue = retArr;
			}
			else
			{
				retValue.effectValue = this.effectValue;
			}
			return retValue;
		}
		
		public function get effectSourceTroop():int
		{
			return _effectSourceTroop;
		}

		public function set effectSourceTroop(value:int):void
		{
			_effectSourceTroop = value;
		}
		
		public function addEventListner():void
		{
			if(_effectSourceTroop >= 0 && effectDuration > 0)			//增加回合减少/结束的事件监听
			{
				GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneNewTroopRoundTag(_effectSourceTroop),sourceTroopNewRoundHandler);
				GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneTroopDeadTag(_effectSourceTroop),sourceTroopDeadHandler);
			}
		}

		/**
		 *  
		 * @param event
		 * 
		 */
		public function sourceTroopNewRoundHandler(event:EffectTroopNewRoundEvent):void
		{
			effectDuration--;
		}
		
		/**
		 * 处理施放此技能的source死亡 
		 * @param event
		 */
		public function sourceTroopDeadHandler(event:EffectSourceDeadEvent):void
		{
			effectDuration = 0;
		}

		public function get effectDuration():int
		{
			return _effectDuration;
		}

		public function set effectDuration(value:int):void
		{
			_effectDuration = value;
			if(_effectDuration <= 0 && _effectSourceTroop >= 0)
			{
				this.dispatchEvent(new Event(effectDurationOver));
				GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneNewTroopRoundTag(_effectSourceTroop),sourceTroopNewRoundHandler);
				GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.geneTroopDeadTag(_effectSourceTroop),sourceTroopDeadHandler);
			}
		}

		public function get effectValue():*
		{
			return _effectValue;
		}

		public function set effectValue(value:*):void
		{
			_effectValue = value;
		}

		
	}
}