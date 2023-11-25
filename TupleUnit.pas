unit TupleUnit;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Variants, TokenUnit, ErrorUnit, VariantHelperUnit;

type
  TTupleElements = TList<Variant>;

  ITuple = interface
    ['{D0C1D564-3EF9-4A95-8B46-F95C2FA3F56C}']
    function GetElements: TTupleElements;
    function GetLength: Integer;
    function Get(i: Integer; AToken: TToken): Variant;
    procedure Put(i: Integer; AValue: Variant; AToken: TToken);
    function ToString: String;
    procedure AddFromTuple(ATuple: ITuple);
    property Elements: TTupleElements read getElements;
    property Length: Integer read GetLength;
  end;

  TTuple = class(TInterfacedObject, ITuple)
    private
      FElements: TTupleElements;
      function GetElements: TTupleElements;
      function GetLength: Integer;
    public
      constructor Create;
      destructor Destroy; override;
      function ToString: string; override;
      function Get(i: Integer; AToken: TToken): Variant;
      procedure Put(i: Integer; AValue: Variant; AToken: TToken);
      procedure AddFromTuple(ATuple: ITuple);
      property Elements: TTupleElements read GetElements;
      property Length: Integer read GetLength;
  end;

implementation

{ TTuple }

procedure TTuple.AddFromTuple(ATuple: ITuple);
begin
  for var MyElem in ATuple.Elements do
  begin
    Elements.Add(MyElem);
  end;
end;

constructor TTuple.Create;
begin
   FElements := TTupleElements.Create;
end;

destructor TTuple.Destroy;
begin
  FreeAndNil(FElements);
  inherited Destroy;
end;

function TTuple.Get(i: Integer; AToken: TToken): Variant;
var
  Count: Integer;
begin
  Count := FElements.Count;
  if Count = 0 then
    Result := Unassigned
  else if (i >= 0) and (i < Count) then
    Result := FElements[i]
  else
    Raise ERuntimeError.Create(AToken, 'Index ('+ IntToStr(i) + ') out of range ('+ '0..' + IntToStr(Count - 1) + ').');
end;

function TTuple.GetElements: TTupleElements;
begin
  Result := FElements;
end;

function TTuple.GetLength: Integer;
begin
  Result := FElements.Count;
end;

procedure TTuple.Put(i: Integer; AValue: Variant; AToken: TToken);
var
  Count: Integer;
begin
  Count := FElements.Count;
  if (i >= 0) and (i < Count) then
    FElements[i] := AValue
  else
    Raise ERuntimeError.Create(AToken, 'Index ('+ IntToStr(i) + ') out of range ('+ '0..' + IntToStr(Count - 1) + ').');
end;

function TTuple.ToString: String;
var
  i: Integer;

  function GetStr(AValue: Variant): string;
  begin
    Result := VariantToStr(AValue);
    if VarIsStr(AValue) then
      Result := QuotedStr(Result);
  end;

begin
  Result := '(';
  if FElements.Count > 0 then
  begin
    for i := 0 to FElements.Count - 2 do
      Result := Result + GetStr(FElements[i]) + ', ';
    Result := Result + GetStr(FElements[FElements.Count-1]);
  end;
  Result := Result + ')';
end;

end.
