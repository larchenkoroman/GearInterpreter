unit VariantHelperUnit;

interface

uses
  System.Classes, System.SysUtils, System.Variants;


function VarSupportsIntf(AValue: Variant; AIntf: array of TGUID): Boolean;
function VariantToStr(AValue: Variant): string;

implementation

uses
  TupleUnit, DictionaryUnit;

{ TVariantHelper }

function VariantToStr(AValue: Variant): string;
begin
  if    VarIsType(AValue, varUnknown)
    and VarSupportsIntf(AValue, [ITuple, IDictionary]) then
  begin
    Result := (IUnknown(AValue) as TInterfacedObject).ToString;
  end
  else
    Result := VarToStrDef(AValue, 'Null');
end;

function VarSupportsIntf(AValue: Variant; AIntf: array of TGUID): Boolean;
var
  i: Integer;
begin
  Result := False;
  if VarIsType(AValue, varUnknown) then
  begin
    for i := 0 to High(AIntf) do
      if VarSupports(AValue, AIntf[i]) then
      begin
        Result := True;
        break;
      end;
  end;
end;

end.
