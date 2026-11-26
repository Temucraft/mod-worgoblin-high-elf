// Mag'har Orc Sympathetic Vigor (modpak F-007): the pet's health. The spell's aura targets the pet (TARGET_UNIT_PET),
// but a passive racial only ever lands on its owner, so the pet never got it. Each time a pet's stats are set up
// (summon, level up), the pet gets the same aura.

#include "Pet.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include <cstring>

namespace
{
    constexpr uint32 SPELL_SYMPATHETIC_VIGOR = 273217;   // BfA ID (@SpellSympatheticVigor)

    bool IsInstalled()
    {
        // only with F-007's spell (the id is a retail one, any other build may not have it)
        SpellInfo const* info = sSpellMgr->GetSpellInfo(SPELL_SYMPATHETIC_VIGOR);
        char const* name = info ? info->SpellName[LOCALE_enUS] : nullptr;
        return name && !std::strcmp(name, "Sympathetic Vigor");
    }
}

class player_maghar_sympathetic_vigor : public PlayerScript
{
public:
    player_maghar_sympathetic_vigor() : PlayerScript("player_maghar_sympathetic_vigor",
        { PLAYERHOOK_ON_AFTER_GUARDIAN_INIT_STATS_FOR_LEVEL }) { }

    void OnPlayerAfterGuardianInitStatsForLevel(Player* player, Guardian* guardian) override
    {
        if (!guardian || !guardian->IsPet() || !player->HasSpell(SPELL_SYMPATHETIC_VIGOR) || guardian->HasAura(SPELL_SYMPATHETIC_VIGOR))
            return;
        static bool const installed = IsInstalled();
        if (installed)
            guardian->AddAura(SPELL_SYMPATHETIC_VIGOR, guardian);
    }
};

void AddSC_F007_SympatheticVigor()
{
    new player_maghar_sympathetic_vigor();
}
