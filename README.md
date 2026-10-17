# os-newt – Pangolin Newt für OPNsense

Lokales Plugin mit WebUI unter **VPN → Pangolin Newt → Settings**, Start-/Stopp-/Neustart-Steuerung und Eintrag in der OPNsense-Dienstübersicht. Enthält das offizielle Newt 1.18.1 für FreeBSD. Dies ist ein eigenes Plugin, kein offizielles Paket von OPNsense oder Pangolin.

## Funktionen

- Aktivierung und Autostart; HTTPS-Endpunkt, Site-ID und verdecktes Site-Secret.
- Log-Level sowie erweiterte Einstellungen für MTU, festen UDP-Port und DNS-Server.
- „Apply“ speichert die Einstellungen und startet den Dienst mit der neuen Konfiguration.
- Speichern im regulären OPNsense-Konfigurationsmodell: Zugangsdaten sind damit auch in config.xml-Sicherungen enthalten.
- Laufzeit-Konfiguration nur für root lesbar; JSON-Escaping im Template; keine Site-Secrets in Prozessargumenten.
- Dienst-Supervisor startet Newt nach einem Absturz neu. Der Status bestätigt den laufenden Prozess; den Tunnelstatus zeigt Pangolin.
- Eigene Logansicht unter VPN → Pangolin Newt → Log File.
- Übernahme einer bestehenden Konfiguration aus `/usr/local/etc/newt/config.json`, sofern noch keine Plugin-Einstellungen existieren. Vorhandene Plugin-Einstellungen werden bei Neuinstallation beibehalten.

LANs und Zugriffsrechte werden weiterhin in Pangolin konfiguriert.

## Paket bauen

Den Quellordner auf die passende OPNsense übertragen und dort ausführen:

```sh
sh build.sh
```

Der Build lädt das offizielle Binary mit fest hinterlegter SHA-256-Prüfsumme. Das Paket unter `dist/` ist für die FreeBSD-/OPNsense-Version des Buildsystems bestimmt. Es enthält keine standortspezifischen Zugangsdaten.

Vor der Erstinstallation die Firewall-Konfiguration sowie eine bestehende Newt-Installation sichern. Installation als root:

```sh
pkg add ./dist/os-newt-1.0.pkg
```

Die Installation übernimmt die bestehende Konfiguration und startet Newt kurz neu. Die WebUI danach neu laden. Das Paket erscheint auch in der installierten Plugin-Liste; Updates kommen als neue lokale Pakete, nicht aus dem offiziellen Repository.

## Verwaltung

```sh
configctl newt status
configctl newt restart
service newt status
```

Deinstallation über die Plugin-Verwaltung oder `pkg delete os-newt` stoppt Newt und entfernt Programm, Integration und erzeugte Laufzeitdateien. Die gespeicherten Einstellungen bleiben in config.xml erhalten, damit eine Neuinstallation sie übernehmen kann.

## Prüfung

`tests/model.php` prüft gültige und ungültige Eingaben mit dem OPNsense-Modell, ohne Konfiguration zu speichern. `tests/templates.py` prüft JSON-Escaping, optionale Felder und Aktivierung. Die Integration wird zusätzlich auf der Ziel-Firewall über die echten WebUI-/API-Endpunkte geprüft.

## Quellen und Lizenzen

Plugin-Code: BSD-2-Clause, siehe LICENSE. Newt: AGPLv3; der Build legt dessen Lizenz unter `/usr/local/share/doc/os-newt/LICENSE.newt` ab.

- Newt-Binary und zugehöriger Quellcode: https://github.com/fosrl/newt/releases/tag/1.18.1
- Newt-Quellarchiv: https://github.com/fosrl/newt/archive/refs/tags/1.18.1.tar.gz
- OPNsense MVC: https://docs.opnsense.org/development/examples/helloworld.html
- Dienstintegration: https://docs.opnsense.org/development/examples/api_enable_services.html
