package modules.battle.battlecomponent
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import animator.animatorengine.AnimatorEngine;
	
	import defines.UserBattleCardInfo;
	
	import fl.controls.Button;
	
	import macro.ArmType;
	import macro.BattleCardTypeDefine;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battlelogic.SingleRound;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.DemoManager;
	
	import synchronousLoader.ResourceConfig;
	import synchronousLoader.ResourcePool;

	public class NextSupplyShow extends Sprite
	{
		
		public static var starSupplyTypeNone:int = 1;
		public static var starSupplyTypeDamage:int = 2;
		public static var starSupplyTypeHP:int = 3;
		
		/*supply类型*/
		public static var supply_SimpleFoot:int = 1;
		public static var supply_SimpleFoot2:int = 2;
		public static var supply_SimpleFoot4:int = 3;
		public static var supply_SimpleFoot5:int = 4;
		
		public static var supply_SimpleArcher3:int = 5;
		public static var supply_SimpleArcher:int = 6;
		public static var supply_SimpleArcher2:int = 7;
		
		public static var supply_SimpleMagic:int = 8;
		
		public static var supply_BigFoot:int = 9;
		public static var supply_BigFoot2:int = 10;
		
		public static var allSupplyTypes:Array = [supply_SimpleFoot,supply_SimpleArcher,supply_SimpleMagic,supply_SimpleFoot2,supply_SimpleArcher2,supply_SimpleArcher3,supply_BigFoot,
			supply_BigFoot2,supply_SimpleFoot4,supply_SimpleFoot5];
		
		public static const enemySupplyType_foot1:int = 1;
		public static const enemySupplyType_foot2:int = 2;
		public static const enemySupplyType_arch1:int = 3;
		public static const enemySupplyType_arch2:int = 4;
		public static const enemySupplyType_magic1:int = 6;
		public static const enemySupplyType_machine1:int = 8;
		public static const enemySupplyType_Boss:int = 9;
		
		public static const allCombatStages:Array = [0,1,2,3];
		public static const combagtStageCount:Array = [12,20,15,1];
		public static const combatStageSupplyDefine:Array = [[enemySupplyType_foot1,enemySupplyType_arch1],
															[enemySupplyType_magic1,enemySupplyType_foot2,enemySupplyType_arch2,enemySupplyType_foot1,enemySupplyType_foot2],
															[enemySupplyType_magic1,enemySupplyType_foot2,enemySupplyType_arch2,enemySupplyType_foot2,enemySupplyType_machine1],
															[enemySupplyType_Boss]];
		
		public var supplyCardId:UserBattleCardInfo;
		
		public var supplyHeroOrArm:int = 0;
		public var curSupplyType:int = 0;
		public var supplyeArmResId:int = -1;
		public var starsCount:int = 1;
		public var supplyArmType:int = 1;
		public var addedDamage:int = 0;
		public var addedHP:int = 0;
		
		private var curPlayer:String = "";
		private var battleCardShow:Bitmap;
		public var genedBattleCardInfo:UserBattleCardInfo;
		
		private static var _instance:NextSupplyShow;
		
		public var starShow:SupplyStarShow;
		public var cancelBtn:Button;
		
		public static function get instance():NextSupplyShow
		{
			if(_instance == null)
				_instance = new NextSupplyShow();
			return _instance;
		}
		
		public function NextSupplyShow()
		{
			starShow = new SupplyStarShow();
			this.addChild(starShow);
			starShow.x = 20;
			starShow.y = 30;
			
			battleCardShow = new Bitmap();
			this.addChild(battleCardShow);
			battleCardShow.x = -200;
			battleCardShow.y = 20;
			
			cancelBtn = new Button();
			cancelBtn.x = 175;
			cancelBtn.y = 30;
			this.addChild(cancelBtn);
			cancelBtn.addEventListener(MouseEvent.CLICK,onCancelBtnClick);
			cancelBtn.width = 100;
			cancelBtn.height = 50;
			cancelBtn.visible = false;
			cancelBtn.label = "取消";
		}
		
		public static function gettargetArmTypeBySupplytype(supplyType:int):int
		{
			var retType:int = 0;
			switch(supplyType)
			{
				case supply_SimpleFoot:
				case supply_SimpleFoot2:
				case supply_SimpleFoot4:
				case supply_SimpleFoot5:
					retType = ArmType.footman;
					break;
				case supply_SimpleArcher:
				case supply_SimpleArcher2:
				case supply_SimpleArcher3:
					retType = ArmType.archer;
					break;
				case supply_SimpleMagic:
					retType = ArmType.magic;
					break;
				case supply_BigFoot:
				case supply_BigFoot2:
					retType = ArmType.machine;
					break;
			}
			return retType;
		}
		
		public static function gettargetArmTypeByEnemySupplyType(enemySupplyType:int):int
		{
			var retType:int = 0;
			switch(enemySupplyType)
			{
				case enemySupplyType_foot1:
				case enemySupplyType_foot2:
					retType = ArmType.footman;
					break;
				case enemySupplyType_arch1:
				case enemySupplyType_arch2:
					retType = ArmType.archer;
					break;
				case enemySupplyType_magic1:
					retType = ArmType.magic;
					break;
				case enemySupplyType_machine1:
					retType = ArmType.machine;
					break;
				case enemySupplyType_Boss:
					retType = ArmType.footman;
					break;
			}
			return retType;
		}
		
		public static function getStarCountNeed(supplyType:int):int
		{
			var retCount:int = 0;
			switch(supplyType)
			{
				case supply_SimpleFoot:
				case supply_SimpleFoot2:
				case supply_SimpleArcher3:
				case supply_SimpleFoot5:
					retCount = 1;
					break;
				case supply_SimpleArcher:
				case supply_SimpleArcher2:
				case supply_SimpleFoot4:
				case supply_SimpleMagic:
					retCount = 2;
					break;
				case supply_BigFoot:
					retCount = 3;
					break;
				case supply_BigFoot2:
					retCount = 4;
					break;
			}
			return retCount;
		}
		
		public static function getStarCountOfHero(effectId:int):int
		{
			var retCount:int = 0;
			switch(effectId)
			{
				case 1305:
					retCount = 3;
					break;
				case 1306:
					retCount = 4;
					break;
				case 1309:
					retCount = 5;
					break;
			}
			return retCount;
		}
		
		public function showSingleSupplyInfo():void
		{
			battleCardShow.bitmapData = null;
			genedBattleCardInfo = null;
			if(SingleRound.roungIndex-1 <= BattleDefine.fakeRoundsAtBeginning)
			{
				supplyHeroOrArm = 0;
			}
			else
			{
				var randomValue:Number = Math.random();
				if(randomValue < BattleDefine.callHeroPossibility && BattleInfoSnap.heroCalledCount < 3)
				{
					supplyHeroOrArm = 1;
				}
				else if(randomValue < (BattleDefine.callHeroPossibility + BattleDefine.callCardPossibility) && SingleRound.roungIndex-1 > 5)
				{
					supplyHeroOrArm = 2;
				}
				else 
				{
					supplyHeroOrArm = 0;
				}
			}
			
			var index:int;
			
			if(supplyHeroOrArm == 0)
			{
				var targetStarCount:int = 1;
				starsCount = -1;
				while((starsCount < targetStarCount && targetStarCount > 0) || starsCount < 0)					//只补进2星兵
				{
					index = int(allSupplyTypes.length * Math.random());
					curSupplyType = allSupplyTypes[index]; 
					
					starsCount = NextSupplyShow.getStarCountNeed(curSupplyType);
				}
								
				if(SingleRound.roungIndex-1 <= BattleDefine.fakeRoundsAtBeginning)
				{
					while(starsCount > BattleDefine.initialEnterArmStar)
					{
						index = int(allSupplyTypes.length * Math.random());
						curSupplyType = allSupplyTypes[index]; 
						starsCount = NextSupplyShow.getStarCountNeed(curSupplyType);
					}
				}
				
				supplyArmType = gettargetArmTypeBySupplytype(curSupplyType);
				supplyeArmResId = DemoManager.getSingleRandomId(curSupplyType);
				
				if(Math.random() <= BattleDefine.geneCardPossibility)
				{
					genedBattleCardInfo = UserBattleCardInfo.makeOneFakeCardInfo();
					battleCardShow.bitmapData = ResourcePool.getBitmapDataById(genedBattleCardInfo.cardeffectid * 100);
				}
				
			}
			else if(supplyHeroOrArm == 2)			//生成卡牌
			{
				supplyCardId = UserBattleCardInfo.makeOneFakeCardInfo();
				while(supplyCardId == null || supplyCardId.cardtype == BattleCardTypeDefine.budian)
				{
					supplyCardId = UserBattleCardInfo.makeOneFakeCardInfo();
					supplyCardId.usercardid = 1;
				}
				starsCount = 2;
			}
			else							//补进英雄
			{
				supplyeArmResId = FakeFormationLineMaker.allheroResIds[(FakeFormationLineMaker.curUsedTsag) % FakeFormationLineMaker.allheroResIds.length];
				starsCount = getStarCountOfHero(supplyeArmResId);
			}
			
			addedDamage = 0;
			addedHP = 0;
			
			updateShowInfo();
		}
		
		public function handlerSingleStarQuilified(type:int,addValue:int,percent:Number,needAdd:Boolean = false):void
		{
			if(needAdd)
			{
				if(type == starSupplyTypeDamage)
					addedDamage += addValue;
				else if(type == starSupplyTypeHP)
					addedHP += addValue;
			}
			starShow.hadnlerNewStarQuilified(type,addValue,percent);
		}
		
		public function getSingleHpSupplyInfo():Array
		{
			var retInfo:Array = [];
			
			var singleStar:SingleSupplyStar;
			for(var i:int = 0;i < starShow.allSingleStars.length;i++)
			{
				singleStar = starShow.allSingleStars[i];
				if(singleStar.curSupplyState != NextSupplyShow.starSupplyTypeHP)
					continue;
				singleStar.curSupplyState = 0;
				retInfo = [NextSupplyShow.starSupplyTypeHP,singleStar.supplyValue];
				break;
			}
			
			return retInfo;
		}
		
		public function get isAllStarQualified():Boolean
		{
			return starShow.isAllStarsQuilified;
		}
		
		private function onCancelBtnClick(event:MouseEvent):void
		{ 
			var totalstartCount:int = NextSupplyShow.instance.starShow.curQuilifiedCount;
			this.supplyHeroOrArm = 0;
			
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
				
				DemoManager.makeNextArmSupply(BattleDefine.firstAtk,supplyArmType,supplyeArmResId,curSupplyType,false);
			}
			
			showSingleSupplyInfo();
		}
		
		public function updateShowInfo():void
		{
			clearShowInfo();
			
			if(supplyHeroOrArm == 0)
			{
				curPlayer = AnimatorEngine.addPlayer(this,ResourceConfig.getPureUrlById(supplyeArmResId),-100,0,0,-1,true);
				cancelBtn.visible = false;
				if(starsCount >= 4)
					cancelBtn.visible = true;
			}
			else if(supplyHeroOrArm == 2)
			{
//				AnimatorEngine.setPlayerMirror(curPlayer,true);
				battleCardShow.bitmapData = ResourcePool.getBitmapDataById(supplyCardId.cardeffectid * 100);
				cancelBtn.visible = false;
			}
			else
			{
				curPlayer = AnimatorEngine.addPlayer(this,ResourceConfig.getPureUrlById(supplyeArmResId * ResourceConfig.swfIdMapValue),-130,0,0,-1,true);
				cancelBtn.visible = true;
//				AnimatorEngine.setPlayerMirror(curPlayer,true);
			}
			
			this.scaleX = 0.7;
			this.scaleY = 0.7;
			
			starShow.initStars(starsCount);
		}
		
		public function clearShowInfo():void
		{
			if(curPlayer != null &&  curPlayer != "")
			{
				AnimatorEngine.removePlayer(curPlayer);
			}
			
			starShow.clearInfo();
		}
		
		public function clearInfo():void
		{
			clearShowInfo();
			addedDamage = 0;
			addedHP = 0;
		}
		
	}
}