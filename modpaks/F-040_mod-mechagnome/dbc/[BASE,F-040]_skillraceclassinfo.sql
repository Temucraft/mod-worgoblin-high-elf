-- F-040_mod-mechagnome: skillraceclassinfo

-- SkillRaceClassInfo for Mechagnome's racial skill line: without it the core drops the skill (and its racials) from
-- every Mechagnome character, at creation and at login
DELETE FROM `skillraceclassinfo` WHERE `id` = @MechagnomeRacialSkillRaceClass;
INSERT INTO `skillraceclassinfo` (`id`, `skill_id`, `race_mask`, `class_mask`, `flags`, `min_level`, `skill_tier_id`, `skill_cost_id`)
VALUES (@MechagnomeRacialSkillRaceClass, @MechagnomeRacials, @MechagnomeMask, @AllClassMask, 1170, 0, 0, 0);
