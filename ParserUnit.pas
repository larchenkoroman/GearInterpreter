unit ParserUnit;

interface

uses
  System.Classes, System.SysUtils, Variants, LexerUnit, TokenUnit, AstUnit, ErrorUnit;

const
  DeclStartSet: TTokenTypeSet = [ttConst, ttVar];
  StmtStartSet: TTokenTypeSet = [ttIf, ttWhile, ttRepeat, ttFor, ttPrint, ttIdentifier];
  BlockEndSet: TTokenTypeSet  = [ttElse, ttUntil, ttEnd, ttCase, ttEOF];
  AssignSet: TTokenTypeSet    = [ttPlusIs, ttMinusIs, ttMulIs, ttDivIs, ttRemainderIs, ttAssign];

type
  TParser = class
    private
      FTokens: TTokens;
      FCurrent: Integer;

      function CurrentToken: TToken;
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


      function ParseUnaryExpr: TExpr;
      function ParseFactor: TExpr;
      //Statements
      function ParseStmt: TStmt;
      function ParsePrintStmt: TStmt;
      function ParseAssignStmt:TStmt;
      function ParseIfStmt: TStmt;
      function ParseWhileStmt: TStmt;
      function ParseRepeatStmt: TStmt;
      function ParseForStmt: TStmt;
      //Declarations
      function ParseDecl: TDecl;
      function ParseVarDecl(AIsConst: Boolean): TDecl;
      function ParseVarDecls(AIsConst: Boolean): TDecl;
      function ParseIdentifier: TIdentifier;
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


{ TParser }

constructor TParser.Create(ALexer: TLexer);
begin
  FTokens := ALexer.Tokens;
  FCurrent := 0;
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
  else
    Error(CurrentToken, ErrExpectedAssignOpFunc);
end;

function TParser.ParseBlock: TBlock;
begin
  Result := TBlock.Create(TNodeList.Create(), CurrentToken);
  while not (CurrentToken.TokenType in BlockEndSet) do
    Result.Nodes.Add(ParseNode);
end;

function TParser.ParseDecl: TDecl;
begin
  Result := nil;
  case CurrentToken.TokenType of
    ttVar, ttConst: Result := ParseVarDecls(CurrentToken.TokenType = ttConst);
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

    ttOpenParen:
    begin
      Next; //Skip '('
      Result := ParseExpr;
      Expect(ttCloseParen);
    end;

    ttIdentifier:
    begin
      Result := TVariable.Create(ParseIdentifier);
    end;

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
  Token := CurrentToken;
  Next; // skip for
  Next; // skip var
  VarDecl := ParseVarDecl(False) as TVarDecl;
  Expect(ttComma);
  Condition := ParseExpr;
  Expect(ttComma);
  Iterator := ParseAssignStmt;
  Expect(ttDo);
  Block := ParseBlock;
  Expect(ttEnd);
  Result := TForStmt.Create(VarDecl, Condition, Iterator, Block, Token);
end;

function TParser.ParseIdentifier: TIdentifier;
var
  Token: TToken;
begin
  Token := CurrentToken;
  Expect(ttIdentifier);
  Result := TIdentifier.Create(Token);
end;

function TParser.ParseIfStmt: TStmt;
var
  Token, VarToken: TToken;
  Condition: TExpr;
  ThenPart: TBlock;
  ElsePart: TBlock;
begin
  ElsePart := nil;
  Token := CurrentToken;
  Next; // skip if
  Condition := ParseExpr;
  Expect(ttThen);
  ThenPart := ParseBlock;
  if CurrentToken.TokenType = ttElse then
  begin
    Next; // skip else
    ElsePart := ParseBlock;
  end;
  Expect(ttEnd);
  Result := TIfStmt.Create(Condition, ThenPart, ElsePart, Token);
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
  Token := CurrentToken;
  Next; // skip repeat
  Block := ParseBlock;
  Expect(ttUntil);
  Condition := ParseExpr;
  Result := TRepeatStmt.Create(Condition, Block, Token);
end;

function TParser.ParseStmt: TStmt;
begin
  case CurrentToken.TokenType of
    ttIf:     Result := ParseIfStmt;
    ttWhile:  Result := ParseWhileStmt;
    ttRepeat: Result := ParseRepeatStmt;
    ttFor:    Result := ParseForStmt;
    ttPrint:  Result := ParsePrintStmt;
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
    Result := ParseFactor;
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
  Token := CurrentToken;
  Next; // skip while
  Condition := ParseExpr;
  Expect(ttDo);
  Block := ParseBlock;
  Expect(ttEnd);
  Result := TWhileStmt.Create(Condition, Block, Token);
end;

function TParser.Peek: TToken;
begin
  Result := nil;
  if not IsLastToken then
    Result := FTokens[FCurrent + 1]
end;
//
procedure TParser.Synchronize(ATypes: TTokenTypeSet);
begin
  while not (CurrentToken.TokenType in ATypes) do
    Next;
end;

end.
