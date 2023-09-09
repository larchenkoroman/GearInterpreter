unit LexerUnit;

interface
uses
  System.Classes, System.SysUtils, ReaderUnit, TokenUnit, Variants;

const
  Space    = #32;
  Tab      = #9;
  CHAR_13  = #13;
  CHAR_10  = #10;
  Quote1   = #39; // '
  Quote2   = #34; // "

  WhiteSpace   = [Tab, CHAR_13, CHAR_10, Space];
  Underscore   = ['_'];
  LoCaseLetter = ['a'..'z'];
  UpCaseLetter = ['A'..'Z'];
  Letters      = UpCaseLetter + LoCaseLetter;
  AlphaChars   = UpCaseLetter + LoCaseLetter + Underscore;
  NumberChars  = ['0'..'9'];
  SpecialChar  = '#';
  IdentChars   = NumberChars + AlphaChars;

type
  TLexer = class
    private
      FLook : Char;              // next input character (still unprocessed)
      FLine, FCol : integer;     // line and column number of the input character
      FReader: TReader;          // contains the text to scan
      FTokens: TTokens;          // list of mined tokens
      FEndOfFile: Boolean;
      function GetChar: Char;
      procedure DoKeywordOrIdentifier(const Line, Col: Integer);
      procedure DoNumber(const Line, Col: Integer);
      procedure DoString(const QuoteChar: Char; const Line, Col: Integer);
      procedure ScanToken(const Line, Col: Integer);
      procedure ScanTokens;
      procedure SingleLineComment;
      procedure MultiLineComment;
      procedure SkipWhiteSpace;
    public
      constructor Create(Reader: TReader);
      destructor Destroy; override;
      property Tokens: TTokens read FTokens;
  end;

implementation

{ TLexer }

constructor TLexer.Create(Reader: TReader);
begin
  FReader := Reader;
  FTokens := TTokens.Create(True); //AOwnsObjects
  FLine := 0;
  FCol := 0;
  FEndOfFile := False;
  FLook := GetChar;   // get first character
  ScanTokens;  // scan all tokens
end;

destructor TLexer.Destroy;
begin
  FreeAndNil(FTokens);
  inherited;
end;

procedure TLexer.DoKeywordOrIdentifier(const Line, Col: Integer);
var
  Lexeme: string;
  TokenType: TTokenType;
  Token: TToken;
begin
  Lexeme := FLook;
  FLook := GetChar;
  while CharInSet(FLook, IdentChars) do
  begin
    Lexeme := Lexeme + Flook;
    Flook := GetChar;
  end;

  //Match the keyword and return its type, otherwise it's an identifier
  if not Keywords.TryGetValue(Lexeme.ToLower, TokenType) then
    TokenType := TTokenType.ttIdentifier;

  Token := TToken.Create(TokenType, Lexeme, Null, Line, Col);
  Tokens.Add(Token);
end;

procedure TLexer.DoNumber(const Line, Col: Integer);
var
  Lexeme: string;
  Value: Extended;
  Token: TToken;
  IsFoundDotDot: Boolean;
  StrNumber: string;
begin
  Lexeme := FLook;
  Flook := GetChar;
  //читаем целую часть
  while CharInSet(Flook, NumberChars) do
  begin
    Lexeme := Lexeme + Flook;
    Flook := GetChar;
  end;

  IsFoundDotDot := (Flook = '.') and (FReader.PeekChar = '.');
  //читаем дробную часть, если есть
  if (Flook = '.') and not IsFoundDotDot then
  begin
    Lexeme := Lexeme + FLook;
    Flook := GetChar;
    while CharInSet(Flook, NumberChars) do
    begin
      Lexeme := Lexeme + Flook;
      Flook := GetChar;
    end;
  end;

  //если в виде экспоненты
  if (UpperCase(FLook) = 'E') and not IsFoundDotDot then
  begin
    Lexeme := Lexeme + FLook;
    Flook := GetChar;
    if CharInSet(FLook, ['+', '-']) then
    begin
      Lexeme := Lexeme + FLook;
      Flook := GetChar;
    end;
    while CharInSet(Flook, NumberChars) do
    begin
      Lexeme := Lexeme + Flook;
      Flook := GetChar;
    end;
  end;

  StrNumber := Lexeme;
  if FormatSettings.DecimalSeparator <> '.' then
    StrNumber := StrNumber.Replace('.', FormatSettings.DecimalSeparator);

  Value := StrToFloat(StrNumber);
  Token := TToken.Create(ttNumber,Lexeme, Value, Line, Col);
  Tokens.Add(Token);
end;

procedure TLexer.DoString(const QuoteChar: Char; const Line, Col: Integer);
var
  Lexeme, Value: string;
  Token: TToken;
begin
  FLook := GetChar;
  while    (FLook <> QuoteChar)
       and not CharInSet(FLook, [CHAR_13, CHAR_10, CHAR_EOF]) do
  begin
    Lexeme := Lexeme + FLook;
    FLook := GetChar;
  end;


  FLook := getChar;   // consume quote
  Value := Lexeme;
  Lexeme := QuoteChar + Lexeme + QuoteChar;  // including the quotes
  Token := TToken.Create(ttString, Lexeme, Value, Line, Col);
  Tokens.Add(Token);
end;

function TLexer.GetChar: Char;
begin
  Result := FLook;
  if FLook <> CHAR_EOF then
  begin
    Result := FReader.NextChar;
    if not CharInSet(FLook, [CHAR_13, CHAR_10]) then
      Inc(FCol);

    if Result = CHAR_10 then
    begin
      Inc(FLine);
      FCol := 0;
    end;
  end;
end;

procedure TLexer.ScanToken(const Line, Col: Integer);
  procedure AddToken(const ATokenType: TTokenType);
  var
    Token: TToken;
  begin
    Token := TToken.Create(ATokenType, Null, Line, Col);
    Tokens.Add(Token);
    FLook := GetChar;
  end;

begin
  case Flook of
    '+': if FReader.PeekChar = '=' then
         begin
           FLook := GetChar;
           AddToken(ttPlusIs); //+=
         end
         else
           AddToken(ttPlus);

    '-': if FReader.PeekChar = '=' then
         begin
           Flook := GetChar;
           AddToken(ttMinusIs); //-=
         end
         else
           AddToken(ttMinus);

    '/': case FReader.PeekChar of
           '/': begin
                  FLook := GetChar;
                  SingleLineComment;
                end;
           '*': begin
                  FLook := GetChar;
                  MultiLineComment;
                end;
           '=': begin
                  FLook := GetChar;
                  AddToken(ttDivIs); {/=}
                end;
           else
             AddToken(ttDiv);
         end;

    '*': if FReader.PeekChar = '=' then
         begin
           FLook := GetChar;
           AddToken(ttMulIs); // *=
         end
         else
           AddToken(ttMul);

    '%': if FReader.PeekChar = '=' then
         begin
           FLook := GetChar;
           AddToken(ttRemainderIs); // %=
         end
         else
           AddToken(ttRemainder);

    ':': if FReader.PeekChar = '=' then
         begin
           FLook := GetChar;
           AddToken(ttAssign); // :=
         end
         else
           AddToken(ttColon);

    '~': AddToken(ttXor);
    '!': AddToken(ttNot);
    '^': AddToken(ttPow);
    '(': AddToken(ttOpenParen);
    ')': AddToken(ttCloseParen);
    '{': AddToken(ttOpenBrace);
    '}': AddToken(ttCloseBrace);
    '[': AddToken(ttOpenBrack);
    ']': AddToken(ttCloseBrack);
    ',': AddToken(ttComma);

    '.': if FReader.PeekChar = '.' then
         begin
           FLook := GetChar;
           AddToken(ttDotDot);
         end
         else
           AddToken(ttDot);

    '=': if FReader.PeekChar = '>' then
         begin
           FLook := GetChar;
           AddToken(ttArrow);
         end
         else
           AddToken(ttEQ);

    '<': case FReader.PeekChar of
           '=': begin
                  Flook := GetChar;
                  AddToken(ttLE);
                end;
           '>': begin
                  Flook := GetChar;
                  AddToken(ttNEQ);
                end;
           else
             AddToken(ttLT);
         end;

    '>': if FReader.PeekChar = '=' then
         begin
           Flook := GetChar;
           AddToken(ttGE);
         end
         else
           AddToken(ttGT);

    '?': AddToken(ttQuestion);
    '0'..'9': DoNumber(Line, Col);
    '_', 'A'..'Z', 'a'..'z': DoKeywordOrIdentifier(Line, Col);
    Quote1: DoString(Quote1, Line, Col);
    Quote2: DoString(Quote2, Line, Col);
    CHAR_EOF: FEndOfFile := True;
    else
      FEndOfFile := True;
  end;
end;

procedure TLexer.ScanTokens;
begin
  while not FEndOfFile do
  begin
    SkipWhiteSpace;
    ScanToken(FLine, FCol);
  end;
  Tokens.Add(TToken.Create(ttEOF, Null, FLine, FCol));
end;

procedure TLexer.MultiLineComment;
begin
  repeat
    repeat
      FLook := GetChar;
    until CharInSet(FLook, ['*', CHAR_EOF]);
    FLook := GetChar;
  until CharInSet(FLook, ['/', CHAR_EOF]);
  FLook := GetChar;
end;

procedure TLexer.SingleLineComment;
begin
  repeat
    FLook := GetChar;
  until CharInSet(FLook, [CHAR_13, CHAR_10, CHAR_EOF]);

  FLook := GetChar;
end;

procedure TLexer.SkipWhiteSpace;
begin
  while CharInSet(FLook, WhiteSpace) do
    FLook := GetChar;
end;

end.
