-- Miglioramento supporto autenticazione OAuth 2
ALTER TABLE `em_accounts` ADD `oauth2_config` TEXT;

-- Aggiunto sistema di gestione Combinazioni Articoli
CREATE TABLE IF NOT EXISTS `mg_attributi` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `nome` varchar(255) NOT NULL,
    `titolo` varchar(255) NOT NULL,
    `ordine` int(11) NOT NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY(`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mg_valori_attributi` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `id_attributo` int(11) NOT NULL,
    `nome` varchar(255) NOT NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY(`id`),
    FOREIGN KEY (`id_attributo`) REFERENCES `mg_attributi`(`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mg_combinazioni` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `codice` varchar(255) NOT NULL,
    `nome` varchar(255) NOT NULL,
    `id_categoria` int(11),
    `id_sottocategoria` int(11),
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY(`id`),
    FOREIGN KEY (`id_categoria`) REFERENCES `mg_categorie`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`id_sottocategoria`) REFERENCES `mg_categorie`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mg_attributo_combinazione` (
    `id_combinazione` int(11) NOT NULL,
    `id_attributo` int(11) NOT NULL,
    `order` int(11) NOT NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(`id_attributo`, `id_combinazione`),
    FOREIGN KEY (`id_attributo`) REFERENCES `mg_attributi`(`id`),
    FOREIGN KEY (`id_combinazione`) REFERENCES `mg_combinazioni`(`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mg_articolo_attributo` (
    `id_articolo` int(11) NOT NULL,
    `id_valore` int(11) NOT NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(`id_articolo`, `id_valore`),
    FOREIGN KEY (`id_articolo`) REFERENCES `mg_articoli`(`id`),
    FOREIGN KEY (`id_valore`) REFERENCES `mg_valori_attributi`(`id`)
) ENGINE=InnoDB;

ALTER TABLE mg_articoli ADD `id_combinazione` int(11), ADD FOREIGN KEY (`id_combinazione`) REFERENCES `mg_combinazioni`(`id`);

INSERT INTO `zz_modules` (`id`, `name`, `title`, `directory`, `options`, `options2`, `icon`, `version`, `compatibility`, `order`, `parent`, `default`, `enabled`) VALUES
(NULL, 'Attributi Combinazioni', 'Attributi Combinazioni', 'attributi_combinazioni', 'SELECT |select| FROM mg_attributi WHERE mg_attributi.deleted_at IS NULL AND 1=1 HAVING 2=2', NULL, 'fa fa-angle-right', '1.0', '2.*', '100', '20', '1', '1'),
(NULL, 'Combinazioni', 'Combinazioni', 'combinazioni_articoli', 'SELECT |select| FROM mg_combinazioni WHERE mg_combinazioni.deleted_at IS NULL AND 1=1 HAVING 2=2', NULL, 'fa fa-angle-right', '1.0', '2.*', '100', '20', '1', '1');

INSERT INTO `zz_plugins` (`id`, `name`, `title`, `idmodule_from`, `idmodule_to`, `position`, `directory`, `options`) VALUES
(NULL, 'Varianti Articolo', 'Varianti Articolo', (SELECT `id` FROM `zz_modules` WHERE `name`='Articoli'), (SELECT `id` FROM `zz_modules` WHERE `name`='Articoli'), 'tab', 'varianti_articolo', 'custom');

-- Aggiunta colonne per il nuovo modulo Attributi Combinazioni
INSERT INTO `zz_views` (`id`, `id_module`, `name`, `query`, `order`, `visible`, `format`, `default`) VALUES
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Attributi Combinazioni'), 'id', 'mg_attributi.id', 1, 0, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Attributi Combinazioni'), 'Nome', 'mg_attributi.nome', 2, 1, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Combinazioni'), 'id', 'mg_combinazioni.id', 1, 0, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Combinazioni'), 'Nome', 'mg_combinazioni.nome', 2, 1, 0, 1);

-- Introduzione della Banca nelle tabelle Fatture
INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name` = 'Fatture di vendita'), 'Banca', '(SELECT CONCAT(co_banche.nome, '' - '' , co_banche.iban) AS descrizione FROM co_banche WHERE co_banche.id = id_banca_azienda)', 6, 1, 0, 1),
((SELECT `id` FROM `zz_modules` WHERE `name` = 'Fatture di acquisto'), 'Banca',
'(SELECT CONCAT(co_banche.nome, '' - '' , co_banche.iban) FROM co_banche WHERE co_banche.id = id_banca_azienda)', 6, 1, 0, 1);