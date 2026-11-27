; Установщик «Ночной чайной». Создатель — Ernomoon (https://t.me/Ernomoon)
Unicode true
ManifestDPIAware true
!ifndef VERSION
  !define VERSION "0.0.0"
  !define VERSION4 "0.0.0.0"
!endif
!define APPNAME "Ночная чайная"
!define EXENAME "Chashi.exe"
!define REGKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Chashi"

Name "${APPNAME}"
Caption "${APPNAME} ${VERSION} — установка"
UninstallCaption "${APPNAME} — удаление"
BrandingText "Ernomoon · t.me/Ernomoon"
OutFile "..\dist\Chashi-Setup-${VERSION}.exe"
InstallDir "$LOCALAPPDATA\Programs\Chashi"
InstallDirRegKey HKCU "Software\Chashi" "InstallDir"
RequestExecutionLevel user
SetCompressor /SOLID lzma
SetCompressorDictSize 8

VIProductVersion "${VERSION4}"
VIFileVersion "${VERSION4}"
VIAddVersionKey /LANG=1049 "ProductName" "${APPNAME}"
VIAddVersionKey /LANG=1049 "FileDescription" "Установщик «${APPNAME}»"
VIAddVersionKey /LANG=1049 "CompanyName" "Ernomoon"
VIAddVersionKey /LANG=1049 "LegalCopyright" "© 2026 Ernomoon"
VIAddVersionKey /LANG=1049 "FileVersion" "${VERSION}"
VIAddVersionKey /LANG=1049 "ProductVersion" "${VERSION}"

!include "MUI2.nsh"
!define MUI_ICON "..\build\icon.ico"
!define MUI_UNICON "..\build\icon.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "..\build\installerHeader.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "..\build\installerHeader.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\build\installerSidebar.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "..\build\installerSidebar.bmp"
!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "Прервать установку Ночной чайной?"

!define MUI_WELCOMEPAGE_TITLE "Добро пожаловать в Ночную чайную"
!define MUI_WELCOMEPAGE_TEXT "Тихий таймер проливов для гунфу ча: фонарь наполняется светом, в окнах деревни горит огонь, а по небу пролетает дракон.$\r$\n$\r$\nЛёгкое приложение на Rust: весит пару мегабайт, работает без интернета и ставится без прав администратора.$\r$\n$\r$\nСоздатель — Ernomoon.$\r$\n$\r$\nНажми «Далее», чтобы продолжить."
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\build\license_ru.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE "Чай готов к завариванию"
!define MUI_FINISHPAGE_TEXT "Ночная чайная установлена. Ярлыки — на рабочем столе и в меню «Пуск».$\r$\n$\r$\nКогда выйдет новая версия, приложение само об этом скажет."
!define MUI_FINISHPAGE_RUN "$INSTDIR\${EXENAME}"
!define MUI_FINISHPAGE_RUN_TEXT "Зажечь фонарь — запустить сейчас"
!define MUI_FINISHPAGE_LINK "Telegram-канал Ernomoon"
!define MUI_FINISHPAGE_LINK_LOCATION "https://t.me/Ernomoon"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Russian"

Function .onInit
  ; Нужен Microsoft Edge WebView2 (есть во всех актуальных Windows 10/11)
  ReadRegStr $0 HKLM "SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" "pv"
  StrCmp $0 "" 0 wv_ok
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" "pv"
  StrCmp $0 "" 0 wv_ok
  ReadRegStr $0 HKCU "Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" "pv"
  StrCmp $0 "" 0 wv_ok
  MessageBox MB_YESNO|MB_ICONINFORMATION "Для работы приложения нужен компонент Microsoft WebView2 — обычно он уже есть в Windows 10 и 11, но здесь его не нашлось.$\r$\n$\r$\nОткрыть официальную страницу загрузки? Установка Ночной чайной продолжится." IDNO wv_ok
  ExecShell "open" "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
  wv_ok:
FunctionEnd

Section "Install"
  ; Если приложение открыто (например, при обновлении) — закрываем его
  nsExec::Exec 'taskkill /F /IM "${EXENAME}"'
  Sleep 400
  ; Переезд со старых версий: 1.0 (Electron) удаляем её же деинсталлятором, следы 1.1 (Neutralino) — вручную
  IfFileExists "$INSTDIR\Uninstall Chashi.exe" 0 +4
    ExecWait '"$INSTDIR\Uninstall Chashi.exe" /S _?=$INSTDIR'
    Delete "$INSTDIR\Uninstall Chashi.exe"
    Sleep 300
  RMDir /r "$INSTDIR\.storage"
  RMDir /r "$INSTDIR\.tmp"
  SetOutPath "$INSTDIR"
  File "..\dist\${EXENAME}"
  File "..\build\icon.ico"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\${EXENAME}" "" "$INSTDIR\icon.ico" 0
  CreateShortcut "$SMPROGRAMS\${APPNAME}.lnk" "$INSTDIR\${EXENAME}" "" "$INSTDIR\icon.ico" 0
  WriteRegStr HKCU "Software\Chashi" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "${REGKEY}" "DisplayName" "${APPNAME}"
  WriteRegStr HKCU "${REGKEY}" "DisplayIcon" "$INSTDIR\icon.ico"
  WriteRegStr HKCU "${REGKEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${REGKEY}" "Publisher" "Ernomoon"
  WriteRegStr HKCU "${REGKEY}" "URLInfoAbout" "https://t.me/Ernomoon"
  WriteRegStr HKCU "${REGKEY}" "HelpLink" "https://github.com/Ernomoon/Chashi"
  WriteRegStr HKCU "${REGKEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${REGKEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD HKCU "${REGKEY}" "NoModify" 1
  WriteRegDWORD HKCU "${REGKEY}" "NoRepair" 1
  WriteRegDWORD HKCU "${REGKEY}" "EstimatedSize" 4500
SectionEnd

Section "Uninstall"
  nsExec::Exec 'taskkill /F /IM "${EXENAME}"'
  Sleep 300
  Delete "$DESKTOP\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\${APPNAME}.lnk"
  Delete "$INSTDIR\${EXENAME}"
  Delete "$INSTDIR\icon.ico"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  ; данные окна WebView2 и настройки
  RMDir /r "$LOCALAPPDATA\com.ernomoon.chashi"
  DeleteRegKey HKCU "${REGKEY}"
  DeleteRegKey HKCU "Software\Chashi"
SectionEnd
