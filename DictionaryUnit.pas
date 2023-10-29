unit DictionaryUnit;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Variants, TokenUnit, ErrorUnit, VariantHelperUnit;

type
  TDictionaryElements = TDictionary<string, Variant>;

  IDictionary = interface
    ['{9215916F-38C6-4CC1-BA8A-2CD651BB8A6C}']
    function GetElements: TDictionaryElements;
    function Get(AKey: string; AToken: TToken): Variant;
    procedure Put(AKey: string; AValue: Variant; AToken: TToken);
    function ToString: String;
    property Elements: TDictionaryElements read GetElements;
  end;

  TDictionary = class(TInterfacedObject, IDictionary)
    private
      FElements: TDictionaryElements;
      function GetElements: TDictionaryElements;
    public
      constructor Create;
      destructor Destroy; override;
      function ToString: string; override;
      function Get(AKey: string; AToken: TToken): Variant;
      procedure Put(AKey: string; AValue: Variant; AToken: TToken);
      property Elements: TDictionaryElements read GetElements;
  end;

implementation

{ TDictionary }

constructor TDictionary.Create;
begin
  FElements := TDictionaryElements.Create;
end;

destructor TDictionary.Destroy;
begin
  FreeAndNil(FElements);
  inherited;
end;

function TDictionary.Get(AKey: string; AToken: TToken): Variant;
begin

end;

function TDictionary.GetElements: TDictionaryElements;
begin
  Result := FElements;
end;

procedure TDictionary.Put(AKey: string; AValue: Variant; AToken: TToken);
begin

end;

function TDictionary.ToString: string;
var
  i: Integer;
  Key: string;

  function GetStr(AValue: Variant): string;
  begin
    Result := VariantToStr(AValue);
    if VarType(AValue) = varString then
      Result := QuotedStr(Result);
  end;

begin
  i := 1;
  Result := '{';
  for Key in FElements.Keys do
  begin
    Result := Result + QuotedStr(Key) + ':' + GetStr(FElements[Key]);
    if i < Felements.Count then
    begin
      Result := Result + ', ';
      Inc(i)
    end;
  end;
  Result := Result + '}';
end;

end.
