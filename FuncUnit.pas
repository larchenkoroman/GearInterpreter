unit FuncUnit;

interface

uses
  System.Classes, System.SysUtils, System.Variants, CallableUnit, InterpreterUnit, AstUnit, MemoryUnit, ErrorUnit, TokenUnit;

type

  TFunc = class(TInterfacedObject, ICallable)
    private
      FFuncDecl: TFuncDecl;
      FClosure: TMemorySpace;
    public
      property FuncDecl: TFuncDecl read FFuncDecl;
      constructor Create(AFuncDecl: TFuncDecl; AClosure: TMemorySpace);
      function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
      function ToString: String; override;
      class procedure CheckArity(AToken: TToken; ANumArgs, ANumParams: Integer); static;
  end;

implementation

{ TFunc }

function TFunc.Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
var
  FuncSpace: TMemorySpace;
  i: Integer;
begin
  CheckArity(AToken, AArgList.Count, FFuncDecl.Params.Count);
  FuncSpace := TMemorySpace.Create(FClosure);

  for i := 0 to FFuncDecl.Params.Count-1 do
    FuncSpace.Store(FFuncDecl.Params[i].FIdentifier, AArgList[i].Value);
  try
    AInterpreter.Execute(FFuncDecl.Body, FuncSpace);
  except on E: EReturnFromFunc do
    Result := E.Value;
  end;
end;

class procedure TFunc.CheckArity(AToken: TToken; ANumArgs, ANumParams: Integer);
begin
 if ANumArgs <> ANumParams then
    Raise ERuntimeError.Create(AToken,
                               Format('Invalid number of arguments. Expected %d arguments.', [ANumParams])
                              );
end;

constructor TFunc.Create(AFuncDecl: TFuncDecl; AClosure: TMemorySpace);
begin
  FFuncDecl := AFuncDecl;
  FClosure := AClosure;
end;

function TFunc.ToString: String;
begin
  Result := '<func ' + FFuncDecl.Identifier.Text+ '>';
end;

end.
