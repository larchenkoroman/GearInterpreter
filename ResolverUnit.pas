unit ResolverUnit;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Variants, AstUnit, TokenUnit, ErrorUnit, VisitorUnit;

type
  TStatus = (sDeclared, sEnabled);

  TSymbol = class
    public
      Name: string;
      Status: TStatus;
      IsConst: Boolean;
      IsNull: Boolean;
      constructor Create(const AName: string; const AStatus: TStatus; const AIsConst: Boolean);
  end;

  TScope = class(TObjectDictionary<string, TSymbol>)
    private
      FEnclosing: TScope;
    public
      property Enclosing: TScope read FEnclosing;
      constructor Create(AEnclosing: TScope = nil);
      procedure AddSymbol(ASymbol: TSymbol);
      function LookUp(AName: string): TSymbol;
  end;

  TScopes = class(TObjectList<TScope>)
    public
      procedure Push(AItem: TScope);
      procedure Pop;
      function Top: TScope;
  end;

  TResolver = class(TVisitor)
    private
      FGlobalScope: TScope;
      FCurrentScope: TScope;
      FScopes: TScopes;
      procedure BeginScope;
      procedure EndScope;
      procedure ResolveLocal(AVariable: TVariable);
      procedure Declare(AIdentifier: TIdentifier; const AIsConst: Boolean = False);
      procedure Enable(AIdentifier: TIdentifier);
      function Retrieve(AIdentifier: TIdentifier): TSymbol;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Resolve(ATree: TProduct);
    published
      procedure VisitNode(ANode: TNode);
      procedure VisitIdentifier(AIdentifier: TIdentifier);
      // Expr
      procedure VisitBinaryExpr(ABinaryExpr: TBinaryExpr);
      procedure VisitConstExpr(AConstExpr: TConstExpr);
      procedure VisitUnaryExpr(AUnaryExpr: TUnaryExpr);
      procedure VisitVariable(AVariable: TVariable);
      // Stmt
      procedure VisitPrintStmt(APrintStmt: TPrintStmt);
      procedure VisitAssignStmt(AAssignStmt: TAssignStmt);
      procedure VisitIfStmt(AIfStmt: TIfStmt);
      procedure VisitWhileStmt(AWhileStmt: TWhileStmt);
      procedure VisitRepeatStmt(ARepeatStmt: TRepeatStmt);
      procedure VisitForStmt(AForStmt: TForStmt);
      // Decl
      procedure VisitVarDecl(AVarDecl: TVarDecl);
      procedure VisitVarDecls(AVarDecls: TVarDecls);
      procedure VisitBlock(ABlock: TBlock);
      procedure VisitProduct(AProduct: TProduct);
  end;

implementation

const
  ErrCannotReadLocalVar = 'Cannot read local variable in its own declaration.';
  ErrCannotAssignToConstant = 'Cannot assign value to constant "%s".';
  ErrDuplicateIdInScope = 'Duplicate identifier "%s" in this scope.';
  ErrUndeclaredVar = 'Undeclared variable "%s".';


{ TSymbol }

constructor TSymbol.Create(const AName: string; const AStatus: TStatus;  const AIsConst: Boolean);
begin
  Name := AName;
  Status := AStatus;
  IsConst := AIsConst;
  isNull := False;
end;

{ TScope }

procedure TScope.AddSymbol(ASymbol: TSymbol);
begin
  Add(ASymbol.Name, ASymbol);
end;

constructor TScope.Create(AEnclosing: TScope);
begin
  inherited Create([doOwnsValues]);
  FEnclosing := AEnclosing;
end;

function TScope.LookUp(AName: string): TSymbol;
begin
  if ContainsKey(AName) then
    Result := Items[AName]
  else if Assigned(FEnclosing) then
    Result := FEnclosing.LookUp(AName)
  else
    Result := nil;
end;

{ TResolver }

procedure TResolver.BeginScope;
begin
  FScopes.Push(TScope.Create(FCurrentScope));
  FCurrentScope := FScopes.Top;
end;

constructor TResolver.Create;
begin
  FGlobalScope := TScope.Create;
  FCurrentScope := FGlobalScope;
  FScopes := TScopes.Create(True);
end;

procedure TResolver.Declare(AIdentifier: TIdentifier; const AIsConst: Boolean);
begin
  if FCurrentScope.ContainsKey(AIdentifier.Text) then
    Errors.Append(AIdentifier.Token.Line, AIdentifier.Token.Col,
                    Format(ErrDuplicateIdInScope, [AIdentifier.Text]))
  else
    FCurrentScope.AddSymbol(TSymbol.Create(AIdentifier.Text, sDeclared, AIsConst));
end;

destructor TResolver.Destroy;
begin
  if Assigned(FGlobalScope) then
    FreeAndNil(FGlobalScope);

  FreeAndNil(FScopes);

end;

procedure TResolver.Enable(AIdentifier: TIdentifier);
var
  Symbol: TSymbol;
begin
  Symbol := Retrieve(AIdentifier);
  if Assigned(Symbol) then
    Symbol.Status := sEnabled;
end;

procedure TResolver.EndScope;
begin
  FCurrentScope := FScopes.Top.Enclosing;
  FScopes.Pop;
end;

procedure TResolver.Resolve(ATree: TProduct);
begin
  VisitProc(ATree);
end;

procedure TResolver.ResolveLocal(AVariable: TVariable);
var
  I: Integer;
begin
  for I := FScopes.Count - 1 downto 0 do
  begin
    if FScopes[I].ContainsKey(AVariable.Identifier.Text) then
    begin
      AVariable.Distance := FScopes.Count - 1 - I;
      Break;
    end;
  end;
end;

function TResolver.Retrieve(AIdentifier: TIdentifier): TSymbol;
begin
  Result := FCurrentScope.Lookup(AIdentifier.Text);
  if not Assigned(Result) then
    Errors.Append(AIdentifier.Token.Line, AIdentifier.Token.Col,
                    Format(ErrUndeclaredVar, [AIdentifier.Text]));
end;

procedure TResolver.VisitIfStmt(AIfStmt: TIfStmt);
begin
  VisitProc(AIfStmt.Condition);
  VisitProc(AIfStmt.ThenPart);

  if Assigned(AIfStmt.ElsePart) then
    VisitProc(AIfStmt.ElsePart);
end;

procedure TResolver.VisitAssignStmt(AAssignStmt: TAssignStmt);
var
  Symbol: TSymbol;
  Identifier: TIdentifier;
begin
  VisitProc(AAssignStmt.Expr);
  Identifier := AAssignStmt.Variable.Identifier;
  Symbol := Retrieve(Identifier);
  if Assigned(Symbol) then
  begin
    if Symbol.IsConst then
      Errors.Append(Identifier.Token, Format(ErrCannotAssignToConstant, [Identifier.Text]))
    else if Symbol.isNull then
      Symbol.isNull := False;
    ResolveLocal(AAssignStmt.Variable);
  end;
end;

procedure TResolver.VisitBinaryExpr(ABinaryExpr: TBinaryExpr);
begin
  VisitProc(ABinaryExpr.Left);
  VisitProc(ABinaryExpr.Right);
end;

procedure TResolver.VisitBlock(ABlock: TBlock);
var
  Node: TNode;
begin
  BeginScope;

  for Node in ABlock.Nodes do
    VisitProc(Node);

  EndScope
end;

procedure TResolver.VisitConstExpr(AConstExpr: TConstExpr);
begin
//do nothing
end;

procedure TResolver.VisitForStmt(AForStmt: TForStmt);
begin
  BeginScope;
  VisitProc(AForStmt.VarDecl);
  VisitProc(AForStmt.Condition);
  VisitProc(AForStmt.Iterator);
  VisitProc(AForStmt.Block);
  EndScope;
end;

procedure TResolver.VisitIdentifier(AIdentifier: TIdentifier);
begin
//do nothing
end;

procedure TResolver.VisitNode(ANode: TNode);
begin
//do nothing
end;

procedure TResolver.VisitPrintStmt(APrintStmt: TPrintStmt);
var
  Expr: TExpr;
begin
  for Expr in APrintStmt.ExprList do
    VisitProc(Expr);
end;

procedure TResolver.VisitProduct(AProduct: TProduct);
var
  Node: TNode;
begin
  for Node in AProduct.Nodes do
    VisitProc(Node);
end;

procedure TResolver.VisitRepeatStmt(ARepeatStmt: TRepeatStmt);
begin
  VisitProc(ARepeatStmt.Condition);
  VisitProc(ARepeatStmt.Block);
end;

procedure TResolver.VisitUnaryExpr(AUnaryExpr: TUnaryExpr);
begin
  VisitProc(AUnaryExpr.Expr);
end;

procedure TResolver.VisitVarDecl(AVarDecl: TVarDecl);
var
  Symbol: TSymbol;
begin
  Declare(AVarDecl.Identifier, AVarDecl.IsConst);
  VisitProc(AVarDecl.Expr);
  Enable(AVarDecl.Identifier);

  if    (AVarDecl.Expr is TConstExpr)
    and ((AVarDecl.Expr as TConstExpr).Token.TokenType = ttNull) then
  begin
    Symbol := Retrieve(AVarDecl.Identifier);
    Symbol.isNull := True;
  end;
end;

procedure TResolver.VisitVarDecls(AVarDecls: TVarDecls);
var
  Decl: TDecl;
begin
  for Decl in AVarDecls.List do
    VisitProc(Decl);
end;

procedure TResolver.VisitVariable(AVariable: TVariable);
var
  Symbol: TSymbol;
begin
  Symbol := Retrieve(AVariable.Identifier);
  if Assigned(Symbol) then
  begin
    if Symbol.Status = sDeclared then
      Errors.Append(AVariable.Token, ErrCannotReadLocalVar);

    ResolveLocal(AVariable);
  end;
end;

procedure TResolver.VisitWhileStmt(AWhileStmt: TWhileStmt);
begin
  VisitProc(AWhileStmt.Condition);
  VisitProc(AWhileStmt.Block);
end;

{ TScopes }

procedure TScopes.Pop;
begin
  Remove(Last);
end;

procedure TScopes.Push(AItem: TScope);
begin
  Add(AItem);
end;

function TScopes.Top: TScope;
begin
  Result := Last;
end;

end.
