<?php
/*
 * OpenSTAManager: il software gestionale open source per l'assistenza tecnica e la fatturazione
 * Copyright (C) DevCode s.n.c.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

include_once __DIR__.'/init.php';

echo '
<div class="table-responsive">
    <table class="table table-striped table-hover table-condensed table-bordered">
        <thead>
            <tr>
                <th width="35" class="text-center" >'.tr('#').'</th>
                <th>'.tr('Descrizione').'</th>
                <th width="120">'.tr('Prev. evasione').'</th>
                <th class="text-center tip" width="150" title="'.tr('da evadere').' / '.tr('totale').'">'.tr('Q.tà').' <i class="fa fa-question-circle-o"></i></th>
                <th class="text-center" width="150">'.tr('Prezzo unitario').'</th>
                <th class="text-center" width="150">'.tr('Iva unitaria').'</th>
                <th class="text-center" width="150">'.tr('Importo').'</th>
                <th width="60"></th>
            </tr>
        </thead>

        <tbody class="sortable">';

// Righe documento
$today = new Carbon\Carbon();
$today = $today->startOfDay();
$righe = $ordine->getRighe();
$num = 0;
foreach ($righe as $riga) {
    ++$num;

    $extra = '';
    $mancanti = 0;

    // Individuazione dei seriali
    if ($riga->isArticolo() && !empty($riga->abilita_serial)) {
        $serials = $riga->serials;
        $mancanti = abs($riga->qta) - count($serials);

        if ($mancanti > 0) {
            $extra = 'class="warning"';
        } else {
            $mancanti = 0;
        }
    }

    echo '
        <tr data-id="'.$riga->id.'" data-type="'.get_class($riga).'" '.$extra.'>
            <td class="text-center">
                '.$num.'
            </td>

            <td>';

    // Aggiunta dei riferimenti ai documenti
    if ($riga->hasOriginalComponent()) {
        echo '
                <small class="pull-right text-right text-muted">'.reference($riga->getOriginalComponent()->getDocument(), tr('Origine')).'</small>';
    }

    if ($riga->isArticolo()) {
        echo Modules::link('Articoli', $riga->idarticolo, $riga->codice.' - '.$riga->descrizione);
    } else {
        echo nl2br($riga->descrizione);
    }

    if ($riga->isArticolo() && !empty($riga->abilita_serial)) {
        if (!empty($mancanti)) {
            echo '
                <br><b><small class="text-danger">'.tr('_NUM_ serial mancanti', [
                    '_NUM_' => $mancanti,
                ]).'</small></b>';
        }
        if (!empty($serials)) {
            echo '
                <br>'.tr('SN').': '.implode(', ', $serials);
        }
    }

    echo '
            </td>';

    // Data prevista evasione
    $info_evasione = '';
    if (!empty($riga->data_evasione)) {
        $evasione = new Carbon\Carbon($riga->data_evasione);
        if ($today->diffInDays($evasione, false) < 0) {
            $evasione_icon = 'fa fa-warning text-danger';
            $evasione_help = tr('Da consegnare _NUM_ giorni fa',
                [
                    '_NUM_' => $today->diffInDays($evasione),
                ]
            );
        } elseif ($today->diffInDays($evasione, false) == 0) {
            $evasione_icon = 'fa fa-clock-o text-warning';
            $evasione_help = tr('Da consegnare oggi');
        } else {
            $evasione_icon = 'fa fa-check text-success';
            $evasione_help = tr('Da consegnare fra _NUM_ giorni',
                [
                    '_NUM_' => $today->diffInDays($evasione),
                ]
            );
        }

        $info_evasione = '<span class="tip" title="'.$evasione_help.'"><i class="'.$evasione_icon.'"></i> '.Translator::dateToLocale($riga->data_evasione).'</span>';
    }

    echo '
        <td class="text-center">
            '.$info_evasione.'
        </td>';

    if ($riga->isDescrizione()) {
        echo '
                <td></td>
                <td></td>
                <td></td>
                <td></td>';
    } else {
        // Quantità e unità di misura
        echo '
            <td class="text-center">
                <i class="'.($riga->confermato ? 'fa fa-check text-success' : 'fa fa-clock-o text-warning').'"></i> 
                '.numberFormat($riga->qta_rimanente, 'qta').' / '.numberFormat($riga->qta, 'qta').' '.$riga->um.'
            </td>';

        // Prezzi unitari
        echo '
            <td class="text-right">
                '.moneyFormat($riga->prezzo_unitario_corrente);

        if ($dir == 'entrata' && $riga->costo_unitario != 0) {
            echo '
                <br><small class="text-muted">
                    '.tr('Acquisto').': '.moneyFormat($riga->costo_unitario).'
                </small>';
        }

        if (abs($riga->sconto_unitario) > 0) {
            $text = discountInfo($riga);

            echo '
                <br><small class="label label-danger">'.$text.'</small>';
        }

        echo '
            </td>';

        // Iva
        echo '
            <td class="text-right">
                '.moneyFormat($riga->iva_unitaria).'
                <br><small class="'.(($riga->aliquota->deleted_at) ? 'text-red' : '').' text-muted">'.$riga->aliquota->descrizione.(($riga->aliquota->esente) ? ' ('.$riga->aliquota->codice_natura_fe.')' : null).'</small>
            </td>';

        // Importo
        echo '
            <td class="text-right">
                '.moneyFormat($riga->importo).'
            </td>';
    }

    // Possibilità di rimuovere una riga solo se l'ordine non è evaso
    echo '
            <td class="text-center">';

    if ($record['flag_completato'] == 0) {
        echo '
                <div class="input-group-btn">';

        if ($riga->isArticolo() && !empty($riga->abilita_serial)) {
            echo '
                    <a class="btn btn-primary btn-xs" title="'.tr('Modifica seriali della riga').'" onclick="modificaSeriali(this)">
                        <i class="fa fa-barcode"></i>
                    </a>';
        }

        echo '
                    <a class="btn btn-xs btn-warning" title="'.tr('Modifica riga').'" onclick="modificaRiga(this)">
                        <i class="fa fa-edit"></i>
                    </a>

                    <a class="btn btn-xs btn-danger" title="'.tr('Rimuovi riga').'" onclick="rimuoviRiga(this)">
                        <i class="fa fa-trash"></i>
                    </a>

                    <a class="btn btn-xs btn-default handle" title="'.tr('Modifica ordine delle righe').'">
                        <i class="fa fa-sort"></i>
                    </a>
                </div>';
    }

    echo '
            </td>
        </tr>';
}

echo '
        </tbody>';

// Calcoli
$imponibile = abs($ordine->imponibile);
$sconto = $ordine->sconto;
$totale_imponibile = abs($ordine->totale_imponibile);
$iva = abs($ordine->iva);
$totale = abs($ordine->totale);

// IMPONIBILE
echo '
        <tr>
            <td colspan="6" class="text-right">
                <b>'.tr('Imponibile', [], ['upper' => true]).':</b>
            </td>
            <td class="text-right">
                '.moneyFormat($imponibile, 2).'
            </td>
            <td></td>
        </tr>';

// SCONTO
if (!empty($sconto)) {
    echo '
        <tr>
            <td colspan="6" class="text-right">
                <b><span class="tip" title="'.tr('Un importo positivo indica uno sconto, mentre uno negativo indica una maggiorazione').'"> <i class="fa fa-question-circle-o"></i> '.tr('Sconto/maggiorazione', [], ['upper' => true]).':</span></b>
            </td>
            <td class="text-right">
                '.moneyFormat($sconto, 2).'
            </td>
            <td></td>
        </tr>';

    // TOTALE IMPONIBILE
    echo '
        <tr>
            <td colspan="6" class="text-right">
                <b>'.tr('Totale imponibile', [], ['upper' => true]).':</b>
            </td>
            <td class="text-right">
                '.moneyFormat($totale_imponibile, 2).'
            </td>
            <td></td>
        </tr>';
}

// IVA
echo '
        <tr>
            <td colspan="6" class="text-right">
                <b>'.tr('Iva', [], ['upper' => true]).':</b>
            </td>
            <td class="text-right">
                '.moneyFormat($iva, 2).'
            </td>
            <td></td>
        </tr>';

// TOTALE
echo '
        <tr>
            <td colspan="6" class="text-right">
                <b>'.tr('Totale', [], ['upper' => true]).':</b>
            </td>
            <td class="text-right">
                '.moneyFormat($totale, 2).'
            </td>
            <td></td>
        </tr>';

echo '
    </table>
</div>';

echo '
<script>
async function modificaRiga(button) {
    let riga = $(button).closest("tr");
    let id = riga.data("id");
    let type = riga.data("type");

    // Salvataggio via AJAX
    let valid = await salvaForm(button, $("#edit-form"));

    if (valid) {
        // Chiusura tooltip
        if ($(button).hasClass("tooltipstered"))
            $(button).tooltipster("close");

        // Apertura modal
        openModal("'.tr('Modifica riga').'", "'.$module->fileurl('row-edit.php').'?id_module=" + globals.id_module + "&id_record=" + globals.id_record + "&riga_id=" + id + "&riga_type=" + type);
    }
}

function rimuoviRiga(button) {
    swal({
        title: "'.tr('Rimuovere questa riga?').'",
        html: "'.tr('Sei sicuro di volere rimuovere questa riga dal documento?').' '.tr("L'operazione è irreversibile").'.",
        type: "warning",
        showCancelButton: true,
        confirmButtonText: "'.tr('Sì').'"
    }).then(function () {
        let riga = $(button).closest("tr");
        let id = riga.data("id");
        let type = riga.data("type");

        $.ajax({
            url: globals.rootdir + "/actions.php",
            type: "POST",
            dataType: "json",
            data: {
                id_module: globals.id_module,
                id_record: globals.id_record,
                op: "delete_riga",
                riga_type: type,
                riga_id: id,
            },
            success: function (response) {
                location.reload();
            },
            error: function() {
                location.reload();
            }
        });
    }).catch(swal.noop);
}

function modificaSeriali(button) {
    let riga = $(button).closest("tr");
    let id = riga.data("id");
    let type = riga.data("type");

    openModal("'.tr('Aggiorna SN').'", globals.rootdir + "/modules/fatture/add_serial.php?id_module=" + globals.id_module + "&id_record=" + globals.id_record + "&riga_id=" + id + "&riga_type=" + type);
}

$(document).ready(function() {
	$(".sortable").each(function() {
        $(this).sortable({
            axis: "y",
            handle: ".handle",
			cursor: "move",
			dropOnEmpty: true,
			scroll: true,
			update: function(event, ui) {
                let order = $(".table tr[data-id]").toArray().map(a => $(a).data("id"))

				$.post(globals.rootdir + "/actions.php", {
					id: ui.item.data("id"),
					id_module: '.$id_module.',
					id_record: '.$id_record.',
					op: "update_position",
                    order: order.join(","),
				});
			}
		});
	});
});
</script>';
