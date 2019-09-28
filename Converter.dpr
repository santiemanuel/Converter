program Converter;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Velthuis.BigIntegers,
  Velthuis.BigDecimals,
  Conversor,
  Validator,
  Normalizer;
var
  conv : NumConvert;
  num : BigDecimal;
  norm : NumNormalizer;
  valid : MyValidator;

begin
    conv := NumConvert.Create('1004','10','16',10);
    conv.convertTo;
    Writeln('Resultado ',conv.getConvNumber);
    norm := NumNormalizer.Create(conv.getConvNumber, 16);
    norm.normalize;
    norm.setValueT(3);
    Writeln('Normalizado 0.',norm.getNormalized, ' * ',norm.getBase, '^',norm.getExponent);
    norm.RoundSym;
    Writeln('Simetrico 0.', norm.getRounded, ' * ',norm.getBase,'^',norm.getExpRound);
    ReadLn;
end.
