package modules.battle.battlecomponent
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import macro.BattleDisplayDefine;
	
	import modules.battle.battleconfig.BattleEffectIdConfig;
	import modules.battle.battledefine.EffectShowTypeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.managers.BattleManager;
	
	import utils.BattleEffectConfig;

	public class HeroPortraitGroup extends Sprite
	{
		
		private var _targetPowerside:PowerSide;					//目标powerside
		
		private var portraitsArr:Array;
		
		public function HeroPortraitGroup()
		{
			portraitsArr =[];
		}
		
		private function initPortraitInfo():void
		{
			if(_targetPowerside)
			{
				var singleHeroTroop:CellTroopInfo;
				var allHeros:Array = BattleFunc.getAllHeroInfo(_targetPowerside);
				var allHeroAfterFilter:Array=[];
				var i:int;
				for(i = 0; i < allHeros.length; i++)
				{
					singleHeroTroop = allHeros[i] as CellTroopInfo;
					if(singleHeroTroop && singleHeroTroop.attackUnit && singleHeroTroop.attackUnit.contentHeroInfo && singleHeroTroop.attackUnit.contentHeroInfo.heroportrait > 0)			//只要填写数据就ok
					{
						allHeroAfterFilter.push(singleHeroTroop);
					}
				}
				
				var portraitRealSize:Point = BattleEffectConfig.getEffectSize(BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_JingYanTiao));
				var portraitLength:int = portraitRealSize.x;
				var jingyanGap:Number = (BattleDisplayDefine.singlePortraitWidth * (allHeroAfterFilter.length - 1) + portraitLength)/allHeroAfterFilter.length;
				var jingYanPos:Number;
				for(i = 0; i < allHeroAfterFilter.length; i++)
				{
					singleHeroTroop = allHeroAfterFilter[i] as CellTroopInfo;
					if(singleHeroTroop == null)
						continue;
					var singlePortrait:HeroPortrait = new HeroPortrait(singleHeroTroop);
					singlePortrait.frameType = i % 2;
					if(_targetPowerside.isFirstAtk)
					{
						singlePortrait.x = BattleDisplayDefine.singlePortraitWidth * i;
						jingYanPos = jingyanGap * i - singlePortrait.x - portraitLength / 2;
						if(i != 0)
							jingYanPos = jingyanGap - BattleDisplayDefine.singlePortraitWidth - portraitLength / 2 - 2;
						else
							jingYanPos = jingyanGap * i - singlePortrait.x - portraitLength / 2;
					}
					else
					{
						singlePortrait.x = 0 - BattleDisplayDefine.singlePortraitWidth * (i + 1);
						jingYanPos = 0 - jingyanGap * i - singlePortrait.x;
						if(i != 0)
							jingYanPos = 0 - jingyanGap - singlePortrait.x - 2;
						else
							jingYanPos = 0 - jingyanGap * i - singlePortrait.x;
					}
					singlePortrait.addPortraitToFrame();
					singlePortrait.setJingYanPos(jingYanPos);
					
					this.addChildAt(singlePortrait,0);
					portraitsArr.push(singlePortrait);
					singlePortrait.setJingYanTiaoValue();
				}
			}
		}

		/**
		 *  设置头像信息
		 */
		public function setPortraitStatus():void
		{
			if(portraitsArr == null)
				return;
			for each(var singlePortrait:HeroPortrait in portraitsArr)
			{
				if(singlePortrait == null || singlePortrait.dataSource == null || 
					singlePortrait.dataSource.logicStatus == LogicSatusDefine.lg_status_dead)
					continue;
				singlePortrait.setJingYanTiaoValue();
			}
		}
		
		/**
		 * 清空信息
		 */
		public function clearInfo():void
		{
			while(portraitsArr.length > 0)
			{
				var singlePortrait:HeroPortrait = portraitsArr.pop() as HeroPortrait;
				if(singlePortrait)
				{
					if(this.contains(singlePortrait))
						this.removeChild(singlePortrait);
					singlePortrait.clearInfo();
					singlePortrait = null;
				}
			}
		}
		
		public function get targetPowerside():PowerSide
		{
			return _targetPowerside;
		}

		public function set targetPowerside(value:PowerSide):void
		{
			_targetPowerside = value;
			initPortraitInfo();
		}

	}
}