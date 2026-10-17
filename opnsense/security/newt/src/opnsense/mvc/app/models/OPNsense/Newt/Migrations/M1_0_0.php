<?php

/*
 * Copyright (c) 2026, Söhnke <mail@soehnke.de>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

namespace OPNsense\Newt\Migrations;

use OPNsense\Base\BaseModelMigration;
use OPNsense\Core\Syslog;
use OPNsense\Newt\Newt;

// phpcs:ignore Squiz.Classes.ValidClassName.NotCamelCaps -- OPNsense migration class naming convention.
class M1_0_0 extends BaseModelMigration
{
    public function run($model)
    {
        parent::run($model);
        if (!$model instanceof Newt || $model->general->siteId->isSet()) {
            return;
        }
        $path = '/usr/local/etc/newt/config.json';
        if (!is_readable($path)) {
            return;
        }
        $legacy = json_decode(file_get_contents($path), true);
        if (!is_array($legacy) || empty($legacy['id']) || empty($legacy['secret']) || empty($legacy['endpoint'])) {
            return;
        }
        $mapping = ['endpoint' => 'endpoint', 'siteId' => 'id', 'secret' => 'secret',
            'logLevel' => 'logLevel', 'mtu' => 'mtu', 'port' => 'port', 'dns' => 'dns'];
        $previous = [];
        foreach ($mapping as $field => $key) {
            $previous[$field] = (string)$model->general->$field;
            if (isset($legacy[$key]) && is_scalar($legacy[$key])) {
                $model->general->$field = (string)$legacy[$key];
            }
        }
        $previous['enabled'] = (string)$model->general->enabled;
        $rcFile = '/etc/rc.conf.d/newt';
        $rc = is_readable($rcFile) ? file_get_contents($rcFile) : '';
        $model->general->enabled = preg_match('/newt_enable=["\x27]?YES/i', $rc) ? '1' : '0';
        if (count($model->performValidation(true))) {
            foreach ($previous as $field => $value) {
                $model->general->$field = $value;
            }
            (new Syslog('newt'))->warning('Legacy Newt settings failed validation and were not imported.');
        }
    }
}
