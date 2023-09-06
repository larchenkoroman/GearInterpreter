unit VisitorUnit;

interface

uses
  System.Classes, System.SysUtils, System.Rtti;

type
  TVisitor = class
    published
      function VisitFunc(Node: TObject): Variant; virtual;
      procedure VisitProc(Node: TObject); virtual;
  end;

implementation

type
  TVisitFunc = function (Node: TObject): Variant of object;
  TVisitProc = procedure (Node: TObject) of object;

{ TVisitor }

function TVisitor.VisitFunc(Node: TObject): Variant;
var
  VisitName: string;
  VisitMethod: TMethod;
  DoVisit: TVisitFunc;
  SelfName: string;
begin
  // Build visitor name: e.g. VisitBinaryExpr from 'Visit' and TBinaryExpr
  VisitName := 'Visit' + Copy(Node.ClassName, 2, 255); //remove T
  SelfName := Self.ClassName;
  VisitMethod.Data := Self;
  VisitMethod.Code := Self.MethodAddress(VisitName);
  if Assigned(VisitMethod.Code) then
  begin
    DoVisit := TVisitFunc(VisitMethod);
    Result := DoVisit(Node);
  end
  else
    raise Exception.Create(Format('No %s.%s method was found.', [SelfName, VisitName]));
end;

procedure TVisitor.VisitProc(Node: TObject);
var
  VisitName: string;
  VisitMethod: TMethod;
  doVisit: TVisitProc;
  SelfName: string ;
begin
 // Build visitor name: e.g. VisitBinaryExpr from 'Visit' and TBinaryExpr
  VisitName := 'Visit' + Copy(Node.ClassName, 2, 255);  // remove 'T'
  SelfName := Self.ClassName;
  VisitMethod.Data := Self;
  VisitMethod.Code := Self.MethodAddress(VisitName);
  if Assigned(VisitMethod.Code) then begin
    doVisit := TVisitProc(VisitMethod);
    doVisit(Node);
  end
  else
    Raise
      Exception.Create(Format('No %s.%s method found.', [SelfName, VisitName]));
end;

end.
