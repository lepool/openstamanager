<?php
/*
 * OpenSTAManager: il software gestionale open source per l'assistenza tecnica e la fatturazione
 * Copyright (C) DevCode s.r.l.
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

namespace Modules\Newsletter;

use Common\SimpleModelTrait;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Models\User;
use Modules\Anagrafiche\Anagrafica;
use Modules\Anagrafiche\Referente;
use Modules\Anagrafiche\Sede;
use Modules\Emails\Account;
use Modules\Emails\Mail;
use Modules\Emails\Template;
use Traits\RecordTrait;

class Newsletter extends Model
{
    use SimpleModelTrait;
    use SoftDeletes;
    use RecordTrait;

    protected $table = 'em_newsletters';

    public static function build(User $user, Template $template, $name)
    {
        $model = new static();

        $model->user()->associate($user);
        $model->template()->associate($template);
        $model->name = $name;

        $model->subject = $template->subject;
        $model->content = $template->body;

        $model->state = 'DEV';

        $model->save();

        return $model;
    }

    /**
     * Restituisce il nome del modulo a cui l'oggetto è collegato.
     *
     * @return string
     */
    public function getModuleAttribute()
    {
        return 'Newsletter';
    }

    public function fixStato()
    {
        $mails = $this->emails;

        $completed = true;
        foreach ($mails as $mail) {
            if (empty($mail->sent_at)) {
                $completed = false;
                break;
            }
        }

        $this->state = $completed ? 'OK' : $this->state;
        $this->completed_at = $completed ? date('Y-m-d H:i:s') : $this->completed_at;
        $this->save();
    }

    // Relazione Eloquent

    public function getDestinatari()
    {
        return $this->anagrafiche
            ->concat($this->sedi)
            ->concat($this->referenti);
    }

    public function anagrafiche()
    {
        return $this
            ->belongsToMany(Anagrafica::class, 'em_newsletter_receiver', 'id_newsletter', 'record_id')
            ->where('record_type', '=', Anagrafica::class)
            ->withPivot('id_email')
            ->orderByRaw('IF(email=\'\',email,enable_newsletter) ASC')
            ->orderBy('ragione_sociale', 'ASC')
            ->withTrashed();
    }

    public function sedi()
    {
        return $this
            ->belongsToMany(Sede::class, 'em_newsletter_receiver', 'id_newsletter', 'record_id')
            ->where('record_type', '=', Sede::class)
            ->withPivot('id_email');
    }

    public function referenti()
    {
        return $this
            ->belongsToMany(Referente::class, 'em_newsletter_receiver', 'id_newsletter', 'record_id')
            ->where('record_type', '=', Referente::class)
            ->withPivot('id_email');
    }

    public function emails()
    {
        return $this->belongsToMany(Mail::class, 'em_newsletter_receiver', 'id_newsletter', 'id_email')->withPivot('id_anagrafica');
    }

    public function account()
    {
        return $this->belongsTo(Account::class, 'id_account');
    }

    public function template()
    {
        return $this->belongsTo(Template::class, 'id_template');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
