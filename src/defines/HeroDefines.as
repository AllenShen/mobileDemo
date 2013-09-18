package defines
{
	public class HeroDefines
	{
		public function HeroDefines()
		{
		}
		
		//玩家主英雄
		public static const userDefaultHero:int = 1;
		public static const greatestHero:int = 17;
		
		//main hero
		public static const amountChangeRadix:int = 5;
		
		//activeState
		public static const Idle:int = 0;	//空闲
		public static const Affair:int = 1;	//内政
		public static const Attack:int = 2;	//在阵上
		//public static const Defense:int = 3;
		public static const Wild:int = 4;	//在城外负责某个任务
		public static const Affair_Wild:int = 5; //同时在内政以及野外
		
		//training state
		public static const nottraining:int = 0;
		public static const training:int = 1;
		
		public static const initHeros:Array = [1,20];
		//sort rule
		public static const AttackFirst:Array = [3,2,1,5,4,0];
		public static const DefenseFirst:Array = [2,1,5,4,0,3];
		public static const IdeleOnly:Array = [0];
		public static const CanOnAffair:Array = [0,4,5];
		
		public static const unlock_null:int=0;
		public static const unlock_event:int=1;
		public static const unlock_map:int=2;
		
		public static const propertygrow:int = 4;
		
		
		public static const WuxingjiangUnlock:Array=[11,17,20,20,1];
		
		//public static const HeroTreasureMax:int=3;
		
		public static function GetHeroStateImg(state:int):int
		{
			switch(state)
			{
				case HeroDefines.Idle:
					return 2100;
				case HeroDefines.Affair:
				case HeroDefines.Affair_Wild:
				case HeroDefines.Wild:
					return 2101;
				case HeroDefines.Attack:
					return 2094;
/*				case HeroDefines.Defense:
					return 2099;*/
			}
			
			return 2100;
		}
		
		public static const HeroJijieMapId:int = 16; 
	}
}