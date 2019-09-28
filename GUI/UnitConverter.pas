unit UnitConverter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Validator, Conversor,
  Vcl.ExtCtrls, System.Win.TaskbarCore, Vcl.Taskbar, Vcl.WinXCtrls,
  Vcl.WinXPanels, Vcl.ComCtrls,
  Vcl.Tabs, JvExStdCtrls,
  JvHtControls, JvExExtCtrls, JvExtComponent, JvClock, JvComponentBase,
  JvAnimTitle, Vcl.Buttons, JvExButtons, JvBitBtn, JvExControls, JvSwitch,
  JvGradient, JvFullColorSpaces, JvFullColorCtrls, Normalizer, Vcl.Samples.Spin;

type
  TForm1 = class(TForm)
    btn1: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    edtNumber: TEdit;
    edtBaseStart: TEdit;
    edtBaseEnd: TEdit;
    lbl4: TLabel;
    edtLong: TEdit;
    pgc1: TPageControl;
    Conversor: TTabSheet;
    Normalizador: TTabSheet;
    Label1: TLabel;
    lbl5: TLabel;
    norm1: TEdit;
    btn2: TButton;
    lbl6: TLabel;
    rg1: TRadioGroup;
    btn3: TButton;
    ResNorm: TJvHTLabel;
    mmo1: TMemo;
    lbl7: TLabel;
    se1: TSpinEdit;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1     : TForm1;
  Validator : MyValidator;
  Conv      : NumConvert;
  Norm      : NumNormalizer;

implementation

{$R *.dfm}

procedure TForm1.btn1Click(Sender: TObject);
var
  per : String;
begin
    if((Length(edtBaseEnd.Text) = 0) or(Length(edtBaseStart.Text) = 0) or (Length(edtLong.Text) = 0)) then
    begin
       Application.MessageBox(PChar('Complete todos los campos'), 'Error', MB_OK);
       Exit;
    end;

    if(edtNumber.Text = '.') then
    begin
        Application.MessageBox(PChar('El numero no tiene digitos'), 'Error', MB_OK);
       Exit;
    end;

    Validator.setEntry(edtNumber.Text);
    Validator.setBase(StrToInt(edtBaseStart.Text));

    if (Validator.isValid) then
    begin
       Conv := NumConvert.Create(edtNumber.Text, edtBaseStart.Text, edtBaseEnd.Text, 0);
       Conv.setLenMin(StrToInt(edtLong.Text));
       Conv.convertTo;
       Mmo1.Text := Conv.getConvNumber;
       if (Conv.getIsPeriod) then
       begin
           per := Conv.getPeriod;
           Application.MessageBox(PChar('Se encontro el periodo '+per),'Info',MB_OK);
       end;

    end
    else
       Application.MessageBox(PChar(Validator.getError), 'Error', MB_OK);
end;


procedure TForm1.btn2Click(Sender: TObject);
begin
    if (Conv = nil) then
    begin
      Application.MessageBox(PChar('Regrese y convierta un numero'), 'Error', MB_OK);
      Exit;
    end;
    if (Conv.getConvNumber = '0.0') then
    begin
      Application.MessageBox(PChar('El numero no cumple las condiciones para normalizar'), 'Error', MB_OK);
      Exit;
    end;
    norm1.Text := Conv.getConvNumber;
    Norm := NumNormalizer.Create(norm1.Text,StrToInt(edtBaseEnd.Text));
    Norm.normalize;
    se1.MaxValue := Length(Norm.getNormalized);
    rg1.ItemIndex := 0;
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  sel : Integer;
begin
    if (Length(se1.Text) = 0) then
    begin
      Application.MessageBox(PChar('Introduzca el valor de T'), 'Error', MB_OK);
      Exit;
    end;

    sel := rg1.ItemIndex;
    Norm.setValueT(StrToInt(se1.Text));
    if (sel = 0) then
    begin
      Norm.RoundCut;
    end;

    if (sel = 1) then
    begin
      Norm.RoundSym;
    end;

    ResNorm.Caption := '0.' + Norm.getRounded + ' * ' + IntToStr(Norm.getBase) +
                            '<sup>'+IntToStr(norm.getExpRound);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Validator := MyValidator.Create('',0);
  pgc1.ActivePageIndex := 0;
  Left:=(Screen.Width-Width) div 2;
  Top:=(Screen.Height-Height) div 2;
end;

end.
