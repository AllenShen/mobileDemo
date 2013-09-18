package modules.battle.stage
{
	import caurina.transitions.Tweener;
	
	import effects.BattleEffectObjBase;
	import effects.BattleEffectObjSWF;
	import effects.BattleResourcePool;
	
	import eventengine.GameEventHandler;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import macro.BattleDisplayDefine;
	import macro.EventMacro;
	
	import modules.battle.battlecomponent.SingleTroopGuanghuanBuff;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battleevents.DamageArrivedEvent;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.funcclass.SkillEffectFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.BattleUnitPool;
	
	import utils.BattleEffectConfig;
	import utils.Utility;

	/**
	 * 战斗特效层 
	 * @author Administrator
	 */
	public class BattleEffectLayer extends Sprite
	{
		public function BattleEffectLayer()
		{
		}
		
		/**
		 * 将弓箭加入到战斗场景中去
		 */
		public function addArrowToStage(troop:CellTroopInfo,targetTroopIndex:int):void
		{
			var targetTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(targetTroopIndex);
			if(troop == null || targetTroop == null)
				return;
			
			var effectId:int = TroopFunc.getMissileEffect(troop);
			var tempArrInstance:BattleEffectObjBase = BattleResourcePool.getFreeResourceUnit(effectId); 
			if(tempArrInstance)
			{
				tempArrInstance.rotation = 0;
				
				var effectSourcePos:Point = SkillEffectFunc.getEffectPos(troop,true,effectId,troop.ownerSide == BattleDefine.firstAtk,troop);
				var targetPos:Point = SkillEffectFunc.getEffectPos(targetTroop,false,effectId,troop.ownerSide == BattleDefine.firstAtk,troop);
				
				if(troop.ownerSide == BattleDefine.firstAtk)
				{
					tempArrInstance.scaleX = -1;
				}
				
				tempArrInstance.x = effectSourcePos.x;
				tempArrInstance.y = effectSourcePos.y;
				
				var sourceLogicPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(troop.occupiedCellStart);
				var targetLogicPos:Point = BattleTargetSearcher.getRowColumnByCellIndex(targetTroop.occupiedCellStart);
				
				var angle:Number = Math.atan((targetPos.y - tempArrInstance.y) / Math.abs((targetPos.x - tempArrInstance.x)) );
				
				var targetAngle:Number;
				if(troop.ownerSide == BattleDefine.secondAtk)
					targetAngle = 0 - (angle)*180;
				else
					targetAngle = angle*180;
				
				targetAngle = Math.max(-45,targetAngle);
				targetAngle = Math.min(45,targetAngle);
				
				if(troop.ownerSide == BattleDefine.secondAtk)
				{
					angle = (0 - targetAngle) / 180;
				}
				else
				{
					angle = targetAngle / 180;
				}
				
				tempArrInstance.rotation = targetAngle/Math.PI;
				
				var effectOffset:Point = BattleEffectConfig.getEffectCenter(effectId);			//此效果的偏移
				var realAngle:Number = (angle);													//旋转的角度
				var originalRatation:Number = Math.atan(effectOffset.y/effectOffset.x);			//偏移的角度
				var RLength:Number = Point.distance(new Point(0,0),effectOffset);				//原点到偏移点的距离 
				
				var xValue:Number = Math.cos(originalRatation + realAngle) * RLength;
				var yValue:Number = Math.sin(originalRatation + realAngle) * RLength;
				if(isNaN(xValue))
					xValue = 0;
				if(isNaN(yValue))
					yValue = 0;
				var moveGap:Point = new Point(effectOffset.x - xValue,effectOffset.y - yValue);
				tempArrInstance.x -= moveGap.x;
				tempArrInstance.y -= moveGap.y;
				
				this.addChild(tempArrInstance);
			}
			
			if(tempArrInstance != null)
			{
				var duration:Number = getArrowFlyTime(new Point(tempArrInstance.x,tempArrInstance.y),targetPos);
				Tweener.addTween(tempArrInstance,{x:targetPos.x,y:targetPos.y,time:Utility.getFrameByTime(duration),useFrames:true,transition:"linear",
					onComplete:singleArrowFlyEnd,onCompleteParams:[tempArrInstance,troop.troopIndex,targetTroopIndex]});
			}
			else
			{
				singleArrowFlyEnd(null,troop.troopIndex,targetTroopIndex);
			}
		}
		
		/**
		 * 获得箭飞行的时间 
		 * @param sourcePos				发出的source
		 * @param targetPos				目标source
		 * @return 
		 */
		private function getArrowFlyTime(sourcePos:Point,targetPos:Point):Number
		{
			var retValue:Number = 0;
			if(sourcePos == null || targetPos == null)
				return retValue;
			
			var distance:Number = Point.distance(sourcePos,targetPos);
			
			retValue = BattleDisplayDefine.moveTimeUnit * distance/BattleDisplayDefine.flyDisPerUnit;
			
			retValue = Math.min(retValue,BattleDisplayDefine.arrowFlyMaxDuration);
			retValue = Math.max(retValue,BattleDisplayDefine.arrowFlyMinDuration);
			
			return retValue;
		}
		
		/**
		 * 单个箭头，飞到目的地 
		 * @param arrow							箭
		 * @param sourceTroop					发出的troop
		 * @param targetTroop					目标troop
		 */
		private function singleArrowFlyEnd(arrow:BattleEffectObjSWF,sourceTroop:int,targetTroop:int):void
		{
			if(arrow != null)
			{
				if(this.contains(arrow))
					this.removeChild(arrow);
				arrow.isBusy = false;
			}
			
			if(BattleManager.instance.status == OtherStatusDefine.battleOn)
			{
				if(BattleManager.needTraceBattleInfo)
				{
					trace("弓箭fly完成，当前帧数: ",BattleInfoSnap.curBattleFrame,"攻击方:",sourceTroop,"被攻击方:",targetTroop);
				}
				GameEventHandler.dispatchGameEvent(EventMacro.DAMAGE_WAIT_HANDELR,new DamageArrivedEvent(sourceTroop,targetTroop));
			}
		}
		
		/**
		 * 获得被攻击特效播放的位置 
		 * @param troop
		 * @return 
		 */
		public function getAttackedEffectPos(atkTroop:CellTroopInfo,defTroop:CellTroopInfo,curPos:Point):Point
		{
			var retValue:Point = new Point(curPos.x,curPos.y);
			if(atkTroop == null || defTroop == null)
				return retValue;
			
			if(defTroop.cellsCountNeed.y == 1)		//如果是1/1的情形
			{
				return retValue;
			}
			
			var cellStart:int = atkTroop.occupiedCellStart; 
			
			if(BattleInfoSnap.aoyiTroopTargetCellInfo.hasOwnProperty(atkTroop.troopIndex))
				cellStart = BattleInfoSnap.aoyiTroopTargetCellInfo[atkTroop.troopIndex];
			
			//获得cell正对目标在deftroop其实位置上y值的偏移
			var getAtkIndex:int = BattleTargetSearcher.getCellYIndex(BattleUnitPool.getCellInfo(cellStart),defTroop);

			retValue.y += getAtkIndex * (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal);
			
			return retValue;
		}
		
		public function addGuangHuanBuff(troop:CellTroopInfo,troopBuff:SingleTroopGuanghuanBuff):void
		{
			this.addChild(troopBuff);
//			if(troop.ownerSide == BattleDefine.firstAtk)
//				troopBuff.x = troop.x + 30;
//			else
//				troopBuff.x = troop.x + 30;
			troop.componentsLayer.addChild(troopBuff);
			troopBuff.x = 30;
//			troopBuff.y = troop.y - troopBuff.realHeight;
			troopBuff.y = 0 - troopBuff.realHeight;
			troopBuff.startCountBack();
		}
		
		public function clearInfo():void
		{
			
		}
	}
}