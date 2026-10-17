<?php

use OPNsense\Core\Backend;

function newt_services()
{
    return [[
        'name' => 'newt',
        'description' => gettext('Pangolin Newt'),
        'pidfile' => '/var/run/newt.pid',
        'configd' => [
            'start' => ['newt start'],
            'stop' => ['newt stop'],
            'restart' => ['newt restart'],
        ],
    ]];
}

function newt_configure()
{
    return ['bootup' => ['newt_configure_bootup']];
}

function newt_configure_bootup($verbose = false)
{
    // Runtime files may have been cleared during an upgrade or restoration.
    (new Backend())->configdRun('template reload OPNsense/Newt');
}
