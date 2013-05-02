" Vim syntax file
" Language:	eAthena Script
" Maintainer:	Syaoran <syao@dotalux.com>
" Last Change:	2008 Oct 30

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" A bunch of useful eAthena keywords
syn keyword	athStatement	goto break return continue end close close2 next jump_zero menu input select prompt
syn keyword	athLabel	case default OnInit OnInterIfInit OnMyMobDeath OnCharIfInit OnAgitStart
syn keyword	athLabel	OnMinute[0-9][0-9] OnClock[0-9][0-9][0-9][0-9] OnHour[0-9][0-9] OnDay[0-9]
syn keyword	athLabel	OnTimer[0-9]+ OnAgitInit OnAgitStart OnAgitEnd OnAgitBreak OnAgitEliminate
syn keyword	athLabel	OnPCLoginEvent OnPCLogoutEvent OnPCBaseLvUpEvent OnPCJobLvUpEvent OnPCDieEvent
syn keyword	athLabel	OnPCKillEvent OnNPCKillEvent OnPCLoadMapEvent

syn keyword	athConditional	if else switch
syn keyword	athRepeat	while for do

syn keyword	athTodo		contained TODO FIXME XXX

" athCommentGroup allows adding matches for special things in comments
syn cluster	athCommentGroup	contains=athTodo

" String and Character constants
" Highlight Event names
syn match	athSpecial	display contained "[a-zA-Z][a-zA-Z0-9 _-]\+::On[A-Z][A-Za-z0-9 _-]\+"
syn region	athString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=athSpecial,@Spell

"syn match	athCharacter	"L\='[^\\]'"
"syn match	athCharacter	"L'[^']*'" contains=athSpecial

"when wanted, highlight trailing white space
"if exists("c_space_errors")
"  if !exists("c_no_trail_space_error")
    syn match	athSpaceError	display excludenl "\s\+$"
"  endif
"  if !exists("c_no_tab_space_error")
    syn match	athSpaceError	display " \+\t"me=e-1
"  endif
"endif

" This should be before cErrInParen to avoid problems with #define ({ xxx })
if exists("c_curly_error")
  syntax match athCurlyError "}"
  syntax region athBlock	start="{" end="}" contains=ALLBUT,athCurlyError,@athParenGroup,athErrInParen,athErrInBracket,athString,@Spell fold
else
  syntax region	athBlock	start="{" end="}" transparent fold
endif

"catch errors caused by wrong parenthesis and brackets
syn cluster	athParenGroup	contains=athParenError,athIncluded,athSpecial,athCommentSkip,athCommentString,athComment2String,@athCommentGroup,athCommentStartError,athUserCont,athUserLabel,athBitField,athNumber,athFloat,athNumbersCom
if exists("c_no_curly_error")
"  syn region	athParen	transparent start='(' end=')' contains=ALLBUT,@athParenGroup,athString,@Spell
  syn region	athParen	transparent start='(' end=')' contains=ALLBUT,@athParenGroup,@Spell
  syn match	athParenError	display ")"
  syn match	athErrInParen	display contained "^[{}]"
elseif exists("c_no_bracket_error")
"  syn region	athParen	transparent start='(' end=')' contains=ALLBUT,@athParenGroup,athString,@Spell
  syn region	athParen	transparent start='(' end=')' contains=ALLBUT,@athParenGroup,@Spell
  syn match	athParenError	display ")"
  syn match	athErrInParen	display contained "[{}]"
else
"  syn region	athParen	transparent start='(' end=')' contains=ALLBUT,@athParenGroup,athErrInBracket,athString,@Spell
  syn region	athParen	transparent start='(' end=')' contains=ALLBUT,@athParenGroup,athErrInBracket,@Spell
  syn match	athParenError	display "[\])]"
  syn match	athErrInParen	display contained "[\]{}]"
"  syn region	athBracket	transparent start='\[' end=']' contains=ALLBUT,@athParenGroup,athErrInParen,athString,@Spell
  syn region	athBracket	transparent start='\[' end=']' contains=ALLBUT,@athParenGroup,athErrInParen,@Spell
  syn match	athErrInBracket	display contained "[);{}]"
endif

"integer number, or floating point number without a dot and with "f".
syn case ignore
syn match	athNumbers	display transparent "\<\d\|\.\d" contains=athNumber,athFloat
syn match	athNumbersCom	display contained transparent "\<\d\|\.\d" contains=athNumber,athFloat
syn match	athNumber	display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"
"hex number
syn match	athNumber	display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
syn match	ahtFloat	display contained "\d\+f"
"floating point number, with dot, optional exponent
syn match	athFloat	display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
"floating point number, starting with a dot, optional exponent
syn match	athFloat	display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"

syn case match

if exists("c_comment_strings")
  " A comment can contain athString, athCharacter and athNumber.
  " But a "*/" inside an athString in an athComment DOES end the comment!  So we
  " need to use a special type of athString: athCommentString, which also ends on
  " "*/", and sees a "*" at the start of the line as comment again.
  " Unfortunately this doesn't very well work for // type of comments :-(
  syntax match	athCommentSkip	contained "^\s*\*\($\|\s\+\)"
  syntax region athCommentString contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=athSpecial,athCommentSkip
  syntax region athComment2String contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=athSpecial
  syntax region  athCommentL	start="//" skip="\\$" end="$" keepend contains=@athCommentGroup,athComment2String,athCharacter,athNumbersCom,athSpaceError,@Spell
  if exists("c_no_comment_fold")
    " Use "extend" here to have preprocessor lines not terminate halfway a
    " comment.
    syntax region athComment	matchgroup=athCommentStart start="/\*" end="\*/" contains=@athCommentGroup,athCommentStartError,athCommentString,athCharacter,athNumbersCom,athSpaceError,@Spell extend
  else
    syntax region athComment	matchgroup=athCommentStart start="/\*" end="\*/" contains=@athCommentGroup,athCommentStartError,athCommentString,athCharacter,athNumbersCom,athSpaceError,@Spell fold extend
  endif
else
  syn region	athCommentL	start="//" skip="\\$" end="$" keepend contains=@athCommentGroup,athSpaceError,@Spell
  if exists("c_no_comment_fold")
    syn region	athComment	matchgroup=athCommentStart start="/\*" end="\*/" contains=@athCommentGroup,athCommentStartError,athSpaceError,@Spell extend
  else
    syn region	athComment	matchgroup=athCommentStart start="/\*" end="\*/" contains=@athCommentGroup,athCommentStartError,athSpaceError,@Spell fold extend
  endif
endif
" keep a // comment separately, it terminates a preproc. conditional
syntax match	athCommentError	display "\*/"
syntax match	athCommentStartError display "/\*"me=e-1 contained

syn keyword	athOperator	getd setd set getvariableofnpc getarg mes
syn keyword	athOperator	setarray cleararray copyarray deletearray getarraysize getelementofarray
syn keyword	athOperator	strcharinfo strnpcinfo readparam getcharid getnpcid getstrlen

syn keyword	athStructure	script warp monster areamonster duplicate shop cashshop rpshop mapflag function callfunc
syn keyword	athStructure	callsub

syn keyword	athConstant	Job_Novice Job_Swordman Job_Mage Job_Archer Job_Acolyte Job_Merchant Job_Thief
syn keyword	athConstant	Job_Knight Job_Priest Job_Wizard Job_Blacksmith Job_Hunter Job_Assassin Job_Knight2
syn keyword	athConstant	Job_Crusader Job_Monk Job_Sage Job_Rogue Job_Alchem Job_Alchemist Job_Bard Job_Dancer
syn keyword	athConstant	Job_Crusader2 Job_Wedding Job_SuperNovice Job_Gunslinger Job_Ninja Job_Xmas Job_Summer
syn keyword	athConstant	Job_Hanbok Job_Novice_High Job_Swordman_High Job_Mage_High Job_Archer_High
syn keyword	athConstant	Job_Acolyte_High Job_Merchant_High Job_Thief_High Job_Lord_Knight Job_High_Priest
syn keyword	athConstant	Job_High_Wizard Job_Whitesmith Job_Sniper Job_Assassin_Cross Job_Lord_Knight2
syn keyword	athConstant	Job_Paladin Job_Champion Job_Professor Job_Stalker Job_Creator Job_Clown Job_Gypsy
syn keyword	athConstant	Job_Paladin2 Job_Baby Job_Baby_Swordman Job_Baby_Mage Job_Baby_Archer Job_Baby_Acolyte
syn keyword	athConstant	Job_Baby_Merchant Job_Baby_Thief Job_Baby_Knight Job_Baby_Priest Job_Baby_Wizard
syn keyword	athConstant	Job_Baby_Blacksmith Job_Baby_Hunter Job_Baby_Assassin Job_Baby_Knight2 Job_Baby_Crusader
syn keyword	athConstant	Job_Baby_Monk Job_Baby_Sage Job_Baby_Rogue Job_Baby_Alchem Job_Baby_Alchemist
syn keyword	athConstant	Job_Baby_Bard Job_Baby_Dancer Job_Baby_Crusader2 Job_Super_Baby Job_Taekwon
syn keyword	athConstant	Job_Star_Gladiator Job_Star_Gladiator2 Job_Soul_Linker Job_Gangsi Job_Death_Knight
syn keyword	athConstant	Job_Dark_Collector Job_Rune_Knight Job_Warlock Job_Ranger Job_Arch_Bishop Job_Mechanic
syn keyword	athConstant	Job_Guillotine_Cross Job_Rune_Knight_T Job_Warlock_T Job_Ranger_T Job_Arch_Bishop_T
syn keyword	athConstant	Job_Mechanic_T Job_Guillotine_Cross_T Job_Royal_Guard Job_Sorcerer Job_Minstrel
syn keyword	athConstant	Job_Wanderer Job_Sura Job_Genetic Job_Shadow_Chaser Job_Royal_Guard_T Job_Sorcerer_T
syn keyword	athConstant	Job_Minstrel_T Job_Wanderer_T Job_Sura_T Job_Genetic_T Job_Shadow_Chaser_T
syn keyword	athConstant	Job_Rune_Knight2 Job_Rune_Knight_T2 Job_Royal_Guard2 Job_Royal_Guard_T2 Job_Ranger2
syn keyword	athConstant	Job_Ranger_T2 Job_Mechanic2 Job_Mechanic_T2 Job_Baby_Rune Job_Baby_Warlock
syn keyword	athConstant	Job_Baby_Ranger Job_Baby_Bishop Job_Baby_Mechanic Job_Baby_Cross Job_Baby_Guard
syn keyword	athConstant	Job_Baby_Sorcerer Job_Baby_Minstrel Job_Baby_Wanderer Job_Baby_Sura Job_Baby_Genetic
syn keyword	athConstant	Job_Baby_Chaser Job_Baby_Rune2 Job_Baby_Guard2 Job_Baby_Ranger2 Job_Baby_Mechanic2
syn keyword	athConstant	Job_Super_Novice_E Job_Super_Baby_E Job_Kagerou Job_Oboro
syn keyword	athConstant	EAJL_2_1 EAJL_2_2 EAJL_2 EAJL_UPPER EAJL_BABY EAJL_THIRD EAJ_UPPERMASK EAJ_BASEMASK
syn keyword	athConstant	EAJ_NOVICE EAJ_SWORDMAN EAJ_MAGE EAJ_ARCHER EAJ_ACOLYTE EAJ_MERCHANT EAJ_THIEF
syn keyword	athConstant	EAJ_TAEKWON EAJ_GUNSLINGER EAJ_NINJA EAJ_GANGSI EAJ_SUPER_NOVICE EAJ_KNIGHT EAJ_WIZARD
syn keyword	athConstant	EAJ_HUNTER EAJ_PRIEST EAJ_BLACKSMITH EAJ_ASSASSIN EAJ_STAR_GLADIATOR EAJ_KAGEROUOBORO
syn keyword	athConstant	EAJ_DEATH_KNIGHT EAJ_CRUSADER EAJ_SAGE EAJ_BARDDANCER EAJ_MONK EAJ_ALCHEMIST EAJ_ROGUE
syn keyword	athConstant	EAJ_SOUL_LINKER EAJ_DARK_COLLECTOR EAJ_RUNE_KNIGHT EAJ_WARLOCK EAJ_RANGER
syn keyword	athConstant	EAJ_ARCH_BISHOP EAJ_MECHANIC EAJ_GUILLOTINE_CROSS EAJ_ROYAL_GUARD EAJ_SORCERER
syn keyword	athConstant	EAJ_MINSTRELWANDERER EAJ_SURA EAJ_GENETIC EAJ_SHADOW_CHASER EAJ_RUNE_KNIGHT_T
syn keyword	athConstant	EAJ_WARLOCK_T EAJ_RANGER_T EAJ_ARCH_BISHOP_T EAJ_MECHANIC_T EAJ_GUILLOTINE_CROSS_T
syn keyword	athConstant	EAJ_ROYAL_GUARD_T EAJ_SORCERER_T EAJ_MINSTRELWANDERER_T EAJ_SURA_T EAJ_GENETIC_T
syn keyword	athConstant	EAJ_SHADOW_CHASER_T EAJ_NOVICE_HIGH EAJ_SWORDMAN_HIGH EAJ_MAGE_HIGH EAJ_ARCHER_HIGH
syn keyword	athConstant	EAJ_ACOLYTE_HIGH EAJ_MERCHANT_HIGH EAJ_THIEF_HIGH EAJ_LORD_KNIGHT EAJ_HIGH_WIZARD
syn keyword	athConstant	EAJ_SNIPER EAJ_HIGH_PRIEST EAJ_WHITESMITH EAJ_ASSASSIN_CROSS EAJ_PALADIN EAJ_PROFESSOR
syn keyword	athConstant	EAJ_CLOWNGYPSY EAJ_CHAMPION EAJ_CREATOR EAJ_STALKER EAJ_BABY EAJ_BABY_SWORDMAN
syn keyword	athConstant	EAJ_BABY_MAGE EAJ_BABY_ARCHER EAJ_BABY_ACOLYTE EAJ_BABY_MERCHANT EAJ_BABY_THIEF
syn keyword	athConstant	EAJ_SUPER_BABY EAJ_BABY_KNIGHT EAJ_BABY_WIZARD EAJ_BABY_HUNTER EAJ_BABY_PRIEST
syn keyword	athConstant	EAJ_BABY_BLACKSMITH EAJ_BABY_ASSASSIN EAJ_BABY_CRUSADER EAJ_BABY_SAGE
syn keyword	athConstant	EAJ_BABY_BARDDANCER EAJ_BABY_MONK EAJ_BABY_ALCHEMIST EAJ_BABY_ROGUE EAJ_SUPER_NOVICE_E
syn keyword	athConstant	EAJ_SUPER_BABY_E EAJ_BABY_RUNE EAJ_BABY_WARLOCK EAJ_BABY_RANGER EAJ_BABY_BISHOP
syn keyword	athConstant	EAJ_BABY_CROSS EAJ_BABY_MECHANIC EAJ_BABY_GUARD EAJ_BABY_SORCERER
syn keyword	athConstant	EAJ_BABY_MINSTRELWANDERER EAJ_BABY_SURA EAJ_BABY_GENETIC EAJ_BABY_CHASER
syn keyword	athConstant	Option_Wedding Option_Xmas Option_Summer Option_Wug Option_Wugrider
syn keyword	athConstant	Option_Hanbok Option_Mounting
syn keyword	athConstant	bc_all bc_map bc_area bc_self bc_pc bc_npc bc_yellow bc_blue bc_woe
syn keyword	athConstant	mf_nomemo mf_noteleport mf_nosave mf_nobranch mf_nopenalty mf_nozenypenalty mf_pvp
syn keyword	athConstant	mf_pvp_noparty mf_pvp_noguild mf_gvg mf_gvg_noparty mf_notrade mf_noskill mf_nowarp
syn keyword	athConstant	mf_partylock mf_noicewall mf_snow mf_fog mf_sakura mf_leaves mf_rain mf_nogo mf_clouds
syn keyword	athConstant	mf_clouds2 mf_fireworks mf_gvg_castle mf_gvg_dungeon mf_nightenabled mf_nobaseexp
syn keyword	athConstant	mf_nojobexp mf_nomobloot mf_nomvploot mf_noreturn mf_nowarpto mf_nightmaredrop
syn keyword	athConstant	mf_restricted mf_nocommand mf_nodrop mf_jexp mf_bexp mf_novending mf_loadevent
syn keyword	athConstant	mf_nochat mf_noexppenalty mf_guildlock mf_town mf_autotrade mf_allowks
syn keyword	athConstant	mf_monster_noteleport mf_pvp_nocalcrank mf_battleground mf_reset mf_channoautojoin
syn keyword	athConstant	mf_nousecart mf_noitemconsumption mf_sumstartmiracle mf_nomineeffect mf_nolockon
syn keyword	athConstant	mf_noitemconsume mf_gvg_noguild
syn keyword	athConstant	cell_walkable cell_shootable cell_water cell_npc cell_basilica cell_landprotector
syn keyword	athConstant	cell_novending cell_nochat cell_chkwall cell_chkwater cell_chkcliff cell_chkpass
syn keyword	athConstant	cell_chkreach cell_chknopass cell_chknoreach cell_chknpc cell_chkbasilica
syn keyword	athConstant	cell_chklandprotector cell_chknovending cell_chknochat
syn keyword	athConstant	StatusPoint BaseLevel SkillPoint Class Upper Zeny Sex Weight MaxWeight JobLevel BaseExp
syn keyword	athConstant	JobExp Karma Manner NextBaseExp NextJobExp Hp MaxHp Sp MaxSp BaseJob BaseClass killerrid
syn keyword	athConstant	killedrid Sitting CharMoves
syn keyword	athConstant	bMaxHP bMaxSP bStr bAgi bVit bInt bDex bLuk bAtk bAtk2 bDef bDef2 bMdef bMdef2 bHit
syn keyword	athConstant	bFlee bFlee2 bCritical bAspd bFame bUnbreakable bAtkRange bAtkEle bDefEle bCastrate
syn keyword	athConstant	bMaxHPrate bMaxSPrate bUseSPrate bAddEle bAddRace bAddSize bSubEle bSubRace bAddEff
syn keyword	athConstant	bResEff bBaseAtk bAspdRate bHPrecovRate bSPrecovRate bSpeedRate bCriticalDef bNearAtkDef
syn keyword	athConstant	bLongAtkDef bDoubleRate bDoubleAddRate bSkillHeal bMatkRate bIgnoreDefEle bIgnoreDefRace
syn keyword	athConstant	bAtkRate bSpeedAddRate bSPRegenRate bMagicAtkDef bMiscAtkDef bIgnoreMdefEle
syn keyword	athConstant	bIgnoreMdefRace bMagicAddEle bMagicAddRace bMagicAddSize bPerfectHitRate
syn keyword	athConstant	bPerfectHitAddRate bCriticalRate bGetZenyNum bAddGetZenyNum bAddDamageClass
syn keyword	athConstant	bAddMagicDamageClass bAddDefClass bAddMdefClass bAddMonsterDropItem bDefRatioAtkEle
syn keyword	athConstant	bDefRatioAtkRace bUnbreakableGarment bHitRate bFleeRate bFlee2Rate bDefRate bDef2Rate
syn keyword	athConstant	bMdefRate bMdef2Rate bSplashRange bSplashAddRange bAutoSpell bHPDrainRate bSPDrainRate
syn keyword	athConstant	bShortWeaponDamageReturn bLongWeaponDamageReturn bWeaponComaEle bWeaponComaRace bAddEff2
syn keyword	athConstant	bBreakWeaponRate bBreakArmorRate bAddStealRate bMagicDamageReturn bAllStats bAgiVit
syn keyword	athConstant	bAgiDexStr bPerfectHide bNoKnockback bClassChange bHPDrainValue bSPDrainValue bWeaponAtk
syn keyword	athConstant	bWeaponAtkRate bDelayrate bHPDrainRateRace bSPDrainRateRace bIgnoreMdefRate
syn keyword	athConstant	bIgnoreDefRate bSkillHeal2 bAddEffOnSkill bHealPower bHealPower2 bRestartFullRecover
syn keyword	athConstant	bNoCastCancel bNoSizeFix bNoMagicDamage bNoWeaponDamage bNoGemStone bNoCastCancel2
syn keyword	athConstant	bNoMiscDamage bUnbreakableWeapon bUnbreakableArmor bUnbreakableHelm bUnbreakableShield
syn keyword	athConstant	bLongAtkRate bCritAtkRate bCriticalAddRace bNoRegen bAddEffWhenHit bAutoSpellWhenHit
syn keyword	athConstant	bSkillAtk bUnstripable bAutoSpellOnSkill bSPGainValue bHPRegenRate bHPLossRate bAddRace2
syn keyword	athConstant	bHPGainValue bSubSize bHPDrainValueRace bAddItemHealRate bSPDrainValueRace bExpAddRace
syn keyword	athConstant	bSPGainRace bSubRace2 bUnbreakableShoes bUnstripableWeapon bUnstripableArmor
syn keyword	athConstant	bUnstripableHelm bUnstripableShield bIntravision bAddMonsterDropItemGroup bSPLossRate
syn keyword	athConstant	bAddSkillBlow bSPVanishRate bMagicSPGainValue bMagicHPGainValue bAddClassDropItem bMatk
syn keyword	athConstant	bSPGainRaceAttack bHPGainRaceAttack bSkillCooldown bSkillFixedCast bSkillVariableCast
syn keyword	athConstant	bFixedCastrate bVariableCastrate bSkillUseSP bSkillUseSPrate bMagicAtkEle bFixedCast
syn keyword	athConstant	bVariableCast
syn keyword	athConstant	EQI_HEAD_TOP EQI_ARMOR EQI_HAND_L EQI_HAND_R EQI_GARMENT EQI_SHOES EQI_ACC_L EQI_ACC_R
syn keyword	athConstant	EQI_HEAD_MID EQI_HEAD_LOW EQI_COSTUME_HEAD_LOW EQI_COSTUME_HEAD_MID EQI_COSTUME_HEAD_TOP
syn keyword	athConstant	EQI_COSTUME_GARMENT
syn keyword	athConstant	LOOK_BASE LOOK_HAIR LOOK_WEAPON LOOK_HEAD_BOTTOM LOOK_HEAD_TOP LOOK_HEAD_MID
syn keyword	athConstant	LOOK_HAIR_COLOR LOOK_CLOTHES_COLOR LOOK_SHIELD LOOK_SHOES LOOK_BODY LOOK_FLOOR LOOK_ROBE
syn keyword	athConstant	Eff_Stone Eff_Freeze Eff_Stun Eff_Sleep Eff_Poison Eff_Curse Eff_Silence Eff_Confusion
syn keyword	athConstant	Eff_Blind Eff_Bleeding Eff_DPoison
syn keyword	athConstant	Ele_Neutral Ele_Water Ele_Earth Ele_Fire Ele_Wind Ele_Poison Ele_Holy Ele_Dark
syn keyword	athConstant	Ele_Ghost Ele_Undead
syn keyword	athConstant	RC_Formless RC_Undead RC_Brute RC_Plant RC_Insect RC_Fish RC_Demon RC_DemiHuman RC_Angel
syn keyword	athConstant	RC_Dragon RC_Boss RC_NonBoss RC_NonDemiHuman
syn keyword	athConstant	RC2_None RC2_Goblin RC2_Kobold RC2_Orc RC2_Golem RC2_Guardian RC2_Ninja
syn keyword	athConstant	Size_Small Size_Medium Size_Large
syn keyword	athConstant	BF_WEAPON BF_MAGIC BF_MISC BF_SHORT BF_LONG BF_SKILL BF_NORMAL
syn keyword	athConstant	ATF_SELF ATF_TARGET ATF_SHORT ATF_LONG ATF_WEAPON ATF_MAGIC ATF_MISC ATF_SKILL
syn keyword	athConstant	IG_BlueBox IG_VioletBox IG_CardAlbum IG_GiftBox IG_ScrollBox IG_FingingOre IG_CookieBag
syn keyword	athConstant	IG_FirstAid IG_Herb IG_Fruit IG_Meat IG_Candy IG_Juice IG_Fish IG_Box IG_Gemstone
syn keyword	athConstant	IG_Resist IG_Ore IG_Food IG_Recovery IG_Mineral IG_Taming IG_Scroll IG_Quiver IG_Mask
syn keyword	athConstant	IG_Accesory IG_Jewel IG_GiftBox_1 IG_GiftBox_2 IG_GiftBox_3 IG_GiftBox_4 IG_EggBoy
syn keyword	athConstant	IG_EggGirl IG_GiftBoxChina IG_LottoBox IG_FoodBag IG_Potion IG_RedBox_2 IG_BleuBox
syn keyword	athConstant	IG_RedBox IG_GreenBox IG_YellowBox IG_OldGiftBox IG_MagicCardAlbum IG_HometownGift
syn keyword	athConstant	IG_Masquerade IG_Tresure_Box_WoE IG_Masquerade_2 IG_Easter_Scroll IG_Pierre_Treasurebox
syn keyword	athConstant	IG_Cherish_Box IG_Cherish_Box_Ori IG_Louise_Costume_Box IG_Xmas_Gift IG_Fruit_Basket
syn keyword	athConstant	IG_Improved_Coin_Bag IG_Intermediate_Coin_Bag IG_Minor_Coin_Bag IG_S_Grade_Coin_Bag
syn keyword	athConstant	IG_A_Grade_Coin_Bag IG_Advanced_Weapons_Box IG_Splendid_Box
syn keyword	athConstant	SC_ALL SC_STONE SC_FREEZE SC_STUN SC_SLEEP SC_POISON SC_CURSE SC_SILENCE SC_CONFUSION
syn keyword	athConstant	SC_BLIND SC_BLEEDING SC_DPOISON SC_PROVOKE SC_ENDURE SC_TWOHANDQUICKEN SC_CONCENTRATE
syn keyword	athConstant	SC_HIDING SC_CLOAKING SC_ENCPOISON SC_POISONREACT SC_QUAGMIRE SC_ANGELUS SC_BLESSING
syn keyword	athConstant	SC_SIGNUMCRUCIS SC_INCREASEAGI SC_DECREASEAGI SC_SLOWPOISON SC_IMPOSITIO SC_SUFFRAGIUM
syn keyword	athConstant	SC_ASPERSIO SC_BENEDICTIO SC_KYRIE SC_MAGNIFICAT SC_GLORIA SC_AETERNA SC_ADRENALINE
syn keyword	athConstant	SC_WEAPONPERFECTION SC_OVERTHRUST SC_MAXIMIZEPOWER SC_TRICKDEAD SC_LOUD SC_ENERGYCOAT
syn keyword	athConstant	SC_BROKENARMOR SC_BROKENWEAPON SC_HALLUCINATION SC_WEIGHT50 SC_WEIGHT90 SC_ASPDPOTION0
syn keyword	athConstant	SC_ASPDPOTION1 SC_ASPDPOTION2 SC_ASPDPOTION3 SC_SPEEDUP0 SC_SPEEDUP1 SC_ATKPOTION
syn keyword	athConstant	SC_MATKPOTION SC_WEDDING SC_SLOWDOWN SC_ANKLE SC_KEEPING SC_BARRIER SC_STRIPWEAPON
syn keyword	athConstant	SC_STRIPSHIELD SC_STRIPARMOR SC_STRIPHELM SC_CP_WEAPON SC_CP_SHIELD SC_CP_ARMOR
syn keyword	athConstant	SC_CP_HELM SC_AUTOGUARD SC_REFLECTSHIELD SC_SPLASHER SC_PROVIDENCE SC_DEFENDER
syn keyword	athConstant	SC_MAGICROD SC_SPELLBREAKER SC_AUTOSPELL SC_SIGHTTRASHER SC_SPEARQUICKEN SC_AUTOBERSERK
syn keyword	athConstant	SC_AUTOCOUNTER SC_SIGHT SC_SAFETYWALL SC_RUWACH SC_EXTREMITYFIST SC_EXPLOSIONSPIRITS
syn keyword	athConstant	SC_COMBO SC_BLADESTOP_WAIT SC_BLADESTOP SC_FIREWEAPON SC_WATERWEAPON SC_WINDWEAPON
syn keyword	athConstant	SC_EARTHWEAPON SC_VOLCANO SC_DELUGE SC_VIOLENTGALE SC_WATK_ELEMENT SC_ARMOR
syn keyword	athConstant	SC_ARMOR_ELEMENT SC_NOCHAT SC_BABY SC_AURABLADE SC_PARRYING SC_CONCENTRATION
syn keyword	athConstant	SC_TENSIONRELAX SC_BERSERK SC_FURY SC_GOSPEL SC_ASSUMPTIO SC_BASILICA SC_GUILDAURA
syn keyword	athConstant	SC_MAGICPOWER SC_EDP SC_TRUESIGHT SC_WINDWALK SC_MELTDOWN SC_CARTBOOST SC_CHASEWALK
syn keyword	athConstant	SC_REJECTSWORD SC_MARIONETTE SC_MARIONETTE2 SC_CHANGEUNDEAD SC_JOINTBEAT SC_MINDBREAKER
syn keyword	athConstant	SC_MEMORIZE SC_FOGWALL SC_SPIDERWEB SC_DEVOTION SC_SACRIFICE SC_STEELBODY SC_ORCISH
syn keyword	athConstant	SC_READYSTORM SC_READYDOWN SC_READYTURN SC_READYCOUNTER SC_DODGE SC_RUN SC_SHADOWWEAPON
syn keyword	athConstant	SC_ADRENALINE2 SC_GHOSTWEAPON SC_KAIZEL SC_KAAHI SC_KAUPE SC_ONEHAND SC_PRESERVE
syn keyword	athConstant	SC_BATTLEORDERS SC_REGENERATION SC_DOUBLECAST SC_GRAVITATION SC_MAXOVERTHRUST
syn keyword	athConstant	SC_LONGING SC_HERMODE SC_SHRINK SC_SIGHTBLASTER SC_WINKCHARM SC_CLOSECONFINE
syn keyword	athConstant	SC_CLOSECONFINE2 SC_DANCING SC_ELEMENTALCHANGE SC_RICHMANKIM SC_ETERNALCHAOS
syn keyword	athConstant	SC_DRUMBATTLE SC_NIBELUNGEN SC_ROKISWEIL SC_INTOABYSS SC_SIEGFRIED SC_WHISTLE
syn keyword	athConstant	SC_ASSNCROS SC_POEMBRAGI SC_APPLEIDUN SC_MODECHANGE SC_HUMMING SC_DONTFORGETME
syn keyword	athConstant	SC_FORTUNE SC_SERVICE4U SC_STOP SC_SPURT SC_SPIRIT SC_COMA SC_INTRAVISION
syn keyword	athConstant	SC_INCALLSTATUS SC_INCSTR SC_INCAGI SC_INCVIT SC_INCINT SC_INCDEX SC_INCLUK SC_INCHIT
syn keyword	athConstant	SC_INCHITRATE SC_INCFLEE SC_INCFLEERATE SC_INCMHPRATE SC_INCMSPRATE SC_INCATKRATE
syn keyword	athConstant	SC_INCMATKRATE SC_INCDEFRATE SC_STRFOOD SC_AGIFOOD SC_VITFOOD SC_INTFOOD SC_DEXFOOD
syn keyword	athConstant	SC_LUKFOOD SC_HITFOOD SC_FLEEFOOD SC_BATKFOOD SC_WATKFOOD SC_MATKFOOD SC_SCRESIST
syn keyword	athConstant	SC_XMAS SC_WARM SC_SUN_COMFORT SC_MOON_COMFORT SC_STAR_COMFORT SC_FUSION SC_SKILLRATE_UP
syn keyword	athConstant	SC_SKE SC_KAITE SC_SWOO SC_SKA SC_TKREST SC_MIRACLE SC_MADNESSCANCEL SC_ADJUSTMENT
syn keyword	athConstant	SC_INCREASING SC_GATLINGFEVER SC_TATAMIGAESHI SC_UTSUSEMI SC_BUNSINJYUTSU SC_KAENSIN
syn keyword	athConstant	SC_SUITON SC_NEN SC_KNOWLEDGE SC_SMA SC_FLING SC_AVOID SC_CHANGE SC_BLOODLUST SC_FLEET
syn keyword	athConstant	SC_SPEED SC_DEFENCE SC_INCFLEE2 SC_JAILED SC_ENCHANTARMS SC_MAGICALATTACK SC_SUMMER
syn keyword	athConstant	SC_EXPBOOST SC_ITEMBOOST SC_BOSSMAPINFO SC_LIFEINSURANCE SC_INCCRI SC_MDEF_RATE
syn keyword	athConstant	SC_INCHEALRATE SC_PNEUMA SC_AUTOTRADE SC_KSPROTECTED SC_ARMOR_RESIST SC_SPCOST_RATE
syn keyword	athConstant	SC_COMMONSC_RESIST SC_SEVENWIND SC_DEF_RATE SC_WALKSPEED SC_REBIRTH SC_ITEMSCRIPT
syn keyword	athConstant	SC_S_LIFEPOTION SC_L_LIFEPOTION SC_JEXPBOOST SC_HELLPOWER SC_INVINCIBLE SC_INVINCIBLEOFF
syn keyword	athConstant	SC_MANU_ATK SC_MANU_DEF SC_SPL_ATK SC_SPL_DEF SC_MANU_MATK SC_SPL_MATK SC_FOOD_STR_CASH
syn keyword	athConstant	SC_FOOD_AGI_CASH SC_FOOD_VIT_CASH SC_FOOD_DEX_CASH SC_FOOD_INT_CASH SC_FOOD_LUK_CASH
syn keyword	athConstant	SC_FEAR SC_BURNING SC_FREEZING SC_ENCHANTBLADE SC_DEATHBOUND SC_MILLENNIUMSHIELD
syn keyword	athConstant	SC_CRUSHSTRIKE SC_REFRESH SC_REUSE_REFRESH SC_GIANTGROWTH SC_STONEHARDSKIN
syn keyword	athConstant	SC_VITALITYACTIVATION SC_STORMBLAST SC_FIGHTINGSPIRIT SC_ABUNDANCE SC_ADORAMUS
syn keyword	athConstant	SC_EPICLESIS SC_ORATIO SC_LAUDAAGNUS SC_LAUDARAMUS SC_RENOVATIO SC_EXPIATIO
syn keyword	athConstant	SC_DUPLELIGHT SC_SECRAMENT SC_WHITEIMPRISON SC_MARSHOFABYSS SC_RECOGNIZEDSPELL
syn keyword	athConstant	SC_STASIS SC_SPHERE_1 SC_SPHERE_2 SC_SPHERE_3 SC_SPHERE_4 SC_SPHERE_5 SC_READING_SB
syn keyword	athConstant	SC_FREEZINGSPELL SC_FEARBREEZE SC_ELECTRICSHOCKER SC_WUGDASH SC_BITE SC_CAMOUFLAGE
syn keyword	athConstant	SC_ACCELERATION SC_HOVERING SC_SHAPESHIFT SC_INFRAREDSCAN SC_ANALYZE SC_MAGNETICFIELD
syn keyword	athConstant	SC_NEUTRALBARRIER SC_NEUTRALBARRIER_MASTER SC_STEALTHFIELD SC_STEALTHFIELD_MASTER
syn keyword	athConstant	SC_OVERHEAT SC_OVERHEAT_LIMITPOINT SC_VENOMIMPRESS SC_POISONINGWEAPON SC_WEAPONBLOCKING
syn keyword	athConstant	SC_CLOAKINGEXCEED SC_HALLUCINATIONWALK SC_HALLUCINATIONWALK_POSTDELAY SC_ROLLINGCUTTER
syn keyword	athConstant	SC_TOXIN SC_PARALYSE SC_VENOMBLEED SC_MAGICMUSHROOM SC_DEATHHURT SC_PYREXIA
syn keyword	athConstant	SC_OBLIVIONCURSE SC_LEECHESEND SC_REFLECTDAMAGE SC_FORCEOFVANGUARD SC_SHIELDSPELL_DEF
syn keyword	athConstant	SC_SHIELDSPELL_MDEF SC_SHIELDSPELL_REF SC_EXEEDBREAK SC_PRESTIGE SC_BANDING
syn keyword	athConstant	SC_BANDING_DEFENCE SC_EARTHDRIVE SC_INSPIRATION SC_SPELLFIST SC_CRYSTALIZE SC_STRIKING
syn keyword	athConstant	SC_WARMER SC_VACUUM_EXTREME SC_PROPERTYWALK SC_SWINGDANCE SC_SYMPHONYOFLOVER
syn keyword	athConstant	SC_MOONLITSERENADE SC_RUSHWINDMILL SC_ECHOSONG SC_HARMONIZE SC_VOICEOFSIREN SC_DEEPSLEEP
syn keyword	athConstant	SC_SIRCLEOFNATURE SC_GLOOMYDAY SC_GLOOMYDAY_SK SC_SONGOFMANA SC_DANCEWITHWUG
syn keyword	athConstant	SC_SATURDAYNIGHTFEVER SC_LERADSDEW SC_MELODYOFSINK SC_BEYONDOFWARCRY
syn keyword	athConstant	SC_UNLIMITEDHUMMINGVOICE SC_SITDOWN_FORCE SC_CRESCENTELBOW SC_CURSEDCIRCLE_ATKER
syn keyword	athConstant	SC_CURSEDCIRCLE_TARGET SC_LIGHTNINGWALK SC_RAISINGDRAGON SC_GT_ENERGYGAIN SC_GT_CHANGE
syn keyword	athConstant	SC_GT_REVITALIZE SC_GN_CARTBOOST SC_THORNSTRAP SC_BLOODSUCKER SC_SMOKEPOWDER SC_TEARGAS
syn keyword	athConstant	SC_MANDRAGORA SC_STOMACHACHE SC_MYSTERIOUS_POWDER SC_MELON_BOMB SC_BANANA_BOMB
syn keyword	athConstant	SC_BANANA_BOMB_SITDOWN SC_SAVAGE_STEAK SC_COCKTAIL_WARG_BLOOD SC_MINOR_BBQ
syn keyword	athConstant	SC_SIROMA_ICE_TEA SC_DROCERA_HERB_STEAMED SC_PUTTI_TAILS_NOODLES SC_BOOST500
syn keyword	athConstant	SC_FULL_SWING_K SC_MANA_PLUS SC_MUSTLE_M SC_LIFE_FORCE_F SC_EXTRACT_WHITE_POTION_Z
syn keyword	athConstant	SC_VITATA_500 SC_EXTRACT_SALAMINE_JUICE SC__REPRODUCE SC__AUTOSHADOWSPELL SC__SHADOWFORM
syn keyword	athConstant	SC__BODYPAINT SC__INVISIBILITY SC__DEADLYINFECT SC__ENERVATION SC__GROOMY SC__IGNORANCE
syn keyword	athConstant	SC__LAZINESS SC__UNLUCKY SC__WEAKNESS SC__STRIPACCESSORY SC__MANHOLE SC__BLOODYLUST
syn keyword	athConstant	SC_CIRCLE_OF_FIRE SC_CIRCLE_OF_FIRE_OPTION SC_FIRE_CLOAK SC_FIRE_CLOAK_OPTION
syn keyword	athConstant	SC_WATER_SCREEN SC_WATER_SCREEN_OPTION SC_WATER_DROP SC_WATER_DROP_OPTION
syn keyword	athConstant	SC_WATER_BARRIER SC_WIND_STEP SC_WIND_STEP_OPTION SC_WIND_CURTAIN 
syn keyword	athConstant	SC_WIND_CURTAIN_OPTION SC_ZEPHYR SC_SOLID_SKIN SC_SOLID_SKIN_OPTION SC_STONE_SHIELD
syn keyword	athConstant	SC_STONE_SHIELD_OPTION SC_POWER_OF_GAIA SC_PYROTECHNIC SC_PYROTECHNIC_OPTION SC_HEATER
syn keyword	athConstant	SC_HEATER_OPTION SC_TROPIC SC_TROPIC_OPTION SC_AQUAPLAY SC_AQUAPLAY_OPTION SC_COOLER
syn keyword	athConstant	SC_COOLER_OPTION SC_CHILLY_AIR SC_CHILLY_AIR_OPTION SC_GUST SC_GUST_OPTION SC_BLAST
syn keyword	athConstant	SC_BLAST_OPTION SC_WILD_STORM SC_WILD_STORM_OPTION SC_PETROLOGY SC_PETROLOGY_OPTION
syn keyword	athConstant	SC_CURSED_SOIL SC_CURSED_SOIL_OPTION SC_UPHEAVAL SC_UPHEAVAL_OPTION SC_TIDAL_WEAPON
syn keyword	athConstant	SC_TIDAL_WEAPON_OPTION SC_ROCK_CRUSHER SC_ROCK_CRUSHER_ATK SC_INCASPDRATE SC_LEADERSHIP
syn keyword	athConstant	SC_GLORYWOUNDS SC_SOULCOLD SC_HAWKEYES SC_ODINS_POWER SC_RAID SC_FIRE_INSIGNIA
syn keyword	athConstant	SC_WATER_INSIGNIA SC_WIND_INSIGNIA SC_EARTH_INSIGNIA SC_PUSH_CART SC_SPELLBOOK1
syn keyword	athConstant	SC_SPELLBOOK2 SC_SPELLBOOK3 SC_SPELLBOOK4 SC_SPELLBOOK5 SC_SPELLBOOK6 SC_MAXSPELLBOOK
syn keyword	athConstant	SC_INCMHP SC_INCMSP SC_PARTYFLEE SC_MEIKYOUSISUI SC_JYUMONJIKIRI SC_KYOUGAKU SC_IZAYOI
syn keyword	athConstant	SC_ZENKAI SC_KAGEHUMI SC_KYOMU SC_KAGEMUSYA SC_ZANGETSU SC_GENSOU SC_AKAITSUKI
syn keyword	athConstant	SC_STYLE_CHANGE SC_GOLDENE_FERSE SC_ANGRIFFS_MODUS SC_ERASER_CUTTER SC_OVERED_BOOST
syn keyword	athConstant	SC_LIGHT_OF_REGENE SC_ASH SC_GRANITIC_ARMOR SC_MAGMA_FLOW SC_PYROCLASTIC SC_PARALYSIS
syn keyword	athConstant	SC_PAIN_KILLER SC_NETHERWORLD

syn keyword	athConstant	e_gasp e_what e_ho e_lv e_swt e_ic e_an e_ag e_cash e_dots e_scissors e_rock e_paper
syn keyword	athConstant	e_korea e_lv2 e_thx e_wah e_sry e_heh e_swt2 e_hmm e_no1 e_no e_omg e_oh e_X e_hlp e_go
syn keyword	athConstant	e_sob e_gg e_kis e_kis2 e_pif e_ok e_mute e_indonesia e_bzz e_rice e_awsm e_meh e_shy
syn keyword	athConstant	e_pat e_mp e_slur e_com e_yawn e_grat e_hp e_philippines e_malaysia e_singapore
syn keyword	athConstant	e_brazil e_flash e_proud e_sigh e_proud e_loud e_otl e_dice1 e_dice2 e_dice3 e_dice4
syn keyword	athConstant	e_dice5 e_dice6 e_india e_luv e_russia e_virgin e_mobile e_mail e_chinese e_antenna1
syn keyword	athConstant	e_antenna2 e_antenna3 e_hum e_abs e_oops e_spit e_ene e_panic e_whisp
syn keyword	athConstant	PET_CLASS PET_NAME PET_LEVEL PET_HUNGRY PET_INTIMATE
syn keyword	athConstant	MOB_NAME MOB_LV MOB_MAXHP MOB_BASEEXP MOB_JOBEXP MOB_ATK1 MOB_ATK2 MOB_DEF MOB_MDEF
syn keyword	athConstant	MOB_STR MOB_AGI MOB_VIT MOB_INT MOB_DEX MOB_LUK MOB_RANGE MOB_RANGE2 MOB_RANGE3 MOB_SIZE
syn keyword	athConstant	MOB_RACE MOB_ELEMENT MOB_MODE MOB_MVPEXP
syn keyword	athConstant	AI_ACTION_TYPE AI_ACTION_TAR_TYPE AI_ACTION_TAR AI_ACTION_SRC AI_ACTION_TAR_TYPE_PC
syn keyword	athConstant	AI_ACTION_TAR_TYPE_MOB AI_ACTION_TAR_TYPE_PET AI_ACTION_TAR_TYPE_HOMUN
syn keyword	athConstant	AI_ACTION_TAR_TYPE_ITEM AI_ACTION_TYPE_NPCCLICK AI_ACTION_TYPE_ATTACK
syn keyword	athConstant	AI_ACTION_TYPE_DETECT AI_ACTION_TYPE_DEAD AI_ACTION_TYPE_ASSIST AI_ACTION_TYPE_KILL
syn keyword	athConstant	AI_ACTION_TYPE_UNLOCK AI_ACTION_TYPE_WALKACK AI_ACTION_TYPE_WARPACK
syn keyword	athConstant	ALL_CLIENT ALL_SAMEMAP AREA AREA_WOS AREA_WOC AREA_WOSC AREA_CHAT_WOC CHAT CHAT_WOS
syn keyword	athConstant	PARTY PARTY_WOS PARTY_SAMEMAP PARTY_SAMEMAP_WOS PARTY_AREA PARTY_AREA_WOS GUILD
syn keyword	athConstant	GUILD_WOS GUILD_SAMEMAP GUILD_SAMEMAP_WOS GUILD_AREA GUILD_AREA_WOS GUILD_NOBG DUEL
syn keyword	athConstant	DUEL_WOS CHAT_MAINCHAT SELF BG BG_WOS BG_SAMEMAP BG_SAMEMAP_WOS BG_AREA BG_AREA_WOS
syn keyword	athConstant	ARCH_MERC_GUILD SPEAR_MERC_GUILD SWORD_MERC_GUILD
syn keyword	athConstant	EF_NONE EF_HIT1 EF_HIT2 EF_HIT3 EF_HIT4 EF_HIT5 EF_HIT6 EF_ENTRY EF_EXIT EF_WARP
syn keyword	athConstant	EF_ENHANCE EF_COIN EF_ENDURE EF_BEGINSPELL EF_GLASSWALL EF_HEALSP EF_SOULSTRIKE EF_BASH
syn keyword	athConstant	EF_MAGNUMBREAK EF_STEAL EF_HIDING EF_PATTACK EF_DETOXICATION EF_SIGHT EF_STONECURSE
syn keyword	athConstant	EF_FIREBALL EF_FIREWALL EF_ICEARROW EF_FROSTDIVER EF_FROSTDIVER2 EF_LIGHTBOLT
syn keyword	athConstant	EF_THUNDERSTORM EF_FIREARROW EF_NAPALMBEAT EF_RUWACH EF_TELEPORTATION EF_READYPORTAL
syn keyword	athConstant	EF_PORTAL EF_INCAGILITY EF_DECAGILITY EF_AQUA EF_SIGNUM EF_ANGELUS EF_BLESSING
syn keyword	athConstant	EF_INCAGIDEX EF_SMOKE EF_FIREFLY EF_SANDWIND EF_TORCH EF_SPRAYPOND EF_FIREHIT
syn keyword	athConstant	EF_FIRESPLASHHIT EF_COLDHIT EF_WINDHIT EF_POISONHIT EF_BEGINSPELL2 EF_BEGINSPELL3
syn keyword	athConstant	EF_BEGINSPELL4 EF_BEGINSPELL5 EF_BEGINSPELL6 EF_BEGINSPELL7 EF_LOCKON EF_WARPZONE
syn keyword	athConstant	EF_SIGHTRASHER EF_BARRIER EF_ARROWSHOT EF_INVENOM EF_CURE EF_PROVOKE EF_MVP EF_SKIDTRAP
syn keyword	athConstant	EF_BRANDISHSPEAR EF_CONE EF_SPHERE EF_BOWLINGBASH EF_ICEWALL EF_GLORIA EF_MAGNIFICAT
syn keyword	athConstant	EF_RESURRECTION EF_RECOVERY EF_EARTHSPIKE EF_SPEARBMR EF_PIERCE EF_TURNUNDEAD
syn keyword	athConstant	EF_SANCTUARY EF_IMPOSITIO EF_LEXAETERNA EF_ASPERSIO EF_LEXDIVINA EF_SUFFRAGIUM
syn keyword	athConstant	EF_STORMGUST EF_LORD EF_BENEDICTIO EF_METEORSTORM EF_YUFITEL EF_YUFITELHIT EF_QUAGMIRE
syn keyword	athConstant	EF_FIREPILLAR EF_FIREPILLARBOMB EF_HASTEUP EF_FLASHER EF_REMOVETRAP EF_REPAIRWEAPON
syn keyword	athConstant	EF_CRASHEARTH EF_PERFECTION EF_MAXPOWER EF_BLASTMINE EF_BLASTMINEBOMB EF_CLAYMORE
syn keyword	athConstant	EF_FREEZING EF_BUBBLE EF_GASPUSH EF_SPRINGTRAP EF_KYRIE EF_MAGNUS EF_BOTTOM
syn keyword	athConstant	EF_BLITZBEAT EF_WATERBALL EF_WATERBALL2 EF_FIREIVY EF_DETECTING EF_CLOAKING
syn keyword	athConstant	EF_SONICBLOW EF_SONICBLOWHIT EF_GRIMTOOTH EF_VENOMDUST EF_ENCHANTPOISON
syn keyword	athConstant	EF_POISONREACT EF_POISONREACT2 EF_OVERTHRUST EF_SPLASHER EF_TWOHANDQUICKEN
syn keyword	athConstant	EF_AUTOCOUNTER EF_GRIMTOOTHATK EF_FREEZE EF_FREEZED EF_ICECRASH EF_SLOWPOISON
syn keyword	athConstant	EF_BOTTOM2 EF_FIREPILLARON EF_SANDMAN EF_REVIVE EF_PNEUMA EF_HEAVENSDRIVE
syn keyword	athConstant	EF_SONICBLOW2 EF_BRANDISH2 EF_SHOCKWAVE EF_SHOCKWAVEHIT EF_EARTHHIT EF_PIERCESELF
syn keyword	athConstant	EF_BOWLINGSELF EF_SPEARSTABSELF EF_SPEARBMRSELF EF_HOLYHIT EF_CONCENTRATION EF_REFINEOK
syn keyword	athConstant	EF_REFINEFAIL EF_JOBCHANGE EF_LVUP EF_JOBLVUP EF_TOPRANK EF_PARTY EF_RAIN EF_SNOW
syn keyword	athConstant	EF_SAKURA EF_STATUS_STATE EF_BANJJAKII EF_MAKEBLUR EF_TAMINGSUCCESS EF_TAMINGFAILED
syn keyword	athConstant	EF_ENERGYCOAT EF_CARTREVOLUTION EF_VENOMDUST2 EF_CHANGEDARK EF_CHANGEFIRE EF_CHANGECOLD
syn keyword	athConstant	EF_CHANGEWIND EF_CHANGEFLAME EF_CHANGEEARTH EF_CHAINGEHOLY EF_CHANGEPOISON EF_HITDARK
syn keyword	athConstant	EF_MENTALBREAK EF_MAGICALATTHIT EF_SUI_EXPLOSION EF_DARKATTACK EF_SUICIDE
syn keyword	athConstant	EF_COMBOATTACK1 EF_COMBOATTACK2 EF_COMBOATTACK3 EF_COMBOATTACK4 EF_COMBOATTACK5
syn keyword	athConstant	EF_GUIDEDATTACK EF_POISONATTACK EF_SILENCEATTACK EF_STUNATTACK EF_PETRIFYATTACK
syn keyword	athConstant	EF_CURSEATTACK EF_SLEEPATTACK EF_TELEKHIT EF_PONG EF_LEVEL99 EF_LEVEL99_2 EF_LEVEL99_3
syn keyword	athConstant	EF_GUMGANG EF_POTION1 EF_POTION2 EF_POTION3 EF_POTION4 EF_POTION5 EF_POTION6 EF_POTION7
syn keyword	athConstant	EF_POTION8 EF_DARKBREATH EF_DEFFENDER EF_KEEPING EF_SUMMONSLAVE EF_BLOODDRAIN
syn keyword	athConstant	EF_ENERGYDRAIN EF_POTION_CON EF_POTION_ EF_POTION_BERSERK EF_POTIONPILLAR EF_DEFENDER
syn keyword	athConstant	EF_GANBANTEIN EF_WIND EF_VOLCANO EF_GRANDCROSS EF_INTIMIDATE EF_CHOOKGI EF_CLOUD
syn keyword	athConstant	EF_CLOUD2 EF_MAPPILLAR EF_LINELINK EF_CLOUD3 EF_SPELLBREAKER EF_DISPELL EF_DELUGE
syn keyword	athConstant	EF_VIOLENTGALE EF_LANDPROTECTOR EF_BOTTOM_VO EF_BOTTOM_DE EF_BOTTOM_VI EF_BOTTOM_LA
syn keyword	athConstant	EF_FASTMOVE EF_MAGICROD EF_HOLYCROSS EF_SHIELDCHARGE EF_MAPPILLAR2 EF_PROVIDENCE
syn keyword	athConstant	EF_SHIELDBOOMERANG EF_SPEARQUICKEN EF_DEVOTION EF_REFLECTSHIELD EF_ABSORBSPIRITS
syn keyword	athConstant	EF_STEELBODY EF_FLAMELAUNCHER EF_FROSTWEAPON EF_LIGHTNINGLOADER EF_SEISMICWEAPON
syn keyword	athConstant	EF_MAPPILLAR3 EF_MAPPILLAR4 EF_GUMGANG2 EF_TEIHIT1 EF_GUMGANG3 EF_TEIHIT2 EF_TANJI
syn keyword	athConstant	EF_TEIHIT1X EF_CHIMTO EF_STEALCOIN EF_STRIPWEAPON EF_STRIPSHIELD EF_STRIPARMOR
syn keyword	athConstant	EF_STRIPHELM EF_CHAINCOMBO EF_RG_COIN EF_BACKSTAP EF_TEIHIT3 EF_BOTTOM_DISSONANCE
syn keyword	athConstant	EF_BOTTOM_LULLABY EF_BOTTOM_RICHMANKIM EF_BOTTOM_ETERNALCHAOS
syn keyword	athConstant	EF_BOTTOM_DRUMBATTLEFIELD EF_BOTTOM_RINGNIBELUNGEN EF_BOTTOM_ROKISWEIL
syn keyword	athConstant	EF_BOTTOM_INTOABYSS EF_BOTTOM_SIEGFRIED EF_BOTTOM_WHISTLE EF_BOTTOM_ASSASSINCROSS
syn keyword	athConstant	EF_BOTTOM_POEMBRAGI EF_BOTTOM_APPLEIDUN EF_BOTTOM_UGLYDANCE EF_BOTTOM_HUMMING
syn keyword	athConstant	EF_BOTTOM_DONTFORGETME EF_BOTTOM_FORTUNEKISS EF_BOTTOM_SERVICEFORYOU EF_TALK_FROSTJOKE
syn keyword	athConstant	EF_TALK_SCREAM EF_POKJUK EF_THROWITEM EF_THROWITEM2 EF_CHEMICALPROTECTION
syn keyword	athConstant	EF_POKJUK_SOUND EF_DEMONSTRATION EF_CHEMICAL2 EF_TELEPORTATION2 EF_PHARMACY_OK
syn keyword	athConstant	EF_PHARMACY_FAIL EF_FORESTLIGHT EF_THROWITEM3 EF_FIRSTAID EF_SPRINKLESAND EF_LOUD
syn keyword	athConstant	EF_HEAL EF_HEAL2 EF_EXIT2 EF_GLASSWALL2 EF_READYPORTAL2 EF_PORTAL2 EF_BOTTOM_MAG
syn keyword	athConstant	EF_BOTTOM_SANC EF_HEAL3 EF_WARPZONE2 EF_FORESTLIGHT2 EF_FORESTLIGHT3 EF_FORESTLIGHT4
syn keyword	athConstant	EF_HEAL4 EF_FOOT EF_FOOT2 EF_BEGINASURA EF_TRIPLEATTACK EF_HITLINE EF_HPTIME EF_SPTIME
syn keyword	athConstant	EF_MAPLE EF_BLIND EF_POISON EF_GUARD EF_JOBLVUP50 EF_ANGEL2 EF_MAGNUM2 EF_CALLZONE
syn keyword	athConstant	EF_PORTAL3 EF_COUPLECASTING EF_HEARTCASTING EF_ENTRY2 EF_SAINTWING EF_SPHEREWIND
syn keyword	athConstant	EF_COLORPAPER EF_LIGHTSPHERE EF_WATERFALL EF_WATERFALL_90 EF_WATERFALL_SMALL
syn keyword	athConstant	EF_WATERFALL_SMALL_90 EF_WATERFALL_T2 EF_WATERFALL_T2_90 EF_WATERFALL_SMALL_T2
syn keyword	athConstant	EF_WATERFALL_SMALL_T2_90 EF_MINI_TETRIS EF_GHOST EF_BAT EF_BAT2 EF_SOULBREAKER
syn keyword	athConstant	EF_LEVEL99_4 EF_VALLENTINE EF_VALLENTINE2 EF_PRESSURE EF_BASH3D EF_AURABLADE EF_REDBODY
syn keyword	athConstant	EF_LKCONCENTRATION EF_BOTTOM_GOSPEL EF_ANGEL EF_DEVIL EF_DRAGONSMOKE EF_BOTTOM_BASILICA
syn keyword	athConstant	EF_ASSUMPTIO EF_HITLINE2 EF_BASH3D2 EF_ENERGYDRAIN2 EF_TRANSBLUEBODY EF_MAGICCRASHER
syn keyword	athConstant	EF_LIGHTSPHERE2 EF_LIGHTBLADE EF_ENERGYDRAIN3 EF_LINELINK2 EF_LINKLIGHT EF_TRUESIGHT
syn keyword	athConstant	EF_FALCONASSAULT EF_TRIPLEATTACK2 EF_PORTAL4 EF_MELTDOWN EF_CARTBOOST EF_REJECTSWORD
syn keyword	athConstant	EF_TRIPLEATTACK3 EF_SPHEREWIND2 EF_LINELINK3 EF_PINKBODY EF_LEVEL99_5 EF_LEVEL99_6
syn keyword	athConstant	EF_BASH3D3 EF_BASH3D4 EF_NAPALMVALCAN EF_PORTAL5 EF_MAGICCRASHER2 EF_BOTTOM_SPIDER
syn keyword	athConstant	EF_BOTTOM_FOGWALL EF_SOULBURN EF_SOULCHANGE EF_BABY EF_SOULBREAKER2 EF_RAINBOW EF_PEONG
syn keyword	athConstant	EF_TANJI2 EF_PRESSEDBODY EF_SPINEDBODY EF_KICKEDBODY EF_AIRTEXTURE EF_HITBODY
syn keyword	athConstant	EF_DOUBLEGUMGANG EF_REFLECTBODY EF_BABYBODY EF_BABYBODY2 EF_GIANTBODY EF_GIANTBODY2
syn keyword	athConstant	EF_ASURABODY EF_4WAYBODY EF_QUAKEBODY EF_ASURABODY_MONSTER EF_HITLINE3 EF_HITLINE4
syn keyword	athConstant	EF_HITLINE5 EF_HITLINE6 EF_ELECTRIC EF_ELECTRIC2 EF_HITLINE7 EF_STORMKICK EF_HALFSPHERE
syn keyword	athConstant	EF_ATTACKENERGY EF_ATTACKENERGY2 EF_CHEMICAL3 EF_ASSUMPTIO2 EF_BLUECASTING EF_RUN
syn keyword	athConstant	EF_STOPRUN EF_STOPEFFECT EF_JUMPBODY EF_LANDBODY EF_FOOT3 EF_FOOT4 EF_TAE_READY
syn keyword	athConstant	EF_GRANDCROSS2 EF_SOULSTRIKE2 EF_YUFITEL2 EF_NPC_STOP EF_DARKCASTING EF_GUMGANGNPC
syn keyword	athConstant	EF_AGIUP EF_JUMPKICK EF_QUAKEBODY2 EF_STORMKICK1 EF_STORMKICK2 EF_STORMKICK3
syn keyword	athConstant	EF_STORMKICK4 EF_STORMKICK5 EF_STORMKICK6 EF_STORMKICK7 EF_SPINEDBODY2 EF_BEGINASURA1
syn keyword	athConstant	EF_BEGINASURA2 EF_BEGINASURA3 EF_BEGINASURA4 EF_BEGINASURA5 EF_BEGINASURA6
syn keyword	athConstant	EF_BEGINASURA7 EF_AURABLADE2 EF_DEVIL1 EF_DEVIL2 EF_DEVIL3 EF_DEVIL4 EF_DEVIL5
syn keyword	athConstant	EF_DEVIL6 EF_DEVIL7 EF_DEVIL8 EF_DEVIL9 EF_DEVIL10 EF_DOUBLEGUMGANG2 EF_DOUBLEGUMGANG3
syn keyword	athConstant	EF_BLACKDEVIL EF_FLOWERCAST EF_FLOWERCAST2 EF_FLOWERCAST3 EF_MOCHI EF_LAMADAN EF_EDP
syn keyword	athConstant	EF_SHIELDBOOMERANG2 EF_RG_COIN2 EF_GUARD2 EF_SLIM EF_SLIM2 EF_SLIM3 EF_CHEMICALBODY
syn keyword	athConstant	EF_CASTSPIN EF_PIERCEBODY EF_SOULLINK EF_CHOOKGI2 EF_MEMORIZE EF_SOULLIGHT EF_MAPAE
syn keyword	athConstant	EF_ITEMPOKJUK EF_05VAL EF_BEGINASURA11 EF_NIGHT EF_CHEMICAL2DASH EF_GROUNDSAMPLE
syn keyword	athConstant	EF_GI_EXPLOSION EF_CLOUD4 EF_CLOUD5 EF_BOTTOM_HERMODE EF_CARTTER EF_ITEMFAST
syn keyword	athConstant	EF_SHIELDBOOMERANG3 EF_DOUBLECASTBODY EF_GRAVITATION EF_TAROTCARD1 EF_TAROTCARD2
syn keyword	athConstant	EF_TAROTCARD3 EF_TAROTCARD4 EF_TAROTCARD5 EF_TAROTCARD6 EF_TAROTCARD7 EF_TAROTCARD8
syn keyword	athConstant	EF_TAROTCARD9 EF_TAROTCARD10 EF_TAROTCARD11 EF_TAROTCARD12 EF_TAROTCARD13
syn keyword	athConstant	EF_TAROTCARD14 EF_ACIDDEMON EF_GREENBODY EF_THROWITEM4 EF_BABYBODY_BACK EF_THROWITEM5
syn keyword	athConstant	EF_BLUEBODY EF_HATED EF_REDLIGHTBODY EF_RO2YEAR EF_SMA_READY EF_STIN EF_RED_HIT
syn keyword	athConstant	EF_BLUE_HIT EF_QUAKEBODY3 EF_SMA EF_SMA2 EF_STIN2 EF_HITTEXTURE EF_STIN3 EF_SMA3
syn keyword	athConstant	EF_BLUEFALL EF_BLUEFALL_90 EF_FASTBLUEFALL EF_FASTBLUEFALL_90 EF_BIG_PORTAL
syn keyword	athConstant	EF_BIG_PORTAL2 EF_SCREEN_QUAKE EF_HOMUNCASTING EF_HFLIMOON1 EF_HFLIMOON2 EF_HFLIMOON3
syn keyword	athConstant	EF_HO_UP EF_HAMIDEFENCE EF_HAMICASTLE EF_HAMIBLOOD EF_HATED2 EF_TWILIGHT1 EF_TWILIGHT2
syn keyword	athConstant	EF_TWILIGHT3 EF_ITEM_THUNDER EF_ITEM_CLOUD EF_ITEM_CURSE EF_ITEM_ZZZ EF_ITEM_RAIN
syn keyword	athConstant	EF_ITEM_LIGHT EF_ANGEL3 EF_M01 EF_M02 EF_M03 EF_M04 EF_M05 EF_M06 EF_M07 EF_KAIZEL
syn keyword	athConstant	EF_KAAHI EF_CLOUD6 EF_FOOD01 EF_FOOD02 EF_FOOD03 EF_FOOD04 EF_FOOD05 EF_FOOD06
syn keyword	athConstant	EF_SHRINK EF_THROWITEM6 EF_SIGHT2 EF_QUAKEBODY4 EF_FIREHIT2 EF_NPC_STOP2
syn keyword	athConstant	EF_NPC_STOP2_DEL EF_FVOICE EF_WINK EF_COOKING_OK EF_COOKING_FAIL EF_TEMP_OK
syn keyword	athConstant	EF_TEMP_FAIL EF_HAPGYEOK EF_THROWITEM7 EF_THROWITEM8 EF_THROWITEM9 EF_THROWITEM10
syn keyword	athConstant	EF_BUNSINJYUTSU EF_KOUENKA EF_HYOUSENSOU EF_BOTTOM_SUITON EF_STIN4 EF_THUNDERSTORM2
syn keyword	athConstant	EF_CHEMICAL4 EF_STIN5 EF_MADNESS_BLUE EF_MADNESS_RED EF_RG_COIN3 EF_BASH3D5 EF_CHOOKGI3
syn keyword	athConstant	EF_KIRIKAGE EF_TATAMI EF_KASUMIKIRI EF_ISSEN EF_KAEN EF_BAKU EF_HYOUSYOURAKU
syn keyword	athConstant	EF_DESPERADO EF_LIGHTNING_S EF_BLIND_S EF_POISON_S EF_FREEZING_S EF_FLARE_S
syn keyword	athConstant	EF_RAPIDSHOWER EF_MAGICALBULLET EF_SPREADATTACK EF_TRACKCASTING EF_TRACKING
syn keyword	athConstant	EF_TRIPLEACTION EF_BULLSEYE EF_MAP_MAGICZONE EF_MAP_MAGICZONE2 EF_DAMAGE1 EF_DAMAGE1_2
syn keyword	athConstant	EF_DAMAGE1_3 EF_UNDEADBODY EF_UNDEADBODY_DEL EF_GREEN_NUMBER EF_BLUE_NUMBER
syn keyword	athConstant	EF_RED_NUMBER EF_PURPLE_NUMBER EF_BLACK_NUMBER EF_WHITE_NUMBER EF_YELLOW_NUMBER
syn keyword	athConstant	EF_PINK_NUMBER EF_BUBBLE_DROP EF_NPC_EARTHQUAKE EF_DA_SPACE EF_DRAGONFEAR EF_BLEEDING
syn keyword	athConstant	EF_WIDECONFUSE EF_BOTTOM_RUNNER EF_BOTTOM_TRANSFER EF_CRYSTAL_BLUE EF_BOTTOM_EVILLAND
syn keyword	athConstant	EF_GUARD3 EF_NPC_SLOWCAST EF_CRITICALWOUND EF_GREEN99_3 EF_GREEN99_5 EF_GREEN99_6
syn keyword	athConstant	EF_MAPSPHERE EF_POK_LOVE EF_POK_WHITE EF_POK_VALEN EF_POK_BIRTH EF_POK_CHRISTMAS
syn keyword	athConstant	EF_MAP_MAGICZONE3 EF_MAP_MAGICZONE4 EF_DUST EF_TORCH_RED EF_TORCH_GREEN EF_MAP_GHOST
syn keyword	athConstant	EF_GLOW1 EF_GLOW2 EF_GLOW4 EF_TORCH_PURPLE EF_CLOUD7 EF_CLOUD8 EF_FLOWERLEAF
syn keyword	athConstant	EF_MAPSPHERE2 EF_GLOW11 EF_GLOW12 EF_CIRCLELIGHT EF_ITEM315 EF_ITEM316 EF_ITEM317
syn keyword	athConstant	EF_ITEM318 EF_STORM_MIN EF_POK_JAP EF_MAP_GREENLIGHT EF_MAP_MAGICWALL
syn keyword	athConstant	EF_MAP_GREENLIGHT2 EF_YELLOWFLY1 EF_YELLOWFLY2 EF_BOTTOM_BLUE EF_BOTTOM_BLUE2
syn keyword	athConstant	EF_WEWISH EF_FIREPILLARON2 EF_FORESTLIGHT5 EF_SOULBREAKER3 EF_ADO_STR EF_IGN_STR
syn keyword	athConstant	EF_CHIMTO2 EF_WINDCUTTER EF_DETECT2 EF_FROSTMYSTY EF_CRIMSON_STR EF_HELL_STR
syn keyword	athConstant	EF_SPR_MASH EF_SPR_SOULE EF_DHOWL_STR EF_EARTHWALL EF_SOULBREAKER4 EF_CHAINL_STR
syn keyword	athConstant	EF_CHOOKGI_FIRE EF_CHOOKGI_WIND EF_CHOOKGI_WATER EF_CHOOKGI_GROUND EF_MAGENTA_TRAP
syn keyword	athConstant	EF_COBALT_TRAP EF_MAIZE_TRAP EF_VERDURE_TRAP EF_NORMAL_TRAP EF_CLOAKING2 EF_AIMED_STR
syn keyword	athConstant	EF_ARROWSTORM_STR EF_LAULAMUS_STR EF_LAUAGNUS_STR EF_MILSHIELD_STR EF_CONCENTRATION2
syn keyword	athConstant	EF_FIREBALL2 EF_BUNSINJYUTSU2 EF_CLEARTIME EF_GLASSWALL3 EF_ORATIO EF_POTION_BERSERK2
syn keyword	athConstant	EF_CIRCLEPOWER EF_ROLLING1 EF_ROLLING2 EF_ROLLING3 EF_ROLLING4 EF_ROLLING5 EF_ROLLING6
syn keyword	athConstant	EF_ROLLING7 EF_ROLLING8 EF_ROLLING9 EF_ROLLING10 EF_PURPLEBODY EF_STIN6 EF_RG_COIN4
syn keyword	athConstant	EF_POISONWAV EF_POISONSMOKE EF_GUMGANG4 EF_SHIELDBOOMERANG4 EF_CASTSPIN2 EF_VULCANWAV
syn keyword	athConstant	EF_AGIUP2 EF_DETECT3 EF_AGIUP3 EF_DETECT4 EF_ELECTRIC3 EF_GUARD4 EF_BOTTOM_BARRIER
syn keyword	athConstant	EF_BOTTOM_STEALTH EF_REPAIRTIME EF_NC_ANAL EF_FIRETHROW EF_VENOMIMPRESS EF_FROSTMISTY
syn keyword	athConstant	EF_BURNING EF_COLDTHROW EF_MAKEHALLU EF_HALLUTIME EF_INFRAREDSCAN EF_CRASHAXE
syn keyword	athConstant	EF_GTHUNDER EF_STONERING EF_INTIMIDATE2 EF_STASIS EF_REDLINE EF_FROSTDIVER3
syn keyword	athConstant	EF_BOTTOM_BASILICA2 EF_RECOGNIZED EF_TETRA EF_TETRACASTING EF_FIREBALL3 EF_INTIMIDATE3
syn keyword	athConstant	EF_RECOGNIZED2 EF_CLOAKING3 EF_INTIMIDATE4 EF_STRETCH EF_BLACKBODY EF_ENERVATION
syn keyword	athConstant	EF_ENERVATION2 EF_ENERVATION3 EF_ENERVATION4 EF_ENERVATION5 EF_ENERVATION6 EF_LINELINK4
syn keyword	athConstant	EF_RG_COIN5 EF_WATERFALL_ANI EF_BOTTOM_MANHOLE EF_MANHOLE EF_MAKEFEINT EF_FORESTLIGHT6
syn keyword	athConstant	EF_DARKCASTING2 EF_BOTTOM_ANI EF_BOTTOM_MAELSTROM EF_BOTTOM_BLOODYLUST EF_BEGINSPELL_N1
syn keyword	athConstant	EF_BEGINSPELL_N2 EF_HEAL_N EF_CHOOKGI_N EF_JOBLVUP50_2 EF_CHEMICAL2DASH2
syn keyword	athConstant	EF_CHEMICAL2DASH3 EF_ROLLINGCAST EF_WATER_BELOW EF_WATER_FADE EF_BEGINSPELL_N3
syn keyword	athConstant	EF_BEGINSPELL_N4 EF_BEGINSPELL_N5 EF_BEGINSPELL_N6 EF_BEGINSPELL_N7 EF_BEGINSPELL_N8
syn keyword	athConstant	EF_WATER_SMOKE EF_DANCE1 EF_DANCE2 EF_LINKPARTICLE EF_SOULLIGHT2 EF_SPR_PARTICLE
syn keyword	athConstant	EF_SPR_PARTICLE2 EF_SPR_PLANT EF_CHEMICAL_V EF_SHOOTPARTICLE EF_BOT_REVERB
syn keyword	athConstant	EF_RAIN_PARTICLE EF_CHEMICAL_V2 EF_SECRA EF_BOT_REVERB2 EF_CIRCLEPOWER2 EF_SECRA2
syn keyword	athConstant	EF_CHEMICAL_V3 EF_ENERVATION7 EF_CIRCLEPOWER3 EF_SPR_PLANT2 EF_CIRCLEPOWER4
syn keyword	athConstant	EF_SPR_PLANT3 EF_RG_COIN6 EF_SPR_PLANT4 EF_CIRCLEPOWER5 EF_SPR_PLANT5 EF_CIRCLEPOWER6
syn keyword	athConstant	EF_SPR_PLANT6 EF_CIRCLEPOWER7 EF_SPR_PLANT7 EF_CIRCLEPOWER8 EF_SPR_PLANT8 EF_HEARTASURA
syn keyword	athConstant	EF_BEGINSPELL_150 EF_LEVEL99_150 EF_PRIMECHARGE EF_GLASSWALL4 EF_GRADIUS_LASER
syn keyword	athConstant	EF_BASH3D6 EF_GUMGANG5 EF_HITLINE8 EF_ELECTRIC4 EF_TEIHIT1T EF_SPINMOVE EF_FIREBALL4
syn keyword	athConstant	EF_TRIPLEATTACK4 EF_CHEMICAL3S EF_GROUNDSHAKE EF_DQ9_CHARGE EF_DQ9_CHARGE2
syn keyword	athConstant	EF_DQ9_CHARGE3 EF_DQ9_CHARGE4 EF_BLUELINE EF_SELFSCROLL EF_SPR_LIGHTPRINT EF_PNG_TEST
syn keyword	athConstant	EF_BEGINSPELL_YB EF_CHEMICAL2DASH4 EF_GROUNDSHAKE2 EF_PRESSURE2 EF_RG_COIN7
syn keyword	athConstant	EF_PRIMECHARGE2 EF_PRIMECHARGE3 EF_PRIMECHARGE4 EF_GREENCASTING EF_WALLOFTHORN
syn keyword	athConstant	EF_FIREBALL5 EF_THROWITEM11 EF_SPR_PLANT9 EF_DEMONICFIRE EF_DEMONICFIRE2
syn keyword	athConstant	EF_DEMONICFIRE3 EF_HELLSPLANT EF_FIREWALL2 EF_VACUUM EF_SPR_PLANT10 EF_SPR_LIGHTPRINT2
syn keyword	athConstant	EF_POISONSMOKE2 EF_MAKEHALLU2 EF_SHOCKWAVE2 EF_SPR_PLANT11 EF_COLDTHROW2
syn keyword	athConstant	EF_DEMONICFIRE4 EF_PRESSURE3 EF_LINKPARTICLE2 EF_SOULLIGHT3 EF_CHAREFFECT EF_GUMGANG6
syn keyword	athConstant	EF_FIREBALL6 EF_GUMGANG7 EF_GUMGANG8 EF_GUMGANG9 EF_BOTTOM_DE2 EF_COLDSTATUS
syn keyword	athConstant	EF_SPR_LIGHTPRINT3 EF_WATERBALL3 EF_HEAL_N2 EF_RAIN_PARTICLE2 EF_CLOUD9 EF_YELLOWFLY3
syn keyword	athConstant	EF_EL_GUST EF_EL_BLAST EF_EL_AQUAPLAY EF_EL_UPHEAVAL EF_EL_WILD_STORM EF_EL_CHILLY_AIR
syn keyword	athConstant	EF_EL_CURSED_SOIL EF_EL_COOLER EF_EL_TROPIC EF_EL_PYROTECHNIC EF_EL_PETROLOGY
syn keyword	athConstant	EF_EL_HEATER EF_POISON_MIST EF_ERASER_CUTTER EF_SILENT_BREEZE EF_MAGMA_FLOW EF_GRAYBODY
syn keyword	athConstant	EF_LAVA_SLIDE EF_SONIC_CLAW EF_TINDER_BREAKER EF_MIDNIGHT_FRENZY EF_MACRO
syn keyword	athConstant	EF_CHEMICAL_ALLRANGE EF_TETRA_FIRE EF_TETRA_WATER EF_TETRA_WIND EF_TETRA_GROUND
syn keyword	athConstant	EF_EMITTER EF_VOLCANIC_ASH EF_LEVEL99_ORB1 EF_LEVEL99_ORB2 EF_LEVEL150 EF_LEVEL150_SUB
syn keyword	athConstant	EF_THROWITEM4_1 EF_THROW_HAPPOKUNAI EF_THROW_MULTIPLE_COIN EF_THROW_BAKURETSU
syn keyword	athConstant	EF_ROTATE_HUUMARANKA EF_ROTATE_BG EF_ROTATE_LINE_GRAY EF_2011RWC EF_2011RWC2 EF_KAIHOU
syn keyword	athConstant	EF_GROUND_EXPLOSION EF_KG_KAGEHUMI EF_KO_ZENKAI_WATER EF_KO_ZENKAI_LAND
syn keyword	athConstant	EF_KO_ZENKAI_FIRE EF_KO_ZENKAI_WIND EF_KO_JYUMONJIKIRI EF_KO_SETSUDAN EF_RED_CROSS
syn keyword	athConstant	EF_KO_IZAYOI EF_ROTATE_LINE_BLUE EF_KG_KYOMU EF_KO_HUUMARANKA EF_BLUELIGHTBODY
syn keyword	athConstant	EF_KAGEMUSYA EF_OB_GENSOU EF_NO100_FIRECRACKER EF_KO_MAKIBISHI EF_KAIHOU1 EF_AKAITSUKI
syn keyword	athConstant	EF_ZANGETSU EF_GENSOU EF_HAT_EFFECT EF_CHERRYBLOSSOM EF_EVENT_CLOUD EF_RUN_MAKE_OK
syn keyword	athConstant	EF_RUN_MAKE_FAILURE EF_MIRESULT_MAKE_OK EF_MIRESULT_MAKE_FAIL EF_ALL_RAY_OF_PROTECTION
syn keyword	athConstant	EF_VENOMFOG EF_DUSTSTORM
syn keyword	athConstant	HAVEQUEST PLAYTIME HUNTING
syn keyword	athConstant	FW_DONTCARE FW_THIN FW_EXTRALIGHT FW_LIGHT FW_NORMAL FW_MEDIUM FW_SEMIBOLD FW_BOLD FW_EXTRABOLD FW_HEAVY
syn keyword	athConstant	VAR_HEAD VAR_WEAPON VAR_HEAD_TOP VAR_HEAD_MID VAR_HEAD_BOTTOM VAR_HEADPALETTE VAR_BODYPALETTE VAR_SHIELD VAR_SHOES
syn keyword	athConstant	DIR_NORTH DIR_NORTHWEST DIR_WEST DIR_SOUTHWEST DIR_SOUTH DIR_SOUTHEAST DIR_EAST DIR_NORTHEAST
syn keyword	athConstant	IT_HEALING IT_USABLE IT_ETC IT_WEAPON IT_ARMOR IT_CARD IT_PETEGG IT_PETARMOR IT_AMMO IT_DELAYCONSUME IT_CASH
syn keyword	athConstant	alb_ship alb2trea alberta alberta_in alde_dun01 alde_dun02 alde_dun03 alde_dun04 aldeba_in
syn keyword	athConstant	aldebaran anthell01 anthell02 arena_room c_tower1 c_tower2 c_tower3 c_tower4 force_1 force_2
syn keyword	athConstant	force_3 gef_dun00 gef_dun01 gef_dun02 gef_dun03 gef_fild00 gef_fild01 gef_fild02 gef_fild03
syn keyword	athConstant	gef_fild04 gef_fild05 gef_fild06 gef_fild07 gef_fild08 gef_fild09 gef_fild10 gef_fild11
syn keyword	athConstant	gef_fild12 gef_fild13 gef_fild14 gef_tower geffen geffen_in gl_cas01 gl_cas02 gl_church
syn keyword	athConstant	gl_chyard gl_dun01 gl_dun02 gl_in01 gl_knt01 gl_knt02 gl_prison gl_prison1 gl_sew01
syn keyword	athConstant	gl_sew02 gl_sew03 gl_sew04 gl_step glast_01 hunter_1 hunter_2 hunter_3 in_hunter
syn keyword	athConstant	in_moc_16 in_orcs01 in_sphinx1 in_sphinx2 in_sphinx3 in_sphinx4 in_sphinx5 iz_dun00
syn keyword	athConstant	iz_dun01 iz_dun02 iz_dun03 iz_dun04 job_sword1 izlu2dun izlude izlude_in job_thief1
syn keyword	athConstant	knight_1 knight_2 knight_3 mjo_dun01 mjo_dun02 mjo_dun03 mjolnir_01 mjolnir_02
syn keyword	athConstant	mjolnir_03 mjolnir_04 mjolnir_05 mjolnir_06 mjolnir_07 mjolnir_08 mjolnir_09 mjolnir_10
syn keyword	athConstant	mjolnir_11 mjolnir_12 moc_castle moc_fild01 moc_fild02 moc_fild03 moc_fild04 moc_fild05
syn keyword	athConstant	moc_fild06 moc_fild07 moc_fild08 moc_fild09 moc_fild10 moc_fild11 moc_fild12 moc_fild13
syn keyword	athConstant	moc_fild14 moc_fild15 moc_fild16 moc_fild17 moc_fild18 moc_fild19 moc_pryd01 moc_pryd02
syn keyword	athConstant	moc_pryd03 moc_pryd04 moc_pryd05 moc_pryd06 moc_prydb1 moc_ruins monk_in morocc
syn keyword	athConstant	morocc_in new_1 new_2 new_3 new_4 new_5 orcsdun01 orcsdun02 ordeal_1 ordeal_2 ordeal_3
syn keyword	athConstant	pay_arche pay_dun00 pay_dun01 pay_dun02 pay_dun03 pay_dun04 pay_fild01 pay_fild02
syn keyword	athConstant	pay_fild03 pay_fild04 pay_fild05 pay_fild06 pay_fild07 pay_fild08 pay_fild09 pay_fild10
syn keyword	athConstant	pay_fild11 payon payon_in01 payon_in02 priest_1 priest_2 priest_3 prontera prt_are_in
syn keyword	athConstant	prt_are01 pvp_room prt_castle prt_church prt_fild00 prt_fild01 prt_fild02 prt_fild03
syn keyword	athConstant	prt_fild04 prt_fild05 prt_fild06 prt_fild07 prt_fild08 prt_fild09 prt_fild10 prt_fild11
syn keyword	athConstant	prt_in prt_maze01 prt_maze02 prt_maze03 prt_monk prt_sewb1 prt_sewb2 prt_sewb3
syn keyword	athConstant	prt_sewb4 pvp_2vs2 pvp_c_room pvp_n_1 pvp_n_2 pvp_n_3 pvp_n_4 pvp_n_5 pvp_n_6 pvp_n_7
syn keyword	athConstant	pvp_n_8 pvp_n_room pvp_y_1 pvp_y_2 pvp_y_3 pvp_y_4 pvp_y_5 pvp_y_6 pvp_y_7 pvp_y_8
syn keyword	athConstant	pvp_y_room sword_1 sword_2 sword_3 treasure01 treasure02 wizard_1 wizard_2 wizard_3 xmas
syn keyword	athConstant	xmas_dun01 xmas_dun02 xmas_fild01 xmas_in beach_dun beach_dun2 beach_dun3 cmd_fild01
syn keyword	athConstant	cmd_fild02 cmd_fild03 cmd_fild04 cmd_fild05 cmd_fild06 cmd_fild07 cmd_fild08 cmd_fild09
syn keyword	athConstant	cmd_in01 cmd_in02 comodo quiz_00 quiz_01 g_room1 g_room2 tur_dun01 tur_dun02 tur_dun03
syn keyword	athConstant	tur_dun04 tur_dun05 tur_dun06 alde_gld aldeg_cas01 aldeg_cas02 aldeg_cas03 aldeg_cas04
syn keyword	athConstant	aldeg_cas05 gefg_cas01 gefg_cas02 gefg_cas03 gefg_cas04 gefg_cas05 gld_dun01 gld_dun02
syn keyword	athConstant	gld_dun03 gld_dun04 guild_room guild_vs1 guild_vs2 guild_vs3 guild_vs4 guild_vs5
syn keyword	athConstant	guild_vs1 guild_vs2 job_hunte job_knt job_prist job_wiz pay_gld payg_cas01 payg_cas02
syn keyword	athConstant	payg_cas03 payg_cas04 payg_cas05 prt_gld prtg_cas01 prtg_cas02 prtg_cas03 prtg_cas04
syn keyword	athConstant	prtg_cas05 alde_alche in_rogue job_cru job_duncer job_monk job_sage mag_dun01 mag_dun02
syn keyword	athConstant	monk_test quiz_test yuno yuno_fild01 yuno_fild02 yuno_fild03 yuno_fild04 yuno_in01
syn keyword	athConstant	yuno_in02 yuno_in03 yuno_in04 yuno_in05 ama_dun01 ama_dun02 ama_dun03 ama_fild01
syn keyword	athConstant	ama_in01 ama_in02 ama_test amatsu gon_dun01 gon_dun02 gon_dun03 gon_fild01 gon_in
syn keyword	athConstant	gon_test gonryun sec_in01 sec_in02 sec_pri umbala um_dun01 um_dun02 um_fild01 um_fild02
syn keyword	athConstant	um_fild03 um_fild04 um_in niflheim nif_fild01 nif_fild02 nif_in yggdrasil01 valkyrie
syn keyword	athConstant	himinn lou_in01 lou_in02 lou_dun03 lou_dun02 lou_dun01 lou_fild01 louyang siege_test
syn keyword	athConstant	n_castle nguild_gef nguild_prt nguild_pay nguild_alde jawaii jawaii_in gefenia01
syn keyword	athConstant	gefenia02 gefenia03 gefenia04 new_zone01 new_zone02 new_zone03 new_zone04 payon_in03
syn keyword	athConstant	ayothaya ayo_in01 ayo_in02 ayo_fild01 ayo_fild02 ayo_dun01 ayo_dun02 que_god01 que_god02
syn keyword	athConstant	yuno_fild05 yuno_fild07 yuno_fild08 yuno_fild09 yuno_fild11 yuno_fild12 alde_tt02
syn keyword	athConstant	turbo_n_1 turbo_n_4 turbo_n_8 turbo_n_16 turbo_e_4 turbo_e_8 turbo_e_16 turbo_room
syn keyword	athConstant	airplane airport einbech einbroch ein_dun01 ein_dun02 ein_fild06 ein_fild07 ein_fild08
syn keyword	athConstant	ein_fild09 ein_fild10 ein_in01 que_sign01 que_sign02 ein_fild03 ein_fild04 lhz_fild02
syn keyword	athConstant	lhz_fild03 yuno_pre lhz_fild01 lighthalzen lhz_in01 lhz_in02 lhz_in03 lhz_que01
syn keyword	athConstant	lhz_dun01 lhz_dun02 lhz_dun03 lhz_cube juperos_01 juperos_02 jupe_area1 jupe_area2
syn keyword	athConstant	jupe_core jupe_ele jupe_ele_r jupe_gate y_airport lhz_airport airplane_01 jupe_cave
syn keyword	athConstant	quiz_02 hu_fild07 hu_fild05 hu_fild04 hu_fild01 yuno_fild06 job_soul job_star que_job01
syn keyword	athConstant	que_job02 que_job03 abyss_01 abyss_02 abyss_03 thana_step thana_boss tha_scene01 tha_t01
syn keyword	athConstant	tha_t02 tha_t03 tha_t04 tha_t07 tha_t05 tha_t06 tha_t08 tha_t09 tha_t10 tha_t11 tha_t12
syn keyword	athConstant	auction_01 auction_02 hugel hu_in01 que_bingo que_hugel p_track01 p_track02 odin_tem01
syn keyword	athConstant	odin_tem02 odin_tem03 hu_fild02 hu_fild03 hu_fild06 ein_fild01 ein_fild02 ein_fild05
syn keyword	athConstant	yuno_fild10 kh_kiehl02 kh_kiehl01 kh_dun02 kh_dun01 kh_mansion kh_rossi kh_school
syn keyword	athConstant	kh_vila force_map1 force_map2 force_map3 job_hunter job_knight job_priest job_wizard
syn keyword	athConstant	ve_in02 rachel ra_in01 ra_fild01 ra_fild02 ra_fild03 ra_fild04 ra_fild05 ra_fild06
syn keyword	athConstant	ra_fild07 ra_fild08 ra_fild09 ra_fild10 ra_fild11 ra_fild12 ra_fild13 ra_san01 ra_san02
syn keyword	athConstant	ra_san03 ra_san04 ra_san05 ra_temin ra_temple ra_temsky que_rachel ice_dun01 ice_dun02
syn keyword	athConstant	ice_dun03 ice_dun04 que_thor thor_camp thor_v01 thor_v02 thor_v03 veins ve_in ve_fild01
syn keyword	athConstant	ve_fild02 ve_fild03 ve_fild04 ve_fild05 ve_fild06 ve_fild07 poring_c01 poring_c02 que_ng
syn keyword	athConstant	nameless_i nameless_n nameless_in abbey01 abbey02 abbey03 poring_w01 poring_w02
syn keyword	athConstant	que_san04 moscovia mosk_in mosk_ship mosk_fild01 mosk_fild02 mosk_dun01 mosk_dun02
syn keyword	athConstant	mosk_dun03 mosk_que force_4 force_5 z_agit que_temsky itemmall bossnia_01 bossnia_02
syn keyword	athConstant	bossnia_03 bossnia_04 schg_cas01 schg_cas02 schg_cas03 schg_cas04 schg_cas05 sch_gld
syn keyword	athConstant	cave moc_fild20 moc_fild21 moc_fild22 que_ba que_moc_16 que_moon arug_cas01 arug_cas02
syn keyword	athConstant	arug_cas03 arug_cas04 arug_cas05 aru_gld bat_room bat_a01 bat_a02 bat_b01 bat_b02
syn keyword	athConstant	que_qsch01 que_qsch02 que_qsch03 que_qsch04 que_qsch05 que_qaru01 que_qaru02 que_qaru03
syn keyword	athConstant	que_qaru04 que_qaru05 @cata e_tower @tower mid_camp mid_campin man_fild01 man_fild03
syn keyword	athConstant	spl_fild02 spl_fild03 moc_fild22b que_dan01 que_dan02 schg_que01 schg_dun01 arug_que01
syn keyword	athConstant	arug_dun01 @orcs @nyd nyd_dun01 nyd_dun02 manuk man_fild02 man_in01 splendide
syn keyword	athConstant	spl_fild01 spl_in01 spl_in02 bat_c01 bat_c02 bat_c03 moc_para01 job3_arch01 job3_arch02
syn keyword	athConstant	job3_arch03 job3_guil01 job3_guil02 job3_guil03 job3_rang01 job3_rang02 job3_rune01
syn keyword	athConstant	job3_rune02 job3_rune03 job3_war01 job3_war02 jupe_core2 brasilis bra_in01 bra_fild01
syn keyword	athConstant	bra_dun01 bra_dun02 dicastes01 dicastes02 dic_in01 dic_fild01 dic_fild02 dic_dun01
syn keyword	athConstant	dic_dun02 job3_gen01 s_atelier job3_sha01 evt_mobroom dic_dun03 evt_swar_b evt_swar_r
syn keyword	athConstant	evt_swar_s evt_swar_t @lhz lhz_dun04 que_lhz gld_dun01_2 gld_dun02_2 gld_dun03_2
syn keyword	athConstant	gld_dun04_2 gld2_ald gld2_gef gld2_pay gld2_prt malaya ma_fild01 ma_fild02 ma_scene01
syn keyword	athConstant	ma_in01 ma_dun01 @ma_h @ma_c @ma_b ma_zif01 ma_zif02 ma_zif03 ma_zif04 ma_zif05
syn keyword	athConstant	ma_zif06 ma_zif07 ma_zif08 ma_zif09 job_ko eclage ecl_fild01 ecl_in01 ecl_in02
syn keyword	athConstant	ecl_in03 ecl_in04 @ecl ecl_tdun01 ecl_tdun02 ecl_tdun03 ecl_tdun04 ecl_hub01 que_avan01
syn keyword	athConstant	moc_prydn1 moc_prydn2 new_event iz_ac01 iz_ac02 treasure_n1 treasure_n2 iz_int iz_ng01
syn keyword	athConstant	iz_int01 iz_int02 iz_int03 iz_int04 iz_ac01_a iz_ac02_a iz_ac01_b iz_ac02_b iz_ac01_c
syn keyword	athConstant	iz_ac02_c iz_ac01_d iz_ac02_d te_prtcas01 te_prtcas02 te_prtcas03 te_prtcas04
syn keyword	athConstant	te_prtcas05 te_aldecas1 te_aldecas2 te_aldecas3 te_aldecas4 te_aldecas5 prt_fild08a
syn keyword	athConstant	prt_fild08b prt_fild08c prt_fild08d izlude_a izlude_b izlude_c izlude_d te_prt_gld
syn keyword	athConstant	te_alde_gld teg_dun01 teg_dun02 @gl_k gl_chyard_ gl_cas02_ evt_bomb @def01 @def02
syn keyword	athConstant	@def03 @gef @face @sara @gef_in dali dungeon000 dungeon001 gef_vilg00 gef_vilg01
syn keyword	athConstant	moc_dugn01 moc_dugn02 moc_intr00 moc_intr01 moc_intr02 moc_intr04 moc_vilg00 moc_vilg01
syn keyword	athConstant	moc_vilg02 mrc_fild01 mrc_fild02 mrc_fild03 mrc_fild04 pro_fild00 pro_fild01 pro_fild04
syn keyword	athConstant	pro_fild05 prt_cstl00 prt_cstl01 prt_dugn00 prt_dugn01 prt_dugn02 prt_dugn03 prt_intr01
syn keyword	athConstant	prt_intr02 prt_vilg00 prt_vilg01 prt_vilg02 payold payold_2 payold01 payold02 moc_old
syn keyword	athConstant	moc_old_2 prt_are_1 prt_are_2 prt_are_3 prt_are_4
syn keyword	athConstant	OnInterIfInit OnInterIfInitOnce OnWhisperGlobal OnGuildBreak OnAgitInit OnAgitStart
syn keyword	athConstant	OnAgitEnd OnMinute OnClock OnHour OnDay OnInit OnTimer OnTimerQuit OnTouchNPC OnBuyItem
syn keyword	athConstant	OnSellItem OnDayMode OnNightMode OnPCDieEvent OnPCKillEvent OnNPCKillEvent
syn keyword	athConstant	OnPCLoginEvent OnPCLogoutEvent OnPCLoadMapEvent OnPCBaseLvUpEvent OnPCJobLvUpEvent
syn keyword	athConstant	OnTouch_ OnTouch
syn keyword	athConstant	NV_BASIC SM_SWORD SM_TWOHAND SM_RECOVERY SM_BASH SM_PROVOKE SM_MAGNUM SM_ENDURE
syn keyword	athConstant	MG_SRECOVERY MG_SIGHT MG_NAPALMBEAT MG_SAFETYWALL MG_SOULSTRIKE MG_COLDBOLT
syn keyword	athConstant	MG_FROSTDIVER MG_STONECURSE MG_FIREBALL MG_FIREWALL MG_FIREBOLT MG_LIGHTNINGBOLT
syn keyword	athConstant	MG_THUNDERSTORM AL_DP AL_DEMONBANE AL_RUWACH AL_PNEUMA AL_TELEPORT AL_WARP AL_HEAL
syn keyword	athConstant	AL_INCAGI AL_DECAGI AL_HOLYWATER AL_CRUCIS AL_ANGELUS AL_BLESSING AL_CURE MC_INCCARRY
syn keyword	athConstant	MC_DISCOUNT MC_OVERCHARGE MC_PUSHCART MC_IDENTIFY MC_VENDING MC_MAMMONITE AC_OWL
syn keyword	athConstant	AC_VULTURE AC_CONCENTRATION AC_DOUBLE AC_SHOWER TF_DOUBLE TF_MISS TF_STEAL TF_HIDING
syn keyword	athConstant	TF_POISON TF_DETOXIFY ALL_RESURRECTION KN_SPEARMASTERY KN_PIERCE KN_BRANDISHSPEAR
syn keyword	athConstant	KN_SPEARSTAB KN_SPEARBOOMERANG KN_TWOHANDQUICKEN KN_AUTOCOUNTER KN_BOWLINGBASH KN_RIDING
syn keyword	athConstant	KN_CAVALIERMASTERY PR_MACEMASTERY PR_IMPOSITIO PR_SUFFRAGIUM PR_ASPERSIO PR_BENEDICTIO
syn keyword	athConstant	PR_SANCTUARY PR_SLOWPOISON PR_STRECOVERY PR_KYRIE PR_MAGNIFICAT PR_GLORIA PR_LEXDIVINA
syn keyword	athConstant	PR_TURNUNDEAD PR_LEXAETERNA PR_MAGNUS WZ_FIREPILLAR WZ_SIGHTRASHER WZ_METEOR WZ_JUPITEL
syn keyword	athConstant	WZ_VERMILION WZ_WATERBALL WZ_ICEWALL WZ_FROSTNOVA WZ_STORMGUST WZ_EARTHSPIKE
syn keyword	athConstant	WZ_HEAVENDRIVE WZ_QUAGMIRE WZ_ESTIMATION BS_IRON BS_STEEL BS_ENCHANTEDSTONE BS_ORIDEOCON
syn keyword	athConstant	BS_DAGGER BS_SWORD BS_TWOHANDSWORD BS_AXE BS_MACE BS_KNUCKLE BS_SPEAR BS_HILTBINDING
syn keyword	athConstant	BS_FINDINGORE BS_WEAPONRESEARCH BS_REPAIRWEAPON BS_SKINTEMPER BS_HAMMERFALL
syn keyword	athConstant	BS_ADRENALINE BS_WEAPONPERFECT BS_OVERTHRUST BS_MAXIMIZE HT_SKIDTRAP HT_LANDMINE
syn keyword	athConstant	HT_ANKLESNARE HT_SHOCKWAVE HT_SANDMAN HT_FLASHER HT_FREEZINGTRAP HT_BLASTMINE
syn keyword	athConstant	HT_CLAYMORETRAP HT_REMOVETRAP HT_TALKIEBOX HT_BEASTBANE HT_FALCON HT_STEELCROW
syn keyword	athConstant	HT_BLITZBEAT HT_DETECTING HT_SPRINGTRAP AS_RIGHT AS_LEFT AS_KATAR AS_CLOAKING
syn keyword	athConstant	AS_SONICBLOW AS_GRIMTOOTH AS_ENCHANTPOISON AS_POISONREACT AS_VENOMDUST AS_SPLASHER
syn keyword	athConstant	NV_FIRSTAID NV_TRICKDEAD SM_MOVINGRECOVERY SM_FATALBLOW SM_AUTOBERSERK AC_MAKINGARROW
syn keyword	athConstant	AC_CHARGEARROW TF_SPRINKLESAND TF_BACKSLIDING TF_PICKSTONE TF_THROWSTONE
syn keyword	athConstant	MC_CARTREVOLUTION MC_CHANGECART MC_LOUD AL_HOLYLIGHT MG_ENERGYCOAT NPC_PIERCINGATT
syn keyword	athConstant	NPC_MENTALBREAKER NPC_RANGEATTACK NPC_ATTRICHANGE NPC_CHANGEWATER NPC_CHANGEGROUND
syn keyword	athConstant	NPC_CHANGEFIRE NPC_CHANGEWIND NPC_CHANGEPOISON NPC_CHANGEHOLY NPC_CHANGEDARKNESS
syn keyword	athConstant	NPC_CHANGETELEKINESIS NPC_CRITICALSLASH NPC_COMBOATTACK NPC_GUIDEDATTACK
syn keyword	athConstant	NPC_SELFDESTRUCTION NPC_SPLASHATTACK NPC_SUICIDE NPC_POISON NPC_BLINDATTACK
syn keyword	athConstant	NPC_SILENCEATTACK NPC_STUNATTACK NPC_PETRIFYATTACK NPC_CURSEATTACK NPC_SLEEPATTACK
syn keyword	athConstant	NPC_RANDOMATTACK NPC_WATERATTACK NPC_GROUNDATTACK NPC_FIREATTACK NPC_WINDATTACK
syn keyword	athConstant	NPC_POISONATTACK NPC_HOLYATTACK NPC_DARKNESSATTACK NPC_TELEKINESISATTACK
syn keyword	athConstant	NPC_MAGICALATTACK NPC_METAMORPHOSIS NPC_PROVOCATION NPC_SMOKING NPC_SUMMONSLAVE
syn keyword	athConstant	NPC_EMOTION NPC_TRANSFORMATION NPC_BLOODDRAIN NPC_ENERGYDRAIN NPC_KEEPING
syn keyword	athConstant	NPC_DARKBREATH NPC_DARKBLESSING NPC_BARRIER NPC_DEFENDER NPC_LICK NPC_HALLUCINATION
syn keyword	athConstant	NPC_REBIRTH NPC_SUMMONMONSTER RG_SNATCHER RG_STEALCOIN RG_BACKSTAP RG_TUNNELDRIVE
syn keyword	athConstant	RG_RAID RG_STRIPWEAPON RG_STRIPSHIELD RG_STRIPARMOR RG_STRIPHELM RG_INTIMIDATE
syn keyword	athConstant	RG_GRAFFITI RG_FLAGGRAFFITI RG_CLEANER RG_GANGSTER RG_COMPULSION RG_PLAGIARISM
syn keyword	athConstant	AM_AXEMASTERY AM_LEARNINGPOTION AM_PHARMACY AM_DEMONSTRATION AM_ACIDTERROR
syn keyword	athConstant	AM_POTIONPITCHER AM_CANNIBALIZE AM_SPHEREMINE AM_CP_WEAPON AM_CP_SHIELD AM_CP_ARMOR
syn keyword	athConstant	AM_CP_HELM AM_BIOETHICS AM_CALLHOMUN AM_REST AM_RESURRECTHOMUN CR_TRUST CR_AUTOGUARD
syn keyword	athConstant	CR_SHIELDCHARGE CR_SHIELDBOOMERANG CR_REFLECTSHIELD CR_HOLYCROSS CR_GRANDCROSS
syn keyword	athConstant	CR_DEVOTION CR_PROVIDENCE CR_DEFENDER CR_SPEARQUICKEN MO_IRONHAND MO_SPIRITSRECOVERY
syn keyword	athConstant	MO_CALLSPIRITS MO_ABSORBSPIRITS MO_TRIPLEATTACK MO_BODYRELOCATION MO_DODGE
syn keyword	athConstant	MO_INVESTIGATE MO_FINGEROFFENSIVE MO_STEELBODY MO_BLADESTOP MO_EXPLOSIONSPIRITS
syn keyword	athConstant	MO_EXTREMITYFIST MO_CHAINCOMBO MO_COMBOFINISH SA_ADVANCEDBOOK SA_CASTCANCEL
syn keyword	athConstant	SA_MAGICROD SA_SPELLBREAKER SA_FREECAST SA_AUTOSPELL SA_FLAMELAUNCHER SA_FROSTWEAPON
syn keyword	athConstant	SA_LIGHTNINGLOADER SA_SEISMICWEAPON SA_DRAGONOLOGY SA_VOLCANO SA_DELUGE SA_VIOLENTGALE
syn keyword	athConstant	SA_LANDPROTECTOR SA_DISPELL SA_ABRACADABRA SA_MONOCELL SA_CLASSCHANGE SA_SUMMONMONSTER
syn keyword	athConstant	SA_REVERSEORCISH SA_DEATH SA_FORTUNE SA_TAMINGMONSTER SA_QUESTION SA_GRAVITY SA_LEVELUP
syn keyword	athConstant	SA_INSTANTDEATH SA_FULLRECOVERY SA_COMA BD_ADAPTATION BD_ENCORE BD_LULLABY BD_RICHMANKIM
syn keyword	athConstant	BD_ETERNALCHAOS BD_DRUMBATTLEFIELD BD_RINGNIBELUNGEN BD_ROKISWEIL BD_INTOABYSS
syn keyword	athConstant	BD_SIEGFRIED BA_MUSICALLESSON BA_MUSICALSTRIKE BA_DISSONANCE BA_FROSTJOKER BA_WHISTLE
syn keyword	athConstant	BA_ASSASSINCROSS BA_POEMBRAGI BA_APPLEIDUN DC_DANCINGLESSON DC_THROWARROW DC_UGLYDANCE
syn keyword	athConstant	DC_SCREAM DC_HUMMING DC_DONTFORGETME DC_FORTUNEKISS DC_SERVICEFORYOU NPC_RANDOMMOVE
syn keyword	athConstant	NPC_SPEEDUP NPC_REVENGE WE_MALE WE_FEMALE WE_CALLPARTNER ITM_TOMAHAWK NPC_DARKCROSS
syn keyword	athConstant	NPC_GRANDDARKNESS NPC_DARKSTRIKE NPC_DARKTHUNDER NPC_STOP NPC_WEAPONBRAKER
syn keyword	athConstant	NPC_ARMORBRAKE NPC_HELMBRAKE NPC_SHIELDBRAKE NPC_UNDEADATTACK NPC_CHANGEUNDEAD
syn keyword	athConstant	NPC_POWERUP NPC_AGIUP NPC_SIEGEMODE NPC_CALLSLAVE NPC_INVISIBLE NPC_RUN LK_AURABLADE
syn keyword	athConstant	LK_PARRYING LK_CONCENTRATION LK_TENSIONRELAX LK_BERSERK HP_ASSUMPTIO HP_BASILICA
syn keyword	athConstant	HP_MEDITATIO HW_SOULDRAIN HW_MAGICCRASHER HW_MAGICPOWER PA_PRESSURE PA_SACRIFICE
syn keyword	athConstant	PA_GOSPEL CH_PALMSTRIKE CH_TIGERFIST CH_CHAINCRUSH PF_HPCONVERSION PF_SOULCHANGE
syn keyword	athConstant	PF_SOULBURN ASC_KATAR ASC_EDP ASC_BREAKER SN_SIGHT SN_FALCONASSAULT SN_SHARPSHOOTING
syn keyword	athConstant	SN_WINDWALK WS_MELTDOWN WS_CARTBOOST ST_CHASEWALK ST_REJECTSWORD CR_ALCHEMY
syn keyword	athConstant	CR_SYNTHESISPOTION CG_ARROWVULCAN CG_MOONLIT CG_MARIONETTE LK_SPIRALPIERCE LK_HEADCRUSH
syn keyword	athConstant	LK_JOINTBEAT HW_NAPALMVULCAN CH_SOULCOLLECT PF_MINDBREAKER PF_MEMORIZE PF_FOGWALL
syn keyword	athConstant	PF_SPIDERWEB ASC_METEORASSAULT ASC_CDP WE_BABY WE_CALLPARENT WE_CALLBABY TK_RUN
syn keyword	athConstant	TK_READYSTORM TK_STORMKICK TK_READYDOWN TK_DOWNKICK TK_READYTURN TK_TURNKICK
syn keyword	athConstant	TK_READYCOUNTER TK_COUNTER TK_DODGE TK_JUMPKICK TK_HPTIME TK_SPTIME TK_POWER
syn keyword	athConstant	TK_SEVENWIND TK_HIGHJUMP SG_FEEL SG_SUN_WARM SG_MOON_WARM SG_STAR_WARM SG_SUN_COMFORT
syn keyword	athConstant	SG_MOON_COMFORT SG_STAR_COMFORT SG_HATE SG_SUN_ANGER SG_MOON_ANGER SG_STAR_ANGER
syn keyword	athConstant	SG_SUN_BLESS SG_MOON_BLESS SG_STAR_BLESS SG_DEVIL SG_FRIEND SG_KNOWLEDGE SG_FUSION
syn keyword	athConstant	SL_ALCHEMIST AM_BERSERKPITCHER SL_MONK SL_STAR SL_SAGE SL_CRUSADER SL_SUPERNOVICE
syn keyword	athConstant	SL_KNIGHT SL_WIZARD SL_PRIEST SL_BARDDANCER SL_ROGUE SL_ASSASIN SL_BLACKSMITH
syn keyword	athConstant	BS_ADRENALINE2 SL_HUNTER SL_SOULLINKER SL_KAIZEL SL_KAAHI SL_KAUPE SL_KAITE SL_KAINA
syn keyword	athConstant	SL_STIN SL_STUN SL_SMA SL_SWOO SL_SKE SL_SKA SM_SELFPROVOKE NPC_EMOTION_ON ST_PRESERVE
syn keyword	athConstant	ST_FULLSTRIP WS_WEAPONREFINE CR_SLIMPITCHER CR_FULLPROTECTION PA_SHIELDCHAIN
syn keyword	athConstant	HP_MANARECHARGE PF_DOUBLECASTING HW_GANBANTEIN HW_GRAVITATION WS_CARTTERMINATION
syn keyword	athConstant	WS_OVERTHRUSTMAX CG_LONGINGFREEDOM CG_HERMODE CG_TAROTCARD CR_ACIDDEMONSTRATION
syn keyword	athConstant	CR_CULTIVATION ITEM_ENCHANTARMS TK_MISSION SL_HIGH KN_ONEHAND AM_TWILIGHT1 AM_TWILIGHT2
syn keyword	athConstant	AM_TWILIGHT3 HT_POWER GS_GLITTERING GS_FLING GS_TRIPLEACTION GS_BULLSEYE
syn keyword	athConstant	GS_MADNESSCANCEL GS_ADJUSTMENT GS_INCREASING GS_MAGICALBULLET GS_CRACKER GS_SINGLEACTION
syn keyword	athConstant	GS_SNAKEEYE GS_CHAINACTION GS_TRACKING GS_DISARM GS_PIERCINGSHOT GS_RAPIDSHOWER
syn keyword	athConstant	GS_DESPERADO GS_GATLINGFEVER GS_DUST GS_FULLBUSTER GS_SPREADATTACK GS_GROUNDDRIFT
syn keyword	athConstant	NJ_TOBIDOUGU NJ_SYURIKEN NJ_KUNAI NJ_HUUMA NJ_ZENYNAGE NJ_TATAMIGAESHI NJ_KASUMIKIRI
syn keyword	athConstant	NJ_SHADOWJUMP NJ_KIRIKAGE NJ_UTSUSEMI NJ_BUNSINJYUTSU NJ_NINPOU NJ_KOUENKA NJ_KAENSIN
syn keyword	athConstant	NJ_BAKUENRYU NJ_HYOUSENSOU NJ_SUITON NJ_HYOUSYOURAKU NJ_HUUJIN NJ_RAIGEKISAI
syn keyword	athConstant	NJ_KAMAITACHI NJ_NEN NJ_ISSEN NPC_EARTHQUAKE NPC_FIREBREATH NPC_ICEBREATH
syn keyword	athConstant	NPC_THUNDERBREATH NPC_ACIDBREATH NPC_DARKNESSBREATH NPC_DRAGONFEAR NPC_BLEEDING
syn keyword	athConstant	NPC_PULSESTRIKE NPC_HELLJUDGEMENT NPC_WIDESILENCE NPC_WIDEFREEZE NPC_WIDEBLEEDING
syn keyword	athConstant	NPC_WIDESTONE NPC_WIDECONFUSE NPC_WIDESLEEP NPC_WIDESIGHT NPC_EVILLAND NPC_MAGICMIRROR
syn keyword	athConstant	NPC_SLOWCAST NPC_CRITICALWOUND NPC_EXPULSION NPC_STONESKIN NPC_ANTIMAGIC NPC_WIDECURSE
syn keyword	athConstant	NPC_WIDESTUN NPC_VAMPIRE_GIFT NPC_WIDESOULDRAIN ALL_INCCARRY NPC_TALK NPC_HELLPOWER
syn keyword	athConstant	NPC_WIDEHELLDIGNITY NPC_INVINCIBLE NPC_INVINCIBLEOFF NPC_ALLHEAL CASH_BLESSING
syn keyword	athConstant	CASH_INCAGI CASH_ASSUMPTIO ALL_WEWISH KN_CHARGEATK CR_SHRINK AS_SONICACCEL
syn keyword	athConstant	AS_VENOMKNIFE RG_CLOSECONFINE WZ_SIGHTBLASTER SA_CREATECON SA_ELEMENTWATER
syn keyword	athConstant	HT_PHANTASMIC BA_PANGVOICE DC_WINKCHARM BS_UNFAIRLYTRICK BS_GREED PR_REDEMPTIO
syn keyword	athConstant	MO_KITRANSLATION MO_BALKYOUNG SA_ELEMENTGROUND SA_ELEMENTFIRE SA_ELEMENTWIND
syn keyword	athConstant	HLIF_HEAL HLIF_AVOID HLIF_BRAIN HLIF_CHANGE HAMI_CASTLE HAMI_DEFENCE HAMI_SKIN
syn keyword	athConstant	HAMI_BLOODLUST HFLI_MOON HFLI_FLEET HFLI_SPEED HFLI_SBR44 HVAN_CAPRICE HVAN_CHAOTIC
syn keyword	athConstant	HVAN_INSTRUCT HVAN_EXPLOSION MS_BASH MS_MAGNUM MS_BOWLINGBASH MS_PARRYING
syn keyword	athConstant	MS_REFLECTSHIELD MS_BERSERK MA_DOUBLE MA_SHOWER MA_SKIDTRAP MA_LANDMINE MA_SANDMAN
syn keyword	athConstant	MA_FREEZINGTRAP MA_REMOVETRAP MA_CHARGEARROW MA_SHARPSHOOTING ML_PIERCE ML_BRANDISH
syn keyword	athConstant	ML_SPIRALPIERCE ML_DEFENDER ML_AUTOGUARD ML_DEVOTION MER_MAGNIFICAT MER_QUICKEN
syn keyword	athConstant	MER_SIGHT MER_CRASH MER_REGAIN MER_TENDER MER_BENEDICTION MER_RECUPERATE MER_MENTALCURE
syn keyword	athConstant	MER_COMPRESS MER_PROVOKE MER_AUTOBERSERK MER_DECAGI MER_SCAPEGOAT MER_LEXDIVINA
syn keyword	athConstant	MER_ESTIMATION MER_KYRIE MER_BLESSING MER_INCAGI GD_APPROVAL GD_KAFRACONTRACT
syn keyword	athConstant	GD_GUARDRESEARCH GD_GUARDUP GD_EXTENSION GD_GLORYGUILD GD_LEADERSHIP GD_GLORYWOUNDS
syn keyword	athConstant	GD_SOULCOLD GD_HAWKEYES GD_BATTLEORDER GD_REGENERATION GD_RESTORE GD_EMERGENCYCALL
syn keyword	athConstant	GD_DEVELOPMENT
syn keyword	athConstant	true false null

syn keyword	athCommand	getchildid getmotherid getfatherid ispartneron getpartnerid getpartyname getpartymember
syn keyword	athCommand	getpartyleader getlook getsavepoint getequipid getequipname getitemname getbrokenid
syn keyword	athCommand	getequipisequiped getequipisenableref getequiprefinerycnt getequipweaponlv
syn keyword	athCommand	getequippercentrefinery getareadropitem getequipcardcnt getinventorylist cardscnt
syn keyword	athCommand	getrefine getnameditem getitemslots getiteminfo getequipcardid getmapxy getgmlevel
syn keyword	athCommand	gettimetick gettime gettimestr getusers getmapusers getareausers getusersname
syn keyword	athCommand	getguildname getguildmaster getguildmasterid getcastlename getcastledata setcastledata
syn keyword	athCommand	getgdskilllv requestguildinfo getmapguildusers getskilllv getskilllist getpetinfo
syn keyword	athCommand	gethominfo petstat getmonsterinfo skillpointcount getscrate playerattached isloggedin
syn keyword	athCommand	checkweight basicskillcheck checkoption checkoption1 checkoption2 setoption setcart
syn keyword	athCommand	checkcart setfalcon checkfalcon setriding checkriding checkvending checkchatting
syn keyword	athCommand	agitcheck isnight isday isequipped isequippedcnt checkequipedcard getequipisidentify
syn keyword	athCommand	attachrid detachrid rid2name message dispbottom areawarp warpparty warpchar warpguild
syn keyword	athCommand	warppartner savepoint save heal itemheal percentheal recovery jobchange jobname eaclass
syn keyword	athCommand	roclass changebase classchange changesex getexp setlook changelook getitem getitem2
syn keyword	athCommand	makeitem rentitem delitem delitem2 countitem countitem2 groupranditem enable_items
syn keyword	athCommand	disable_items itemskill produce successremovecards failedremovecards repair
syn keyword	athCommand	successrefitem failedrefitem unequip clearitem equip autoequip openstorage
syn keyword	athCommand	guildopenstorage guildchangegm guildgetexp guildskill resetlvl resetstatus resetskill
syn keyword	athCommand	sc_start sc_start2 sc_start4 sc_end skilleffect npcskilleffect specialeffect
syn keyword	athCommand	specialeffect2 statusup statusup2 bonus bonus2 bonus3 bonus4 bonus5 skill addtoskill
syn keyword	athCommand	nude disguise undisguise marriage wedding divorce pcfollow pcstopfollow pcblockmove
syn keyword	athCommand	killmonster killmonsterall strmobinfo mobcount clone summon homevolution mobspawn
syn keyword	athCommand	mobremove getmobdata setmobdata mobassist mobattach unitwalk unitkill unitwarp
syn keyword	athCommand	unitattack unitstop unittalk unitemote disablenpc enablenpc hideonnpc hideoffnpc doevent
syn keyword	athCommand	donpcevent cmdothernpc npctalk setnpcdisplay addtimer deltimer addtimercount
syn keyword	athCommand	initnpctimer stopnpctimer startnpctimer setnpctimer getnpctimer attachnpctimer
syn keyword	athCommand	detachnpctimer sleep sleep2 awake announce mapannounce areaannounce callshop npcshopitem
syn keyword	athCommand	npcshopadditem npcshopdelitem npcshopattach waitingroom delwaitingroom
syn keyword	athCommand	enablewaitingroomevent disablewaitingroomevent enablearena disablearena
syn keyword	athCommand	getwaitingroomstate warpwaitingpc kickwaitingroomall setmapflagnosave setmapflag
syn keyword	athCommand	setbattleflag getbattleflag removemapflag warpportal mapwarp maprespawnguildid agitstart
syn keyword	athCommand	agitend gvgon gvgoff flagemblem guardian guardianinfo npcspeed npcwalkto npcstop movenpc
syn keyword	athCommand	debugmes logmes globalmes rand viewpoint cutin pet emotion misceffect soundeffect
syn keyword	athCommand	soundeffectall pvpon pvpoff atcommand charcommand unitskilluseid unitskillusepos day
syn keyword	athCommand	night defpattern activatepset deactivatepset deletepset pow sqrt distance query_sql
syn keyword	athCommand	query_logsql escape_sql setitemscript atoi axtoi compare charisalpha petskillbonus
syn keyword	athCommand	petrecovery petloot petskillsupport petheal petskillattack petskillattack2 bpet makepet
syn keyword	athCommand	checkidle openmail openauction homshuffle setcell md5 autobonus autobonus2 autobonus3
syn keyword	athCommand	cooking getmobdrops getmapflag ascii setiteminfo checkcell setwall delwall
syn keyword	athCommand	mercenary_create mercenary_heal mercenary_sc_start mercenary_get_calls
syn keyword	athCommand	mercenary_get_faith mercenary_set_calls mercenary_set_faith readbook setfont
syn keyword	athCommand	areamobuseskill progressbar agitstart2 agitend2 agitcheck2 waitingroom2bg
syn keyword	athCommand	waitingroom2bg_single bg_team_setxy bg_warp bg_monster bg_monster_set_team bg_leave
syn keyword	athCommand	bg_destroy areapercentheal bg_get_data bg_getareausers bg_updatescore instance_create
syn keyword	athCommand	instance_destroy instance_attachmap instance_detachmap instance_attach instance_id
syn keyword	athCommand	instance_set_timeout instance_init instance_announce instance_npcname has_instance
syn keyword	athCommand	instance_warpall setquest erasequest completequest checkquest changequest charrename
syn keyword	athCommand	searchitem showevent playbgm playbgmall masteropenstorage expmission globalexpmission
syn keyword	athCommand	mapswarmmission pushpc buyingstore searchstores showdigit charisupper charislower charat
syn keyword	athCommand	setchar insertchar delchar strtoupper strtolower substr explode implode makerune
syn keyword	athCommand	checkdragon setdragon ismounting setmounting sprintf sscanf strpos replacestr countstr
syn keyword	athCommand	getstatus getgroupid instance_check_party getargcount is_function freeloop get_revision
syn keyword	athCommand	checkwug hommutate bindatcmd unbindatcmd useatcmd checkre repairall getrandgroupitem
syn keyword	athCommand	checkweight2 getcharip cleanmap cleanarea npcskill consumeitem delequip sit stand
syn keyword	athCommand	morhpembryo checkhomcall

syn region	athPreCondit	start="^\s*\(npc\|delnpc\)\>" skip="\\$" end="$" end="//"me=s-1 contains=athIncluded,athComment,athString,athCharacter,athParenError,athNumbers,athCommentError,athSpaceError
syn region	athIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
"syn match cLineSkip	"\\$"
syn cluster	athPreProcGroup	contains=athPreCondit,athIncluded,athErrInParen,athErrInBracket,athUserLabel,athSpecial,athNumber,athFloat,athNumbersCom,athString,athCommentSkip,athCommentString,athComment2String,@athCommentGroup,athCommentStartError,athParen,athBracket,athMulti

" Highlight User Labels
syn cluster	athMultiGroup	contains=athIncluded,athSpecial,athCommentSkip,athCommentString,athComment2String,@athCommentGroup,athCommentStartError,athUserCont,athUserLabel,athBitField,athNumber,athFloat,athNumbersCom,athString
syn region	athMulti	transparent start='?' skip='::' end=':' contains=ALLBUT,@athMultiGroup,@Spell
" Avoid matching foo::bar() in C++ by requiring that the next char is not ':'
syn cluster	athLabelGroup	contains=athUserLabel
syn match	athUserCont	display "^\s*\I\i*\s*:$" contains=@athLabelGroup
syn match	athUserCont	display ";\s*\I\i*\s*:$" contains=@athLabelGroup
syn match	athUserCont	display "^\s*\I\i*\s*:[^:]"me=e-1 contains=@athLabelGroup
syn match	athUserCont	display ";\s*\I\i*\s*:[^:]"me=e-1 contains=@athLabelGroup

syn match	athUserLabel	display "\I\i*" contained

" Avoid recognizing most bitfields as labels
"syn match	athBitField	display "^\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=athCommand
"syn match	athBitField	display ";\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=athCommand

if exists("c_minlines")
  let b:c_minlines = c_minlines
else
  if !exists("c_no_if0")
    let b:c_minlines = 50	" #if 0 constructs can be long
  else
    let b:c_minlines = 15	" mostly for () constructs
  endif
endif
if exists("c_curly_error")
  syn sync fromstart
else
  exec "syn sync ccomment cComment minlines=" . b:c_minlines
endif

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link athCommentL		athComment
hi def link athCommentStart	athComment
hi def link athLabel		Label
hi def link athUserLabel	Label
hi def link athConditional	Conditional
hi def link athRepeat		Repeat
"hi def link athCharacter	Character
hi def link athNumber		Number
hi def link athFloat		Float
hi def link athParenError	athError
hi def link athErrInParen	athError
hi def link athErrInBracket	athError
hi def link athCommentError	athError
hi def link athCommentStartError athError
hi def link athSpaceError	athError
hi def link athCurlyError	athError
hi def link athOperator		Operator
hi def link athStructure	Structure
hi def link athIncluded		athString
hi def link athError		Error
hi def link athStatement	Statement
hi def link athPreCondit	PreCondit
hi def link athCommand		Type
hi def link athConstant		PreProc
hi def link athCommentString	athString
hi def link athComment2String	athString
hi def link athCommentSkip	athComment
hi def link athString		String
hi def link athComment		Comment
hi def link athSpecial		SpecialChar
hi def link athTodo		Todo

let b:current_syntax = "ath"

" vim: ts=8 tw=120

