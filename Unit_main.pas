unit Unit_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, IniFiles, Vcl.StdCtrls, Vcl.Menus, Vcl.ComCtrls, Vcl.WinXCtrls, DosCommand,
  Vcl.BaseImageCollection,
  Vcl.ImageCollection, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, JSON, Vcl.NumberBox, Data.Bind.EngExt,
  Vcl.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors;

type
  TfrmMain = class(TForm)
    tiMain: TTrayIcon;
    cliRelease: TRESTClient;
    respRelease: TRESTResponse;
    reqRelease: TRESTRequest;
    Panel1: TPanel;
    btnExit: TButton;
    btnStartMailpit: TButton;
    downloadPanel: TPanel;
    ActivityIndicator1: TActivityIndicator;
    Label2: TLabel;
    dsMailpit: TDosCommand;
    btnStopMailpit: TButton;
    dsMailpitVersion: TDosCommand;
    lblMailpitVersion: TLabel;
    dsMailpitInstancesChecker: TDosCommand;
    dsMailpitKiller: TDosCommand;
    tMailpitIntanceChecker: TTimer;
    componentsImagesCollection: TImageCollection;
    trayImagesCollection: TImageCollection;
    componentsImages: TVirtualImageList;
    trayImages: TVirtualImageList;
    cbxMailpitDb: TCheckBox;
    logMemo: TMemo;
    Label1: TLabel;
    pmTray: TPopupMenu;
    Dmarrer1: TMenuItem;
    Arrter1: TMenuItem;
    Quitter1: TMenuItem;
    Panel2: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lbMessagerie: TLinkLabel;
    Label6: TLabel;
    Label7: TLabel;
    timerAutoRun: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure btnStopMailpitClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnStartMailpitClick(Sender: TObject);
    procedure tMailpitIntanceCheckerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tiMainClick(Sender: TObject);
    procedure dsMailpitInstancesCheckerNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
    procedure dsMailpitInstancesCheckerTerminated(Sender: TObject);
    procedure dsMailpitVersionNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
    procedure dsMailpitNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
    procedure cbxMailpitDbClick(Sender: TObject);
    procedure timerAutoRunTimer(Sender: TObject);
    procedure lbMessagerieClick(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }
  end;

const
  APP_NAME = 'mailpitGUI';

const
  MAILPIT_ZIP_FILENAME = 'mailpit-windows-amd64.zip';

const
  MAILPIT_ZIP_RELEASE_URL = 'https://api.github.com/repos/axllent/mailpit/releases/latest';

const
  MAILPIT_VERSION_KEY = 'tag_name';

const
  MAILPIT_NEED_DB_KEY = 'needDb';

const
  MAILPIT_EXE = 'mailpit.exe';

const
  MAILPIT_CURRENT_VERSION_KEY = 'currentVersion';

const
  CONFIG_FILENAME = 'config.ini';

const
  DS_BASE = 'cmd /c ';

const
  MAILPIT_DB_OPTION = ' -d mailbox.db';

var
  frmMain: TfrmMain;
  configIni: TIniFile;
  configPath, releaseFile: String;
  releaseInfoJson: TJSONValue;

  autoRunHelper: Integer;

implementation

uses u_download, Zip, IOUtils, // ShlObj, ComObj, ActiveX,
  ShellAPI, UITypes;

// Functions

function IsSingleInstance(MutexName: string; KeepMutex: Boolean = true): Boolean;
const
  MUTEX_GLOBAL = 'Global\'; // Prefix to explicitly create the object in the global or session namespace.
var
  MutexHandle: THandle;
begin
  MutexHandle := CreateMutex(nil, true, PChar(MUTEX_GLOBAL + MutexName));
  Result := (GetLastError = ERROR_SUCCESS);
  if (not KeepMutex) and (MutexHandle <> 0) then
    CloseHandle(MutexHandle);
end;

procedure downloadFile(fileUrl: String; to_filename: String);
var
  releaseDownloader: tdownload_file;
begin

  // dwonloading
  frmMain.downloadPanel.visible := true;
  releaseDownloader := tdownload_file.Create;

  try
    releaseDownloader.download(fileUrl, to_filename,
      procedure
      begin
        // Update is ready;
        frmMain.downloadPanel.visible := false;
        MessageDlg('La mise à jour est pête, elle sera installée au prochain démarrage !', TMsgDlgType.mtInformation,
          [TMsgDlgBtn.mbOK], 0);
      end,
      procedure
      begin
        ShowMessage('échec de téléchargement');
      end);

  except

    on E: Exception do
      ShowMessage(E.Message);

  end;

  releaseDownloader.Free;
end;

procedure extractRelaseFile;
var
  releaseZip: TZipFile;
begin

  if FileExists(releaseFile) then
  begin

    releaseZip := TZipFile.Create;

    try
      releaseZip.Open(releaseFile, TZipMode.zmRead);
      releaseZip.ExtractAll(configPath);
      releaseZip.Close;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;

    releaseZip.Free;

    TFile.Delete(releaseFile); // delete file after extraction

  end;
end;


// Functions  end

{$R *.dfm}

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Self.Hide;
  btnStopMailpit.Click;
  btnExit.enabled := false;
  Sleep(5000);
  Application.Terminate;
end;

procedure TfrmMain.btnStartMailpitClick(Sender: TObject);
begin
  // running mailpit
  try
    dsMailpit.Execute;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TfrmMain.btnStopMailpitClick(Sender: TObject);
begin
  // killing mailpit processus
  try
    dsMailpitKiller.Execute;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TfrmMain.cbxMailpitDbClick(Sender: TObject);
var
  dbOption: STring;
begin
  dbOption := '';

  if (cbxMailpitDb.Checked) then
  begin
    dbOption := MAILPIT_DB_OPTION;
  end;
  configIni.WriteBool(MAILPIT_EXE, MAILPIT_NEED_DB_KEY, cbxMailpitDb.Checked);
  dsMailpit.CommandLine := concat(DS_BASE, '"', MAILPIT_EXE, ' --smtp-auth-accept-any --smtp-auth-allow-insecure -m ',
    IntToStr(Integer.MaxValue), ' ', dbOption, ' "');
end;

procedure TfrmMain.dsMailpitInstancesCheckerNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
begin
  if AOutputType = otEntireLine then
  begin
    // if service keyword is inside => mailpit is not running =>enable btn start

    btnStartMailpit.enabled := (StrPos(PChar(ANewLine), 'service') <> nil);
    pmTray.Items[0].enabled := btnStartMailpit.enabled;

    btnStopMailpit.enabled := Not btnStartMailpit.enabled;
    pmTray.Items[1].enabled := Not btnStartMailpit.enabled;

    tMailpitIntanceChecker.enabled := true;
  end;

end;

procedure TfrmMain.dsMailpitInstancesCheckerTerminated(Sender: TObject);
begin
  // enable instance checker timer bacause the prevous command is executed  and finished
  tMailpitIntanceChecker.enabled := true;

  if (autoRunHelper = 3) then
    timerAutoRun.enabled := true
  else if (autoRunHelper < 3) then
    autoRunHelper := autoRunHelper + 1
  else
    timerAutoRun.enabled := false;

end;

procedure TfrmMain.dsMailpitNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
begin
  if AOutputType = otEntireLine then
  begin
    logMemo.Lines.Add(ANewLine);
  end;

end;

procedure TfrmMain.dsMailpitVersionNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
begin
  if AOutputType = otEntireLine then
  begin
    lblMailpitVersion.Caption := ANewLine;
    configIni.WriteString(MAILPIT_EXE, MAILPIT_CURRENT_VERSION_KEY, ANewLine);

    if (StrPos(PChar(ANewLine), 'update') <> nil) then
    begin
      downloadFile(releaseInfoJson.GetValue<String>('assets[6].browser_download_url'), releaseFile)
    end;

  end;

end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := false;
  Self.Hide;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  dbOption: String;
begin
  autoRunHelper := 0;
  timerAutoRun.enabled := false;

  configPath := TPath.Combine(TPath.GetPublicPath, TPath.GetFileNameWithoutExtension(Application.ExeName));
  releaseFile := TPath.Combine(configPath, MAILPIT_ZIP_FILENAME);

  dsMailpit.CurrentDir := configPath;
  dsMailpitVersion.CurrentDir := configPath;
  dbOption := '';

  // checking if instance exist
  if (IsSingleInstance(APP_NAME)) then
  begin

    // creating config dir if it does not exist
    if (Not TDirectory.Exists(configPath)) then
      TDirectory.CreateDirectory(configPath);

    configIni := TIniFile.Create(TPath.Combine(configPath, CONFIG_FILENAME));

    if (configIni.ReadBool(MAILPIT_EXE, MAILPIT_NEED_DB_KEY, true)) then
      dbOption := MAILPIT_DB_OPTION;

    cbxMailpitDb.Checked := configIni.ReadBool(MAILPIT_EXE, MAILPIT_NEED_DB_KEY, true);

    dsMailpitVersion.CommandLine := concat(DS_BASE, '"', MAILPIT_EXE, ' version"');

    dsMailpit.CommandLine := concat(DS_BASE, '"', MAILPIT_EXE, ' --smtp-auth-accept-any --smtp-auth-allow-insecure -m ',

      IntToStr(Integer.MaxValue), ' ', dbOption, ' "');

    dsMailpitInstancesChecker.CommandLine := concat(DS_BASE, '"', 'tasklist /FI "IMAGENAME eq ', MAILPIT_EXE, '""');

    dsMailpitKiller.CommandLine := concat(DS_BASE, '"', 'taskkill /F /IM ', MAILPIT_EXE, '"');

    Application.ProcessMessages;

    // extract mailpit zip if it exist and delete the zip after
    if (TFile.Exists(releaseFile)) then
    begin
      Application.ProcessMessages;
      dsMailpitKiller.Execute;
      Sleep(5000);
      extractRelaseFile;
    end;

    // checking mailpit update from github
    try
      cliRelease.BaseURL := MAILPIT_ZIP_RELEASE_URL;
      reqRelease.Execute;
      releaseInfoJson := respRelease.JSONValue;

    except
      on E: Exception do
        ShowMessage(E.Message);
    end;

    if (TFile.Exists(TPath.Combine(configPath, MAILPIT_EXE))) then
    begin
      // check mailpit version
      // check this component onNewline event
      try
        dsMailpitVersion.Execute;
        dsMailpitInstancesChecker.Execute;
      except
        on E: Exception do
          ShowMessage(E.Message);
      end;

    end

    else
    begin // mailpit.exe not found =>  download it

      if (releaseInfoJson = nil) then
      begin
        MessageDlg('Mailpit n''existe pas et nous n''avons pas accès à internet pour le télécharger ! Désolé ! ',
          TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
        Halt;
      end
      else
      begin
        MessageDlg
          ('Mailpit n''existe pas mais nous allons le télécharger pour vous ! ça va durer entre 1 et 5 min selon votre connexion ',
          TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
        downloadFile(releaseInfoJson.GetValue<String>('assets[6].browser_download_url'), releaseFile);
      end;
    end;

  end

  else // we have a running instance
  begin

    ShowMessage('Une instance est déjà en éxécution');
    Halt; // stop this instance
  end;

end;

procedure TfrmMain.lbMessagerieClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://localhost:8025', nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmMain.tiMainClick(Sender: TObject);
begin
  Self.Show;
end;

procedure TfrmMain.timerAutoRunTimer(Sender: TObject);
begin

  if (btnStartMailpit.enabled) then
    btnStartMailpit.Click;
end;

procedure TfrmMain.tMailpitIntanceCheckerTimer(Sender: TObject);
begin

  tMailpitIntanceChecker.enabled := false;
  // // disable it to avoid try running another check while another one still running
  // // checking if mailpit still running
  try
    dsMailpitInstancesChecker.Execute;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;

end;

end.
