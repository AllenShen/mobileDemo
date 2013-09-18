package modules.battle.battlecomponent
{
	import defines.UserHeroInfo;
	
	import effects.BattleEffectObjBase;
	import effects.BattleEffectObjSWF;
	import effects.BattleResourcePool;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import macro.BattleDisplayDefine;
	
	import modules.battle.battleconfig.BattleEffectIdConfig;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.EffectShowTypeDefine;
	import modules.battle.battlelogic.CellTroopInfo;
	
	import synchronousLoader.ResourcePool;
	
	import uipacket.previews.PreviewImage;
	import uipacket.previews.PreviewLabel;

	/**
	 * 显示战斗时候英雄头像控件 
	 * @author SDD
	 */
	public class HeroPortrait extends TroopComponentBase
	{
		
		public static const heroTroopDeadTag:String = "heroTroopDeadTagPortrait";
		public static const lvContainer:String = "dengji";
		
		private var _frameType:int = 0;				//框子的类型
		
		private var _frameMc:MovieClip;				//框架的mc
		private var _portraitContainer:DisplayObjectContainer;		//portrait的父容器
		
		private var _portraitBmp:PreviewImage;			//头像对应的bitmap
		
		private var _jingyanBeijing:MovieClip;
		private var _levelContainer:DisplayObjectContainer;
		
		private var _jiangyantiao:MovieClip;		//经验条
		private var _levelShowView:PreviewLabel;
		
		private var jingyanFrames:int;				//经验动画帧数
		private var nextToStopFrame:int = 1;		//需要停止的位置
		
		private var curJingYanLevel:int = 0;			//当前经验等级
		private var curJingYanValue:int = 0;			//当前的经验值
		private var curLevelMaxJingYanValue:int = 0;	//当前级别升级所需要的经验值
		
		private var targetJingYanLevel:int = 0;			//目标等级
		private var targetJingYanValue:int = 0;			//目标经验值
		
		private var battleCardShow:Object;				//保存显示等待的战斗卡片
		
		public function HeroPortrait(troop:CellTroopInfo)
		{
			super(troop);
		}
		
		/**
		 *  将头像加入到容器中
		 */
		public function addPortraitToFrame():void
		{
			if(portraitContainer && _portraitBmp)
			{
				portraitContainer.addChild(_portraitBmp);
				
				_portraitBmp.y = BattleDisplayDefine.portraitYOffset;
				if(this.dataSource.ownerSide == BattleDefine.secondAtk)
				{
					_frameMc.scaleX = -1;
				}
			}
		}
		
		/**
		 *  设置经验条值
		 */
		public function setJingYanTiaoValue():void
		{
			if(dataSource == null || dataSource.attackUnit.contentHeroInfo == null)
				return;
			var heroInfoOnClient:UserHeroInfo = dataSource.attackUnit.contentHeroInfo;
			targetJingYanValue = heroInfoOnClient.getHeroCurrentExp();
			targetJingYanLevel = heroInfoOnClient.herolevel;
			curLevelMaxJingYanValue = heroInfoOnClient.getHeroTargetExp();
			
			if(_levelShowView)
				_levelShowView.text = curJingYanLevel.toString();
			
			if(targetJingYanLevel > curJingYanLevel)			//升级了
			{
				nextToStopFrame = jingyanFrames;
				jiangyantiao && jiangyantiao.play();
			}
			else
			{
				nextToStopFrame = HeroPortrait.getJingYanFrameByValue(targetJingYanValue,curLevelMaxJingYanValue,jingyanFrames);
				if(_jiangyantiao && nextToStopFrame != _jiangyantiao.currentFrame)
				{
					jiangyantiao && jiangyantiao.play();
				}
				curJingYanValue = targetJingYanValue;
			}
		}
		
		/**
		 * 设置经验条位置 
		 * @param posposX			x位置
		 */
		public function setJingYanPos(posX:Number):void
		{
			if(_jingyanBeijing)
				_jingyanBeijing.x = posX;
			if(_jiangyantiao)
				_jiangyantiao.x = posX;
		}
		
		/**
		 * troop死亡 
		 * @param event
		 */
		private function heroDeadHandler(event:Event):void
		{
			if(dataSource)
				dataSource.removeEventListener(heroTroopDeadTag,heroDeadHandler);
			if(_frameMc)
				_frameMc.play();
		}
		
		/**
		 * movieclip的enterframe事件处理函数 
		 * @param event
		 */
		private function frameMcEnterFrame(event:Event):void
		{
			var targetMc:MovieClip = event.target as MovieClip;
			if(targetMc && targetMc.currentFrame == targetMc.totalFrames)
			{
				targetMc.removeEventListener(Event.ENTER_FRAME,frameMcEnterFrame);
				targetMc.stop();
			}
		}
		
		/**
		 * 经验条的enterframe处理事件 
		 * @param event
		 */
		private function jingyantiaoEnterFrame(event:Event):void
		{
			if(_jiangyantiao)
			{
				if(_jiangyantiao.currentFrame == nextToStopFrame)
				{
					_jiangyantiao.stop();
					if(curJingYanLevel < targetJingYanLevel)
					{
						curJingYanLevel = targetJingYanLevel;
						curJingYanValue = targetJingYanValue;
						nextToStopFrame = HeroPortrait.getJingYanFrameByValue(targetJingYanValue,curLevelMaxJingYanValue,jingyanFrames);
						_jiangyantiao.play();
					}
				}
				if(_jiangyantiao.currentFrame == _jiangyantiao.totalFrames)			//显示当前的帧数级别
				{
					_levelShowView.text = targetJingYanLevel.toString();
				}
			}
		}
		
		override public function clearInfo():void
		{
			if(this._frameMc)
			{
				_frameMc.removeEventListener(Event.ENTER_FRAME,frameMcEnterFrame);
				_frameMc = null;
			}
			
			if(portraitContainer && portraitContainer.numChildren > 0)
				portraitContainer.removeChildAt(0);
			if(dataSource)
				dataSource.removeEventListener(heroTroopDeadTag,heroDeadHandler);
			
			frameMc = null;
			
			dataSource = null;
			
			if(_portraitBmp)
				_portraitBmp.ClearImg(false);
			portraitBmp = null;
			jiangyantiao = null;
			nextToStopFrame = 1;
			
			curJingYanLevel = 0;
			curJingYanValue = 0;
			curLevelMaxJingYanValue = 0;
			targetJingYanLevel = 0;
			targetJingYanValue = 0;
			
			if(battleCardShow)
			{
				var singleObj:BattleEffectObjBase;
				for(var key:String in battleCardShow)
				{
					singleObj = battleCardShow[key];
					if(singleObj)
					{
						if(this.contains(singleObj))
						{
							this.removeChild(singleObj);
							singleObj.isBusy = false;
						}
					}
				}
			}
			
			if(_levelShowView && _levelContainer && _levelContainer.contains(_levelShowView))
			{
				_levelContainer.removeChild(_levelShowView);
			}
			_levelShowView = null;
			
		}
		
		override public function set dataSource(value:CellTroopInfo):void
		{
			super.dataSource = value;
			if(dataSource && dataSource.isHero)
			{
//				this.portraitBmp = ResourcePool.getResById(value.attackUnit.contentHeroInfo.heroportrait);
				
				this.portraitBmp = new PreviewImage();
				portraitBmp.setResid(value.attackUnit.contentHeroInfo.heroportrait);
				
				dataSource.addEventListener(heroTroopDeadTag,heroDeadHandler);
				
				if(dataSource.ownerSide == BattleDefine.firstAtk)
				{
					jiangyantiao = ResourcePool.getReflectSwfById(BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_JingYanTiao));
					jingyanBeijing = ResourcePool.getReflectSwfById(BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_JingYanBeiJing));
					
					//设置初始化信息
					curJingYanLevel = dataSource.attackUnit.contentHeroInfo.herolevel;
					curJingYanValue = dataSource.attackUnit.contentHeroInfo.heroexp;
					
//					nextToStopFrame = HeroPortrait.getJingYanFrameByValue(targetJingYanValue,curLevelMaxJingYanValue,jingyanFrames);
					nextToStopFrame = 1;
					_jiangyantiao.gotoAndStop(1);			//初始化信息
					_levelShowView = new PreviewLabel();
					if(_levelContainer)
						_levelContainer.addChild(_levelShowView);
					_levelShowView.SetFont(1);
				}
				else
				{
					jiangyantiao = null;
					jingyanBeijing = null;
				}
				
				if(dataSource.isPlayerHero)				//是否是默认英雄
				{
					battleCardShow ={};
				}
			}
		}
		
		public function get frameType():int
		{
			return _frameType;
		}

		public function set frameType(value:int):void
		{
			_frameType = value;
			var portraitFrameResId:int = 0;
			if(_frameType == 0)
			{
				portraitFrameResId = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_HeroPortraitFrame1);
//				if(_levelShowView)
//				{
//					_levelShowView.x = -47;
//					_levelShowView.y = 64;
//				}
			}
			else if(_frameType == 1)
			{
				portraitFrameResId = BattleEffectIdConfig.getResIdForEffect(EffectShowTypeDefine.EffectResource_HeroPortraitFrame2);
//				if(_levelShowView)
//				{
//					_levelShowView.x = -33;
//					_levelShowView.y = 64;
//				}
			}
			frameMc = ResourcePool.getReflectSwfById(portraitFrameResId);
			
			_frameMc.gotoAndStop(1);
			_frameMc.addEventListener(Event.ENTER_FRAME,frameMcEnterFrame);
		}

		public function get frameMc():MovieClip
		{
			return _frameMc;
		}

		public function set frameMc(value:MovieClip):void
		{
			if(_frameMc != null)
			{
				if(this.contains(_frameMc))
				{
					this.removeChild(_frameMc);
					_frameMc.removeEventListener(Event.ENTER_FRAME,frameMcEnterFrame);
				}
				_frameMc = null;
				portraitContainer = null;
			}
			_frameMc = value;
			if(_frameMc)
			{
				this.addChildAt(_frameMc,0);
				portraitContainer = _frameMc.getChildByName("portraitframe") as DisplayObjectContainer;
			}
		}

		public function get portraitBmp():PreviewImage
		{
			return _portraitBmp;
		}

		public function set portraitBmp(value:PreviewImage):void
		{
			_portraitBmp = value;
			if(_portraitBmp)
			{
				if(portraitContainer)
				{
					while(portraitContainer.numChildren > 0)
					{
						var tempObj:DisplayObject = portraitContainer.removeChildAt(0);
						tempObj = null;
					}
				}
			}
		}

		public function get jiangyantiao():MovieClip
		{
			return _jiangyantiao;
		}

		public function set jiangyantiao(value:MovieClip):void
		{
			if(_jiangyantiao != null)
			{
				if(this.contains(_jiangyantiao))
				{
					this.removeChild(_jiangyantiao);
					_jiangyantiao.removeEventListener(Event.ENTER_FRAME,jingyantiaoEnterFrame);
				}
				_jiangyantiao = null;
			}
			_jiangyantiao = value;
			if(_jiangyantiao)
			{
				this.addChild(_jiangyantiao);
				_jiangyantiao.addEventListener(Event.ENTER_FRAME,jingyantiaoEnterFrame);
				_jiangyantiao.x = BattleDisplayDefine.jiangYanTiaoPos.x;
				_jiangyantiao.y = BattleDisplayDefine.jiangYanTiaoPos.y;
				_jiangyantiao.gotoAndPlay(1);
				jingyanFrames = _jiangyantiao.totalFrames;
			}
		}

		public function get jingyanBeijing():MovieClip
		{
			return _jingyanBeijing;
		}

		public function set jingyanBeijing(value:MovieClip):void
		{
			if(_jingyanBeijing != null)
			{
				if(this.contains(_jingyanBeijing))
				{
					this.removeChild(_jingyanBeijing);
				}
				_jingyanBeijing = null;
			}
			_jingyanBeijing = value;
			if(_jingyanBeijing)
			{
				this.addChild(_jingyanBeijing);
				_jingyanBeijing.x = BattleDisplayDefine.jiangYanBeiJingPos.x;
				_jingyanBeijing.y = BattleDisplayDefine.jiangYanBeiJingPos.y;
				
				if(_jingyanBeijing)
					_levelContainer = _jingyanBeijing.getChildByName(lvContainer) as DisplayObjectContainer;
			}
		}

		/**
		 * 获得当前值对应的动画帧数 
		 * @param curValue
		 * @param maxValue
		 * @param totalFrames
		 * @return 
		 */
		public static function getJingYanFrameByValue(curValue:int,maxValue:int,totalFrames:int):int
		{
			var resValue:int;
			resValue = (curValue / maxValue) * totalFrames;
			resValue = Math.max(1,resValue);
			resValue = Math.min(totalFrames,resValue);
			return resValue;
		}

		public function get portraitContainer():DisplayObjectContainer
		{
			return _portraitContainer;
		}

		public function set portraitContainer(value:DisplayObjectContainer):void
		{
			_portraitContainer = value;
		}

		
	}
}