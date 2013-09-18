package defines
{
	import macro.UserResourceType;
	
	import tools.textengine.StringUtil;
	import tools.textengine.TextEngine;

	public class ErrorCode
	{
		public static const suc:int=0;
		public static const nosuchinfo:int=1;
		public static const leveloverhall:int=2;
		public static const citynotmatch:int=3;
		public static const leveloverflow:int=4;
		public static const infonotmatched:int=5;
		public static const valueoverflow:int=6;
		public static const socketerror:int = 7;
		public static const notlogined:int = 8;
		public static const valuedownflow:int = 9;
		public static const intervalnotreached:int=10;
		public static const todaycountlimitreached:int=11;
		public static const nosuchenemyseq:int=12;
		public static const nosuchenemy:int=13;
		public static const usernotexist:int=14;
		public static const sysheronotexist:int = 15;
		public static const notcanhiredhero:int = 16;
		public static const paramerror:int = 17;
		public static const eventexcuted:int = 18;
		public static const nosuchbuidling:int = 19;
		public static const iteminvisible:int = 20;
		public static const inventoryisfull:int = 21;
		public static const nosuchsysequip:int = 22;
		public static const tempequipcannotsell:int = 23;
		public static const nosuchmapitem:int = 24;
		public static const nosuchmonsterlair:int = 25;
		public static const emptymonsterlair:int = 26;
		public static const fujiangcannotequipmount:int= 27;
		public static const equiplevelnotreached:int = 28;
		public static const ROOM_FULL:int = 29;
		public static const NOSUCH_ROOM:int = 30;
		public static const allroomfull:int = 31;
		public static const targetnotexisted:int = 32;
		public static const targetbusy:int = 33;
		public static const targeterror:int = 34;
		public static const battlestarterror:int = 35;
		public static const preparebattleerror:int = 36;
		public static const battlecarduseout:int = 37;
		public static const nosuchbattlecard:int = 38;
		public static const ishiredhero:int = 39;
		public static const buildingnumover:int = 40;
		public static const notenough_herospace:int=41;
		public static const nosuchshopitem:int=42;
		public static const nosuchsysmedal:int = 43;
		public static const nosuchsysshenfu:int = 44;
		public static const nosuchsyswuxingshi:int = 45;
		public static const nosuchsyssuipian:int = 46;
		public static const instancelocked:int=47;
		public static const collectionlocked:int=48;
		public static const collectionscorelimit:int=49;
		public static const nosuchteam:int = 50;
		public static const teamfull:int = 51;
		public static const noleaderpermission:int = 52;
		public static const nosuchuserhero:int = 53;
		public static const nosuchuserequip:int = 54;
		public static const nosuchusermedal:int = 55;
		public static const nosuchusershenfu:int = 56;
		public static const nosuchuserwuxingshi:int =57;
		public static const nosuchusersuipian:int =58;
		public static const heroisalreadytrain:int=59;
		public static const noidletrainqueue:int=60;
		public static const heroisnotintrain:int=61;
		public static const enhancetimesover:int=62;
		public static const equipleveltoohigh:int=63;
		public static const counttrainexperr:int=64;
		public static const buytrainspaceerror:int=65;
		public static const nosucheqiupforgeformula:int=66;
		public static const notenough_materials:int=67;
		public static const nosuchpreequip:int=68;
		public static const medalhasused:int=69;
		public static const medalnotused:int=70;
		public static const nosuchshenfuforgeformula:int=71;
		public static const forgeshenfuerror:int=72;
		public static const shenfunotused:int=73;
		public static const shenfuhasused:int=74;
		public static const wuxingshinotused:int=75;
		public static const wuxingshihasused:int=76;
		public static const yuanshicannotuse:int=77;
		public static const nosuchwuxingslot:int=78;
		public static const wuxingnotmatched:int=79;
		public static const wuxingshilevelmax:int=80;
		public static const suipianoverflow:int=81;
		public static const mainherocannottrain:int=82;
		public static const toolowleveltoupgradehero:int=83;
		public static const allupgradecompleted:int=84;
		public static const nosuchskillstudyinfo:int=85;
		public static const instancenotfinished:int=86;
		public static const rewardalreadygot:int=87;
		public static const collectiondailylimit:int=88;
		public static const energyoverflow:int=90;
		public static const energydownflow:int=91;
		public static const notreasureteam:int=92;
		public static const receiverewardstatenow:int=93;
		public static const starttreasurestate:int=94;
		public static const cityarea_movecd:int=95;
		public static const cityarea_notowner:int=96;
		public static const cityarea_havestcd:int=97;
		public static const cityarea_minecountcap:int=98;
		public static const cityarea_robcap:int=99;
		public static const cityarea_levellimit:int=100;
		public static const cityarea_changecitycd:int=101;
		public static const action_end:int = 102;
		public static const TEAM_FULL:int = 103;
		public static const cityarea_minerobbed:int=104;
		public static const cityarea_rescap:int=105;
		public static const cityarea_unionrobbed:int=106;
		public static const cityarea_targetfighting:int=107;
		public static const cityarea_needfight:int=108;
		public static const cityarea_noowner:int=109;
		public static const cityarea_nofight:int=110;
		public static const cityarea_cannotreplace:int=111;
		public static const pvp_toolowleveltopvp:int=112;
		public static const ROOM_START:int = 113;
		public static const cityarea_attackfail:int=114;
		public static const pvp_opnoformation:int=115;
		public static const pvp_overflowranking:int=116;
		public static const DUOQI_itemCaptured:int = 117;			
		public static const DUOQI_itemCDing:int = 118;
		public static const DUOQI_itemCountOut:int = 119;
		public static const pvp_notinranking:int=120;
		public static const cityarea_cannotdismissdefaultmine:int=121;
		public static const pvp_erroropinfo:int=122;
		public static const pvp_norewardnow:int=123;
		public static const DUOQI_PVEEND:int = 124;
		public static const pvp_pvpendorpause:int=125;
		public static const DUOQI_PLAYERCHALLENGEFAILED:int = 126;			
		public static const FORMATION_SELFNULL:int = 127;		
		public static const FORMATION_OPPONULL:int = 128;			
		public static const action_notStart:int = 129;				
		public static const CANNOT_ATTACKTEAMMATE:int = 130;
		public static const DUOQI_YUNCHUICOUNTMAX:int = 131;
		public static const NOSUCH_PLAYER:int = 132;
		public static const DUOQI_TargetItemRefushed:int = 133;
		public static const DUOQI_NoEnoughYunChui:int = 134;
		public static const zb_nothopedplayer:int = 135;
		public static const DUOQI_CANNOTATTACK:int=136;				//此时不能攻击
		public static const DUOQI_ItemUseFailed:int = 137;			//使用道具失败
		public static const notenough_cards:int=138;
		public static const VIP_LOW:int=139;
		public static const ONLINE_TIMESHORT:int = 140;				//在线时间太短了
		public static const NOSUCH_TREASURE:int = 141;
		public static const DAJIN_PROTECTING:int = 142;
		public static const DAJIN_NEEDFIGHT:int = 143;
		public static const NICKNAME_DUPLICATE:int = 144;
		public static const NICKNAME_ISNULL:int = 145;
		public static const NOSUCH_PUSHREWARD:int = 146;
		public static const REWARDEXPIRED:int = 147;
		public static const CHALLENGE_CD:int = 148;
		public static const TARGET_IN_CHALLENGE:int = 149;
		public static const DAILY_QUEST_REFRESHMAX:int = 150;					//刷新次数到最大
		public static const DAILY_QUEST_NOSUCH_QUEST:int = 151;
		public static const DAILY_QUEST_BEACCEPTED:int = 152;
		public static const DAILY_QUEST_OTHERACCEPTED:int = 153;
		public static const DAILY_QUEST_CANNOTCANCEL:int = 154;
		public static const DAILY_QUEST_NOINFO:int = 155;							//不存在每日任务信息
		public static const DAILY_QUESTBECANCELED:int = 156;						//被放弃的任务不能再被接受
		
		public static const NOSUCH_RAID:int = 157;
		public static const raid_levellimit:int = 158;
		public static const raid_notopening:int = 159;
		public static const raid_noroom:int = 160;
		public static const NOSUCH_USER:int = 161;
		public static const raid_notready:int = 162;
		public static const raid_overcount:int = 163;
		public static const cityarea_robcity_levellimit:int = 164;
		
		public static const cannot_buymore:int = 165;
		public static const cityarea_robcity_levellimit_def:int = 166;
		public static const cityarea_capmine_levellimit:int = 167;
		public static const cityarea_capmine_levellimit_def:int = 168;
		public static const cityarea_robmine_cd:int = 169;
		
		public static const TARGET_BE_INVITED:int = 170;
		public static const instance_usercannotentercol:int = 171;
		public static const instance_userteamcountdailylimit:int = 172;
		public static const instance_teamplayernotready:int = 173;
		public static const team_infighting:int = 174;
		
		public static const CardcodeNotExist:int = 175;
		public static const CardcodeIsUsed:int = 176;
		public static const NotCardcodeOwner:int = 177; 
		
		public static const FireHeroInventoryFull:int = 178;
		
		public static const Guild_Coin_Contribute_Limit:int = 179;
		
		public static const cityarea_capmine_ownlimit:int = 180;
		
		public static const zaixianRewardCountOut:int = 181;
		
		public static const duoqientercountout:int = 182;
		
		public static const DUOQI_jiaxuenbuyMax:int = 183;				//
		public static const DUOQI_NoEnoughJiaXue:int = 184;
		
		public static const GET_SHORTCUTREWARD_ERR:int = 185;
		
		public static const QUEST_FinishCommiticalQuest:int = 186;
		
		public static const QUSET_FINISHNORMALQUEST:int = 187;
		
		public static const NOSUCH_VipTeQuan:int = 188;
		
		public static const Energy_NotEnough:int = 189;
		
		public static const instance_userenergylimit:int = 190;
		
		public static const HeroUnlockQuestNotDone:int = 191;
		public static const MainHeroCannotSpeedup:int = 192;
		public static const MainHeroLevelMustbeFirst:int = 193;
		public static const Skill_NoLevelLock:int = 194;
		public static const NoPaihangReward:int = 195;
		
		public static const FubenofflinebekillcountOut:int = 196;
		public static const cityarea_sucwithrob:int = 197;
		public static const cityarea_switchchannelcd:int = 198;
		public static const cityarea_beattacking:int = 199;
		
		public function ErrorCode()
		{
		}
		
		public static function GetResCollectError(errorcode:int, ... rest):String
		{
			switch(errorcode)
			{
				case nosuchinfo:
					return TextEngine.getTextById(301);
				case citynotmatch:
					return TextEngine.getTextById(302);
				case infonotmatched:
					return TextEngine.getTextById(303);
				case valuedownflow:
					return TextEngine.getTextById(306);
			}
			
			return StringUtil.substitute(TextEngine.getTextById(194),errorcode);
		}
		
		
		public static function ShowValueErroCode(changerreturn:Array,needpop:Boolean=true):String
		{
			var showstr:String=null;
			
			var restype:int=0;
			if (changerreturn[0]==valuedownflow)
			{
				restype=changerreturn[1];
				switch(changerreturn[1])
				{

					case UserResourceType.Coin:
						showstr=TextEngine.getTextById(186);
						break;
					case UserResourceType.Food:
						showstr=TextEngine.getTextById(188);
						break;
					case UserResourceType.Stone:
						showstr=TextEngine.getTextById(187);
						break;
					case UserResourceType.Lijin:
						showstr=TextEngine.getTextById(198);
						break;
					case UserResourceType.Yuanbao:
						showstr=TextEngine.getTextById(199);
						break;
					case UserResourceType.TreasureMap:
						showstr=TextEngine.getTextById(426);
						break;
					case UserResourceType.Reputation:
						showstr=TextEngine.getTextById(898);
						break;
				}
				showstr=StringUtil.substitute(showstr,-changerreturn[2]);
			}
			else if (changerreturn[0]==valueoverflow)
			{
				
				switch(changerreturn[1])
				{
					case UserResourceType.Stamina:
						showstr=TextEngine.getTextById(533);
						restype=UserResourceType.Stamina_cap;
						break;
					case UserResourceType.Coin:
						showstr=TextEngine.getTextById(189);
						restype=UserResourceType.Coin_cap;
						break;
					case UserResourceType.Food:
						showstr=TextEngine.getTextById(191);
						restype=UserResourceType.Food_cap;
						break;
					case UserResourceType.Stone:
						showstr=TextEngine.getTextById(190);
						restype=UserResourceType.Stone_cap;
						break;
				}
			}
			
			if (showstr)
			{
				return showstr;
			}
			
			return StringUtil.substitute(TextEngine.getTextById(201),changerreturn[0]);
		}
		
		public static function GetTechErrorString(errorcode:int, ... rest):String
		{
			switch(errorcode)
			{
				case leveloverflow:
					return TextEngine.getTextById(210);
				case leveloverhall:
					return StringUtil.substitute(TextEngine.getTextById(211),rest);
					
			}
			
			return StringUtil.substitute(TextEngine.getTextById(194),errorcode);
		}
		
		public static function GetContactErrorString(errorcode:int, ... rest):String
		{
			switch(errorcode)
			{
				case usernotexist:
					break;
				case ErrorCode.infonotmatched:
					return TextEngine.getTextById(20054);
					break;
				case ErrorCode.valueoverflow:
					return StringUtil.substitute(TextEngine.getTextById(20056),rest);
					break;
			}
			
			return getErrorString(errorcode,rest);
		}
		
		public static function GetMailErrorString(errorcode:int, ... rest):String
		{
			switch(errorcode)
			{
				
			}
			
			return getErrorString(errorcode,rest);
		}
		
		public static function GetCityErrorString(errorcode:int, ... rest):String
		{
			switch(errorcode)
			{
				case usernotexist:
					return TextEngine.getTextById(401);
					break;
				case leveloverhall:
					return TextEngine.getTextById(193);
					break;
				case citynotmatch:
					return TextEngine.getTextById(195);
					break;
				case infonotmatched:
					return TextEngine.getTextById(196);
					break;
				case nosuchinfo:
					return TextEngine.getTextById(200);
					break;
				case nosuchbuidling:
					return TextEngine.getTextById(197);
					break;
				case leveloverflow:
					return TextEngine.getTextById(192);
					break;
				case buildingnumover:
					return TextEngine.getTextById(185);
				case valuedownflow:
				case valueoverflow:
				case energydownflow:
				case energyoverflow:
					return "";
					break;
			}
			return StringUtil.substitute(TextEngine.getTextById(194),errorcode);
		}
		
		public static function GetShenfuErrorString(errorcode:int, ... rest):String
		{
			switch(errorcode)
			{
				case nosuchinfo:
					return TextEngine.getTextById(347);
					break;
				case infonotmatched:
					return TextEngine.getTextById(348);
					break;
				
			}
			return StringUtil.substitute(TextEngine.getTextById(194),errorcode);
		}
		
		public static function GetMedalErrorString(errorcode:int, ... rest):String
		{
			switch(errorcode)
			{
				case nosuchinfo:
					return TextEngine.getTextById(252);
					break;
			
			}
			return StringUtil.substitute(TextEngine.getTextById(194),errorcode);
		}
		
		public static function GetGiftErrorString(errorcode:int, ... rest):String
		{
			var errorString:String = "";
			switch(errorcode)
			{
				case CardcodeNotExist:
					errorString = TextEngine.getTextById(961);
					break;
				case CardcodeIsUsed:
					errorString = TextEngine.getTextById(962);
					break;
				case NotCardcodeOwner:
					errorString = TextEngine.getTextById(963);
					break;
			}
			
			return errorString;
		}
	
		public static function getErrorString(errorcode:int, ... rest):String
		{
			var errorString:String = "";
			switch(errorcode)
			{
				case usernotexist:
					errorString = TextEngine.getTextById(271);
					break;
				case sysheronotexist:
					errorString = TextEngine.getTextById(272);
					break;
				case notcanhiredhero:
					errorString = TextEngine.getTextById(273);
					break;
				case inventoryisfull:
					errorString = TextEngine.getTextById(274);
					break;
				case nosuchsysequip:
					errorString = TextEngine.getTextById(275);
					break;
				case tempequipcannotsell:
					errorString = TextEngine.getTextById(276);
					break;
				case equiplevelnotreached:
					errorString = TextEngine.getTextById(277);
					break;
				case ishiredhero:
					errorString = TextEngine.getTextById(278);
					break;
				case notenough_herospace:
					errorString = TextEngine.getTextById(279);
					break;
				case nosuchshopitem:
					errorString = TextEngine.getTextById(280);
					break;
				case nosuchsysmedal:
					errorString = TextEngine.getTextById(281);
					break;
				case nosuchsysshenfu:
					errorString = TextEngine.getTextById(282);
					break;
				case nosuchsyswuxingshi:
					errorString = TextEngine.getTextById(283);
					break;
				case nosuchsyssuipian:
					errorString = TextEngine.getTextById(284);
					break;
				case nosuchuserhero:
					errorString = TextEngine.getTextById(285);
					break;
				case nosuchuserequip:
					errorString = TextEngine.getTextById(286);
					break;
				case nosuchusermedal:
					errorString = TextEngine.getTextById(287);
					break;
				case nosuchusershenfu:
					errorString = TextEngine.getTextById(288);
					break;
				case nosuchuserwuxingshi:
					errorString = TextEngine.getTextById(289);
					break;
				case nosuchusersuipian:
					errorString = TextEngine.getTextById(290);
					break;
				case heroisalreadytrain:
					errorString = TextEngine.getTextById(291);
					break;
				case noidletrainqueue:
					errorString = TextEngine.getTextById(292);
					break;
				case heroisnotintrain:
					errorString = TextEngine.getTextById(293);
					break;
				case enhancetimesover:
					errorString = TextEngine.getTextById(294);
					break;
				case equipleveltoohigh:
					errorString = TextEngine.getTextById(295);
					break;
				case counttrainexperr:
					errorString = TextEngine.getTextById(296);
					break;
				case buytrainspaceerror:
					errorString = TextEngine.getTextById(297);
					break;
				case nosucheqiupforgeformula:
					errorString = TextEngine.getTextById(298);
					break;
				case notenough_materials:
					errorString = TextEngine.getTextById(299);
					break;
				case nosuchpreequip:
					errorString = TextEngine.getTextById(300);
					break;
				case nosuchshenfuforgeformula:
					errorString = TextEngine.getTextById(319);
					break;
				case forgeshenfuerror:
					errorString = TextEngine.getTextById(320);
					break;
				case shenfunotused:
					errorString = TextEngine.getTextById(322);
					break;
				case shenfuhasused:
					errorString = TextEngine.getTextById(321);
					break;
				case wuxingshinotused:
					errorString = TextEngine.getTextById(329);
					break;
				case wuxingshihasused:
					errorString = TextEngine.getTextById(330);
					break;
				case yuanshicannotuse:
					errorString = TextEngine.getTextById(334);
					break;
				case nosuchwuxingslot:
					errorString = TextEngine.getTextById(338);
					break;
				case wuxingnotmatched:
					errorString = TextEngine.getTextById(339);
					break;
				case wuxingshilevelmax:
					errorString = TextEngine.getTextById(345);
					break;
				case suipianoverflow:
					errorString = TextEngine.getTextById(346);
					break;
				case mainherocannottrain:
					errorString = TextEngine.getTextById(368);
					break;
				case toolowleveltoupgradehero:
					errorString = TextEngine.getTextById(371);
					break;
				case allupgradecompleted:
					errorString = TextEngine.getTextById(372);
					break;
				case nosuchskillstudyinfo:
					errorString = TextEngine.getTextById(373);
					break;
				case collectiondailylimit:
					errorString = TextEngine.getTextById(399);
					break;
				case notreasureteam:
					errorString = TextEngine.getTextById(420);
					break;
				case receiverewardstatenow:
					errorString = TextEngine.getTextById(421);
					break;
				case starttreasurestate:
					errorString = TextEngine.getTextById(422);
					break;
				case pvp_toolowleveltopvp:
					errorString = TextEngine.getTextById(449);
					break;
				case ROOM_START:
					errorString = TextEngine.getTextById(485);
					break;
				case TEAM_FULL:
				case teamfull:
					errorString = TextEngine.getTextById(474);
					break;
				case ROOM_FULL:
					errorString = TextEngine.getTextById(486);
					break;
				case NOSUCH_ROOM:
					errorString = TextEngine.getTextById(487);
					break;
				case pvp_opnoformation:
					errorString = TextEngine.getTextById(488);
					break;
				case pvp_overflowranking:
					errorString = TextEngine.getTextById(525);
					break;
				case pvp_notinranking:
					errorString = TextEngine.getTextById(526);
					break;
				case pvp_erroropinfo:
					errorString = TextEngine.getTextById(537);
					break;
				case pvp_norewardnow:
					errorString = TextEngine.getTextById(538);
					break;
				case pvp_pvpendorpause:
					errorString = TextEngine.getTextById(543);
					break;
				case CANNOT_ATTACKTEAMMATE:
					errorString = TextEngine.getTextById(567);
					break;
				case DUOQI_NoEnoughYunChui:
					errorString = TextEngine.getTextById(573);
					break;
				case NOSUCH_PLAYER:
					errorString = TextEngine.getTextById(596);
					break;
				case DUOQI_ItemUseFailed:
					errorString = TextEngine.getTextById(597);
					break;
				case DUOQI_TargetItemRefushed:
					errorString = TextEngine.getTextById(598);
					break;
				case ONLINE_TIMESHORT:
					errorString = TextEngine.getTextById(682);
					break;
				case NOSUCH_PUSHREWARD:
					errorString = TextEngine.getTextById(761);
					break;
				case REWARDEXPIRED:
					errorString = TextEngine.getTextById(762);
					break;
				case nosuchteam:
					errorString = TextEngine.getTextById(766);
					break;
				case targetnotexisted:
					errorString = TextEngine.getTextById(775);
					break;
				case targetbusy:
					errorString = TextEngine.getTextById(559);
					break;
				case CHALLENGE_CD:
					errorString = TextEngine.getTextById(776);
					break;
				case collectionlocked:
					errorString = TextEngine.getTextById(782);
					break;
				case DAILY_QUEST_REFRESHMAX:
					errorString = TextEngine.getTextById(800);
					break;
				case DAILY_QUEST_NOSUCH_QUEST:
					errorString = TextEngine.getTextById(801);
					break;
				case DAILY_QUEST_BEACCEPTED:
					errorString = TextEngine.getTextById(802);
					break;
				case DAILY_QUEST_OTHERACCEPTED:
					errorString = TextEngine.getTextById(803);
					break;
				case DAILY_QUEST_NOINFO:
					errorString = TextEngine.getTextById(806);
					break;
				case DUOQI_itemCaptured:
					errorString = TextEngine.getTextById(831);
					break;
				case DUOQI_itemCDing:
					errorString = TextEngine.getTextById(830);
					break;
				case DUOQI_itemCountOut:
					errorString = TextEngine.getTextById(832);
					break;
				case FireHeroInventoryFull:
					errorString = TextEngine.getTextById(967);
					break;
				case duoqientercountout:
					errorString = TextEngine.getTextById(20046);
					break;
				case DUOQI_NoEnoughJiaXue:
					errorString = TextEngine.getTextById(20064);
					break;
				case DUOQI_jiaxuenbuyMax:
					errorString = TextEngine.getTextById(572);
					break;
				case QUEST_FinishCommiticalQuest:
					errorString = TextEngine.getTextById(20070);
					break;
				case QUSET_FINISHNORMALQUEST:
					errorString = TextEngine.getTextById(20073);
					break;
				case NOSUCH_VipTeQuan:
					errorString = TextEngine.getTextById(20074);
					break;
				case HeroUnlockQuestNotDone:
					errorString = TextEngine.getTextById(20092);
					break;
				case MainHeroCannotSpeedup:
					errorString = TextEngine.getTextById(20101);
					break;
				case MainHeroLevelMustbeFirst:
					errorString = TextEngine.getTextById(20102);
					break;
				case Skill_NoLevelLock:
					errorString = TextEngine.getTextById(20219);
					break;
				case NoPaihangReward:
					errorString = TextEngine.getTextById(20220);
					break;
				case instance_userteamcountdailylimit:
					errorString = TextEngine.getTextById(949);
					break;
				default:
					break;
			}
			
			if(rest.length > 0)
			{
				return StringUtil.substitute(errorString, rest);
			}
			else
			{
				return errorString;
			}
		}
		
		public static function getCityAreaErrorString(errorcode:int, ... rest):String
		{
			var errorString:String = "";
			switch(errorcode)
			{
				case cityarea_movecd:
					errorString = TextEngine.getTextById(429);
					break;
				case cityarea_havestcd:
					errorString = TextEngine.getTextById(430);
					break;
				case cityarea_minecountcap:
					errorString = TextEngine.getTextById(431);
					break;
				case cityarea_robcap:
				case cityarea_minerobbed:
					errorString = TextEngine.getTextById(432);
					break;
				case cityarea_targetfighting:
					errorString = TextEngine.getTextById(692);
					break;
				case ErrorCode.cityarea_unionrobbed:
					errorString = TextEngine.getTextById(971);
					break;
				case cityarea_switchchannelcd:
					errorString = TextEngine.getTextById(20317);
					break;
				case cityarea_beattacking:
					errorString = TextEngine.getTextById(20333);
					break;
				default:
					break;
			}
			
			if(rest.length > 0){
				return StringUtil.substitute(errorString, rest);
			}else{
				return errorString;
			}
		}
		
		public static function getRaidErrorString(errorcode:int, ... rest):String
		{
			var errorString:String = "";
			switch(errorcode)
			{
				case raid_levellimit:
					errorString = TextEngine.getTextById(835);
					break;
				case raid_notopening:
					errorString = TextEngine.getTextById(836);
					break;
				case raid_notready:
					errorString = TextEngine.getTextById(837);
					break;
				case raid_overcount:
					errorString = TextEngine.getTextById(838);
					break;
				default:
					break;
			}
			
			if(rest.length > 0){
				return StringUtil.substitute(errorString, rest);
			}else{
				return errorString;
			}
		}
	}
}