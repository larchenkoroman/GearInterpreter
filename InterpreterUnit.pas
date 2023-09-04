unit InterpreterUnit;

interface

uses
  System.Classes, System.SysUtils, System.Variants, VisitorUnit, AstUnit, TokenUnit, ErrorUnit, EvalMathUnit;

type
  TInterpreter = class(TVisitor)
    public
      procedure Execute(Tree: TProduct);
    published
      //expressions
      function VisitBinaryExpr(ABinaryExpr: TBinaryExpr): Variant;
      function VisitConstExpr(AConstExpr: TConstExpr): Variant;
      function VisitUnaryExpr(AUnaryExpr: TUnaryExpr): Variant;
      //statements
      //declaretions
      //blocks
      function VisitProduct(Product: TProduct): Variant;
  end;

implementation

{ TInterpreter }

procedure TInterpreter.Execute(Tree: TProduct);
var
  Value: Variant;
begin
  try
    Value := VisitFunc(Tree);
    Writeln(VarToStrDef(Value, 'Null'));
  except
    on E: ERunTimeError do
      RuntimeError(E);
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
//    ttOr:   Result := TMath._Or(Left, Right, Op);
//    ttAnd:  Result := TMath._And(Left, Right, Op);
//    ttXor:  Result := TMath._Xor(Left, Right, Op);
//    ttShl:  Result := TMath._Shl(Left, Right, Op);
//    ttShr:  Result := TMath._Shr(Left, Right, Op);
    ttPow:  Result := TMath._Pow(Left, Right, Op);
//    ttEQ:   Result := TMath._EQ(Left, Right, Op);
//    ttNEQ:  Result := TMath._NEQ(Left, Right, Op);
//    ttGT:   Result := TMath._GT(Left, Right, Op);
//    ttGE:   Result := TMath._GE(Left, Right, Op);
//    ttLT:   Result := TMath._LT(Left, Right, Op);
//    ttLE:   Result := TMath._LE(Left, Right, Op);
  end;
end;

function TInterpreter.VisitConstExpr(AConstExpr: TConstExpr): Variant;
begin
  Result := AConstExpr.Value;
end;

function TInterpreter.VisitProduct(Product: TProduct): Variant;
begin
  Result := VisitFunc(Product.Node);
end;

function TInterpreter.VisitUnaryExpr(AUnaryExpr: TUnaryExpr): Variant;
var
  Expr: Variant;
begin
  Expr := VisitFunc(AUnaryExpr.Expr);
  case AUnaryExpr.Op.TokenType of
//    ttNot: Result := TMath._Not(Expr, UnaryExpr.Op);
    ttMinus: Result := TMath._Neg(Expr, AUnaryExpr.Op);
    else Result := Expr;
  end;
end;

end.
