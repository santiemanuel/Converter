unit Conversor;

interface

uses
  Classes, System.SysUtils, System.Math, Generics.Collections,
  Velthuis.BigDecimals, Velthuis.BigIntegers;

const
  DIGIT = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  MAX_BASE = 62;

type
    StrList = TList<String>;    //Lista dinamica de String
    IntList = TList<Integer>;   //Lista dinamica de Integer
    BigIntList = TList<BigInteger>;
    NumConvert = class
    private
      number   : String;     //Numero de entrada
      decpart  : String;     //Parte decimal de entrada
      intpart  : String;     //Parte entera de entrada
      period   : String;     //Periodo de la conversion, si la tiene

      baseFrom : String;     //Base Inicial
      baseTo   : String;     //Base Final

      isPeriod : Boolean;    //Bandera si el resultado es periodico

      intvalue   : Integer;  //Valor entero de parte entera
      decvalue   : Real;     //Valor real parte decimal

      convNumber : String;   //Numero final convertido
      minlenConv : Integer;  //Longitud minima de parte decimal de convertido

      function fromNto10(baseF : String) : String;
      function powInt(base, exp:Integer): Integer;

    public
      constructor Create(num : String; baseF, baseT : String; len : Integer);
      procedure convertTo();
      procedure convertDecimal(decimal10, bTo : String);
      procedure decimalTo10(base : String);

      function getNumber() : String;
      procedure setNumber(num : String);
      function getDecpart() : String;
      procedure setDecpart(decp : String);
      function getIntpart() : String;
      procedure setIntpart(intp : String);
      function getPeriod() : String;
      procedure setPeriod(per : String);
      function getBaseFrom() : String;
      procedure setBaseFrom(bfrom : String);
      function getBaseTo() : String;
      procedure setBaseTo(bto : String);
      function getIsPeriod() : Boolean;
      procedure setIsPeriod(per : Boolean);
      function getIntval() : Integer;
      procedure setIntval(intval : Integer);
      function getDecVal() : Real;
      procedure setDecVal(decval : Real);
      function getConvNumber() : String;
      procedure setConvNumber(conv : String);
      function getLenMin() : Integer;
      procedure setLenMin(len : Integer);
      procedure longerConv();

      destructor DestroyClass();
    end;

implementation


{-------------------------------------------------------------------------------
  Procedure: NumConvert.Create
  Author:    SANTIAGO
  DateTime:  2019.09.05
  Arguments: num : String;           = Numero de entrada
             baseF, baseT : String;  = Base Inicial, Base Final
             len: Integer            = Longitud minima de resultado
  Result:    None
-------------------------------------------------------------------------------}
constructor NumConvert.Create(num : String; baseF, baseT : String; len: Integer);
      var I : Integer;
      begin
          number := num;
          baseFrom := baseF;
          baseTo := baseT;
          period := '';
          isPeriod := false;

          setLenMin(len);
          I := 1;

          //Busqueda de posicion del punto
          while ((number[I] <> '.') and (I <= Length(number))) do
              Inc(I);

          //Si se encontro el punto
          if (I < Length(number)) then
          begin
              //Si el punto esta al inicio, como ser .25 = 0.25
              if (I = 1) then
              begin
                intpart := '0';
                decpart := Copy(number,2,Length(number)-1);
              end
              else
              begin
                intpart := Copy(number,1,I-1);
                decpart := Copy(number,I+1,Length(number)-I);
              end;
          end
          else //No tiene punto, solo parte entera
          begin
            intpart := number;
            decpart := '0';
          end;

      end;


procedure NumConvert.convertTo();
      var
        BIntStart  : BigInteger;
        baseF      : Integer;
        BigDigList : BigIntList;
        index      : Integer;
        resFinal   : String;
        code, i, aux : Integer;

      begin
           index := 0;
           aux := 0;
           val(getBaseFrom(), baseF, code); //Convierto base partida a Integer

           BigDigList := BigIntList.Create;  //Lista de digitos
           BIntStart := 0;                   //Parte entera inicial

           if (baseF = 10) then
           begin
             BIntStart := getIntpart();
           end
           else
           begin
             BIntStart := fromNto10(getBaseFrom);
           end;

           if (BIntStart = 0) then
              resFinal := '0';

           while (BIntStart > 0) do
           begin
              BigDigList.Add(BigInteger.Remainder(BIntStart,getBaseTo));
              BIntStart := BigInteger.Divide(BIntStart,getBaseTo);
              inc(index);
           end;

           //Armo la parte entera segun el simbolo en la posicion de cada resto
           for i:=0 to (index-1) do
           begin
              resFinal := DIGIT[StrToInt(String(BigDigList[i]))+1] + resFinal;
           end;

            ////////// FIN ////////////
           //Guardo parte entera ya convertida
           setIntpart(resFinal);

           //Si parte decimal es 0, solo la agrego al resultado
           if (getDecpart = '0') then
           begin
             setConvNumber(getIntpart+ '.' +getDecpart);
           end
           else
           begin
             //Si base de partida es 10 convierto directo con
             //Multiplicacion reiterada
             if (baseF = 10) then
             begin
                convertDecimal('0.'+getDecpart,getBaseTo);
             end
             else  //Sino convierto a base 10, y luego a la base Final
             begin
               decimalTo10(getBaseFrom);
               convertDecimal(getDecpart, getBaseTo);
             end;
             setConvNumber(getIntpart+ '.' + getDecpart);
           end;

           //Una vez convertido todo el numero, si este es periodico
           //Agrego tantos digitos como se necesiten para alcanzar
           //La longitud deseada del resultado
           if (isPeriod) then longerConv();

      end;


{-------------------------------------------------------------------------------
  Procedure: NumConvert.convertDecimal
  Author:    SANTIAGO
  DateTime:  2019.09.05
  Arguments: decimal10, bTo : String = Parte decimal en base 10 a base Final
  Result:    None
-------------------------------------------------------------------------------}
procedure NumConvert.convertDecimal(decimal10, bTo : String);
      var
        decimal    : BigDecimal;
        partial    : String;
        code       : Integer;
        digInt     : Integer;
        resFinal   : String;
        periodlist : StrList;
        repeated   : Boolean;
        index      : Integer;
        ini, fin, I: Integer;

      begin
           //Ajustes de precision de tipo de dato BigDecimal
           BigDecimal.DefaultPrecision := 100;
           BigDecimal.DefaultRoundingMode := rmNearestDown;

           //Inicializo la lista de restos para detectar un periodo
           periodlist := StrList.Create;
           repeated := false;
           resFinal := '';
           index := 0;
           decimal := decimal10;

           //Repito mientras el numero no se haga cero, no se alcance el limite
           //De 50 digitos y no se encuentre un periodo
           while (decimal > 0) and (index < 50) and (not(repeated)) do
           begin
                decimal := decimal * bTo;                          //Multiplico el numero por la base Final
                if (decimal >= 1) then                             //Si el resultado vale mas que 1
                begin
                  digInt := decimal.Trunc;                         //Trunco para tener la parte entera
                  resFinal := resFinal + DIGIT[digInt + 1];        //Agrego el simbolo correspondiente en la base
                  decimal := decimal - IntToStr(digInt);           //Resto la parte entera al numero
                  partial := String(decimal);                      //Resultado parcial absoluto sin notacion cientifica
                  if (periodlist.IndexOf(partial) = -1) then       //Si el resultado no esta en la lista para periodo
                     periodlist.Add(partial)                       //Se lo agrega a la lista
                  else
                  begin
                     ini := periodlist.IndexOf(partial);            //Si se encuentra guardo el indice de primera aparicion
                     fin := index;                                  //La posicion actual es el indice de ultima aparicion
                     setPeriod(resFinal.Substring(ini+1,fin-ini));  //Guardo el periodo tomando la subcadena en los limites hallados
                     repeated := true;                              //Guardo que tiene repeticion
                     Delete(resFinal,(Length(resFinal)+1),1);       //Borro el ultimo digito agregado porque es parte del periodo
                     setIsperiod(repeated);
                  end;
                end
                else                                                 //Si no es mayor que 1 solo agrego un 0 al resultado
                begin
                   if(periodlist.IndexOf(String(decimal)) = -1) then //Idem arriba, guardo los resultados para detectar periodo
                     periodlist.Add(String(decimal));
                   resFinal := resFinal + '0';
                end;
                inc(index);
           end;

           setDecpart(resFinal);

      end;


{-------------------------------------------------------------------------------
  Procedure: NumConvert.decimalTo10
  Author:    SANTIAGO
  DateTime:  2019.09.05
  Arguments: base : String = base Inicial a base 10
  Result:    None
-------------------------------------------------------------------------------}
procedure NumConvert.decimalTo10(base : String);
      var
        decimals : String;
        index    : Integer;
        exp      : Integer;
        sum      : BigDecimal;
        partial  : BigDecimal;
        mult     : BigDecimal;
        baseF    : BigInteger;
        value    : Char;
        code     : Integer;

      begin
          BigDecimal.DefaultPrecision := 100;
          BigDecimal.DefaultRoundingMode := rmNearestUp;
          index := 1;
          exp := 1;
          decimals := getDecpart;
          sum := 0;
          partial := 0;
          mult := 0;
          baseF := base;

          //Ciclo de suma ponderada para la conversion
          // value   : 1 digito
          // partial : 1 / Base Inicial ^ exponente
          // mult    : partial * (valor ordinal del digito actual)
          while (index <= Length(decimals)) do
          begin
             value := decimals[index];
             partial := BigDecimal.Divide('1', string(BigInteger.Pow(baseF, exp)));
             mult := BigDecimal.Multiply(partial, (DIGIT.IndexOf(value)));
             sum := sum + mult;
             Inc(index);
             Inc(exp);
          end;

          setDecpart(string(sum));

      end;

      function NumConvert.getNumber() : String;
      begin
           result := self.number;
      end;

      procedure NumConvert.setNumber(num : String);
      begin
           Self.number := num;
      end;

      function NumConvert.getDecpart() : String;
      begin
           result := self.decpart;
      end;

      procedure NumConvert.setDecpart(decp : String);
      begin
           Self.decpart := decp;
      end;

      function NumConvert.getIntpart() : String;
      begin
           result := self.intpart;
      end;

      procedure NumConvert.setIntpart(intp : String);
      begin
          Self.intpart := intp;
      end;

      function NumConvert.getPeriod() : String;
      begin
           result := self.period;
      end;

      procedure NumConvert.setPeriod(per : String);
      begin
          Self.period := per;
      end;

      function NumConvert.getBaseFrom() : String;
      begin
           result := self.baseFrom;
      end;

      procedure NumConvert.setBaseFrom(bfrom : String);
      begin
          Self.baseFrom := bfrom;
      end;

      function NumConvert.getBaseTo() : String;
      begin
           result := self.baseTo;
      end;

      procedure NumConvert.setBaseTo(bto : String);
      begin
          Self.baseTo := bto;
      end;

      function NumConvert.getIsPeriod() : Boolean;
      begin
           result := self.isPeriod;
      end;

      procedure NumConvert.setIsPeriod(per : Boolean);
      begin
           self.isPeriod := per;
      end;

      function NumConvert.getIntval() : Integer;
      begin
           result := self.intvalue;
      end;

      procedure NumConvert.setIntval(intval : Integer);
      begin
           intvalue := intval;
      end;

      function NumConvert.getDecVal() : Real;
      begin
           result := self.decvalue;
      end;

      procedure NumConvert.setDecVal(decval : Real);
      begin
           Self.decvalue := decval;
      end;

      function NumConvert.getConvNumber() : String;
      begin
          result := self.convNumber;
      end;

      procedure NumConvert.setConvNumber(conv: String);
      begin
         convNumber := conv;
      end;

      function NumConvert.getLenMin;
      begin
         Result := Self.minlenConv;
      end;

      procedure NumConvert.setLenMin(len: Integer);
      begin
         Self.minlenConv := len;
      end;


{-------------------------------------------------------------------------------
  Function: NumConvert.fromNto10 Conversion de parte entera
  Author:    SANTIAGO
  DateTime:  2019.09.05
  Arguments: baseF : String  = Base de partida
  Result:    String
-------------------------------------------------------------------------------}
function NumConvert.fromNto10(baseF : String) : String;
      var
         intStart, resS : String;
         len            : Integer;
         exp            : Integer;
         res            : Integer;
         mult           : Integer;
         partial        : Integer;
         aux            : Integer;
         bF, code       : Integer;
         baseBig        : BigInteger;
         multBig        : BigInteger;
         resBig         : BigInteger;
         auxBig         : BigInteger;
         value          : Char;

      begin

         intStart := getIntpart();
         len := Length(intStart);
         exp := len - 1;
         val(baseF, bF, code);
         res := 0;
         resBig := 0;
         baseBig := baseF;

         //Suma ponderada en la parte entera
         while (exp >= 0) do
         begin
             value := intStart[len-exp];
             mult := powInt(bF,exp); //
             multBig := BigInteger.Pow(baseBig, exp);
             partial := pos(value, digit) - 1;
             aux := partial * mult;  //
             auxBig := partial * multBig;
             res := res + aux; //
             resBig := resBig + auxBig;
             dec(exp);
         end;
         Str(res,resS);

         result := string(resBig);

      end;


{-------------------------------------------------------------------------------
  Function: NumConvert.powInt : Potencia entera
  Author:    SANTIAGO
  DateTime:  2019.09.05
  Arguments: base, exp: Integer = base y exponente
  Result:    Integer
-------------------------------------------------------------------------------}
function NumConvert.powInt(base, exp: Integer) : Integer;
      var
        aux, I: Integer;

      begin
          aux := 1;
          if (exp = 0) then
          begin
            Result := 1;
          end
          else
          begin
            for I := 1 to exp do
            begin
              aux := aux * base;
            end;
          end;
          Result := aux;

      end;


{-------------------------------------------------------------------------------
  Procedure: NumConvert.longerConv
  Author:    SANTIAGO
  DateTime:  2019.09.05
  Arguments:
  Result:    Agrego digitos al resultado si es que no alcanzo la longitud minima
             Y el resultado es periodico
-------------------------------------------------------------------------------}
procedure NumConvert.longerConv();
      var
        conv, dec : String;
        I    : Integer;
      begin
        conv := getConvNumber();

        I := 1;
        while (I <= Length(conv)) and (conv[I]<> '.')  do
           Inc(I);

        dec := copy(conv,I+1,Length(conv)-I);

        conv := getConvNumber;

        if ((Length(dec) < getLenMin) and (isPeriod))then
        begin
           while (Length(dec) - 2 < getLenMin) do
           begin
             conv := conv + getPeriod;
             dec := dec + getPeriod;
           end;

        end;

        if (Length(dec) > getLenMin) then
           Delete(conv, I+1+getLenMin, Length(conv)-I-getLenMin+1);

        setConvNumber(conv);
      end;


      destructor NumConvert.DestroyClass();
      begin
           inherited Destroy;
      end;
end.

