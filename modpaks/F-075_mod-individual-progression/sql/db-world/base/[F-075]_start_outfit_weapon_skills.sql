/* Every weapon in a start outfit needs its weapon skill, or the character starts with it in the bags.
   Individual Progression's weapon skills are per stock race and class (pre-3.3), and the rows above give custom
   races their Home race's, so combinations Individual Progression doesn't know (ARAC's, such as Human Hunter, and
   classes a custom race has that its Home race lacks) can be left without the skill for the weapon their outfit
   holds. This adds it for exactly that race and class, from the outfit itself, after everything else has run.
   Skills that SkillRaceClassInfo doesn't allow for the combination are left out (the character couldn't keep them). */

DROP TEMPORARY TABLE IF EXISTS `f075_weapon_skill`;
CREATE TEMPORARY TABLE `f075_weapon_skill` (`subclass` TINYINT UNSIGNED PRIMARY KEY, `skill` SMALLINT UNSIGNED NOT NULL);
INSERT INTO `f075_weapon_skill` (`subclass`, `skill`) VALUES
(0, 44),   -- One-Handed Axes
(1, 172),  -- Two-Handed Axes
(2, 45),   -- Bows
(3, 46),   -- Guns
(4, 54),   -- One-Handed Maces
(5, 160),  -- Two-Handed Maces
(6, 229),  -- Polearms
(7, 43),   -- One-Handed Swords
(8, 55),   -- Two-Handed Swords
(10, 136), -- Staves
(13, 473), -- Fist Weapons
(15, 173), -- Daggers
(16, 176), -- Thrown
(18, 226), -- Crossbows
(19, 228); -- Wands

INSERT IGNORE INTO `playercreateinfo_skills` (`raceMask`, `classMask`, `skill`, `rank`, `comment`)
SELECT DISTINCT 1 << (`o`.`race` - 1), 1 << (`o`.`class` - 1), `w`.`skill`, 0, 'Start outfit weapon (F-075)'
FROM (
    SELECT `race`, `class`, `item_1` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_2` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_3` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_4` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_5` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_6` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_7` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_8` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_9` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_10` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_11` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_12` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_13` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_14` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_15` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_16` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_17` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_18` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_19` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_20` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_21` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_22` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_23` AS `item` FROM `dbc_db`.`charstartoutfit` UNION ALL
    SELECT `race`, `class`, `item_24` AS `item` FROM `dbc_db`.`charstartoutfit`
) AS `o`
JOIN `item_template` AS `i` ON `i`.`entry` = `o`.`item` AND `i`.`class` = 2
JOIN `f075_weapon_skill` AS `w` ON `w`.`subclass` = `i`.`subclass`
WHERE `o`.`item` > 0
  AND EXISTS (SELECT 1 FROM `playercreateinfo` AS `p` WHERE `p`.`race` = `o`.`race` AND `p`.`class` = `o`.`class`)
  AND NOT EXISTS (
      SELECT 1 FROM `playercreateinfo_skills` AS `s`
      WHERE `s`.`skill` = `w`.`skill`
        AND (`s`.`raceMask` = 0 OR `s`.`raceMask` & (1 << (`o`.`race` - 1)))
        AND (`s`.`classMask` = 0 OR `s`.`classMask` & (1 << (`o`.`class` - 1))))
  AND EXISTS (
      SELECT 1 FROM `dbc_db`.`skillraceclassinfo` AS `r`
      WHERE `r`.`skill_id` = `w`.`skill`
        AND (`r`.`race_mask` = 0 OR `r`.`race_mask` & (1 << (`o`.`race` - 1)))
        AND (`r`.`class_mask` = 0 OR `r`.`class_mask` & (1 << (`o`.`class` - 1))));

DROP TEMPORARY TABLE `f075_weapon_skill`;
