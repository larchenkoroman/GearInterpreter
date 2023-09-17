unit MemoryUnit;

interface

uses
  System.Classes, System.SysUtils, System.Variants, System.Generics.Collections, AstUnit, TokenUnit, ErrorUnit;

type

  TMemorySpace = class(TDictionary<string, Variant>)
    public
      procedure Store(AName: string; AValue: Variant; AToken: TToken); overload;
      procedure Store(AIdentifier: TIdentifier; AValue: Variant); overload;
      function Load(AName: string; AToken: TToken): Variant; overload;
      function Load(AIdentifier: TIdentifier): Variant; overload;
      procedure Update(AName: string; AValue: Variant; AToken: TToken); overload;
      procedure Update(AIdentifier: TIdentifier; AValue: Variant); overload;
  end;


implementation

const
  ErrVarUndefined = 'Variable "%s" is undefined.';
  ErrVarDefined = 'Variable "%s" is already defined.';

{ TMemorySpace }

function TMemorySpace.Load(AName: string; AToken: TToken): Variant;
begin
  if not TryGetValue(AName, Result) then
    raise ERunTimeError.Create(AToken, Format(ErrVarUndefined, [AName]));
end;

function TMemorySpace.Load(AIdentifier: TIdentifier): Variant;
begin
  Result := Load(AIdentifier.Text, AIdentifier.Token);
end;

procedure TMemorySpace.Store(AIdentifier: TIdentifier; AValue: Variant);
begin
  Store(AIdentifier.Text, AValue, AIdentifier.Token);
end;

procedure TMemorySpace.Store(AName: string; AValue: Variant; AToken: TToken);
begin
  if not ContainsKey(AName) then
    Add(AName, AValue)
  else
    raise ERunTimeError.Create(AToken, Format(ErrVarDefined, [AName]));
end;

procedure TMemorySpace.Update(AName: string; AValue: Variant; AToken: TToken);
begin
  if ContainsKey((AName)) then
    Items[AName] := AValue
  else
    raise ERunTimeError.Create(AToken, Format(ErrVarUndefined, [AName]));
end;

procedure TMemorySpace.Update(AIdentifier: TIdentifier; AValue: Variant);
begin
  Update(AIdentifier.Text, AValue, AIdentifier.Token);
end;

end.
