unit PrinterUnit;

interface

uses
  System.Classes, System.SysUtils, System.Variants, AstUnit, TokenUnit, VisitorUnit;

type
  TPrinter = class(TVisitor)
    private
      const
        INCREASE = 2;
      var
        FIndent: string;
        FTree: TProduct;
      procedure IncIndent;
      procedure DecIndent;
    public
      constructor Create(ATree: TProduct);
      procedure Print;
    published
      procedure VisitNode(Node: TNode);
      //expressions
      procedure VisitBinaryExpr(ABinaryExpr: TBinaryExpr);
      procedure VisitConstExpr(AConstExpr: TConstExpr);
      procedure VisitUnaryExpr(AUnaryExpr: TUnaryExpr);
      procedure VisitCallExpr(ACallExpr: TCallExpr);
      procedure VisitIfExpr(AIfExpr: TIfExpr);
      //statements
      procedure VisitAssignStmt(AAssignStmt: TAssignStmt);
      procedure VisitIfStmt(AIfStmt: TIfStmt);
      procedure VisitWhileStmt(AWhileStmt: TWhileStmt);
      procedure VisitRepeatStmt(RepeatStmt: TRepeatStmt);
      procedure VisitForStmt(AForStmt: TForStmt);
      procedure VisitBreakStmt(ABreakStmt: TBreakStmt);
      procedure VisitContinueStmt(AContinueStmt: TContinueStmt);
      procedure VisitReturnStmt(AReturnStmt: TReturnStmt);
      procedure VisitCallExprStmt(ACallExprStmt: TCallExprStmt);
      //declarattions
      procedure VisitIdentifier(AIdentifier: TIdentifier);
      procedure VisitVarDecl(AVarDecl: TVarDecl);
      procedure VisitVarDecls(AVarDecls: TVarDecls);
      procedure VisitVariable(AVariable: TVariable);
      procedure VisitFuncDecl(AFuncDecl: TFuncDecl);
      //blocks
      procedure VisitBlock(ABlock: TBlock);
      procedure VisitPrintStmt(ANode: TPrintStmt);
      procedure VisitProduct(AProduct: TProduct);
  end;

implementation

{ TPrinter }

constructor TPrinter.Create(ATree: TProduct);
begin
  FIndent := '  ';
  FTree := ATree;
end;

procedure TPrinter.DecIndent;
begin
  FIndent := StringOfChar(' ', FIndent.Length - INCREASE);
end;

procedure TPrinter.IncIndent;
begin
  FIndent := StringOfChar(' ', FIndent.Length + INCREASE);
end;

procedure TPrinter.Print;
begin
  VisitProc(FTree);
  Writeln;
end;

procedure TPrinter.VisitAssignStmt(AAssignStmt: TAssignStmt);
begin
  IncIndent;
  VisitNode(AAssignStmt);
  WriteLn(FIndent, '(', AAssignStmt.Op.TokenType.toString, ')');
  VisitProc(AAssignStmt.Variable);
  VisitProc(AAssignStmt.Expr);
  DecIndent;
end;

procedure TPrinter.VisitBinaryExpr(ABinaryExpr: TBinaryExpr);
begin
  IncIndent;
  Writeln(FIndent, '(', ABinaryExpr.Op.TokenType.ToString, ')');
  VisitProc(ABinaryExpr.Left);
  VisitProc(ABinaryExpr.Right);
  DecIndent;
end;

procedure TPrinter.VisitBlock(ABlock: TBlock);
var
  Node: TNode;
begin
  IncIndent;
  VisitNode(ABlock);
  for Node in ABlock.Nodes do
    VisitProc(Node);
  DecIndent;
end;

procedure TPrinter.VisitBreakStmt(ABreakStmt: TBreakStmt);
begin
  IncIndent;
  VisitNode(ABreakStmt);
  if Assigned(ABreakStmt.Condition) then
    VisitProc(ABreakStmt.Condition);
  DecIndent;
end;

procedure TPrinter.VisitCallExpr(ACallExpr: TCallExpr);
var
  i: Integer;
begin
  IncIndent;
  VisitNode(ACallExpr);
  VisitProc(ACallExpr.Callee);
  IncIndent;
  Writeln(FIndent, 'Arguments:');
  for i := 0 to ACallExpr.Args.Count - 1 do
    VisitProc(ACallExpr.Args[i].Expr);
  DecIndent;
  DecIndent;
end;

procedure TPrinter.VisitCallExprStmt(ACallExprStmt: TCallExprStmt);
begin
  IncIndent;
  VisitNode(ACallExprStmt);
  VisitProc(ACallExprStmt.CallExpr);
  DecIndent;
end;

procedure TPrinter.VisitConstExpr(AConstExpr: TConstExpr);
begin
  IncIndent;
  Writeln(FIndent, VarToStrDef(AConstExpr.Value, 'Null'));
  DecIndent;
end;

procedure TPrinter.VisitContinueStmt(AContinueStmt: TContinueStmt);
begin
  IncIndent;
  VisitNode(AContinueStmt);
  DecIndent;
end;

procedure TPrinter.VisitForStmt(AForStmt: TForStmt);
begin
  IncIndent;
  VisitNode(AForStmt);
  VisitProc(AForStmt.VarDecl);
  Writeln(FIndent, 'Condition:');
  VisitProc(AForStmt.Condition);
  VisitProc(AForStmt.Iterator);
  IncIndent;
  WriteLn(FIndent, 'Loop:');
  VisitProc(AForStmt.Block);
  DecIndent;
  DecIndent;
end;

procedure TPrinter.VisitFuncDecl(AFuncDecl: TFuncDecl);
var
  i: Integer;
begin
  IncIndent;
  VisitNode(AFuncDecl);  // Print FuncDecl
  if Assigned(AFuncDecl.Identifier) then
    VisitProc(AFuncDecl.Identifier);
  IncIndent;
  WriteLn(FIndent, 'Parameters:');
  for i := 0 to AFuncDecl.Params.Count-1 do
  begin
    VisitProc(AFuncDecl.Params[i].FIdentifier);
  end;
  DecIndent;
  VisitProc(AFuncDecl.Body);
  DecIndent;
end;

procedure TPrinter.VisitIdentifier(AIdentifier: TIdentifier);
begin
  IncIndent;
  Writeln(FIndent + 'Identifier: ' + AIdentifier.Text);
  DecIndent;
end;

procedure TPrinter.VisitIfExpr(AIfExpr: TIfExpr);
begin
  IncIndent;
  VisitNode(AIfExpr);
  VisitProc(AIfExpr.Condition);
  IncIndent;
  Writeln(FIndent, 'True:');
  VisitProc(AIfExpr.TrueExpr);
  Writeln(FIndent, 'False:');
  VisitProc(AIfExpr.FalseExpr);
  DecIndent;
  DecIndent;
end;

procedure TPrinter.VisitIfStmt(AIfStmt: TIfStmt);
var
  i: Integer;
begin
  IncIndent;
  VisitNode(AIfStmt);
  VisitProc(AIfStmt.Condition);
  IncIndent;
  WriteLn(FIndent, 'ThenPart:');
  VisitProc(AIfStmt.ThenPart);
  if Assigned(AIfStmt.ElseIfs) then
  begin
    WriteLn(FIndent, 'IfElseParts:');
    for i := 0 to AIfStmt.ElseIfs.Count-1 do
    begin
      VisitProc(AIfStmt.ElseIfs[i]);
      VisitProc(AIfStmt.ElseIfParts[i]);
    end;
  end;
  if Assigned(AIfStmt.ElsePart) then
  begin
    WriteLn(FIndent, 'ElsePart:');
    VisitProc(AIfStmt.ElsePart);
  end;
  DecIndent;
  DecIndent;
end;

procedure TPrinter.VisitNode(Node: TNode);
begin
  Writeln(FIndent, Node.ClassName.Substring(1));
end;

procedure TPrinter.VisitPrintStmt(ANode: TPrintStmt);
var
  Expr: TExpr;
begin
  IncIndent;
  VisitNode(ANode);
  for Expr in ANode.ExprList do
    VisitProc(Expr);
  DecIndent;
end;

procedure TPrinter.VisitProduct(AProduct: TProduct);
var
  Node: TNode;
begin
  IncIndent;
  VisitNode(AProduct);
  for Node in AProduct.Nodes do
    VisitProc(Node);
  DecIndent;
end;

procedure TPrinter.VisitRepeatStmt(RepeatStmt: TRepeatStmt);
begin
  IncIndent;
  VisitNode(RepeatStmt);
  VisitProc(RepeatStmt.Condition);
  IncIndent;
  WriteLn(FIndent, 'Loop:');
  VisitProc(RepeatStmt.Block);
  DecIndent;
  DecIndent;
end;

procedure TPrinter.VisitReturnStmt(AReturnStmt: TReturnStmt);
begin
  IncIndent;
  VisitNode(AReturnStmt);
  VisitProc(AReturnStmt.Expr);
  DecIndent;
end;

procedure TPrinter.VisitUnaryExpr(AUnaryExpr: TUnaryExpr);
begin
  IncIndent;
  Writeln(FIndent, '(', AUnaryExpr.Op.TokenType.ToString, ')');
  VisitProc(AUnaryExpr.Expr);
  DecIndent;
end;

procedure TPrinter.VisitVarDecl(AVarDecl: TVarDecl);
begin
  IncIndent;
  VisitNode(AVarDecl);

  if AVarDecl.IsConst then
    Writeln(FIndent, 'Const ')
  else
    Writeln(FIndent, 'Var ');

  VisitProc(AVarDecl.Identifier);

  VisitProc(AVarDecl.Expr);
  DecIndent;
end;

procedure TPrinter.VisitVarDecls(AVarDecls: TVarDecls);
var
  Decl: TDecl;
begin
  for Decl in AVarDecls.List do
    VisitProc(Decl);
end;

procedure TPrinter.VisitVariable(AVariable: TVariable);
begin
  IncIndent;
  WriteLn(FIndent, 'Var: ', AVariable.Identifier.Text);
  DecIndent;
end;

procedure TPrinter.VisitWhileStmt(AWhileStmt: TWhileStmt);
begin
  IncIndent;
  VisitNode(AWhileStmt);
  VisitProc(AWhileStmt.Condition);
  IncIndent;
  WriteLn(FIndent, 'Loop:');
  VisitProc(AWhileStmt.Block);
  DecIndent;
  DecIndent;
end;

end.
