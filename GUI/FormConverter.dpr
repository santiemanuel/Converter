program FormConverter;

uses
  Vcl.Forms,
  Validator in '..\Numerica\Converter\Validator.pas',
  Conversor in '..\Numerica\Converter\Conversor.pas',
  UnitConverter in 'UnitConverter.pas' {Form1},
  Normalizer in '..\Numerica\Converter\Normalizer.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Material');
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
