unit UnitBeta;

interface

implementation

procedure CreateUpdaterBatFile;
var
  BatFile: TextFile;
  BatFilePath: string;
begin
  BatFilePath := 'updater.bat'; // Chemin du fichier updater.bat

  AssignFile(BatFile, BatFilePath);
  Rewrite(BatFile);

  Writeln(BatFile, '@echo off');
  Writeln(BatFile, 'taskkill /F /IM mailpitGUI.exe');
  Writeln(BatFile, 'timeout /t 5 /nobreak > nul');
  Writeln(BatFile, 'if exist "mailpitGUI.txt" del "mailpitGUI.txt"');
  Writeln(BatFile, 'if exist "update.txt" ren "update.txt" "mailpitGUI.txt"');

  CloseFile(BatFile);
end;

end.



// if (AnsiSt(PChar(ANewLine),CONFIG_MAILPIT_SECTION ) <> nil) then
// begin
// btnStartMailpit.Enabled := false;
// end
// else
// begin
// btnStartMailpit.Enabled := true;
// end;
//
// tMailpitIntanceChecker.Enabled := true;
// btnStopMailpit.Enabled := Not btnStartMailpit.Enabled;

// logMemo.Lines.Add(ANewLine + '\n');



// if AOutputType = otEntireLine then
// begin
// logMemo.Lines.Add(UTF8Decode(ANewLine));
// end;


// btnStartMailpit.Enabled := true;
// btnStopMailpit.Enabled := Not btnStartMailpit.Enabled;

// TODO option
// -m number max of messages   (int)
// -d db file (string)

// --smtp-auth-accept-any --smtp-auth-allow-insecure to allow any connection

else if (TFile.Exists(MAILPIT_ZIP_FILENAME)) then
    begin
      try
        TFile.Copy(MAILPIT_ZIP_FILENAME, releaseFile);
        MessageDlg('Mailpit copié avec succès , il sera fonctionnel au démarrage !', TMsgDlgType.mtInformation,
          [TMsgDlgBtn.mbOK], 0);
        Application.Terminate;
      except
        on E: Exception do
          ShowMessage(E.Message);
      end;
    end