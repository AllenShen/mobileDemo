package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import eventengine.GameEventHandler;
	
	import macro.CommonEventTypeDefine;
	import macro.EventMacro;
	import macro.GameSizeDefine;
	
	import synchronousLoader.GameResourceManager;
	import synchronousLoader.LoadManEvent;
	import synchronousLoader.ResourcePool;
	
	import tools.textengine.StringUtil;
	import tools.textengine.TextEngine;
	
	import uipacket.previews.PreviewImage;
	import uipacket.previews.PreviewLabel;
	
	/**
	 * 加载资源进度条 
	 * @author SDD
	 */
	public class LoadProgress extends Sprite
	{
		
		private var progressSwf:MovieClip;
		private var labelShow:PreviewLabel=new PreviewLabel;
		private var logoShow:PreviewLabel=new PreviewLabel;
		
		private var loadBackPreviewImage:PreviewImage;
		
		private var showProgress:int = 0;
		private var jiaProgress:int=15;
		
		private var jiagoed:int=0;
		
		private var maxCount:int = 1;
		
		private var innerTimer:Timer = null;
		private var innertimestep:int=0;
		
		private var nextToStopFrame:int = 1;
		
		private static var instaceObj:LoadProgress;
				
		private var m_timestep:int = 100;
		
		private var m_lastProgress:int = 0;
		
		private var m_loadBackGround:Sprite;
		
		private var m_contentLayer:Sprite;
		
		public function LoadProgress()
		{
			super();
			
			GameEventHandler.addListener(EventMacro.CommonEventHandler,CommonEventTypeDefine.Event_ScreenChanged,makeSelfLookCenter);
			
			m_loadBackGround = new Sprite();
			this.addChild(m_loadBackGround);
			
			m_contentLayer = new Sprite();
			m_contentLayer.graphics.clear();
			m_contentLayer.graphics.beginFill(0,0);
			m_contentLayer.graphics.drawRect(0,0,GameSizeDefine.maxWidth,GameSizeDefine.maxHeight);
			m_contentLayer.graphics.endFill();
			this.addChild(m_contentLayer);
			
			drawBackGround();
			
			labelShow.wordWrap = false;
			labelShow.autoSize = TextFieldAutoSize.CENTER;
			
			m_contentLayer.addChild(labelShow);
			m_contentLayer.addChild(logoShow);
			labelShow.width = 395;
			
			logoShow.width=400;
			logoShow.height = 50;
			logoShow.wordWrap = true;
			
			var textFormat:TextFormat = new TextFormat();
			
			textFormat.font="黑体";
			textFormat.size=12;
			textFormat.color=0xffffff;
			textFormat.bold=1;
			textFormat.italic=0;
			textFormat.underline=0;
			
			labelShow.setStyle("textFormat",textFormat);
			logoShow.setStyle("textFormat",textFormat);
			logoShow.htmlText=("<font color='#f8a01a' size='12'>抵制不良游戏，拒绝盗版游戏。注意自我保护，谨防受骗上当。\r\n适度游戏益脑，沉迷游戏伤身。合理安排时间，享受健康生活。</font>");
			
			loadBackPreviewImage = new PreviewImage;
			m_contentLayer.addChild(loadBackPreviewImage);
			loadBackPreviewImage.setResid(2369);
			
			progressSwf = ResourcePool.getReflectSwf("/resources/components/jiazaijindutiao.swf");
			if(progressSwf)
				setProgressBarValue(1);
			
			Layout();
			
			GameEventHandler.addListener(EventMacro.LOAD_EVENT,LoadManEvent.LOAD_START,startLoadHandler);
			GameEventHandler.addListener(EventMacro.LOAD_EVENT,LoadManEvent.LOAD_SINGLE_FINISH,loadSingleFinishHandler);
			GameEventHandler.addListener(EventMacro.LOAD_EVENT,LoadManEvent.LOAD_ERROR,loadErrorHandler);
			GameEventHandler.addListener(EventMacro.LOAD_EVENT,LoadManEvent.LOAD_PROGRESS,loadProgressHandler);
			GameEventHandler.addListener(EventMacro.LOAD_EVENT,LoadManEvent.LOAD_COMPLETE,loadCompleteHandler);
			
			GameEventHandler.addListener(EventMacro.LOAD_EVENT,LoadManEvent.LOAD_SETINITSTATUS,setInitStatus);
		}
		
		private function AutoRun():void
		{
			stop();

			innerTimer = new Timer(m_timestep);
			innerTimer.addEventListener(TimerEvent.TIMER, onTimer);
			innerTimer.start();
			
			innertimestep=0;
		}
		
		private function stop():void
		{
			if(innerTimer != null)
			{
				innerTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				innerTimer.stop();
				innerTimer = null;
			}
		}
		
		private function onTimer(event:TimerEvent):void
		{
			innertimestep++;
			
			jiagoed = Math.random()*7 + innertimestep;
			
			setProgressValue(jiagoed,100);
			
			if (jiagoed>30)
			{
				stop();
			}
		}
		
		public static function get instance():LoadProgress
		{
			if(instaceObj == null)
			{
				instaceObj = new LoadProgress();
			}
			return instaceObj;
		}
		
		public function Layout():void
		{
			var alterx:Number = (GameSizeDefine.maxWidth-481) / 2;
			var altery:int = (GameSizeDefine.maxHeight-338) / 2;
			
			logoShow.visible = true;
			
			if (GameResourceManager.curLoadBackShowType == GameResourceManager.completeLoad)
			{
				labelShow.x = 420;
				labelShow.y = 493 + 25;
				logoShow.x = 285 + altery;
				logoShow.y = 493 + 100;
				
				loadBackPreviewImage.x = 0;
				loadBackPreviewImage.y = 0;
				loadBackPreviewImage.setResid(2369);
				
				if(progressSwf)
				{
					progressSwf.x = 420;
					progressSwf.y = 493;
				}
			}
			else if (GameResourceManager.curLoadBackShowType == GameResourceManager.simplyBack)
			{
				labelShow.x = 410;
				labelShow.y = 293 + 25;
				logoShow.x = 268 + altery;
				logoShow.y = 293 + 100;
				
				logoShow.visible = false;
				
				loadBackPreviewImage.x = 411;
				loadBackPreviewImage.y = 157.05;
				loadBackPreviewImage.setResid(2370);
				if(progressSwf)
				{
					progressSwf.x = 410.25;
					progressSwf.y = 293;
				}
			}
			else if(GameResourceManager.curLoadBackShowType == GameResourceManager.normalBack)
			{
				labelShow.x = 50 + alterx;
				labelShow.y =  369.25 - 20;
				
				labelShow.x = 419;
				labelShow.y = 369.25 + 25;
				
				logoShow.x = 250 + altery + 30;
				logoShow.y = 369.25 + 100;
				
				loadBackPreviewImage.x = 349.10;
				loadBackPreviewImage.y = 69.00;
				loadBackPreviewImage.setResid(2371);
				if(progressSwf)
				{
					progressSwf.x = 419.25;
					progressSwf.y = 369.25;
				}
			}
			
			drawBackGround();
			
			m_contentLayer.addChild(loadBackPreviewImage);
			
			m_contentLayer.addChild(labelShow);
			m_contentLayer.addChild(logoShow);
			
			if(progressSwf)
				m_contentLayer.addChild(progressSwf);
		}
		
		private function drawBackGround():void
		{
			m_loadBackGround.graphics.clear();
			if (GameResourceManager.curLoadBackShowType == GameResourceManager.completeLoad)
			{
				m_loadBackGround.graphics.beginFill(0,1);
			}
			else if (GameResourceManager.curLoadBackShowType == GameResourceManager.simplyBack)
			{
				m_loadBackGround.graphics.beginFill(0,0.65);
			}
			else if(GameResourceManager.curLoadBackShowType == GameResourceManager.normalBack)
			{
				m_loadBackGround.graphics.beginFill(0,1);
			}
			m_loadBackGround.graphics.drawRect(0,0,GameSizeDefine.viewwidth,GameSizeDefine.viewheight);
			m_loadBackGround.graphics.endFill();
		}
		
		private function makeSelfLookCenter(event:Event):void
		{
			this.m_contentLayer.x = (GameSizeDefine.viewwidth - this.m_contentLayer.width) / 2;
			if(event)
			{
				drawBackGround();
			}
		}
		
		private function startLoadHandler(event:LoadManEvent):void
		{
//			jiaProgress = 20 + Math.random() * 10; 
			
			maxCount = event.m_totalCount;
			setProgressBarValue(1);
			labelShow.text = TextEngine.getTextById(548) + showProgress.toString() + "% ";
			nextToStopFrame = 1;
			
			Layout();
			
			MobileNew.instance.addChild(LoadProgress.instaceObj);
			LoadProgress.instaceObj.x = (960 - GameSizeDefine.maxWidth) / 2;
			LoadProgress.instaceObj.y = (640 - GameSizeDefine.maxHeight) / 2;
			
			makeSelfLookCenter(null);
			
			showProgress=0;
			loadProgressHandler(new LoadManEvent(LoadManEvent.LOAD_PROGRESS,"",0,0,showProgress));
			
			AutoRun();
		}
		
		private function setInitStatus(event:LoadManEvent):void
		{
			labelShow.text = event.m_errInfo;
			setProgressValue(100,100);
		}
		
		private function loadProgressHandler(event:LoadManEvent):void
		{
			if (event.m_progress>0)
			{
				stop();
			}
			var oldValue:int = showProgress;
			showProgress = jiagoed + (event.m_progress/100)*(100-jiagoed);
			showProgress = Math.max(showProgress,oldValue);
			var speed:int = Math.max(event.m_speed,1);
			if(speed == 1)
			{
				speed = Math.max(event.m_speed,Math.random() * 100);
			}
			var textToShow:String;
			if(GameResourceManager.curLoadBackShowType == GameResourceManager.normalBack ||
				GameResourceManager.curLoadBackShowType == GameResourceManager.simplyBack ||
				GameResourceManager.curLoadBackShowType == GameResourceManager.completeLoad)
			{
//				textToShow = TextEngine.getTextById(828);
				textToShow = "正在加载 {0}% 加载速度 {1} kb/s";
				textToShow = StringUtil.substitute(textToShow,showProgress,speed);
			}
			else if(GameResourceManager.curLoadBackShowType == GameResourceManager.dataInitProgress)
			{
//				textToShow = TextEngine.getTextById(827);
				textToShow = "正在初始化场景{0}%";
				textToShow = StringUtil.substitute(textToShow,showProgress);
			}
			labelShow.text = textToShow;
				
			setProgressValue(showProgress,100);
		}
		
		private function loadSingleFinishHandler(event:LoadManEvent):void
		{
			setProgressValue(event.m_curCount,event.m_totalCount);
		}
		
		private function loadErrorHandler(event:LoadManEvent):void
		{
			labelShow.text = event.m_name + TextEngine.getTextById(550);
			setProgressValue(event.m_curCount,event.m_totalCount);
		}
		
		private function loadCompleteHandler(event:LoadManEvent):void
		{
//			if(GlobalData.g_app)
//			{
//				labelShow.text = TextEngine.getTextById(551);
//				setProgressValue(100,100);
//				if(Global.g_addOnApp == 1)
//				{
//					if(LoadProgress.instaceObj.parent)
//						ViewManager.removeModelUI(LoadProgress.instaceObj);
//					else
//						ViewManager.switchModelMask(false);
//				}
//				else
//				{
//					if(GlobalData.g_app.contains(LoadProgress.instaceObj))
//						GlobalData.g_app.removeChild(LoadProgress.instaceObj);
//				}
//				GameResourceManager.autoCloseLoadProgress = true;
//				m_lastProgress = 0;
//			}
//			else
			
			if(MobileNew.instance.contains(this))
				this.parent.removeChild(this);
			
			{
				labelShow.text = "加载完成";
			}
		}
		
		private function setProgressValue(curValue:int,maxValue:int):void
		{
			if(progressSwf)
			{
				var nextValue:int = (curValue / maxValue) * progressSwf.totalFrames;
				nextValue =  Math.max(nextToStopFrame,nextValue);
				nextValue = Math.min(nextValue,progressSwf.totalFrames);
				nextToStopFrame = nextValue;
				setProgressBarValue(nextToStopFrame);
			}
		}
		
		private function setProgressBarValue(frame:int):void
		{
			if(progressSwf)
				progressSwf.gotoAndStop(frame);
		}

	}
}