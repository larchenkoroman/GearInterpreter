unit ParserUnit;

interface

uses
  System.Classes, System.SysUtils, Variants, LexerUnit, TokenUnit, AstUnit, ErrorUnit;

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
      function ParseUnaryExpr: TExpr;
      function ParseFactor: TExpr;
      //Statements
      //Declarations
      //Blocks
      function ParseProduct: TProduct;
    public
      constructor Create(ALexer: TLexer);
      destructor Destroy; override;
      function Parse: TProduct;
  end;

implementation

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

destructor TParser.Destroy;
begin
  if Assigned(FTokens) then
    FreeAndNil(FTokens);

  inherited;
end;

procedure TParser.Error(AToken: TToken; AMsg: string);
begin
  Errors.Append(AToken.Line, AToken.Col, AMsg);
end;

procedure TParser.Expect(const ATokenType: TTokenType);
const
  Msg = 'Syntax error, "%s: expected.';
begin
  if CurrentToken.TokenType = ATokenType then
    Next
  else
    Error(CurrentToken, Format(Msg, [ATokenType.ToString]))
end;

function TParser.IsAddOp: Boolean;
begin
  Result := CurrentToken.TokenType in [ttPlus, ttMinus];
end;

function TParser.IsLastToken: Boolean;
begin
  Result := FCurrent = FTokens.Count - 1;
end;

function TParser.IsMulOp: Boolean;
begin
  Result := CurrentToken.TokenType in [ttMul, ttDiv, ttRemainder];
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
  try
    Result := ParseProduct;
    Expect(ttEOF);  
  except
    on E: EParseError do
      Result := nil;
  end;
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

    else
    begin
      Result := TExpr.Create(CurrentToken);
      Error(CurrentToken, 'Unexpected token: ' + CurrentToken.ToString + '.');
    end;
  end;
end;

function TParser.ParseMulExpr: TExpr;
var
  MulOp: TToken;
begin
  Result := ParseUnaryExpr;
  while IsMulOp do
  begin
    MulOp := CurrentToken;
    Next;
    Result := TBinaryExpr.Create(Result, MulOp, ParseUnaryExpr);  
  end;
end;

function TParser.ParseProduct: TProduct;
begin
  Result := TProduct.Create(ParseExpr, CurrentToken);
end;

function TParser.ParseUnaryExpr: TExpr;
var
  Op: TToken;
begin
  if CurrentToken.TokenType in [ttPlus, ttMinus] then
  begin
    Op := CurrentToken;
    Next;
    Result := TUnaryExpression.Create(Op, ParseUnaryExpr);
  end
  else
    Result := ParseFactor;
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

end.
