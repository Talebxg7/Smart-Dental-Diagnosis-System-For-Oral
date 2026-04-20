<?php
/**
 * Simple class autoloader (no Composer) – maps classes to files.
 */
declare(strict_types=1);

spl_autoload_register(function (string $class): void {
    $root = __DIR__;
    $map = [
        'Config\\Database' => $root . '/config/database.php',
        'Models\\User' => $root . '/models/User.php',
        'Models\\Report' => $root . '/models/Report.php',
        'Models\\ReportMessage' => $root . '/models/ReportMessage.php',
        'Utils\\Response' => $root . '/utils/Response.php',
        'Utils\\Validator' => $root . '/utils/Validator.php',
        'Utils\\AdminAuth' => $root . '/utils/AdminAuth.php',
    ];
    if (isset($map[$class])) {
        require_once $map[$class];
    }
});
