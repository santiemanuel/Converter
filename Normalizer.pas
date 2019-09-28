unit Normalizer;

interface
uses
  Classes, System.SysUtils, Velthuis.BigDecimals,
  Velthuis.BigIntegers, Conversor;


const
  DIGIT = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

type
    NumNormalizer = class
    private
      //Atributos para numero normalizado
      numStrInt  : String;       //Parte entera de numero de entrada
      numStrDec  : String;       //Parte decimal de numero de entrada
      normalized : String;       //Parte decimal de normalizado (se agrega 0. externamente)
      base       : Integer;      //Base del numero a normalizar
      exponent   : Integer;      //Valor e del numero ya normalizado

      //Atributos para numero redondeado
      valueT     : Integer;              //T de la malla
      expRound   : Integer;              //Valor e al redondear
      rounded    : String;               //Parte decimal del redondeo, sea corte o simetrico

      function fillZero(val1, val2: string) : String;
      function remLeadingZero(const S : String) : String;
    public

      constructor Create(num: String; b : Integer);
      procedure normalize();
      function sumNumber(n1, n2 : String) : String;
      function compare(num1, num2 : String) : Integer;
      procedure setNumInt(num : String);
      function getNumInt() : String;
      procedure setNumDec(num : String);
      function getNumDec() : String;
      procedure setNormalized(norm : String);
      function getNormalized() : String;
      procedure setExponent(exp : Integer);
      function getExponent() : Integer;
      procedure setBase(b : Integer);
      function getBase() : Integer;

      function getValueT() : Integer;
      procedure setValueT(val : Integer);
      function getExpRound() : Integer;
      procedure setExpRound(exp : Integer);
      function getRounded() : String;
      procedure setRounded(num : String);
      procedure RoundSym();
      procedure RoundCut();

      destructor DestroyClass();
    end;
implementation

constructor NumNormalizer.Create(num : String; b : Integer);
var
   I : Integer;
   intp : string;
   decp : string;
begin

  I := 1;

  //En esta seccion busco el punto para poder separar
  //correctamente el numero y guardar segun corresponda
  while (I <= Length(num)) and (num[I]<> '.')  do
    Inc(I);

  intp := Copy(num, 1, I-1);           //Parte entera
  Delete(num, 1, I-1);                 //Borro parte entera
  decp := Copy(num, 1+1, Length(num)); //Parte decimal

  Self.numStrInt := intp;
  Self.numStrDec := decp;
  Self.exponent := 0;
  Self.base := b;
  Self.valueT := 0;

end;

procedure NumNormalizer.normalize();
var
  len  : Integer;
  digits  : String;
  aux     : string;
begin

  //Si la parte decimal es 0 entonces solamente necesito contar los digitos
  //de la parte entera y tomar el numero tal cual
  if (getNumDec = '0') then
  begin
     digits := getNumInt;
     aux := digits;
     setNormalized(aux);
     setExponent(Length(digits));
  end
  else
  begin
    //Proceso analogo para cuando solo tengo parte decimal
    if (getNumInt = '0') then
    begin
       len := Length(getNumDec);
       digits := remLeadingZero(getNumDec);
       aux := digits;
       setNormalized(aux);
       setExponent(Length(digits)-len);
    end
    else   //Proceso para cuando tengo ambas partes, las uno y calculo exponente
    begin
      len := Length(getNumInt);
      digits := getNumInt + getNumDec;
      aux := digits;
      setNormalized(aux);
      setExponent(Length(getNumInt));
    end;

  end;
end;

//Dados dos numeros a sumar, genera una cadena de ceros de longitud
//del numero de mayor longitud
function NumNormalizer.fillZero(val1, val2: String) : String;
var
   len, I  : Integer;
   zerostr : String;
begin
    if (Length(val1) > Length(val2)) then
      len := Length(val1)
    else
      len := Length(val2);
    for I := 1 to len do
       zerostr := zerostr + '0';

    Result := zerostr;
end;

//Suma de 2 numeros cualesquiera en cualquier base
//Ligeramente modificado para el caso especial de suma 1 unidad
//de menor valor. Ejemplo 266 + 1 -> 266 + 001
function NumNormalizer.sumNumber(n1, n2: String) : String;
var
  num1, num2, res          : String;
  diff, prev, I, partial   : Integer;
begin
    num1 := n1;
    num2 := n2;
    prev := 0;
    partial := 0;
    res := fillZero(num1, num2);
    diff := Abs(Length(num1)- Length(num2));

    //Igualo la longitud de ambos numeros agregando ceros
    if (Length(num1) > Length(num2)) then
       for I := 1 to diff do
          num2 := '0' + num2
    else
       for I := 1 to diff do
          num1 := '0' + num1;

    //Proceso de suma desde el ultimo indice al primero
    for I := Length(res) downto 1 do
    begin
       //Suma parcial de digitos + el acarreo de la suma anterior
       //La primera iteracion el acarreo es 0 asi que no afecta
       partial := DIGIT.IndexOf(num1[I]) + DIGIT.IndexOf(num2[I]) + prev;

       //Si la suma parcial supera la base en la cual se opera,
       //Guardamos el valor MOD de este y el acarreo para la siguiente suma
       if (partial >= getBase) then
       begin
           res[I] := DIGIT[(partial mod getBase) + 1];
           prev := partial div getBase;
       end
       else  //Sino solo guardamos el digito y reseteamos el acarreo
       begin
         res[I] := DIGIT[partial + 1];
         prev := 0;
       end;
    end;


    //----Seccion especializada para el problema derivado debido a que
    //    el resultado de la suma tiene mas digitos que los sumandos----

    //Si existe acarreo al terminar de sumar. Ejemplo 99 + 01 = 00,
    //Acarreo final tiene un 1 guardado.
    if (prev > 0) then
    begin
       res[1] := '1';                //Cambio el primer digito por 1
       setExpRound(getExponent + 1); //Ajusto el exponente por la re-normalizacion
    end
    else setExpRound(getExponent);   //Si no se debe un acarreo no re-normalizar

    Result := res;
end;

//Borro los ceros excedentes para la parte decimal
function NumNormalizer.remLeadingZero(const S: string) : String;
var
  index : Integer;
  len   : Integer;
begin
      len := Length(S);
      index := 1;
      while (index < len) and (S[index] = '0') do inc(index);
      Result := Copy(S, index);
end;


// Comparacion entre dos numeros de cualquier base, ambos seran de la
// Base em que se instancio el normalizador
// El algoritmo esta basado en el codigo fuente del comparador de cadenas
// de Java, adaptado para Pascal.
// Resultados:
// 1  : num1 > num2
// 0  : num1 = num2
// -1 : num1 < num2
function NumNormalizer.compare(num1, num2: string) : Integer;
var
  str1 : String;
  str2 : String;
  I    : Integer;
begin
    str1 := num1;
    str2 := num2;

    for I := 1 to Length(str1) do
    begin
      if (str1[I] <> str2[I])then
      begin
        if (Ord(str1[I])-Ord(str2[I]) > 0) then
        begin
           Result := 1;
           Exit;
        end
        else if (Ord(str1[I])-Ord(str2[I]) < 0) then
        begin
           Result := -1;
           Exit;
        end;
      end;
    end;

    Result := 0;
end;

procedure NumNormalizer.setNumInt(num: string);
begin
    Self.numStrInt := num;
end;

function NumNormalizer.getNumInt;
begin
    Result := Self.numStrInt;
end;

procedure NumNormalizer.setNumDec(num: string);
begin
    self.numStrDec := num;
end;

function NumNormalizer.getNumDec;
begin
    Result := Self.numStrDec;
end;

procedure NumNormalizer.setExponent(exp: Integer);
begin
    self.exponent := exp;
end;

function NumNormalizer.getExponent: Integer;
begin
    Result := self.exponent;
end;

procedure NumNormalizer.setBase(b : Integer);
begin
  Self.base := b;
end;

function NumNormalizer.getBase;
begin
   Result := Self.base;
end;

procedure NumNormalizer.setNormalized(norm: string);
begin
  Self.normalized := norm;
end;

function NumNormalizer.getNormalized;
begin
  Result := self.normalized;
end;

//Redondeo simetrico
procedure NumNormalizer.RoundSym();
var
   half         : NumConvert;
   len          : Integer;
   partB        : String;
   digHalf      : String;
   digB, digA   : String;

begin


   //Obtengo la parte A tomando T digitos del normalizado
   digA := Copy(getNormalized, 1, getValueT);

   //La parte B la obtengo despues de la posicion de T
   partB := '0.' + Copy(getNormalized, getValueT+1,
            Length(getNormalized)-getValueT);
   if (Length(partB) = 2) then
      partB := '0.0';

   //Longitud de parte B descontando el 0.
   len := Length(partB) - 2;

   //Variable que guarda el 0.5 en la base que se esta trabajando
   //Se la obtiene de la longitud que es la parteB para poder
   //comparar correctamente luego
   half := NumConvert.Create('0.5', '10', IntToStr(getBase), len);
   half.convertTo;

   //Pregunto si la mitad en la nueva base tiene periodo
   //Si es asi agrego 1 caracter mas del periodo y un 0 a la parte B
   //Esto es util cuando B = 0.555, Half = 0.555, aparentemente son iguales
   //Pero al ser Half periodico tendremos B = 0.5550, Half = 0.5555 dando
   //que Half > B
   if (half.getIsPeriod) then
   begin
     partB := partB + '0';
     half.setConvNumber(half.getConvNumber + half.getPeriod[1]);
   end;
   if (not half.getIsPeriod) then
   begin
     //Si no es periodico agrego ceros a la derecha a Half para poder comparar
     while(Length(half.getConvNumber) < Length(partB)) do
        half.setConvNumber(half.getConvNumber + '0');
   end;

   //Tomo solo los digitos de la parte decimal de parte B
   digB := Copy(partB, 3, Length(partB)-2);

   //Tomo solo los digitos de la parte decimal de la mitad
   digHalf := Copy(half.getConvNumber,3,Length(half.getConvNumber)-2);

   //Hago la comparacion de estos
   //Si supera la mitad, agrego 1 unidad a la Parte A
   //Sumando en la base determinada
   if (compare(digB, digHalf) >= 0) then
   begin
       setRounded(sumNumber(digA, '1'));
   end
   else
   begin
     setRounded(digA);
     setExpRound(getExponent);
   end;

end;


// Redondeo por corte: Solo tomo T digitos del normalizado
procedure NumNormalizer.RoundCut();
var
  len : Integer;
  str : String;

begin
    len := getValueT;
    str := getNormalized;
    setRounded(Copy(str, 1, getValueT));
    setExpRound(getExponent);

end;

function NumNormalizer.getValueT() : Integer;
begin
  Result := self.valueT;
end;

procedure NumNormalizer.setValueT(val : Integer);
begin
  Self.valueT := val;
end;

function NumNormalizer.getExpRound() : Integer;
begin
  Result := Self.expRound;
end;

procedure NumNormalizer.setExpRound(exp : Integer);
begin
  Self.expRound := exp;
end;

function NumNormalizer.getRounded() : String;
begin
  Result := Self.rounded;
end;

procedure NumNormalizer.setRounded(num : String);
begin
  Self.rounded := num;
end;

destructor NumNormalizer.DestroyClass;
begin
    inherited Destroy;
end;


end.
