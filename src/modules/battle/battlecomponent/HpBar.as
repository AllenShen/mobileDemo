package modules.battle.battlecomponent
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import caurina.transitions.Tweener;
	
	import eventengine.GameEventHandler;
	
	import macro.BattleDisplayDefine;
	import macro.Color;
	import macro.EventMacro;
	
	import modules.battle.battledefine.BattleCompDefine;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.utils.BattleEventTagFactory;

	/**
	 * 显示troop的血量 
	 * @author SDD
	 */
	public class HpBar extends TroopComponentBase
	{
		private var contentFrame:Sprite;				//血条的边框
		private var contentBar:Sprite;					//血条内容
		private var countBackCircle:Sprite;				//显示个数的背景
		
		private var increaseSpriteLayer:Sprite;			//血条增长时候的layer
		private var decreaseSpriteLayer:Sprite;			//血条减少时候的layer
		private var decreaseSpriteMaskLayer:Sprite;		//血条减少时候的mask
		
		private var _totalHpValue:int = 0;
		private var _curHpValue:int = 0;
		
		private var _selfMask:Shape;
		
		private var _fadeCountTimer:Timer;
		private var _fadeWaitTime:int = 4000;
		private var _mouseOutTime:int = 300;
		
		private var _frameWidth:int = BattleCompDefine.contentBarWidth;
		
		public function HpBar(cellInfo:CellTroopInfo)
		{
			super(cellInfo);
			
			if(cellInfo == null)
				return;
			
			frameWidth = (cellInfo.cellsCountNeed.x - 1) * BattleDisplayDefine.cellWidth + BattleCompDefine.contentBarWidth;
			
			contentFrame = new Sprite;
			contentFrame.graphics.clear();
			contentFrame.graphics.lineStyle(1,Color.blackColor,1);
			contentFrame.graphics.beginFill(Color.blackColor,0.2);
			contentFrame.graphics.drawRoundRect(0,0,frameWidth,BattleCompDefine.contentBarHeight,1,1);
			contentFrame.graphics.endFill();
			contentFrame.x = 0;
			contentFrame.y = 0;
			this.addChild(contentFrame);
			
			increaseSpriteLayer = new Sprite;
			increaseSpriteLayer.graphics.clear();
			increaseSpriteLayer.y = 1;
			contentFrame.addChild(increaseSpriteLayer);
			
			decreaseSpriteLayer = new Sprite;
			decreaseSpriteLayer.graphics.clear();
			decreaseSpriteLayer.y = 1;
			decreaseSpriteLayer.graphics.beginFill(BattleDisplayDefine.bpBarDecreaseColor);
			decreaseSpriteLayer.graphics.drawRect(0,0,frameWidth - 1,BattleCompDefine.contentBarHeight - 1);
			decreaseSpriteLayer.graphics.endFill();
			contentFrame.addChild(decreaseSpriteLayer);
			decreaseSpriteLayer.visible = false;
			
			contentBar = new Sprite;
			contentBar.graphics.clear();
			contentBar.y = 1;
			contentBar.graphics.beginFill(BattleDisplayDefine.hpBarContentColor);
			contentBar.graphics.drawRect(0,0,frameWidth - 1,BattleCompDefine.contentBarHeight - 1);
			contentBar.graphics.endFill();
			contentFrame.addChild(contentBar);
			
			decreaseSpriteMaskLayer = new Sprite;
			decreaseSpriteMaskLayer.graphics.clear();
			decreaseSpriteMaskLayer.graphics.beginFill(0,0);
			decreaseSpriteMaskLayer.graphics.drawRect(0,0,frameWidth - 1,BattleCompDefine.contentBarHeight - 1);
			decreaseSpriteMaskLayer.x = 1;
			decreaseSpriteMaskLayer.y = 1;
			contentFrame.addChild(decreaseSpriteMaskLayer);
			decreaseSpriteLayer.mask = decreaseSpriteMaskLayer;
			
			this.dataSource = cellInfo;
			
			_selfMask = new Shape();
			_selfMask.graphics.clear();
			_selfMask.graphics.beginFill(Color.redColor,0);
			_selfMask.x = 1;
			_selfMask.y = 1;
			_selfMask.graphics.drawRoundRect(0,0,frameWidth,BattleCompDefine.contentBarHeight - 1,1,1);
			_selfMask.graphics.endFill();
			contentFrame.addChild(_selfMask);
			contentBar.mask = _selfMask;
			
			this.visible = false;
		}
		
		/**
		 * 初始化 
		 */
		public function initStatus():void
		{
			if(dataSource)
			{
				_totalHpValue = dataSource.totalHpOfSlot;
				_curHpValue = dataSource.totalHpValue;
				
				_totalHpValue = Math.max(_totalHpValue,_curHpValue);
				
				contentBar.x = 1;
				decreaseSpriteLayer.x = 1;
				decreaseSpriteLayer.visible = false;
				
				var targetX:Number = 0 - frameWidth * (1 - (_curHpValue / _totalHpValue)) + 1;
				contentBar.x = targetX;
				increaseSpriteLayer.x = targetX;
				decreaseSpriteLayer.x = targetX;
			}
			else
			{
				_totalHpValue = 0;
				_curHpValue = 0;
				contentBar.x = 1;
				decreaseSpriteLayer.x = 1;
				decreaseSpriteLayer.visible = false;
			}
			setHpVisible(true);
		}
		
		/**
		 * 初始化timer 
		 */
		private function initTimer(needInit:Boolean = true):void
		{
			return;
			if(_fadeCountTimer)
			{
				_fadeCountTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,timerComplete);
				_fadeCountTimer.stop();
				_fadeCountTimer = null;
			}
			if(needInit)
			{
				_fadeCountTimer = new Timer(_fadeWaitTime,1);
				_fadeCountTimer.addEventListener(TimerEvent.TIMER_COMPLETE,timerComplete);
				_fadeCountTimer.start();
			}
		}
		
		public function initMouseMoveOutTimer(init:Boolean = true):void
		{
			return;
			if(_fadeCountTimer)
			{
				_fadeCountTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,timerComplete);
				_fadeCountTimer.stop();
				_fadeCountTimer = null;
			}
			if(init)
			{
				_fadeCountTimer = new Timer(_mouseOutTime,1);
				_fadeCountTimer.addEventListener(TimerEvent.TIMER_COMPLETE,timerComplete);
				_fadeCountTimer.start();	
			}
		}
		
		/**
		 * 显示时间到 
		 * @param event
		 */
		private function timerComplete(event:TimerEvent):void
		{
			setHpVisible(false);
		}
		
		/**
		 * hp发生变化
		 * @param hpValue			变化值
		 * @param decrease			是否减少
		 */
		public function hpChange(hpValue:int):void
		{
			setHpVisible(true);
			if(hpValue == 0)
			{
				return;
			}
			
			_totalHpValue = dataSource.totalHpOfSlot;
			
			_curHpValue -= hpValue;
			_curHpValue = Math.max(_curHpValue,0);
			_curHpValue = Math.min(_curHpValue,_totalHpValue);
			if(hpValue > 0)
			{
				makeMove(hpValue,true);
			}
			else
			{
				makeMove(hpValue,false);
			}
		}
		
		/**
		 * 进行变化 
		 * @param  curChangeValue			变化的血量
		 * @param  decrease					是否是减血
		 */
		private function makeMove(curChangeValue:int,decrease:Boolean = true):void
		{
			var targetX:Number;
			var duration:Number = 0.2;
			if(decrease)
			{
				decreaseSpriteLayer.visible = true;
			}
			else
			{
				decreaseSpriteLayer.visible = false;
			}
			targetX = 0 - frameWidth * (1 - (_curHpValue / _totalHpValue)) + 1;
			
			increaseSpriteLayer.graphics.clear();
			Tweener.removeTweens(contentBar);
			Tweener.removeTweens(decreaseSpriteLayer);
			if(decrease)		//如果是减少血量
			{
				contentBar.x = targetX;
				duration = getBarMoveDuration(targetX - decreaseSpriteLayer.x);
				Tweener.addTween(decreaseSpriteLayer,{x:targetX,time:duration,transition:"linear",onComplete:singleMoveEnd});
			}
			else				//增加血量
			{
				increaseSpriteLayer.x = contentBar.x + contentBar.width;
				increaseSpriteLayer.graphics.beginFill(BattleDisplayDefine.bpBarAddColor);
				increaseSpriteLayer.graphics.drawRect(0,0,Math.abs(targetX - contentBar.x),BattleCompDefine.contentBarHeight - 1);
				increaseSpriteLayer.graphics.endFill();
				decreaseSpriteLayer.x = targetX;
				
				duration = getBarMoveDuration(targetX - contentBar.x);
				Tweener.addTween(contentBar,{x:targetX,time:duration,onComplete:singleMoveEnd});
			}
		}
		
		/**
		 * 获得移动需要的事件 
		 * @param		dis			移动距离
		 * @return 					时间
		 */
		private function getBarMoveDuration(dis:Number):Number
		{
			var retValue:Number = 0.2;
			dis = Math.abs(dis);
			retValue = (dis / BattleDisplayDefine.hpBarMoveSpeed) * 0.1;
			retValue = Math.max(0.3,retValue);
			retValue = Math.min(1,retValue);
			return retValue;
		}
		
		/**
		 * 变化完成，清空遮罩等 
		 */
		private function singleMoveEnd():void
		{
			increaseSpriteLayer.graphics.clear();
			decreaseSpriteLayer.visible = false;
		}
		
		/**
		 * 隐藏完成 
		 */
		private function hideComplete():void
		{
			this.visible = false;
		}
		
		/**
		 * 设置hp是否显示
		 * @param visible
		 */
		public function setHpVisible(visible:Boolean):void
		{
			if(visible)
			{
				this.alpha = 1;
				initTimer(true);
				this.visible = true;
				Tweener.removeTweens(this);
			}
			else
			{
				Tweener.addTween(this,{alpha:0,time:0.2,transition:"linear",onComplete:hideComplete});
				GameEventHandler.removeListener(EventMacro.NORMAL_BATTLE_EVENT,BattleEventTagFactory.getHpShowEventTag(dataSource),hpHideHandler);
			}
			if(!BattleDefine.needShowHpBar)
				this.visible = false;
//			this.visible = false;
		}
		
		/**
		 * 是否正在等待消去 
		 * @return 
		 */
		public function get isTimerRunning():Boolean
		{
			return _fadeCountTimer && _fadeCountTimer.running;
		}
		
		/**
		 * 隐藏 
		 * @param event
		 */
		private function hpHideHandler(event:Event):void
		{
			setHpVisible(false);
		}

		public function get frameWidth():int
		{
			return _frameWidth;
		}

		public function set frameWidth(value:int):void
		{
			_frameWidth = value;
		}

		override public function clearInfo():void
		{
			initMouseMoveOutTimer(false);
			Tweener.removeTweens(contentBar);
			Tweener.removeTweens(decreaseSpriteLayer);
			super.clearInfo();
		}
		
	}
}