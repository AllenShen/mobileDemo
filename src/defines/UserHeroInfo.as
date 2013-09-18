package defines
{
	import macro.ArmType;
	import macro.SuitUnlockInfo;
	import macro.UnlockRequirement;
	import macro.WuXingType;
	
	import sysdata.Skill;
	import sysdata.SkillUnlockInfo;
	import sysdata.UnlockElementInfo;
	import sysdata.WuxingSlotInfo;
	
	import tools.textengine.TextEngine;

	/**
	 * 用户的英雄信息
	 * 所有的英雄属性和装备相关的，记录两个值：未穿装备时的属性，穿了装备时的属性
	 * 
	 * @author fangc
	 */
	public class UserHeroInfo
	{
		//id
		public var userheroid:int;
		//用户id
		public var uid:int;
		//英雄id
		public var heroid:int;
		//英雄名字
		public var heroname:int;
		public var namestr:String;
		//英雄品质
		public var rarelevel:int;
		//英雄的攻击类型
		public var herotype:int;
		//等级
		public var herolevel:int;
		//经验
		public var heroexp:int;
		//是否有士气
		public var hasmorale:int;
		//五行槽
		public var slotinfo:Array;
		//石头的技能
		//public var stoneeffects:Array;
		//实际五行值
		public var wuxing:Array;
		//不穿装备时的五行值
		public var basewuxing:Array;
		//五行天性
		public var giftwuxing:Array;
		//实际武力值
		public var wuli:int;
		//不穿装备时的武力值
		public var basewuli:int;
		//实际智力值
		public var zhili:int;
		//不穿装备时的智力值
		public var basezhili:int;
		//实际霸气值
		public var baqi:int;
		//不穿装备时的霸气值
		public var basebaqi:int;
		//实际物理攻击
		public var pattack:int;
		//不穿装备时的物理攻击
		public var basepattack:int;
		//实际魔法攻击
		public var mattack:int;
		//不穿装备时的魔法攻击
		public var basemattack:int;
		//实际物理防御
		public var pdefence:int;
		//不穿装备时的物理防御
		public var basepdefence:int;
		//实际的魔法防御
		public var mdefence:int;
		//不穿装备时的魔法防御
		public var basemdefence:int;
		//实际带兵量
		public var amount:Array;
		//不穿装备时的带兵量
		public var baseamout:int;
		//带兵增长
		public var amountincrement:int;
		//基础技能伤害
		public var baseskilldamage:int;
		//当前技能伤害
		public var skilldamage:Number;
		//英雄暴击
		public var herocrit:Number;
		//影响士兵魔法命中
		public var skillrateadd:Number;
		public var mofamingzhongadd:Number;
		//影响士兵hp
		public var hpadd:Number;
		//影响士兵伤害
		public var damageadd:Number;
		//影响士兵暴击
		public var critadd:Number;
		//影响士兵闪避
		public var dodgeadd:Number;
		//增加某种兵的带兵量：[armid, value]
		public var amountability:Array;
		//增加某种兵的伤害值：[armid, value]
		public var damageability:Array;
		//增加某种兵的抗性：[armid, value]
		public var defenseability:Array;
		//已解锁功能[id1,id2...]
		public var unlockskills:Array;
		//待解锁技能：[[{"水":300,"火":300},id],[{"水":300,"火":300},id],[{"水":300,"火":300},id]]
		public var heroskills:Array;
		public var heroaoyi:Skill;
		//套装装备信息: [[suitid,num],[suitid,num]...]
		public var suitinfo:Array;
		public var suitskills:Array;
		//英雄头像
		public var heroportrait:int;
		//英雄描述
		public var herodesc:String;
		//英雄当前状态：已雇佣，可雇用
		public var herostate:int;
		//可分配五行值
		public var potential:int;
		//有时效的buff
		public var tempbuffs:Array;
		//动画表现
		public var effectid:int;
		public var fightpower:int;//英雄战斗力
		public var activestate:int;//英雄活动状态
		public var istraining:int;//是否在训练
		public var buyedskills:Array;
		
		public var forgelevel:int=0;//融合次数
		public var baseheroid:int;//基础英雄id
		
		public function LoadBattlePacket(info:Array):void
		{
			this.userheroid = info.shift();
			this.uid = info.shift();
			this.heroid = info.shift();
			this.herotype = info.shift();
			this.heroexp = info.shift();
			this.herolevel = info.shift();
			this.hasmorale = info.shift();
			this.pattack = info.shift();
			this.mattack = info.shift();
			this.pdefence = info.shift();
			this.mdefence = info.shift();
			this.amount=info.shift();
			
			var arr:Array = info.shift();//已解锁功能[[id1,rate],[id2,rate]...]
			if(arr)
			{
				unlockskills =[];
				for(var i:int = 0;i < arr.length;i++)
				{
					var subarr:Array = arr[i];
					if(subarr == null)
					{
						unlockskills.push(null);
					}
					else
					{
						var skillid:int = subarr.shift();
						var skillrate:Number = subarr.shift();
						var skill:Skill = null;
						if(skill)
						{
							var newskill:Skill = new Skill();
							newskill.copyData(skill);
							newskill.skillrate = skillrate;
							unlockskills.push(newskill);
						}
						else
						{
							unlockskills.push(skill);
						}
					}
				}
			}

			var aoyiarr:Array = info.shift();//英雄奥义
			if(aoyiarr){
				var aoyi:Skill = null;
				if(aoyi){
					heroaoyi = new Skill();
					heroaoyi.copyData(aoyi);
					heroaoyi.skillrate = int(aoyiarr[1]);
				}
			}
			
			this.heroportrait = info.shift();
			this.effectid = info.shift();
			this.skilldamage = info.shift();
			this.herocrit = info.shift();
		}
		
		public function MakeAverageHero(heroes:Array):void
		{
			var seed:int=heroes.length;
			for(var index:int=0;index<heroes.length;index++)
			{
				pattack+=heroes[index].pattack;
				mattack+=heroes[index].mattack;
				pdefence+=heroes[index].pdefence;
				mdefence+=heroes[index].mdefence;

				heroportrait+=heroes[index].heroportrait;
				effectid+=heroes[index].effectid;
				skilldamage+=heroes[index].skilldamage;
				herocrit+=heroes[index].herocrit;
			}
			
			pattack=pattack/seed;
			mattack=mattack/seed;
			pdefence=pdefence/seed;
			mdefence=mdefence/seed;
			
			heroportrait=heroportrait/seed;
			effectid=effectid/seed;
			skilldamage=skilldamage/seed;
			herocrit=herocrit/seed;
		}
		
		public function MakeBattlePacket():Array
		{
			var packet:Array=[];
			packet.push(userheroid);
			packet.push(uid);
			packet.push(heroid);
			packet.push(herotype);
			packet.push(heroexp);
			packet.push(herolevel);
			packet.push(hasmorale);
			packet.push(pattack);
			packet.push(mattack);
			packet.push(pdefence);
			packet.push(mdefence);
//			packet.push(amount);
//			packet.push(unlockskills);
			packet.push(heroportrait);
			packet.push(effectid);
			packet.push(skilldamage);
			packet.push(herocrit);
			
			return packet;
		}
		
		public function getUnlockSkillsSnap():Array
		{
			var arr:Array=[];
			for(var i:int = 0;i< this.unlockskills.length;i++)
			{
				var singleSkill:Skill = this.unlockskills[i] as Skill;
				if(singleSkill == null)
				{
					arr[i] = null;
				}
				else
				{
					arr[i] = [singleSkill.skillid,singleSkill.skillrate];
				}
			}
			return arr;
		}
		
		public function UserHeroInfo()
		{
		}
		
		public function fromArray(data:Array):void
		{
			if(data)
			{
				userheroid = int(data.shift());//标识
				uid = int(data.shift());//用户id
				heroid = int(data.shift());//英雄id
				heroname = int(data.shift());//英雄名字
				rarelevel = int(data.shift());//英雄品质
				herotype = int(data.shift());//英雄的攻击类型
				herolevel = int(data.shift());//等级
				heroexp = int(data.shift());//经验
				hasmorale = int(data.shift());//是否有士气
				
				var slotinfoarr:Array = data.shift();
				if(slotinfoarr)
				{
					this.slotinfo =[];
					for each(var slotinfoobj:Array in slotinfoarr){
						var slotInfo:WuxingSlotInfo = new WuxingSlotInfo();
						slotInfo.fromArray(slotinfoobj);
						this.slotinfo.push(slotInfo);
					}
				}
				
				wuxing = data.shift();//实际五行值
				
				basewuxing = data.shift();//不穿装备时的五行值
				
				pattack = int(data.shift());//实际物理攻击
				basepattack = int(data.shift());//不穿装备时的物理攻击
				mattack = int(data.shift());//实际魔法攻击
				basemattack = int(data.shift());//不穿装备时的魔法攻击
				pdefence = int(data.shift());//实际物理防御
				basepdefence = int(data.shift());//不穿装备时的物理防御
				mdefence = int(data.shift());//实际的魔法防御
				basemdefence = int(data.shift());//不穿装备时的魔法防御
				amount = data.shift();//实际带兵量
				
				baseamout = int(data.shift());//不穿装备时的带兵量
				amountincrement = int(data.shift());//带兵增长
				baseskilldamage = int(data.shift());//不穿装备时的技能伤害
				skilldamage =  Number(data.shift());//技能伤害增加
				herocrit = Number(data.shift());//英雄暴击上限
				
				mofamingzhongadd = Number(data.shift());//影响士兵命中
				skillrateadd = Number(data.shift());//影响士兵技能触发
				hpadd = Number(data.shift());//影响士兵hp
				damageadd = Number(data.shift());//影响士兵伤害
				critadd = Number(data.shift());//影响士兵暴击
				dodgeadd = Number(data.shift());//影响士兵闪避
				
				var arr:Array = data.shift();//已解锁功能[[id1,rate],[id2,rate]...]
				if(arr)
				{
					unlockskills =[];
					for each(var subarr:Array in arr){
						var skillid:int = subarr.shift();
						var skillrate:Number = subarr.shift();
						
					}
				}
				
				var heroskillarr:Array = data.shift();//待解锁技能：[[{"水":300,"火":300},id],[{"水":300,"火":300},id],[{"水":300,"火":300},id]]
				if(heroskillarr)
				{
					this.heroskills =[];
					for each(var unlockobj:Array in heroskillarr){
						var skillunlockInfo:SkillUnlockInfo = new SkillUnlockInfo();
						skillunlockInfo.FromArray(unlockobj);
						this.heroskills.push(skillunlockInfo);
					}
				}
				
				var aoyiarr:Array = data.shift();//英雄奥义
				if(aoyiarr){
				}
				
				var suitinfoarr:Array = data.shift()//套装装备信息
				if(suitinfoarr)
				{
					this.suitinfo =[];
					this.suitskills =[];
					for each(var suitobj:Array in suitinfoarr){
						var suitarr:Array=[];
						suitarr.push(suitobj[0]);
						suitarr.push(suitobj[1]);
						suitinfo.push(suitarr);
					}
				}
				
				heroportrait = int(data.shift());//英雄头像
				herodesc = data.shift();//英雄描述
				herostate = int(data.shift());//英雄当前状态：已雇佣，可雇用
				
				effectid = int(data.shift());//动画表现
				fightpower = int(data.shift());//英雄战斗力
				
				activestate = int(data.shift());//英雄活动状态
				istraining = int(data.shift());//是否在训练
				
				buyedskills = data.shift();
				forgelevel=data.shift();
				baseheroid=data.shift();
				
				
				if (forgelevel>0)
				{
					namestr=TextEngine.getTextById(20283)+TextEngine.getTextById(heroname);
				}
				else
				{
					namestr=(baseheroid>0?TextEngine.getTextById(20282):"")+TextEngine.getTextById(heroname);
				}
			}
		}
		
		public function copy(srcUserHeroInfo:UserHeroInfo):void
		{
			this.userheroid = srcUserHeroInfo.userheroid;
			this.uid = srcUserHeroInfo.uid;
			this.heroid = srcUserHeroInfo.heroid;
			this.heroname = srcUserHeroInfo.heroname;
			this.namestr = srcUserHeroInfo.namestr;
			this.rarelevel = srcUserHeroInfo.rarelevel;
			this.herotype = srcUserHeroInfo.herotype;
			this.herolevel = srcUserHeroInfo.herolevel;
			this.heroexp = srcUserHeroInfo.heroexp;
			this.hasmorale = srcUserHeroInfo.hasmorale;
			this.slotinfo =[];
			var i:int = 0;
			if(srcUserHeroInfo.slotinfo){
				for(i=0;i<srcUserHeroInfo.slotinfo.length;i++){
					if(srcUserHeroInfo.slotinfo[i]){
						this.slotinfo.push((srcUserHeroInfo.slotinfo[i] as WuxingSlotInfo).clone());
					}
				}
			}
			/*this.stoneeffects ={};
			if(srcUserHeroInfo.stoneeffects){
				for(i=0;i<srcUserHeroInfo.stoneeffects.length;i++){
					this.stoneeffects.push((srcUserHeroInfo.stoneeffects[i] as NormalEffectInfo));
				}
			}*/
			this.wuxing =[];
			if(srcUserHeroInfo.wuxing){
				for(i=0;i<srcUserHeroInfo.wuxing.length;i++){
					this.wuxing.push(srcUserHeroInfo.wuxing[i]);
				}
			}
			this.basewuxing =[];
			if(srcUserHeroInfo.basewuxing){
				for(i=0;i<srcUserHeroInfo.basewuxing.length;i++){
					this.basewuxing.push(srcUserHeroInfo.basewuxing[i]);
				}
			}
			this.giftwuxing =[];
			if(srcUserHeroInfo.giftwuxing){
				for(i=0;i<srcUserHeroInfo.giftwuxing.length;i++){
					this.giftwuxing.push(srcUserHeroInfo.giftwuxing[i]);
				}
			}
			
			this.pattack = srcUserHeroInfo.pattack;
			this.basepattack = srcUserHeroInfo.basepattack;
			this.mattack = srcUserHeroInfo.mattack;
			this.basemattack = srcUserHeroInfo.basemattack;
			this.pdefence = srcUserHeroInfo.pdefence;
			this.basepdefence = srcUserHeroInfo.basepdefence;
			this.mdefence = srcUserHeroInfo.mdefence;
			this.basemdefence = srcUserHeroInfo.basemdefence;
			this.amount =[];
			if(srcUserHeroInfo.amount){
				for(i=0;i<srcUserHeroInfo.amount.length;i++){
					this.amount.push(srcUserHeroInfo.amount[i]);
				}
			}
			this.baseamout = srcUserHeroInfo.baseamout;
			this.amountincrement = srcUserHeroInfo.amountincrement;
			this.baseskilldamage = srcUserHeroInfo.baseskilldamage;
			this.skilldamage = srcUserHeroInfo.skilldamage;
			this.herocrit = srcUserHeroInfo.herocrit;
			this.skillrateadd = srcUserHeroInfo.skillrateadd;
			this.mofamingzhongadd = srcUserHeroInfo.mofamingzhongadd;
			this.hpadd = srcUserHeroInfo.hpadd;
			this.damageadd = srcUserHeroInfo.damageadd;
			this.critadd = srcUserHeroInfo.critadd;
			this.dodgeadd = srcUserHeroInfo.dodgeadd;
			
			this.unlockskills =[];
			if(srcUserHeroInfo.unlockskills){
				for(i=0;i<srcUserHeroInfo.unlockskills.length;i++){
					if(srcUserHeroInfo.unlockskills[i])
					{
						var newskill:Skill = new Skill();
						newskill.copyData(srcUserHeroInfo.unlockskills[i] as Skill);
						this.unlockskills.push(newskill);
					}else
					{
						this.unlockskills.push(null);
					}
				}
			}
			this.heroaoyi = null;
			if(srcUserHeroInfo.heroaoyi){
				this.heroaoyi = new Skill();
				this.heroaoyi.copyData(srcUserHeroInfo.heroaoyi);
			}
			this.heroskills =[];
			if(srcUserHeroInfo.heroskills){
				for(i=0;i<srcUserHeroInfo.heroskills.length;i++){
					this.heroskills.push((srcUserHeroInfo.heroskills[i] as SkillUnlockInfo).clone());
				}
			}
			this.suitinfo =[];
			if(srcUserHeroInfo.suitinfo){
				for(i=0;i<srcUserHeroInfo.suitinfo.length;i++){
					this.suitinfo.push([srcUserHeroInfo.suitinfo[i][0], srcUserHeroInfo.suitinfo[i][1]]);
				}
			}
			this.suitskills =[];
			if(srcUserHeroInfo.suitskills){
				for(i=0;i<srcUserHeroInfo.suitskills.length;i++){
					var suitskillinfoarr:Array = srcUserHeroInfo.suitskills[i] as Array;
					this.suitskills.push([(suitskillinfoarr[0] as SuitUnlockInfo).clone(), suitskillinfoarr[1], suitskillinfoarr[2]]);
				}
			}
			this.heroportrait = srcUserHeroInfo.heroportrait;
			this.herodesc = srcUserHeroInfo.herodesc;
			this.herostate = srcUserHeroInfo.herostate;
			//			this.tempbuffs:Array;
			this.effectid = srcUserHeroInfo.effectid;
			this.fightpower = srcUserHeroInfo.fightpower;
			this.activestate = srcUserHeroInfo.activestate;
			this.istraining = srcUserHeroInfo.istraining;
			
			this.buyedskills =[];
			if(srcUserHeroInfo.buyedskills){
				for(i=0;i<srcUserHeroInfo.buyedskills.length;i++){
					this.buyedskills.push(srcUserHeroInfo.buyedskills[i]);
				}
			}
			
			forgelevel=srcUserHeroInfo.forgelevel;
			baseheroid=srcUserHeroInfo.baseheroid;
		}
		
		public function calAllCanuseSkills():void
		{
//			var i:int = 0;
//			i = this.unlockskills?this.unlockskills.length:0;
//			while(i <= 2)
//			{
//				this.unlockskills.push(null);
//				i++;
//			}
//			var weapon:UserEquipmentInfo = GlobalData.owner.userEquips.getHeroEquipByType(this.userheroid, EquipmentType.WEAPON);
//			
//			i = 0;
//			var len:int = 0;
//			if( weapon && weapon.unlockskills){
//				for(i=0,len=weapon.unlockskills.length;i<len;i++){
//					var newskill:Skill = new Skill();
//					newskill.copyData(weapon.unlockskills[i] as Skill);
//					this.unlockskills.push(newskill);
//				}
//			}
//			while(i <= 2)
//			{
//				this.unlockskills.push(null);
//				i++;
//			}
//			
//			i = 0;
//			var j:int=0;
//			for(len=this.suitskills.length;j<len;j++){
//				var suitskillarr:Array = this.suitskills[j] as Array;
//				if(!suitskillarr)
//					continue;
//				
//				var suitUnlockInfo:SuitUnlockInfo = suitskillarr[0] as SuitUnlockInfo;
//				var effect:* = suitUnlockInfo.getEffect();
//				if(effect is Skill)
//				{
//					i++;
//					var suitskill:Skill = new Skill();
//					suitskill.copyData(effect as Skill);
//					this.unlockskills.push(suitskill);
//				}
//			}
//			while(i <= 2)
//			{
//				this.unlockskills.push(null);
//				i++;
//			}
		}
		
		public function clone():UserHeroInfo
		{
			var userHeroInfo:UserHeroInfo = new UserHeroInfo();
			
			userHeroInfo.copy(this);
			
			return userHeroInfo;
		}
		
		public function getHeroShowSkills():Array
		{
			var ret:Array=[];
			for each(var skillunlockInfo:SkillUnlockInfo in heroskills){
				var data:Array=[];
				var wuxingunlockelement:UnlockElementInfo;
				var show:Boolean = true;
				var wuxinglocked:Boolean = false;
				var unlocklevel:int = 0;
				for each(var unlockElement:UnlockElementInfo in skillunlockInfo.unlockRequiredments){
					if(unlockElement.type == UnlockRequirement.heroLevel){
						unlocklevel = unlockElement.value;
						if(this.herolevel < unlockElement.value){
							if(this.buyedskills == null || this.buyedskills.indexOf(skillunlockInfo.skillid) == -1)
							{
								show = false;
							}
						}
					}else{
						wuxingunlockelement = unlockElement;
						if(wuxingunlockelement.value > this.wuxing[wuxingunlockelement.type-1]){
							wuxinglocked = true;
						}
					}
				}
				
				data.push(skillunlockInfo.skillid);
				data.push(wuxingunlockelement);
				data.push(show);
				data.push(wuxinglocked);
				data.push(unlocklevel);
				data.push(this.rarelevel);
				ret.push(data);
			}
			
			return ret;
		}
		
		public function addHeroExp(exp:int):int
		{
			var levelup:Boolean = false;
			this.heroexp += exp;
			var crosslevel:int = 0;
			while(checkLevelup()){
				levelup = true;
				crosslevel++;
			}
			if(levelup){
				this.onLevelUp();
			}
			return crosslevel;
		}
		
		public function GetAddHeroLevel(addheroexp:int):int
		{
			return 0;
		}
		
		private function checkLevelup():Boolean
		{
			var levelup:Boolean = false;
			return levelup;
		}
		
		/**
		 * 获得当前等级已经获得的经验
		 */
		public function getHeroCurrentExp():int
		{
			return 0;
		}
		
		/**
		 * 获得到下一等级总共需要的经验
		 */
		public function getHeroTargetExp():int
		{
			return 0;
		}
		
		/**
		 * 英雄升级时重新计算英雄信息
		 */
		public function onLevelUp():void
		{
			//是主英雄的情况下
			if(this.heroid == 1){//commented by fangc
				//带兵增长变更
//				if(this.herolevel%HeroDefines.amountChangeRadix == 0){
//					this.baseamout += this.amountincrement;
//					this.amount += this.amountincrement;
//				}
//				//潜力点增长
//				if(this.herolevel%HeroDefines.getFreedomPropLevelRadix == 0){
//					this.potential += HeroDefines.freedomPropNum;
//				}
//				//品质增长
//				if(this.herolevel%HeroDefines.rareLevelUpRadix == 0){
//					this.rarelevel++;
//				}
//				//技能变更
//				if(this.herolevel%HeroDefines.changeSkillLevelRadix == 0){
//					//TODO change skill
//				}
			}
		}
		
		/**
		 * 英雄属性变化时检查技能解锁（等级变动，五行值变动）
		 */
		private function checkSkillUnlock():void
		{
			unlockskills =[];
			for each(var arr:Array in heroskills)
			{
				if(arr && arr.length == 2)
				{
					var skillId:int = int(arr[0]);
					var unlockInfo:Object = arr[1];
					var unlocked:Boolean = true;
					for each(var type:String in unlockInfo)
					{
						
						switch(int(type))
						{
							case UnlockRequirement.heroLevel:
								if(this.herolevel < int(unlockInfo[type]))
								{
									unlocked = false;
								}
								break;
							case UnlockRequirement.jin:
								if(this.wuxing[0] < int(unlockInfo[type]))
								{
									unlocked = false;
								}
								break;
							case UnlockRequirement.mu:
								if(this.wuxing[1] < int(unlockInfo[type]))
								{
									unlocked = false;
								}
								break;
							case UnlockRequirement.shui:
								if(this.wuxing[2] < int(unlockInfo[type]))
								{
									unlocked = false;
								}
								break;
							case UnlockRequirement.huo:
								if(this.wuxing[3] < int(unlockInfo[type]))
								{
									unlocked = false;
								}
								break;
							case UnlockRequirement.tu:
								if(this.wuxing[4] < int(unlockInfo[type]))
								{
									unlocked = false;
								}
								break;
						}
						
						if(!unlocked)
						{
							break;
						}
					}
					
					//解锁成功的情况下
					if(unlocked)
					{
						//TODO:skillInfo
						unlockskills.push(skillId);
					}
				}
			}
		}
		
		/**
		 * 获得指定兵种的带兵量
		 */
		public function getArmAmount(armType:int = 0):Number
		{
			var armAmount:Number = 0;
			switch(armType){
				case ArmType.footman:
					armAmount = this.amount[0];
					break;
				case ArmType.archer:
					armAmount = this.amount[1];
					break;
				case ArmType.magic:
					armAmount = this.amount[2];
					break;
				case ArmType.machine:
					armAmount = this.amount[3];
					break;
				default:
					armAmount = 3;
					break;
			}
			return armAmount;
		}
		
		public function GetHeroTrainImg():int
		{
			if (this.istraining==1)
			{
				return 2104;
			}
			else
			{
				return 2100;
			}
		}
		public function GetHeroStateImg():int
		{
			return HeroDefines.GetHeroStateImg(activestate);
		}
		
		public function copyExpInfo(sourceHero:UserHeroInfo):void
		{
			if(sourceHero == null)
				return;
			this.herolevel = sourceHero.herolevel;
			this.heroexp = sourceHero.heroexp;
		}
		
		public function getCanEmbedSlotNum():int
		{
			var slotnum:int = 0;
			if(this.slotinfo){
				for(var i:int=0;i<this.slotinfo.length;i++){
					if((this.slotinfo[i] as WuxingSlotInfo).wuxing != WuXingType.empty){
						slotnum++;
					}
				}
			}
			
			return slotnum;
		}
		
		public static function getFakeHeroInfo():UserHeroInfo
		{
			var retInfo:UserHeroInfo = new UserHeroInfo();
			
			retInfo.effectid = FakeFormationLineMaker.allheroResIds[FakeFormationLineMaker.curUsedTsag++ % FakeFormationLineMaker.allheroResIds.length];
			if(retInfo.effectid == 1305)		//许褚
			{
				retInfo.pattack = 22;
			}
			else if(retInfo.effectid == 1306)	//貂蝉
			{
				retInfo.pattack = 25;
			}
			else if(retInfo.effectid == 1309)		//张飞
			{
				retInfo.pattack = 35;
			}
			
			return retInfo;
		}
		
	}
}
