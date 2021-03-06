//::///////////////////////////////////////////////
//:: [Charm Person]
//:: [NW_S0_CharmPer.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is charmed for 1 round
//:: per caster level.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 29, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 5, 2001
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 20, 2001

#include "NW_I0_SPELLS"
#include "x2_inc_spellhook"
#include "ku_boss_inc"

void main()
{

/*
  Spellcast Hook Code
  Added 2003-06-23 by GeorgZ
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook


    //Declare major variables
    object oTarget = GetSpellTargetObject();
    effect eVis = EffectVisualEffect(VFX_IMP_CHARM);
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    int nDuration = 2 + GetLevelByClass(48)/3;  //CLASS_TYPE_KURTIZANA

    //Link persistant effects
    effect eLink = EffectLinkEffects(eDur, eMind);
    if(!GetIsReactionTypeFriendly(oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_CHARM_PERSON, FALSE));
        //Make SR Check
        if (!MyResistSpell(OBJECT_SELF, oTarget))
        {
          int nRacial = GetRacialType(oTarget);
          //Verify that the Racial Type is humanoid
          if ((nRacial == RACIAL_TYPE_DWARF) ||
              (nRacial == RACIAL_TYPE_ELF) ||
              (nRacial == RACIAL_TYPE_GNOME) ||
              (nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID) ||
              (nRacial == RACIAL_TYPE_HALFLING) ||
              (nRacial == RACIAL_TYPE_HUMAN) ||
              (nRacial == RACIAL_TYPE_HALFELF) ||
              (nRacial == RACIAL_TYPE_HALFORC) ||
              (nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS) ||
              (nRacial == RACIAL_TYPE_HUMANOID_ORC) ||
              (nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN)) {
                //Make a Will Save check
                if (!MySavingThrow(SAVING_THROW_WILL, oTarget, GetSpellSaveDC()+GetThalieSpellDCBonus(OBJECT_SELF), SAVING_THROW_TYPE_MIND_SPELLS))
                {
                    //Apply impact and linked effects
                    if(GetIsPC(oTarget)) {
                      ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                    }
                    else {
                      if(GetIsBoss(oTarget)) {
                        nDuration = ReduceShortSpellDurationForBoss_int(oTarget, nDuration, nDuration);
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                      }
                      else
                        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
                      }
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                }
           }

         }
     }
}
