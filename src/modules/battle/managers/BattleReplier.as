package modules.battle.managers
{
	import eventengine.GameEventHandler;
	
	import macro.EventMacro;
	
	import modules.battle.battleevents.CheckBattleEndEvent;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.funcclass.BattleFunc;
	import modules.battle.utils.BattleUtils;

	/**
	 * 专门用来重播的类 
	 * @author Administrator
	 * 
	 */
	public class BattleReplier
	{
		
		public var replayIndex:int = 0;						//重播播放到的roundIndedx
		
		public var roundVedioArr:Array;						//用于回放的round信息集合
		
		public var allVedieChainInfo:Object;
		
		public var curRoundPlayedStatus:Object;								//记录round中每个chain是否播放的状态
		
		private static var instanceObj:BattleReplier;
		
		public static function get instance():BattleReplier				//单件模式
		{
			if(BattleReplier.instanceObj == null)
				BattleReplier.instanceObj = new BattleReplier;
			return BattleReplier.instanceObj;
		}
		
		public function BattleReplier()
		{
		}
		
		/**
		 * 初始化重播的信息 
		 * 完毕后开始播放
		 * @param roundInfo
		 * 
		 */
		public function initReplyInfo(roundInfo:Array):void
		{
			if(roundInfo == null)
				return;
			
			roundVedioArr = roundInfo;
			
			allVedieChainInfo ={};
			
			replayIndex = 0;
			
			for(var i:int = 0; i < roundInfo.length;i++)
			{
				var singleRound:Array = roundInfo[i] as Array;
				if(singleRound)
				{
					for(var ii:int = 0; ii < singleRound.length;ii++)
					{
						var singleVedio:CombatChain = singleRound[ii] as CombatChain;
						if(singleVedio)
						{
							allVedieChainInfo[singleVedio.chainIndex] = singleVedio;
						}
					}
				}
			}
			
			playParticularRound();	
		}
		
		/**
		 * 播放某个回合的数据 
		 */
		public function playParticularRound():void
		{
			curRoundPlayedStatus ={};
			
			if(replayIndex >= roundVedioArr.length)			//播放完成
			{
				GameEventHandler.dispatchGameEvent(EventMacro.NORMAL_BATTLE_EVENT,new CheckBattleEndEvent(CheckBattleEndEvent.BATTLE_VEDIO_END));
				return;
			}
			
			var chainInfoInRound:Array = roundVedioArr[replayIndex++] as Array;
			
			for(var j:int = 0; j < chainInfoInRound.length; j++)								//初始化chain的播放状态
			{
				var singleChainInfo:CombatChain = chainInfoInRound[j] as CombatChain;
				curRoundPlayedStatus[singleChainInfo.chainIndex] = 0;
			}	
			
			var noPreChains:Array = BattleFunc.getChainwithNoPreChains(chainInfoInRound);		//获得一个round中所有的无前置chain信息
			
			for(var i:int = 0; i < noPreChains.length; i++)
			{
				playParticluarChainVedio(noPreChains[i]);
			}
			
		}
		
		/**
		 * 播放某个特定的chain信息 
		 * @param chainIndex
		 */
		public function playParticluarChainVedio(chainIndex:int):void
		{
			var singleChainVedio:CombatChain = allVedieChainInfo[chainIndex] as CombatChain;
			if(singleChainVedio)
			{
				var atkTroop:CellTroopInfo = BattleUnitPool.getTroopInfo(singleChainVedio.atkTroopIndex);
				if(atkTroop.isMcOnCanAttackStatus)
					singleChainVedio.makeChainPlayVedio();
			}
		}
		
		/**
		 * 将某个chain标记为已经播放 
		 * @param chainIndex
		 * 
		 */
		public function makeParticularChainPlayed(chainIndex:int):void
		{
			delete curRoundPlayedStatus[chainIndex];
		}
		
		/**
		 * 处理某个chain播放完成 
		 * @param chainIndex  chainIndex
		 */
		public function handlerChainPlayOver(chainIndex:int):void
		{
			var singleChainVedio:CombatChain = allVedieChainInfo[chainIndex] as CombatChain;
			if(singleChainVedio)					//播放后置chain信息
			{				
				var nxtChainIndex:int = singleChainVedio.nxtChain;
				if(nxtChainIndex >= 0)											//存在后置chain，直接播放
					playParticluarChainVedio(nxtChainIndex);
				else
					checkCanPlayChainVedio();
			}
		}
		
		/**
		 * 查看此时是否能play录像信息 
		 */
		public function checkCanPlayChainVedio():void
		{
			if(BattleUtils.getObjectLength(curRoundPlayedStatus) <= 0)				//如果当前已经全部播放完成
			{
				playParticularRound();				//开始新一轮的播放
			}
			else
			{
				var preDoneChain:Array=[];
				var singleChainInfo:CombatChain;
				for(var key:String in curRoundPlayedStatus)
				{
					singleChainInfo = allVedieChainInfo[key] as CombatChain;
					if(!curRoundPlayedStatus.hasOwnProperty(singleChainInfo.preChain))			//如果前置的chain已经都播放了
						preDoneChain.push(int(key));
				}
				for(var i:int = 0; i < preDoneChain.length; i++)
				{
					playParticluarChainVedio(preDoneChain[i]);
				}
			}
		}
	}
}