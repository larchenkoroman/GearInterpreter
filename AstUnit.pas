unit AstUnit;

interface
uses
  System.Classes, System.SysUtils, TokenUnit;

type
  TNode = class
    private
      FToken: TToken;
    public
      property Token: TToken read FToken;
      constructor Create(AToken: TToken);
  end;

  TExpr = class(TNode)
    // Base node for expression
  end;

  TFactorExpr = class(TExpr)
    //Base node fo parsing a factor
  end;

  TBinaryExpr = class(TExpr)
    private
      FLeft, FRight: TExpr;
      FOp: TToken;
    public
      property Left: TExpr read FLeft;
      property Right: TExpr read FRight;
      property Op: TToken read FOp;
      constructor Create(ALeft, ARight: TExpr; AOp: TToken);
      destructor Destroy; override;
  end;

  TUnaryExpression = class(TFactorExpr)
    private
      FOp: TToken;
      FExpr: TExpr;
    public
      property Op: TToken read FOp;
      property Expr: TExpr read FExpr;
      constructor Create(AOp: TToken; AExpr: TExpr);
      destructor Destroy; override;
  end;

  TConstExpr = class(TFactorExpr)
    private
      FValue: Variant;
    public
      property Value: Variant read FValue;
      constructor Create(Constant: Variant; AToken: TToken);
  end;

  TProduct = class(TNode)
    private
      FNode: TNode;
    public
      property Node: TNode read FNode;
      constructor Create(ANode: TNode; AToken: TToken);
      destructor Destroy; override;
  end;


implementation

{ TNode }

constructor TNode.Create(AToken: TToken);
begin
  FToken :=AToken;
end;

{ TBinaryExpr }

constructor TBinaryExpr.Create(ALeft, ARight: TExpr; AOp: TToken);
begin
  inherited Create(AOp);
  FLeft := ALeft;
  FOp := AOp;
  ARight := ARight;
end;

destructor TBinaryExpr.Destroy;
begin
  if Assigned(FLeft) then
    FreeAndNil(FLeft);

  if Assigned(FRight) then
    FreeAndNil(FRight);

  inherited;
end;

{ TUnaryExpression }

constructor TUnaryExpression.Create(AOp: TToken; AExpr: TExpr);
begin
  inherited Create(AOp);
  FOp := AOp;
  FExpr := AExpr;
end;

destructor TUnaryExpression.Destroy;
begin
  if Assigned(FExpr) then
    FreeAndNil(FExpr);

  inherited;
end;

{ TConstExpr }

constructor TConstExpr.Create(Constant: Variant; AToken: TToken);
begin
  inherited Create(AToken);
  FValue := Constant;
end;

{ TProduct }

constructor TProduct.Create(ANode: TNode; AToken: TToken);
begin
  inherited Create(AToken);
  FNode := ANode;
end;

destructor TProduct.Destroy;
begin
  if Assigned(FNode) then
    FreeAndNil(FNode);

  inherited;
end;

end.
