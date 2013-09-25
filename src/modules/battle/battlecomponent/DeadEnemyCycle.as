package modules.battle.battlecomponent
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import caurina.transitions.Tweener;
	
	import fl.controls.Button;
	
	import macro.AttackRangeDefine;
	import macro.BattleCardTypeDefine;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.funcclass.TroopEffectDisplayFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.*;
	
	public class DeadEnemyCycle extends Sprite
	{
		
		private var _curCount:int = 0;
		private var radius:int = 50;
		
		private var percentShow:Sprite;
		private var maskSprite:Sprite;
		
		private var supplyButton:Button;
		private var baojiButton:Button;

		private var isMoving:Boolean = false;
		
		private var maskMoveTime:int = 2000;
		
		private var supplyTimer:Timer;
		private var supplyTime:int = 2;			//步进次数
		private static const originalTotalStarCount:int = 3; 
		private var totalSupplyStarCount:int = originalTotalStarCount;
		private var curTimerIndex:int = 1;
		
		private static var _instance:DeadEnemyCycle;
		
		//总的点数
		private const maxCount:int = 9; 
		
		public static function get instance():DeadEnemyCycle
		{
			if(_instance == null)
			{
				_instance = new DeadEnemyCycle();
			}
			return _instance;
		}
		
		public function DeadEnemyCycle()
		{
			this.mouseEnabled = false;
			
			this.graphics.clear();
			this.graphics.beginFill(0,0);
			this.graphics.lineStyle(2,0,1);
			this.graphics.drawCircle(radius,radius,radius);
			this.graphics.endFill();
			
			percentShow = new Sprite;
			percentShow.graphics.clear();
			percentShow.graphics.beginFill(0xff0000,1);
			percentShow.graphics.lineStyle(2,0,1);
			percentShow.graphics.drawCircle(radius,radius,radius);
			percentShow.graphics.endFill();
			this.addChild(percentShow);
			percentShow.mouseEnabled = false;
			
			maskSprite = new Sprite;
			maskSprite.graphics.clear();
			maskSprite.graphics.beginFill(0,0);
			maskSprite.graphics.drawRect(0,0,radius*2,radius*2);
			maskSprite.graphics.endFill();
			this.addChild(maskSprite);
			percentShow.mask = maskSprite;
			maskSprite.mouseEnabled = false;
			
			supplyButton = new Button();
			supplyButton.label = "补兵";
			this.addChild(supplyButton);
			supplyButton.y = -20;
			supplyButton.width = 45;
			supplyButton.addEventListener(MouseEvent.CLICK,onSupplyClicked);
			
			baojiButton = new Button();
			baojiButton.label = "暴击";
			this.addChild(baojiButton);
			baojiButton.width = 45;
			baojiButton.y = -20;
			baojiButton.x = 50;
			baojiButton.addEventListener(MouseEvent.CLICK,onBaojiClicked);
			
			supplyButton.enabled = false;
			baojiButton.enabled = false;
			
			super();
		}
		
		//敌人死亡
		public function handleSingleEnemyDead():void
		{
			if(!this.visible)
				return;
			if(isMoving)
				return;
			curCount += 1;
		}
		
		//我方自己的兵被点掉
		public function handleSelfArmCycled():void
		{
			if(!this.visible)
				return;
			if(isMoving)
				return;
			curCount += 1;
		}
		
		private function initTimer(init:Boolean):void{
			totalSupplyStarCount = originalTotalStarCount;
			if(supplyTimer)
			{
				supplyTimer.removeEventListener(TimerEvent.TIMER,onTImerTrigger);
				supplyTimer.stop();
				supplyTimer = null;
			}
			if(init)
			{
				curTimerIndex = 1;
				supplyTimer = new Timer(maskMoveTime / supplyTime,supplyTime);
				supplyTimer.addEventListener(TimerEvent.TIMER,onTImerTrigger);
				supplyTimer.start();
			}
		}
		
		private function onTImerTrigger(event:TimerEvent):void
		{
			var starsCount:int = 0;
//			if(totalSupplyStarCount <= 0)
//				return;
//			var minStarCount:int = Math.min(totalSupplyStarCount,2);
			var targetCount:int = curTimerIndex++;
			while(starsCount != targetCount)
			{
				var index:int = int(NextSupplyShow.allSupplyTypes.length * Math.random());
				var tempSupplyType:int = NextSupplyShow.allSupplyTypes[index]; 
				starsCount = NextSupplyShow.getStarCountNeed(tempSupplyType);
			}
			
//			totalSupplyStarCount -= starsCount;
			
			var supplyArmType:int = NextSupplyShow.gettargetArmTypeBySupplytype(tempSupplyType);
			var supplyeArmResId:int = DemoManager.getSingleRandomId(tempSupplyType);
			
			DemoManager.makeNextArmSupply(BattleDefine.firstAtk,supplyArmType,supplyeArmResId,tempSupplyType,true);		
		}
		
		private function onSupplyClicked(event:MouseEvent):void
		{
			supplyButton.enabled = false;
			baojiButton.enabled = false;
			isMoving = true;
			initTimer(true);
			Tweener.removeTweens(this.maskSprite);
			Tweener.addTween(maskSprite,{y:2* radius,time:maskMoveTime/1000,transition:"linear",onComplete:onSupplyReleaseMoveEnd});
		}
		
		private function onSupplyReleaseMoveEnd():void
		{
			if(BattleManager.instance.status != OtherStatusDefine.battleOn)
				return;
			isMoving = false;
			this.curCount = 0;
			Tweener.removeTweens(this.maskSprite);
		}
		
		private function onBaojiClicked(event:MouseEvent):void
		{
			supplyButton.mouseEnabled = false;
			baojiButton.mouseEnabled = false;
			
			isMoving = true;
			Tweener.removeTweens(this.maskSprite);
			Tweener.addTween(maskSprite,{y:2* radius,time:maskMoveTime/1000,transition:"linear",onComplete:onBaojiMoveEnd});
			
			BattleInfoSnap.quanTiGongJiRound = 12;
			return;
			
			var targetArr:Array = BattleTargetSearcher.getTargetsForSomeRange(0,AttackRangeDefine.woFangQuanTi);
			var singleEffect:BattleSingleEffect;
			for(var i:int = 0; i < targetArr.length;i++)
			{
				var singleTarget:CellTroopInfo = targetArr[i] as CellTroopInfo;
				if(singleTarget == null || singleTarget.logicStatus == LogicSatusDefine.lg_status_dead || singleTarget.logicStatus == LogicSatusDefine.lg_status_hangToDie)
					continue;
				
				singleEffect = new BattleSingleEffect();
				singleEffect.effectId = SpecialEffectDefine.BaoJi;
				singleEffect.effectDuration = 3;
				singleEffect.effectValue = 1;
				singleEffect.effectTarget = AttackRangeDefine.woFangQuanTi;
				
				singleEffect.effectSourceTroop = singleTarget.troopIndex;
				TroopFunc.addSingleBuff(singleTarget,singleEffect,true);
				
				TroopEffectDisplayFunc.showBattleCardEffect(singleTarget,BattleCardTypeDefine.baojiChu);
			}
			
		}
		
		private function onBaojiMoveEnd():void
		{
			isMoving = false;
			this.curCount = 0;
		}
		
		public function get curCount():int
		{
			return _curCount;
		}

		public function set curCount(value:int):void
		{
			_curCount = value;
			_curCount = Math.min(_curCount,maxCount);
			this.maskSprite.y = 2 * radius - (_curCount / maxCount) * 2 * radius;
			
			if(_curCount < maxCount)
			{
				supplyButton.enabled = false;
				baojiButton.enabled = false;
			}
			else
			{
				supplyButton.enabled = true;
				baojiButton.enabled = true;
			}
		}
		
		public function clearInfo():void
		{
			this.isMoving = false;
			this.curCount = 0;
			Tweener.removeTweens(this.maskSprite);
			supplyButton.enabled = false;
			baojiButton.enabled = false;	
			initTimer(false);
		}
		
		
	}
}