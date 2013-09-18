package modules.battle.managers
{
	import avatarsys.util.WeaponGenedEffectConfig;
	
	import effects.BattleEffectObjSWF;
	import effects.BattleResourcePool;
	
	import eventengine.GameEventHandler;
	
	import flash.events.Event;
	
	import macro.EventMacro;
	
	import modules.battle.battledefine.EffectsAddedToTroopDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.funcclass.TroopEffectDisplayFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.stage.BattleStage;
	import modules.battle.utils.BattleEventTagFactory;
	
	import utils.TroopActConfig;

	/**
	 * 奥义管理类 
	 * @author SDD
	 */
	public class AoYiManager
	{
		private var _waitTroops:Array;
		private var _curWaitHero:CellTroopInfo;
		
		private static var aoyiBackEffect:BattleEffectObjSWF;
		private static var aoyiPortraitContainer:BattleEffectObjSWF;
		
		private var _hangOutToDieTroops:Array=[];
		
		public function AoYiManager()
		{
			waitTroops =[];
		}

		/**
		 * 是否播放奥义 
		 * @param troopInfo
		 * @return 
		 */
		public function isHeroGonnaPlayAoYi(troopInfo:CellTroopInfo):Boolean
		{
			if(troopInfo == null || troopInfo == null || !troopInfo.isHero)
				return false;
			if(_curWaitHero == null)
				return false;
			if(troopInfo.attackUnit.contentHeroInfo.heroid == _curWaitHero.attackUnit.contentHeroInfo.heroid && troopInfo.troopIndex == _curWaitHero.troopIndex)
				return true;
			return false;
		}
		
		/**
		 *  当前troop是否play奥义
		 * 	@param	troopInfo
		 */
		public function isCurHeroPlayAoyi(troopInfo:CellTroopInfo):Boolean
		{
			if(troopInfo == null || troopInfo == null || !troopInfo.isHero)
				return false;
			if(_curWaitHero == null)
			{
				for each(var singleTroop:CellTroopInfo in waitTroops)
				{
					if(singleTroop.troopIndex == troopInfo.troopIndex)
					{
						curWaitHero = singleTroop;
						if(curWaitHero.troopIndex == troopInfo.troopIndex)
							return true;
						else
							return false;
					}
				}
				return false;
			}
			else
			{
				if(_curWaitHero.troopIndex == troopInfo.troopIndex)
					return true;
				return false;
			}
		}
		
		/**
		 * 增加播放奥义的troop 
		 * @param troopInfo
		 */
		public function addAoYiTroop(troopInfo:CellTroopInfo):void
		{
			if(troopInfo == null || troopInfo == null || !troopInfo.isHero)
				return;
			for each(var singleTroop:CellTroopInfo in waitTroops)
			{
				if(singleTroop && singleTroop.troopIndex == troopInfo.troopIndex)
				{
					return;
				}
			}
			waitTroops.push(troopInfo);
			TroopEffectDisplayFunc.showAoYoBottomEffect(troopInfo,EffectsAddedToTroopDefine.aoyiWaitEffect,true);
		}
		
		/**
		 * 增加单个需要挂起死亡的troop 
		 * @param troopInfo
		 */
		public function addSingleTroopToDie(troopInfo:CellTroopInfo):void
		{
			if(troopInfo == null)
				return;
			if(_hangOutToDieTroops.indexOf(troopInfo.troopIndex) < 0)
				_hangOutToDieTroops.push(troopInfo.troopIndex);
		}
		
		/**
		 * 删除某个已经变成dead的troop
		 * @param troopIndex
		 */
		public function deleteSingleHangToDieTroop(troopIndex:int):void
		{
			var curIndex:int = _hangOutToDieTroops.indexOf(troopIndex);
			if(curIndex >= 0)
			{
				_hangOutToDieTroops.splice(curIndex,1);
			}
		}
		
		/**
		 * 显示aoyi效果 
		 * @param troop
		 */
		public function showAoYiEffect(troop:CellTroopInfo):void
		{
			if(troop == null || !troop.isHero)
				return;
			var targetEffect:int = 0;
			if(aoyiBackEffect == null)
			{
				if(!troop.isPlayerHero)
					targetEffect = TroopActConfig.getAoyibackeffect(troop.mcIndex);
				else
					targetEffect = WeaponGenedEffectConfig.getAoyibackeffect(troop.avatarShowObj.avatarConfig);
					
				aoyiBackEffect = BattleResourcePool.getFreeResourceUnit(targetEffect) as BattleEffectObjSWF;
			}
			if(aoyiBackEffect)
				BattleStage.instance.aoYiEffectLayer.addChild(aoyiBackEffect);
//			if(aoyiPortraitContainer == null)
//			{
//				if(!troop.isPlayerHero)
//					targetEffect = TroopActConfig.getAoyiportraitcontainer(troop.mcIndex);
//				else
//					targetEffect = WeaponGenedEffectConfig.getAoyiportraitcontainer(troop.avatarShowObj.avatarConfig);
//					
//				aoyiPortraitContainer = BattleResourcePool.getFreeResourceUnit(targetEffect) as BattleEffectObjSWF;
//			}
//			if(aoyiPortraitContainer == null)
//				return;
//			aoyiPortraitContainer.playOnce = true;
//			BattleStage.instance.aoYiEffectLayer.addChild(aoyiPortraitContainer);
			
//			var heroPortraitId:int = 0;
//			if(!troop.isPlayerHero)
//				heroPortraitId = TroopActConfig.getAoYiEffectPortrait(troop.mcIndex);
//			else
//				heroPortraitId = WeaponGenedEffectConfig.getAoYiEffectPortrait(troop.avatarShowObj.avatarConfig);
//			
//			var portrait:Bitmap = ResourcePool.getBitmapById(heroPortraitId);
//			var container:DisplayObjectContainer = aoyiPortraitContainer.movieClip.getChildByName("portraitframe") as DisplayObjectContainer;
//			if(container)
//			{
//				while(container.numChildren > 0)
//				{
//					container.removeChildAt(0);
//				}
//			}
//			if(container && portrait)
//			{
//				container.addChild(portrait);
//				portrait.x = 0;
//			}
			troop.addSinglePureHandler(0);
			TroopEffectDisplayFunc.showAoYoBottomEffect(troop,EffectsAddedToTroopDefine.aoyiWaitEffect,false);
			TroopEffectDisplayFunc.showAoYoBottomEffect(troop,EffectsAddedToTroopDefine.aoyiJiaodiEffect,true,true);
		}
		
		/**
		 *  隐藏奥义的背景特效
		 */
		public static function hideAoyiBackEffect():void
		{
			if(aoyiBackEffect != null)
			{
				aoyiBackEffect.isBusy = false;
				if(BattleStage.instance.aoYiEffectLayer.contains(aoyiBackEffect))
					BattleStage.instance.aoYiEffectLayer.removeChild(aoyiBackEffect);
			}
			
		}
		
		/**
		 * 处理英雄死亡 
		 * @param event
		 */
		private function handleHeroDead(event:Event):void
		{
			curWaitHero = null;
		}

		public function get curWaitHero():CellTroopInfo
		{
			return _curWaitHero;
		}

		public function set curWaitHero(value:CellTroopInfo):void
		{
			if(value == null)
			{
				var singleHandDeadTroop:CellTroopInfo;
				for(var index:int = 0;index < _hangOutToDieTroops.length;index++)
				{
					singleHandDeadTroop = BattleUnitPool.getTroopInfo(_hangOutToDieTroops[index]);
					if(singleHandDeadTroop)
					{
						singleHandDeadTroop.logicStatus = LogicSatusDefine.lg_status_dead;
						TroopFunc.makeTroopDieReally(singleHandDeadTroop);
					}
				}
			}
			
			var oldValue:CellTroopInfo = _curWaitHero;
			if(value && value.isHero && value.logicStatus != LogicSatusDefine.lg_status_dead)
				_curWaitHero = value;
			else
				_curWaitHero = null;
			if(_curWaitHero)
			{
				GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,
					BattleEventTagFactory.geneTroopDeadTag(_curWaitHero.troopIndex),handleHeroDead);
			}
			else
			{
				if(oldValue)
				{
					GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,
						BattleEventTagFactory.geneTroopDeadTag(oldValue.troopIndex),handleHeroDead);
					var singleTroop:CellTroopInfo;
					for(var i:int = 0; i < waitTroops.length;i++)				//将此troop移除
					{
						singleTroop = waitTroops[i] as CellTroopInfo;
						if(singleTroop && singleTroop.troopIndex == oldValue.troopIndex)
						{
							waitTroops.splice(i,1);
							break;
						}
					}
				}
			}
		}
		
		public function clearInfo():void
		{
			curWaitHero = null;
			var singleTroop:CellTroopInfo;
			for(var i:int = 0; i < waitTroops.length;i++)				//将此troop清空
			{
				singleTroop = waitTroops[i] as CellTroopInfo;
				if(singleTroop)
				{
					GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,
						BattleEventTagFactory.geneTroopDeadTag(singleTroop.troopIndex),handleHeroDead);
				}
			}
			waitTroops =[];
			_hangOutToDieTroops =[];
			
			if(aoyiBackEffect != null)
			{
				aoyiBackEffect.isBusy = false;
				if(aoyiBackEffect.parent)
					aoyiBackEffect.parent.removeChild(aoyiBackEffect);
			}
			aoyiBackEffect = null;
			if(aoyiPortraitContainer != null)
			{
				aoyiPortraitContainer.isBusy = false;
				if(aoyiPortraitContainer.parent)
					aoyiPortraitContainer.parent.removeChild(aoyiPortraitContainer);
			}
			aoyiPortraitContainer = null;
			BattleStage.instance.showAoYiLayer(false);
		}

		public function get waitTroops():Array
		{
			return _waitTroops;
		}

		public function set waitTroops(value:Array):void
		{
			_waitTroops = value;
		}

		public function get hangOutToDieTroops():Array
		{
			return _hangOutToDieTroops;
		}

		public function set hangOutToDieTroops(value:Array):void
		{
			_hangOutToDieTroops = value;
		}

		
	}
}