package modules.battle.stage
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	
	import eventengine.GameEventHandler;
	
	import macro.EventMacro;
	import macro.GameSizeDefine;
	
	import modules.battle.battledefine.BattleConstString;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	
	import synchronousLoader.ResourcePool;
	
	import uipacket.previews.PreviewImage;
	import uipacket.previews.PreviewLabel;
	
	public class BattleDaojuLayer extends Sprite
	{
		
		private var waveShowBackGround:PreviewImage;
		private var battleWaveShowInfo:MovieClip;
		
		private var waitUserShowOnRaid:WaitUserShowOfRaid;
		
		private var waitTagShow:PreviewLabel;
		
		public function BattleDaojuLayer()
		{
			super();
			waveShowBackGround = new PreviewImage();
			this.addChild(waveShowBackGround);
			waveShowBackGround.visible = false;
			waveShowBackGround.x = 720 + 260;
			waveShowBackGround.y = 90;
			
			GameEventHandler.addListener(EventMacro.CommonEventHandler,BattleConstString.showWaitForOther,showWaitForOtherInfo);
			GameEventHandler.addListener(EventMacro.CommonEventHandler,BattleConstString.hideWaitForOther,hideWaitForOtherInfo);
		}
		
		public function init():void
		{
			var needShowReally:Boolean = true;
			if(BattleModeDefine.checkNeedConsiderWave())
			{
				if(BattleManager.instance.battleMode == BattleModeDefine.PVE_SingleMultipleWaves || BattleManager.instance.battleMode == BattleModeDefine.PVE_KuaiSuZhanDouMulWaves)
				{
					var allWaves:int = BattleManager.instance.getTotalWacesCount();
					if(allWaves <= 1)
						needShowReally = false;
				}
				
			}
			else
			{
				needShowReally = false;
			}
			if(needShowReally)
				initWaveShow();
			else
			{
				if(battleWaveShowInfo)
					battleWaveShowInfo.visible = false;
				waveShowBackGround.visible = false;
			}
			
			if(waitUserShowOnRaid)
			{
				waitUserShowOnRaid.visible = false;
			}
			
			if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance || BattleModeDefine.isGeneralRaid)
			{
				if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Raid)
				{
					if(waitUserShowOnRaid == null)
					{
						waitUserShowOnRaid = new WaitUserShowOfRaid();
						waitUserShowOnRaid.x = 415;
						waitUserShowOnRaid.y = 0;
					}
					this.addChild(waitUserShowOnRaid);
					waitUserShowOnRaid.visible = true;
					waitUserShowOnRaid.clearInfo(null);
					
				}
				
//				GameEventHandler.addListener(EventMacro.NORMAL_BATTLE_EVENT,RaidMaterialGotEvent.Event_addNewMaterialOfRaid,getNewMaterialofRaid);
			}
			
			if(BattleManager.instance.battleMode != BattleModeDefine.PVE_Instance)
			{
				return;
			}
		}
		
		private function initWaveShow():void
		{
			waveShowBackGround.setResid(15006);
			if(waveShowBackGround)
			{
				this.addChild(waveShowBackGround);
				waveShowBackGround.visible = true;
			}
			if(battleWaveShowInfo == null)
			{
				battleWaveShowInfo = ResourcePool.getResById(2325) as MovieClip;
				if(battleWaveShowInfo)
				{
					this.addChild(battleWaveShowInfo);
					battleWaveShowInfo.x = 850 + 260;
					battleWaveShowInfo.y = 120;
				}
			}
			if(battleWaveShowInfo)
			{
				this.addChild(battleWaveShowInfo);
				battleWaveShowInfo.visible = true;
				handleSingleWaveStart();
			}
		}
		
		private function showWaitForOtherInfo(event:Event):void
		{
			if(waitTagShow == null)
			{
				waitTagShow = new PreviewLabel();
				this.addChild(waitTagShow);
				waitTagShow.width = 150;
				waitTagShow.wordWrap = false;
				waitTagShow.autoSize = TextFieldAutoSize.CENTER;
				waitTagShow.x = (GameSizeDefine.maxWidth - waitTagShow.width) / 2;
				waitTagShow.y = (GameSizeDefine.maxHeight - waitTagShow.height) / 2;
				waitTagShow.SetFont(7);
			}
			waitTagShow.SetTextID(881);
			waitTagShow.visible = true;
		}
		
		private function hideWaitForOtherInfo(event:Event):void
		{
			if(waitTagShow)
			{
				waitTagShow.visible = false;
			}
		}
		
		public function handleSingleWaveStart():void
		{
			if(battleWaveShowInfo)
			{
				var curWave:int = BattleManager.instance.curWaveIndex;
				var allWaves:int = BattleManager.instance.getTotalWacesCount();
				
				if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Instance)
					allWaves = BattleInfoSnap.maxWaveCount;
				
				allWaves = Math.min(999,allWaves);
				curWave = Math.min(curWave,allWaves);
				
				var allParentNames:Array = ["shuzixia1","shuzixia2","shuzishang1","shuzishang2","shuzishang3","shuzixia3"];
				var singleParent:DisplayObjectContainer;
				for(var i:int = 0; i < allParentNames.length;i++)
				{
					singleParent = battleWaveShowInfo.getChildByName(allParentNames[i]) as DisplayObjectContainer;
					while(singleParent.numChildren > 0)
					{
						singleParent.removeChildAt(0);
					}
				}
				
				var curRealnum:int = 0;
				var singleBmpInfo:DisplayObject = BattleFunc.getNumberBitmap(curWave / 10);
				if(curWave >= 100)
				{
					var curRealWaves:int = curWave % 100;
					singleBmpInfo = BattleFunc.getNumberBitmap(int(curWave / 100));
					singleParent = battleWaveShowInfo.getChildByName("shuzishang3") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
					
					curRealnum = curWave % 100;
					singleBmpInfo = BattleFunc.getNumberBitmap(int(curRealnum / 10));
					singleParent = battleWaveShowInfo.getChildByName("shuzishang2") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
					
					singleBmpInfo = BattleFunc.getNumberBitmap(curWave % 10);
					singleParent = battleWaveShowInfo.getChildByName("shuzishang1") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
				}
				else if(curWave >= 10)
				{
					singleBmpInfo = BattleFunc.getNumberBitmap(int(curWave / 10));
					singleParent = battleWaveShowInfo.getChildByName("shuzishang2") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
					
					singleBmpInfo = BattleFunc.getNumberBitmap(curWave % 10);
					singleParent = battleWaveShowInfo.getChildByName("shuzishang1") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
				}
				else
				{
					singleBmpInfo = BattleFunc.getNumberBitmap(curWave);
					singleParent = battleWaveShowInfo.getChildByName("shuzishang1") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
				}
				
				if(allWaves >= 100)
				{
					singleBmpInfo = BattleFunc.getNumberBitmap(int(allWaves / 100));
					singleParent = battleWaveShowInfo.getChildByName("shuzixia1") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
					
					curRealnum = allWaves % 100;
					singleBmpInfo = BattleFunc.getNumberBitmap(int(curRealnum / 10));
					singleParent = battleWaveShowInfo.getChildByName("shuzixia2") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
					
					singleBmpInfo = BattleFunc.getNumberBitmap(allWaves % 10);
					singleParent = battleWaveShowInfo.getChildByName("shuzixia3") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
				}
				else if(allWaves >= 10)
				{
					singleBmpInfo = BattleFunc.getNumberBitmap(int(allWaves / 10));
					singleParent = battleWaveShowInfo.getChildByName("shuzixia1") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
					
					singleBmpInfo = BattleFunc.getNumberBitmap(allWaves % 10);
					singleParent = battleWaveShowInfo.getChildByName("shuzixia2") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
				}
				else
				{
					singleBmpInfo = BattleFunc.getNumberBitmap(allWaves % 10);
					singleParent = battleWaveShowInfo.getChildByName("shuzixia1") as DisplayObjectContainer;
					singleBmpInfo && singleParent.addChild(singleBmpInfo);
				}
			}
		}
		
		public function clearInfo():void
		{
			while(this.numChildren > 0)
			{
				BattleStage.instance.daojuLayer.removeChildAt(0);
			}
		}
		
	}
}