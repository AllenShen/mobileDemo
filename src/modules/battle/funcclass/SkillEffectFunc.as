package modules.battle.funcclass
{
	import flash.geom.Point;
	
	import macro.AttackRangeDefine;
	import macro.BattleDisplayDefine;
	import macro.SkillTrigger;
	import macro.SpecialEffectDefine;
	
	import modules.battle.battledefine.BattleDefine;
	import modules.battle.battledefine.BattleTypeDefine;
	import modules.battle.battledefine.BattleValueDefine;
	import modules.battle.battledefine.LogicSatusDefine;
	import modules.battle.battledefine.McStatusDefine;
	import modules.battle.battledefine.RandomValueService;
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.CombatChain;
	import modules.battle.battlelogic.skillandeffect.BattleSingleEffect;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.stage.BattleStage;
	
	import sysdata.Skill;
	import sysdata.SkillElement;
	
	import utils.BattleEffectConfig;
	import utils.TroopActConfig;

	/**
	 * 处理各种效果的功能类 
	 * @author SDD
	 * 
	 */
	public class SkillEffectFunc
	{
		public function SkillEffectFunc()
		{
		}
		
		/**
		 * 奥义技能 
		 * @param troopInfo
		 * @return 
		 */
		public static function newSkillForAoYi(troopInfo:CellTroopInfo):Skill
		{
			return troopInfo.attackUnit.contentHeroInfo.heroaoyi;
		}
		
		/**
		 * 英雄技能 
		 * @param troopInfo
		 * @return 
		 */
		public static function getHeroSkillOnAttack(troopInfo:CellTroopInfo):Skill
		{
//			if(troopInfo.moraleValue < BattleValueDefine.moraleGapToSkillAttack)
//				return null;
//			if(BattleInfoSnap.zhudongjinengChuFaInfo.hasOwnProperty(troopInfo.troopIndex))
//				return null;
			var moraleLevel:int = 0;
			if(troopInfo.moraleValue >= BattleValueDefine.maxMoraleValue)
				moraleLevel = 1;
			
			var allSkillInfo:Array;
			if(!troopInfo.heroPropertyStore.hasOwnProperty("allskillInfo"))
			{
				allSkillInfo = TroopFunc.getAllSkillsOfTroop(troopInfo);
				troopInfo.heroPropertyStore["allskillInfo"] = allSkillInfo;
			}
			else
			{
				allSkillInfo = troopInfo.heroPropertyStore["allskillInfo"] as Array;
			}
			if(allSkillInfo.length == 0 && troopInfo.ownerSide == BattleDefine.firstAtk)
			{
				var fakeSkillInfo:Skill = new Skill;
				fakeSkillInfo.elements = [new SkillElement(SpecialEffectDefine.FuJiaGongJi,0,0,0,AttackRangeDefine.duotiGongJi1)];
				allSkillInfo = [fakeSkillInfo];
			}
			var targetInfo:Skill = null;
			moraleLevel = Math.min(moraleLevel,allSkillInfo.length - 1);
			while((targetInfo == null || targetInfo.elements.length <= 0) && moraleLevel >= 0)
			{
				targetInfo = allSkillInfo[moraleLevel--];
			}
			var realRetSkillInfo:Skill;
			if(targetInfo)
			{
				realRetSkillInfo = new Skill();
				var weaponSkill:Array = [targetInfo,allSkillInfo[3],allSkillInfo[4],allSkillInfo[5]];
				for(var i:int = 0;i < weaponSkill.length;i++)
				{
					var singleTempSkill:Skill = weaponSkill[i];
					if(singleTempSkill == null || singleTempSkill.elements == null || singleTempSkill.elements.length <= 0)
						continue;
					for(var eIndex:int = 0;eIndex < singleTempSkill.elements.length;eIndex++)
					{
						realRetSkillInfo.elements.push(singleTempSkill.elements[eIndex]);
					}
				}
				BattleInfoSnap.zhudongjinengChuFaInfo[troopInfo.troopIndex] = 1;
			}
			return realRetSkillInfo;
		}
		
		/**
		 * 主动技能 (新技能)
		 * @return 
		 */
		public static function getArmSkillOnAttack(troopInfo:CellTroopInfo):Skill
		{
//			if(BattleInfoSnap.zhudongjinengChuFaInfo.hasOwnProperty(troopInfo.troopIndex))
//				return null;
			
			var retArray:Array=[];
			
			var allSkillInfo:Array;
			
			if(!troopInfo.heroPropertyStore.hasOwnProperty("allskillInfo"))
			{
				allSkillInfo = TroopFunc.getAllSkillsOfTroop(troopInfo);
				troopInfo.heroPropertyStore["allskillInfo"] = allSkillInfo;
			}
			else
			{
				allSkillInfo = troopInfo.heroPropertyStore["allskillInfo"] as Array;
			}
			
			var singleSkill:Skill;
			for(var i:int = 0; i < allSkillInfo.length; i++)
			{
				singleSkill = allSkillInfo[i] as Skill;
				if(singleSkill && (singleSkill.skilltrigger == SkillTrigger.zhudong))
					retArray.push(singleSkill);
			}
			var retSkill:Skill = SkillEffectFunc.getSkillToWork(troopInfo,retArray,true);
			if(retSkill)
			{
				BattleInfoSnap.zhudongjinengChuFaInfo[troopInfo.troopIndex] = 1;
			}
			return retSkill;
		}
		
		/**
		 * 被动技能 (新技能)
		 * @param	troopInfo 攻击方   用于取得攻击类型
		 * @param   isFanji		是否为反击
		 * @param	generateSkillAllowed		是否允许发动被动技能
		 * @return 
		 */
		public static function newSkillGeneratedOnDefense(troopInfo:CellTroopInfo,chainInfo:CombatChain,isFanji:Boolean = true,
												   generateSkillAllowed:Boolean = false):Skill
		{
			if(isFanji)
				return null;
			if(!generateSkillAllowed)
				return null;
			
			if(BattleInfoSnap.beidongjinengChuFaInfo.hasOwnProperty(troopInfo.troopIndex))
				return null;
			
			if(troopInfo.logicStatus == LogicSatusDefine.lg_status_filling || troopInfo.mcStatus == McStatusDefine.mc_status_running)
				return null;
			
			var retArray:Array=[];
			
			var allSkillInfo:Array;
			
			if(!troopInfo.heroPropertyStore.hasOwnProperty("allskillInfo"))
			{
				allSkillInfo = TroopFunc.getAllSkillsOfTroop(troopInfo);
				troopInfo.heroPropertyStore["allskillInfo"] = allSkillInfo;
			}
			else
			{
				allSkillInfo = troopInfo.heroPropertyStore["allskillInfo"] as Array;
			}
			
			var atkTroopInfo:CellTroopInfo = chainInfo.sourceTroop;
			
			if(atkTroopInfo == null)
				return null;
			
			var singleSkill:Skill;
			for(var i:int = 0; i < allSkillInfo.length; i++)
			{
				singleSkill = allSkillInfo[i] as Skill;
				if(singleSkill)
				{
					if(singleSkill.skilltrigger == SkillTrigger.quanbeidong)
						retArray.push(singleSkill);
					else if(singleSkill.skilltrigger == SkillTrigger.yuanbeidong)
						retArray.push(singleSkill);
					else if(singleSkill.skilltrigger == SkillTrigger.jinbeidong && BattleFunc.checkDistanceOfTroops(troopInfo,atkTroopInfo) == 0)
						retArray.push(singleSkill);
				}
			}
			var retSkill:Skill = SkillEffectFunc.getSkillToWork(troopInfo,retArray,false,chainInfo.atkTroopIndex);
			BattleInfoSnap.beidongjinengChuFaInfo[troopInfo.troopIndex] = 1;
			return retSkill;
		}
		
		/**
		 * 从一系列技能中取出此次随机的技能 
		 * @param arr
		 * @return 
		 */
		public static function getSkillToWork(troopInfo:CellTroopInfo,arr:Array,isZhudong:Boolean,sourceTroopIndex:int = 0):Skill
		{
//			if(BattleInfoSnap.needControlBattle)
//				return null;
			if(arr == null || arr.length == 0)
				return null;
			
			var i:int = 0;
			var singleSkill:Skill;
			
			var totalRate:Number = 0;
			for(i = 0; i < arr.length; i++)
			{
				singleSkill = arr[i] as Skill;
				totalRate += singleSkill.skillrate;
			}
			
			var singleRealRate:Number;
			
			var rate:Number = 0;
			if(isZhudong)
				rate = RandomValueService.getRandomValue(RandomValueService.RD_SKILLCHOOSE,troopInfo.troopIndex);
			else
			{
				rate = RandomValueService.getRandomValue(RandomValueService.RD_BDSKILLCHOOSE,troopInfo.troopIndex,sourceTroopIndex);
			}
			var lastCheckGap:Number = 0;
			
			for(i  = 0; i < arr.length; i++)
			{
				singleSkill = arr[i] as Skill;
				singleRealRate = singleSkill.skillrate / totalRate;
				
				if(rate < singleRealRate + lastCheckGap)			//如果概率落在此区间
				{
					break;
				}
				lastCheckGap += singleRealRate;
			}
			
			if(singleSkill)					//判断此技能是否触发
			{
				var chufaGailv:Number = 0;
				if(TroopFunc.hasSpecificEffect(troopInfo,SpecialEffectDefine.noSkillChuFa))
				{
					singleSkill = null;
				}
				else if(!TroopFunc.hasSpecificEffect(troopInfo,SpecialEffectDefine.jiNengChuFa))			//如果有技能触发效果，直接触发
				{
					if(isZhudong)
					{
						chufaGailv = RandomValueService.getRandomValue(RandomValueService.RD_SKILLCHUFA,troopInfo.troopIndex);
						if(chufaGailv >= singleSkill.skillrate)
							singleSkill = null;
					}
					else
					{
						chufaGailv = RandomValueService.getRandomValue(RandomValueService.RD_BDSKILLCHUFA,troopInfo.troopIndex,sourceTroopIndex);
						if(chufaGailv >= singleSkill.skillrate)
							singleSkill = null;
					}
				}
				else
				{
//					trace("技能必然触发");
				}
			}
			
			//将目标为当前攻击目标的effect排列到最后
			sortSkill(singleSkill);
			
			return singleSkill;
		}
		
		/**
		 * 排列技能 
		 * @param sourceSkill
		 */
		private static function sortSkill(sourceSkill:Skill):void
		{
			if(sourceSkill == null)
				return;
			var targetEffects:Array=[];
			for(var i:int = 0;i < sourceSkill.elements.length;i++)
			{
				var singleEffect:SkillElement = sourceSkill.elements[i];
				if(singleEffect && singleEffect.target == AttackRangeDefine.zijiZhunBeiGongJi)
				{
					targetEffects.push(singleEffect);
					sourceSkill.elements.splice(i,1);
					i--;
				}
			}
			for(i = 0;i < targetEffects.length;i++)
			{
				sourceSkill.elements.push(targetEffects[i]);
			}
		}
		
		/**
		 * 获得过滤过的技能效果
		 */
		public static function getFiltedBattleSingleEffects(skill:Skill):Array
		{
			var retArr:Array=[];
			
			if(skill == null)
				return retArr;
			
			var hasNLianJi:Boolean = false;
			
			var i:int = 0;
			var singleSkillElement:SkillElement;
			var lianjieCount:int = 0;
			for(i = 0; i < skill.elements.length;i++)
			{
				singleSkillElement = skill.elements[i] as SkillElement;
				if(singleSkillElement == null)
					continue;
				if(singleSkillElement.buffeid == SpecialEffectDefine.NLianJi)
				{
					hasNLianJi = true;
					lianjieCount = singleSkillElement.buffValue;
					break;
				}
			}
			
			var lianjiEffect:BattleSingleEffect;
			if(hasNLianJi)
			{
				lianjiEffect = new BattleSingleEffect(singleSkillElement);
				var lianjiArr:Array=[];
				retArr.push(lianjiEffect);
			}
			
			var curCount:int = 0;
			
			for(i = 0; i < skill.elements.length;i++)
			{
				singleSkillElement = skill.elements[i] as SkillElement;
				if(singleSkillElement == null)
					continue;
				if(curCount < lianjieCount && singleSkillElement.buffeid == SpecialEffectDefine.ShangHaiShuChuZengJia &&
					singleSkillElement.target == AttackRangeDefine.woFangZiJi)
				{
					lianjiArr.push(singleSkillElement.buffValue);
					curCount++;
				}
				else if(singleSkillElement.buffeid != SpecialEffectDefine.NLianJi)
				{
					retArr.push(new BattleSingleEffect(singleSkillElement));
				}
			}
			if(lianjiEffect)
				lianjiEffect.effectValue = lianjiArr;
			
			return retArr;
		}
		
		/**
		 * 光环类的skill 
		 * @return 
		 */
		public static function getGuanghuangSkill(troopInfo:CellTroopInfo):Array
		{
			var retArray:Array=[];
			
			var allSkillInfo:Array;
			
			if(!troopInfo.heroPropertyStore.hasOwnProperty("allskillInfo"))
			{
				allSkillInfo = TroopFunc.getAllSkillsOfTroop(troopInfo);
				troopInfo.heroPropertyStore["allskillInfo"] = allSkillInfo;
			}
			else
			{
				allSkillInfo = troopInfo.heroPropertyStore["allskillInfo"] as Array;
			}
			
			var singleSkill:Skill;
			for(var i:int = 0; i < allSkillInfo.length; i++)
			{
				singleSkill = allSkillInfo[i] as Skill;
				if(singleSkill && (singleSkill.skilltrigger == SkillTrigger.guanghuan))
					retArray.push(singleSkill);
			}
			return retArray;
		}
		
		/**
		 * 判断此chain是否是可以被闪避的 
		 * @return 
		 */
		public static function checkCanBeEvade(chainInfo:CombatChain):Boolean
		{
			var res:Boolean = false;
			//N连击  附加攻击 或者 普通伤害攻击是可以被闪避的
			
			if(chainInfo.atkTroopIndex == chainInfo.defTroopIndex)
				res = false;
			else
				res = ChainFunc.hasSomeNewGeneratedEffect(chainInfo,SpecialEffectDefine.ShangHaiShuChuZengJia,false);
			return res;
		}
		
		/**
		 * 判断buf类型 
		 * @param bufId
		 * @return 
		 */
		public static function checkbufType(effect:int):int
		{
			var type:int = BattleTypeDefine.atkBuff;			
			switch(effect)
			{
				case SpecialEffectDefine.ZhongDu:
				case SpecialEffectDefine.XuanYun:
				case SpecialEffectDefine.jiNengChuFa:
				case SpecialEffectDefine.shiQiEWaiZengJia:
				case SpecialEffectDefine.HPShangXianZengJia:
					type = BattleTypeDefine.bothBuff;
					break;
				case SpecialEffectDefine.XiXue:
				case SpecialEffectDefine.ZengJianHP:
				case SpecialEffectDefine.ShangHaiShuChuZengJia:
				case SpecialEffectDefine.NLianJi:
				case SpecialEffectDefine.FuJiaGongJi:
				case SpecialEffectDefine.BaoJiZengJia:
				case SpecialEffectDefine.ShangHaiZengJia:
				case SpecialEffectDefine.BaoJi:
				case SpecialEffectDefine.bingLiBuChong:
				case SpecialEffectDefine.jueduiMingZhong:
				case SpecialEffectDefine.shengmingHuiFu:	
					type = BattleTypeDefine.atkBuff;
					break;
				case SpecialEffectDefine.WuLiShangHaiMianYi:
				case SpecialEffectDefine.MoFaShangHaiMianYi:
				case SpecialEffectDefine.FanJi:
				case SpecialEffectDefine.ShangHaiFanTan:
				case SpecialEffectDefine.ShiQiZengJia:
				case SpecialEffectDefine.ShanBiZengJia:
				case SpecialEffectDefine.ShanBi:
				case SpecialEffectDefine.weiMingZhong:
				case SpecialEffectDefine.shanghaiXiShou:
				case SpecialEffectDefine.baohuqiang:
					type = BattleTypeDefine.defBuff;
					break;
			}
			return type;
		}
		
		/**
		 * 得到加入某个效果的cell的位置 
		 * @param troopInfo					触发效果的troop
		 * @param isMirrored				效果是否镜像
		 * @return 
		 */
		public static function getEffectPos(troopInfo:CellTroopInfo,isAttack:Boolean,mcIndex:int,isMirrored:Boolean,atkTroop:CellTroopInfo):Point
		{
			var retPoint:Point = new Point(0,0);
			if(troopInfo == null)
				return retPoint;
			
			if(troopInfo.ownerSide == BattleDefine.firstAtk)
			{
				retPoint.x = troopInfo.x + troopInfo.startPos.x;
				retPoint.y = troopInfo.y - troopInfo.startPos.y;
			}
			else
			{
				retPoint.x = troopInfo.x - troopInfo.startPos.x;
				retPoint.y = troopInfo.y - troopInfo.startPos.y;
			}
			
			retPoint.x = troopInfo.x;
			retPoint.y = troopInfo.y;
			
			var troopActPos:Point;								//获得此troop的偏移地点
			if(isAttack)
			{
				troopActPos = TroopActConfig.getAttackSoucePos(troopInfo.mcIndex);			
			}
			else
			{
				troopActPos = TroopActConfig.getBearPoint(troopInfo.mcIndex);
			}
			//效果的中心点
			var effectCenterPoint:Point = BattleEffectConfig.getEffectCenter(mcIndex);
			
			var isAtk:Boolean = troopInfo.ownerSide == BattleDefine.firstAtk;			//是否为攻击方	是否为镜像
			
			if(!isAtk)
			{
				if(!isMirrored)					//troop没有镜像，效果无镜像
				{
					retPoint.x -= effectCenterPoint.x;
					retPoint.x += troopActPos.x;
				}
				else							//troop没有镜像，效果有镜像			（ex,被弓箭击中）
				{
					retPoint.x += effectCenterPoint.x;
					retPoint.x += troopActPos.x;
				}
				retPoint.y -= effectCenterPoint.y;
				retPoint.y += troopActPos.y;
				
				if(atkTroop)			//被攻击时需要计算正对目标在y值上的偏移，计算打击点
				{
					retPoint = BattleStage.instance.effectLayer.getAttackedEffectPos(atkTroop,troopInfo,retPoint);
				}
			}
			else
			{
				if(isMirrored)					//troop镜像，效果镜像				(ex:被攻击，发出弓箭等)
				{
					retPoint.x += BattleDisplayDefine.cellWidth;
					retPoint.x -= troopActPos.x;
					retPoint.x += effectCenterPoint.x;
					
					retPoint.y -= effectCenterPoint.y;
					retPoint.y += troopActPos.y;
				}
				else							//troop镜像，效果未镜像				(ex:被弓箭击中)
				{
					retPoint.x += BattleDisplayDefine.cellWidth;
					retPoint.x -= troopActPos.x;
					retPoint.x -= effectCenterPoint.x;
					
					retPoint.y -= effectCenterPoint.y;
					retPoint.y += troopActPos.y;
				}
			}
			return retPoint;
		}
		
		/**
		 * 获得skill中某个单个效果信息 
		 * @param skillInfo
		 * @param effectId
		 * @return 
		 */
		public static function getParticularEffect(skillInfo:Skill,effectId:int):SkillElement
		{
			var resElement:SkillElement = null;
			if(skillInfo == null)
				return resElement;
			
			for(var i:int = 0;i < skillInfo.elements.length;i++)
			{
				var singleElement:SkillElement = skillInfo.elements[i];
				if(singleElement && singleElement.buffeid == effectId)
				{
					resElement = singleElement;
					break;
				}
			}
			return resElement;
		}
		
	}
}