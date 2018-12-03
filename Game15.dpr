program Game15;

uses
  Forms,
  Main in 'Main.pas' {FormMain},
  About in 'About.pas' {FormHelp},
  Settings in 'Settings.pas' {FormSet},
  UResult in 'UResult.pas' {FormResult};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Пятнашки';
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormHelp, FormHelp);
  Application.CreateForm(TFormSet, FormSet);
  Application.CreateForm(TFormResult, FormResult);
  Application.Run;
end.
