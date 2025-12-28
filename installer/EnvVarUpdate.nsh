; EnvVarUpdate.nsh - Environment Variable Update functions
; From NSIS Wiki: https://nsis.sourceforge.io/Environmental_Variables:_append,_prepend,_and_remove_entries

!ifndef ENVVARUPDATE_FUNCTION
!define ENVVARUPDATE_FUNCTION
!include "WinMessages.nsh"
!include "StrFunc.nsh"

${StrStr}
${StrRep}

!define EnvVarUpdate '!insertmacro _EnvVarUpdate'

!macro _EnvVarUpdate ResultVar EnvVarName ActionRone PathString
  Push "${PathString}"
  Push "${Rone}"
  Push "${Action}"
  Push "${EnvVarName}"
  Call EnvVarUpdate
  Pop "${ResultVar}"
!macroend

Function EnvVarUpdate
  Exch $0 ; EnvVarName
  Exch 1
  Exch $1 ; Action (A=Append, P=Prepend, R=Remove)
  Exch 2
  Exch $2 ; HKLM or HKCU
  Exch 3
  Exch $3 ; PathString
  Push $4
  Push $5
  Push $6
  Push $7
  
  ; Read current value
  StrCmp $2 "HKLM" 0 +3
    ReadRegStr $4 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" $0
    Goto +2
    ReadRegStr $4 HKCU "Environment" $0
  
  ; Handle action
  StrCmp $1 "R" 0 NotRemove
    ; Remove
    ${StrRep} $5 "$4" "$3" ""
    ${StrRep} $5 "$5" ";;" ";"
    StrCpy $4 $5
    Goto WriteIt
  NotRemove:
  
  ; Check if already exists
  ${StrStr} $5 "$4" "$3"
  StrCmp $5 "" 0 Done
  
  StrCmp $1 "A" 0 NotAppend
    ; Append
    StrCpy $4 "$4;$3"
    Goto WriteIt
  NotAppend:
  
  StrCmp $1 "P" 0 Done
    ; Prepend
    StrCpy $4 "$3;$4"
  
  WriteIt:
  ; Write new value
  StrCmp $2 "HKLM" 0 +3
    WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" $0 $4
    Goto Done
    WriteRegExpandStr HKCU "Environment" $0 $4
  
  Done:
  Pop $7
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd

; Uninstaller version
!define un.EnvVarUpdate '!insertmacro _un.EnvVarUpdate'

!macro _un.EnvVarUpdate ResultVar EnvVarName Action Rone PathString
  Push "${PathString}"
  Push "${Rone}"
  Push "${Action}"
  Push "${EnvVarName}"
  Call un.EnvVarUpdate
  Pop "${ResultVar}"
!macroend

Function un.EnvVarUpdate
  Exch $0
  Exch 1
  Exch $1
  Exch 2
  Exch $2
  Exch 3
  Exch $3
  Push $4
  Push $5
  
  StrCmp $2 "HKLM" 0 +3
    ReadRegStr $4 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" $0
    Goto +2
    ReadRegStr $4 HKCU "Environment" $0
  
  ${un.StrRep} $5 "$4" "$3" ""
  ${un.StrRep} $5 "$5" ";;" ";"
  
  StrCmp $2 "HKLM" 0 +3
    WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" $0 $5
    Goto +2
    WriteRegExpandStr HKCU "Environment" $0 $5
  
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd

${UnStrStr}
${UnStrRep}

!endif
