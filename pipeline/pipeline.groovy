// Gemeinsame Umgebungs-Variablen
def setupEnv = {
    // Device Farm Basis-URL
    env.SFT_BASE_URL = 'http://172.17.204.245:7100'
}

// Generische Funktion zum Ausführen von Flutter-Tests
// type: 'unit', 'integration', 'widget', 'golden'
// dir: Verzeichnis, in dem die Tests liegen (z.B. 'test/unit')
// dartDefine: Optionaler Dart-Define-Parameter (z.B. '--dart-define=golden_tolerance=15')
def runFlutterTest = { String type, String dir, String dartDefine = '' ->

    // Parameter-Validierung
    if (!['unit', 'integration', 'widget', 'golden'].contains(type)) {
        error("Ungültiger Testtyp '${type}'! Erlaubt sind: unit, integration, widget, golden.")
    }
    if (!dir) {
        error("Kein Verzeichnis für ${type}-Tests angegeben!")
    }

    // Test ankündigen
    echo "Running ${type}-tests in '${dir}'…"

    // Pfade für Reports dieses Test-Typs definieren
    def reportDir = "reports/${type}_tests"
    // Flutter JSON Ausgabepfad
    def json = "${reportDir}/${type}_results.json"
    // Junit XML Ausgabepfad
    def xml = "${reportDir}/junit.xml"

    // Zielverzeichnis bei Bedarf anlegen
    sh "mkdir -p ${reportDir}"
    
    // Falls dartDefine angegeben ist, in den Befehl einfügen
    def defineArg = dartDefine ? " ${dartDefine}" : ''

    // Flutter Test ausführen und JSON-Report generieren
    def result = sh(
        script: "flutter test --machine ${dir}${defineArg} > ${json}",
        returnStatus: true
    )

    if (!fileExists(json)) {
        error("${type}-tests: JSON-Report '${json}' nicht gefunden.")
    }

    // JSON-Report in JUnit XML umwandeln
    sh "tojunit --input ${json} --output ${xml}"

    // JUNIT XML Report verarbeiten und veröffentlichen
    junit skipPublishingChecks: true, testResults: xml

    // Testergebnisse archivieren
    // archiveArtifacts artifacts: "${json}, ${xml}", fingerprint: true

    // Als instabil markieren, wenn Fehler aufgetreten sind
    if (result != 0) {
        currentBuild.result = 'UNSTABLE'
        echo "${type}-tests failed (rc=${rc}), marking build UNSTABLE."
    }
}

node('flutter-agent') {
    setupEnv()
    
    // Arbeitsverzeichnis bereinigen
    stage('Clean Workspace') {
        cleanWs()
    }

    // App Repository klonen
    stage('Clone Stage') {
        git url: 'http://172.17.204.245/root/my-first-flutter-app.git',
            branch: 'master',
            credentialsId: 'gitlab'
        stash name: 'source-code', includes: '**'
    }
}

// Alle Nodes mit dem Label 'flutter-test' vorbereiten inkl. Abhängigkeiten
stage('Prepare on All Nodes') {
    script {
        // Label, auf dem wir vorbereiten wollen
        def targetLabel = 'flutter-test'
        // Alle Node-Namen mit diesem Label ermitteln
        def testNodeNames = Jenkins.instance
                                  .getLabel(targetLabel)
                                  .getNodes()
                                  .collect { it.nodeName }

        if (!testNodeNames) {
            error("Keine Nodes mit Label '${targetLabel}' gefunden!")
        }

        // Parallel-Branches für jede gefundene Node
        def depsJobs = testNodeNames.collectEntries { nodeName ->
            ["install deps on ${nodeName}": {
                node(nodeName) {
                    // Arbeitsverzeichnis bereinigen
                    cleanWs()

                    unstash 'source-code'
                    echo "Installing on ${env.NODE_NAME}"
                    sh 'git config --global --add safe.directory /opt/flutter'
                    sh 'flutter pub get'
                }
            }]
        }

        parallel depsJobs
    }
}

node('flutter-agent') {
    setupEnv()
    
    // Quellecode analysieren
    stage('Static Code Analysis') {
        sh 'flutter analyze'
    }

    // Unit Tests ausführen
    stage('Run Unit Tests') {
        runFlutterTest('unit','test/unit')
    }

    // Widget Tests ausführen
    stage('Run Widget Tests') {
        runFlutterTest('widget','test/widget')
    }

    // Integration Tests ausführen
    stage('Run Integration Tests') {
        runFlutterTest('integration','test/integration')
    }

    // Golden Tests ausführen
    stage('Run Golden Tests') {
        runFlutterTest('golden','test/goldens','--dart-define=golden_tolerance=15')
    }

    // Test Ergebnisse verifizieren
    stage('Verify Test Results') {
        script {
            // Bei Fehler UNSTABLE setzen
            catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                def thresholds = [ unit:5, widget:5, integration:5, golden:10 ]
                def resultsMap = [:]

                thresholds.each { type, thr ->
                    def a = currentBuild.rawBuild.getAction(hudson.tasks.junit.TestResultAction)
                    if (!a) {
                        echo "Kein Report für '${type}' gefunden – überspringe Prüfung."
                        return
                    }

                    // Gesamte Anzahl der Tests und Fehler abrufen
                    def total  = a.totalCount
                    def failed = a.failCount + a.skipCount
                    if (total == 0) {
                        echo "Keine Testfälle im Report für '${type}' – überspringe Prüfung."
                        return
                    }

                    // Fehlerrate berechnen
                    def percent = (failed.toDouble() / total.toDouble()) * 100.0

                    // Nur Zahlenwert formatieren, kein '%' anhängen
                    def formattedRate = String.format('%.2f', percent)  // z.B. "2.50"
                    
                    // Prüfen, ob die Fehlerrate den Schwellenwert überschreitet, wenn ja UNSTABLE setzen
                    if (percent > thr) {
                        unstable("Fehlerrate ${formattedRate} überschreitet Schwellenwert ${thr}")
                    }

                    echo "Typ='${type}': total=${total}, failed=${failed}, rate=${formattedRate}    (Schwelle ${thr})"

                    resultsMap[type] = [
                        total:     total,
                        failed:    failed,
                        rate:      formattedRate,  // nur Zahl, kein '%'
                        threshold: thr
                    ]
                }

                def json       = groovy.json.JsonOutput.toJson(resultsMap)
                def prettyJson = groovy.json.JsonOutput.prettyPrint(json)
                writeFile file: 'reports/test_results.json', text: prettyJson
                stash name: 'test-results-json', includes: 'reports/test_results.json'
                stash name: 'test-reports',        includes: 'reports/**/junit.xml'
            }
        }
    }

}



// Geräte e2e Tests ausführen
stage('Run Device Tests') {
    script {
        // Wenn die Pipeline UNSTABLE ist, überspringen wir die Device-Tests
        if (currentBuild.currentResult == 'UNSTABLE') {
            echo "Skipping device tests due to previous UNSTABLE result."
            return
        }

        // Gerätegruppen anhand von Filtern definieren
        def deviceFilters = [
            [ name: 'Emulatoren', filter: { d ->
                d.present &&
                (d.product?.toLowerCase()?.startsWith('sdk_') ||
                 d.product?.toLowerCase()?.contains('emu') ||
                 d.model?.toLowerCase()?.contains('sdk') ||
                 d.manufacturer?.toLowerCase()?.contains('unknown') ||
                 (d.serial?.contains(':') ?: false))
            }],
            [ name: 'Physische Geräte', filter: { d ->
                d.present &&
                !(d.product?.toLowerCase()?.startsWith('sdk_') ||
                  d.product?.toLowerCase()?.contains('emu') ||
                  d.model?.toLowerCase()?.contains('sdk') ||
                  d.manufacturer?.toLowerCase()?.contains('unknown') ||
                  (d.serial?.contains(':') ?: false))
            }]
        ]

        // Alle Geräte aus API holen
        def remoteDevices = []
        node('flutter-agent') {
            // API Token aus Credentials holen
            withCredentials([string(credentialsId:'devicefarm', variable:'DEVICEFARM_TOKEN')]) {
                // API aufrufen und Geräte abrufen
                def resp = sh(
                    script: "curl -H \"Authorization: Bearer \$DEVICEFARM_TOKEN\" ${env.SFT_BASE_URL}/api/v1/devices",
                    returnStdout: true
                ).trim()

                // Prüfen, ob die Antwort leer ist
                def json = readJSON text: resp
                if (!json.devices) {
                    error("No devices found! ${resp}")
                }

                // Nur Geräte, die aktuell an der Device Farm angemeldet sind hinzufügen
                remoteDevices = json.devices.findAll { it.present }
                echo "Remote devices:\n" + remoteDevices.collect { "- ${it.serial}" }.join('\n')
            }
        }

        // Gerätegruppenfilter durchlaufen und Tests starten
        deviceFilters.each { grp ->
            // Aktuelles Geräte aus Gesamtliste filtern
            def matches = remoteDevices.findAll(grp.filter)

            // Wenn keine Geräte in der Gruppe gefunden wurden, überspringen
            if (!matches) {
                echo "Keine Geräte in Gruppe ${grp.name}"
                return
            }

            // Ankündigung der Tests für die Gruppe
            echo "Starte Tests für Gruppe ${grp.name}"

            // Jobs für jedes gefundene Gerät in der Gruppe erstellen
            def jobs = matches.collectEntries { dev ->
                ["${dev.serial} (${grp.name})": {
                    node('flutter-test') {
                        unstash 'source-code'
                        echo "=== ${dev.serial} auf ${env.NODE_NAME} ==="

                        // 1) Gerät blocken & connect anfordern
                        def remoteConnectionUrl = null
                        withCredentials([string(credentialsId: 'devicefarm', variable:          'DEVICEFARM_TOKEN')]) {
                            // Gerät blocken
                            sh """
                                curl -X POST -H "Content-Type: application/json" \\
                                     -d '{"serial":"${dev.serial}"}' \\
                                     -H "Authorization: Bearer \$DEVICEFARM_TOKEN" \\
                                     ${env.SFT_BASE_URL}/api/v1/user/devices/${dev.serial}
                            """

                            // RemoteConnect anfordern
                            def connectResp = sh(
                                script: """
                                    curl -X POST \\
                                         -H "Authorization: Bearer \$DEVICEFARM_TOKEN" \\
                                         ${env.SFT_BASE_URL}/api/v1/user/devices/${dev.serial}/remoteConnect
                                """,
                                returnStdout: true
                            ).trim()

                            def connectRespObj = readJSON text: connectResp
                            if (!connectRespObj.success) {
                                echo "WARN: RemoteConnect failed for ${dev.serial}"
                                return
                            }
                            remoteConnectionUrl = connectRespObj.remoteConnectUrl
                        }

                        // 2) E2E-Tests inline
                        if (remoteConnectionUrl) {
                            // Init Variablen für JUnit-Report
                            def safeId    = remoteConnectionUrl.replaceAll(':','_')
                            def xmlDir    = "reports/e2e_tests/${safeId}"
                            def xmlFile   = "${xmlDir}/junit_report.xml"
                            def timestamp = new Date().format("yyyy-MM-dd'T'HH:mm:ss", TimeZone.getTimeZone('UTC'))

                            // Verzeichnis anlegen und Datei mit sauberer XML-Deklaration starten
                            sh "mkdir -p ${xmlDir}"
                            writeFile file: xmlFile, text: '<?xml version="1.0" encoding="UTF-8"?><testsuites>'

                            // E2E-Testdateien ermitteln
                            def driverPath = 'test/e2e/test_driver/test_driver.dart'
                            def testFiles = sh(
                                script: "find test/e2e -name '*.dart' " +
                                        "! -path '${driverPath}' " +
                                        "! -path 'test/e2e/test_driver/*' " +
                                        "! -path 'test/e2e/utils/*' " +
                                        "! -path 'test/e2e/util/*'",
                                returnStdout: true
                            ).trim().split('\n')

                            // Für jede Testdatei…
                            testFiles.each { f ->
                                // Init JUnit-Report Variablen für diesen Test
                                def name    = f.tokenize('/').last().replace('.dart','')
                                def pkgName = f.replaceAll(/^\//,'').replaceAll(/\.dart$/,'').replaceAll(/[\/]/,'.')
                                def start   = System.currentTimeMillis()
                                def status  = 0

                                // Initialisiere Indikator auf Fehler
                                def indikator = 1
                                
                                // Bis zu 3× versuchen, Flutter Drive auszuführen und bei Fehler ADB neu verbinden
                                try {
                                    retry(3) {
                                        // 1) Flutter Drive ausführen, Rückgabecode in 'indikator' ablegen
                                        indikator = sh(
                                            returnStatus: true,
                                            script: """
                                                flutter drive --no-pub \\
                                                  -d ${remoteConnectionUrl} \\
                                                  --driver=${driverPath} \\
                                                  --target=${f}
                                            """
                                        )
                                
                                        // 2) Wenn erfolgreich (indikator == 0), wird kein Fehler geworfen und retry endet
                                        if (indikator == 0) {
                                            echo "Drive-Test erfolgreich."
                                            return
                                        }
                                
                                        // 3) Wenn fehlgeschlagen (indikator != 0) und noch Versuche übrig, ADB neu verbinden
                                        echo "WARN: flutter drive rc=${indikator} – versuche ADB-Reconnect"
                                        sh "adb disconnect ${remoteConnectionUrl} || true"
                                        sh "adb connect ${remoteConnectionUrl}"
                                
                                        // Exception werfen, damit retry erneut ausgelöst wird
                                        throw new Exception("Drive-Test fehlgeschlagen, nächster Versuch…")
                                    }
                                } catch (e) {
                                    // Nach 3 Fehlversuchen: Build auf UNSTABLE setzen
                                    unstable("Drive-Test auf ${remoteConnectionUrl} nach 3 Versuchen fehlgeschlagen")
                                }
                                
                                def duration = (System.currentTimeMillis() - start) / 1000.0

                                // Testergebnis anhängen
                                sh """
                                    cat >> ${xmlFile} <<EOF
                        <testsuite name="${pkgName}" tests="1" failures="${status!=0?1:0}" errors="0" skipped="0"                       timestamp="${timestamp}">
                          <properties><property name="platform" value="vm"/></properties>
                          <testcase classname="${pkgName}" name="${name}" time="${duration}">
                            ${status!=0?'<failure message="Test failed"/>' : ''}
                          </testcase>
                        </testsuite>
                        EOF
                                """
                            }

                            // XML abschließen
                            sh "echo '</testsuites>' >> ${xmlFile}"


                            junit(allowEmptyResults: true, testResults: xmlFile, skipPublishingChecks: true)

                            // E2E-XML staschen, damit es in späterer Stage verfügbar ist
                            stash name: 'e2e-reports', includes: "${xmlDir}/junit_report.xml"

                            // Gerät wieder freigeben
                            sh "adb disconnect ${remoteConnectionUrl}"
                            withCredentials([string(credentialsId:'devicefarm',         variable:'DEVICEFARM_TOKEN')]) {
                                sh """
                                    curl -X DELETE -H "Authorization: Bearer \$DEVICEFARM_TOKEN" \\
                                         ${env.SFT_BASE_URL}/api/v1/user/devices/${dev.serial}/remoteConnect
                                """
                                sh """
                                    curl -X DELETE -H "Authorization: Bearer \$DEVICEFARM_TOKEN" \\
                                         ${env.SFT_BASE_URL}/api/v1/user/devices/${dev.serial}
                                """
                            }
                        }
                    }
                }]
            }
            parallel jobs
        }
    }
}


node('flutter-agent') {
    // Umgebung einrichten (Flutter, Android SDK, PATH, Base URL)
    setupEnv()

    // Release APK und AAB bauen
    stage('Build APK & AAB') {
        echo 'Building APK (Release)...'
        sh 'flutter build apk --release'

        echo 'Building AAB (Release)...'
        sh 'flutter build appbundle --release'

        archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk, build/app/  outputs/bundle/release/app-release.aab', fingerprint: true
    }
    
    // Report mit Screenshots generieren
   stage('Generate HTML Report') {

        // Artefakte entpacken
        unstash 'test-results-json'      // JSON-Summaries
        unstash 'test-reports'           // Unit/Integration/Widget-JUnit
        unstash 'e2e-reports'            // E2E-JUnit

        // Verzeichnis für Screenshots
        def screenshotsDir = 'screenshots'
        sh "mkdir -p ${screenshotsDir}"

        // Basisdaten für Report
        def htmlFile = "${screenshotsDir}/report.html"
        def buildTs  = new Date().format('yyyy-MM-dd HH:mm:ss', TimeZone.getTimeZone('UTC'))

        // HTML-Header
        def html = """<!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Test Report & Screenshots</title>
    </head>
    <body>
      <h1>Test Report</h1>
      <p>Build #${env.BUILD_NUMBER} @ ${buildTs} UTC</p>
    """

        // JSON-Summaries einlesen
        def jsonText = readFile('reports/test_results.json')
        def results  = new groovy.json.JsonSlurperClassic()
                         .parseText(jsonText) as Map    // LinkedHashMap ⇒ serialisierbar

        // Unit / Integration / Widget / Golden
        ['unit','integration','widget','golden'].each { t ->
            if (results.containsKey(t)) {
                def d = results[t]
                html += """
      <h2>${t.capitalize()} Tests</h2>
      <ul>
        <li>Total: ${d.total}</li>
        <li>Failures: ${d.failed}</li>
        <li>Failure Rate: ${d.rate}%</li>
      </ul>
    """
            } else {
                html += """
      <h2>${t.capitalize()} Tests</h2>
      <p>No summary entry found.</p>
    """
            }
        }

        // E2E-JUnit pro Device
        html += "<h1>E2E Tests</h1>\n"
        def xmlFiles = sh(
            script: "find reports/e2e_tests -type f -name 'junit_report.xml' 2>/dev/null || true",
            returnStdout: true
        ).trim().split('\\n').findAll { it }

        xmlFiles.each { xml ->
            def devId = xml.tokenize('/').getAt(2) ?: 'unknown_device'
            def parts = sh(
                script: """
    total=\$(grep -c '<testcase' "${xml}" || true)
    failures=\$(grep -c '<failure'  "${xml}" || true)
    errors=\$(grep -c '<error'     "${xml}" || true)
    failed=\$((failures + errors))
    pct=\$(awk -v f=\$failed -v t=\$total 'BEGIN{printf "%.2f", (f/t)*100}')
    echo "\$total|\$failed|\$pct"
    """,
                returnStdout: true
            ).trim().split('\\|')

            if (parts.size() == 3) {
                html += """
      <h2>Device ${devId}</h2>
      <ul>
        <li>Total E2E Tests: ${parts[0]}</li>
        <li>Failures: ${parts[1]}</li>
        <li>Failure Rate: ${parts[2]}%</li>
      </ul>
    """
            }
        }

        if (xmlFiles.isEmpty()) {
            html += "<p>Keine E2E-JUnit-XML-Dateien gefunden.</p>\n"
        }

        // Screenshots anhängen
        def shots = sh(
            script: "find ${screenshotsDir} -type f -name '*.png' 2>/dev/null || true",
            returnStdout: true
        ).trim().split('\\n').findAll { it }

        if (shots) {
            html += "<h1>Screenshots</h1>\n<div>\n"
            shots.each { f ->
                def rel = f.replaceFirst("^${screenshotsDir}/",'')
                html += """
      <div>
        <h3>${rel}</h3>
        <img src="${rel}" style="height:200px"/>
      </div>
    """
            }
            html += "</div>\n"
        }

        // HTML schreiben & publizieren
        html += "</body></html>"
        writeFile file: htmlFile, text: html

        publishHTML([
          reportDir            : screenshotsDir,
          reportFiles          : 'report.html',
          reportName           : 'Test Report & Screenshots',
          keepAll              : true,
          allowMissing         : false,
          alwaysLinkToLastBuild: true
        ])
    }
}