unit InterpreterUnit;

interface

uses
  System.Classes, System.SysUtils, System.Variants, VisitorUnit, AstUnit, TokenUnit, ErrorUnit, EvalMathUnit, MemoryUnit;

type
  TInterpreter = class(TVisitor)
    private
      FCurrentSpace: TMemorySpace;
      FGlobals: TMemorySpace;
      function Lookup(AVariable: TVariable): Variant;
      procedure CheckDuplicate(AIdentifier: TIdentifier; const ATypeName: String);
      function TypeOf(AValue: Variant): String;
      function getAssignValue(OldValue, NewValue: Variant; ID, Op: TToken): Variant;
      procedure Assign(AVariable: TVariable; AValue: Variant);
    public
      constructor Create;
      destructor Destroy; override;
      procedure Execute(Tree: TProduct);
      property Globals: TMemorySpace read FGlobals;
    published
      //expressions
      function VisitBinaryExpr(ABinaryExpr: TBinaryExpr): Variant;
      function VisitConstExpr(AConstExpr: TConstExpr): Variant;
      function VisitUnaryExpr(AUnaryExpr: TUnaryExpr): Variant;
      //statements
      procedure VisitPrintStmt(APrintStmt: TPrintStmt);
      procedure VisitAssignStmt(AAssignStmt: TAssignStmt);
      procedure VisitIfStmt(AIfStmt: TIfStmt);
      procedure VisitWhileStmt(AWhileStmt: TWhileStmt);
      procedure VisitRepeatStmt(ARepeatStmt: TRepeatStmt);
      procedure VisitForStmt(AForStmt: TForStmt);
      procedure VisitBreakStmt(ABreakStmt: TBreakStmt);
      procedure VisitContinueStmt(AContinueStmt: TContinueStmt);
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
  ErrConditionNotBoolean = 'Condition is not Boolean.';

procedure TInterpreter.Assign(AVariable: TVariable; AValue: Variant);
begin
 if AVariable.Distance >= 0 then
    FCurrentSpace.UpdateAt(AVariable.Distance, AVariable.Identifier, AValue)
  else
    Globals.Update(AVariable.Identifier, AValue);
end;

procedure TInterpreter.CheckDuplicate(AIdentifier: TIdentifier; const ATypeName: String);
begin
  if FCurrentSpace.ContainsKey(AIdentifier.Text) then
    raise ERunTimeError.Create(AIdentifier.Token, Format(ErrDuplicateID, [ATypeName, AIdentifier.Text]));
end;

constructor TInterpreter.Create;
begin
  FGlobals := TMemorySpace.Create;
  FCurrentSpace := FGlobals;
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

  if    (OldType <> NewType)
    and not (    (OldType = 'String')
             and (NewType = 'Number')
             and (Op.TokenType = ttMulIs) // для строк допустимо *=
            ) then
  begin
    raise ERuntimeError.Create(ID, Format(ErrIncompatibleTypes, [OldType, NewType]));
  end;

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

function TInterpreter.Lookup(AVariable: TVariable): Variant;
begin
  if AVariable.Distance >= 0 then
    Result := FCurrentSpace.LoadAt(AVariable.Distance, AVariable.Identifier.Text)
  else
    Result := Globals.Load(AVariable.Identifier);
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
  if Assigned(AAssignStmt) then
  begin
    OldValue := Lookup(AAssignStmt.Variable);
    NewValue := VisitFunc(AAssignStmt.Expr);
    Value := getAssignValue(OldValue, NewValue, AAssignStmt.Variable.Token, AAssignStmt.Op);
    Assign(AAssignStmt.Variable, Value);
  end;
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
  EnclosingSpace: TMemorySpace;
begin
  EnclosingSpace := FCurrentSpace;
  try
    FCurrentSpace := TMemorySpace.Create(EnclosingSpace);
    for Node in ABlock.Nodes do
      VisitProc(Node);
  finally
    FCurrentSpace := EnclosingSpace;
  end;
end;

procedure TInterpreter.VisitBreakStmt(ABreakStmt: TBreakStmt);
var
  Condition: Variant;
begin
  Condition := True;
  if Assigned(ABreakStmt.Condition) then
    Condition := VisitFunc(ABreakStmt.Condition);

  if not VarIsType(Condition, varBoolean) then
    Raise ERuntimeError.Create(ABreakStmt.Token, ErrConditionNotBoolean);

  if Condition then
    raise EBreakException.Create('');
end;

function TInterpreter.VisitConstExpr(AConstExpr: TConstExpr): Variant;
begin
  Result := AConstExpr.Value;
end;

procedure TInterpreter.VisitContinueStmt(AContinueStmt: TContinueStmt);
begin
  raise EContinueException.Create('');
end;

procedure TInterpreter.VisitForStmt(AForStmt: TForStmt);
var
  Condition: Variant;
  SavedSpace: TMemorySpace;
begin
  SavedSpace := FCurrentSpace;
  try
    FCurrentSpace := TMemorySpace.Create(SavedSpace);
    VisitProc(AForStmt.VarDecl);
    Condition := VisitFunc(AForStmt.Condition);
    try
      if VarIsType(Condition, varBoolean) then
      begin
        while Condition do
        begin
          try
            VisitProc(AForStmt.Block);
          except on E: EContinueException do;
          end;
          VisitProc(AForStmt.Iterator);
          Condition := VisitFunc(AForStmt.Condition);
        end;
      end
      else
        Raise ERuntimeError.Create(AForStmt.Token, ErrConditionNotBoolean);
    except on E: EBreakException do;
    end;
  finally
    FreeAndNil(FCurrentSpace);
    FCurrentSpace := SavedSpace;
  end;
end;

procedure TInterpreter.VisitIdentifier(AIdentifier: TIdentifier);
begin

end;

procedure TInterpreter.VisitIfStmt(AIfStmt: TIfStmt);

  function isBooleanAndTrue(Condition: TExpr): Boolean;
  var
    Value: Variant;
  begin
    Value := VisitFunc(Condition);
    if VarIsType(Value, varBoolean) then
      Result := Boolean(Value)
    else
      Raise ERuntimeError.Create(AIfStmt.Token, ErrConditionNotBoolean);
  end;

var
  Condition: Variant;
  i: Integer;
  ElseIfExecuted: Boolean;
begin
  ElseIfExecuted := False;
  if isBooleanAndTrue(AIfStmt.Condition) then
    VisitProc(AIfStmt.ThenPart)
  else if Assigned(AIfStmt.ElseIfs) then
  begin
    for i := 0 to AIfStmt.ElseIfs.Count-1 do
    begin
      if isBooleanAndTrue(AIfStmt.ElseIfs[i]) then
      begin
        VisitProc(AIfStmt.ElseIfParts[i]);
        ElseIfExecuted := True;
        Break;
      end;
    end;
    if not ElseIfExecuted then
      if Assigned(AIfStmt.ElsePart) then
        VisitProc(AIfStmt.ElsePart);
  end
  else if Assigned(AIfStmt.ElsePart) then
    VisitProc(AIfStmt.ElsePart);
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
  Writeln;
end;

procedure TInterpreter.VisitProduct(AProduct: TProduct);
var
  Node: TNode;
begin
  for Node in AProduct.Nodes do
    VisitProc(Node);
end;

procedure TInterpreter.VisitRepeatStmt(ARepeatStmt: TRepeatStmt);
var
  Condition: Variant;
begin
  try
    Condition := VisitFunc(ARepeatStmt.Condition);
    if VarIsType(Condition, varBoolean) then
    begin
      repeat
        try
          VisitProc(ARepeatStmt.Block);
        except on E: EContinueException do;
        end;
        Condition := VisitFunc(ARepeatStmt.Condition);
      until Condition;
    end
    else
      Raise ERuntimeError.Create(ARepeatStmt.Token, ErrConditionNotBoolean);
  except on E: EBreakException do;
  end;
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
  if Assigned(AVarDecl) then
  begin
    CheckDuplicate(AVarDecl.Identifier, 'Variable');
    FCurrentSpace.Store(AVarDecl.Identifier, VisitFunc(AVarDecl.Expr));
  end;
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

procedure TInterpreter.VisitWhileStmt(AWhileStmt: TWhileStmt);
var
  Condition: Variant;
begin
  try
    Condition := VisitFunc(AWhileStmt.Condition);
    if VarIsType(Condition, varBoolean) then
    begin
      while Condition do
      begin
        try
          VisitProc(AWhileStmt.Block);
        except on E: EContinueException do;
        end;
        Condition := VisitFunc(AWhileStmt.Condition);
      end;
    end
    else
      Raise ERuntimeError.Create(AWhileStmt.Token, ErrConditionNotBoolean);
  except on E: EBreakException do;
  end;
end;

end.
