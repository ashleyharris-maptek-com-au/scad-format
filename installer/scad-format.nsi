; NSIS Installer Script for scad-format
; Requires NSIS 3.x

!include "MUI2.nsh"

; Basic installer info
!define PRODUCT_NAME "scad-format"
!define PRODUCT_VERSION "0.1.0"
!define PRODUCT_PUBLISHER "Ashley Harris"
!define PRODUCT_WEB_SITE "https://github.com/ashleyharris-maptek-com-au/scad-format"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "..\dist\scad-format-${PRODUCT_VERSION}-setup.exe"
InstallDir "$PROGRAMFILES\scad-format"
InstallDirRegKey HKLM "Software\scad-format" "InstallDir"
RequestExecutionLevel admin

; Modern UI settings
!define MUI_ABORTWARNING

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Language
!insertmacro MUI_LANGUAGE "English"

; Installer section
Section "Install"
    SetOutPath "$INSTDIR"
    
    ; Copy files
    File "..\dist\scad-format.exe"
    File "..\README.md"
    File /nonfatal "..\LICENSE"
    File /oname=example.scad-format "..\.\.scad-format"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
    
    ; Registry entries
    WriteRegStr HKLM "Software\scad-format" "InstallDir" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\scad-format" \
        "DisplayName" "${PRODUCT_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\scad-format" \
        "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\scad-format" \
        "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\scad-format" \
        "Publisher" "${PRODUCT_PUBLISHER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\scad-format" \
        "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    
    ; Add to PATH using registry
    ReadRegStr $0 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"
    StrCpy $0 "$0;$INSTDIR"
    WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path" "$0"
    
    ; Notify shell of environment change
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

; Uninstaller section
Section "Uninstall"
    ; Remove files
    Delete "$INSTDIR\scad-format.exe"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\LICENSE"
    Delete "$INSTDIR\example.scad-format"
    Delete "$INSTDIR\uninstall.exe"
    
    ; Remove directory
    RMDir "$INSTDIR"
    
    ; Remove registry entries
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\scad-format"
    DeleteRegKey HKLM "Software\scad-format"
    
    ; Note: PATH cleanup requires manual removal or a more complex script
    ; Notify shell of environment change
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd
