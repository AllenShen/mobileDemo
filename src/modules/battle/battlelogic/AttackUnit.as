package modules.battle.battlelogic
{
	
	import flash.geom.Point;
	
	import defines.FormationSlotInfo;
	import defines.HeroDefines;
	import defines.UserArmInfo;
	import defines.UserHeroInfo;
	
	import macro.FormationElementType;
	
	import modules.battle.battledefine.SpecialTroopType;
	import modules.battle.managers.BattleInfoSnap;
	import modules.battle.managers.BattleManager;
	import modules.battle.managers.BattleUnitPool;

	/**
	 * 表示战斗的单位载体基类,主要是士兵，或者英雄单位 
	 * @author SDD
	 * 
	 */
	public class AttackUnit
	{
		/**
		 * 类型 
		 */
		public var type:int = 0;
		
		private var _sizeNeed:Point = new Point;
		
		/**
		 * 攻击类型 
		 */
		private var _armtype:int = 0;
		
		/**
		 * 伤害类型 
		 */
		private var _damageType:int = 0;
		
		/**
		 * 英雄类型 
		 */
		private var _heroType:int = 0;
		
		/**
		 * 攻击距离 
		 */
		private var _attackDistance:int = 1;
		
		/**
		 * 攻击范围 
		 */
		private var _attackRange:int = 1;
		
		/**
		 *  特殊类型   (抽象过的   不能攻击 不能移动 不能被攻击等)
		 */
		private var _specialRoleType:int = 1;
		
		/**
		 * 攻击值(加成后的) 
		 */
		private var _damageValue:Number;
		
		/**
		 * 抗性值(加成后的  停用) 
		 */
		private var _defenseValue:Number;

		/**
		 * 英雄一般攻击力(加成后) 
		 */
		private var _heroNormalAttack:Number;
		
		/**
		 * 英雄一般攻击力(加成后)  
		 */
		private var _heroNormalDefense:Number;
		
		/**
		 * 英雄的魔法攻击力(加成后)  
		 */
		private var _heroMagicAttack:Number;
		
		/**
		 * 英雄的魔法防御力(加成后)   
		 */
		private var _heroMagicDefense:Number;
		
		/**
		 * 五行种类 
		 */
		private var _elementType:int = 0;
		
		/**
		 * 五行类型的值
		 */
		private var _elementValue:int = 0;
		
		/**
		 * 闪避率 
		 */
		private var _evadeRate:Number = 0;
		
		/**
		 * 暴击概率
		 */
		private var _critRate:Number = 0;
		
		/**
		 * 命中率 
		 */
		private var _hitRate:Number = 0;
		
		/**
		 * 带兵量 
		 */
		private var _curArmCount:int = 0;
		
		/**
		 * hp士兵血量 
		 */
		private var _troopHp:int = 0;
		
		private var _wuli:Number;			//武力值
		
		private var _zhili:Number;		//智力值 
		
		private var _baqi:Number;		//霸值
		
		private var _effectid:int;			//使用的effectid
		
		private var _pveenemyunitid:int = 0;			//pve 敌人id
		private var _slotVisible:int = 1;				//是否显示
		
		private var _armcountofslot:int = 0;				//slot上最大的带兵量
		
		private var _slotType:int = 0;
		
		public var contentArmInfo:UserArmInfo;					//实际对应的arm信息
		public var contentHeroInfo:UserHeroInfo;				//实际对应的hero信息
		
		public function AttackUnit(slotInfo:FormationSlotInfo)
		{
			this.pveenemyunitid = slotInfo.pveenemyunitid;
			this.slotVisible = slotInfo.visible;
			this._armcountofslot = slotInfo.maxnum;
			this.slotType = slotInfo.type;
			
			var info:* = slotInfo.info;
			if(info)
			{
				//根据slot的类型得到是否为某种特殊类型
				this.specialRoleType =  SpecialTroopType.turnSlotTypeToSpecialType(slotInfo.type);
				
				var armInfo:UserArmInfo;
				var heroInfo:UserHeroInfo;
				if(info is UserArmInfo)
				{
					armInfo = info as UserArmInfo;
					this.type = FormationElementType.ARM;
					this.sizeNeed = new Point(armInfo.width,armInfo.height);
					this._armtype = armInfo.armtype;
					this._damageType = armInfo.damagetype;
					
					this._damageValue = armInfo.damage;								//伤害值
					
					this._evadeRate = armInfo.dodge;							//闪避率
					this._critRate = armInfo.crit;								//暴击率
					this._hitRate = armInfo.hitrate;								//命中率
					
					this._attackRange = armInfo.attacktype;							//攻击目标种类
					this._attackDistance = armInfo.attackrange;						//攻击距离
					
					this._elementType = armInfo.wuxingtype;
					this._elementValue = armInfo.wuxingvalue;
					
					this._curArmCount = slotInfo.curnum;
					
					this._troopHp = armInfo.hp;
					
					this.effectid = armInfo.effectid;
					
					this.contentArmInfo = armInfo;
					
					if(armInfo.uid == GlobalData.owner.uid)
					{
						var curNum:int = 0;
						if(BattleUnitPool.allBaseArmOnBattle.hasOwnProperty(armInfo.basearmid))
						{
							curNum = BattleUnitPool.allBaseArmOnBattle[armInfo.basearmid];
						}
						curNum += slotInfo.curnum;
						BattleUnitPool.allBaseArmOnBattle[armInfo.basearmid] = curNum;
					}
				}
				else if(info is UserHeroInfo)
				{
					heroInfo = info as UserHeroInfo;
					this.type = FormationElementType.HERO;
					this.sizeNeed = new Point(1,1);
					
					this._heroType = heroInfo.herotype;
					this.heroNormalAttack = heroInfo.pattack;
					this.heroNormalDefense = heroInfo.pdefence;
					this.heroMagicAttack = heroInfo.mattack;
					this.heroMagicDefense = heroInfo.mdefence;
					
					this._wuli = heroInfo.wuli;			
					
					this._zhili = heroInfo.zhili;		
					
					this._baqi = heroInfo.baqi;		
					
					this.effectid = heroInfo.effectid;
					
					this.contentHeroInfo = heroInfo;
					
					var newHeroInfo:UserHeroInfo = heroInfo;
					if(this.contentHeroInfo.heroid == HeroDefines.userDefaultHero && this.contentHeroInfo.uid == GlobalData.owner.uid)
						BattleInfoSnap.curMainHero = newHeroInfo;
					if(heroInfo.uid == GlobalData.owner.uid)
					{
						BattleManager.instance.allUserHeroInfo.push(this.contentHeroInfo);
					}
				}
			}
		}
		
		public function get damageType():int
		{
			return _damageType;
		}

		public function set damageType(value:int):void
		{
			_damageType = value;
		}

		/**
		 *  初始化函数，游戏逻辑中，使用userHero等信息进行初始化
		 * @param SDD
		 * 
		 */
		public function init(infoSource:*):void
		{
			
		}
		
		/**
		 * 攻击距离值 
		 * @return 距离值
		 */
		public function get attackDistance():int
		{
			return _attackDistance;
		}
		
		public function set attackDistance(value:int):void
		{
			_attackDistance = value;
		}
		
		/**
		 * 攻击范围，只有一个或者两个 
		 * @return 返回值
		 * 
		 */
		public function get attackRange():int
		{
			return _attackRange;
		}
		
		public function set attackRange(value:int):void
		{
			_attackRange = value;
		}
		
		/**
		 * 特殊类型，不参与攻击，不参与防御，两者都不参与等 
		 * @return 
		 * 
		 */
		public function get specialRoleType():int
		{
			return _specialRoleType;
		}

		public function set specialRoleType(value:int):void
		{
			_specialRoleType = value;
		}
		
		/**
		 * 判断是否参与回合结束，战斗结束的判断 
		 * @return 
		 * 
		 */
		public function get isOnJudgeList():Boolean
		{
			return specialRoleType != SpecialTroopType.NON_ATTACKED && specialRoleType != SpecialTroopType.NON_MOVE_ATTACKED;
		}

		/**
		 * 伤害值 
		 */
		public function get damageValue():Number
		{
			return _damageValue;
		}

		/**
		 * @private
		 */
		public function set damageValue(value:Number):void
		{
			_damageValue = value;
		}

		/**
		 * 抗性值 
		 */
		public function get defenseValue():Number
		{
			return _defenseValue;
		}

		/**
		 * @private
		 */
		public function set defenseValue(value:Number):void
		{
			_defenseValue = value;
		}

		/**
		 * 英雄一般的攻击力(加成后的) 
		 */
		public function get heroNormalAttack():Number
		{
			return _heroNormalAttack;
		}

		/**
		 * @private
		 */
		public function set heroNormalAttack(value:Number):void
		{
			_heroNormalAttack = value;
		}

		/**
		 *  英雄一般攻击力(加成后) 
		 */
		public function get heroNormalDefense():Number
		{
			return _heroNormalDefense;
		}

		/**
		 * @private
		 */
		public function set heroNormalDefense(value:Number):void
		{
			_heroNormalDefense = value;
		}

		/**
		 * 英雄的魔法攻击力 
		 */
		public function get heroMagicAttack():Number
		{
			return _heroMagicAttack;
		}

		/**
		 * @private
		 */
		public function set heroMagicAttack(value:Number):void
		{
			_heroMagicAttack = value;
		}

		/**
		 *  英雄的魔法防御击力(加成后)  
		 */
		public function get heroMagicDefense():Number
		{
			return _heroMagicDefense;
		}

		/**
		 * @private
		 */
		public function set heroMagicDefense(value:Number):void
		{
			_heroMagicDefense = value;
		}

		/**
		 * 武力值 
		 */
		public function get wuli():Number
		{
			return _wuli;
		}

		/**
		 * @private
		 */
		public function set wuli(value:Number):void
		{
			_wuli = value;
		}

		/**
		 * 智力值 
		 */
		public function get zhili():Number
		{
			return _zhili;
		}

		/**
		 * @private
		 */
		public function set zhili(value:Number):void
		{
			_zhili = value;
		}

		/**
		 * 霸值 
		 */
		public function get baqi():Number
		{
			return _baqi;
		}

		/**
		 * @private
		 */
		public function set baqi(value:Number):void
		{
			_baqi = value;
		}

		/**
		 * 攻击类型
		 */
		public function get armtype():int
		{
			return _armtype;
		}

		/**
		 * @private
		 */
		public function set armtype(value:int):void
		{
			_armtype = value;
		}

		public function get elementType():int
		{
			return _elementType;
		}

		public function set elementType(value:int):void
		{
			_elementType = value;
		}

		public function get elementValue():int
		{
			return _elementValue;
		}

		public function set elementValue(value:int):void
		{
			_elementValue = value;
		}

		public function get sizeNeed():Point
		{
			return _sizeNeed;
		}

		public function set sizeNeed(value:Point):void
		{
			_sizeNeed = value;
		}

		/**
		 * 带兵量 
		 */
		public function get curArmCount():int
		{
			return _curArmCount;
		}

		/**
		 * @private
		 */
		public function set curArmCount(value:int):void
		{
			_curArmCount = value;
		}

		/**
		 * 闪避率 
		 */
		public function get evadeRate():Number
		{
			return _evadeRate;
		}

		/**
		 * @private
		 */
		public function set evadeRate(value:Number):void
		{
			_evadeRate = value;
		}

		/**
		 * 暴击概率
		 */
		public function get critRate():Number
		{
			return _critRate;
		}

		/**
		 * @private
		 */
		public function set critRate(value:Number):void
		{
			_critRate = value;
		}

		/**
		 * 命中率 
		 */
		public function get hitRate():Number
		{
			return _hitRate;
		}

		/**
		 * @private
		 */
		public function set hitRate(value:Number):void
		{
			_hitRate = value;
		}

		/**
		 * hp血量 
		 */
		public function get troopHp():int
		{
			return _troopHp;
		}

		/**
		 * @private
		 */
		public function set troopHp(value:int):void
		{
			_troopHp = value;
		}

		/**
		 * 英雄类型 
		 */
		public function get heroType():int
		{
			return _heroType;
		}

		/**
		 * @private
		 */
		public function set heroType(value:int):void
		{
			_heroType = value;
		}

		public function get effectid():int
		{
			return _effectid;
		}

		public function set effectid(value:int):void
		{
			_effectid = value;
		}

		public function get pveenemyunitid():int
		{
			return _pveenemyunitid;
		}

		public function set pveenemyunitid(value:int):void
		{
			_pveenemyunitid = value;
		}

		public function get slotVisible():int
		{
			return _slotVisible;
		}

		public function set slotVisible(value:int):void
		{
			_slotVisible = value;
		}

		public function get armcountofslot():int
		{
			return _armcountofslot;
		}

		public function get slotType():int
		{
			return _slotType;
		}

		public function set slotType(value:int):void
		{
			_slotType = value;
		}

		
	}
}