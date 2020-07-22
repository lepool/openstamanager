<?php

namespace Modules\Interventi\API\AppV1;

use API\AppResource;
use Auth;
use Carbon\Carbon;
use Modules\Interventi\Components\Articolo;
use Modules\Interventi\Components\Riga;
use Modules\Interventi\Components\Sconto;
use Modules\Interventi\Intervento;

class Righe extends AppResource
{
    protected function getCleanupData()
    {
        // Periodo per selezionare interventi
        $today = new Carbon();
        $start = $today->copy()->subMonths(2);
        $end = $today->copy()->addMonth(1);

        // Informazioni sull'utente
        $user = Auth::user();
        $id_tecnico = $user->id_anagrafica;

        $query = 'SELECT in_righe_interventi.id FROM in_righe_interventi WHERE in_righe_interventi.idintervento IN (
            SELECT in_interventi.id FROM in_interventi WHERE
            deleted_at IS NOT NULL
            OR EXISTS(
                SELECT orario_fine FROM in_interventi_tecnici WHERE
                    in_interventi_tecnici.idintervento = in_interventi.id
                    AND orario_fine NOT BETWEEN :period_start AND :period_end
                    AND idtecnico = :id_tecnico
            )
        )';
        $records = database()->fetchArray($query, [
            ':period_end' => $end,
            ':period_start' => $start,
            ':id_tecnico' => $id_tecnico,
        ]);

        $da_interventi = array_column($records, 'id');
        $mancanti = $this->getMissingIDs('in_righe_interventi', 'id');

        $results = array_unique(array_merge($da_interventi, $mancanti));

        return $results;
    }

    protected function getData($last_sync_at)
    {
        // Periodo per selezionare interventi
        $today = new Carbon();
        $start = $today->copy()->subMonths(2);
        $end = $today->copy()->addMonth(1);

        // Informazioni sull'utente
        $user = Auth::user();
        $id_tecnico = $user->id_anagrafica;

        $query = 'SELECT in_righe_interventi.id FROM in_righe_interventi WHERE in_righe_interventi.idintervento IN (
            SELECT in_interventi.id FROM in_interventi WHERE
            in_interventi.id IN (
                SELECT idintervento FROM in_interventi_tecnici
                WHERE in_interventi_tecnici.idintervento = in_interventi.id
                    AND in_interventi_tecnici.orario_fine BETWEEN :period_start AND :period_end
                    AND in_interventi_tecnici.idtecnico = :id_tecnico
            )
            AND deleted_at IS NULL
        )';

        // Filtro per data
        if ($last_sync_at) {
            $last_sync = new Carbon($last_sync_at);
            $query .= ' AND in_righe_interventi.updated_at > '.prepare($last_sync);
        }
        $records = database()->fetchArray($query, [
            ':period_start' => $start,
            ':period_end' => $end,
            ':id_tecnico' => $id_tecnico,
        ]);

        return array_column($records, 'id');
    }

    protected function getDetails($id)
    {
        // Gestione della visualizzazione dei dettagli del record
        $dati = database()->fetchOne('SELECT idintervento AS id_intervento,
           idarticolo AS id_articolo,
           is_descrizione,
           is_sconto
        FROM in_righe_interventi WHERE in_righe_interventi.id = '.prepare($id));

        // Individuazione riga tramite classi
        if (!empty($dati['is_sconto'])) {
            $type = Sconto::class;
        } elseif (!empty($dati['id_articolo'])) {
            $type = Articolo::class;
        } else {
            $type = Riga::class;
        }
        $intervento = Intervento::find($dati['id_intervento']);
        $riga = $intervento->getRiga($type, $id);

        // Generazione del record ristretto ai campi di interesse
        $record = [
            'id' => $riga->id,
            'id_intervento' => $riga->idintervento,
            'descrizione' => $riga->descrizione,
            'qta' => $riga->qta,
            'um' => $riga->um,
            'ordine' => $riga->order,

            // Caratteristiche della riga
            'id_articolo' => $riga->idarticolo,
            'is_articolo' => intval($riga->isArticolo()),
            'is_riga' => intval($riga->isRiga()),
            'is_descrizione' => intval($riga->isDescrizione()),
            'is_sconto' => intval($riga->isSconto()),

            // Campi contabili
            'costo_unitario' => $riga->costo_unitario,
            'prezzo_unitario' => $riga->prezzo_unitario,
            'tipo_sconto' => $riga->tipo_sconto,
            'sconto_percentuale' => $riga->sconto_percentuale,
            'sconto_unitario' => $riga->sconto_unitario,
            'id_iva' => $riga->idiva,
            'iva_unitaria' => $riga->iva_unitaria,
            'prezzo_unitario_ivato' => $riga->prezzo_unitario_ivato,
            'sconto_iva_unitario' => $riga->sconto_iva_unitario,
            'sconto_unitario_ivato' => $riga->sconto_unitario_ivato,

            // Campi contabili di riepilogo
            'imponibile' => $riga->imponibile,
            'sconto' => $riga->sconto,
            'totale_imponibile' => $riga->totale_imponibile,
            'iva' => $riga->iva,
            'totale' => $riga->totale,
        ];

        return $record;
    }
}
