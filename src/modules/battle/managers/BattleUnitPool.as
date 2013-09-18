package modules.battle.managers
{
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import animator.resourceengine.ResType;
	
	import avatarsys.avatar.AvatarConfig;
	import avatarsys.avatar.AvatarShowFunc;
	import avatarsys.constants.AvatarDefine;
	import avatarsys.util.WeaponGenedEffectConfig;
	
	import defines.FormationSlotInfo;
	import defines.HeroDefines;
	import defines.UserArmInfo;
	import defines.UserHeroInfo;
	
	import eventengine.GameEventHandler;
	
	import macro.BattleDisplayDefine;
	import macro.EventMacro;
	import macro.FormationElementType;
	import macro.GameSizeDefine;
	
	import modules.battle.battlecomponent.HeroPortraitGroup;
	import modules.battle.battledata.ResLoadCompleteAgent;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.OtherStatusDefine;
	import modules.battle.battleevents.BattleStartEvent;
	import modules.battle.battlelogic.Cell;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.PowerSide;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.funcclass.TroopDisplayFunc;
	import modules.battle.funcclass.TroopFunc;
	import modules.battle.funcclass.TroopInitClearFunc;
	import modules.battle.stage.BattleStage;
	
	import synchronousLoader.BattleResourceCopy;
	import synchronousLoader.GameResourceManager;
	import synchronousLoader.LoadUnit;
	import synchronousLoader.ResourceConfig;
	import synchronousLoader.ResourcePool;
	
	import utils.TroopActConfig;

	/**
	 * 保存战斗单元的池，战斗开始的时候初始化    保存，cell，troop等信息
	 * @author SDD
	 */
	public class BattleUnitPool
	{
		
		private static var cellPool:Object={};
		public static var troopPool:Object =  [];
		private static var _nextWaveTroopPoolInfo:Object={};
		public static var nextWaveTroopInfo:Array=[];
		public static var allBaseArmOnBattle:Object={};			//在阵上的所有基础属性的值
		
		public static var usedTroopInfo:Array=[];				//此次用到的troop信息
		
		public static var tempResources:Array = [1415,1402,1403,1404,1405,1406,1407,1409,1451,1452,1453,1454,1455,1456,
			1457,1458,1459,1460,1461,1462,1463,1464,1465,1466,1467,1481,1482,1483,1484,1485,1486,1487,1488,15007,1469,1470,1472,14011];
		
		public static var resourceNeedToForceRelease:Array = [1410,1411,15002];
		
		public function BattleUnitPool()
		{
		}
		
		public static function get curWaveTroopPool():Object
		{
			return troopPool;
		}
		
		public static function getCompletedDefenseFormation(sourceFormation:Array,defenseInfo:Array):Array
		{
			var chengQiangArr:Array = defenseInfo[1];
			var chengQiangInfo:FormationSlotInfo;
			if(chengQiangArr)
			{
				chengQiangInfo = chengQiangArr[0];
			}
			
			var firstLineJianTa:Array = null;
			if(defenseInfo)
			{
				firstLineJianTa = defenseInfo[0];
			}
			
			var lastLineJianTa:Array = null;
			if(defenseInfo)
			{
				lastLineJianTa = defenseInfo[2];
			}
			
			var index:int;
			var singleHorizonLine:int = 0;
			for(index = 0;index < sourceFormation.length;index++)
			{
				var tempArr:Array = sourceFormation[index] as Array;
				if(tempArr)
					singleHorizonLine = Math.max(tempArr.length,singleHorizonLine);
			}
			
			var faleUserHeroInfo:UserHeroInfo = BattleFunc.makeAvarageHeroInfo(sourceFormation);
			
			var fakeFormation:FormationSlotInfo;
			for(index = 0;index < sourceFormation.length;index++)
			{
				tempArr = sourceFormation[index] as Array;
				if(tempArr != null)
				{
					while(tempArr.length < singleHorizonLine)
					{
						fakeFormation = new FormationSlotInfo;
						fakeFormation.type = FormationElementType.NOTHING;
						tempArr.push(fakeFormation);
					}
				}
			}
			
			var hasChengQiangInfo:Boolean = false;
			
			var singleArr:Array;
			var singleFormationInfo:FormationSlotInfo;
			if((chengQiangInfo)&&(chengQiangInfo.info))					//加入城墙逻辑
			{
				for(var i:int = 0;i < sourceFormation.length;i++)
				{
					singleArr = sourceFormation[i] as Array;
					if(i == 0)
					{
						singleArr.push(chengQiangInfo);
					}
					else
					{
						var emptyInfo:FormationSlotInfo = new FormationSlotInfo();
						emptyInfo.type = FormationElementType.NOTHING;
						singleArr.push(emptyInfo);
					}
				}
				hasChengQiangInfo = true;
			}
			
			var jIndex:int = 0;
			
			var hasJianTaInfo:Boolean = false;
			//增加箭塔
			if(firstLineJianTa && firstLineJianTa.length > 0)
			{
				var fakeFirstLine:Array=[];
				for(jIndex = 0;jIndex < Math.min(firstLineJianTa.length,singleHorizonLine - 1);jIndex++)
				{
					fakeFormation = firstLineJianTa[jIndex];
					if ((fakeFormation != null)&& fakeFormation.type != FormationElementType.NOTHING && fakeFormation.info)
					{
						fakeFirstLine.push(fakeFormation);
					}
				}
				if(fakeFirstLine.length > 0)
				{
					while(fakeFirstLine.length < singleHorizonLine - 1)
					{
						fakeFormation = new FormationSlotInfo();
						fakeFormation.type = FormationElementType.NOTHING;
						fakeFirstLine.unshift(fakeFormation);
					}
					
					fakeFormation = new FormationSlotInfo();
					fakeFormation.type = FormationElementType.HERO;
					fakeFormation.visible = BattleDefine.hidden;
					fakeFormation.info = faleUserHeroInfo;
					fakeFirstLine.unshift(fakeFormation);
					
					if(hasChengQiangInfo)				//城墙处加入空格
					{
						fakeFormation = new FormationSlotInfo();
						fakeFormation.type = FormationElementType.NOTHING;
						fakeFirstLine.push(fakeFormation);
					}
					sourceFormation.unshift(fakeFirstLine);
					hasJianTaInfo = true;
				}
			}
			
			if(lastLineJianTa && lastLineJianTa.length > 0)
			{
				var fakeLastLine:Array=[];
				for(jIndex = 0;jIndex < Math.min(lastLineJianTa.length,singleHorizonLine - 1);jIndex++)
				{
					fakeFormation = lastLineJianTa[jIndex];
					if((fakeFormation != null)&& fakeFormation.type != FormationElementType.NOTHING && fakeFormation.info!=null)
					{
						fakeLastLine.push(fakeFormation);
					}
				}
				if(fakeLastLine.length > 0)
				{
					while(fakeLastLine.length < singleHorizonLine - 1)
					{
						fakeFormation = new FormationSlotInfo();
						fakeFormation.type = FormationElementType.NOTHING;
						fakeLastLine.unshift(fakeFormation);
					}
					fakeFormation = new FormationSlotInfo();
					fakeFormation.type = FormationElementType.HERO;
					fakeFormation.visible = BattleDefine.hidden;
					fakeFormation.info = faleUserHeroInfo;
					fakeLastLine.unshift(fakeFormation);
					
					if(hasChengQiangInfo)					//城墙处加入空格
					{
						fakeFormation = new FormationSlotInfo();
						fakeFormation.type = FormationElementType.NOTHING;
						fakeLastLine.push(fakeFormation);
					}
					sourceFormation.push(fakeLastLine);
				}
			}
			
			return sourceFormation;
		}
		
		//pve_Raid初始化下一波数据
		public static function initNextTeamInfo(atkFromation:Array):void
		{
			if(atkFromation == null)
				return;
			usedTroopInfo =[];
			var singleFormationRows:int = 0;
			singleFormationRows = atkFromation.length;
			var formationOffectVertical:int = 0;
			var singleHorizon:Array;
			var singleHorizonLength:int = 0;
			var i:int = 0,ii:int = 0;
			var singleLoadResId:int;
			var singleCell:Cell;
			var singleTroop:CellTroopInfo;
			var curStartIndex:int = 0;
			var singleSlot:FormationSlotInfo;
			var singleConfigInfo:AvatarConfig;
			var heroPosPt:Point;
			var singleResInfoNeed:Array=[];
			var resNeedInfoId:Array=[];
			var allAvatarConfigInfo:Array=[];
			
			if(singleFormationRows < BattleDefine.maxFormationYValue)
			{
				if((BattleDefine.maxFormationYValue - singleFormationRows) % 2 == 0)
					formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows)/2;
				else
					formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows - 1)/2;
			}
			else
				formationOffectVertical = 0;
			
			singleHorizon = atkFromation[0] as Array;
			singleHorizonLength = singleHorizon.length;
			
			BattleManager.instance.pSideAtk.yMaxValue = atkFromation.length;
			BattleManager.instance.pSideAtk.xMaxValue = singleHorizonLength;
			BattleManager.instance.pSideAtk.xMaxValue = Math.max(BattleManager.instance.pSideAtk.xMaxValue,BattleDisplayDefine.heroPosLeastGap + 1);		//英雄最多在第三排
			
			for(ii = 0; ii < BattleDefine.maxFormationYValue;ii++)
			{
				if(ii < atkFromation.length)
					singleHorizon = atkFromation[ii] as Array;
				else
					singleHorizon = null;
				for(i = 0;i < BattleDefine.maxFormationXValue;i++)
				{
					singleLoadResId = -1;
					singleConfigInfo = null;
					
					curStartIndex = i * BattleDefine.maxFormationYValue + ii;
					
					singleCell = getFreeCell(curStartIndex);
					if(singleHorizon && i < singleHorizon.length)
					{
						singleSlot = singleHorizon[singleHorizonLength - 1 - i] as FormationSlotInfo;
						if(singleSlot && FormationElementType.NOTHING != singleSlot.type)				//如果有type
						{
							singleTroop = getFreeTroop(CellTroopInfo.globalTroopIndex++);
							usedTroopInfo.push(singleTroop);
							singleTroop.initDataFromSlot(singleSlot);
							singleTroop.slotIndex = singleSlot.colindex + singleSlot.rowindex * 100;			//自己玩家的兵，要记录当前的slot的索引
							singleTroop.occupiedCellStart = singleCell.index + formationOffectVertical;				//加入cell和troop之间的联系
							
							//添加需要下载的资源
							if(singleTroop.isHero)
							{
								//英雄最多站在第二排后面
								heroPosPt = BattleTargetSearcher.getRowColumnByCellIndex(singleTroop.occupiedCellStart);
								if(heroPosPt.x < BattleDisplayDefine.heroPosLeastGap)
								{
									singleTroop.occupiedCellStart += (BattleDisplayDefine.heroPosLeastGap - heroPosPt.x) * BattleDefine.maxFormationYValue;
								}
								
								//如果不是隐藏英雄
								if(singleTroop.troopVisibleOnBattle)
								{
									if(!singleTroop.isPlayerHero)
									{
										singleLoadResId = singleTroop.attackUnit.effectid;
										singleResInfoNeed.push(singleLoadResId * ResourceConfig.swfIdMapValue);
									}
									else
									{
										singleConfigInfo = TroopFunc.getTroopAvatarConfigInfo(singleTroop,true);
									}
								}
								//								singleResInfoNeed.push(singleTroop.attackUnit.contentHeroInfo.heroportrait);
							}
							else
							{
								singleLoadResId = singleTroop.attackUnit.effectid;
							}
							
							if(singleLoadResId > 0)
							{
								if(!singleTroop.isHero)
									resNeedInfoId.push(singleLoadResId);
							}
							if(singleConfigInfo != null)
							{
								allAvatarConfigInfo.push(singleConfigInfo);
							}
							BattleStage.instance.troopLayer.addTroopToStage(singleTroop,true);			//troop将入舞台
						}
					}
				}
			}
			
			var allCellInfo:Array;
			var checkedCell:Object={};
			for each(singleTroop in usedTroopInfo)
			{
				if(singleTroop)			
				{
					allCellInfo = BattleFunc.getCellsOccupied(singleTroop.troopIndex);
					for each(var singleCellIndex:int in allCellInfo)
					{
						if(checkedCell.hasOwnProperty(singleCellIndex))
							continue;
						singleCell = BattleUnitPool.getCellInfo(singleCellIndex);
						if(singleCell)
						{
							singleCell.troopInfo = singleTroop;
							checkedCell[singleCellIndex] = 1;
						}
					}
				}
			}
			
			var singleEffectId:int = 0;
			for each(var singleId:int in resNeedInfoId)
			{
				GameResourceManager.addResIdArr(TroopActConfig.getAllEffectNeed(singleId));
			}
			GameResourceManager.addResIdArr(singleResInfoNeed);
			
			for each(var singleAvatarConfigInfo:AvatarConfig in allAvatarConfigInfo)
			{
				singleAvatarConfigInfo.adjustConfigForNormal();
				singleAvatarConfigInfo.adjustForBattle();
				GameResourceManager.addResIdArr(WeaponGenedEffectConfig.getAllEffectNeed(singleAvatarConfigInfo));
				
				var avatarResNeedArr:Array = AvatarShowFunc.getResNeedFromConfig(singleAvatarConfigInfo,AvatarDefine.battle);
				for each(var singleAvatarResUrl:String in avatarResNeedArr)
				{
					GameResourceManager.addResToLoadByUrl(singleAvatarResUrl);
				}
			}
			
			BattleManager.instance.pSideAtk.adjustHeroPos(true);				//调整英雄位置
			
			ResLoadCompleteAgent.setCurFuncInfo(singleTeamResLoaded,null);
			BattleResourceCopy.analyseResToLoad(ResLoadCompleteAgent.executeFunc);
			GameResourceManager.startLoad(ResLoadCompleteAgent.onResLoadCompleteCall,GameResourceManager.simplyBack);
		}
		
		public static function makeWaitTeamLoad(atkFromation:Array):void
		{
			if(atkFromation == null || atkFromation.length <= 0)
			{
				return;
			}
			usedTroopInfo =[];
			var uHeroInfo:UserHeroInfo;
			var userArmInfo:UserArmInfo;
			var singleHorizon:Array;
			var singleHorizonLength:int = 0;
			var i:int = 0,ii:int = 0;
			var singleLoadResId:int;
			var singleSlot:FormationSlotInfo;
			var singleConfigInfo:AvatarConfig;
			var heroPosPt:Point;
			var singleResInfoNeed:Array=[];
			var resNeedInfoId:Array=[];
			var allAvatarConfigInfo:Array=[];
			
			singleHorizon = atkFromation[0] as Array;
			singleHorizonLength = singleHorizon.length;
			
			for(ii = 0; ii < BattleDefine.maxFormationYValue;ii++)
			{
				if(ii < atkFromation.length)
					singleHorizon = atkFromation[ii] as Array;
				else
					singleHorizon = null;
				for(i = 0;i < BattleDefine.maxFormationXValue;i++)
				{
					singleLoadResId = -1;
					singleConfigInfo = null;
					
					if(singleHorizon && i < singleHorizon.length)
					{
						singleSlot = singleHorizon[singleHorizonLength - 1 - i] as FormationSlotInfo;
						if(singleSlot && FormationElementType.NOTHING != singleSlot.type)				//如果有type
						{
							//添加需要下载的资源
							if(FormationElementType.HERO == singleSlot.type && singleSlot.info as UserHeroInfo)
							{
								//如果不是隐藏英雄
								if(singleSlot.visible == BattleDefine.normalShow)
								{
									uHeroInfo = singleSlot.info as UserHeroInfo;
									if(!uHeroInfo.heroid == HeroDefines.userDefaultHero)
									{
										singleLoadResId = uHeroInfo.effectid;
										singleResInfoNeed.push(singleLoadResId * ResourceConfig.swfIdMapValue);
									}
									else
									{
										singleConfigInfo = BattleInfoSnap.getSingleUserAvatarInfo(uHeroInfo.uid);
									}
								}
							}
							else if(FormationElementType.ARM == singleSlot.type && singleSlot.info as UserArmInfo)
							{
								userArmInfo = singleSlot.info as UserArmInfo;
								singleLoadResId = userArmInfo.effectid;
							}
							
							if(singleLoadResId > 0)
							{
								resNeedInfoId.push(singleLoadResId);
							}
							if(singleConfigInfo != null)
							{
								allAvatarConfigInfo.push(singleConfigInfo);
							}
						}
					}
				}
			}
			
			var singleEffectId:int = 0;
			for each(var singleId:int in resNeedInfoId)
			{
				GameResourceManager.addResToBackLoadByIdArr(TroopActConfig.getAllEffectNeed(singleId));
			}
			GameResourceManager.addResToBackLoadByIdArr(singleResInfoNeed);
			
			for each(var singleAvatarConfigInfo:AvatarConfig in allAvatarConfigInfo)
			{
				singleAvatarConfigInfo.adjustConfigForNormal();
				singleAvatarConfigInfo.adjustForBattle();
				GameResourceManager.addResToBackLoadByIdArr(WeaponGenedEffectConfig.getAllEffectNeed(singleAvatarConfigInfo));
				var avatarResNeedArr:Array = AvatarShowFunc.getResNeedFromConfig(singleAvatarConfigInfo,AvatarDefine.battle);
				for each(var singleAvatarResUrl:String in avatarResNeedArr)
				{
					GameResourceManager.addResToBackLoadByUrl(singleAvatarResUrl);
				}
			}
			GameResourceManager.startBackLoad();
		}
		
		public static function singleTeamResLoaded(params:Array = null):void
		{
			var singleTroop:CellTroopInfo;
			var allAtkTroops:Array = BattleUnitPool.getTroopsOfSomeSide(BattleDefine.firstAtk);
			for each(singleTroop in allAtkTroops)
			{
				if(singleTroop && (singleTroop.troopPlayerId == "" || singleTroop.troopPlayerId == null) && 
					singleTroop.avatarShowObj == null && singleTroop.heroShowObj == null)			//如果此时动画没有加到troop中
				{
					TroopDisplayFunc.initShowInfo(singleTroop);
				}
			}
			
			//当前在阵上的初始化
			initLeftPortrait(true);
			
			BattleManager.instance.portraitGroupAtk.targetPowerside = BattleManager.instance.pSideAtk;
			BattleManager.instance.startNextPlayerTeamInfo();
		}
		
		/**
		 * 根据阵型，初始化数据
		 * @param atkFromation				先手阵形数据
		 * @param defFromation				后手阵形数据
		 * 
		 */
		public static function initFormationInfo(atkFromation:Array):void
		{
//			var formationInfo:UserFormationInfo = GlobalData.owner.userFormation.GetUserFormByType(FormationDefine.CITY_DEFENCE);
//			var sourceFormation:Array = formationInfo.getBattleFormation();
//			var defenseInfo:Array = formationInfo.GetDefenceFormation();
//			atkFromation = getCompletedDefenseFormation(sourceFormation,defenseInfo);
			
			var defFromation:Array = BattleManager.instance.getCurWaveEnemyInfo();
			var nextWave:Array = BattleManager.instance.getNextWaveEnemyInfo();
			
			BattleInfoSnap.isNextWaveOnDaiJiQu = false;
			//初始化双方势力信息
			BattleManager.instance.pSideAtk = new PowerSide;
			BattleManager.instance.pSideAtk.isFirstAtk = true;
			BattleManager.instance.pSideDef = new PowerSide;
			BattleManager.instance.pSideDef.isFirstAtk = false;
			
			var i:int = 0;
			var ii:int = 0;
			
			var curIndex:int = 0;			//cell的index
//			var troopIndex:int = 0;			//troop的index
			
			var singleHorizon:Array;
			var singleSlot:FormationSlotInfo;
			var singleCell:Cell;
			var singleTroop:CellTroopInfo;
			var singleHorizonLength:int = 0;
			
			var resNeedInfoId:Array=[];			//需要的资源		资源id
			var singleResInfoNeed:Array=[];
			var allAvatarConfigInfo:Array=[];
			
			var singleLoadResId:int = 0;
			var singleConfigInfo:AvatarConfig = null;
			
			var singleFormationRows:int = 0;
			var formationOffectVertical:int = 0;
			
			var curStartIndex:int = 0;		//初始化的index
			var curCellIndex:int = 0;
			var heroPosPt:Point;
			
			usedTroopInfo =[];			//此次用到的troop信息
			
			singleFormationRows = atkFromation.length;
			if(singleFormationRows < BattleDefine.maxFormationYValue)
			{
				if((BattleDefine.maxFormationYValue - singleFormationRows) % 2 == 0)
					formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows)/2;
				else
					formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows - 1)/2;
			}
			else
				formationOffectVertical = 0;
			
			singleHorizon = atkFromation[0] as Array;
			singleHorizonLength = singleHorizon.length;
			
			BattleManager.instance.pSideAtk.yMaxValue = atkFromation.length;
			BattleManager.instance.pSideAtk.xMaxValue = singleHorizonLength;
			BattleManager.instance.pSideAtk.xMaxValue = Math.max(BattleManager.instance.pSideAtk.xMaxValue,BattleDisplayDefine.heroPosLeastGap + 1);		//英雄最多在第三排
			
			for(ii = 0; ii < BattleDefine.maxFormationYValue;ii++)
			{
				if(ii < atkFromation.length)
					singleHorizon = atkFromation[ii] as Array;
				else
					singleHorizon = null;
				for(i = 0;i < BattleDefine.maxFormationXValue;i++)
				{
					singleLoadResId = -1;
					singleConfigInfo = null;
					
					curStartIndex = i * BattleDefine.maxFormationYValue + ii;
					
					singleCell = getFreeCell(curStartIndex);
					if(singleHorizon && i < singleHorizon.length)
					{
						singleSlot = singleHorizon[singleHorizonLength - 1 - i] as FormationSlotInfo;
						if(singleSlot && FormationElementType.NOTHING != singleSlot.type)				//如果有type
						{
							singleTroop = getFreeTroop(CellTroopInfo.globalTroopIndex++);
							usedTroopInfo.push(singleTroop);
							singleTroop.initDataFromSlot(singleSlot);
							singleTroop.slotIndex = singleSlot.colindex + singleSlot.rowindex * 100;			//自己玩家的兵，要记录当前的slot的索引
							singleTroop.occupiedCellStart = singleCell.index + formationOffectVertical;				//加入cell和troop之间的联系
							
							//添加需要下载的资源
							if(singleTroop.isHero)
							{
								//英雄最多站在第二排后面
								heroPosPt = BattleTargetSearcher.getRowColumnByCellIndex(singleTroop.occupiedCellStart);
								if(heroPosPt.x < BattleDisplayDefine.heroPosLeastGap)
								{
									singleTroop.occupiedCellStart += (BattleDisplayDefine.heroPosLeastGap - heroPosPt.x) * BattleDefine.maxFormationYValue;
								}
								
								//如果不是隐藏英雄
								if(singleTroop.troopVisibleOnBattle)
								{
									if(!singleTroop.isPlayerHero)
									{
										singleLoadResId = singleTroop.attackUnit.effectid;
										singleResInfoNeed.push(singleLoadResId * ResourceConfig.swfIdMapValue);
									}
									else
									{
										singleConfigInfo = TroopFunc.getTroopAvatarConfigInfo(singleTroop,true);
									}
								}
//								singleResInfoNeed.push(singleTroop.attackUnit.contentHeroInfo.heroportrait);
							}
							else
							{
								if(singleTroop.attackUnit)
									singleLoadResId = singleTroop.attackUnit.effectid;
								else
									singleLoadResId = -1;
								
							}
							
							if(singleLoadResId > 0)
							{
								resNeedInfoId.push(singleLoadResId);
							}
							if(singleConfigInfo != null)
							{
								allAvatarConfigInfo.push(singleConfigInfo);
							}
							BattleStage.instance.troopLayer.addTroopToStage(singleTroop,true);			//troop将入舞台
						}
					}
				}
			}
			
			singleFormationRows = defFromation.length;
			var leftSide:int = BattleFunc.getPowerSideCellCount();
			
			if(singleFormationRows < BattleDefine.maxFormationYValue)
			{
				if((BattleDefine.maxFormationYValue - singleFormationRows) % 2 == 0)
					formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows)/2;
				else
					formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows - 1)/2;
			}
			else
				formationOffectVertical = 0;
			
			singleHorizon = defFromation[0] as Array;
			singleHorizonLength = singleHorizon.length;
			BattleManager.instance.pSideDef.yMaxValue = defFromation.length;
			BattleManager.instance.pSideDef.xMaxValue = singleHorizonLength;
			BattleManager.instance.pSideDef.xMaxValue = Math.max(BattleManager.instance.pSideDef.xMaxValue,BattleDisplayDefine.heroPosLeastGap + 1);	//英雄最多在第三排
			
			var hsaVisibleHero:Boolean = false;
			for(ii = 0; ii < defFromation.length;ii++)
			{
				singleHorizon = defFromation[ii] as Array;
				if(singleHorizon)
				{
					singleSlot = singleHorizon[0] as FormationSlotInfo;
					if(singleSlot && singleSlot.type == FormationElementType.HERO && singleSlot.visible)
					{
						hsaVisibleHero = true;
						break;
					}
				}
			}
			if(hsaVisibleHero)
			{
				BattleInfoSnap.hasVisibleHeroOnWave = true;
				BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex = Math.max(BattleManager.instance.pSideDef.xMaxValue,BattleDefine.shuaGuaiTroopLength);
			}
			else
			{
				BattleInfoSnap.hasVisibleHeroOnWave = false;
				BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex = BattleDefine.shuaGuaiTroopLength;
			}
			
			for(ii = 0;ii < BattleDefine.maxFormationYValue;ii++)
			{
				if(ii <defFromation.length)
					singleHorizon = defFromation[ii] as Array;
				else
					singleHorizon = null;
				for(i = 0;i < BattleDefine.maxFormationXValue;i++)
				{
					singleLoadResId = -1;
					singleConfigInfo = null;
					
					curStartIndex = i * BattleDefine.maxFormationYValue + ii + leftSide;
					
					singleCell = getFreeCell(curStartIndex);
					if(singleHorizon && i < singleHorizon.length)
					{
						singleSlot = singleHorizon[singleHorizonLength - 1 - i] as FormationSlotInfo;
						if(FormationElementType.NOTHING != singleSlot.type)				//如果有type
						{
							singleTroop = getFreeTroop(CellTroopInfo.globalTroopIndex++);
							usedTroopInfo.push(singleTroop);
							singleTroop.initDataFromSlot(singleSlot);
							singleTroop.slotIndex = singleSlot.colindex + singleSlot.rowindex * 100;			//自己玩家的兵，要记录当前的slot的索引
							singleTroop.occupiedCellStart = singleCell.index + formationOffectVertical;				//加入cell和troop之间的联系
							
							//添加需要下载的资源
							if(singleTroop.isHero)
							{
								//英雄最多站在第二排后面
								heroPosPt = BattleTargetSearcher.getRowColumnByCellIndex(singleTroop.occupiedCellStart);
								if(heroPosPt.x < BattleDisplayDefine.heroPosLeastGap)
								{
									singleTroop.occupiedCellStart += (BattleDisplayDefine.heroPosLeastGap - heroPosPt.x) * BattleDefine.maxFormationYValue;
								}
								
								if(singleTroop.troopVisibleOnBattle)
								{
									if(!singleTroop.isPlayerHero)
									{
										singleLoadResId = singleTroop.attackUnit.effectid;
										singleResInfoNeed.push(singleLoadResId * ResourceConfig.swfIdMapValue);
									}
									else
									{
										singleConfigInfo = TroopFunc.getTroopAvatarConfigInfo(singleTroop,false); 
									}
								}
//								singleResInfoNeed.push(singleTroop.attackUnit.contentHeroInfo.heroportrait);
							}
							else
							{
								singleLoadResId = singleTroop.attackUnit.effectid;
							}
							
							if(singleLoadResId > 0)
							{
								resNeedInfoId.push(singleLoadResId);
							}
							if(singleConfigInfo != null)
							{
								allAvatarConfigInfo.push(singleConfigInfo);
							}
							
							BattleStage.instance.troopLayer.addTroopToStage(singleTroop,false);			//troop将入舞台
						}
					}
				}
			}

			nextWaveTroopInfo = null;
			if(nextWave != null)
			{
				nextWaveTroopInfo =[];
				singleFormationRows = nextWave.length;
				singleHorizon = nextWave[0] as Array;
				singleHorizonLength = singleHorizon.length;
				
				if(singleFormationRows < BattleDefine.maxFormationYValue)
				{
					if((BattleDefine.maxFormationYValue - singleFormationRows) % 2 == 0)
						formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows)/2;
					else
						formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows - 1)/2;
				}
				else
					formationOffectVertical = 0;
				
				for(ii = 0;ii < BattleDefine.maxFormationYValue;ii++)
				{
					if(ii < nextWave.length)
						singleHorizon = nextWave[ii] as Array;
					else
						singleHorizon = null;
					for(i = 0;i < BattleDefine.maxFormationXValue;i++)
					{
						singleLoadResId = -1;
						
						curStartIndex = i * BattleDefine.maxFormationYValue + ii + leftSide;
						
						if(singleHorizon && i < singleHorizon.length)
						{
							singleSlot = singleHorizon[singleHorizonLength - 1 - i] as FormationSlotInfo;
							if(FormationElementType.NOTHING != singleSlot.type)				//如果有type
							{
								singleTroop = getNextWaveFreeTroop(CellTroopInfo.globalTroopIndex++);
								nextWaveTroopInfo.push(singleTroop);
								
								singleTroop.initDataFromSlot(singleSlot);
								singleTroop.occupiedCellStart = curStartIndex + formationOffectVertical;				//加入cell和troop之间的联系
								
								//添加需要下载的资源
								if(singleTroop.isHero)
								{
									//英雄最多站在第二排后面
									heroPosPt = BattleTargetSearcher.getRowColumnByCellIndex(singleTroop.occupiedCellStart);
									if(heroPosPt.x < BattleDisplayDefine.heroPosLeastGap)
									{
										singleTroop.occupiedCellStart += (BattleDisplayDefine.heroPosLeastGap - heroPosPt.x) * BattleDefine.maxFormationYValue;
									}
									
									if(singleTroop.troopVisibleOnBattle)
									{
										if(!singleTroop.isPlayerHero)
										{
											singleLoadResId = singleTroop.attackUnit.effectid;
											singleResInfoNeed.push(singleLoadResId * ResourceConfig.swfIdMapValue);
										}
										else
										{
											singleConfigInfo = TroopFunc.getTroopAvatarConfigInfo(singleTroop,false);
										}
									}
//									singleResInfoNeed.push(singleTroop.attackUnit.contentHeroInfo.heroportrait);
								}
								else
								{
									singleLoadResId = singleTroop.attackUnit.effectid;
								}
								
//								if(singleLoadResId > 0)
//								{
//									resNeedInfoId.push(singleLoadResId);
//								}
								if(singleConfigInfo != null)
								{
									allAvatarConfigInfo.push(singleConfigInfo);
								}
								BattleStage.instance.troopLayer.addNextWaveTroopToStage(singleTroop);			//troop将入舞台
							}
						}
					}
				}
			}
			
			var poolAllTroop:Array = getAllTroops();
			var allCellInfo:Array;
			var checkedCell:Object={};
			for each(singleTroop in poolAllTroop)
			{
				if(singleTroop)			
				{
					allCellInfo = BattleFunc.getCellsOccupied(singleTroop.troopIndex);
					for each(var singleCellIndex:int in allCellInfo)
					{
						if(checkedCell.hasOwnProperty(singleCellIndex))
							continue;
						singleCell = BattleUnitPool.getCellInfo(singleCellIndex);
						if(singleCell)
						{
							singleCell.troopInfo = singleTroop;
							checkedCell[singleCellIndex] = 1;
						}
					}
				}
			}
			
			var singleEffectId:int = 0;
			for each(var singleId:int in resNeedInfoId)
			{
				GameResourceManager.addResIdArr(TroopActConfig.getAllEffectNeed(singleId));
			}
			GameResourceManager.addResIdArr(singleResInfoNeed);
			
			for each(var singleAvatarConfigInfo:AvatarConfig in allAvatarConfigInfo)
			{
				singleAvatarConfigInfo.adjustConfigForNormal();
				singleAvatarConfigInfo.adjustForBattle();
				GameResourceManager.addResIdArr(WeaponGenedEffectConfig.getAllEffectNeed(singleAvatarConfigInfo));
				
				var avatarResNeedArr:Array = AvatarShowFunc.getResNeedFromConfig(singleAvatarConfigInfo,AvatarDefine.battle);
				for each(var singleAvatarResUrl:String in avatarResNeedArr)
				{
					GameResourceManager.addResToLoadByUrl(singleAvatarResUrl);
				}
			}
			
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance)
			{
				GameResourceManager.addResToLoadById(15002);
			}
			
			addTempBattleResource();
			
			BattleManager.instance.curWaveIndex++;
		}
		
		/**
		 * 战斗资源全部加载完 
		 */
		public static function battleResourceLoaded(param:Array):void
		{
//			BattleStage.instance.visible = true;
			BattleStage.instance.showBattle(true);
			
			var backGroundImage:Bitmap = ResourcePool.getBitmapById(BattleInfoSnap.battleBackgroundId);
			if(backGroundImage)
			{
				BattleStage.instance.realbattleBackGroundLayer.addChild(backGroundImage);
			}
//				BattleStage.instance.battleBackGroundLayer.addChildAt(backGroundImage,0);
			
			//左侧的头像集合初始化
			initLeftPortrait(true);
			
			//右侧的头像集合初始化
			initLeftPortrait(false);
			
			var usedTroopInfo:Array = param[0] as Array;
			var singleTRoop:CellTroopInfo;
			for each(singleTRoop in usedTroopInfo)				//初始化信息
			{
				TroopDisplayFunc.initShowInfo(singleTRoop);
			}
			
			if(nextWaveTroopInfo)
			{
				for each(singleTRoop in nextWaveTroopInfo)				//初始化信息
				{
					TroopDisplayFunc.initShowInfo(singleTRoop);
				}
			}
			
			BattleManager.instance.portraitGroupAtk.targetPowerside = BattleManager.instance.pSideAtk;
			BattleManager.instance.portraitGroupDef.targetPowerside = BattleManager.instance.pSideDef;
			
			BattleManager.instance.pSideAtk.adjustHeroPos(true);
			BattleManager.instance.pSideDef.adjustHeroPos(true);
			
			BattleManager.cardManager.initAvailableCards([]);
			
			BattleStage.instance.initAfterResLoaded();
			
			GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,
				new BattleStartEvent(BattleStartEvent.BATTLE_START,OtherStatusDefine.battleOn));
		}
		
		/**
		 *  初始化刷怪或副本时候的一波的情形
		 */
		public static function initSingleWaveInfo():void
		{
			BattleInfoSnap.isNextWaveOnDaiJiQu = false;
			var i:int = 0,ii:int = 0,curIndex:int = 0;			//troop的index
			var singleHorizon:Array;
			var singleSlot:FormationSlotInfo;
			var singleTroop:CellTroopInfo;
			var singleHorizonLength:int = 0;
			var singleEffectId:int = 0;
			var singleLoadResId:int = 0,missileId:int = 0,bearEffect:int = 0,secondBearEffect:int = 0,magicEffect:int = 0;			//英雄头像
			
			//将nextWave的数据转为当前的troop信息
			for each(singleTroop in nextWaveTroopInfo)
			{
				if(singleTroop)
				{
					singleLoadResId = 0;
					troopPool[singleTroop.troopIndex] = singleTroop;
					delete _nextWaveTroopPoolInfo[singleTroop.troopIndex];
					if(singleTroop.logicStatus == LogicSatusDefine.lg_status_waitingForNextWave)
						singleTroop.logicStatus = LogicSatusDefine.lg_status_idle;
					//清除信息，以防万一
					singleTroop.allHeroArr = null;
					singleTroop.heroPropertyStore ={};
					
					if(singleTroop.isHero)
					{
						if(singleTroop.troopVisibleOnBattle)
						{
							singleLoadResId = singleTroop.attackUnit.effectid;
							GameResourceManager.addResToLoadById(singleLoadResId * ResourceConfig.swfIdMapValue);
						}
					}
					else
					{
						singleLoadResId = singleTroop.attackUnit.effectid;
					}
					if(singleLoadResId > 0)				
					{
						GameResourceManager.addResIdArr(TroopActConfig.getAllEffectNeed(singleLoadResId));
					}
				}
			}

			var leftside:int = BattleFunc.getPowerSideCellCount(true);
			var rightCount:int = BattleFunc.getPowerSideCellCount(false);
			for(i = leftside; i < leftside + rightCount;i++)
			{
				cellPool[i] = new Cell(i);
			}
			
			var allCellInfo:Array;
			var checkedCell:Object={};
			var singleCell:Cell;
			for each(singleTroop in nextWaveTroopInfo)
			{
				if(singleTroop)			
				{
					allCellInfo = BattleFunc.getCellsOccupied(singleTroop.troopIndex);
					for each(var singleCellIndex:int in allCellInfo)
					{
						if(checkedCell.hasOwnProperty(singleCellIndex))
							continue;
						singleCell = BattleUnitPool.getCellInfo(singleCellIndex);
						if(singleCell)
						{
							singleCell.troopInfo = singleTroop;
							checkedCell[singleCellIndex] = 1;
						}
					}
				}
			}
			
			var defFromation:Array = BattleManager.instance.getCurWaveEnemyInfo();
			singleHorizon = defFromation[0] as Array;
			singleHorizonLength = singleHorizon.length;
			BattleManager.instance.pSideDef.yMaxValue = defFromation.length;
			BattleManager.instance.pSideDef.xMaxValue = singleHorizonLength;
			BattleManager.instance.pSideDef.xMaxValue = Math.max(BattleManager.instance.pSideDef.xMaxValue,BattleDisplayDefine.heroPosLeastGap + 1);	//英雄最多在第三排
			
			var hsaVisibleHero:Boolean = false;
			for(ii = 0; ii < defFromation.length;ii++)
			{
				singleHorizon = defFromation[ii] as Array;
				if(singleHorizon)
				{
					singleSlot = singleHorizon[0] as FormationSlotInfo;
					if(singleSlot && singleSlot.type == FormationElementType.HERO && singleSlot.visible)
					{
						hsaVisibleHero = true;
						break;
					}
				}
			}
			if(hsaVisibleHero)
			{
				BattleInfoSnap.hasVisibleHeroOnWave = true;
				BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex = Math.max(BattleManager.instance.pSideDef.xMaxValue,BattleDefine.shuaGuaiTroopLength);
			}
			else
			{
				BattleInfoSnap.hasVisibleHeroOnWave = false;
				BattleManager.instance.pSideDef.shuaiGuaiCheckRowIndex = BattleDefine.shuaGuaiTroopLength;
			}
			
			var nextWave:Array = null;
			nextWaveTroopInfo = null;
			nextWave = BattleManager.instance.getNextWaveEnemyInfo();
			BattleManager.instance.curWaveIndex++;
			if(nextWave == null)
			{
				ResLoadCompleteAgent.setCurFuncInfo(singleWaveResLoaded,null);
				BattleResourceCopy.analyseResToLoad(ResLoadCompleteAgent.executeFunc);
				GameResourceManager.startLoad(ResLoadCompleteAgent.onResLoadCompleteCall,GameResourceManager.simplyBack);
				return;
			}
			
			nextWaveTroopInfo =[];
			var singleFormationRows:int = 0,formationOffectVertical:int = 0;			//水平方向的偏移量
			var resNeedInfoId:Object = new Dictionary;			//需要的资源		资源id
			var scatteredArr:Array=[];
			
			var curStartIndex:int = 0;		//初始化的index
			var curCellIndex:int = 0;
			var heroPosPt:Point;
			
			var leftSide:int = BattleFunc.getPowerSideCellCount();
			singleFormationRows = nextWave.length;
			
			singleHorizon = nextWave[0] as Array;
			singleHorizonLength = singleHorizon.length;
			
			if(singleFormationRows < BattleDefine.maxFormationYValue)
			{
				if((BattleDefine.maxFormationYValue - singleFormationRows) % 2 == 0)
					formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows)/2;
				else
					formationOffectVertical = (BattleDefine.maxFormationYValue - singleFormationRows - 1)/2;
			}
			else
				formationOffectVertical = 0;
			
			for(ii = 0;ii < BattleDefine.maxFormationYValue;ii++)
			{
				if(ii < nextWave.length)
					singleHorizon = nextWave[ii] as Array;
				else
					singleHorizon = null;
				for(i = 0;i < BattleDefine.maxFormationXValue;i++)
				{
					singleLoadResId = -1;
					
					curStartIndex = i * BattleDefine.maxFormationYValue + ii + leftSide;
					
					if(singleHorizon && i < singleHorizon.length)
					{
						singleSlot = singleHorizon[singleHorizonLength - 1 - i] as FormationSlotInfo;
						if(FormationElementType.NOTHING != singleSlot.type)				//如果有type
						{
							singleTroop = getNextWaveFreeTroop(CellTroopInfo.globalTroopIndex++);
							nextWaveTroopInfo.push(singleTroop);
							
							if(BattleModeDefine.isGeneralRaid)
								singleTroop.initDataFromSlot(singleSlot);
							else
								singleTroop.initDataFromSlot(singleSlot);
							singleTroop.occupiedCellStart = curStartIndex + formationOffectVertical;				//加入cell和troop之间的联系
							
							//添加需要下载的资源
							if(singleTroop.isHero)
							{
								//英雄最多站在第二排后面
								heroPosPt = BattleTargetSearcher.getRowColumnByCellIndex(singleTroop.occupiedCellStart);
								if(heroPosPt.x < BattleDisplayDefine.heroPosLeastGap)
								{
									singleTroop.occupiedCellStart += (BattleDisplayDefine.heroPosLeastGap - heroPosPt.x) * BattleDefine.maxFormationYValue;
								}
								
								if(singleTroop.troopVisibleOnBattle)
								{
									singleLoadResId = singleTroop.attackUnit.effectid;
									scatteredArr.push(singleLoadResId * ResourceConfig.swfIdMapValue);
								}
//								scatteredArr.push(singleTroop.attackUnit.contentHeroInfo.heroportrait);
							}
							else
							{
								singleLoadResId = singleTroop.attackUnit.effectid;
							}
							
							if(singleLoadResId > 0)
							{
								resNeedInfoId[singleTroop] = singleLoadResId;
							}
							BattleStage.instance.troopLayer.addNextWaveTroopToStage(singleTroop);			//troop将入舞台
						}
					}
				}
			}
			
			//下一波敌人需要的效果资源，后台加载
			var needBackLoadRes:Array=[];
			for(var singleTroopTag:* in resNeedInfoId)
			{
				var realId:int = resNeedInfoId[singleTroopTag];
				var targetTroop:CellTroopInfo = singleTroopTag as CellTroopInfo;
				if(targetTroop == null)
					continue;
					
				needBackLoadRes = needBackLoadRes.concat(TroopActConfig.getAllEffectNeed(realId));
				if(targetTroop.isHero)
				{
					var resourUnit:LoadUnit = ResourceConfig.getSingleResConfigById(realId);
					if(resourUnit.m_type == ResType.REFLECT_SWF)
					{
						var swfResId:int = realId * ResourceConfig.swfIdMapValue;
						var mappedSwf:LoadUnit = ResourceConfig.getSingleResConfigById(swfResId);
						if(mappedSwf && mappedSwf.m_type == ResType.ANIMATOR)
						{
							needBackLoadRes.push(realId * ResourceConfig.swfIdMapValue);
						}
					}
				}
			}
			needBackLoadRes = needBackLoadRes.concat(scatteredArr);
			
			//加载资源
			ResLoadCompleteAgent.setCurFuncInfo(singleWaveResLoaded,[needBackLoadRes]);
			BattleResourceCopy.analyseResToLoad(ResLoadCompleteAgent.executeFunc);
			GameResourceManager.startLoad(ResLoadCompleteAgent.onResLoadCompleteCall,GameResourceManager.simplyBack,needBackLoadRes);
		}
		
		/**
		 * 单个wave的资源加载完成 
		 * @param param
		 */
		private static function singleWaveResLoaded(resArr:Array = null):void
		{
			var singleTroop:CellTroopInfo;
			var allDefTroops:Array = BattleUnitPool.getTroopsOfSomeSide(BattleDefine.secondAtk);
			for each(singleTroop in allDefTroops)
			{
				if(singleTroop && (singleTroop.troopPlayerId == "" || singleTroop.troopPlayerId == null) && 
					singleTroop.avatarShowObj == null && singleTroop.heroShowObj == null)			//如果此时动画没有加到troop中
				{
					TroopDisplayFunc.initShowInfo(singleTroop);
				}
			}
			
			var singleEffectId:int = 0;
			//下一波的数据
			if(nextWaveTroopInfo)
			{
				for each(singleTroop in nextWaveTroopInfo)				//初始化信息,如果此资源下载完成了，直接初始化
				{
					if(!singleTroop.troopVisibleOnBattle)
						continue;
					if(singleTroop.isHero)
					{
						singleEffectId = singleTroop.attackUnit.contentHeroInfo.effectid;
						var offsetValue:Point = TroopActConfig.getStartPos(singleEffectId);
						if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi || BattleModeDefine.isDarenFuBen() || BattleModeDefine.isGeneralRaid)
						{
							offsetValue.y -= (singleTroop.cellsCountNeed.y - 1) * (-10 - BattleDisplayDefine.cellGapVertocal);
						}
						singleTroop.startPos = offsetValue;
						
						singleTroop.mcIndex = singleEffectId;
					}
					else
					{
						singleEffectId = singleTroop.attackUnit.contentArmInfo.effectid;
						singleTroop.mcIndex = singleEffectId;
					}
					if(singleEffectId <= 0)
						continue;
					if(singleTroop.isHero)
					{
						if(ResourcePool.hasSomeResById(singleEffectId))
						{
							var fakeEvent:Event;
							var needYpInfo:Boolean = false;
							var ypResInfo:int = singleEffectId * ResourceConfig.swfIdMapValue;
							if(ResourceConfig.getSingleResConfigById(ypResInfo) != null)
							{
								needYpInfo = true;
							}
							if(needYpInfo)
							{
								if(ResourcePool.getSourceByteArr(ypResInfo) != null || BattleResourceCopy.hasParticlarAnimator(ypResInfo))
								{
									fakeEvent = new Event(ypResInfo.toString(),false,false);			//假的完成效果
									singleTroop.singleBackLoadAnimatorLoaded(fakeEvent);
									continue;
								}
								else
								{
									GameResourceManager.eventHandler.addEventListener(ypResInfo.toString(),singleTroop.singleBackLoadAnimatorLoaded);
								}
							}
							else
							{
								fakeEvent = new Event(ypResInfo.toString(),false,false);			//假的完成效果
								singleTroop.singleBackLoadAnimatorLoaded(fakeEvent);
								continue;
							}
							fakeEvent = new Event(singleEffectId.toString(),false,false);			//假的完成效果
							singleTroop.singleBackLoadAnimatorLoaded(fakeEvent);
						}
						else
						{
							GameResourceManager.eventHandler.addEventListener(singleEffectId.toString(),singleTroop.singleBackLoadAnimatorLoaded);
							GameResourceManager.eventHandler.addEventListener((singleEffectId * ResourceConfig.swfIdMapValue).toString(),singleTroop.singleBackLoadAnimatorLoaded);
						}
					}
					else
					{
						if(ResourcePool.hasSomeResById(singleEffectId))
						{
							fakeEvent = new Event(singleEffectId.toString(),false,false);			//假的完成效果
							singleTroop.singleBackLoadAnimatorLoaded(fakeEvent);
//							TroopDisplayFunc.initShowInfo(singleTroop);
						}
						else
						{
							GameResourceManager.eventHandler.addEventListener(singleEffectId.toString(),singleTroop.singleBackLoadAnimatorLoaded);
						}
					}
				}
			}
				
			initLeftPortrait(false);
			
			BattleManager.instance.portraitGroupDef.targetPowerside = BattleManager.instance.pSideDef;
			
			BattleManager.instance.startNextWave();
			
			if(resArr)
			{
				var curResArr:Array = resArr[0] as Array;
				if(curResArr)
				{
					for each(var singleResId:int in curResArr)
					{
						GameResourceManager.addResToBackLoadById(singleResId);
					}
				}
				
				GameResourceManager.startBackLoad();
			}
		}
		
		/**
		 * 获得空闲cell 
		 * @param index
		 * @return 
		 */
		private static function getFreeCell(index:int):Cell
		{
			var curCell:Cell = getCellInfo(index);
			if(curCell == null)
			{
				curCell = new Cell(index);
				cellPool[index] = curCell;
			}
			return curCell;
		}
		
		/**
		 * 获得空闲cellTroop
		 * @param index
		 * @return 
		 */
		public static function getFreeTroop(index:int):CellTroopInfo
		{
			var retTroopInfo:CellTroopInfo = getTroopInfo(index);
			if(retTroopInfo == null)
			{
				retTroopInfo = TroopPool.getFreeTroop(index);
				troopPool[index] = retTroopInfo;
			}
			retTroopInfo.alpha = 1.0;
			retTroopInfo.visible = true;
			return retTroopInfo;
		}
		
		/**
		 * 获得空闲cellTroop,为下波使用
		 * @param index
		 * @return 
		 */
		private static function getNextWaveFreeTroop(index:int):CellTroopInfo
		{
			var retTroopInfo:CellTroopInfo = getNextWaveTroopInfo(index);
			if(retTroopInfo == null)
			{
				retTroopInfo = TroopPool.getFreeTroop(index);
				nextWaveTroopPoolInfo[index] = retTroopInfo;
			}
			retTroopInfo.alpha = 1.0;
			retTroopInfo.visible = true;
			return retTroopInfo;
		}
		
		/**
		 * 取得某个cell 
		 * @return 
		 */
		public static function getCellInfo(index:int):Cell
		{
			return cellPool[index] as Cell;
		}
		
		/**
		 * 获得某个index的troop信息 
		 * @param index
		 * @return 
		 * 
		 */
		public static function getTroopInfo(index:int):CellTroopInfo
		{
			return troopPool[index] as CellTroopInfo;
		}
		
		/**
		 * 获得防守方的一个troop 
		 * @return 
		 */
		public static function getCellFromSomeSide(side:int):CellTroopInfo
		{
			var retTroop:CellTroopInfo;
			for(var key:String in troopPool)
			{
				var singleTroopInfo:CellTroopInfo = troopPool[key] as CellTroopInfo;
				if(singleTroopInfo && side == singleTroopInfo.ownerSide)
				{
					retTroop = singleTroopInfo;
					break;
				}
			}
			return retTroop;
		}
		
		/**
		 *  获得某个index的troop信息 
		 * @param index
		 * @return 
		 * 
		 */
		public static function getNextWaveTroopInfo(index:int):CellTroopInfo
		{
			return nextWaveTroopPoolInfo[index] as CellTroopInfo;
		}
		
		/**
		 * 获得所有的troop信息 
		 * @return 
		 */
		public static function getAllTroops():Array
		{
			var resValue:Array=[];
			for(var key:String in troopPool)
			{
				var singleTroopInfo:CellTroopInfo = troopPool[key] as CellTroopInfo;
				if(singleTroopInfo)
					resValue.push(singleTroopInfo);
			}
			return resValue;
		}
		
		/**
		 * 获得所有下波数据信息
		 * @return 
		 */
		public static function getNextWaveTroops():Array
		{
			var resValue:Array=[];
			for(var key:String in nextWaveTroopPoolInfo)
			{
				var singleTroopInfo:CellTroopInfo = nextWaveTroopPoolInfo[key] as CellTroopInfo;
				if(singleTroopInfo)
					resValue.push(singleTroopInfo);
			}
			return resValue;
		}
		
		/**
		 * 获得某一方的所有troop 
		 * @param side
		 */
		public static function getTroopsOfSomeSide(side:int):Array
		{
			var resValue:Array=[];
			for(var key:String in troopPool)
			{
				var singleTroopInfo:CellTroopInfo = troopPool[key] as CellTroopInfo;
				if(singleTroopInfo && side == singleTroopInfo.ownerSide)
					resValue.push(singleTroopInfo);
			}
			return resValue;
		}
		
		/**
		 * 获得本方所有的troop信息，并且属于owner 
		 * @param side
		 * @return 
		 */
		public static function getTroopsOsSomeSideOfOwner(side:int):Array
		{
			var resValue:Array=[];
			for(var key:String in troopPool)
			{
				var singleTroopInfo:CellTroopInfo = troopPool[key] as CellTroopInfo;
				if(singleTroopInfo && side == singleTroopInfo.ownerSide)
				{
					if(singleTroopInfo.isHero && singleTroopInfo.attackUnit.contentHeroInfo.uid == GlobalData.owner.uid)
					{
						resValue.push(singleTroopInfo);
					}
					else if(!singleTroopInfo.isHero && singleTroopInfo.attackUnit.contentArmInfo.uid == GlobalData.owner.uid)
					{
						resValue.push(singleTroopInfo);
					}
				}
			}
			return resValue;
		}
		
		/**
		 * 获得所有的cell 
		 * @return 
		 */
		public static function getAllCells():Array
		{
			var resValue:Array=[];
			for(var key:String in cellPool)
			{
				var singleCell:Cell = cellPool[key] as Cell;
				if(singleCell)
					resValue.push(singleCell);
			}
			return resValue;
		}
		
		/**
		 *  某一方的所有cell集合
		 * @param owerSide
		 * @return 
		 */
		public static function getCellsOfSomeSide(owerSide:int):Array
		{
			var leftCount:int = BattleFunc.getPowerSideCellCount();
			var rightCount:int = leftCount + BattleFunc.getPowerSideCellCount(false);
			
			var startIndex:int = 0;
			var maxIndex:int = leftCount;
			
			if(owerSide == BattleDefine.firstAtk)
			{
				startIndex = 0;
				maxIndex = leftCount;
			}
			else
			{
				startIndex = leftCount;
				maxIndex = rightCount;
			}
			
			var resValue:Array=[];
			for(var key:String in cellPool)
			{
				var singleCell:Cell = cellPool[key] as Cell;
				if(singleCell)
				{
					if(singleCell.index >= startIndex && singleCell.index < maxIndex)
						resValue.push(singleCell);
				}
			}
			return resValue;
		}
		
		public static function clearInfo():void
		{
			var key:String; 
			var singleTroop:CellTroopInfo;
			for(key in troopPool)
			{
				singleTroop = troopPool[key];
				if(singleTroop) 
				{
					TroopInitClearFunc.clearTroopInfo(singleTroop,true);
					singleTroop.attackUnit = null;
					singleTroop = null;
				}
			}
			troopPool ={};
			
			for(key in nextWaveTroopPoolInfo)
			{
				singleTroop = nextWaveTroopPoolInfo[key];
				if(singleTroop) 
				{
					TroopInitClearFunc.clearTroopInfo(singleTroop,true);
					singleTroop.attackUnit = null;
					singleTroop = null;
				}
			}
			_nextWaveTroopPoolInfo ={};
			
			var singleCell:Cell;
			for(key in cellPool)
			{
				singleCell = cellPool[key];
				if(singleCell) 
				{
					TroopInitClearFunc.clearCellInfo(singleCell);
					singleCell = null;
				}
			}
			cellPool ={};
			
			if(nextWaveTroopInfo)
			{
				for(var i:int = 0; i < nextWaveTroopInfo.length; i++)
				{
					singleTroop = nextWaveTroopInfo[i] as CellTroopInfo;
					TroopInitClearFunc.clearTroopInfo(singleTroop,true);
					singleTroop = null;
				}
				nextWaveTroopInfo = [];
			}
			allBaseArmOnBattle ={};
		}
		
		/**
		 * 清空单个power上的troop和cell信息
		 * @param owenrSide
		 */
		public static function clearSinglePowerSide(owenrSide:int):void
		{
			var key:String;
			for(key in troopPool)
			{
				var singleTroopInfo:CellTroopInfo = troopPool[key] as CellTroopInfo;
				if(singleTroopInfo && owenrSide == singleTroopInfo.ownerSide)
				{
					TroopInitClearFunc.clearTroopInfo(singleTroopInfo,false);
					singleTroopInfo.attackUnit = null;
					singleTroopInfo = null;
					troopPool[key] = null;
				}
			}
			
			var leftCount:int = BattleFunc.getPowerSideCellCount();
			var rightCount:int = leftCount + BattleFunc.getPowerSideCellCount(false);
			
			var startIndex:int = 0;
			var maxIndex:int = leftCount;
			
			if(owenrSide == BattleDefine.firstAtk)
			{
				startIndex = 0;
				maxIndex = leftCount;
			}
			else
			{
				startIndex = leftCount;
				maxIndex = rightCount;
			}
			for(key in cellPool)
			{
				var singleCell:Cell = cellPool[key] as Cell;
				if(singleCell)
				{
					if(singleCell.index >= startIndex && singleCell.index < maxIndex)
					{
						TroopInitClearFunc.clearCellInfo(singleCell);
						cellPool[key] = null;
					}
				}
			}
		}
		
		private static function addTempBattleResource():void
		{
			GameResourceManager.addResToLoadById(BattleInfoSnap.battleBackgroundId);
			
//			1408
			
//			for(var i:int = 0;i < tempResources.length;i++)			//手动增加计数，防止被release掉
//			{
//				ResourcePool.getResById(tempResources[i]);
//			}
			GameResourceManager.addResIdArr(tempResources);
			
			if(BattleModeDefine.checkNeedConsiderWave())
			{
				//波数
				GameResourceManager.addResToLoadById(2325);
				GameResourceManager.addResToLoadById(1412);
				GameResourceManager.addResToLoadById(1427);
			}
		}

		/**
		 * 保存下波敌人用到的troop 
		 */
		public static function get nextWaveTroopPoolInfo():Object
		{
			return _nextWaveTroopPoolInfo;
		}

		public static function getTroopFromSomeUser(uid:int):int
		{
			var alltroop:Array = getTroopsOfSomeSide(BattleDefine.firstAtk);
			for(var i:int = 0; i < alltroop.length;i++)
			{
				var singleTroop:CellTroopInfo = alltroop[i] as CellTroopInfo;
				if(singleTroop && singleTroop.logicStatus != LogicSatusDefine.lg_status_dead && !singleTroop.isHero && singleTroop.attackUnit.contentArmInfo.uid == uid)
				{
					return singleTroop.troopIndex;
				}
			}
			return 0;
		}
		
		/**
		 * 根据heroid uid 获得英雄信息 
		 * @param heroId
		 * @param uid
		 * @return 
		 */
		public static function getUserHeroByHidUid(heroId:int,uid:int):UserHeroInfo
		{
			var retValue:UserHeroInfo;
			
			var alltroop:Array = BattleUnitPool.getAllTroops();
			
			for(var i:int = 0; i < alltroop.length;i++)
			{
				var singleTroop:CellTroopInfo = alltroop[i] as CellTroopInfo;
				if(singleTroop && singleTroop.isHero)
				{
					if(singleTroop.attackUnit.contentHeroInfo.uid == uid && singleTroop.attackUnit.contentHeroInfo.heroid == heroId)
					{
						retValue = singleTroop.attackUnit.contentHeroInfo;
						break;
					}
				}
			}
			return retValue;
		}
		
		private static function initLeftPortrait(isLeft:Boolean = false):void
		{
			if(isLeft)
			{
				if(BattleManager.instance.portraitGroupAtk == null)
				{
					BattleManager.instance.portraitGroupAtk = new HeroPortraitGroup();
					BattleManager.instance.portraitGroupAtk.x = BattleDisplayDefine.leftPortraitPos - BattleStage.instance.shakeLayer.x;
					BattleManager.instance.portraitGroupAtk.y = 0 - BattleStage.instance.shakeLayer.y;
					BattleStage.instance.troopLayer.addChild(BattleManager.instance.portraitGroupAtk);
				}
			}
			else
			{
				if(BattleManager.instance.portraitGroupDef == null)
				{
					BattleManager.instance.portraitGroupDef = new HeroPortraitGroup();
					BattleManager.instance.portraitGroupDef.x = GameSizeDefine.viewwidth + 20;
					BattleManager.instance.portraitGroupDef.y = 0 - BattleStage.instance.shakeLayer.y;
					BattleStage.instance.troopLayer.addChild(BattleManager.instance.portraitGroupDef);
				}
			}
		}
		
	}
}