unit VisitorUnit;

interface

uses
  System.Classes, System.SysUtils, System.Rtti, System.Variants;

{$M+}
type
  TVisitor = class
    published
      function VisitFunc(ANode: TObject): Variant; virtual;
      procedure VisitProc(ANode: TObject); virtual;
  end;

implementation

type
  TVisitFunc = function (Node: TObject): Variant of object;
  TVisitProc = procedure (Node: TObject) of object;

{ TVisitor }

function TVisitor.VisitFunc(ANode: TObject): Variant;
var
  VisitName: string;
  VisitMethod: TMethod;
  DoVisit: TVisitFunc;
  SelfName: string;
begin
  Result := Null;
  // Build visitor name: e.g. VisitBinaryExpr from 'Visit' and TBinaryExpr
  if Assigned(ANode) then
  begin
    VisitName := 'Visit' + Copy(ANode.ClassName, 2, 255); //remove T
    SelfName := Self.ClassName;
    VisitMethod.Data := Self;
    VisitMethod.Code := Self.MethodAddress(VisitName);
    if Assigned(VisitMethod.Code) then
    begin
      DoVisit := TVisitFunc(VisitMethod);
      Result := DoVisit(ANode);
    end
    else
      raise Exception.Create(Format('No %s.%s method was found.', [SelfName, VisitName]));
  end;
end;

procedure TVisitor.VisitProc(ANode: TObject);
var
  VisitName: string;
  VisitMethod: TMethod;
  doVisit: TVisitProc;
  SelfName: string ;
begin
 // Build visitor name: e.g. VisitBinaryExpr from 'Visit' and TBinaryExpr
   if Assigned(ANode) then
   begin
     VisitName := 'Visit' + Copy(ANode.ClassName, 2, 255);  // remove 'T'
     SelfName := Self.ClassName;
     VisitMethod.Data := Self;
     VisitMethod.Code := Self.MethodAddress(VisitName);
     if Assigned(VisitMethod.Code) then
     begin
       doVisit := TVisitProc(VisitMethod);
       doVisit(ANode);
     end
     else
       Raise
         Exception.Create(Format('No %s.%s method found.', [SelfName, VisitName]));
   end;
end;

end.
