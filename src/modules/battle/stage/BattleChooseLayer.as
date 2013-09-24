package modules.battle.stage
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import eventengine.GameEventHandler;
	
	import macro.BattleDisplayDefine;
	import macro.EventMacro;
	import macro.GameSizeDefine;
	
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.battlelogic.SingleRound;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleTargetSearcher;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.managers.DemoManager;
	
	public class BattleChooseLayer extends Sprite
	{
		
		private var isChoosing:Boolean = false;
		private var _targetSide:int = -1;
		private var _searchType:int = 0;
		
		private var curCenterCellIndex:int;
		private var curShowBottomCells:Object = {};
		private var curShowSelectedCells:Array = [];
		
		private var curSlideTarget:Cell = null;
		private var isMouseDown:Boolean = false;
		private var mouseReleasePos:Point;
		private var mouseDownPos:Point;
		private var isSliding:Boolean = false;
		
		public function BattleChooseLayer()
		{
			super();
//			this.addEventListener(MouseEvent.MOUSE_MOVE,onSelectMouseMove);
			this.addEventListener(MouseEvent.CLICK,onSelectMoveDown);
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			this.graphics.clear();
			this.graphics.beginFill(0,0);
			this.graphics.drawRect(0,0,GameSizeDefine.maxWidth,GameSizeDefine.maxHeight);
			this.graphics.endFill();
		}

		public function init():void
		{
			GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,BattleConstString.refreshChoostTarget,onRefreshTargetStatus);
		}
		
		private function onRefreshTargetStatus(event:Event):void
		{
			if(!isChoosing)
				return;
			this.visible = true;
			searchType = searchType;
		}
		
		public function showChooseInfo(side:int,type:int):void
		{
			this.visible = true;
			isChoosing = true;
			targetSide = side;
			searchType = type;
		}
		
		private function onSelectMouseMove(event:MouseEvent):void
		{
			reCalRange();
		}
		
		/**
		 * 选中目标，开始进行逻辑
		 * @param event
		 */
		private function onSelectMoveDown(event:MouseEvent):void
		{
			if(SingleRound.roungIndex <= BattleDefine.fakeRoundsAtBeginning)
				return;
			if(isSliding)
				return;
			curCenterCellIndex = -1;
			reCalRange();
			var hasQualified:Boolean = false;
			for(var singleKey:String in curShowBottomCells)
			{
				hasQualified = true;
			}
			if(hasQualified)
			{
				if(curShowSelectedCells.length > 0)
				{
					var singleCell:Cell;
					var checkedTroop:Object = {};
					var troopTargets:Array = [];
					for(var i:int = 0;i < curShowSelectedCells.length;i++)
					{
						singleCell = curShowSelectedCells[i];
						if(singleCell && singleCell.troopInfo)
						{
							if(checkedTroop.hasOwnProperty(singleCell.troopInfo.troopIndex))
								continue;
							if(singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead || singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_hangToDie)
								continue;
							if(singleCell.troopInfo.logicStatus == LogicSatusDefine.lg_status_filling)
								continue;
							checkedTroop[singleCell.troopInfo.troopIndex] = 1;
							troopTargets.push(singleCell.troopInfo);
						}
					}
					
					DemoManager.handleTroopBeCycled(troopTargets);
					
					var singleCellInfo:Cell;
					while(curShowSelectedCells.length > 0)
					{
						singleCellInfo = curShowSelectedCells.shift();
						if(singleCellInfo)
						{
							singleCellInfo.showSelectStatus(BattleDefine.Status_NoShow);
						}
					}
					GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.refreshSelectingCardStatus));
				}
			}
			else
			{
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new Event(BattleConstString.refreshSelectingCardStatus));
				isChoosing = false;
				this.visible = false;
				clearCurSelectedStatus();
			}
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			isSliding = false;
			reCalRange();
			if(curShowSelectedCells.length <= 0)
				return;
			curSlideTarget = curShowSelectedCells[0] as Cell;
			if(curSlideTarget == null || curSlideTarget.troopInfo == null || curSlideTarget.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead)
				return;
			mouseDownPos = new Point(mouseX,mouseY);
			isMouseDown = true;
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			if(mouseDownPos == null)
				return;
			mouseReleasePos = new Point(mouseX,mouseY);
			var realCell:Cell = null;
			if(mouseReleasePos.x - mouseDownPos.x >= 30)
			{
				if(curSlideTarget == null || curSlideTarget.troopInfo == null || curSlideTarget.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead)
					return;
				isSliding = true;
				realCell = BattleUnitPool.getCellInfo(curSlideTarget.troopInfo.occupiedCellStart);
				BattleStage.instance.troopLayer.checkHeBingOnSameLine(realCell);
			}
			else if(mouseDownPos.x - mouseReleasePos.x >= 20)			//反响滑动
			{
				if(curSlideTarget == null || curSlideTarget.troopInfo == null || curSlideTarget.troopInfo.logicStatus == LogicSatusDefine.lg_status_dead)
					return;
				isSliding = true;
				realCell = BattleUnitPool.getCellInfo(curSlideTarget.troopInfo.occupiedCellStart);
				BattleStage.instance.troopLayer.checkFanXiangHeBingOnSameLine(realCell);
			}
		}
		
		/**
		 *  清除当前显示的所有信息
		 */
		private function clearCurSelectedStatus():void
		{
			var singleCellInfo:Cell;
			var tempCurShowCellIndexs:Array = [];
			for(var eachCIndex:String in curShowBottomCells)
			{
				tempCurShowCellIndexs.push(curShowBottomCells[eachCIndex]);
			}
			curShowBottomCells = {};
			while(tempCurShowCellIndexs.length > 0)
			{
				singleCellInfo = tempCurShowCellIndexs.shift();
				if(singleCellInfo)
				{
					singleCellInfo.showSelectStatus(BattleDefine.Status_NoShow);
				}
			}
			while(curShowSelectedCells.length > 0)
			{
				singleCellInfo = curShowSelectedCells.shift();
				if(singleCellInfo)
				{
					singleCellInfo.showSelectStatus(BattleDefine.Status_NoShow);
				}
			}
		}
		
		/**
		 * 重绘目标格子,进行选择
		 */
		private function reCalRange():void
		{
			if(!isChoosing)
				return;
			var curX:int = mouseX;
			var curY:int = mouseY;
			var statrtCellCount:int = 0;
			
			var mouseInSide:int = 0;
			
			var rowIndexMin:int = -1;
			var rowIndexMax:int = -1;
			
			var singleTroop:CellTroopInfo;
			var yMin:int = 640;
			var yMax:int = 0;
			var xMin:int = 960;
			var xMax:int = 0;
			
			var selfSide:int = 0;
			
			var allTroops:Array = BattleUnitPool.getTroopsOfSomeSide(targetSide);
			for(var i:int = 0;i < allTroops.length;i++)
			{
				singleTroop = allTroops[i];
				if(singleTroop == null || !singleTroop.visible || singleTroop.logicStatus == LogicSatusDefine.lg_status_dead || 
					singleTroop.logicStatus == LogicSatusDefine.lg_status_hangToDie)
					continue;
				if(searchType != BattleDefine.Range_SingleHero)
				{
					if(singleTroop.isHero)
						continue;
				}
				if(selfSide == targetSide && !TroopFunc.isPlayerSelfTroop(singleTroop))
				{
					continue;
				}
				var rowColumnIndex:Point = new Point(0,0);
				yMin = Math.min(singleTroop.y,yMin);
				yMax = Math.max(yMax,singleTroop.y + (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal) * (singleTroop.cellsCountNeed.y));
				rowColumnIndex = BattleTargetSearcher.getRowColumnByCellIndex(singleTroop.occupiedCellStart);
				if(rowIndexMin < 0)
					rowIndexMin = rowColumnIndex.x;
				if(rowIndexMax < 0)
					rowIndexMax = rowColumnIndex.x;
				var index:int = 0;
				var allCells:Array = BattleFunc.getCellsOccupied(singleTroop.troopIndex);
				var singleCell:Cell;
				
				if(targetSide == BattleDefine.firstAtk)
				{	
					xMin = Math.min(xMin,singleTroop.x - (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal) * (singleTroop.cellsCountNeed.x - 1));
					xMax = Math.max(xMax,singleTroop.x + BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal);
				}
				else
				{
					xMin = Math.min(xMin,singleTroop.x);
					xMax = Math.max(xMax,singleTroop.x + (BattleDisplayDefine.cellWidth + BattleDisplayDefine.cellGapHorizonal) * singleTroop.cellsCountNeed.x);
				}
				
				for(index == 0;index < allCells.length;index++)
				{
					singleCell = BattleUnitPool.getCellInfo(allCells[index]);
					if(singleCell == null)
						continue;
					rowColumnIndex = BattleTargetSearcher.getRowColumnByCellIndex(singleCell.index);
					rowIndexMin = Math.min(rowIndexMin,rowColumnIndex.x);
					rowIndexMax = Math.max(rowIndexMax,rowColumnIndex.x);
				}
			}
			
//			curX = Math.max(curX,xMin);
//			curX = Math.min(curX,xMax);
//			curY = Math.max(curY,yMin);
//			curY = Math.min(curY,yMax);
//			
//			curX = Math.max(curX,0);
//			curX = Math.min(curX,GameSizeDefine.maxWidth);
//			curY = Math.max(curY,0);
//			curY = Math.min(curY,GameSizeDefine.maxHeight);
			
			var firstSideX:int = BattleDisplayDefine.atkStartPos.x + BattleDisplayDefine.cellWidth;
			var targetPowerSide:PowerSide;
			if(targetSide == BattleDefine.firstAtk)
			{
				targetPowerSide = BattleManager.instance.pSideAtk;
			}
			else
			{
				targetPowerSide = BattleManager.instance.pSideDef;
			}
			
			if(curX <= firstSideX)
			{
				mouseInSide = BattleDefine.firstAtk;
				statrtCellCount = 0;
			}
			else if(curX >= BattleDisplayDefine.defStartPos.x)
			{
				mouseInSide = BattleDefine.secondAtk;
				statrtCellCount = BattleFunc.getPowerSideCellCount(true);
			}
			else
			{
				return;
			}
				
			if(mouseInSide != targetSide)			//不在目标区域内
				return;
			
			var guessCellIndex:int = 0;
			var cellIndexX:int = 0;
			if(curY == yMax)
				curY--;
			if(curX == xMax)
				curX--;
//			if(curX == xMin)
//				curX++;
			var cellIndexY:int = (curY - BattleDisplayDefine.atkStartPos.y) / (BattleDisplayDefine.cellHeight + BattleDisplayDefine.cellGapVertocal);
			if(mouseInSide == BattleDefine.firstAtk)
			{
				cellIndexX = (firstSideX - curX) / BattleDisplayDefine.cellWidth;
			}
			else
			{
				cellIndexX = (curX - BattleDisplayDefine.defStartPos.x) / BattleDisplayDefine.cellWidth;
			}
			
//			cellIndexX = Math.min(rowIndexMax,cellIndexX);
			cellIndexX = Math.max(rowIndexMin,cellIndexX);
			
			guessCellIndex = cellIndexX * BattleDefine.maxFormationYValue + cellIndexY + statrtCellCount;
			
			if(guessCellIndex == curCenterCellIndex)
				return;
			
			curCenterCellIndex = guessCellIndex;
			var cell:Cell = BattleUnitPool.getCellInfo(guessCellIndex);
			
			if(cell == null)
				return;
			
			var mappedTroop:CellTroopInfo = cell.troopInfo;
			var tempIndex:int = 0;
			var tempTargetCells:Array = [];
			var tempCheckCell:Cell;
			
			switch(searchType)
			{
				case BattleDefine.Range_SingleHero:
					if(mappedTroop != null)
					{
						var heroes:Array = mappedTroop.allHeroArr;
						for(var hIndex:int = 0;hIndex < heroes.length;hIndex++)
						{
							var singleHeroInfo:CellTroopInfo = heroes[hIndex];
							if(singleHeroInfo && singleHeroInfo.isHero && singleHeroInfo.visible && 
								singleHeroInfo.logicStatus != LogicSatusDefine.lg_status_hangToDie && singleHeroInfo.logicStatus != LogicSatusDefine.lg_status_dead)
							{
								tempTargetCells.push(BattleUnitPool.getCellInfo(singleHeroInfo.occupiedCellStart));
							}
						}
					}
					break;
				case BattleDefine.Range_singleArm:
					tempTargetCells.push(cell);
					break;
				case BattleDefine.Range_columnArm1:
					tempTargetCells = BattleFunc.particularCellsVertical(cellIndexX,targetPowerSide);
					break;
				case BattleDefine.Range_columnArm2:
					tempTargetCells = BattleFunc.particularCellsVertical(cellIndexX,targetPowerSide);
					var secondCells:Array = BattleFunc.particularCellsVertical(cellIndexX + 1,targetPowerSide);
					tempTargetCells = tempTargetCells.concat(secondCells);
					break;
				case BattleDefine.Range_columnArm3:
					tempTargetCells = BattleFunc.particularCellsVertical(cellIndexX,targetPowerSide);
					var nextLines:Array = BattleFunc.particularCellsVertical(cellIndexX + 1,targetPowerSide);
					tempTargetCells = tempTargetCells.concat(nextLines);
					nextLines = BattleFunc.particularCellsVertical(cellIndexX - 1,targetPowerSide);
					tempTargetCells = tempTargetCells.concat(nextLines);
					break;
			}
			
			var hasQualified:Boolean = false;
			for(tempIndex = 0;tempIndex < tempTargetCells.length;tempIndex++)
			{
				tempCheckCell = tempTargetCells[tempIndex];
				if(tempCheckCell && curShowBottomCells.hasOwnProperty(tempCheckCell.index))
				{
					hasQualified = true;
						break;
				}
			}
			
			if(hasQualified)
			{
				while(curShowSelectedCells.length > 0)
				{
					tempCheckCell = curShowSelectedCells.shift();
					if(tempCheckCell)
					{
						tempCheckCell.showSelectStatus(BattleDefine.Status_Default);
					}
				}
				
				for(tempIndex = 0;tempIndex < tempTargetCells.length;tempIndex++)
				{
					tempCheckCell = tempTargetCells[tempIndex];
					if(tempCheckCell && curShowBottomCells.hasOwnProperty(tempCheckCell.index))
					{
						curShowSelectedCells.push(tempCheckCell);
						tempCheckCell.showSelectStatus(BattleDefine.Status_Selected);
					}
				}
			}
			
		}
		
		public function get targetSide():int
		{
			return _targetSide;
		}
		
		public function set targetSide(value:int):void
		{
			_targetSide = value;
		}

		public function get searchType():int
		{
			return _searchType;
		}

		public function set searchType(value:int):void
		{
			_searchType = value;
			var singleCellInfo:Cell;
			clearCurSelectedStatus();
			if(_searchType != BattleDefine.Range_Clear)
			{
				this.visible = true;
				var allCells:Array = BattleUnitPool.getCellsOfSomeSide(targetSide);
				var selfSide:int = BattleFunc.getUserSelfSide(GlobalData.owner.uid);
				for(var i:int = 0;i < allCells.length;i++)
				{
					singleCellInfo = allCells[i];
					if(singleCellInfo != null)
					{
						if(singleCellInfo.troopInfo == null)
							continue;
						if(selfSide == targetSide && !TroopFunc.isPlayerSelfTroop(singleCellInfo.troopInfo))
						{
							continue;
						}
						if(singleCellInfo.checkCanShowSelected(_searchType))
						{
							singleCellInfo.showSelectStatus(BattleDefine.Status_Default);
							curShowBottomCells[singleCellInfo.index] = singleCellInfo;
						}
					}
				}
			}
		}
		
		public function clearInfo():void
		{
			this.visible = false;
			isChoosing = false;
			clearCurSelectedStatus();
			_targetSide = -1;
			_searchType = 0;
		}

	}
}