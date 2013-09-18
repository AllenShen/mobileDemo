package defines
{
	import macro.FormationDefine;
	import macro.FormationElementType;

	public class FormationSlotInfo
	{
		//放置类型：英雄、士兵、城墙、箭塔
		public var type:int;
		//英雄信息或者士兵信息
		public var info:* =  null;
		//该格子当前兵量，放士兵时有效
		public var curnum:int;
		//该格子可放最大兵量，放士兵时有效
		public var maxnum:int;
		//PVE敌人的id		
		public var pveenemyunitid:int;
		//PVE敌人是否显示
		public var visible:int;
		
		public var rowindex:int;
		public var colindex:int;
		
		public var supplyType:int;

		public function FormationSlotInfo(type:int = 0)
		{
			this.type = type;
			this.info = null;
			this.curnum = 0;
			this.maxnum = FormationDefine.FORMATIONSLOT_ARMNUM;
			this.pveenemyunitid = 0;
			this.visible = 1;
			rowindex=-1;
			colindex=-1;
		}
		
		public function MakeBattlePacketToServer():Array
		{
			var data:Array=[];
			data.push(type);
			data.push(curnum);
			data.push(maxnum);

			switch(type)
			{
				case FormationElementType.HERO:
					var heroinfo:UserHeroInfo=info as UserHeroInfo;
					data.push(heroinfo.heroid);
					data.push(heroinfo.MakeBattlePacket());
					data.push(heroinfo.getUnlockSkillsSnap());
					break;
				case FormationElementType.ARM:
					var armyinfo:UserArmInfo=info as UserArmInfo;
					data.push(armyinfo.basearmid);
					data.push(armyinfo.MakeBattlePacket());
					break;
				case FormationElementType.CITY_WALL:
				case FormationElementType.ARROW_TOWER:
					armyinfo=info as UserArmInfo;
					data.push(0);
					data.push(armyinfo.MakeBattlePacket());
					break;
			}
			
			return data;
		}
		
		public function LoadFromServerPacket(packet:Array):void
		{
			if (packet!=null)
			{
				type=packet.shift();
				curnum=packet.shift();
				maxnum=packet.shift();

				var slotinfo:Array=packet.shift();
				if (slotinfo)
				{
					switch(type)
					{
						case FormationElementType.HERO:
							var tempHeroInfo:UserHeroInfo = new UserHeroInfo;
							tempHeroInfo.LoadBattlePacket(slotinfo);
							info = tempHeroInfo;
							break;
						case FormationElementType.ARM:
							var tempArmInfo:UserArmInfo = new UserArmInfo();
							tempArmInfo.LoadBattlePacket(slotinfo);
							info = tempArmInfo;
							break;
						case FormationElementType.CITY_WALL:
						case FormationElementType.ARROW_TOWER:
							tempArmInfo = new UserArmInfo();
							tempArmInfo.LoadBattlePacket(slotinfo);
							info = tempArmInfo;
							break;
					}
				}
				else
				{
					type=FormationElementType.NOTHING;
					info = null; 
				}
			}
			else
			{
				type=FormationElementType.NOTHING;
				info = null; 
			}
		}
	}
}