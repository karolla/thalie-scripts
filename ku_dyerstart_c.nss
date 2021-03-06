#include "ku_libtime"
//#include "nwnx_funcs"
#include "ku_taylor_inc"

/*
 * rev. 27.06.2008 Kucik Nahrazeni move funkci za copy
 */

void main()
{
  object oDyer = OBJECT_SELF;
//  object oStand = GetLocalObject(oDyer,"KU_STAND");
  object oChest = GetLocalObject(oDyer,"KU_CHEST");
  object oPC = GetPCSpeaker();
  int iDiscount;


//  SetMovementRate(oPC,MOVEMENT_RATE_IMMOBILE);

//  return;

  if( GetLocalInt(oPC,"KU_APPRAISE_TIME") < ku_GetTimeStamp() ) {
     iDiscount = (GetSkillRank(SKILL_APPRAISE,oPC) + Random(20) + 1) * 50 / 90;
     SetLocalInt(oPC,"KU_APPRAISE",iDiscount);
     SetLocalInt(oPC,"KU_APPRAISE_TIME",ku_GetTimeStamp(0,0,6));
  }
  else {
     iDiscount = GetLocalInt(oPC,"KU_APPRAISE");
     if(GetLocalInt(oPC,"KU_APPRAISE_TIME") < ku_GetTimeStamp(0,5))
        SetLocalInt(oPC,"KU_APPRAISE_TIME",ku_GetTimeStamp(0,5));
  }




//  SetLocalObject(oDyer,"KU_STAND",oStand);

  SetListenPattern(OBJECT_SELF, "**", 777); //listen to all text
  SetListening(OBJECT_SELF, TRUE);          //be sure NPC is listening

  if(!GetIsObjectValid(oChest)) {
    SpeakString("Neni truhla -kontaktujte DM");
    return;
  }
  object oCloth;

  int iSlot = INVENTORY_SLOT_CLOAK;
  oCloth = GetItemInSlot(iSlot,oPC);


  if(!GetIsObjectValid(oCloth)) {
    if(!GetLocalInt(OBJECT_SELF,"dye_shut_up"))
      SpeakString("Nemas na sobe plast ktery by bylo mozne barvit.");
    return;
  }
  int iBaseItem = GetBaseItemType(oCloth);;


  SetLocked(oChest,TRUE);
  SetLockKeyRequired(oChest,TRUE);
  SetLocalInt(oDyer,"DYE_INV_SLOT",iSlot);

  object oOldCloth = oCloth;
  oCloth = CopyItem(oOldCloth,oChest,TRUE);
  DestroyObject(oOldCloth);
  object oNewCloth = CopyObject(oCloth,GetLocation(oPC),oPC,"ku_shop_dyer");

  DelayCommand(0.2,AssignCommand(oPC,ActionEquipItem(oNewCloth,iSlot)));

  SetLocalObject(oDyer,"CUSTOMER",oPC);
  SetLocalObject(oDyer,"ITEM",oNewCloth);
  SetLocalObject(oDyer,"ITEM_BACKUP",oCloth);
  SetLocalInt(oDyer,"TAYLOR_MODE",0);

  SetLocalInt(oDyer,"working",1);
  ku_TaylorRememberModels(oCloth);
  ku_DyerRememberColors(oCloth);

  SetCustomToken(6001,"0");
}
