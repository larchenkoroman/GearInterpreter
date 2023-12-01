unit ListUnit;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Variants, TokenUnit, ErrorUnit, VariantHelperUnit;

type
  TListElements = TList<Variant>;

  IList = interface
    ['{D0C1D564-3EF9-4A95-8B46-F95C2FA3F56C}']
    function GetElements: TListElements;
    function GetLength: Integer;
    function Get(i: Integer; AToken: TToken): Variant;
    procedure Put(i: Integer; AValue: Variant; AToken: TToken);
    function ToString: String;
    procedure AddFromList(AList: IList);
    property Elements: TListElements read getElements;
    property Length: Integer read GetLength;
  end;

  TGearList = class(TInterfacedObject, IList)
    private
      FElements: TListElements;
      function GetElements: TListElements;
      function GetLength: Integer;
    public
      constructor Create;
      destructor Destroy; override;
      function ToString: string; override;
      function Get(i: Integer; AToken: TToken): Variant;
      procedure Put(i: Integer; AValue: Variant; AToken: TToken);
      procedure AddFromList(AList: IList);
      property Elements: TListElements read GetElements;
      property Length: Integer read GetLength;
  end;

implementation

{ TGearList }

procedure TGearList.AddFromList(AList: IList);
begin
  for var MyElem in AList.Elements do
  begin
    Elements.Add(MyElem);
  end;
end;

constructor TGearList.Create;
begin
   FElements := TListElements.Create;
end;

destructor TGearList.Destroy;
begin
  FreeAndNil(FElements);
  inherited Destroy;
end;

function TGearList.Get(i: Integer; AToken: TToken): Variant;
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

function TGearList.GetElements: TListElements;
begin
  Result := FElements;
end;

function TGearList.GetLength: Integer;
begin
  Result := FElements.Count;
end;

procedure TGearList.Put(i: Integer; AValue: Variant; AToken: TToken);
var
  Count: Integer;
begin
  Count := FElements.Count;
  if (i >= 0) and (i < Count) then
    FElements[i] := AValue
  else
    Raise ERuntimeError.Create(AToken, 'Index ('+ IntToStr(i) + ') out of range ('+ '0..' + IntToStr(Count - 1) + ').');
end;

function TGearList.ToString: String;
var
  i: Integer;

  function GetStr(AValue: Variant): string;
  begin
    Result := VariantToStr(AValue);
    if VarIsStr(AValue) then
      Result := QuotedStr(Result);
  end;

begin
  Result := '[';
  if FElements.Count > 0 then
  begin
    for i := 0 to FElements.Count - 2 do
      Result := Result + GetStr(FElements[i]) + ', ';
    Result := Result + GetStr(FElements[FElements.Count-1]);
  end;
  Result := Result + ']';
end;

end.
