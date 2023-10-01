unit StandardFunctionsUnit;

interface

uses
  CallableUnit, InterpreterUnit, TokenUnit, FuncUnit;
type

  TPi = class(TInterfacedObject, ICallable)
    function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
  end;

  TWriteln = class(TInterfacedObject, ICallable)
    function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
  end;

implementation

{ TPi }

function TPi.Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
begin
  TFunc.CheckArity(AToken, AArgList.Count, 0);
  Result := pi;
end;


{ TWriteln }

function TWriteln.Call(AToken: TToken; AInterpreter: TInterpreter;  AArgList: TArgList): Variant;
begin
  for var i := 0 to AArgList.Count - 1 do
    Write(AArgList[i].Value);
  Writeln;
end;

end.
