unit StandardFunctionsUnit;

interface

uses
  System.Variants, CallableUnit, InterpreterUnit, TokenUnit, FuncUnit, VariantHelperUnit, ListUnit, ErrorUnit, DictionaryUnit;

type

  TListInsert = class(TInterfacedObject, ICallable)
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


function TListInsert.Call(AToken: TToken; AInterpreter: TInterpreter;  AArgList: TArgList): Variant;
var
  List: IList;
  i: Integer;
begin
  if AArgList.Count < 2 then
    Raise ERuntimeError.Create(AToken, 'Too few arguments were supported for ListInsert.')
  else
  if VarIsList(AArgList[0].Value) then
  begin
    List := IList(TVarData(AArgList[0].Value).VPointer);
    for i := 1 to AArgList.Count - 1 do
      List.Elements.Add(AArgList[i].Value);
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

  if VarIsList(value) then
    Result := IList(TVarData(Value).VPointer).Length
  else if VarIsDict(Value) then
    Result := IDictionary(TVarData(Value).VPointer).Length
  else if not VarIsNo(Value) then
    Result := Length(VarToStr(Value));
end;

end.
