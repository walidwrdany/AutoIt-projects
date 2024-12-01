#RequireAdmin


; Define window titles as variables
Local $installWizardTitle = "Internet Download Manager Installation Wizard"
Local $licenseWindowTitle = "Please read IDM license"
Local $destinationTitle = "Choose Destination Location"
Local $startInstallTitle = "Start Installation of Internet Download Manager"
Local $completeTitle = "Installation Complete"




; Set IDM registry language to English
SetIDMLanguage()

; Open file dialog to select the IDM installer
Local $installerPath = SelectInstaller()
If $installerPath = "" Then Exit ; Exit if no file was selected

; Ensure IDM is not running
CloseIDMIfRunning()

; Run the installer and proceed with the installation steps
InstallIDM($installerPath)

; Close any remaining IDM processes post-installation
CleanUpProcesses()

; Notify the user of successful installation
MsgBox(0, "Installation Complete", "IDM has been installed successfully.")


; ---------------------------- Functions ----------------------------

; Function to set IDM language in the registry
Func SetIDMLanguage()
    RegWrite("HKEY_CURRENT_USER\SOFTWARE\DownloadManager", "LanguageID", "REG_DWORD", "9")
EndFunc

; Function to open file dialog and select the IDM installer
Func SelectInstaller()
    Local $path = FileOpenDialog("Select IDM Installer", @WorkingDir & "\", "Executable Files (*.exe)", 1)
    If @error Then
        MsgBox(0, "No File Selected", "No installer file was selected. Exiting.")
        Return ""
    EndIf
    Return $path
EndFunc

; Function to close IDM if it is already running, with an option to cancel
Func CloseIDMIfRunning()
    If ProcessExists("IDMan.exe") Then
        Local $response = MsgBox(1, "Process Status", "IDMan.exe is currently running. Click OK to close it and continue installation, or Cancel to exit.")
        
        ; If the user clicks Cancel, exit the script
        If $response = 2 Then
            Exit
        EndIf

        ; Otherwise, close the IDM process
        ProcessClose("IDMan.exe")
    EndIf
EndFunc


; Function to wait for and activate a window
Func _WinWaitActivate($title, $text = "", $timeout = 0)
    WinWait($title, $text, $timeout)
    If Not WinActive($title, $text) Then WinActivate($title, $text)
    WinWaitActive($title, $text, $timeout)
EndFunc

; Function to install IDM with automated steps
Func InstallIDM($installerPath)
    ; Run the IDM installer
    Run($installerPath)

    ; Step through the installation wizard
    _WinWaitActivate($installWizardTitle)
    Send("{ENTER}")

    ; Agree to the license terms and proceed
    _WinWaitActivate($licenseWindowTitle)
    ControlClick($licenseWindowTitle, "", "Button5") ; Checkbox for agreement
    ControlClick($licenseWindowTitle, "", "Button2") ; Next button

    ; Confirm default installation location
    _WinWaitActivate($destinationTitle)
    Send("{ENTER}")

    ; Start the installation process
    _WinWaitActivate($startInstallTitle)
    Send("{ENTER}")

    ; Finish the installation
    _WinWaitActivate($completeTitle)
    Send("{ENTER}")
EndFunc

; Function to clean up IDM-related processes after installation
Func CleanUpProcesses()
    Sleep(3000) ; Wait for installation finalization
    ProcessClose("IDMan.exe")
    ProcessClose("IEMonitor.exe")
EndFunc
