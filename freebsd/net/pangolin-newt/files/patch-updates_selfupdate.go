--- updates/selfupdate.go.orig	1979-11-29 23:00:00 UTC
+++ updates/selfupdate.go
@@ -117,6 +117,12 @@ func CheckAndSelfUpdate(cfg SelfUpdateConfig) error {
 // the function does not return – the process is replaced by the new binary via
 // syscall.Exec.
 func CheckAndSelfUpdate(cfg SelfUpdateConfig) error {
+	// Package-owned binaries must only be replaced through pkg.
+	if runtime.GOOS == "freebsd" {
+		logger.Debug("checkAndSelfUpdate: updates are managed by pkg on FreeBSD")
+		return nil
+	}
+
 	logger.Debug("checkAndSelfUpdate: starting update check (currentVersion=%s)", cfg.CurrentVersion)
 
 	if isOfficialContainer() {
