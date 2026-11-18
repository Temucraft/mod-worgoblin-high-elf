-- [F-019] mod-vulpera: skillraceclassinfo: 1 inserts, 0 updates, 0 deletes

-- SkillRaceClassInfo for Vulpera's racial skill line: without it the core drops the skill (and its racials) from
-- every Vulpera character, at creation and at login
DELETE FROM `skillraceclassinfo` WHERE `id` = @VulperaRacialSkillRaceClass;
INSERT INTO `skillraceclassinfo` (`id`, `skill_id`, `race_mask`, `class_mask`, `flags`, `min_level`, `skill_tier_id`, `skill_cost_id`)
VALUES (@VulperaRacialSkillRaceClass, @VulperaRacials, @VulperaMask, @AllClassMask, 1170, 0, 0, 0);
