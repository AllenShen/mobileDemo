package modules.battle.funcclass
{
	import animator.animatorengine.AnimatorEngine;
	import animator.resourceengine.ResType;
	
	import caurina.transitions.Tweener;
	
	import effects.BattleEffectObjBase;
	
	import eventengine.GameEventHandler;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.sensors.Accelerometer;
	
	import macro.EventMacro;
	
	import modules.battle.battlecomponent.BattleEffectSwfForEffect;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.McStatusDefine;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.stage.BattleStage;
	
	import synchronousLoader.GameResourceManager;
	import synchronousLoader.LoadUnit;
	import synchronousLoader.ResourceConfig;
	import synchronousLoader.ResourcePool;

	/**
	 * troop初始化	清理的函数 
	 * @author SDD
	 */
	public class TroopInitClearFunc
	{
		public function TroopInitClearFunc()
		{
		}
		
		/**
		 * 清空某个troop上的所有时间监听事件 
		 */
		public static function clearTroopListener(troopInfo:CellTroopInfo,force:Boolean = false):void
		{
			if(troopInfo)
			{
				if(!troopInfo.isHero || force)
					AnimatorEngine.removeAllHandlersForPlayer(troopInfo.troopPlayerId);
			}
		}
		
		/**
		 * 将被simplyclear的troop初始化
		 * @param troopInfo
		 */
		public static function initTroopSimply(troopInfo:CellTroopInfo):void
		{
			if(troopInfo == null || troopInfo.isHero)
				return;
			troopInfo.addEventListener(MouseEvent.ROLL_OVER,troopInfo.troopMouseRollInHandler);
			troopInfo.addEventListener(MouseEvent.ROLL_OUT,troopInfo.troopMouseRollOutHandler);
			troopInfo.mcIndex = troopInfo.attackUnit.contentArmInfo.effectid;				//初始化mcindex
			TroopDisplayFunc.initShowInfo(troopInfo);																	//初始化各种控件
		}
		
		//将可以清空的信息清空掉
		public static function clearTroopSimply(troopInfo:CellTroopInfo,needRelease:Boolean = false):void
		{
			if(troopInfo == null)
				return;
			
			troopInfo.stageBelong = -1;
			troopInfo.graphics.clear();
			troopInfo.curSelectedStatus = BattleDefine.Status_NoShow;
			GameResourceManager.eventHandler.removeEventListener(troopInfo.mcIndex.toString(),troopInfo.singleBackLoadAnimatorLoaded);
			if(troopInfo.isHero)
			{
				GameResourceManager.eventHandler.removeEventListener((troopInfo.mcIndex * ResourceConfig.swfIdMapValue).toString(),troopInfo.singleBackLoadAnimatorLoaded);
			}
			GameEventHandler.removeAllListener(EventMacro.singleTroopHandlerMacro(troopInfo.troopIndex));
			TroopInitClearFunc.clearTroopListener(troopInfo);
			troopInfo.startPos = new Point();
			
			troopInfo.moraleValue = 0;
			troopInfo.curArmCount = 0;
			troopInfo.curTroopHp = 0;
			troopInfo.isEffectChongdie = false;
			troopInfo.waitDamageSource = -1;
			troopInfo.alldamageSource ={};
			
			troopInfo.allHeroArr = null;
			troopInfo.heroPropertyStore = {};
			troopInfo.isTroopFanji = false;
			troopInfo.isFirstOnTotalAtk = false;
			TroopFunc.initTroopStaggerTimer(troopInfo);
			troopInfo.removeEventListener(MouseEvent.ROLL_OVER,troopInfo.troopMouseRollInHandler);
			troopInfo.removeEventListener(MouseEvent.ROLL_OUT,troopInfo.troopMouseRollOutHandler);
			
			for each(var singleBattleEffectSwfForEffect:BattleEffectSwfForEffect in troopInfo.specialEffects)
			{
				if(singleBattleEffectSwfForEffect)
					singleBattleEffectSwfForEffect.clearInfo();
			}
			troopInfo.specialEffects ={};
			
			var singleEffect:BattleSingleEffect;
			var allPool:Array = [troopInfo.effectOnAttack,troopInfo.effectOnDefense,troopInfo.effectOnBothAtkDef,
				troopInfo.kapianBufOnAttack,troopInfo.kapianBufOnDefense,troopInfo.kapianBufOnBothAtkDef];
			
			for each(var singlePool:Array in allPool)
			{
				if(singlePool)
				{
					while(singlePool.length > 0)
					{
						singleEffect = singlePool.pop() as BattleSingleEffect;
						if(singleEffect)
							singleEffect.effectDuration = 0;
						singleEffect = null;
					}
				}
			}
			
			TroopDisplayFunc.showSmallCard(troopInfo,false);
			TroopDisplayFunc.showArmSupplyeInfo(troopInfo,false);
			
			clearTroopCharacterShowInfo(troopInfo,needRelease);
			
			if(troopInfo.mcIndex != 0)
			{
//				ResourcePool.releaseResourceById(troopInfo.mcIndex,needRelease);
				if(!troopInfo.isHero)
				{
					var tempLoadUnit:LoadUnit = ResourceConfig.getSingleResConfigById(troopInfo.mcIndex);
					if(tempLoadUnit && tempLoadUnit.m_type == ResType.REFLECT_SWF)
					{
						ResourcePool.releaseResourceById(troopInfo.mcIndex,false);
					}
				}
				troopInfo.mcIndex = 0;
			}
			
			troopInfo.troopPlayerId = "";
			troopInfo.mirrorLayer.scaleX = 1;
			troopInfo.mirrorLayer.x = 0;
			
			troopInfo.visible = false;
			
			troopInfo.heroOffectValue = 0;			//herotroop的偏移量归零
			
			Tweener.removeTweens(troopInfo);
			
			troopInfo.effectObjBasesAddedToTroop ={};
			
			if(troopInfo.iconSlots)
			{
				if(troopInfo.componentsLayer.contains(troopInfo.iconSlots))
					troopInfo.componentsLayer.removeChild(troopInfo.iconSlots);
				troopInfo.iconSlots.clearInfo();
				troopInfo.iconSlots = null;
			}
			if(troopInfo.hpBar)
			{
				if(troopInfo.componentsLayer.contains(troopInfo.hpBar))
					troopInfo.componentsLayer.removeChild(troopInfo.hpBar);
				troopInfo.hpBar.clearInfo();
				troopInfo.hpBar = null;
			}
			if(troopInfo.moraleBar)
			{
				if(troopInfo.componentsLayer.contains(troopInfo.moraleBar))
					troopInfo.componentsLayer.removeChild(troopInfo.moraleBar);
				troopInfo.moraleBar.clearInfo();
				troopInfo.moraleBar = null;
			}
			if(troopInfo.selfHeroGuideArrow)
			{
				if(troopInfo.selfHeroGuideArrow.parent)
					troopInfo.selfHeroGuideArrow.parent.removeChild(troopInfo.selfHeroGuideArrow);
				troopInfo.selfHeroGuideArrow.ClearRes();
				troopInfo.selfHeroGuideArrow = null;
			}
			
			if(troopInfo.parent && troopInfo.parent.contains(troopInfo))
				troopInfo.parent.removeChild(troopInfo);
			
			troopInfo.chainInvolved = null;
			BattleInfoSnap.troopsHaveBeenSimplyCleared[troopInfo.troopIndex] = 1;
			troopInfo.needDispatchAtkEvent = false;
			troopInfo.haveDispatchAtkEvent = false;
			
			if(troopInfo.attackUnit)
				troopInfo.attackUnit.contentHeroInfo = null;
		}
		
		/**
		 * 清空troop信息  troop死亡或者初始化时执行 
		 */
		public static function clearTroopInfo(troopInfo:CellTroopInfo,needRelease:Boolean):void
		{
			if(troopInfo == null)
				return;
			
			troopInfo.mappedHeroIndex = -1;
			
			if(!BattleInfoSnap.troopsHaveBeenSimplyCleared.hasOwnProperty(troopInfo.troopIndex))
			{
				clearTroopSimply(troopInfo,needRelease);
			}
			else
			{
				delete BattleInfoSnap.troopsHaveBeenSimplyCleared[troopInfo.troopIndex];
			}
			
			troopInfo.ownerSide = 0;
			troopInfo.occupiedCellStart = -1;
			troopInfo.cellsCountNeed = new Point(0,0);
			
			troopInfo.mcStatus = McStatusDefine.mc_status_idle;
			troopInfo.logicStatus = LogicSatusDefine.lg_status_idle;
			
			//清空当前的所有效果
			
			troopInfo.slotIndex = -1;
			troopInfo.needDispatchAtkEvent = false;
			troopInfo.haveDispatchAtkEvent = false;
			
			if(troopInfo.componentsLayer)
			{
				while(troopInfo.componentsLayer.numChildren > 0)
				{
					troopInfo.componentsLayer.removeChildAt(0);
				}
			}
			
			while(troopInfo.numChildren > 0)
				troopInfo.removeChildAt(0);
			
			troopInfo.isBusy = false;
		}
		
		public static function clearTroopCharacterShowInfo(troopInfo:CellTroopInfo,needRelease:Boolean = false):void
		{
			if(troopInfo.avatarShowObj)
			{
				if(troopInfo.mirrorLayer.contains(troopInfo.avatarShowObj))
					troopInfo.mirrorLayer.removeChild(troopInfo.avatarShowObj);
				troopInfo.avatarShowObj.clearAvataShowData();
				troopInfo.avatarShowObj = null;
			}
			
			if(troopInfo.heroShowObj)
			{
				if(troopInfo.mirrorLayer.contains(troopInfo.heroShowObj))
					troopInfo.mirrorLayer.removeChild(troopInfo.heroShowObj);
				troopInfo.heroShowObj.clearData(needRelease);
				troopInfo.heroShowObj = null;
			}
			
			if(troopInfo.troopPlayerId != null && troopInfo.troopPlayerId.length > 0)
			{
				AnimatorEngine.removeAllHandlersForPlayer(troopInfo.troopPlayerId);				//把此troop的所有帧监听器移除
				AnimatorEngine.removePlayer(troopInfo.troopPlayerId);
			}
		}
		
		/**
		 * 清理cell信息 
		 * @param cell
		 */
		public static function clearCellInfo(cell:Cell):void
		{
			if(cell)
			{
				cell.clearCellInfo();
			}
		}
		
	}
}