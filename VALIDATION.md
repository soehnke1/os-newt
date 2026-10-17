# Validierung

Zielsystem: OPNsense 26.7.6_3, FreeBSD 15.1-RELEASE-p4, amd64.

- PHP-Syntax, XML und Shell-Syntax geprüft.
- OPNsense-Modell akzeptiert gültige Einstellungen und optionale leere Felder; lehnt HTTP-Endpunkte, ungültige Site-IDs, MTUs, Ports und DNS-Adressen ab.
- JSON-Template erhält Sonderzeichen in Secrets korrekt und erzeugt typisierte MTU-/Port-Werte.
- Installation übernimmt bestehende Site-Zugangsdaten ohne deren Ausgabe.
- Konfigurationsseite wird über `/ui/newt/` authentifiziert erfolgreich gerendert; Secret wird als Passwortfeld ausgegeben.
- Echte authentifizierte WebUI-API geprüft: Einstellungen lesen/speichern, ungültige MTU ablehnen, Änderungen anwenden, Start, Stopp, Deaktivierung und erneute Aktivierung.
- Die OPNsense-Dienstübersicht liefert `newt` als laufenden Dienst mit Beschreibung „Pangolin Newt“.
- Laufzeit-Konfiguration besitzt Eigentümer root und Modus 0600; Logdatei wird separat unter `/var/log/newt` angelegt.
- Nach den Tests sind Aktivierung und INFO-Protokollierung wiederhergestellt. Die Site-Zugangsdaten bleiben identisch.

Ein vollständiger Firewall-Neustart wurde nicht ausgeführt. Die bestehenden OPNsense-Formular- und Dienst-Widgets werden verwendet; die HTTP-/API-Integration ist geprüft, es wurde kein automatisierter Browser-Klicktest ausgeführt.
