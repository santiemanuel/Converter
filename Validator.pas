unit Validator;

interface

uses
   Classes, System.SysUtils;

//Digitos soportados hasta la base maxima
const
  DIGIT = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  B_MIN = 2;  //Base minima a convertir
  B_MAX = 62; //Base maxima a convertir

type
  MyValidator = class
    private

    entry : String;     //Entrada de datos
    base  : Integer;    //Base Inicial recibida
    error : String;     //Mensaje de error en caso de que ocurra

    public
      constructor Create(en: String; b: Integer);
      procedure setEntry(e: String);
      function getEntry() : String;
      procedure setBase(b: Integer);
      function getBase() : Integer;
      function isValid() : Boolean;
      procedure setError(msg: String);
      function  getError() : String;
      destructor destruct();
  end;
implementation

constructor MyValidator.Create(en : String; b: Integer);
begin
    Self.entry := en;
    Self.base := b;
end;

function MyValidator.getBase: Integer;
begin
     Result := Self.base;
end;

procedure MyValidator.setBase(b: Integer);
begin
     Self.base := b;
end;

function MyValidator.getEntry: String;
begin
     Result := Self.entry;
end;

procedure MyValidator.setEntry(e: String);
begin
     Self.entry := e;
end;

function MyValidator.isValid: Boolean;
var
   I, dotCount: Integer;
   ent : String;
begin
     dotCount := 0;       //conteo de puntos
     ent := getEntry();   //la entrada

     //Error de entrada vacia
     if (Length(ent) = 0) then
     begin
       setError('Entrada vacia');
       Result := False;
       Exit;
     end;

     //Error de entrada fuera del rango admitido
     if (base < B_MIN) or (base > B_MAX) then
     begin
       setError('Error de base, rango soportado 2-62');
       Result := False;
       exit;
     end;

     //Ciclo que revisa si tiene caracteres que no existen en
     //DIGIT, todos los caracteres validos
     //Al mismo tiempo cuenta los puntos
     for I := 1 to Length(ent) do
     begin
         if ((DIGIT.IndexOf(ent[i]) = -1) and (ent[i]<> '.')) then
         begin
            setError('Simbolo desconocido');
            result := false;
            exit;
         end;
         if (ent[I] = '.') then Inc(dotCount); //conteo de puntos
     end;
     //Si tiene mas de 1 punto entonces salgo con falso
     if (dotCount > 1) then
     begin
        setError('Se encontraron 2 o mas puntos');
        Result := false;
        exit;
     end
     else
     begin
        //En este ciclo reviso la posicion del caracter en DIGIT
        //Ejemplo: Si la base es 8, la posicion que encuentro no puede ser
        //mayor o igual que 8, uso indice para trabajar con caracteres
        //mas alla de los numeros
        for I := 1 to Length(ent) do
        begin
           if ((DIGIT.IndexOf(ent[I]) >= getBase) and (ent[i]<> '.')) then
           begin
              setError('El caracter excede la base de partida');
              result := false;
              exit;
           end;
        end;
     end;
     //si nada interrumpio el flujo entonces es valida
     Result := true;
end;

procedure MyValidator.setError(msg : String);
begin
  self.error := msg;
end;

function MyValidator.getError() : string;
begin
  Result := Self.error;
end;

destructor MyValidator.destruct();
begin
     inherited Destroy;
end;


end.
