-- F-038_mod-earthen-alliance: skillraceclassinfo

-- SkillRaceClassInfo for Alliance Earthen's racial skill line: without it the core drops the skill (and its racials) from
-- every Alliance Earthen character, at creation and at login
DELETE FROM `skillraceclassinfo` WHERE `id` = @AllianceEarthenRacialSkillRaceClass;
INSERT INTO `skillraceclassinfo` (`id`, `skill_id`, `race_mask`, `class_mask`, `flags`, `min_level`, `skill_tier_id`, `skill_cost_id`)
VALUES (@AllianceEarthenRacialSkillRaceClass, @AllianceEarthenRacials, @AllianceEarthenMask, @AllClassMask, 1170, 0, 0, 0);
