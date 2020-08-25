<?php

// File e cartelle deprecate
$files = [
    'plugins/fornitori_articolo',
];

foreach ($files as $key => $value) {
    $files[$key] = realpath(DOCROOT.'/'.$value);
}

delete($files);

/* Porting modifica UNIQUE con riduzione dei campi per versioni di MySQL < 5.7 */
// Riduzione lunghezza campo nome zz_settings per problema compatibilità mysql 5.6 con UNIQUE
$impostazioni = $database->fetchArray('SELECT `nome`, COUNT(`nome`) AS numero_duplicati FROM `zz_settings` GROUP BY `nome` HAVING COUNT(`nome`) > 1');
foreach ($impostazioni as $impostazione) {
    $limit = intval($impostazione['numero_duplicati']) - 1;

    $database->query('DELETE FROM `zz_settings` WHERE `nome` = '.prepare($impostazione['nome']).' LIMIT '.$limit);
}
$database->query('ALTER TABLE `zz_settings` CHANGE `nome` `nome` VARCHAR(150) NOT NULL');
$database->query('ALTER TABLE `zz_settings` ADD UNIQUE(`nome`)');

// Riduzione lunghezza campo username zz_users per problema compatibilità mysql 5.6 con UNIQUE
$database->query('ALTER TABLE `zz_users` CHANGE `username` `username` VARCHAR(150) NOT NULL');
$database->query('ALTER TABLE `zz_users` ADD UNIQUE(`username`)');
