package
{
	import flash.display.Sprite;
	
	import fl.controls.Label;
	import fl.controls.TextInput;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.managers.BattleInfoSnap;

	public class BattleParamConfig extends Sprite
	{
		private static var _instance:BattleParamConfig;
		
		
		private var cardAddLabel:Label = new Label;
		private var cardAddNum:TextInput = new TextInput;
		
		private var selfSupplyStarLabel:Label = new Label;
		private var selfSupplyStarLabelValue:TextInput = new TextInput;
		
		private var selfSupplyStarCount:Label = new Label;
		private var selfSupplyStarCountValue:TextInput = new TextInput;
		
		private var heroCallProperity:Label = new Label;
		private var heroCallProperity2:TextInput = new TextInput;
		
		private var enemySupplyRoundSpeed:Label = new Label;
		private var enemySupplyRoundSpeedValue:TextInput = new TextInput;
		
		private var enemySupplyRoundSpeed2:Label = new Label;
		private var enemySupplyRoundSpeedValue2:TextInput = new TextInput;
		
		private var enemySupplyCount:Label = new Label;
		private var enemySupplyCountValue:TextInput = new TextInput;
		
		private var cardGeneTag:Label = new Label;
		private var cardGeneProbValue:TextInput = new TextInput();
		
		public static function get instance():BattleParamConfig
		{
			if(_instance == null)
			{
				_instance = new BattleParamConfig();
			}
			return _instance;
		}
		
		public function BattleParamConfig()
		{
			cardAddLabel.text = "开始赠送卡牌";
			this.addChild(cardAddLabel);
			cardAddLabel.x = 10;
			cardAddLabel.y = 10;
			
			this.addChild(cardAddNum);
			cardAddNum.x = 100;
			cardAddNum.y = 10;
			cardAddNum.width = 50;
			
			selfSupplyStarLabel.text = "我方点数补充所需回合数";
			this.addChild(selfSupplyStarLabel);
			selfSupplyStarLabel.x = 200;
			selfSupplyStarLabel.y = 10;
			selfSupplyStarLabel.width = 130;
			
			this.addChild(selfSupplyStarLabelValue);
			selfSupplyStarLabelValue.x = 350;
			selfSupplyStarLabelValue.y = 10;
			selfSupplyStarLabelValue.width = 50;
			
			selfSupplyStarCount.text = "我方所有点数";
			this.addChild(selfSupplyStarCount);
			selfSupplyStarCount.x = 450;
			selfSupplyStarCount.y = 10;
			
			this.addChild(selfSupplyStarCountValue);
			selfSupplyStarCountValue.x = 600;
			selfSupplyStarCountValue.y = 10;
			selfSupplyStarCountValue.width = 50;
			
			heroCallProperity.text = "召唤出英雄的概率";
			this.addChild(heroCallProperity);
			heroCallProperity.x = 700;
			heroCallProperity.y = 10;
			
			this.addChild(heroCallProperity2);
			heroCallProperity2.x = 850;
			heroCallProperity2.y = 10;
			heroCallProperity2.width = 50;
			
			enemySupplyRoundSpeed.text = "第一阶段敌方点数补充速度";
			this.addChild(enemySupplyRoundSpeed);
			enemySupplyRoundSpeed.x = 10;
			enemySupplyRoundSpeed.y = 50;
			enemySupplyRoundSpeed.width = 150;
			
			this.addChild(enemySupplyRoundSpeedValue);
			enemySupplyRoundSpeedValue.x = 150;
			enemySupplyRoundSpeedValue.y = 50;
			enemySupplyRoundSpeedValue.width = 30;
			
			enemySupplyRoundSpeed2.text = "第二三四阶段敌方点数补充速度";
			this.addChild(enemySupplyRoundSpeed2);
			enemySupplyRoundSpeed2.x = 200;
			enemySupplyRoundSpeed2.y = 50;
			enemySupplyRoundSpeed2.width = 170;
			
			this.addChild(enemySupplyRoundSpeedValue2);
			enemySupplyRoundSpeedValue2.x = 380;
			enemySupplyRoundSpeedValue2.y = 50;
			enemySupplyRoundSpeedValue2.width = 50;
			
			enemySupplyCount.text = "敌方所有点数";
			this.addChild(enemySupplyCount);
			enemySupplyCount.x = 450;
			enemySupplyCount.y = 50;
			
			this.addChild(enemySupplyCountValue);
			enemySupplyCountValue.x = 600;
			enemySupplyCountValue.y = 50;
			enemySupplyCountValue.width = 50;
			
			this.addChild(cardGeneTag);
			cardGeneTag.x = 10;
			cardGeneTag.y = 100;
			cardGeneTag.width = 150;
			cardGeneTag.text = "产生卡牌的概率";
			
			this.addChild(cardGeneProbValue);
			cardGeneProbValue.x = 150;
			cardGeneProbValue.y = 100;
			cardGeneProbValue.width = 50;
			
//			for(var i:int = 0;i < NextSupplyShow.allSupplyTypes.length;i++)
//			{
//				var singleType:int = NextSupplyShow.allSupplyTypes[i];
//				var singleArmParamShow:SingleArmParamShow = new SingleArmParamShow();
//				singleArmParamShow.ownerSide = BattleDefine.firstAtk;
//				singleArmParamShow.contentSupplyType = singleType;
//				
//				singleArmParamShow.x = 10;
//				singleArmParamShow.y = 50 * i + 100;
//				
//				this.addChild(singleArmParamShow);
//			}
			
			initBattleParam();
		}
		
		public function initBattleParam():void
		{
			cardAddNum.text = BattleDefine.ranBattleCardGiveCount.toString();
			selfSupplyStarLabelValue.text = BattleDefine.autoStarIncreaseRoundGap.toString();
			selfSupplyStarCountValue.text = BattleInfoSnap.MaxSelfSupplyCount.toString();
			heroCallProperity2.text = BattleDefine.callHeroPossibility.toString();
			
			cardGeneProbValue.text = BattleDefine.geneCardPossibility.toString();
			
			enemySupplyRoundSpeedValue.text = BattleDefine.autoEnemySupplyRoungGap.toString();
			enemySupplyRoundSpeedValue2.text = BattleDefine.autoEnemySupplyRoundGapFast.toString();
			enemySupplyCountValue.text = BattleInfoSnap.MaxEnemySupplyCount.toString();
		}
		
		public function recordConfig():void
		{
			BattleDefine.ranBattleCardGiveCount = int(cardAddNum.text);
			BattleDefine.autoStarIncreaseRoundGap = int(selfSupplyStarLabelValue.text);
			BattleInfoSnap.MaxSelfSupplyCount = int(selfSupplyStarCountValue.text);
			BattleDefine.callHeroPossibility = Number(heroCallProperity2.text);
			BattleDefine.geneCardPossibility = Number(cardGeneProbValue.text);
			
			BattleDefine.autoEnemySupplyRoungGap = int(enemySupplyRoundSpeedValue.text);
			BattleDefine.autoEnemySupplyRoundGapFast = int(enemySupplyRoundSpeedValue2.text);
			BattleInfoSnap.MaxEnemySupplyCount = int(enemySupplyCountValue.text);
		}
		
	}
}