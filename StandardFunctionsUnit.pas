unit StandardFunctionsUnit;

interface

uses
  System.Variants, CallableUnit, InterpreterUnit, TokenUnit, FuncUnit, VariantHelperUnit, TupleUnit, ErrorUnit;

type

  TTupleInsert = class(TInterfacedObject, ICallable)
    function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
  end;

  TTupleLength = class(TInterfacedObject, ICallable)
    function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
  end;

  TWriteln = class(TInterfacedObject, ICallable)
    function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
  end;

implementation

{ TWriteln }

function TWriteln.Call(AToken: TToken; AInterpreter: TInterpreter;  AArgList: TArgList): Variant;
begin
  for var i := 0 to AArgList.Count - 1 do
    Write(VariantToStr(AArgList[i].Value));
  Writeln;
end;

{ TTupleInsert }

function TTupleInsert.Call(AToken: TToken; AInterpreter: TInterpreter;  AArgList: TArgList): Variant;
var
  Tuple: ITuple;
  i: Integer;
begin
  if AArgList.Count <= 2 then
    Raise ERuntimeError.Create(AToken, 'Too few arguments were supported for TupleInsert.')
  else
  if    VarIsType(AArgList[0].Value, varUnknown)
    and VarSupports(AArgList[0].Value, ITuple) then
  begin
    Tuple := ITuple(TVarData(AArgList[0].Value).VPointer);
    for i := 1 to AArgList.Count - 1 do
      Tuple.Elements.Add(AArgList[i].Value);
  end
  else
    Raise ERuntimeError.Create(AToken, 'First argument must be a tuple.');
end;

{ T ортежƒлина }

function TTupleLength.Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
var
  Tuple: ITuple;
begin
  Result := 0;
  if   (AArgList.Count > 1)
    or (AArgList.Count = 0) then
  begin
    Raise ERuntimeError.Create(AToken, 'TupleLength ожидает один аргумент - кортеж');
  end
  else
  if    VarIsType(AArgList[0].Value, varUnknown)
    and VarSupports(AArgList[0].Value, ITuple) then
  begin
    Tuple := ITuple(TVarData(AArgList[0].Value).VPointer);
    Result := Tuple.Elements.Count;
  end
  else
    Raise ERuntimeError.Create(AToken, 'Argument must be a tuple.');
end;

end.
