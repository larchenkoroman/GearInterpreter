unit StandardFunctionsUnit;

interface

uses
  System.Variants, CallableUnit, InterpreterUnit, TokenUnit, FuncUnit, VariantHelperUnit, TupleUnit, ErrorUnit, DictionaryUnit;

type

  TTupleInsert = class(TInterfacedObject, ICallable)
    function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
  end;

  TLength = class(TInterfacedObject, ICallable)
    function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
  end;

  TWriteln = class(TInterfacedObject, ICallable)
    function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
  end;

implementation


function TWriteln.Call(AToken: TToken; AInterpreter: TInterpreter;  AArgList: TArgList): Variant;
begin
  for var i := 0 to AArgList.Count - 1 do
    Write(VariantToStr(AArgList[i].Value));
  Writeln;
end;


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


function TLength.Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
var
  Value: Variant;
begin
  Result := 0;
  TFunc.CheckArity(AToken, AArgList.Count, 1);
  Value := AArgList[0].Value;

  if VarIsType(Value, varUnknown) then
  begin
    if VarSupports(Value, ITuple) then
      Result := ITuple(TVarData(Value).VPointer).Length
    else if VarSupports(Value, IDictionary) then
      Result := IDictionary(TVarData(Value).VPointer).Length;
  end
  else
  if    not VarIsNull(Value)
    and not VarIsEmpty(Value) then
    Result := Length(VarToStr(Value));
end;

end.
