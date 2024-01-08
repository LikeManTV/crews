CREATE TABLE IF NOT EXISTS `crews` (
  `owner` varchar(46) DEFAULT NULL,
  `label` varchar(50) DEFAULT NULL,
  `tag` varchar(4) DEFAULT NULL,
  `data` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;