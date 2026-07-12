<?php
/**
 * NOTFALL-Script: Admin-Passwort zurücksetzen
 * Nach Gebrauch LÖSCHEN!
 *
 * Aufruf: https://timm-sander.net/sws/api/_reset_admin.php?email=DEINE@EMAIL.DE&pass=NEUESPASSWORT
 */

declare(strict_types=1);

$email = trim($_GET['email'] ?? '');
$pass  = trim($_GET['pass']  ?? '');

if ($email === '' || $pass === '') {
    http_response_code(400);
    die('?email=...&pass=... erforderlich');
}
if (strlen($pass) < 8) {
    http_response_code(400);
    die('Passwort mindestens 8 Zeichen');
}

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/db.php';

$pdo = getDb();

// Prüfen ob User existiert
$stmt = $pdo->prepare('SELECT id, role FROM users WHERE email = ?');
$stmt->execute([$email]);
$user = $stmt->fetch();

$hash = password_hash($pass, PASSWORD_BCRYPT);

if ($user) {
    $pdo->prepare('UPDATE users SET password = ?, role = ? WHERE id = ?')
        ->execute([$hash, 'admin', $user['id']]);
    echo "OK – Passwort für {$email} aktualisiert, Rolle auf admin gesetzt.\n";
} else {
    $pdo->prepare('INSERT INTO users (email, password, role) VALUES (?, ?, ?)')
        ->execute([$email, $hash, 'admin']);
    echo "OK – Admin {$email} angelegt.\n";
}

echo "\nDu kannst dich jetzt unter https://timm-sander.net/sws/api/ einloggen.\n";
echo "Benutzername (E-Mail): {$email}\n";
echo "Passwort: das eben vergebene\n";
