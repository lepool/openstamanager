-- Nuovo modulo "Fasce orarie"
CREATE TABLE IF NOT EXISTS `in_fasceorarie` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL,
  `giorni` varchar(255) DEFAULT NULL,
  `ora_inizio` time DEFAULT NULL,
  `ora_fine` time DEFAULT NULL,
  `can_delete` BOOLEAN NOT NULL DEFAULT TRUE,
  `include_bank_holidays` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

INSERT INTO `zz_modules` (`id`, `name`, `title`, `directory`, `options`, `options2`, `icon`, `version`, `compatibility`, `order`, `parent`, `default`, `enabled`, `use_notes`, `use_checklists`) VALUES (NULL, 'Fasce orarie', 'Fasce orarie', 'fasce_orarie', 'SELECT |select| FROM `in_fasceorarie` WHERE 1=1 HAVING 2=2', '', 'fa fa-angle-right', '2.4.32', '2.4.32', '1', (SELECT id FROM zz_modules t WHERE t.name = 'Interventi'), '1', '1', '0', '0'); 

INSERT INTO `zz_views` (`id`, `id_module`, `name`, `query`, `order`, `visible`, `format`, `default`) VALUES
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Fasce orarie'), 'id', 'in_fasceorarie.id', 1, 1, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Fasce orarie'), 'Nome', 'in_fasceorarie.nome', 2, 1, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Fasce orarie'), 'Giorni', 'IF(in_fasceorarie.giorni = ''1,2,3,4,5'', ''Lavorativi'',  IF(in_fasceorarie.giorni = ''6,7'', ''Fine settimana'', IF(in_fasceorarie.giorni = ''6'', ''Solo Sabato'', IF(in_fasceorarie.giorni = ''1,2,3,4,5,6,7'', ''Tutti i giorni'', ''Nessuno'' ))))', 3, 1, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Fasce orarie'), 'Ora inizio', 'in_fasceorarie.ora_inizio', 4, 1, 1, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Fasce orarie'), 'Ora fine', 'in_fasceorarie.ora_fine', 5, 1, 1, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Fasce orarie'), 'Festività', 'IF(in_fasceorarie.include_bank_holidays, ''S&igrave;'', ''No'')', 6, 1, 0, 1);



-- Fascia oraria "Ordinaria"
INSERT INTO `in_fasceorarie` (`id`, `nome`, `giorni`, `ora_inizio`, `ora_fine`, `can_delete`) VALUES (NULL, 'Ordinario', '1,2,3,4,5,6,7', '00:00', '23:59', '0'); 

-- Relazione fasca oraria / tipo intervento
CREATE TABLE IF NOT EXISTS `in_fasceorarie_tipiintervento` (
  `idfasciaoraria` int NOT NULL,
  `idtipointervento` int NOT NULL,
  `costo_orario` decimal(12,6) NOT NULL,
  `costo_km` decimal(12,6) NOT NULL,
  `costo_diritto_chiamata` decimal(12,6) NOT NULL,
  `costo_orario_tecnico` decimal(12,6) NOT NULL,
  `costo_km_tecnico` decimal(12,6) NOT NULL,
  `costo_diritto_chiamata_tecnico` decimal(12,6) NOT NULL,
  PRIMARY KEY (`idfasciaoraria`,`idtipointervento`),
  FOREIGN KEY (`idfasciaoraria`) REFERENCES `in_fasceorarie` (`id`),
  FOREIGN KEY (`idtipointervento`) REFERENCES `in_tipiintervento` (`idtipointervento`),
  KEY `idtipointervento` (`idtipointervento`)
) ENGINE=InnoDB;


-- Nuovo modulo "Eventi"
CREATE TABLE IF NOT EXISTS `zz_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL,
  `data` date NOT NULL,
  `id_nazione` int NOT NULL,
  `id_regione` int DEFAULT NULL,
  `is_recurring` tinyint(1) NOT NULL DEFAULT '0',
  `is_bank_holiday` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  FOREIGN KEY (`id_nazione`) REFERENCES `an_nazioni` (`id`)
) ENGINE=InnoDB;


INSERT INTO `zz_modules` (`id`, `name`, `title`, `directory`, `options`, `options2`, `icon`, `version`, `compatibility`, `order`, `parent`, `default`, `enabled`, `use_notes`, `use_checklists`) VALUES (NULL, 'Eventi', 'Eventi', 'eventi', 'SELECT |select| FROM `zz_events` INNER JOIN `an_nazioni` ON `an_nazioni`.id = `zz_events`.id_nazione WHERE 1=1 HAVING 2=2', '', 'fa fa-angle-right', '2.4.32', '2.4.32', '1', (SELECT id FROM zz_modules t WHERE t.name = 'Tabelle'), '1', '1', '0', '0');

INSERT INTO `zz_views` (`id`, `id_module`, `name`, `query`, `order`, `visible`, `format`, `default`) VALUES
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Eventi'), 'id', 'zz_events.id', 1, 0, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Eventi'), 'Nome', 'zz_events.nome', 2, 1, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Eventi'), 'Nazione', 'an_nazioni.nome', 3, 1, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Eventi'), 'Data', 'zz_events.data', 4, 1, 1, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Eventi'), 'Ricorrente', 'IF(zz_events.is_recurring, ''S&igrave;'', ''No'')', 5, 1, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Eventi'), 'Festività', 'IF(zz_events.is_bank_holiday, ''S&igrave;'', ''No'')', 6, 1, 0, 1);

-- Natale
INSERT INTO `zz_events` (`id`, `nome`, `data`, `id_nazione`, `id_regione`, `is_recurring`, `is_bank_holiday`) VALUES (NULL, 'Natale', '2022-12-25', (SELECT id FROM an_nazioni WHERE nome = 'Italia'), NULL, '1', '1'); 

-- Fix ordine colonne Conto dare e Conto avere in Prima nota
UPDATE `zz_views` SET `order` = '8' WHERE `zz_views`.`name` = 'Conto dare';
UPDATE `zz_views` SET `order` = '9' WHERE `zz_views`.`name` = 'Conto avere';
UPDATE `zz_views` SET `order` = '20' WHERE `zz_views`.`name` = '_print_';

-- Fix visualizzazione colonne Totali in fatture
UPDATE `zz_modules` SET `options` = 'SELECT |select| FROM `co_documenti`\n    LEFT JOIN `an_anagrafiche` ON `co_documenti`.`idanagrafica` = `an_anagrafiche`.`idanagrafica`\n    LEFT JOIN `co_tipidocumento` ON `co_documenti`.`idtipodocumento` = `co_tipidocumento`.`id`\n    LEFT JOIN `co_statidocumento` ON `co_documenti`.`idstatodocumento` = `co_statidocumento`.`id`\n    LEFT JOIN `fe_stati_documento` ON `co_documenti`.`codice_stato_fe` = `fe_stati_documento`.`codice`\n    LEFT JOIN (\n        SELECT `iddocumento`,\n            SUM(`subtotale` - `sconto`) AS `totale_imponibile`,\n                SUM(`iva`) AS `iva`,\n                `split_payment`\n         FROM `co_righe_documenti` LEFT JOIN `co_documenti` ON `co_righe_documenti`.`iddocumento`=`co_documenti`.`id`\n        GROUP BY `iddocumento`\n    ) AS righe ON `co_documenti`.`id` = `righe`.`iddocumento`\n    LEFT JOIN (\n        SELECT `numero_esterno`, `id_segment`\n        FROM `co_documenti`\n        WHERE `co_documenti`.`idtipodocumento` IN(SELECT `id` FROM `co_tipidocumento` WHERE `dir` = \'entrata\') |date_period(`co_documenti`.`data`)| AND `numero_esterno` != \'\'\n        GROUP BY `id_segment`, `numero_esterno`\n        HAVING COUNT(`numero_esterno`) > 1\n    ) dup ON `co_documenti`.`numero_esterno` = `dup`.`numero_esterno` AND `dup`.`id_segment` = `co_documenti`.`id_segment`\n    LEFT JOIN (\n        SELECT `zz_operations`.`id_email`, `zz_operations`.`id_record`\n        FROM `zz_operations`\n            INNER JOIN `em_emails` ON `zz_operations`.`id_email` = `em_emails`.`id`\n            INNER JOIN `em_templates` ON `em_emails`.`id_template` = `em_templates`.`id`\n            INNER JOIN `zz_modules` ON `zz_operations`.`id_module` = `zz_modules`.`id`\n        WHERE `zz_modules`.`name` = \'Fatture di vendita\' AND `zz_operations`.`op` = \'send-email\'\n        GROUP BY `zz_operations`.`id_record`\n    ) AS `email` ON `email`.`id_record` = `co_documenti`.`id`\nWHERE 1=1 AND `dir` = \'entrata\' |segment(`co_documenti`.`id_segment`)| |date_period(`co_documenti`.`data`)|\nHAVING 2=2\nORDER BY `co_documenti`.`data` DESC, CAST(`co_documenti`.`numero_esterno` AS UNSIGNED) DESC' WHERE `zz_modules`.`name` = 'Fatture di vendita';

UPDATE `zz_views` SET `query` = '(righe.totale_imponibile + righe.iva + `co_documenti`.`rivalsainps` + `co_documenti`.`iva_rivalsainps`) * IF(co_tipidocumento.reversed, -1, 1)' WHERE `zz_views`.`name` = 'Totale ivato' AND `zz_views`.`id_module`=(SELECT `id` FROM `zz_modules` WHERE `name` = 'Fatture di vendita'); 

UPDATE `zz_views` SET `query` = '(righe.totale_imponibile + IF(righe.split_payment=0, righe.iva, 0) + `co_documenti`.`rivalsainps` + `co_documenti`.`iva_rivalsainps` - `co_documenti`.`ritenutaacconto` - `co_documenti`.`sconto_finale`) * (1 - `co_documenti`.`sconto_finale_percentuale` / 100) * IF(co_tipidocumento.reversed, -1, 1)' WHERE `zz_views`.`name` = 'Netto a pagare' AND `zz_views`.`id_module`=(SELECT `id` FROM `zz_modules` WHERE `name` = 'Fatture di vendita'); 

UPDATE `zz_modules` SET `options` = 'SELECT |select| FROM `co_documenti`\nLEFT JOIN `an_anagrafiche` ON `co_documenti`.`idanagrafica` = `an_anagrafiche`.`idanagrafica`\nLEFT JOIN `co_tipidocumento` ON `co_documenti`.`idtipodocumento` = `co_tipidocumento`.`id`\nLEFT JOIN `co_statidocumento` ON `co_documenti`.`idstatodocumento` = `co_statidocumento`.`id`\nLEFT JOIN (\n    SELECT `iddocumento`,\n    SUM(`subtotale` - `sconto`) AS `totale_imponibile`,\n    SUM(`iva`) AS `iva`,\n    `split_payment`\n    FROM `co_righe_documenti` LEFT JOIN `co_documenti` ON `co_righe_documenti`.`iddocumento`=`co_documenti`.`id`\n    GROUP BY `iddocumento`\n) AS righe ON `co_documenti`.`id` = `righe`.`iddocumento`\nLEFT JOIN (\n    SELECT COUNT(`d`.`id`) AS `conteggio`,\n        IF(`d`.`numero_esterno`=\'\', `d`.`numero`, `d`.`numero_esterno`) AS `numero_documento`,\n        `d`.`idanagrafica` AS `anagrafica`\n    FROM `co_documenti` AS `d`\n    LEFT JOIN `co_tipidocumento` AS `d_tipo` ON `d`.`idtipodocumento` = `d_tipo`.`id`\n    WHERE 1=1\n        AND `d_tipo`.`dir` = \'uscita\'\n        AND (\'|period_start|\' <= `d`.`data` AND \'|period_end|\' >= `d`.`data` OR \'|period_start|\' <= `d`.`data_competenza` AND \'|period_end|\' >= `d`.`data_competenza`)\n        GROUP BY `numero_documento`, `d`.`idanagrafica`\n) AS `d` ON (`d`.`numero_documento` = IF(`co_documenti`.`numero_esterno`=\'\', `co_documenti`.`numero`, `co_documenti`.`numero_esterno`) AND `d`.`anagrafica`=`co_documenti`.`idanagrafica`)\nWHERE 1=1 AND `dir` = \'uscita\' |segment(`co_documenti`.`id_segment`)||date_period(custom, \'|period_start|\' <= `co_documenti`.`data` AND \'|period_end|\' >= `co_documenti`.`data`, \'|period_start|\' <= `co_documenti`.`data_competenza` AND \'|period_end|\' >= `co_documenti`.`data_competenza` )|\nHAVING 2=2\nORDER BY `co_documenti`.`data` DESC, CAST(IF(`co_documenti`.`numero` = \'\', `co_documenti`.`numero_esterno`, `co_documenti`.`numero`) AS UNSIGNED) DESC' WHERE `zz_modules`.`name` = 'Fatture di acquisto';

UPDATE `zz_views` SET `query` = '(righe.totale_imponibile + righe.iva + `co_documenti`.`rivalsainps` + `co_documenti`.`iva_rivalsainps`) * IF(co_tipidocumento.reversed, -1, 1)' WHERE `zz_views`.`name` = 'Totale ivato' AND `zz_views`.`id_module`=(SELECT `id` FROM `zz_modules` WHERE `name` = 'Fatture di acquisto'); 

UPDATE `zz_views` SET `query` = '(righe.totale_imponibile + IF(righe.split_payment=0, righe.iva, 0) + `co_documenti`.`rivalsainps` + `co_documenti`.`iva_rivalsainps` - `co_documenti`.`ritenutaacconto` - `co_documenti`.`sconto_finale`) * (1 - `co_documenti`.`sconto_finale_percentuale` / 100) * IF(co_tipidocumento.reversed, -1, 1)' WHERE `zz_views`.`name` = 'Netto a pagare' AND `zz_views`.`id_module`=(SELECT `id` FROM `zz_modules` WHERE `name` = 'Fatture di acquisto'); 