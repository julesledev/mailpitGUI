; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "MailpitGUI"
#define MyAppVersion "1.0"
#define MyAppPublisher "Jules le dev"
#define MyAppURL "https://julesledev.web.app"
#define MyAppExeName "MailPitGUI.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{92516CB8-C2F6-447C-9538-7F5FFF98F993}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\Mailpit GUI
DisableDirPage=yes
DefaultGroupName=Mailpit GUI
DisableProgramGroupPage=yes
LicenseFile=D:\Documents\Embarcadero\Studio\Projets\MailPit GUI\resources\licence.txt
InfoBeforeFile=D:\Documents\Embarcadero\Studio\Projets\MailPit GUI\resources\before-install.txt
InfoAfterFile=D:\Documents\Embarcadero\Studio\Projets\MailPit GUI\resources\after-install.txt
OutputDir=D:\Documents\Embarcadero\Studio\Projets\MailPit GUI
OutputBaseFilename=Mailpit GUI
SetupIconFile=D:\Documents\Embarcadero\Studio\Projets\MailPit GUI\MailPitGUI_Icon.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
Source: "D:\Documents\Embarcadero\Studio\Projets\MailPit GUI\Win32\Debug\MailPitGUI.exe"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent