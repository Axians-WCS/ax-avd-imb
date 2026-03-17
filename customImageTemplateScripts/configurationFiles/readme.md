# Axians AVD Safe Optimization Baseline

Deze repository bevat de gevalideerde set van configuraties (LGPO's, Default User Settings en Scheduled Tasks) voor integratie in Azure Image Builder (AIB) pipelines. 

## Ontwerpprincipes: Voorspelbare Stabiliteit

De standaard Microsoft Virtual Desktop Optimization Tool (VDOT) is ontworpen voor maximale dichtheid (cost-per-user) ten koste van robuustheid. Het blind injecteren van VDOT-templates in enterprise AVD-omgevingen kan leiden tot onvoorspelbare performance degradaties, vooral bij gebruik van FSLogix profielen op gedeelde storage.

De Axians-baseline hanteert de volgende architectuurkeuzes:
1. **Geen destructieve acties:** Wij sluiten agressieve opschoningsacties (zoals het verwijderen van `*.etl`, `*.log` of AppContainers) uit om de integriteit van het OS en FSLogix te waarborgen.
2. **Geen Shell-manipulatie:** We strippen visuele ballast en achtergrondprocessen, maar laten de kern van `NTUSER.DAT` intact.
3. **Decentraal over Centraal:** Applicatie-specifieke beleidsregels (zoals Microsoft Edge) horen thuis in Active Directory (GPO) of Intune, niet in een statische golden image.
4. **Zelfhelend OS:** Native onderhoudstaken van Windows (zoals Component Cleanup) blijven actief.

---

## 1. Local Group Policies (`policyRegSettings.json`)

Deze subset bevat uitsluitend veilige LGPO's gericht op het reduceren van inlogtijden en netwerk-overhead, zonder de integriteit van het VDI-platform aan te tasten.

### Geëlimineerde Risico's (Niet opgenomen in deze baseline)
* `DeleteUserAppContainersOnLogoff`: Bewust weggelaten. Deze policy veroorzaakt bij sessie-onderbrekingen massale I/O-verwijderacties (delete storms) in het FSLogix-profiel, wat leidt tot SMB-timeouts en asynchrone kernel deadlocks.
* `NoThumbnailCache` & File Explorer tweaks: Te agressieve optimalisaties hierop forceren rebuild-storms en `explorer.exe` crashes bij trage storage I/O.

### Toegepaste Optimalisaties
* **OOBE & Logon UX:** Onderdrukking van First-Logon animaties (`EnableFirstLogonAnimation = 0`) en lockscreen blur (`DisableAcrylicBackgroundOnLogon`) voor een snellere desktop-presentatie.
* **Consumer Features:** Blokkade op het achtergrond-downloaden van consumenten-apps (`DisableWindowsConsumerFeatures`) en Spotlight-suggesties om netwerk-egress en opslag te besparen.
* **Achtergrondprocessen:** Delivery Optimization geforceerd naar 'Simple' mode (`DODownloadMode = 99`) om te voorkomen dat AVD-hosts lokaal netwerkverkeer satureren via peer-to-peer updates.

---

## 2. Default User Settings (`defaultUserSettings.json`)

Deze configuratie past wijzigingen toe op het default user profile om CPU en RAM-verspilling per sessie tegen te gaan.

### Geëlimineerde Risico's
* **Microsoft VDOT DefaultUserSettings**: De hardcoded injectie van +150 registerwijzigingen is verwijderd. Dit breekt moderne AppX-packages (zoals de nieuwe Teams client) tijdens FSLogix profile mounts.

### Toegepaste Optimalisaties
* **UWP Background Access:** Hard uitschakelen van achtergrondprocessen voor standaard Windows 11 apps (`Microsoft.Windows.Photos`, `Microsoft.SkypeApp`, `Microsoft.YourPhone`). Voorkomt onnodige RAM-allocatie bij elke nieuwe sessie.
* **Gaming Overlays:** Deactivatie van GameBar en GameDVR polling (`UseNexusForGameBarEnabled`, `AppCaptureEnabled`). Verwijdert onnodige belasting op de grafische stack, cruciaal voor GPU-loze AVD hosts.
* **Search & I/O Restricties:** Beperkt de Windows Search UI om bij elke toetsaanslag het web of netwerkpaden te bevragen (`NoResolveSearch`, `NoRemoteDestinations`), wat egress en I/O-wachtrijen reduceert.
* **UX Standaardisatie:** Forceert de Windows 11 taakbalk naar links (`TaskbarMn = 0`) om frictie en helpdesk-calls vanuit Windows 10-gebruikers te minimaliseren.

---

## 3. Scheduled Tasks (`scheduledTasks.json`)

Deze configuratie deactiveert ingebouwde Windows-onderhoudstaken die onnodige I/O en CPU genereren in een gevirtualiseerde Azure-omgeving.

### Geëlimineerde Risico's
* **`StartComponentCleanup` (Behouden):** De Microsoft VDOT schakelt deze taak standaard uit. Wij laten deze bewust *actief*. Dit is de enige veilige, native methode waarop Windows zijn Component Store (`WinSxS`) en AppX-staging opruimt. Het uitschakelen hiervan dwingt architectonisch het gebruik van destructieve, custom opschoningsscripts af, wat leidt tot OS-corruptie.

### Toegepaste Optimalisaties
* **Opslag & I/O:** Uitschakelen van `ScheduledDefrag` en `Diagnostics (DiskFootprint)`. Defragmentatie en continue disk-polling op Azure Managed Disks vreet kostbare IOPS.
* **Hardware Diagnostiek:** Uitschakelen van `RunFullMemoryDiagnostic`. Het lokaal draaien van RAM-diagnostiek binnen een VM is zinloos en belast de hypervisor.
* **Telemetrie & Consumententaken:** Uitschakelen van dataverzameling (`Consolidator`, `UsbCeip`) en Xbox-gerelateerde achtergrondtaken (`XblGameSaveTask`) om CPU-credits te besparen.