//::///////////////////////////////////////////////
//:: Bigby's Grasping Hand
//:: [x0_s0_bigby3]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Make an attack roll. If target fails fotitude throw,
    it is held for lvl/3 rounds.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
//:: Updated by P.A., March 8, 2014

#include "x0_i0_spells"

#include "x2_inc_spellhook"

void main()
{

/*
  Spellcast Hook Code
  Added 2003-06-20 by Georg
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
    int nDuration = GetCasterLevel(OBJECT_SELF);
    nDuration = GetThalieCaster(OBJECT_SELF,oTarget,nDuration,FALSE) / 3; // duration changed to lvl/3 rounds
    int nMetaMagic = GetMetaMagicFeat();
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);

    //Check for metamagic extend
    if (nMetaMagic == METAMAGIC_EXTEND) //Duration is +100%
    {
         nDuration = nDuration * 2;
    }

    if(!GetIsReactionTypeFriendly(oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, 461, TRUE));

        // Check spell resistance
        if((!MyResistSpell(OBJECT_SELF, oTarget)) &&(!MySavingThrow(SAVING_THROW_FORT,oTarget,GetSpellSaveDC()+GetThalieSpellDCBonus(OBJECT_SELF),SAVING_THROW_TYPE_SPELL) ))
        {
            // Check caster ability vs. target's AC

            int nCasterModifier = GetCasterAbilityModifier(OBJECT_SELF);
            int nCasterRoll = d20(1)
                + nCasterModifier
                + GetCasterLevel(OBJECT_SELF) + 10 + -1;

            int nTargetRoll = GetAC(oTarget);

            // * grapple HIT succesful,
            //if (nCasterRoll >= nTargetRoll)
            {
                // * now must make a GRAPPLE check to
                // * hold target for duration of spell
                // * check caster ability vs. target's size & strength
                // Hold the target paralyzed
                    effect eKnockdown = EffectParalyze();

                    // creatures immune to paralzation are still prevented from moving
                    if (GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS) ||
                        GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS))
                    {
                        eKnockdown = EffectCutsceneImmobilize();
                    }
                    if(GetLocalInt(oTarget,"AI_BOSS"))
                      eKnockdown = EffectSlow();

                    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                    effect eHand = EffectVisualEffect(VFX_DUR_BIGBYS_GRASPING_HAND);
                    effect eLink = EffectLinkEffects(eKnockdown, eDur);
                    eLink = EffectLinkEffects(eHand, eLink);
                    eLink = EffectLinkEffects(eVis, eLink);

                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                                        eLink, oTarget,
                                        RoundsToSeconds(nDuration));

//                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
//                                        eVis, oTarget,RoundsToSeconds(nDuration));
                    FloatingTextStrRefOnCreature(2478, OBJECT_SELF);
                }
                /*else
                {
                    FloatingTextStrRefOnCreature(83309, OBJECT_SELF);
                }   */

        }
    }
}


