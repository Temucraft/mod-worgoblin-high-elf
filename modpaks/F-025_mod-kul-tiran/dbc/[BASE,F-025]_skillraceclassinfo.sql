-- F-025_mod-kul-tiran: skillraceclassinfo

-- SkillRaceClassInfo for Kul Tiran's racial skill line: without it the core drops the skill (and its racials) from
-- every Kul Tiran character, at creation and at login
DELETE FROM `skillraceclassinfo` WHERE `id` = @KulTiranRacialSkillRaceClass;
INSERT INTO `skillraceclassinfo` (`id`, `skill_id`, `race_mask`, `class_mask`, `flags`, `min_level`, `skill_tier_id`, `skill_cost_id`)
VALUES (@KulTiranRacialSkillRaceClass, @KulTiranRacials, @KulTiranMask, @AllClassMask, 1170, 0, 0, 0);
