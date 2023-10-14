unit ParserUnit;

interface

uses
  System.Classes, System.SysUtils, Variants, LexerUnit, TokenUnit, AstUnit, ErrorUnit;

const
  DeclStartSet: TTokenTypeSet = [ttConst, ttVar, ttFunc];
  StmtStartSet: TTokenTypeSet = [ttIf, ttWhile, ttRepeat, ttFor, ttPrint, ttIdentifier, ttBreak, ttContinue, ttReturn];
  BlockEndSet: TTokenTypeSet  = [ttElse, ttElseIf, ttUntil, ttEnd, ttEOF];
  AssignSet: TTokenTypeSet    = [ttPlusIs, ttMinusIs, ttMulIs, ttDivIs, ttRemainderIs, ttAssign];

type
  TParser = class
    private
      type
        TFuncForm = (ffFunction, ffAnonym);
    private
      FTokens: TTokens;
      FCurrent: Integer;
      FLoopDepth: Integer;

      function CurrentToken: TToken;
      function ParseExprList: TExprList;
      function Peek: TToken;
      function IsLastToken: Boolean;
      procedure Error(AToken: TToken; AMsg: string);
      procedure Expect(const ATokenType:TTokenType);
      procedure Next;
      procedure Synchronize(ATypes: TTokenTypeSet);
      //Expressions
      function ParseExpr: TExpr;
      function IsRelOp: Boolean;
      function ParseAddExpr: TExpr;
      function IsAddOp: Boolean;
      function ParseMulExpr: TExpr;
      function IsMulOp: Boolean;

      function ParsePowExpr: TExpr;
      function IsPowOp: Boolean;
      function ParseIfExpr: TExpr;
      function ParseCaseExpr: TExpr;
      function ParseIdentifierExpr: TExpr;
      function ParseInterpolatedExpr: TExpr;

      function ParseUnaryExpr: TExpr;
      function ParseParenExpr: TExpr;
      function ParseFactor: TExpr;
      function ParseCallExpr: TExpr;
      function ParseCallArgs(ACallee: TExpr): TExpr;

      //Statements
      function ParseStmt: TStmt;
      function ParsePrintStmt: TStmt;
      function ParseAssignStmt:TStmt;
      function ParseIfStmt: TStmt;
      function ParseWhileStmt: TStmt;
      function ParseRepeatStmt: TStmt;
      function ParseForStmt: TStmt;
      function ParseBreakStmt: TStmt;
      function ParseContinueStmt: TStmt;
      function ParseReturnStmt: TStmt;
      //Declarations
      function ParseDecl: TDecl;
      function ParseVarDecl(AIsConst: Boolean): TDecl;
      function ParseVarDecls(AIsConst: Boolean): TDecl;
      function ParseIdentifier: TIdentifier;
      function ParseFuncDecl(AFuncForm: TFuncForm): TDecl;
      //Blocks
      function ParseNode: TNode;
      function ParseBlock: TBlock;
      function ParseProduct: TProduct;
    public
      constructor Create(ALexer: TLexer);
      function Parse: TProduct;
  end;

implementation

const
  ErrSyntax = 'Syntax error, "%s" expected.';
  ErrUnexpectedToken = 'Unexpected token: %s.';
  ErrDuplicateTerminator = 'Duplicate terminator not allowed.';
  ErrUnexpectedAttribute = 'Unexpected attribute "%s:".';
  ErrInvalidAssignTarget = 'Invalid assignment target.';
  ErrExpectedAssignOpFunc = 'Expected assignment operator, or function call.';
  ErrUnrecognizedDeclOrStmt = 'Unrecognized declaration or statement.';
  ErrBreakInLoop = 'Break can only be used from inside a loop.';
  ErrExpectedArrow = 'Expected arrow "=>".';
  ErrIncorrectInherit = 'Incorrect inheritance expression.';
  ErrUnallowedDeclIn = 'Unallowed declaration in "%s".';
  ErrNotExistsUseFile = 'Used file "%s" does not exist.';
  ErrIncorrectUseFile = 'Used file "%s" is incorrect or corrupt.';
  ErrNotAllowedInRange = 'Token "%s" not allowed in range expression.';
  ErrAtLeastOneEnum = 'At least one enum is required in declaration.';
  ErrDuplicateEnum = 'Duplicate enum name "%s".';
  ErrNotAllowedInEnum = 'Constant value "%s" not allowed in enum declaration.';
  ErrDuplicateSetName = 'Duplicate enum set name "%s".';
  ErrNotAFunction = '"%s" is not defined as function.';

{ TParser }

constructor TParser.Create(ALexer: TLexer);
begin
  FTokens := ALexer.Tokens;
  FCurrent := 0;
  FLoopDepth := 0;
end;

function TParser.CurrentToken: TToken;
begin
  Result := FTokens[FCurrent];
end;

procedure TParser.Error(AToken: TToken; AMsg: string);
begin
  Errors.Append(AToken.Line, AToken.Col, AMsg);
  Raise EParseError.Create(AMsg);
end;

procedure TParser.Expect(const ATokenType: TTokenType);
const
  Msg = 'Syntax error, ''%s'' expected.';
begin
  if CurrentToken.TokenType = ATokenType then
    Next
  else
    Error(CurrentToken, Format(Msg, [ATokenType.ToString]))
end;

function TParser.IsAddOp: Boolean;
begin
  Result := CurrentToken.TokenType in [ttPlus, ttMinus, ttOr, ttXor];
end;

function TParser.IsLastToken: Boolean;
begin
  Result := FCurrent = FTokens.Count - 1;
end;

function TParser.IsMulOp: Boolean;
begin
  Result := CurrentToken.TokenType in [ttMul, ttDiv, ttPow, ttRemainder, ttAnd];
end;

function TParser.IsPowOp: Boolean;
begin
  Result := CurrentToken.TokenType = ttPow;
end;

function TParser.IsRelOp: Boolean;
begin
  Result := CurrentToken.TokenType in [ttEQ, ttNEQ, ttGT, ttGE, ttLT, ttLE];
end;

procedure TParser.Next;
begin
  Inc(FCurrent);
end;

function TParser.Parse: TProduct;
begin
  Result := ParseProduct;
end;

function TParser.ParseAddExpr: TExpr;
var
  AddOp: TToken;
begin
  Result := ParseMulExpr;
  while IsAddOp do
  begin
    AddOp := CurrentToken;
    Next;
    Result := TBinaryExpr.Create(Result, AddOp, ParseMulExpr);
  end;
end;


function TParser.ParseAssignStmt: TStmt;
var
  Token, Op: TToken;
  Left, Right: TExpr;
begin
  Result := nil;
  Token := CurrentToken;
  Left := ParseExpr;
  if CurrentToken.TokenType in AssignSet then
  begin
    Op := CurrentToken;
    Next; // skip assign token
    Right := ParseExpr;
    if Left is TVariable then
    begin
      Result := TAssignStmt.Create(Left as TVariable, Op, Right);
    end
    else
      Error(Token, ErrInvalidAssignTarget);
  end
  else if Left is TCallExpr then
    Result := TCallExprStmt.Create(Left as TCallExpr, Token)
  else
    Error(CurrentToken, ErrExpectedAssignOpFunc);
end;

function TParser.ParseBlock: TBlock;
begin
  Result := TBlock.Create(TNodeList.Create(), CurrentToken);
  while not (CurrentToken.TokenType in BlockEndSet) do
    Result.Nodes.Add(ParseNode);
end;

function TParser.ParseBreakStmt: TStmt;
var
  Token: TToken;
  Condition: TExpr;
begin
  Condition := nil;
  if FLoopDepth = 0 then
    Error(CurrentToken, ErrBreakInLoop);
  Token := CurrentToken;
  Next; // skip Break
  if CurrentToken.TokenType = ttOn then
  begin
    Next; // skip On
    Condition := ParseExpr;
  end;
  Result := TBreakStmt.Create(Condition, Token);
end;

function TParser.ParseCallArgs(ACallee: TExpr): TExpr;
var
  CallExpr: TCallExpr;
  Token: TToken;

  procedure ParseArg;
  var
    Expr: TExpr;
  begin
    Expr := ParseExpr;
    CallExpr.AddArgument(Expr);
  end;

begin
  Token := CurrentToken;
  Next;  // skip (
  CallExpr := TCallExpr.Create(ACallee, Token);
  if CurrentToken.TokenType <> ttCloseParen then
  begin
    ParseArg;
    while CurrentToken.TokenType = ttComma do
    begin
      Next;  // skip ,
      ParseArg;
    end;
  end;
  Expect(ttCloseParen);
  Result := CallExpr;
end;

function TParser.ParseCallExpr: TExpr;
begin
  Result := ParseFactor;
  while CurrentToken.TokenType = ttOpenParen do
    Result := ParseCallArgs(Result);
end;

function TParser.ParseContinueStmt: TStmt;
begin
  Result := TContinueStmt.Create(CurrentToken);
  Next; // skip continue
end;

function TParser.ParseDecl: TDecl;
begin
  Result := nil;
  case CurrentToken.TokenType of
    ttVar, ttConst: Result := ParseVarDecls(CurrentToken.TokenType = ttConst);
    ttFunc:         Result := ParseFuncDecl(ffFunction);
  end;
end;

function TParser.ParseExpr: TExpr;
var
  RelOp: TToken;
begin
  Result := ParseAddExpr;
  if IsRelOp then
  begin
    RelOp := CurrentToken;
    Next;
    Result := TBinaryExpr.Create(Result, RelOp, ParseAddExpr);
  end;
end;

function TParser.ParseExprList: TExprList;
begin
  Result := TExprList.Create();
  Result.Add(ParseExpr);
  while CurrentToken.TokenType = ttComma do
  begin
    Next;  // skip ,
    Result.Add(ParseExpr);
  end;
end;

function TParser.ParseFactor: TExpr;
begin
  case CurrentToken.TokenType of
    ttFalse, ttTrue:
    begin
      Result := TConstExpr.Create(CurrentToken.TokenType = ttTrue, CurrentToken);
      Next;
    end;

    ttNull:
    begin
      Result := TConstExpr.Create(Null, CurrentToken);
      Next;
    end;

    ttNumber, ttString:
    begin
      Result := TConstExpr.Create(CurrentToken.Value, CurrentToken);
      Next;
    end;

    ttOpenParen:    Result := ParseParenExpr;
    ttFunc:         Result := TFuncDeclExpr.Create(ParseFuncDecl(ffAnonym) as TFuncDecl);
    ttIf:           Result := ParseIfExpr;
    ttCase:         Result := ParseCaseExpr;
    ttInterpolated: Result := ParseInterpolatedExpr;
    ttIdentifier:   Result := ParseIdentifierExpr;

    else
    begin
      Result := TExpr.Create(CurrentToken);
      Error(CurrentToken, 'Unexpected token: ' + CurrentToken.ToString + '.');
    end;
  end;
end;

function TParser.ParseForStmt: TStmt;
var
  Token: TToken;
  VarDecl: TVarDecl;
  Condition: TExpr;
  Iterator: TStmt;
  Block: TBlock;
begin
  try
    Inc(FLoopDepth);
    Token := CurrentToken;
    Next; // skip for
    Next; // skip var
    VarDecl := ParseVarDecl(False) as TVarDecl;
    Expect(ttSemiColon);
    Condition := ParseExpr;
    Expect(ttSemiColon);
    Iterator := ParseAssignStmt;
    Expect(ttDo);
    Block := ParseBlock;
    Expect(ttEnd);
    Result := TForStmt.Create(VarDecl, Condition, Iterator, Block, Token);
  finally
    Dec(FLoopDepth);
  end;
end;

function TParser.ParseFuncDecl(AFuncForm: TFuncForm): TDecl;
var
  FuncDecl: TFuncDecl;
  Token: TToken;
  Name: TIdentifier;

  procedure ParseParameters;
  begin
    if CurrentToken.TokenType <> ttCloseParen then
    begin
      FuncDecl.AddParam(ParseIdentifier);
      while CurrentToken.TokenType = ttComma do
      begin
        Next; // skip comma
        FuncDecl.AddParam(ParseIdentifier);
      end;
    end;
  end;

begin
  Name := nil;
  Token := CurrentToken;
  case AFuncForm of
    ffFunction: begin
                  Next; //skip func
                  Name := ParseIdentifier;
                end;
    ffAnonym:   Next;
  end;
  FuncDecl := TFuncDecl.Create(Name, Token);
  Expect(ttOpenParen);
  ParseParameters;
  Expect(ttCloseParen);
  if CurrentToken.TokenType = ttArrow then
  begin
    FuncDecl.Body := TBlock.Create(TNodeList.Create(), CurrentToken);
    FuncDecl.Body.Nodes.Add(ParseReturnStmt);
  end
  else
  begin
    FuncDecl.Body := ParseBlock;
    Expect(ttEnd);
  end;
  Result := FuncDecl;
end;

function TParser.ParseIdentifier: TIdentifier;
var
  Token: TToken;
begin
  Token := CurrentToken;
  Expect(ttIdentifier);
  Result := TIdentifier.Create(Token);
end;

function TParser.ParseIdentifierExpr: TExpr;
var
  Identifier: TIdentifier;
  FuncDecl: TFuncDecl;
begin
  Identifier := ParseIdentifier;
  if CurrentToken.TokenType = ttArrow then
  begin
    FuncDecl := TFuncDecl.Create(nil, CurrentToken);
    FuncDecl.AddParam(Identifier);
    FuncDecl.Body := TBlock.Create(TNodeList.Create(), CurrentToken);
    FuncDecl.Body.Nodes.Add(ParseReturnStmt);
    Result := TFuncDeclExpr.Create(FuncDecl);
  end
  else Result := TVariable.Create(Identifier);
end;

function TParser.ParseIfStmt: TStmt;
var
  Token: TToken;
  Condition: TExpr;
  ThenPart: TBlock;
  ElsePart: TBlock;
  ElseIfs: TExprList;
  ElseIfParts: TBlocks;
begin
  ElsePart := nil;
  ElseIfs := nil;
  ElseIfParts := nil;

  Token := CurrentToken;
  Next; // skip if
  Condition := ParseExpr;
  Expect(ttThen);
  ThenPart := ParseBlock;

  if CurrentToken.TokenType = ttElseif then
  begin
    ElseIfs := TExprList.Create();
    ElseIfParts := TBlocks.Create();
    repeat
      Next;  // skip elseif
      ElseIfs.Add(ParseExpr);
      Expect(ttThen);
      ElseIfParts.Add(ParseBlock);
    until CurrentToken.TokenType <> ttElseIf;
  end;

  if CurrentToken.TokenType = ttElse then
  begin
    Next; // skip else
    ElsePart := ParseBlock;
  end;
  Expect(ttEnd);
  Result := TIfStmt.Create(Condition, ElseIfs, ElseIfParts, ThenPart,  ElsePart, Token);
end;

function TParser.ParseInterpolatedExpr: TExpr;
var
  ExprList: TExprList;
  Token: TToken;
begin
  Token := CurrentToken;
  ExprList := TExprList.Create();
  while CurrentToken.TokenType = ttInterpolated do
  begin
    ExprList.Add(TConstExpr.Create(CurrentToken.Value, CurrentToken)); // Opening string
    Next;
    ExprList.Add(ParseExpr);          // Interpolated expression
  end;
  if CurrentToken.TokenType = ttString then
    ExprList.Add(ParseFactor)
  else
    Error(CurrentToken, 'Expected end of string interpolation.');
  Result := TInterpolatedExpr.Create(ExprList, Token);
end;

function TParser.ParseMulExpr: TExpr;
var
  MulOp: TToken;
begin
  Result := ParsePowExpr;
  while IsMulOp do
  begin
    MulOp := CurrentToken;
    Next;
    Result := TBinaryExpr.Create(Result, MulOp, ParsePowExpr);
  end;
end;

function TParser.ParseNode: TNode;
begin
  Result := nil;
  try
    if CurrentToken.TokenType in DeclStartSet then
      Result := ParseDecl
    else if CurrentToken.TokenType in  StmtStartSet then
      Result := ParseStmt
    else
      Error(CurrentToken, ErrUnrecognizedDeclOrStmt);
  except
    Synchronize(DeclStartSet + StmtStartSet + [ttEOF]);
    Result := nil;//TNode.Create(CurrentToken);
  end;
end;

function TParser.ParseParenExpr: TExpr;
var
  FuncDecl: TFuncDecl;
begin
  Expect(ttOpenParen);
  if     (Peek.TokenType = ttComma)
      or (    (CurrentToken.TokenType = ttCloseParen)
          and (Peek.TokenType = ttArrow)
         ) then
  begin
    FuncDecl := TFuncDecl.Create(nil, CurrentToken);
    if Peek.TokenType = ttComma then
    begin      // it's a list of parameters
      FuncDecl.AddParam(ParseIdentifier);
      while CurrentToken.TokenType = ttComma do
      begin
        Next; // skip ,
        FuncDecl.AddParam(ParseIdentifier);
      end;
    end;
    Expect(ttCloseParen);
    if CurrentToken.TokenType <> ttArrow then
      Errors.Append(CurrentToken.Line, CurrentToken.Col, ErrExpectedArrow);
    FuncDecl.Body := TBlock.Create(TNodeList.Create(), CurrentToken);
    FuncDecl.Body.Nodes.Add(ParseReturnStmt);
    Result := TFuncDeclExpr.Create(FuncDecl);
  end
  else
  begin
    Result := ParseExpr;
    Expect(ttCloseParen);
  end;
end;

function TParser.ParsePowExpr: TExpr;
var
  PowOp: TToken;
begin
  Result := ParseUnaryExpr;
  while isPowOp do begin
    PowOp := CurrentToken;
    Next;
    Result := TBinaryExpr.Create(Result, PowOp, ParseUnaryExpr);
  end;
end;

function TParser.ParsePrintStmt: TStmt;
var
  ExprList: TExprList;
  Token: TToken;
begin
  try
    Token := CurrentToken;
    Next; // skip print
    Expect(ttOpenParen);
    ExprList := TExprList.Create(false);
    if CurrentToken.TokenType <> ttCloseParen then
    begin
      ExprList.Add(ParseExpr);
      while CurrentToken.TokenType = ttComma do
      begin
        Next; // skip ,
        ExprList.Add(ParseExpr);
      end;
    end;
    Expect(ttCloseParen);
    Result := TPrintStmt.Create(ExprList, Token);
  except
      Synchronize(DeclStartSet + StmtStartSet + [ttEOF]);
      Result := nil;
  end;
end;

function TParser.ParseProduct: TProduct;
var
  Token: TToken;
begin
  Token := CurrentToken;
  Result := TProduct.Create(ParseBlock.Nodes, Token);
end;

function TParser.ParseRepeatStmt: TStmt;
var
  Token: TToken;
  Condition: TExpr;
  Block: TBlock;
begin
  try
    Inc(FLoopDepth);
    Token := CurrentToken;
    Next; // skip repeat
    Block := ParseBlock;
    Expect(ttUntil);
    Condition := ParseExpr;
    Result := TRepeatStmt.Create(Condition, Block, Token);
  finally
    Dec(FLoopDepth);
  end;
end;

function TParser.ParseReturnStmt: TStmt;
var
  Token: TToken;
  Expr: TExpr;
begin
  Token := CurrentToken;
  Next; // skip return
  Expr := ParseExpr;
  Result := TReturnStmt.Create(Expr, Token);
end;

function TParser.ParseStmt: TStmt;
begin
  case CurrentToken.TokenType of
    ttIf:       Result := ParseIfStmt;
    ttWhile:    Result := ParseWhileStmt;
    ttRepeat:   Result := ParseRepeatStmt;
    ttFor:      Result := ParseForStmt;
    ttPrint:    Result := ParsePrintStmt;
    ttBreak:    Result := ParseBreakStmt;
    ttContinue: Result := ParseContinueStmt;
    ttReturn:   Result := ParseReturnStmt;
  else
    Result := ParseAssignStmt;
  end;
end;

function TParser.ParseUnaryExpr: TExpr;
var
  Op: TToken;
begin
  if CurrentToken.TokenType in [ttPlus, ttMinus, ttNot] then
  begin
    Op := CurrentToken;
    Next;
    Result := TUnaryExpr.Create(Op, ParseUnaryExpr);
  end
  else
    Result := ParseCallExpr;
end;

function TParser.ParseVarDecl(AIsConst: Boolean): TDecl;
var
  Identifier: TIdentifier;
  Token: TToken;
begin
  Token := CurrentToken;
  Identifier := ParseIdentifier;
  Expect(ttAssign);
  Result := TVarDecl.Create(Identifier, ParseExpr, Token, AIsConst);
end;


function TParser.ParseVarDecls(AIsConst: Boolean): TDecl;
var
  VarDecls: TVarDecls;
begin
  VarDecls := TVarDecls.Create(TDeclList.Create(), CurrentToken);
  Next; // skip var or const
  VarDecls.List.Add(ParseVarDecl(AIsConst));
  while CurrentToken.TokenType = ttComma do
  begin
    Next; // skip ,
    VarDecls.List.Add(ParseVarDecl(AIsConst));
  end;
  Result := VarDecls;
end;

function TParser.ParseWhileStmt: TStmt;
var
  Token: TToken;
  Condition: TExpr;
  Block: TBlock;
begin
  try
    Inc(FLoopDepth);
    Token := CurrentToken;
    Next; // skip while
    Condition := ParseExpr;
    Expect(ttDo);
    Block := ParseBlock;
    Expect(ttEnd);
    Result := TWhileStmt.Create(Condition, Block, Token);
  finally
    Dec(FLoopDepth);
  end;
end;

function TParser.Peek: TToken;
begin
  Result := nil;
  if not IsLastToken then
    Result := FTokens[FCurrent + 1]
end;

procedure TParser.Synchronize(ATypes: TTokenTypeSet);
begin
  while not (CurrentToken.TokenType in ATypes) do
    Next;
end;

function TParser.ParseCaseExpr: TExpr;
var
  Token: TToken;
  Value, Expr: TExpr;
  CaseExpr: TCaseExpr;
  Values: TExprList;
begin
  Token := CurrentToken;
  Next; // skip Case
  CaseExpr := TCaseExpr.Create(ParseExpr, Token);
  Expect(ttWhen); // one When is mandatory
  Values := ParseExprList;
  Expect(ttThen);
  Expr := ParseExpr;
  for Value in Values do
    CaseExpr.AddLimb(Value, Expr);

  while CurrentToken.TokenType = ttWhen do
  begin
    Next;  // skip When
    Values := ParseExprList;
    Expect(ttThen);
    Expr := ParseExpr;
    for Value in Values do
      CaseExpr.AddLimb(Value, Expr);
  end;

  if CurrentToken.TokenType = ttElse then
  begin
    Next; //skip else
    CaseExpr.ElseLimb := ParseExpr;
  end;
  Expect(ttEnd);
  Result := CaseExpr;
end;

function TParser.ParseIfExpr: TExpr;
var
  Condition, TrueExpr, FalseExpr: TExpr;
  Token: TToken;
begin
  Token := CurrentToken;
  Next; // skip 'if'
  Condition := ParseExpr;
  Expect(ttThen);
  TrueExpr := ParseExpr;
  Expect(ttElse);
  FalseExpr := ParseExpr;
  Result := TIfExpr.Create(Condition, TrueExpr, FalseExpr, Token);
end;

end.
