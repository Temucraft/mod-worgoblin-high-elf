// Two Forms (F-024_mod-playable-worgen)

#include "ModpakScripts.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "Spell.h"
#include "SpellInfo.h"
#include "SpellMgr.h"

enum WorgenTwoForms
{
    SPELL_DARKFLIGHT        = 68992, // a Worgen racial, to tell Worgen apart (@SpellDarkflight)
    SPELL_TWO_FORMS_MALE    = 68996, // @SpellTwoFormsMale
    SPELL_TWO_FORMS_FEMALE  = 68995, // @SpellTwoFormsFemale

    ZONE_GILNEAS            = 4714,
    ZONE_GILNEAS_CITY       = 4755,
};

// Worgen get Two Forms from a Gilneas quest that not every setup has ported, so a Worgen who lacks it is taught it on
// logging in or changing zone anywhere outside Gilneas (where the questline still teaches it).
//
// With F-063 and the patched client, Two Forms applies the altered form aura and the male spell serves both genders.
// Without them (stock exe), each spell is a plain transform into a human illusion of its gender, so female Worgen need
// the female spell. Entering combat or casting Darkflight drops the human form, as in Cataclysm.
class player_worgen_two_forms : public PlayerScript
{
public:
    player_worgen_two_forms() : PlayerScript("player_worgen_two_forms") { }

    void OnPlayerLogin(Player* player) override { Teach(player, player->GetZoneId()); }
    void OnPlayerUpdateZone(Player* player, uint32 newZone, uint32 /*newArea*/) override { Teach(player, newZone); }

    void OnPlayerEnterCombat(Player* player, Unit* /*enemy*/) override { DropHumanForm(player); }

    // Darkflight is a Worgen-form ability
    void OnPlayerSpellCast(Player* player, Spell* spell, bool /*skipCheck*/) override
    {
        if (spell->GetSpellInfo()->Id == SPELL_DARKFLIGHT)
            DropHumanForm(player);
    }

private:
    static void DropHumanForm(Player* player)
    {
        if (IsStockTransform())
            player->RemoveAurasDueToSpell(SpellFor(player));
    }

    // The F-063 version applies the altered form aura instead of a transform
    static bool IsStockTransform()
    {
        SpellInfo const* info = sSpellMgr->GetSpellInfo(SPELL_TWO_FORMS_MALE);
        return info && info->HasAura(SPELL_AURA_TRANSFORM);
    }

    static uint32 SpellFor(Player const* player)
    {
        if (IsStockTransform() && player->getGender() == GENDER_FEMALE)
            return SPELL_TWO_FORMS_FEMALE;
        return SPELL_TWO_FORMS_MALE;
    }

    static void Teach(Player* player, uint32 zoneId)
    {
        if (!WHE::IsSpellForPlayerRace(player, SPELL_DARKFLIGHT) || zoneId == ZONE_GILNEAS || zoneId == ZONE_GILNEAS_CITY)
            return;

        uint32 wanted = SpellFor(player);
        uint32 other = wanted == SPELL_TWO_FORMS_MALE ? SPELL_TWO_FORMS_FEMALE : SPELL_TWO_FORMS_MALE;
        // A female Worgen taught the male spell before this fix turned into a human man
        if (player->HasSpell(other))
            player->removeSpell(other, SPEC_MASK_ALL, false);
        if (!player->HasSpell(wanted) && sSpellMgr->GetSpellInfo(wanted))
            player->learnSpell(wanted);
    }
};

void AddSC_F024_WorgenTwoForms()
{
    new player_worgen_two_forms();
}
