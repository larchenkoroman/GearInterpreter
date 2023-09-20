unit InterpreterUnit;

interface

uses
  System.Classes, System.SysUtils, System.Variants, VisitorUnit, AstUnit, TokenUnit, ErrorUnit, EvalMathUnit, MemoryUnit;

type
  TInterpreter = class(TVisitor)
    private
      FCurrentSpace: TMemorySpace;
      function Lookup(Variable: TVariable): Variant;
      procedure CheckDuplicate(AIdentifier: TIdentifier; const ATypeName: String);
      function TypeOf(AValue: Variant): String;
      function getAssignValue(OldValue, NewValue: Variant; ID, Op: TToken): Variant;
      procedure Assign(AVariable: TVariable; AValue: Variant);
    public
      constructor Create;
      destructor Destroy; override;
      procedure Execute(Tree: TProduct);
    published
      //expressions
      function VisitBinaryExpr(ABinaryExpr: TBinaryExpr): Variant;
      function VisitConstExpr(AConstExpr: TConstExpr): Variant;
      function VisitUnaryExpr(AUnaryExpr: TUnaryExpr): Variant;
      //statements
      procedure VisitPrintStmt(APrintStmt: TPrintStmt);
      procedure VisitAssignStmt(AAssignStmt: TAssignStmt);
      //declarations
      procedure VisitIdentifier(AIdentifier: TIdentifier);
      procedure VisitVarDecl(AVarDecl: TVarDecl);
      procedure VisitVarDecls(AVarDecls: TVarDecls);
      function VisitVariable(AVariable: TVariable): Variant;
      //blocks
      procedure VisitBlock(ABlock: TBlock);
      procedure VisitProduct(AProduct: TProduct);
  end;

implementation

{ TInterpreter }

const
  ErrDuplicateID = 'Duplicate identifier: %s "%s" is already declared.';
  ErrIncompatibleTypes = 'Incompatible types in assignment: %s vs. %s.';

procedure TInterpreter.Assign(AVariable: TVariable; AValue: Variant);
begin
  FCurrentSpace.Update(AVariable.Identifier, AValue);
end;

procedure TInterpreter.CheckDuplicate(AIdentifier: TIdentifier; const ATypeName: String);
begin
  if FCurrentSpace.ContainsKey(AIdentifier.Text) then
    raise ERunTimeError.Create(AIdentifier.Token, Format(ErrDuplicateID, [ATypeName, AIdentifier.Text]));
end;

constructor TInterpreter.Create;
begin
  FCurrentSpace := TMemorySpace.Create;
end;

destructor TInterpreter.Destroy;
begin
  if Assigned(FCurrentSpace) then
    FreeAndNil(FCurrentSpace);

  inherited;
end;

procedure TInterpreter.Execute(Tree: TProduct);
begin
  try
    VisitProc(Tree);
  except
    on E: ERuntimeError do
      RuntimeError(E);
  end;
end;

function TInterpreter.getAssignValue(OldValue, NewValue: Variant; ID, Op: TToken): Variant;
var
  OldType, NewType: String;
begin
  OldType := TypeOf(OldValue);
  NewType := TypeOf(NewValue);
  if VarIsNull(OldValue) and (Op.TokenType = ttAssign) then
    Exit(NewValue);

  if VarIsNull(NewValue) and (Op.TokenType = ttAssign) then
    Exit(Null);

  if OldType <> NewType then //добавить *= для строк
    raise ERuntimeError.Create(ID, Format(ErrIncompatibleTypes, [OldType, NewType]));

  if not VarIsNull(OldValue) then begin
    if Op.TokenType <> ttAssign then
    case Op.TokenType of
      ttPlusIs:      NewValue := TMath._Add(OldValue, NewValue, Op);
      ttMinusIs:     NewValue := TMath._Sub(OldValue, NewValue, Op);
      ttMulIs:       NewValue := TMath._Mul(OldValue, NewValue, Op);
      ttDivIs:       NewValue := TMath._Div(OldValue, NewValue, Op);
      ttRemainderIs: NewValue := TMath._Rem(OldValue, NewValue, Op);
    end;
    Exit(NewValue);
  end;

  Raise ERuntimeError.Create(ID, Format(ErrIncompatibleTypes, [OldType, NewType]));
end;

function TInterpreter.Lookup(Variable: TVariable): Variant;
begin
  Result := FCurrentSpace.Load(Variable.Identifier);
end;

function TInterpreter.TypeOf(AValue: Variant): String;
begin
  if VarIsNull(AValue) then
    Result := 'Null'
  else if VarIsStr(AValue) then
    Result := 'String'
  else if varIsType(AValue, varBoolean) then
    Result := 'Boolean'
  else if VarIsNumeric(AValue) then
    Result := 'Number'
  else
    Result := 'Unknown';
end;

procedure TInterpreter.VisitAssignStmt(AAssignStmt: TAssignStmt);
var
  OldValue, NewValue, Value: Variant;
begin
  OldValue := Lookup(AAssignStmt.Variable);
  NewValue := VisitFunc(AAssignStmt.Expr);
  Value := getAssignValue(OldValue, NewValue, AAssignStmt.Variable.Token, AAssignStmt.Op);
  Assign(AAssignStmt.Variable, Value);
end;

function TInterpreter.VisitBinaryExpr(ABinaryExpr: TBinaryExpr): Variant;
var
  Left, Right: Variant;
  Op: TToken;
begin
  Left := VisitFunc(ABinaryExpr.Left);
  Right := VisitFunc(ABinaryExpr.Right);
  Op := ABinaryExpr.Op;
  case ABinaryExpr.Op.TokenType of
    ttPlus:      Result := TMath._Add(Left, Right, Op);
    ttMinus:     Result := TMath._Sub(Left, Right, Op);
    ttMul:       Result := TMath._Mul(Left, Right, Op);
    ttDiv:       Result := TMath._Div(Left, Right, Op);
    ttRemainder: Result := TMath._Rem(Left, Right, Op);
    ttOr:        Result := TMath._Or(Left, Right, Op);
    ttAnd:       Result := TMath._And(Left, Right, Op);
    ttXor:       Result := TMath._XOr(Left, Right, Op);
    ttPow:       Result := TMath._Pow(Left, Right, Op);
    ttEQ:        Result := TMath._EQ(Left, Right, Op);
    ttNEQ:       Result := TMath._NEQ(Left, Right, Op);
    ttGT:        Result := TMath._GT(Left, Right, Op);
    ttGE:        Result := TMath._GE(Left, Right, Op);
    ttLT:        Result := TMath._LT(Left, Right, Op);
    ttLE:        Result := TMath._LE(Left, Right, Op);
  end;
end;

procedure TInterpreter.VisitBlock(ABlock: TBlock);
var
  Node: TNode;
begin
  for Node in ABlock.Nodes do
    VisitProc(Node);
end;

function TInterpreter.VisitConstExpr(AConstExpr: TConstExpr): Variant;
begin
  Result := AConstExpr.Value;
end;

procedure TInterpreter.VisitIdentifier(AIdentifier: TIdentifier);
begin

end;

procedure TInterpreter.VisitPrintStmt(APrintStmt: TPrintStmt);
var
  Value: String;
  Expr: TExpr;
begin
  Value := '';
  for Expr in APrintStmt.ExprList do
  begin
    Value := VarToStrDef(VisitFunc(Expr), 'Null');
    Value := StringReplace(Value, '\n', sLineBreak, [rfReplaceAll]);
    Value := StringReplace(Value, '\t', #9, [rfReplaceAll]);
    Write(Value);
  end;
end;

procedure TInterpreter.VisitProduct(AProduct: TProduct);
var
  Node: TNode;
begin
  for Node in AProduct.Nodes do
    VisitProc(Node);
end;

function TInterpreter.VisitUnaryExpr(AUnaryExpr: TUnaryExpr): Variant;
var
  Expr: Variant;
begin
  Expr := VisitFunc(AUnaryExpr.Expr);
  case AUnaryExpr.Op.TokenType of
    ttNot:   Result := TMath._Not(Expr, AUnaryExpr.Op);
    ttMinus: Result := TMath._Neg(Expr, AUnaryExpr.Op);
    else Result := Expr;
  end;
end;

procedure TInterpreter.VisitVarDecl(AVarDecl: TVarDecl);
begin
  CheckDuplicate(AVarDecl.Identifier, 'Variable');
  FCurrentSpace.Store(AVarDecl.Identifier, VisitFunc(AVarDecl.Expr));
end;

procedure TInterpreter.VisitVarDecls(AVarDecls: TVarDecls);
var
  Decl: TDecl;
begin
  for Decl in AVarDecls.List do
    VisitProc(Decl);
end;

function TInterpreter.VisitVariable(AVariable: TVariable): Variant;
begin
   Result := Lookup(AVariable);
end;

end.
