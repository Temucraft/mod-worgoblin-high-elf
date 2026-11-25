-- Racial skills
DELETE FROM `playercreateinfo_skills` WHERE `raceMask` = @HighmountainTaurenMask AND `classMask` = 0 AND `skill` = @HighmountainTaurenRacials;
INSERT IGNORE INTO `playercreateinfo_skills` (`raceMask`,`classMask`,`skill`,`rank`,`comment`)
VALUES (@HighmountainTaurenMask, 0, @HighmountainTaurenRacials, 0, @HighmountainTaurenRacialNameenUS);

-- Two-Handed Maces: the warrior outfit copied from Tauren starts with one
UPDATE IGNORE `playercreateinfo_skills` SET `racemask` = `racemask` | @HighmountainTaurenMask WHERE `skill` = @2HMaceSkill;
