# Installation und Funktionstest

Diese Anleitung beschreibt den manuellen Test von **v1.1-rc1**. Die Pakete wurden für OPNsense **26.7.6_3 / FreeBSD 15.1 / amd64** gebaut. Installation, Upgrade, Entfernen, Neustart und Client-Zugriff des Kandidaten sind noch zu prüfen; siehe [VALIDATION.md](../VALIDATION.md). Die Pakete sind noch keine offizielle OPNsense-Veröffentlichung. Den ersten Test auf einer entbehrlichen OPNsense-VM durchführen.

## 1. Pakete bereitstellen

Aus dem [Release v1.1-rc1](https://github.com/soehnke1/os-newt/releases/tag/v1.1-rc1) herunterladen:

- `pangolin-newt-1.18.1.pkg` – Newt-Dienst und rc-Skript
- `os-newt-devel-1.1.pkg` – OPNsense-WebUI und Dienstintegration
- `SHA256SUMS` – Prüfsummen

Das Repository ist privat. Zum Herunterladen im Browser bei GitHub mit einem berechtigten Konto anmelden. Ein anonymer `fetch`-Aufruf auf die Release-Adresse funktioniert nicht.

Bei einem Upgrade von Version 1.0 zusätzlich das bisherige `os-newt-1.0.pkg` aus [Release v1.0](https://github.com/soehnke1/os-newt/releases/tag/v1.0) für den Rückweg bereithalten.

Per SSH direkt zur Firewall verbinden. `OPNSENSE_HOST` und Port `222` in den Beispielen an die eigene Installation anpassen. Die Verbindung muss auch erreichbar bleiben, während Newt gestoppt ist.

```sh
ssh -p 222 root@OPNSENSE_HOST
```

Auf der OPNsense die Verzeichnisse anlegen:

```sh
mkdir -p /root/newt-test /root/newt-rollback
chmod 700 /root/newt-test /root/newt-rollback
```

In einem zweiten Terminal auf dem Rechner mit den heruntergeladenen Dateien ausführen:

```sh
scp -P 222 pangolin-newt-1.18.1.pkg os-newt-devel-1.1.pkg SHA256SUMS root@OPNSENSE_HOST:/root/newt-test/
```

Beim Upgrade auch das alte Paket übertragen:

```sh
scp -P 222 os-newt-1.0.pkg root@OPNSENSE_HOST:/root/newt-rollback/
```

Auf der OPNsense die SHA256-Werte beider Pakete mit den entsprechenden Zeilen aus `SHA256SUMS` vergleichen. Bei Abweichungen nicht installieren.

```sh
cd /root/newt-test
sha256 pangolin-newt-1.18.1.pkg os-newt-devel-1.1.pkg
cat SHA256SUMS
```

Die ebenfalls in `SHA256SUMS` aufgeführte Quellcode-Datei ist für die Installation nicht erforderlich.

## 2. Konfiguration sichern

Vor jedem Versuch ein neues Backup-Verzeichnis verwenden. Die folgenden Befehle funktionieren auch in der standardmäßigen root-Shell der OPNsense:

```sh
sh
umask 077
backup_dir=$(mktemp -d /root/newt-rollback/config.XXXXXXXX)
cp -p /conf/config.xml "$backup_dir/config.xml"
if [ -f /usr/local/etc/newt/config.json ]; then
    cp -p /usr/local/etc/newt/config.json "$backup_dir/config.json"
fi
printf 'Backup: %s\n' "$backup_dir"
exit
```

Das Backup enthält Zugangsdaten und gehört nicht ins Git-Repository. Den ausgegebenen Pfad für einen möglichen Rückweg notieren.

## 3. Installieren oder von Version 1.0 wechseln

Nur beim Upgrade des bisherigen kombinierten Pakets zuerst ausführen:

```sh
pkg delete os-newt
```

Dadurch wird Newt gestoppt. Das Modell unter `OPNsense/Newt` in `/conf/config.xml` bleibt erhalten. Die alten Laufzeitdateien werden beim Entfernen teilweise gelöscht und vom neuen Plugin wieder erzeugt.

Anschließend bei Erstinstallation und Upgrade:

```sh
cd /root/newt-test
pkg add ./pangolin-newt-1.18.1.pkg
pkg add ./os-newt-devel-1.1.pkg
```

Bei einem Fehler anhalten und die Meldung prüfen. Dateikonflikte oder fehlende Abhängigkeiten nicht mit `-f` oder `-d` umgehen. Das alte kombinierte Paket und die separate Newt-Abhängigkeit besitzen teilweise dieselben Dateipfade.

## 4. WebUI und Dienst prüfen

```sh
pkg info os-newt-devel pangolin-newt
/usr/local/bin/newt --version
configctl newt status
```

Beide Pakete müssen registriert sein, die Newt-Version muss `1.18.1` lauten. Nach einem Upgrade mit zuvor aktiviertem Newt sollte der Dienst bereits laufen. Eine Erstinstallation bleibt bis zur Konfiguration deaktiviert.

Die Weboberfläche neu laden und Folgendes prüfen:

1. **VPN → Pangolin Newt → Settings** öffnen. Beim Upgrade müssen die bisherigen Einstellungen vorhanden sein. Bei Erstinstallation HTTPS-Adresse des Pangolin-Servers, Site-ID und Secret aus der vorgesehenen Pangolin-Site eintragen, Newt aktivieren und speichern/anwenden.
2. Die Seite erneut öffnen und prüfen, dass die Einstellungen erhalten bleiben. Das Secret wird maskiert dargestellt.
3. Unter **System → Diagnostics → Services** prüfen, dass Newt angezeigt wird. Stoppen und Starten testen; nach beiden Aktionen auch `configctl newt status` prüfen. Der Tunnel wird beim Stoppen unterbrochen.
4. Das Log unter **VPN → Pangolin Newt** prüfen. Die zugehörige Site muss auf dem Pangolin-Server online erscheinen. Ein laufender lokaler Prozess allein bestätigt noch keine Tunnelverbindung.

## 5. Zugriff und automatischen Start testen

Auf dem iPhone WLAN ausschalten, den Pangolin-Client mit der passenden Organisation verbinden und einen freigegebenen internen Dienst aufrufen. Dafür müssen das LAN-Netz beziehungsweise die Ressource der richtigen Site zugeordnet und die Zugriffsrechte im Pangolin-Server eingerichtet sein.

Falls der Client während des Paketwechsels oder der Diensttests bereits verbunden war und der Zugriff scheitert, die Verbindung im Pangolin-Client trennen und neu aufbauen. Beim Live-Test von v1.1-rc1 funktionierte der iPhone-Zugriff erst nach diesem erneuten Verbinden. Ein automatischer Wiederaufbau einer bestehenden Client-Verbindung nach einem Newt-Neustart ist damit nicht bestätigt.

Beispiel für einen Switch, dessen Oberfläche nur HTTP unterstützt:

```text
http://10.42.73.110/index.html
```

Die Adresse durch einen tatsächlich vorhandenen internen Dienst ersetzen. Bei einem HTTP-Dienst ausdrücklich `http://` verwenden.

Zum Abschluss die OPNsense über die WebUI neu starten, sobald eine Unterbrechung möglich ist. Nach dem Neustart erneut Dienststatus, Site-Status und iPhone-Zugriff prüfen. Bei aktiviertem Newt muss der Dienst automatisch starten.

Für den Testbericht OPNsense-Version, Paketversionen und Ergebnisse von Installation, Speichern/Anwenden, Stoppen/Starten, Neustart und Client-Zugriff festhalten. Keine Secrets oder vollständigen Konfigurationsdateien veröffentlichen. Bestandene Tests erst dann in [VALIDATION.md](../VALIDATION.md) dokumentieren.

## 6. Rückweg zur bisherigen Version 1.0

Für eine zuvor mit Version 1.0 betriebene Installation, nachdem das alte Paket wie oben gesichert wurde:

```sh
pkg delete os-newt-devel
pkg delete pangolin-newt
pkg add /root/newt-rollback/os-newt-1.0.pkg
configctl newt status
```

Jeden Schritt auf Erfolg prüfen, bevor der nächste ausgeführt wird. Die bisherigen Einstellungen bleiben im Modell in `config.xml` erhalten. Anschließend WebUI, Site-Status und Client-Zugriff erneut prüfen. Bei einer Erstinstallation ohne vorherige Version entfallen die letzten beiden Befehle; das Entfernen der Pakete kann Konfigurationseinträge zurücklassen.

Die gesicherte `config.xml` dient zusätzlich zur Wiederherstellung über die OPNsense-Konfigurationssicherung. Ein vollständiges Zurückspielen setzt auch andere Änderungen seit dem Backup zurück und ist für den normalen Paket-Rückwechsel nicht erforderlich.
