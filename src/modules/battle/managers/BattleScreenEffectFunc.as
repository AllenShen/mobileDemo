package modules.battle.managers
{
	import caurina.transitions.Tweener;
	
	import effects.BattleEffectObjSWF;
	import effects.BattleResourcePool;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import modules.battle.battleconfig.BattleEffectIdConfig;
	import modules.battle.battledefine.EffectShowTypeDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.stage.BattleStage;
	
	import synchronousLoader.ResourceConfig;
	import synchronousLoader.ResourcePool;
	
	import utils.TroopActConfig;

	/**
	 * 显示battle各种全屏特效
	 * @author SDD
	 */
	public class BattleScreenEffectFunc
	{
		
		private static var curShakeIndex:int = 0;
		private static var singleShakeTime:Number = 0.04;
		private static var shakeTracks:Array = [9,-8,8,-8,0];
		
		private static var shakeFrameEffect:MovieClip;
		
		public function BattleScreenEffectFunc()
		{
		}
		
		/**
		 * 屏幕震动 
		 * @param type
		 */
		public static function showScreenShake(type:int = 0):void
		{
			curShakeIndex = 0;
			if(type == 0)
			{
				if(shakeFrameEffect == null)
				{
					shakeFrameEffect = ResourcePool.getReflectSwfById(BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_HongKuang));
					if(shakeFrameEffect)
					{
						BattleStage.instance.effectLayer.addChild(shakeFrameEffect);
						shakeFrameEffect.addEventListener(Event.ENTER_FRAME,frameEnterHandler);
					}
				}
				if(shakeFrameEffect)
				{
					shakeFrameEffect.visible = true;
					shakeFrameEffect.gotoAndPlay(1);
				}
			}
			Tweener.addTween(BattleStage.instance.shakeLayer,{y:shakeTracks[curShakeIndex++],time:singleShakeTime,onComplete:singleShakeOver});
			return;
		}
		
		private static function frameEnterHandler(event:Event):void
		{
			if(shakeFrameEffect)
			{
				if(shakeFrameEffect.currentFrame == shakeFrameEffect.totalFrames)
				{
					shakeFrameEffect.stop();
					shakeFrameEffect.visible = false;
				}
			}
		}
		
		/**
		 * 单次抖动结束 
		 * @param curCount
		 */
		private static function singleShakeOver():void
		{
			if(curShakeIndex < shakeTracks.length)
			{
				Tweener.addTween(BattleStage.instance.shakeLayer,{y:shakeTracks[curShakeIndex++],time:singleShakeTime,onComplete:singleShakeOver});
			}
		}
		
		/**
		 *  清空效果
		 */
		public static function clearEffects():void
		{
			Tweener.removeTweens(BattleStage.instance);
		}
		
	}
}