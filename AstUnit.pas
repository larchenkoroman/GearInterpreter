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

  TBlocks = TObjectList<TBlock>;

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

  TCallExpr = class(TExpr)
    private
      type
        TArg = class
          Expr: TExpr;
          constructor Create(AExpr: TExpr);
          destructor Destroy; override;
        end;
        TArgs = TObjectList<TArg>;
    private
      FCallee: TExpr;
      FArgs: TArgs;
    public
      property Callee: TExpr read FCallee;
      property Args: TArgs read FArgs;
      constructor Create(ACallee: TExpr; AToken: TToken);
      destructor Destroy; override;
      procedure AddArgument(AExpr: TExpr);
  end;


  TIdentifier = class(TNode)
    private
      FText: string;
    public
      property Text: string read FText;
      constructor Create(AToken: TToken);
  end;

  TVariable = class(TFactorExpr)
    private
      FIdentifier: TIdentifier;
      FDistance: Integer;
    public
      property Identifier: TIdentifier read FIdentifier;
      property Distance: Integer read FDistance write FDistance;
      constructor Create(AIdentifier: TIdentifier);
      destructor Destroy; override;
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

  TAssignStmt = class(TStmt)
    private
      FVariable: TVariable;
      FOp: TToken;
      FExpr: TExpr;
    public
      property Variable: TVariable read FVariable;
      property Op: TToken read FOp;
      property Expr: TExpr read FExpr;
      constructor Create(AVariable: TVariable; AOp: TToken; AExpr: TExpr);
      destructor Destroy; override;
  end;

  TWhileStmt = class(TStmt)
    private
      FCondition: TExpr;
      FBlock: TBlock;
    public
      property Condition: TExpr read FCondition;
      property Block: TBlock read FBlock;
      constructor Create(ACondition: TExpr; ABlock: TBlock; AToken: TToken);
      destructor Destroy; override;
  end;

  TRepeatStmt = class(TStmt)
    private
      FCondition: TExpr;
      FBlock: TBlock;
    public
      property Condition: TExpr read FCondition;
      property Block: TBlock read FBlock;
      constructor Create(ACondition: TExpr; ABlock: TBlock; AToken: TToken);
      destructor Destroy; override;
  end;

  TBreakStmt = class(TStmt)
    private
      FCondition: TExpr;
    public
      property Condition: TExpr read FCondition;
      constructor Create(ACondition: TExpr; AToken: TToken);
      destructor Destroy; override;
  end;

  TContinueStmt = class(TStmt)
    //nothing here
  end;

  //Base class for declarations
  TDecl = class(TNode)
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

  TDeclList = TObjectList<TDecl>;

  TVarDecls = class(TDecl)
    private
      FList: TDeclList;
    public
      property List: TDeclList read FList;
      constructor Create(AList: TDeclList; AToken: TToken);
      destructor Destroy; override;
  end;

  TForStmt = class(TStmt)
    private
      FVarDecl: TVarDecl;
      FCondition: TExpr;
      FIterator: TStmt;
      FBlock: TBlock;
    public
      property VarDecl: TVarDecl read FVarDecl;
      property Condition: TExpr read FCondition;
      property Block: TBlock read FBlock;
      property Iterator: TStmt read FIterator;
      constructor Create(AVarDecl: TVarDecl; ACondition: TExpr; AIterator: TStmt; ABlock: TBlock; AToken: TToken);
      destructor Destroy; override;
  end;

  TIfStmt = class(TStmt)
    private
      FCondition: TExpr;
      FThenPart: TBlock;
      FElsePart: TBlock;
      FElseIfs: TExprList;
      FElseIfParts: TBlocks;
    public
      property Condition: TExpr read FCondition;
      property ThenPart: TBlock read FThenPart;
      property ElsePart: TBlock read FElsePart;
      property ElseIfs: TExprList read FElseIfs;
      property ElseIfParts: TBlocks read FElseIfParts;
      constructor Create(ACondition: TExpr; AElseIfs: TExprList; AElseIfParts: TBlocks;
                         AThenPart, AElsePart: TBlock; AToken: TToken);
      destructor Destroy; override;
  end;

  TFuncDecl = class(TDecl)
    private
      type
        TParam = class
          FIdentifier: TIdentifier;
          constructor Create(AIdentifier: TIdentifier);
          destructor Destroy; override;
        end;
        TParams = TObjectList<TParam>;
      var
        FParams: TParams;
        FBody: TBlock;
    public
      property Params: TParams read FParams;
      property Body: TBlock read FBody write FBody;
      constructor Create(AIdentifier: TIdentifier; AToken: TToken);
      destructor Destroy; override;
      procedure AddParam(AIdentifier: TIdentifier);
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

{ TVariable }

constructor TVariable.Create(AIdentifier: TIdentifier);
begin
  inherited Create(AIdentifier.Token);
  FIdentifier := AIdentifier;
  FDistance := -1;
end;

destructor TVariable.Destroy;
begin
  if Assigned(FIdentifier) then
    FreeAndNil(FIdentifier);

  inherited;
end;

{ TAssignStmt }

constructor TAssignStmt.Create(AVariable: TVariable; AOp: TToken; AExpr: TExpr);
begin
 inherited Create(AOp);
  FVariable := AVariable;
  FOp := AOp;
  FExpr := AExpr;
end;

destructor TAssignStmt.Destroy;
begin
  if Assigned(FVariable) then
    FreeAndNil(FVariable);

  if Assigned(FExpr) then
    FreeAndNil(FExpr);

  inherited;
end;

{ TVarDecls }

constructor TVarDecls.Create(AList: TDeclList; AToken: TToken);
begin
  Inherited Create(Nil, AToken);
  FList := AList;
end;

destructor TVarDecls.Destroy;
begin
  if Assigned(FList) then
    FreeAndNil(FList);

  inherited;
end;

{ TIfStmt }

constructor TIfStmt.Create(ACondition: TExpr; AElseIfs: TExprList; AElseIfParts: TBlocks;
                         AThenPart, AElsePart: TBlock; AToken: TToken);
begin
  inherited Create(AToken);
  FCondition := ACondition;
  FThenPart := AThenPart;
  FElsePart := AElsePart;
  FElseIfs := AElseIfs;
  FElseIfParts:= AElseIfParts;
end;

destructor TIfStmt.Destroy;
begin
  if Assigned(FCondition) then
    FreeAndNil(FCondition);

  if Assigned(FThenPart) then
    FreeAndNil(FThenPart);

  if Assigned(FElsePart) then
    FreeAndNil(FElsePart);

  if Assigned(FElseIfs) then
    FreeAndNil(FElseIfs);

  if Assigned(FElseIfParts) then
    FreeAndNil(FElseIfParts);

  inherited Destroy;
end;

{ TWhileStmt }

constructor TWhileStmt.Create(ACondition: TExpr; ABlock: TBlock; AToken: TToken);
begin
  inherited Create(AToken);
  FCondition := ACondition;
  FBlock := ABlock;
end;

destructor TWhileStmt.Destroy;
begin
  if Assigned(FCondition) then
    FreeAndNil(FCondition);

  if Assigned(FBlock) then
    FreeAndNil(FBlock);

  inherited Destroy;
end;

{ TRepeatStmt }

constructor TRepeatStmt.Create(ACondition: TExpr; ABlock: TBlock; AToken: TToken);
begin
  inherited Create(AToken);
  FCondition := ACondition;
  FBlock := ABlock;
end;

destructor TRepeatStmt.Destroy;
begin
  if Assigned(FCondition) then
    FreeAndNil(FCondition);

  if Assigned(FBlock) then
    FreeAndNil(FBlock);

  inherited Destroy;
end;


{ TForStmt }

constructor TForStmt.Create(AVarDecl: TVarDecl; ACondition: TExpr; AIterator: TStmt; ABlock: TBlock; AToken: TToken);
begin
  inherited Create(AToken);

  FVarDecl := AVarDecl;
  FCondition := ACondition;
  FIterator := AIterator;
  FBlock := ABlock;
end;

destructor TForStmt.Destroy;
begin
  if Assigned(FVarDecl) then
    FreeAndNil(FVarDecl);

  if Assigned(FCondition) then
    FreeAndNil(FCondition);

  if Assigned(FIterator) then
    FreeAndNil(FIterator);

  if Assigned(FBlock) then
    FreeAndNil(FBlock);

  inherited;
end;

{ TBreakStmt }

constructor TBreakStmt.Create(ACondition: TExpr; AToken: TToken);
begin
  inherited Create(AToken);
  FCondition := ACondition;
end;

destructor TBreakStmt.Destroy;
begin
  if Assigned(FCondition) then
    FreeandNil(FCondition);

  inherited Destroy;
end;

{ TFuncDecl.TParam }

constructor TFuncDecl.TParam.Create(AIdentifier: TIdentifier);
begin
  FIdentifier := AIdentifier;
end;

destructor TFuncDecl.TParam.Destroy;
begin
  if Assigned(FIdentifier) then
    FreeAndNil(FIdentifier);

  inherited;
end;

{ TFuncDecl }

procedure TFuncDecl.AddParam(AIdentifier: TIdentifier);
begin
  FParams.Add(TParam.Create(AIdentifier));
end;

constructor TFuncDecl.Create(AIdentifier: TIdentifier; AToken: TToken);
begin
  Inherited Create(AIdentifier, AToken);
  FBody := nil;
  FParams := TParams.Create(True);
end;

destructor TFuncDecl.Destroy;
begin
  FreeAndNil(FParams);

  if Assigned(FBody) then
    FreeAndNil(FBody);

  inherited;
end;

{ TCallExpr.TArg }

constructor TCallExpr.TArg.Create(AExpr: TExpr);
begin
  Expr := AExpr;
end;

destructor TCallExpr.TArg.Destroy;
begin
  if Assigned(Expr) then
    FreeAndNil(Expr);

  inherited;
end;

{ TCallExpr }

procedure TCallExpr.AddArgument(AExpr: TExpr);
begin
  FArgs.Add(TArg.Create(AExpr));
end;

constructor TCallExpr.Create(ACallee: TExpr; AToken: TToken);
begin
  inherited Create(AToken);
  FCallee := ACallee;
  FArgs := TArgs.Create(True);
end;

destructor TCallExpr.Destroy;
begin
  FreeAndNil(FArgs);
  if Assigned(FCallee) then
    FreeAndNil(FCallee);

  inherited;
end;

end.

