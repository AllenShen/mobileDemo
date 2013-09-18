package modules.battle.battlelogic
{
	import handlers.server.BattleHandler;
	
	import modules.battle.battledata.BDataPvpSingle;
	import modules.battle.battledata.BattleData;
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleModeDefine;
	import modules.battle.battledefine.BattleResultValue;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleUnitPool;

	/**
	 * 表示战斗结果的类 
	 * @author SDD
	 * 
	 */
	public class BattleResult
	{
		//大胜，获胜，险胜，微败，失败，惨败
		public var result:int = 0;
		//胜利，失败
		public var resultSummary:int = 0;
		//PVE敌人的序列id
		public var enemyseqid:int = 0;
		//PVE敌人序列中正在打的敌人id
		public var enemyid:int = 0;
		//根据兵种类型记录损兵数据
		public var userLost:Object={};
		//根据pve敌人id记录损兵数据
		public var pveEnemyLost:Object={};
		//根据兵种类型记录PVP损兵数据
		public var pvpUserLost:Object={};
		public var heroes:Array=[];
		
		public function BattleResult(obj:Object = null)
		{
			if(obj != null)
			{
				for(var key:String in obj)
				{
					if(this.hasOwnProperty(key))
						this[key] = obj[key];
				}
			}
		}
		
		public function loadFromDataArray(data:Array):void
		{
			result = data[0] as int;
			resultSummary = data[1] as int;
			enemyseqid = data[2] as int;
			enemyid = data[3] as int;
			userLost = data[4] as Object;
			pveEnemyLost = data[5] as Object;
			pvpUserLost = data[6] as Object;
			heroes = data[7] as Array;
		}
		
		/**
		 * 解析从服务器返回的值 
		 * @param data
		 */
		public function resolveInfoFromServerData(param:Array):void
		{
			if(param == null)
				return;
			
			if(BattleManager.instance.battleMode == BattleModeDefine.PVP_Single && BattleHandler.instance.onLineManager.curbattledata)
			{
				var bData:BattleData =  BattleHandler.instance.onLineManager.curbattledata;
				var data:Array = param[2];
				var serverResult:int = data[0];
				var pvpData:BDataPvpSingle = (BattleHandler.instance.onLineManager.curbattledata as BDataPvpSingle);
				if(pvpData.attackuid == GlobalData.owner.uid)						//自己是挑战方
				{
					this.resultSummary = serverResult;
					this.userLost = data[1];
					this.pveEnemyLost = data[2];
				}
				else															
				{
					if(serverResult == BattleResultValue.resultWin)
					{
						this.resultSummary = BattleResultValue.resultLose;
					}
					else if(serverResult == BattleResultValue.resultLose)
					{
						this.resultSummary = BattleResultValue.resultWin;
					}
					else
					{
						this.resultSummary = BattleResultValue.resultDraw;
					}
					this.userLost = data[2];
					this.pveEnemyLost = data[1];
				}
			}
//			else if(BattleManager.instance.battleMode == BattleModeDefine.PVE_Multi)
//			{
//				GlobalData.owner.userArms.HandleArmyChangeMessage(param[3], true);
//				var arrext:Array = handlerUserRewardsOnPvEM(param[5]);
//				var infoToExecute:Array=[];
//				if(arrext)
//				{
//					var newinfo:ExecuteInfo = new ExecuteInfo(ExecuteInfoType.ShowDropWnd, arrext);
//					infoToExecute.push(newinfo);
//				}
//				ViewManager.getRoomScene().executeInfo(infoToExecute);
//			}
		}
		
		/**
		 * 处理某个回合中得到的奖励 
		 * @param param
		 * @return 
		 */
		public function handlerUserRewardsOnPvEM(param:Array):Array
		{
			return [];
		}
		
		protected function initRewardArray():Array
		{
			var ret:Array=[];
			ret.push([]);
			ret.push([]);
			ret.push([]);
			
			return ret;
		}
		
		public function updateResultInfo():void
		{
			var allTroopInfo:Array = BattleUnitPool.getAllTroops();
			for each(var singleTroopInfo:CellTroopInfo in allTroopInfo)
			{
				if(singleTroopInfo && singleTroopInfo.attackUnit)
				{
					if(!singleTroopInfo.isHero && singleTroopInfo.troopVisibleOnBattle)
					{
						if(singleTroopInfo.attackUnit.pveenemyunitid > 0)
						{
							if(!this.pveEnemyLost[singleTroopInfo.attackUnit.pveenemyunitid])
								this.pveEnemyLost[singleTroopInfo.attackUnit.pveenemyunitid] = 0;
							this.pveEnemyLost[singleTroopInfo.attackUnit.pveenemyunitid] = singleTroopInfo.curArmCount - singleTroopInfo.maxArmCount;
						}
						else if(singleTroopInfo.ownerSide == BattleDefine.firstAtk)
						{
							if(!this.userLost[singleTroopInfo.attackUnit.contentArmInfo.armid])
								this.userLost[singleTroopInfo.attackUnit.contentArmInfo.armid] = 0;
							var realCurArmCount:int = Math.min(singleTroopInfo.curArmCount,singleTroopInfo.maxArmCount);
							this.userLost[singleTroopInfo.attackUnit.contentArmInfo.armid] += realCurArmCount - singleTroopInfo.maxArmCount;
						}
					}
					if(singleTroopInfo.isHero)
					{
						if(singleTroopInfo.ownerSide == BattleDefine.firstAtk)
						{
							if(singleTroopInfo.attackUnit.contentHeroInfo)
							{
								if(this.heroes.indexOf(singleTroopInfo.attackUnit.contentHeroInfo.heroid) < 0)
									this.heroes.push(singleTroopInfo.attackUnit.contentHeroInfo.heroid);
							}
						}
					}
				}
			}
		}
		
	}
}