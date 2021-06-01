INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
	('society_weazelnews','Journaliste',1)
;

INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES
	('society_weazelnews','Journaliste', 1)
;
INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES
	('society_weazelnews', 'Journaliste', 1)
;

INSERT INTO `jobs`(`name`, `label`, `whitelisted`) VALUES
	('weazelnews', 'Journaliste', 1)
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('weazelnews',0,'recrue','Intérimaire', 200, '{}', '{}'),
	('weazelnews',1,'novice','Employé', 400, '{}', '{}'),
	('weazelnews',3,'boss','Patron', 800,'{}', '{}')
;