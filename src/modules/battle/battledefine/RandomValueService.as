package modules.battle.battledefine
{
	
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;

	public class RandomValueService
	{
		
		public static var allRandomValue:Object;
		
		public static const underLine:String = "_";
		
		public static const atkGapValue:String = "atkgap_";							//攻击时候错开时间的随机值
		public static const cauTag:String = "cau_";									//计算伤害时候的随机因子
		public static const skillChoseTag:String = "scz_";							//主动技能选择时候的随机值
		public static const skillChufa:String = "stz_";								//主动技能触发的随机值
		public static const skillChoseBeiDongTag:String = "scb_";					//被动技能选择的随机因子
		public static const skillChufaBeiDongTag:String = "stb_";					//被动技能触发的随机值
		public static const baojiTag:String = "bj_";								//暴击概率随机因子
		public static const suiji1Tag:String = "sj1_";								//随机目标因子1
		public static const suiji2Tag:String = "sj2_";								//随机目标因子2
		public static const suiji3Tag:String = "sj3_";								//随机目标因子3
		public static const duobiTag:String = "db_";								//躲避随机因子
		public static const xuanyun:String = "xy_";									//眩晕随机因子
		
		public static const diaoluo:String = "diaoluo_";							//掉落值
		public static const diaoluohuoqu:String = "diaoluohuoqu_";								//是否获得的随机值

		/**各种随机值的宏定义**/
		public static const RD_CAU:int = 1;
		public static const RD_SKILLCHOOSE:int = 2;
		public static const RD_SKILLCHUFA:int = 3;
		public static const RD_BDSKILLCHOOSE:int = 4;
		public static const RD_BDSKILLCHUFA:int = 5;
		public static const RD_BAOJI:int = 6;
		public static const RD_SUIJI1:int = 7;
		public static const RD_SUIJI2:int = 8;
		public static const RD_SUIJI3:int = 9;
		public static const RD_DUOBI:int = 10;
		public static const RD_XUANYUN:int = 11;
		public static const RD_DIAOLUO:int = 12;
		public static const RD_DIAOLUOHUOQU:int = 13;
		public static const RD_ATKRANDOM:int = 14;
		
		public function RandomValueService()
		{
		}
		
		/**
		 * 取第一个随机值，用于pvp战斗地图 
		 * @param type
		 * @param targetIndex
		 * @return 
		 */
		public static function getRValueDirect():Number
		{
			var randomTag:String = atkGapValue + "0";
			var curValue:int = allRandomValue[randomTag];
			if(isNaN(curValue))
				curValue = 0;
			return curValue / 100;
		}
		
		public static function getRandomValueForcely(type:int,targetIndex:int,attackIndex:int = 0,indexOfArr:int = 0):Number
		{
			var randomTag:String;
			switch(type)
			{
				case RD_CAU:
					randomTag = cauTag + targetIndex.toString();
					break;
				case RD_ATKRANDOM:
					randomTag = atkGapValue + targetIndex.toString();
					break;
				case RD_SKILLCHOOSE:
					randomTag = skillChoseTag + targetIndex.toString();
					break;
				case RD_SKILLCHUFA:
					randomTag = skillChufa + targetIndex.toString();
					break;
				case RD_BDSKILLCHOOSE:
					randomTag = skillChoseBeiDongTag + targetIndex.toString() + underLine + attackIndex.toString();
					break;
				case RD_BDSKILLCHUFA:
					randomTag = skillChufaBeiDongTag + targetIndex.toString() + underLine + attackIndex.toString();
					break;
				case RD_BAOJI:
					randomTag = baojiTag + targetIndex.toString();
					break;
				case RD_SUIJI1:
					randomTag = suiji1Tag + targetIndex.toString();
					break;
				case RD_SUIJI2:
					randomTag = suiji2Tag + targetIndex.toString();
					break;
				case RD_SUIJI3:
					randomTag = suiji3Tag + targetIndex.toString();
					break;
				case RD_DUOBI:
					randomTag = duobiTag + targetIndex.toString() + underLine + attackIndex.toString();
					break;
				case RD_XUANYUN:
					randomTag = xuanyun + targetIndex.toString() + underLine + attackIndex.toString();
					break;
				case RD_DIAOLUO:
					randomTag = diaoluo + targetIndex.toString() + underLine + indexOfArr.toString();
					break;
				case RD_DIAOLUOHUOQU:
					randomTag = diaoluohuoqu + targetIndex.toString() + underLine + indexOfArr.toString();
					break;
			}
			BattleInfoSnap.usedRandomTagInRound[randomTag] = 1;
			if(!allRandomValue.hasOwnProperty(randomTag))
			{
				trace("请求tag:",randomTag,"没有随机值:");
			}
			var curValue:int = allRandomValue[randomTag];
			if(isNaN(curValue))
			{
				curValue = 0;
				trace("请求tag:",randomTag,"没有随机值:");
			}
			
			return curValue / 100;
		}
		
		public static function getRandomValue(type:int,targetIndex:int,attackIndex:int = 0,indexOfArr:int = 0):Number
		{
			var randomTag:String;
			
			if(!BattleModeDefine.checkNeedServerData())
			{
				return Math.random();
			}
			else															//需要取得服务端发回的随机值
			{
				switch(type)
				{
					case RD_CAU:
						randomTag = cauTag + targetIndex.toString();
						break;
					case RD_ATKRANDOM:
						randomTag = atkGapValue + targetIndex.toString();
						break;
					case RD_SKILLCHOOSE:
						randomTag = skillChoseTag + targetIndex.toString();
						break;
					case RD_SKILLCHUFA:
						randomTag = skillChufa + targetIndex.toString();
						break;
					case RD_BDSKILLCHOOSE:
						randomTag = skillChoseBeiDongTag + targetIndex.toString() + underLine + attackIndex.toString();
						break;
					case RD_BDSKILLCHUFA:
						randomTag = skillChufaBeiDongTag + targetIndex.toString() + underLine + attackIndex.toString();
						break;
					case RD_BAOJI:
						randomTag = baojiTag + targetIndex.toString();
						break;
					case RD_SUIJI1:
						randomTag = suiji1Tag + targetIndex.toString();
						break;
					case RD_SUIJI2:
						randomTag = suiji2Tag + targetIndex.toString();
						break;
					case RD_SUIJI3:
						randomTag = suiji3Tag + targetIndex.toString();
						break;
					case RD_DUOBI:
						randomTag = duobiTag + targetIndex.toString() + underLine + attackIndex.toString();
						break;
					case RD_XUANYUN:
						randomTag = xuanyun + targetIndex.toString() + underLine + attackIndex.toString();
						break;
					case RD_DIAOLUO:
						randomTag = diaoluo + targetIndex.toString() + underLine + indexOfArr.toString();
						break;
					case RD_DIAOLUOHUOQU:
						randomTag = diaoluohuoqu + targetIndex.toString() + underLine + indexOfArr.toString();
						break;
				}
				BattleInfoSnap.usedRandomTagInRound[randomTag] = 1;
				if(!allRandomValue.hasOwnProperty(randomTag))
				{
					trace("请求tag:",randomTag,"没有随机值:");
				}
				var curValue:int = allRandomValue[randomTag];
				if(isNaN(curValue))
				{
					curValue = 0;
					trace("请求tag:",randomTag,"没有随机值:");
				}
				
//				if(BattleManager.needTraceBattleInfo)
//				{
//					if(type == RD_CAU)
//					{
//						trace(targetIndex,"请求伤害计算tag:",curValue);
//					}
//				}
				
				return curValue / 100;
			}
		}
	}
}