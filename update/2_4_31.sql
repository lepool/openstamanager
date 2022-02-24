-- Aggiunta dicitura fissa nei segmenti fiscali
ALTER TABLE `zz_segments` ADD `dicitura_fissa` TEXT NOT NULL AFTER `note`; 

-- Fix codice iva 
UPDATE `co_iva` SET `codice`=`id` WHERE `codice` IS NULL; 

-- Aggiunta vista Inviato in Scadenzario
UPDATE `zz_modules` SET `options` = 'SELECT |select| FROM `co_scadenziario`\nLEFT JOIN `co_documenti` ON `co_scadenziario`.`iddocumento` = `co_documenti`.`id`\nLEFT JOIN `an_anagrafiche` ON `co_documenti`.`idanagrafica` = `an_anagrafiche`.`idanagrafica`\nLEFT JOIN `co_pagamenti` ON `co_documenti`.`idpagamento` = `co_pagamenti`.`id`\nLEFT JOIN `co_tipidocumento` ON `co_documenti`.`idtipodocumento` = `co_tipidocumento`.`id`\nLEFT JOIN `co_statidocumento` ON `co_documenti`.`idstatodocumento` = `co_statidocumento`.`id`\nLEFT JOIN (\n         SELECT `zz_operations`.`id_email`, `zz_operations`.`id_record`\n         FROM `zz_operations`\n                INNER JOIN `em_emails` ON `zz_operations`.`id_email` = `em_emails`.`id`\n                INNER JOIN `em_templates` ON `em_emails`.`id_template` = `em_templates`.`id`\n                INNER JOIN `zz_modules` ON `zz_operations`.`id_module` = `zz_modules`.`id`\n         WHERE `zz_modules`.`name` = ''Scadenzario'' AND `zz_operations`.`op` = ''send-email''\n         GROUP BY `zz_operations`.`id_record`\n     ) AS `email` ON `email`.`id_record` = `co_scadenziario`.`id`\nWHERE 1=1 AND\n(`co_statidocumento`.`descrizione` IS NULL OR `co_statidocumento`.`descrizione` IN(''Emessa'',''Parzialmente pagato'',''Pagato''))\nHAVING 2=2\nORDER BY `scadenza` ASC' WHERE `zz_modules`.`name` = 'Scadenzario';

INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name` = 'Scadenzario'), 'icon_Inviato', 'IF(`email`.`id_email` IS NOT NULL, ''fa fa-envelope text-success'', '''')', 16, 1, 0, 0, '', '', 1, 0, 1),
((SELECT `id` FROM `zz_modules` WHERE `name` = 'Scadenzario'), 'icon_title_Inviato', 'IF(`email`.`id_email` IS NOT NULL, ''Inviato'', '''')', 17, 1, 0, 0, '', '', 0, 0, 1);

-- Set tipo intervento tempo_standard = 1
UPDATE `in_tipiintervento` SET `tempo_standard` = '1' WHERE `in_tipiintervento`.`tempo_standard` = 0 OR `in_tipiintervento`.`tempo_standard` IS NULL; 

-- Aggiunto campo Barcode fornitore
ALTER TABLE `mg_fornitore_articolo` ADD `barcode_fornitore` VARCHAR(255) NOT NULL AFTER `codice_fornitore`; 

-- Aggiunta impostazione per scegliere colore sessioni dashboard
INSERT INTO `zz_settings` (`id`, `nome`, `valore`, `tipo`, `editable`, `sezione`, `order`, `help`) VALUES (NULL, 'Visualizzazione colori sessioni', 'Sfondo colore stato - bordo colore tecnico', 'list[Sfondo colore stato - bordo colore tecnico,Sfondo colore tecnico - bordo colore stato]', '1', 'Dashboard', '7', '');

-- Aggiunta impostazione per riportare nei documenti tutti i riferimenti collegati
INSERT INTO `zz_settings` (`id`, `nome`, `valore`, `tipo`, `editable`, `sezione`, `order`, `help`) VALUES (NULL, 'Mantieni riferimenti tra tutti i documenti collegati', '1', 'boolean', '1', 'Generali', '19', 'Permette l''aggiunta dei riferimenti di tutti i documenti collegati');

-- Aggiunta colonna Codice in Anagrafiche
INSERT INTO `zz_views` (`id`, `id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Anagrafiche'), 'Codice', 'an_anagrafiche.codice', 1, 1, 0, 0, '', '', 0, 0, 1);

-- Aggiunta opzione formattazione HTML nelle viste per la gestione dei campi CKeditor
ALTER TABLE `zz_views` ADD `html_format` TINYINT NOT NULL DEFAULT '1' AFTER `format`; 
UPDATE `zz_views` SET `html_format` = '1'; 