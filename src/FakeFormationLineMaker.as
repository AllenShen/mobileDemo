package
{
	import flash.geom.Point;
	
	import defines.FormationSlotInfo;
	import defines.UserArmInfo;
	import defines.UserHeroInfo;
	
	import macro.ArmType;
	import macro.DamageType;
	import macro.FormationElementType;
	
	import modules.battle.battlecomponent.NextSupplyShow;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battlelogic.AttackUnit;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.managers.BattleUnitPool;
	import modules.battle.managers.DemoManager;
	
	import synchronousLoader.ResourceConfig;
	
	import utils.TroopActConfig;

	public class FakeFormationLineMaker
	{
		
		private static var allDamageTypes:Array = [1,2];
		private static var allArmTypes:Array = [1,2,3,4];			//近戰，弓箭  法師   機械
		
//		private static var allWuliResIds:Array = [5001,5002,5003,5004,5005,5006,5007,5008,5009,5010,5012,5013,5014,5015,5016,5017,5018,5020,5021,5022,5023,5024,5025];
//		private static var allGongJianResId:Array = [5401,5402,5403,5404,5405,5406,5407,5408,5409,5410,5411,5412,5413,5415,5416,5417,5418,5419];
//		private static var allFashiResId:Array = [5801,5802,5803,5804,5805,5806,5807,5808,5809,5810,5811,5812,5813,5814,5815];
		
		private static var allWuliResIds:Array = [5013];
		private static var allWuliResIds2:Array = [5022];
		private static var allGongJianResId:Array = [1001];
		private static var allGongJianResId2:Array = [1017];
		private static var allFashiResId:Array = [1010];
		private static var allGongJianResId3:Array = [5408];
		private static var allWuliResIds4:Array = [1015];
		private static var allWuliResIds5:Array = [1002];
		
		private static var allBigFootResId:Array = [6225];
		private static var allBigFootResId2:Array = [6227];
		
		private static var allBigBossResId:Array = [5032];
		
		public static var allheroResIds:Array = [1309,1305,1306];
		
		public static var battleCardResIds:Array = [7014,7010,7020,7001,7013];
		
		public static var curUsedTsag:int = 0;
		
		public function FakeFormationLineMaker()
		{
			
		}
		
		private static function getDamageTypeByArmType(armType:int):int
		{
			var retType:int = 0;
			
			switch(armType)
			{
				case ArmType.footman:
				case ArmType.archer:
				case ArmType.machine:
					retType = DamageType.Physical;
					break;
				case ArmType.magic:
					retType = DamageType.Magic;
					break;
			}
			
			return retType;
		}
		
		public static function makeFakeSupplyTroop(owenrSide:int,armType:int,resId:int,supplyType:int,needForce:Boolean = false):CellTroopInfo
		{
			var retInfo:CellTroopInfo = BattleUnitPool.getFreeTroop(CellTroopInfo.globalTroopIndex++);
			
			BattleUnitPool.troopPool[retInfo.troopIndex] = retInfo;
			
			var singleArmInfo:UserArmInfo;
			if(owenrSide == BattleDefine.firstAtk)
			{
				if(NextSupplyShow.instance.supplyHeroOrArm == 0 || needForce)
				{
					singleArmInfo = UserArmInfo.getFakeArmInfo(getDamageTypeByArmType(armType),armType,
						resId,owenrSide,supplyType);
				}
				else
				{
					//补进英雄信息
					trace("英雄补进信息");
					return null;
				}
			}
			else
			{
				var curSupplyType:int = DemoManager.getNextEnemySupplyType();
//				var randomValue:Number = Math.random();
//				if(randomValue < 0.5)
//					curSupplyType = NextSupplyShow.supply_SimpleFoot;
//				else if(randomValue < 0.80)
//					curSupplyType = NextSupplyShow.supply_SimpleArcher;
//				else
//					curSupplyType = NextSupplyShow.supply_SimpleMagic;
				
				
				var supplyArmType:int = NextSupplyShow.gettargetArmTypeByEnemySupplyType(curSupplyType);
				var supplyeArmResId:int = DemoManager.getSingleRandomIdByEnemyType(curSupplyType);
				
				singleArmInfo = UserArmInfo.getFakeArmInfo(getDamageTypeByArmType(supplyArmType),supplyArmType,supplyeArmResId,owenrSide,curSupplyType);
			}
			
			var tempFormationSlotInfo:FormationSlotInfo = new FormationSlotInfo();
			tempFormationSlotInfo.info = singleArmInfo;
			tempFormationSlotInfo.type = FormationElementType.ARM;
			tempFormationSlotInfo.curnum = singleArmInfo.currentnum;
			tempFormationSlotInfo.maxnum = tempFormationSlotInfo.curnum;
			
			retInfo.attackUnit = new AttackUnit(tempFormationSlotInfo);
			
			retInfo.cellsCountNeed = new Point(singleArmInfo.width,singleArmInfo.height);
			
			retInfo.curArmCount = retInfo.maxArmCount;			//初始化带兵量
			retInfo.curTroopHp = retInfo.maxTroopHp;				//初始化单个兵的血量
			retInfo.supplyType =  NextSupplyShow.instance.curSupplyType;
			retInfo.ownerSide = owenrSide;
			
			return retInfo;
		}
		
		public static function makeFakeHeroTroop(sourceTroop:CellTroopInfo):void
		{
			var fakeHeroInfo:UserHeroInfo = UserHeroInfo.getFakeHeroInfo();
			var tempFormationInfo:FormationSlotInfo = new FormationSlotInfo();
			tempFormationInfo.type = FormationElementType.HERO;
			tempFormationInfo.info = fakeHeroInfo;
			sourceTroop.attackUnit = new AttackUnit(tempFormationInfo);
		}
		
		public static function getRandomSingleLine(side:int):Array
		{
			var maxArmLines:int = 4;
			var retInfo:Array = [];
			
			var singleFormationSlot:FormationSlotInfo = new FormationSlotInfo();
			
			if(side == BattleDefine.firstAtk)
			{
//				singleFormationSlot.type = FormationElementType.HERO;
				singleFormationSlot.type = FormationElementType.HERO;
//	
//				var singleHeroInfo:UserHeroInfo = new UserHeroInfo;
//				singleHeroInfo.effectid = allheroResIds[int(Math.random() * allheroResIds.length)];
//				DemoManager.addSingleHeroId(singleHeroInfo.effectid);
//				singleHeroInfo.userheroid = 1 + Math.random() * 10;
//				singleFormationSlot.info = singleHeroInfo;	
			}
			else
			{
				singleFormationSlot.type = FormationElementType.HERO;
				
				var singleHeroInfo:UserHeroInfo = new UserHeroInfo;
//				singleHeroInfo.effectid = allheroResIds[curUsedTsag++ % allheroResIds.length];
				singleHeroInfo.effectid = 0;
				
				DemoManager.addSingleHeroId(singleHeroInfo.effectid);
				singleHeroInfo.userheroid = 1 + Math.random() * 10;
				singleFormationSlot.info = singleHeroInfo;	
			}
			
			retInfo.push(singleFormationSlot);
			
			var i:int = 0;
			var curLineCount:int = 1 + maxArmLines * Math.random();
			if(side == 1)
				curLineCount = maxArmLines;
			
//			for(var i:int = 0;i < curLineCount;i++)
//			{
//				singleFormationSlot = new FormationSlotInfo();
//				singleFormationSlot.type = FormationElementType.ARM;
//				
//				var singleType:int = NextSupplyShow.allSupplyTypes[int(NextSupplyShow.allSupplyTypes.length * Math.random())];
//				
//				for(var ii:int = 0;ii < NextSupplyShow.allSupplyTypes.length;ii++)
//				{
//					var tempType:int = NextSupplyShow.allSupplyTypes[ii];
//					if(!BattleInfoSnap.usedSupplyTypes[tempType])
//					{
//						singleType = tempType;
//						BattleInfoSnap.usedSupplyTypes[tempType] = 1;
//						break;
//					}
//				}
//				
//				var armtype:int = NextSupplyShow.gettargetArmTypeBySupplytype(singleType);
//				var damageType:int = getDamageTypeByArmType(armtype);
//				
//				var effectId:int = 0; 
//				if(singleType == NextSupplyShow.supply_SimpleFoot)
//				{
//					effectId = allWuliResIds[int(Math.random() * allWuliResIds.length)];
//				}
//				else if(singleType == NextSupplyShow.supply_SimpleArcher)
//				{
//					effectId = allGongJianResId[int(Math.random() * allGongJianResId.length)];
//				}
//				else if(singleType == NextSupplyShow.supply_SimpleMagic)
//				{
//					effectId = allFashiResId[int(Math.random() * allFashiResId.length)];
//				}
//				else 
//				{
//					effectId = allBigFootResId[int(Math.random() * allBigFootResId.length)];
//				}
//			
//				var singleArmInfo:UserArmInfo = UserArmInfo.getFakeArmInfo(damageType,armtype,effectId);
//				DemoManager.addSingleArmId(singleType,effectId);
//				
//				singleFormationSlot.info = singleArmInfo;
//				singleFormationSlot.curnum = singleArmInfo.currentnum;
//				singleFormationSlot.supplyType = singleType; 
//				
//				retInfo.push(singleFormationSlot);
//			}
			
			curLineCount = 0;
			
			for(i = curLineCount;i < maxArmLines;i++)
			{
				singleFormationSlot = new FormationSlotInfo();
				singleFormationSlot.type = FormationElementType.NOTHING;
				
				retInfo.push(singleFormationSlot);
			}
			
			return retInfo;
		}
		
		public static function getAllResNeed():Array
		{
			var retInfo:Array = [];
			var allIds:Array = allWuliResIds.concat(allGongJianResId).concat(allFashiResId).concat(allWuliResIds2).concat(allGongJianResId2).concat(allGongJianResId3)
				.concat(allBigFootResId).concat(allWuliResIds4).concat(allBigBossResId).concat(allWuliResIds5).concat(allBigFootResId2);
			var resIds:Array = [];
			for(var i:int = 0;i < allIds.length;i++)
			{
				var singleRes:int = allIds[i];
				retInfo = retInfo.concat(TroopActConfig.getAllEffectNeed(singleRes));
				retInfo.push(singleRes);
			}

			for(i = 0; i< allheroResIds.length;i++)
			{
				singleRes = allheroResIds[i];
				retInfo.push(singleRes);
				retInfo.push(singleRes * ResourceConfig.swfIdMapValue);
				retInfo = retInfo.concat(TroopActConfig.getAllEffectNeed(singleRes));
			}
			
			for(i = 0;i < battleCardResIds.length;i++)
			{
				retInfo.push(battleCardResIds[i] * 100);
			}
			
			DemoManager.usedArmIds[NextSupplyShow.supply_SimpleFoot] = allWuliResIds;
			DemoManager.usedArmIds[NextSupplyShow.supply_SimpleFoot2] = allWuliResIds2;
			DemoManager.usedArmIds[NextSupplyShow.supply_SimpleArcher3] = allGongJianResId3;
			DemoManager.usedArmIds[NextSupplyShow.supply_SimpleFoot4] = allWuliResIds4;
			DemoManager.usedArmIds[NextSupplyShow.supply_SimpleFoot5] = allWuliResIds5;
			
			DemoManager.usedArmIds[NextSupplyShow.supply_SimpleArcher] = allGongJianResId;
			DemoManager.usedArmIds[NextSupplyShow.supply_SimpleArcher2] = allGongJianResId2;
			DemoManager.usedArmIds[NextSupplyShow.supply_SimpleMagic] = allFashiResId;
			
			DemoManager.usedArmIds[NextSupplyShow.supply_BigFoot] = allBigFootResId;
			DemoManager.usedArmIds[NextSupplyShow.supply_BigFoot2] = allBigFootResId2;
			
			DemoManager.enemyUsedArmIds[NextSupplyShow.enemySupplyType_foot1] = allWuliResIds;
			DemoManager.enemyUsedArmIds[NextSupplyShow.enemySupplyType_foot2] = allWuliResIds2;
			DemoManager.enemyUsedArmIds[NextSupplyShow.enemySupplyType_arch1] = allGongJianResId;
			DemoManager.enemyUsedArmIds[NextSupplyShow.enemySupplyType_arch2] = allGongJianResId2;
			DemoManager.enemyUsedArmIds[NextSupplyShow.enemySupplyType_magic1] = allFashiResId;
			DemoManager.enemyUsedArmIds[NextSupplyShow.enemySupplyType_machine1] = allBigFootResId;
			DemoManager.enemyUsedArmIds[NextSupplyShow.enemySupplyType_Boss] = allBigBossResId;
			
			DemoManager.usedHeroIds = allheroResIds;
			
			return retInfo;
		}
	}
}