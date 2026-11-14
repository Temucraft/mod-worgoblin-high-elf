-- F-039_mod-earthen-horde: skillraceclassinfo

-- SkillRaceClassInfo for Horde Earthen's racial skill line: without it the core drops the skill (and its racials) from
-- every Horde Earthen character, at creation and at login
DELETE FROM `skillraceclassinfo` WHERE `id` = @HordeEarthenRacialSkillRaceClass;
INSERT INTO `skillraceclassinfo` (`id`, `skill_id`, `race_mask`, `class_mask`, `flags`, `min_level`, `skill_tier_id`, `skill_cost_id`)
VALUES (@HordeEarthenRacialSkillRaceClass, @HordeEarthenRacials, @HordeEarthenMask, @AllClassMask, 1170, 0, 0, 0);
