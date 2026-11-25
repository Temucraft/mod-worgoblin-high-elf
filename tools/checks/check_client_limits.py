#!/usr/bin/env python3
"""Checks client DBC files against the limits of the stock 3.3.5a (12340) Wow.exe that crash it.

Each check names the Wow.exe function (address from the wowdecomp // OFFSET: tags) that the data would break:

  CharSections order      BuildComponentArray 0x004F3DD0 sizes each race/sex/section list from one run of rows.
                          Rows of one race, sex and section (or variation) that are split up give a list sized for
                          the last run, and the next pass writes past it: heap damage that crashes later, anywhere.
                          Sort by race, sex, section, variation, color.
  CharSections race ids   the lookup holds 2 * (highest ChrRaces id) + 2 entries.
  Playable race ids       CCharacterCreation::m_charPreferences[22][2] (0x00B6B0D0) is indexed by race id
                          (SetSelectedRace 0x004E20B0, SetSelectedSex 0x004E1540): a playable race of id 22 or more
                          writes over m_raceIndex, m_character and the race list. Ids of 32 or more also do not fit
                          the 32-bit race masks (1 << (race - 1)).
  Playable race count     the glue has 20 race buttons (MAX_RACES), and Script_GetAvailableRaces 0x004E1880 pushes
                          3 Lua values per race without lua_checkstack.
  Faction list index      CGReputationInfo::m_factionStandings[128] (0x00C22B70); an index past 127 writes over
                          m_headers[64] and crashes in CGReputationInfo::AddHeader 0x005CFE70.
  EmotesTextSound order   SI2::InitEmoteSounds 0x004CECB0 keeps pointers into a list that moves as it grows; rows of
                          an emote that come after a later emote's first row are written through an old pointer.

With --races-30 the checks are for a Wow.exe patched by Temucraft's _tools/patch_wow_races.py (m_charPreferences
moved to a [256][2] array, lua_checkstack added to the three race and class lists) and a glue with 30 race buttons:
playable race ids up to 31 and up to 30 playable races are then fine.

Usage: check_client_limits.py [--races-30] DBC_FOLDER [MORE_FOLDERS...]
A file missing from the first folder is taken from the next one (so a patch's few DBCs can be checked on top of the
full set). Exit code 1 when an error is found.
"""
import os
import struct
import sys


def load(folders, name):
    for d in folders:
        p = os.path.join(d, name + '.dbc')
        if os.path.isfile(p) and os.path.getsize(p) > 20:
            b = open(p, 'rb').read()
            if b[:4] != b'WDBC':
                raise SystemExit(f'{p}: not a DBC file')
            n, f, rs, _ = struct.unpack('<4I', b[4:20])
            rows = []
            for i in range(n):
                o = 20 + i * rs
                rows.append(struct.unpack('<%dI' % f, b[o:o + rs]) if rs == f * 4 else tuple(b[o:o + rs]))
            return rows, p
    return None, None


def main(folders, races30=False):
    errors = []
    warnings = []

    races, _ = load(folders, 'ChrRaces')
    if races is None:
        raise SystemExit('ChrRaces.dbc not found')
    race_ids = {r[0] for r in races}
    max_race = max(race_ids)
    playable = sorted(r[0] for r in races if not (r[1] & 1))

    for r in playable:
        if r >= 32:
            errors.append(f'ChrRaces: playable race {r} is 32 or more (32-bit race masks)')
        elif r >= 22 and not races30:
            errors.append(f'ChrRaces: playable race {r} is 22 or more (CCharacterCreation::m_charPreferences[22][2])')
    if len(playable) > 30:
        warnings.append(f'ChrRaces: {len(playable)} playable races; the glue has 30 race buttons')
    elif len(playable) > 20 and not races30:
        warnings.append(f'ChrRaces: {len(playable)} playable races; the glue has 20 race buttons and '
                        'GetAvailableRaces has no lua_checkstack')

    base, _ = load(folders, 'CharBaseInfo')
    if base is not None:
        with_classes = {r[0] for r in base}
        for r in playable:
            if r not in with_classes:
                warnings.append(f'CharBaseInfo: playable race {r} has no classes')

    sections, path = load(folders, 'CharSections')
    if sections is not None:
        bad = sorted({r[1] for r in sections if r[1] > max_race})
        if bad:
            errors.append(f'CharSections: race ids past ChrRaces ({max_race}): {bad}')
        # the stock client's two passes, exactly
        rows = [r for r in sections if r[3] < 5]
        sizes = {}
        if rows:
            race, sex, sec, var = rows[0][1], rows[0][2], rows[0][3], 0
            for r in rows:
                if (race, sex, sec) != (r[1], r[2], r[3]):
                    sizes[(race, sex, sec)] = var + 1
                    var = 0
                var = max(var, r[8])
                race, sex, sec = r[1], r[2], r[3]
            sizes[(race, sex, sec)] = var + 1
        overruns = []
        race, sex, sec, var = 1, 0, 0, 0
        for r in rows:
            if (race, sex, sec, var) != (r[1], r[2], r[3], r[8]):
                n = sizes.get((race, sex, sec), 0)
                if n > 0 and var >= n:
                    overruns.append((race, sex, sec, var, n))
            race, sex, sec, var = r[1], r[2], r[3], r[8]
        seen, prev, split = set(), None, set()
        for r in rows:
            k = (r[1], r[2], r[3])
            if k != prev:
                if k in seen:
                    split.add(k)
                seen.add(k)
                prev = k
        if overruns:
            errors.append(f'CharSections ({path}): the stock client writes past {len(overruns)} lists, first: '
                          'race %d sex %d section %d variation %d, list of %d' % overruns[0])
        if split:
            first = sorted(split)[0]
            (errors if overruns else warnings).append(
                f'CharSections: {len(split)} race/sex/section groups are split up (first: race {first[0]} sex '
                f'{first[1]} section {first[2]}); sort by race, sex, section, variation, color')

    faction, _ = load(folders, 'Faction')
    if faction is not None:
        idx = [r[1] for r in faction if r[1] != 0xFFFFFFFF]
        over = sorted(i for i in idx if i > 127)
        if over:
            errors.append(f'Faction: reputation list indexes past 127: {over[:10]}')
        dup = sorted({i for i in idx if idx.count(i) > 1})
        if dup:
            errors.append(f'Faction: reputation list indexes used twice: {dup[:10]}')
        free = 128 - len(set(i for i in idx if i <= 127))
        print(f'Faction: {len(set(idx))} reputation list indexes in use, {free} of 128 free')

    emotes, _ = load(folders, 'EmotesTextSound')
    if emotes is not None:
        order, newest, late = {}, -1, 0
        for r in emotes:
            o = order.setdefault(r[1], len(order))
            if o > newest:
                newest = o
            elif o < newest:
                late += 1
        if late:
            warnings.append(f'EmotesTextSound: {late} rows come after a later emote\'s first row; '
                            'sort by emote, race, sex')

    print(f'ChrRaces: {len(races)} races, highest id {max_race}, playable: {playable}')
    for w in warnings:
        print('WARNING ' + w)
    for e in errors:
        print('ERROR   ' + e)
    if not errors:
        print('No errors.')
    return 1 if errors else 0


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__)
        raise SystemExit(2)
    args = [a for a in sys.argv[1:] if a != '--races-30']
    raise SystemExit(main(args, races30=len(args) != len(sys.argv) - 1))
