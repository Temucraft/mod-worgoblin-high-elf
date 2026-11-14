-- skillraceclassinfo: 2 inserts, 0 updates, 0 deletes

-- New entries
INSERT INTO `skillraceclassinfo` (`id`, `skill_id`, `race_mask`, `class_mask`, `flags`, `min_level`, `skill_tier_id`, `skill_cost_id`) VALUES
(@PandarenRacialSkillRaceClass, @PandarenRacials, @HordePandarenMask, @AllClassMask, 1170, 0, 0, 0)
-- Both Pandaren modpaks share this row: each adds its race, so neither removes the other's
ON DUPLICATE KEY UPDATE `race_mask` = `race_mask` | VALUES(`race_mask`);
