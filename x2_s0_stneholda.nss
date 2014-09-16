//::///////////////////////////////////////////////
//:: Stonehold
//:: X2_S0_StneholdA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates an area of effect that will cover the
    creature with a stone shell holding them in
    place.
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: August  2003
//:: Updated   : October 2003
//:://////////////////////////////////////////////


#include "NW_I0_SPELLS"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "ku_boss_inc"

void main()
{
    //Declare major variables
    int nRounds;
    effect eHold = EffectParalyze();
    effect eDur = EffectVisualEffect(476  );
    effect eFind;
    object oTarget;
    object oCreator;
    float fDelay;
    int iSpecBonus = 0;
    if (GetHasFeat(FEAT_DRUID_SPECIALIZACE_PRIRODA) || GetHasFeat(FEAT_DRUID_SPECIALIZACE_MOROVY))
    {
        iSpecBonus= 2;
    }
    int nMetaMagic = GetMetaMagicFeat();
    effect eLink = EffectLinkEffects(eDur,eHold);
    effect eSlow = EffectLinkEffects(eDur, EffectSlow());
    //Get the first object in the persistant area
    oTarget = GetEnteringObject();
    if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, GetAreaOfEffectCreator()))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_STONEHOLD));
        //Make a SR check
            if(!MyResistSpell(GetAreaOfEffectCreator(), oTarget))
            {
                //Make a Fort Save
                if(!MySavingThrow(SAVING_THROW_WILL, oTarget, GetSpellSaveDC()+GetThalieSpellDCBonus(OBJECT_SELF)+iSpecBonus, SAVING_THROW_TYPE_MIND_SPELLS))
                {
                   nRounds = MaximizeOrEmpower(6, 1, nMetaMagic);
                   fDelay = GetRandomDelay(0.45, 1.85);
                   // Boss exception 
                   if(GetIsBoss(oTarget))
                     DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, oTarget, RoundsToSeconds(nRounds)));
                   else 
                     //Apply the VFX impact and linked effects
                     DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nRounds)));
                }
        }
    }
}
