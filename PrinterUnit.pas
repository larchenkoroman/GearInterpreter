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
      //statements
      //declarattions
      //blocks
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

procedure TPrinter.VisitBinaryExpr(ABinaryExpr: TBinaryExpr);
begin
  IncIndent;
  Writeln(FIndent, '(', ABinaryExpr.Op.TokenType.ToString, ')');
  VisitProc(ABinaryExpr.Left);
  VisitProc(ABinaryExpr.Right);
  DecIndent;
end;

procedure TPrinter.VisitConstExpr(AConstExpr: TConstExpr);
begin
  IncIndent;
  Writeln(FIndent, VarToStrDef(AConstExpr.Value, 'Null'));
  DecIndent;
end;

procedure TPrinter.VisitNode(Node: TNode);
begin
  Writeln(FIndent + string(Node.ClassName).Substring(1));
end;

procedure TPrinter.VisitProduct(AProduct: TProduct);
begin
  DecIndent;
  VisitNode(AProduct);
  VisitProc(AProduct.Node);
  DecIndent;
end;

procedure TPrinter.VisitUnaryExpr(AUnaryExpr: TUnaryExpr);
begin
  IncIndent;
  Writeln(FIndent, '(', AUnaryExpr.Op.TokenType.ToString, ')');
  VisitProc(AUnaryExpr.Expr);
  DecIndent;
end;

end.