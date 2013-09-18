package modules.battle.battledefine
{
	import defines.WuxingRelation;
	
	import macro.WuXingType;
	
	import modules.battle.battlelogic.CellTroopInfo;
	import modules.battle.battlelogic.RelationDes;

	/**
	 * 参与战斗计算数值的类 
	 * @author SDD
	 */
	public class BattleCaualValue
	{
		
		/**
		 * 有属性 攻击 没有属性 
		 */
		public static const elementToNull:Number = 0.05;
		/**
		 * 攻击 克 防守   最终伤害增加
		 */
		public static const atkIncreaseOnWeak:Number = 0.05;
		/**
		 * 防守 克 攻击	 最终伤害减少
		 */
		public static const atkDecreaseOnStrong:Number = -0.05;
		/**
		 * 防守 生 攻击         最终伤害减少
		 */
		public static const atkDecreaseFromGenerate:Number = -0.05;
		
		//以下是对相生相克关系的定义描述
		public static const noReleation:int = 0;					//没有任何关系
		public static const elementToNone:int = 1;				//有属性的攻击无属性的
		public static const atkDigestDef:int = 2;					//攻击方克防守
		public static const defDigestAtk:int = 3;					//防守方克攻击
		public static const atkGeneDef:int = 4;					//攻击生防守
		public static const defGeneAtk:int = 5;					//防守生攻击
		
		/**
		 * 改变值的最大比例 
		 */
		public static const maxChangePercent:Number = 0.25;
		
		public function BattleCaualValue()
		{
		}
		
		/**
		 * 获得两种五行元素之间的关系 
		 * @param atkType
		 * @param defType
		 * @return 
		 */
		public static function getRelation(atkType:int,defType:int):int
		{
			if(atkType == WuXingType.empty)
				return noReleation;						//没有关系
			if(defType == WuXingType.empty)
				return elementToNone;					//属性攻击无属性
			if(WuxingRelation.XiangKeRelation[atkType] == defType)
				return atkDigestDef;					//攻击方克防守
			if(WuxingRelation.XiangKeRelation[defType] == atkType)
				return defDigestAtk;					//防守方克攻击
			if(WuxingRelation.XiangKeRelation[atkType] == defType)
				return atkGeneDef;						//攻击生防守
			if(WuxingRelation.XiangKeRelation[defType] == atkType)
				return defGeneAtk;						//防守生攻击
			
			return noReleation;
		}
		
		/**
		 * 获得五行阵之间影响的值
		 * @param atkTroop							攻击方  可能是英雄
		 * @param defTroop							被攻击方 不可能是英雄
		 * @return 
		 */
		public static function checkRelation(atkTroop:CellTroopInfo,defTroop:CellTroopInfo):RelationDes
		{
			var retvalue:RelationDes = new RelationDes;
			
			if(atkTroop == null || defTroop == null)
				return retvalue;
			
			var atkElementType:int = 0;					
			var atkElementValue:int = 0;
			
			if(atkTroop.isHero)						//如果是英雄  需要手动判断		
			{
				var retValue:Array = atkTroop.attackUnit.contentHeroInfo.getXiangkeWuXing(defTroop.attackUnit.elementType);
				if(retValue && retValue.length == 2)
				{
					atkElementType = retValue[0];
					atkElementValue = retValue[1];
				}
			}
			else
			{
				atkElementType = atkTroop.attackUnit.elementType;
				atkElementValue = atkTroop.attackUnit.elementValue;
			}
			
			var relationType:int = getRelation(atkElementType,defTroop.attackUnit.elementType);
			retvalue.relationId = relationType;
			
			var influenceValue:Number;				//影响进攻的值
			switch(relationType)
			{
				case noReleation:
					influenceValue = 0;
					break;
				case elementToNone:
					influenceValue = atkElementType * elementToNull;
					break;
				case atkDigestDef:
					influenceValue = atkElementType * atkIncreaseOnWeak;
					break;
				case defDigestAtk:
					influenceValue = atkElementType * atkDecreaseOnStrong;
					break;
				case defGeneAtk:
					influenceValue = atkElementType * atkDecreaseFromGenerate;
					break;
			}
			//不能超过  +-25%的误差
			retvalue.relationValue = Math.max(influenceValue,1 - maxChangePercent);
			retvalue.relationValue = Math.min(influenceValue,1 + maxChangePercent);
			return retvalue;
		}
		
	}
}