unit MemoryUnit;

interface

uses
  System.Classes, System.SysUtils, System.Variants, System.Generics.Collections, AstUnit, TokenUnit, ErrorUnit;

type

  TMemorySpace = class(TDictionary<string, Variant>)
    private
      FEnclosingSpace: TMemoryspace;
    public
      property EnclosingSpace: TMemorySpace read FEnclosingSpace;
      constructor Create(AEnclosingSpace: TMemorySpace = nil);
      procedure Store(AName: string; AValue: Variant; AToken: TToken); overload;
      procedure Store(AIdentifier: TIdentifier; AValue: Variant); overload;
      function Load(AName: string; AToken: TToken): Variant; overload;
      function Load(AIdentifier: TIdentifier): Variant; overload;
      procedure Update(AName: string; AValue: Variant; AToken: TToken); overload;
      procedure Update(AIdentifier: TIdentifier; AValue: Variant); overload;
      function LoadAt(ADistance: Integer; AName: String): Variant;
      procedure UpdateAt(ADistance: Integer; AIdentifier: TIdentifier; AValue: Variant);
      function MemorySpaceAt(ADistance: Integer): TMemorySpace;
  end;


implementation

const
  ErrVarUndefined = 'Variable "%s" is undefined.';
  ErrVarDefined = 'Variable "%s" is already defined.';

{ TMemorySpace }

function TMemorySpace.Load(AName: string; AToken: TToken): Variant;
begin
  if ContainsKey(AName) then
    Result := Items[AName]
  else if Assigned(FEnclosingSpace) then
    Result := FEnclosingSpace.Load(Aname, AToken)
  else
    raise ERunTimeError.Create(AToken, Format(ErrVarUndefined, [AName]));
end;

constructor TMemorySpace.Create(AEnclosingSpace: TMemorySpace);
begin
  inherited Create;
  FEnclosingSpace := AEnclosingSpace;
end;

function TMemorySpace.Load(AIdentifier: TIdentifier): Variant;
begin
  Result := Load(AIdentifier.Text, AIdentifier.Token);
end;

function TMemorySpace.LoadAt(ADistance: Integer; AName: String): Variant;
var
  MemorySpace: TMemorySpace;
begin
  MemorySpace := MemorySpaceAt(ADistance);
  if not MemorySpace.TryGetValue(AName, Result) then
    Result := Unassigned;
end;

function TMemorySpace.MemorySpaceAt(ADistance: Integer): TMemorySpace;
var
  MemorySpace: TMemorySpace;
  I: Integer;
begin
  MemorySpace := Self;
  for I := 1 to ADistance do
    MemorySpace := MemorySpace.EnclosingSpace;
  Result := MemorySpace;
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
  if ContainsKey(AName) then
    Items[AName] := AValue
  else if Assigned(FEnclosingSpace) then
    FEnclosingSpace.Update(AName, AValue, AToken)
  else
    raise ERunTimeError.Create(AToken, Format(ErrVarUndefined, [AName]));
end;

procedure TMemorySpace.Update(AIdentifier: TIdentifier; AValue: Variant);
begin
  Update(AIdentifier.Text, AValue, AIdentifier.Token);
end;

procedure TMemorySpace.UpdateAt(ADistance: Integer;  AIdentifier: TIdentifier; AValue: Variant);
begin
  MemorySpaceAt(ADistance)[AIdentifier.Text] := AValue;
end;

end.
