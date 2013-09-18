package modules.battle.battlecomponent
{
	import caurina.transitions.Tweener;
	
	import effects.BattleEffectObjBase;
	import effects.BattleResourcePool;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import macro.BattleDisplayDefine;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battleconfig.BattleEffectIdConfig;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.EffectShowTypeDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;

	/**
	 * 显示troop所挂着的iocn的容器 
	 * @author SDD
	 */
	public class EffectIconSlots extends TroopComponentBase
	{
		
		private var maskSp:Sprite;
		
		private var curShowSortedEffects:Array = [];
		private var curStoredEffects:Object = {};
		private var allKindEffs:Object = {};
		
		private var isAtk:Boolean = false;				//是否为攻击方，处理位置
		private var startPos:Point = new Point;
		
		public function EffectIconSlots(troop:CellTroopInfo)
		{
			super(troop);
			curStoredEffects = {};
			curShowSortedEffects =[];
			allKindEffs = {};
			
			maskSp = new Sprite;
			maskSp.graphics.clear();
			maskSp.graphics.beginFill(0,0);
			maskSp.graphics.drawRect(0,0,BattleDisplayDefine.iconWidth,BattleDisplayDefine.iconGapVertical * BattleDisplayDefine.maxShowIconCount);
			maskSp.graphics.endFill();
			this.addChild(maskSp);
			maskSp.x = startPos.x;
			maskSp.y = startPos.y;
			this.mask = maskSp;
		}
		
		/**
		 * 初始化 
		 */
		public function initStatus():void
		{
			for each(var singleBitmap:BattleEffectObjBase in curStoredEffects)
			{
				if(singleBitmap)
				{
					if(this.contains(singleBitmap))
						this.removeChild(singleBitmap);
					singleBitmap.isBusy = false;
				}
			}
			curStoredEffects = {};
			curShowSortedEffects = [];
			
		}
		
		/**
		 * 增加一个新的effect 
		 * @param effect
		 */
		public function addnewEffectIcon(effect:BattleSingleEffect):void
		{
			if(effect == null || effect.effectDuration <= 0 || effect.effectDuration >= BattleDefine.guanghuangDurationOnCheck)
				return;
			
			effect.addEventListener(BattleSingleEffect.effectDurationOver,singleEffectDurationOver);
			
			var curExistedIndex:int = curShowSortedEffects.indexOf(effect.effectId);
			if(curExistedIndex >= 0)
			{
				curShowSortedEffects.splice(curExistedIndex,1);
			}
			curShowSortedEffects.push(effect.effectId);
			
			if(!curStoredEffects[effect.effectId])
			{
				var effectShowTypeId:int = getTargetEffectShowId(effect);
				var resId:int = BattleEffectIdConfig.getResIdForEffect(effectShowTypeId);
				
				if(resId <= 0)
					return;
				
				var battleIconObj:BattleEffectObjBase = BattleResourcePool.getFreeResourceUnit(resId);
				curStoredEffects[effect.effectId] = battleIconObj;
				
				var pos:Point = new Point;
				pos.y = Math.min(curShowSortedEffects.length - 1,BattleDisplayDefine.maxShowIconCount) * BattleDisplayDefine.iconGapVertical;
				
				pos.x = pos.x + startPos.x;
				pos.y = pos.y + startPos.y;
				
				battleIconObj.x = pos.x;
				battleIconObj.y = pos.y;
				this.addChild(battleIconObj);
			}
			adjustIcocPos();
		}
		
		//重新计算当前所挂的buff
		private function reCalcauCurBuffs():void
		{
			var targetObj:Array = dataSource.effectOnAttack.concat(dataSource.effectOnDefense,dataSource.kapianBufOnAttack);
			var singleEffect:BattleSingleEffect;
			var allEffsDuration:Object = {};
			allKindEffs = {};
			for(var i:int = 0;i < targetObj.length;i++)					//重组当前的buff的值
			{
				singleEffect = targetObj[i];
				if(singleEffect == null || singleEffect.effectDuration >= BattleDefine.guanghuangDurationOnCheck)
					continue;
				if(!allKindEffs.hasOwnProperty(singleEffect.effectId))
					allKindEffs[singleEffect.effectId] = 0;
				if(!allEffsDuration.hasOwnProperty(singleEffect.effectId))
					allEffsDuration[singleEffect.effectId] = 0;
				var curValue:Number = allKindEffs[singleEffect.effectId];
				curValue += singleEffect.effectValue;
				var curDuration:int = allEffsDuration[singleEffect.effectId];
				curDuration = Math.max(curDuration,singleEffect.effectDuration);
				allKindEffs[singleEffect.effectId] = curValue;
				allEffsDuration[singleEffect.effectId] = curDuration;
			}
			
			for(i = 0;i < curShowSortedEffects.length;i++)
			{
				var singleEffectID:int = curShowSortedEffects[i];
				if(allKindEffs.hasOwnProperty(singleEffectID) && allKindEffs[singleEffectID] != null && allEffsDuration[singleEffectID] > 0)
					continue;
				var childObj:BattleEffectObjBase = curStoredEffects[singleEffectID]; 
				if(childObj != null && this.contains(childObj))
					this.removeChild(childObj);
				delete curStoredEffects[singleEffectID]; 
				curShowSortedEffects.splice(i,1);
				i--;
			}
			adjustIcocPos();
		}
		
		/**
		 * 某个effect失效 重新调整位置
		 * @param event
		 */
		private function singleEffectDurationOver(event:Event):void
		{
			//需要重新刷新effect信息
			reCalcauCurBuffs();
			adjustIcocPos();
		}
		
		/**
		 * 获得某个icon应该出现的位置 
		 * @return 			位置
		 * 
		 */
		public function getTargetPos(index:int):Point		
		{
			var pos:Point = new Point(0,0);
			var lineCount:int = (index - 1) / BattleDisplayDefine.maxCountPerVertical;
//			if(isAtk)
//			{
//				pos.x += lineCount * BattleDisplayDefine.iconGapHorizon;
//			}
//			else
//			{
//				pos.x -= lineCount * BattleDisplayDefine.iconGapHorizon;
//			}
//			pos.y += (index - 1) * BattleDisplayDefine.iconGapVertical;
			
			if(curShowSortedEffects.length <= BattleDisplayDefine.maxShowIconCount)
			{
				pos.y = BattleDisplayDefine.iconGapVertical * (index - 1);
			}
			else 
			{
				pos.y = 0 - BattleDisplayDefine.iconGapVertical * (curShowSortedEffects.length - BattleDisplayDefine.maxShowIconCount - index + 1);
			}
			
			pos.x = pos.x + startPos.x;
			pos.y = pos.y + startPos.y;
			
			return pos;
		}
		
		/**
		 * 调整位置
		 */
		private function adjustIcocPos():void
		{
			var curIndex:int = 0;
			var singlePos:Point;
			var childObj:BattleEffectObjBase;
			for(var i:int = 0;i < curShowSortedEffects.length; i++)
			{
				if(curStoredEffects[curShowSortedEffects[i]])
				{
					childObj = curStoredEffects[curShowSortedEffects[i]];
					if(childObj && this.contains(childObj))
					{
						curIndex++;
						singlePos = getTargetPos(curIndex);
						Tweener.removeTweens(childObj);
						Tweener.addTween(childObj,{x:singlePos.x,y:singlePos.y,time:BattleDisplayDefine.iconMoveDuration,transition:"linear"});
					}
				}
			} 
		}
		
		override public function set dataSource(value:CellTroopInfo):void
		{
			super.dataSource = value;
			isAtk = (super.dataSource.ownerSide == BattleDefine.firstAtk);
			if(isAtk)
			{
				startPos = new Point(BattleDisplayDefine.changzhiIconSidePadding,BattleDisplayDefine.changzhiIconTopPadding);
				startPos.x -= (dataSource.cellsCountNeed.x - 1) * BattleDisplayDefine.cellWidth;
			}
			else
			{
				startPos = new Point(BattleDisplayDefine.cellWidth - BattleDisplayDefine.changzhiIconSidePadding - BattleDisplayDefine.iconWidth,
					BattleDisplayDefine.changzhiIconTopPadding);
				startPos.x += (dataSource.cellsCountNeed.x - 1) * BattleDisplayDefine.cellWidth;
			}
		}

		/**
		 * 根据给定的effect获得对应的effectid 
		 * @param effect
		 * @return 
		 */
		public static function getTargetEffectShowId(effect:BattleSingleEffect):int
		{
			var targetId:int = 0;
			switch(effect.effectId)
			{
				case SpecialEffectDefine.BaoJiZengJia:
					if(effect.effectValue > 0)
						targetId = EffectShowTypeDefine.EffectIcon_BaojiTiSheng;
					else if(effect.effectValue < 0)
						targetId = EffectShowTypeDefine.EffectIcon_BaojiJiangDi;
					break;
				case SpecialEffectDefine.ShanBiZengJia:
					if(effect.effectValue > 0)
						targetId = EffectShowTypeDefine.EffectIcon_ShanbiTiSheng;
					else if(effect.effectValue < 0)
						targetId = EffectShowTypeDefine.EffectIcon_ShanbiJiangDi;
					break;
				case SpecialEffectDefine.ShangHaiShuChuZengJia:
					if(effect.effectValue < 0)
						targetId = EffectShowTypeDefine.EffectIcon_GongjiJiangdi;
					if(effect.effectValue > 0)
						targetId = EffectShowTypeDefine.EffectIcon_GongjiTiSheng;
					break;
				case SpecialEffectDefine.MoFaShangHaiMianYi:
					if(effect.effectValue < 0)
						targetId = EffectShowTypeDefine.EffectIcon_MoFaFangyuTiSheng;
					if(effect.effectValue > 0)
						targetId = EffectShowTypeDefine.EffectIcon_MoFaPoJia;
					break;
				case SpecialEffectDefine.WuLiShangHaiMianYi:
					if(effect.effectValue < 0)
						targetId = EffectShowTypeDefine.EffectIcon_WuLiFangyuTiSheng;
					else if(effect.effectValue > 0)
						targetId = EffectShowTypeDefine.EffectIcon_WuLiPoJia;
					break;
				case SpecialEffectDefine.HPShangXianZengJia:
					if(effect.effectValue < 0)
						targetId = EffectShowTypeDefine.EffectIcon_ShengmingJiangDi;
					else if(effect.effectValue > 0)
						targetId = EffectShowTypeDefine.EffectIcon_ShengmingTiSheng;
					break;
				case SpecialEffectDefine.noSkillChuFa:							//技能不触发
					targetId = EffectShowTypeDefine.EffectShow_jinengBuChuFa;
					break;
				case SpecialEffectDefine.noSkillChuFa:							//技能必定触发
					targetId = EffectShowTypeDefine.EffectShow_jinengBiRanChuFa;
					break;
				case SpecialEffectDefine.shengmingHuiFu:
					targetId = EffectShowTypeDefine.EffectShow_shengmingChixuJia;
					break;
			}
			
			return targetId;
		}
		
		/**
		 * clearInfo信息 
		 */
		override public function clearInfo():void
		{
			for each(var singleBitmap:BattleEffectObjBase in curStoredEffects)
			{
				if(singleBitmap)
				{
					if(this.contains(singleBitmap))
						this.removeChild(singleBitmap);
					singleBitmap.isBusy = false;
				}
			}
			allKindEffs = {};
			curStoredEffects = {};
			curShowSortedEffects = [];
		}
		
	}
}