package defines
{
	import macro.ArmType;
	import macro.AttackRangeDefine;
	
	import modules.battle.battlecomponent.NextSupplyShow;
	import modules.battle.battledefine.BattleDefine;
	
	import sysdata.Skill;
	
	import tools.Json.JSON;
	import tools.textengine.TextEngine;

	public class UserArmInfo
	{
		//userarmid
		public var userarmid:int;
		//uid
		public var uid:int;
		//兵种id
		public var armid:int;
		//兵种类型，0-99
		public var armtype:int;
		public var subarmtype:int;
		//是否为特殊兵种
		public var specialtype:int;
		//是否基础兵种
		public var basearmid:int;
		public var isbase:int;
		//兵种名字
		public var nameid:int;
		public var namestr:String;
		//五行属性
		public var wuxingtype:int;
		//五行属性对应的值
		public var wuxingvalue:int;
		//兵种宽度
		public var width:int = 1;
		//兵种高度
		public var height:int = 1;
		//伤害
		public var damage:int;
		//伤害类型
		public var damagetype:int;
		
		//技能1
		public var skill1:String;
		//技能2
		public var skill2:String;
		//技能3
		public var skill3:String;
		
		//技能1
		public var skill1obj:Skill;
		//技能2
		public var skill2obj:Skill;
		//技能3
		public var skill3obj:Skill;
		//暴击概率
		public var crit:Number;
		//躲避概率
		public var dodge:Number;
		//命中率
		public var hitrate:Number;
		//金钱
		public var needcoin:int;
		//粮食
		public var needfood:int;
		//石头
		public var needstone:int;
		//攻击范围1-8
		public var attacktype:int;
		//攻击距离
		public var attackrange:int;
		//血量
		public var hp:int;
		//佩戴的勋章
		public var medal:int;
		//士兵装备
		public var armequip:int;
		//动画表现
		public var effectid:int;
		
		public var currentnum:int;
		
		public var maketime:int;
		
		public var portrait:int;
		
		public function LoadBattlePacket(data:Array):void
		{
			this.userarmid = data.shift();//标识
			this.uid = data.shift();//用户标识
			this.armid = data.shift();//兵种id
			this.basearmid  =  data.shift();//未佩戴纹章前的id
			this.isbase = data.shift();
			this.armtype = data.shift();//兵种类型，0-99
			this.subarmtype = data.shift();
			this.specialtype = data.shift();//是否为特殊兵种
			this.nameid = data.shift();//兵种名字
			this.wuxingtype = data.shift();//五行属性
			this.wuxingvalue = data.shift();//五行属性对应的值
			this.width = data.shift();//兵种宽度
			this.height = data.shift();//兵种高度
			this.damage = data.shift();//伤害
			this.damagetype = data.shift();//伤害类型
			
			this.skill1 = data.shift();//技能1
			this.skill2 = data.shift();//技能2
			this.skill3 = data.shift();//技能3	
			
			this.crit = data.shift();//暴击概率
			this.dodge = data.shift();//躲避概率
			this.hitrate = data.shift();//命中率
			this.needcoin = data.shift();//金钱
			this.needfood = data.shift();//粮食
			this.needstone = data.shift();//石头
			this.attacktype = data.shift();//攻击范围1-8
			this.attackrange = data.shift();//攻击距离
			this.hp = data.shift();//血量
			this.medal = data.shift();
			this.armequip = data.shift();//士兵装备
			this.effectid = data.shift();//动画表现
			maketime=data.shift();
			
			initskillobj();
			
		}
		
		public function MakeBattlePacket():Array
		{
			
			var packet:Array=[];
			packet.push(userarmid);//标识
			packet.push(uid);//用户标识
			packet.push(armid);//兵种id
			packet.push(basearmid);//未佩戴纹章前的id
			packet.push(isbase);
			packet.push(armtype);//兵种类型，0-99
			packet.push(subarmtype);
			packet.push(specialtype);//是否为特殊兵种
			packet.push(nameid);//兵种名字
			packet.push(wuxingtype);//五行属性
			packet.push(wuxingvalue);//五行属性对应的值
			packet.push(width);//兵种宽度
			packet.push(height);//兵种高度
			packet.push(damage);//伤害
			packet.push(damagetype);//伤害类型
			
			packet.push(skill1);//技能1
			packet.push(skill2);//技能2
			packet.push(skill3);//技能3	
			
			packet.push(crit);//暴击概率
			packet.push(dodge);//躲避概率
			packet.push(hitrate);//命中率
			packet.push(needcoin);//金钱
			packet.push(needfood);//粮食
			packet.push(needstone);//石头
			packet.push(attacktype);//攻击范围1-8
			packet.push(attackrange);//攻击距离
			packet.push(hp);//血量
			packet.push(medal);
			packet.push(armequip);//士兵装备
			packet.push(effectid);//动画表现
			packet.push(maketime);
			return packet;
		}
		
		public function Copy(arminfo:UserArmInfo):void
		{
			uid = arminfo.uid;
			armid = arminfo.armid;
			armtype = arminfo.armtype;
			subarmtype = arminfo.subarmtype;
			isbase=arminfo.isbase;
			specialtype = arminfo.specialtype;
			basearmid = arminfo.basearmid;
			nameid = arminfo.nameid;
			wuxingtype = arminfo.wuxingtype;
			wuxingvalue = arminfo.wuxingvalue;
			width = arminfo.width;
			height = arminfo.height;
			damage = arminfo.damage;
			damagetype = arminfo.damagetype;
			skill1 = arminfo.skill1;
			skill2 = arminfo.skill2;
			skill3 = arminfo.skill3;
			
			skill1obj=null;
			if (arminfo.skill1obj)
			{
				skill1obj = new Skill;
				skill1obj.copyData(arminfo.skill1obj);
			}
			skill2obj=null;
			if (arminfo.skill2obj)
			{
				skill2obj = new Skill;
				skill2obj.copyData(arminfo.skill2obj);
			}
			skill3obj=null;
			if (arminfo.skill3obj)
			{
				skill3obj = new Skill;
				skill3obj.copyData(arminfo.skill3obj);
			}
			
			crit = arminfo.crit;
			dodge = arminfo.dodge;
			hitrate = arminfo.hitrate;
			needcoin = arminfo.needcoin;
			needfood = arminfo.needfood;
			needstone = arminfo.needstone;
			attacktype = arminfo.attacktype;
			attackrange = arminfo.attackrange;
			hp = arminfo.hp;
			medal = arminfo.medal;
			armequip = arminfo.armequip;
			effectid = arminfo.effectid;
			namestr=arminfo.namestr;
			portrait=arminfo.portrait;
			maketime=arminfo.maketime;
		}
		/**
		 * 拷贝士兵信息
		 */
		public function clone():UserArmInfo
		{
			var userArmInfo:UserArmInfo = new UserArmInfo();
			userArmInfo.Copy(this);			
			
			return userArmInfo;
		}
		
		public function initskillobj():void
		{
			var skillinfos:Array=["skill1","skill2","skill3"];
			
			for each (var skillkey:String in skillinfos)
			{
				if ((this[skillkey])&&(this[skillkey].length>0))
				{
					var skill:Skill=new Skill;
					var skillinfo:Array=tools.Json.JSON.decode(this[skillkey]);
				}
			}

		}
		
		public function fromArray(data:Array):void
		{
			this.userarmid=data.shift();//标识
			this.uid=data.shift();//用户标识
			this.armid=data.shift();//兵种id
			this.basearmid=data.shift();//未佩戴纹章前的id
			this.isbase=data.shift();
			this.armtype=data.shift();//兵种类型，0-99
			this.subarmtype=data.shift();
			this.specialtype=data.shift();//是否为特殊兵种
			this.nameid=data.shift();//兵种名字
			this.wuxingtype=data.shift();//五行属性
			this.wuxingvalue=data.shift();//五行属性对应的值
			this.width=data.shift();//兵种宽度
			this.height=data.shift();//兵种高度
			this.damage=data.shift();//伤害
			this.damagetype=data.shift();//伤害类型
						
			this.skill1=data.shift();//技能1
			this.skill2=data.shift();//技能2
			this.skill3=data.shift();//技能3	
			
			this.crit=data.shift();//暴击概率
			this.dodge=data.shift();//躲避概率
			this.hitrate=data.shift();//命中率
			this.needcoin=data.shift();//金钱
			this.needfood=data.shift();//粮食
			this.needstone=data.shift();//石头
			this.attacktype=data.shift();//攻击范围1-8
			this.attackrange=data.shift();//攻击距离
			this.hp=data.shift();//血量
			this.medal=data.shift();
			this.armequip=data.shift();//士兵装备
			this.effectid=data.shift();//动画表现
			maketime=data.shift();
			
			this.namestr=TextEngine.getTextById(nameid);
			
			initskillobj();
			
		}
		public function fromObject(obj:Object):void
		{
			userarmid=obj["userarmid"];//标识
			this.uid=obj["uid"];
			this.armid=obj["armid"];
			this.basearmid=obj["baseid"];
			this.armtype=obj["armtype"];
			subarmtype=obj["subarmtype"];
			this.isbase=obj["isbase"];
			this.specialtype=obj["specialtype"];
			this.nameid=obj["nameid"];
			this.wuxingtype=obj["wuxingtype"];
			this.wuxingvalue=obj["wuxingvalue"];
			this.width=obj["width"];
			this.height=obj["height"];
			this.damage=obj["damage"];
			this.damagetype=obj["damagetype"];
			this.skill1=obj["skill1"];
			this.skill2=obj["skill2"];
			this.skill3=obj["skill3"];
			
			//this.skill1obj=obj["skill1obj"];
			//this.skill2obj=obj["skill2obj"];
			//this.skill3obj=obj["skill3obj"];
			
			this.crit=obj["crit"];
			this.dodge=obj["dodge"];
			this.hitrate=obj["hitrate"];
			this.needcoin=obj["needcoin"];
			this.needfood=obj["needfood"];
			this.needstone=obj["needstone"];
			this.attackrange=obj["attacktype"];
			this.attackrange=obj["attackrange"];
			this.hp=obj["hp"];
			this.medal=obj["medal"];
			this.armequip=obj["armequip"];
			this.effectid=obj["effectid"];
			maketime=obj["maketime"];
			
			this.namestr=TextEngine.getTextById(nameid);
			
			initskillobj();
		}
		
		public function GetArmyLevel():Array
		{
			if (this.medal!=0)
			{
			}
			
			return [0,0];
		}
		/**
		 * 计算战斗时的士兵数据
		 */
		public function calBattleValue(heroInfo:UserHeroInfo):void
		{
			if(this.armtype == ArmType.magic){
				this.hitrate += heroInfo.mofamingzhongadd;
			}
			
			if(heroInfo.damageadd > 1){
				this.damage += heroInfo.damageadd;
			}else{
				this.damage = this.damage*(1+heroInfo.damageadd);
			}
			
			if(heroInfo.hpadd > 1){
				this.hp += heroInfo.hpadd;
			}else{
				this.hp = this.hp*(1+heroInfo.hpadd);
			}
			
			this.crit += heroInfo.critadd;
			this.dodge += heroInfo.dodgeadd;
		}
		
		public function addEquipBuffer():void
		{
		}
			
		public static function getFakeArmInfo(type:int,armType:int,resId:int,ownerSide:int,supplyType:int):UserArmInfo
		{
			var retArmInfo:UserArmInfo = new UserArmInfo();
			retArmInfo.damagetype = type;
			retArmInfo.armtype = armType;
			retArmInfo.effectid = resId;
			
			retArmInfo.currentnum = 1;
			
			retArmInfo.attacktype = AttackRangeDefine.dantiGongJi;
			if(armType == ArmType.footman)
			{
				retArmInfo.attackrange = 0;
			}
			else if(armType == ArmType.archer)
			{
				retArmInfo.attackrange = 5;
			}
			else if(armType == ArmType.magic)
			{
				retArmInfo.attackrange = 5;
			}
			else if(armType == ArmType.machine)
			{
				retArmInfo.attackrange = 5;
			}
			
			if(ownerSide == BattleDefine.firstAtk)
			{
				switch(supplyType)
				{
					case NextSupplyShow.supply_SimpleFoot:
						retArmInfo.hp = 100;
						retArmInfo.damage = 12;
						break;
					case NextSupplyShow.supply_SimpleFoot2:
						retArmInfo.hp = 120;
						retArmInfo.damage = 10;
						break;
					case NextSupplyShow.supply_SimpleArcher3:
						retArmInfo.hp = 50;
						retArmInfo.damage = 12;
						break;
					case NextSupplyShow.supply_SimpleArcher:
						retArmInfo.hp = 100;
						retArmInfo.damage = 20;
						break;
					case NextSupplyShow.supply_SimpleArcher2:
						retArmInfo.hp = 135;
						retArmInfo.damage = 20;
						break;
					case NextSupplyShow.supply_SimpleFoot4:
						retArmInfo.hp = 190;
						retArmInfo.damage = 15;
						break;
					case NextSupplyShow.supply_SimpleFoot5:
						retArmInfo.hp = 140;
						retArmInfo.damage = 8;
						break;
					case NextSupplyShow.supply_SimpleMagic:
						retArmInfo.hp = 120;
						retArmInfo.damage = 25;
						break;
					case NextSupplyShow.supply_BigFoot:
						retArmInfo.hp = 330;
						retArmInfo.damage = 16;
						
						retArmInfo.width = 2;
						retArmInfo.height = 1;
						
						retArmInfo.attacktype = AttackRangeDefine.duotiGongJi1;
						
						retArmInfo.armtype = ArmType.machine;
						break;
					case NextSupplyShow.supply_BigFoot2:
						retArmInfo.hp = 500;
						retArmInfo.damage = 18;
						
						retArmInfo.width = 2;
						retArmInfo.height = 2;
						
						retArmInfo.attacktype = AttackRangeDefine.duotiGongJi7;
						
						retArmInfo.armtype = ArmType.machine;
						break;
				}
			}
			else
			{
				switch(supplyType)
				{
					case NextSupplyShow.enemySupplyType_foot1:
						retArmInfo.hp = 45;
						retArmInfo.damage = 15;
						break;
					case NextSupplyShow.enemySupplyType_foot2:
						retArmInfo.hp = 150;
						retArmInfo.damage = 15;
						break;
					case NextSupplyShow.enemySupplyType_arch1:
						retArmInfo.hp = 45;
						retArmInfo.damage = 27;
						break;
					case NextSupplyShow.enemySupplyType_arch2:
						retArmInfo.hp = 120;
						retArmInfo.damage = 27;
						break;
					case NextSupplyShow.enemySupplyType_magic1:
						retArmInfo.hp = 135;
						retArmInfo.damage = 45;
						break;
					case NextSupplyShow.enemySupplyType_machine1:
						retArmInfo.width = 2;
						retArmInfo.height = 1;
						retArmInfo.hp = 350;
						retArmInfo.damage = 40;
						retArmInfo.armtype = ArmType.machine;
						break;
					case NextSupplyShow.enemySupplyType_Boss:
						retArmInfo.hp = 3600;
						retArmInfo.damage = 22;
						
						retArmInfo.width = 3;
						retArmInfo.height = 3;
						retArmInfo.attacktype = AttackRangeDefine.duotiGongJi8;
						break;
				}
			}
			
			retArmInfo.damage += NextSupplyShow.instance.addedDamage;
			retArmInfo.hp += NextSupplyShow.instance.addedHP;
			
			return retArmInfo;
		}
		
	}
}