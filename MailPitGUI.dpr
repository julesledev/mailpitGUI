program MailPitGUI;

uses
  Vcl.Forms,
  Unit_main in 'Unit_main.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'mailpit GUI';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;

end.
