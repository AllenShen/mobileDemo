package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import animator.animatorengine.AnimatorEngine;
	import animator.sceneengine.data.ModelFixConfig;
	
	import asynloadmanager.DeamResourceOfMap;
	
	import avatarsys.constants.AvatarDefine;
	import avatarsys.util.AvatarFrameConfig;
	import avatarsys.util.AvatarSizeConfig;
	import avatarsys.util.ResourceService;
	import avatarsys.util.WeaponGenedEffectConfig;
	
	import fl.controls.Button;
	
	import macro.GameSizeDefine;
	
	import modules.battle.battleconfig.BattleEffectIdConfig;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battlelogic.BattleResult;
	import modules.battle.managers.BattleManager;
	import modules.battle.stage.BattleStage;
	
	import synchronousLoader.GameResourceManager;
	import synchronousLoader.ResourceConfig;
	import synchronousLoader.ResourcePool;
	
	import utils.AvatarActConfig;
	import utils.BattleEffectConfig;
	import utils.TroopActConfig;
	import utils.TroopFrameConfig;
	
	public class MobileNew extends Sprite
	{
		
		public static var instance:MobileNew;
		private var configInfoLoader:URLLoader;
		
		private var tempBtn:Button;
		private var configInfo:BattleParamConfig;
		
		public function MobileNew()
		{
			super();
			
			instance = this;
			
			AnimatorEngine.startEngine();
			BattleManager.instance;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;                
			//重点，加上这个事件之后才有效；获得屏幕宽度，高度，同样要用这种方法
			this.addEventListener(Event.ENTER_FRAME,enterframe);
			
			tempBtn = new Button;
			
			if(configInfoLoader == null)
			{
				configInfoLoader = new URLLoader;
				
				//var resourceConfigUrl:String = "http://" + Global.g_rooturl + Global.g_language + "/resourceConfig.xml";
				var resourceConfigUrl:String = Global.g_rooturl + Global.g_language + "/resourceConfig.xml";
				
				configInfoLoader.dataFormat = URLLoaderDataFormat.BINARY;
				var urlrequest:URLRequest = new URLRequest(resourceConfigUrl);
				
				configInfoLoader.addEventListener(Event.COMPLETE,configLoadComplete);
				configInfoLoader.addEventListener(IOErrorEvent.IO_ERROR,loadEventHandler);
				configInfoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,loadEventHandler);
				
				configInfoLoader.load(urlrequest);
			}
		}
		
		private function enterframe(event:Event):void 
		{
			this.removeEventListener(Event.ENTER_FRAME,enterframe);//重点
			stage.setOrientation(StageOrientation.ROTATED_RIGHT);//屏幕处于向右旋转方向。
		}
		
		private function loadEventHandler(event:Event):void
		{
			trace("加载失败");
		}
		
		private function configLoadComplete(event:Event):void
		{
			var xmlinfo:String;
			xmlinfo = (event.target as URLLoader).data.toString();
			
			var xmlInfo:XML = new XML(xmlinfo);
			
			AvatarDefine.avatarResourcePath = Global.g_resourceurl + "/" + Global.g_resourcesdir + "/body/";
			AvatarDefine.avatarRolePath = Global.g_resourceurl + "/" + Global.g_resourcesdir +  "/role/";
			AvatarDefine.avatarConfigPath = Global.g_resourceurl + "/" + Global.g_resourcesdir + "/config/";
			
			AvatarDefine.avatarResourcePath = "/" + Global.g_resourcesdir + "/body/";
			AvatarDefine.avatarRolePath = "/" + Global.g_resourcesdir +  "/role/";
			AvatarDefine.avatarConfigPath = "/" + Global.g_resourcesdir + "/config/";
			
			AvatarDefine.avatarConfigPath = Global.g_resourceurl;
			
			//	ResourceConfig.init(xmlInfo,"http://" + Global.g_rooturl + Global.g_language);
			ResourceConfig.init(xmlInfo,Global.g_rooturl + Global.g_language);
			
			GameResourceManager.addResToLoadById(2322);
			GameResourceManager.startLoad(jiazaiJinduloaded,GameResourceManager.completeLoad);
		}
		
		private function jiazaiJinduloaded():void
		{
			LoadProgress.instance;
			GameResourceManager.addResToLoadById(20);
			GameResourceManager.startLoad(avatarConfigLoaded,GameResourceManager.completeLoad);
		}
		
		private function avatarConfigLoaded():void
		{
			var xmlInfo:XML = ResourcePool.getResById(27) as XML;
			ResourceService.xmlData = xmlInfo;
			xmlInfo = ResourcePool.getResById(28);
			AvatarSizeConfig.initInfo(xmlInfo);
			xmlInfo = ResourcePool.getResById(29);
			AvatarFrameConfig.initInfo(xmlInfo);
			xmlInfo = ResourcePool.getResById(30);
			ModelFixConfig.initInfo(xmlInfo);
			
			xmlInfo = ResourcePool.getResById(21) as XML;
			TroopActConfig.init(xmlInfo);
			
			xmlInfo = ResourcePool.getResById(22) as XML;
			BattleEffectConfig.init(xmlInfo);
			
			xmlInfo = ResourcePool.getResById(23);
			TroopFrameConfig.initConfig(xmlInfo);
			
			xmlInfo = ResourcePool.getResById(24);
			AvatarActConfig.init(xmlInfo);
			
			xmlInfo = ResourcePool.getResById(25);
			WeaponGenedEffectConfig.init(xmlInfo);
			
			xmlInfo = ResourcePool.getResById(26);
			BattleEffectIdConfig.init(xmlInfo);
			
			xmlInfo = ResourcePool.getResById(31);
			DeamResourceOfMap.initLoaderRes(xmlInfo);
			
			this.addChild(BattleParamConfig.instance);
			
			tempBtn.width = 100;
			tempBtn.height = 50;
			
			tempBtn.x = 800;
			tempBtn.y = 580;
			
			tempBtn.label = "开始战斗";
			
			this.addChild(tempBtn);
			tempBtn.addEventListener(MouseEvent.CLICK,onBtnClicked);
		}
		
		private function onBtnClicked(event:MouseEvent):void
		{
			startBattleTest();
		}
		
		private function startBattleTest():void
		{
			trace("战斗开始");
			GlobalData.owner = new User();
			this.addChild(BattleStage.instance.parent);
			
			BattleManager.instance.startBattle([makeFakeFormation(1)],onBattleEndCallback,BattleModeDefine.PVE_Single,makeFakeFormation(0));
			
			BattleStage.instance.parent.x = (960 - GameSizeDefine.maxWidth) / 2;
			BattleStage.instance.parent.y = (640 - GameSizeDefine.maxHeight) / 2;
		}
		
		private function onBattleEndCallback(errorCode:int,resultInfo:BattleResult):void
		{
			trace("战斗结束");
		}
		
		private function makeFakeFormation(side:int):Array
		{
			var retArr:Array = [];
			var singleLine:Array = [];
			
			singleLine = FakeFormationLineMaker.getRandomSingleLine(side);
			retArr.push(singleLine);
			singleLine = FakeFormationLineMaker.getRandomSingleLine(side);
			retArr.push(singleLine);
			singleLine = FakeFormationLineMaker.getRandomSingleLine(side);
			retArr.push(singleLine);
			
			return retArr;
		}
		
	}
}