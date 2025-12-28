; NSIS Installer Script for scad-format
; Requires NSIS 3.x

!include "MUI2.nsh"
!include "EnvVarUpdate.nsh"

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
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

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
    File /oname=example.scad-format "..\.scad-format"
    
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
    
    ; Add to PATH
    ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR"
    
    ; Notify shell of environment change
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

; Uninstaller section
Section "Uninstall"
    ; Remove from PATH
    ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR"
    
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
    
    ; Notify shell of environment change
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd
