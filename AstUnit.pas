unit AstUnit;

interface
uses
  System.Classes, System.SysUtils, TokenUnit, Variants, System.Generics.Collections;

type
  TNode = class
    private
      FToken: TToken;
    public
      property Token: TToken read FToken;
      constructor Create(AToken: TToken);
  end;

  TNodeList = TObjectList<TNode>;

  TBlock = class(TNode)
    private
      FNodes: TNodeList;
    public
      property Nodes: TNodeList read FNodes;
      constructor Create(ANodes: TNodeList; AToken: TToken);
      destructor Destroy; override;
  end;

  TExpr = class(TNode)
    // Base node for expression
  end;

  TExprList = TObjectList<TExpr>;

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
      constructor Create(ALeft: TExpr; AOp: TToken; ARight: TExpr);
      destructor Destroy; override;
  end;

  TUnaryExpr = class(TFactorExpr)
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

  TIdentifier = class(TNode)
    private
      FText: string;
    public
      property Text: string read FText;
      constructor Create(AToken: TToken);
  end;

  //Statements
  TStmt = class(TNode)
    // Base class for statements
  end;

  TPrintStmt = class(TStmt)
    private
      FExprList: TExprList;
    public
      property ExprList: TExprList read FExprList;
      constructor Create(AExprList: TExprList; AToken: TToken);
      destructor Destroy; override;
  end;

  TDecl = class(TNode)
    // Base class for statements
    private
      FIdentifier: TIdentifier;
    public
      property Identifier: TIdentifier read FIdentifier;
      constructor Create(AIdentifier: TIdentifier; AToken: TToken);
      destructor Destroy; override;
  end;

  TVarDecl = class(TDecl)
    private
      FExpr: TExpr;
      FIsConst: Boolean;
    public
      property Expr: TExpr read FExpr;
      property IsConst: Boolean read FIsConst;
      constructor Create(AIdentifier: TIdentifier; AExpr: TExpr; AToken: TToken; AIsConst: Boolean);
      destructor Destroy; override;
  end;


  TProduct = class(TBlock)
  end;


implementation

{ TNode }

constructor TNode.Create(AToken: TToken);
begin
  FToken := AToken;
end;

{ TBinaryExpr }

constructor TBinaryExpr.Create(ALeft: TExpr; AOp: TToken; ARight: TExpr);
begin
  inherited Create(AOp);
  FLeft := ALeft;
  FOp := AOp;
  FRight := ARight;
//  Writeln('TBinaryExpr.Create ', AOp.ToString);
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

constructor TUnaryExpr.Create(AOp: TToken; AExpr: TExpr);
begin
  inherited Create(AOp);
  FOp := AOp;
  FExpr := AExpr;
//  WriteLn('TUnaryExpression.Create ', AOp.ToString);
end;

destructor TUnaryExpr.Destroy;
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
//  Writeln('TConstExpr.Create ', VarToStr(Constant));
end;

{ TBlock }

constructor TBlock.Create(ANodes: TNodeList; AToken: TToken);
begin
  inherited Create(AToken);
  FNodes := ANodes;
end;

destructor TBlock.Destroy;
begin
  if Assigned(FNodes) then
    FreeAndNil(FNodes);

  inherited;
end;

{ TPrintStmt }

constructor TPrintStmt.Create(AExprList: TExprList; AToken: TToken);
begin
  inherited Create(AToken);
  FExprList := AExprList;
end;

destructor TPrintStmt.Destroy;
begin
  if Assigned(FExprList) then
    FreeAndNil(FExprList);

  inherited;
end;

{ TIdentifier }

constructor TIdentifier.Create(AToken: TToken);
begin
  inherited Create(AToken);
  FText := Atoken.Lexeme;
end;

{ TDecl }

constructor TDecl.Create(AIdentifier: TIdentifier; AToken: TToken);
begin
  inherited Create(AToken);
  FIdentifier := AIdentifier;
end;

destructor TDecl.Destroy;
begin
  if Assigned(FIdentifier) then
    FreeAndNil(FIdentifier);

  inherited;
end;

{ TVarDecl }

constructor TVarDecl.Create(AIdentifier: TIdentifier; AExpr: TExpr;  AToken: TToken; AIsConst: Boolean);
begin
  inherited Create(AIdentifier, AToken);
  FExpr := AExpr;
  FIsConst := AIsConst;
end;

destructor TVarDecl.Destroy;
begin
  if Assigned(FExpr) then
    FreeAndNil(FExpr);

  inherited;
end;

end.

