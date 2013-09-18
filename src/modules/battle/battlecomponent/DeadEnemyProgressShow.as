package modules.battle.battlecomponent
{
	import flash.display.Sprite;
	
	import defines.UserBattleCardInfo;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.DemoManager;
	
	public class DeadEnemyProgressShow extends Sprite
	{
		
		private static const maxDeadTroopNeed:int = 25;    //最大能量
		
		private static var _instance:DeadEnemyProgressShow;
		
		private var _curCount:int = 0;
		
		private var sizeLength:int = 200;
		private var sizeWidth:int = 25;
		
		public function DeadEnemyProgressShow()
		{
			super();
			this.y = 20;
			this.curCount = 0;
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public static function get instance():DeadEnemyProgressShow
		{
			if(_instance == null)
			{
				_instance = new DeadEnemyProgressShow();
			}
			return _instance;
		}
		
		public function handleSingleEnemyDead():void
		{
			curCount+=5;      //能量增加
			return;
			if(curCount >= maxDeadTroopNeed)
			{
				
				if(BattleInfoSnap.heroCalledCount < 3 && BattleDefine.callHeroPossibility == 0)
					BattleManager.cardManager.handleNewBattleCardGened(UserBattleCardInfo.makeSingleHeroCard());
				
	//			BattleManager.cardManager.handleNewBattleCardGened(UserBattleCardInfo.makeOneFakeCardInfo());    //能量满的时候不取得卡片
				
				var totalstartCount:int = 1;			//点数配置
				while(totalstartCount > 0)
				{
					var index:int = int(NextSupplyShow.allSupplyTypes.length * Math.random());
					var curSupplyType:int = NextSupplyShow.allSupplyTypes[index]; 
					var starsCount:int = NextSupplyShow.getStarCountNeed(curSupplyType);
					
					if(totalstartCount < starsCount)
						continue;
					
					totalstartCount -= starsCount;
					
					var supplyArmType:int = NextSupplyShow.gettargetArmTypeBySupplytype(curSupplyType);
					var supplyeArmResId:int = DemoManager.getSingleRandomId(curSupplyType);
					
					DemoManager.makeNextArmSupply(BattleDefine.firstAtk,supplyArmType,supplyeArmResId,curSupplyType,true);		//
				}

				
				curCount = 0;
			}
		}

		public function get curCount():int
		{
			return _curCount;
		}

		public function set curCount(value:int):void
		{
			_curCount = value;
			
			_curCount = Math.max(value,0);
			
			this.graphics.clear();
			this.graphics.lineStyle(5,0,1);
			
			this.graphics.beginFill(0,0.2);
			this.graphics.drawRect(0,0,sizeLength,sizeWidth);
			
			this.graphics.lineStyle(5,0,0);
			this.graphics.beginFill(0xff0000,1);
			this.graphics.drawRect(0,0,sizeLength * curCount / maxDeadTroopNeed,sizeWidth);
			this.graphics.endFill();
		}

	}
}