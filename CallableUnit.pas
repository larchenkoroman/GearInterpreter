unit CallableUnit;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, InterpreterUnit, AstUnit, TokenUnit;

type
  TCallArg = class
    Value: Variant;
    constructor Create(AValue: Variant);
  end;

  TArgList = TObjectList<TCallArg>;

  ICallable = interface
    ['{0769509F-E74D-432F-A846-9A1D9B4AC602}']
    function Call(AToken: TToken; AInterpreter: TInterpreter; AArgList: TArgList): Variant;
    function ToString: String;
  end;

implementation

{ TCallArg }

constructor TCallArg.Create(AValue: Variant);
begin
  Value := AValue;
end;

end.
