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
      FLook : char;              // next input character (still unprocessed)
      FLine, FCol : integer;     // line and column number of the input character
      FReader: TReader;          // contains the text to scan
      FTokens: TTokens;          // list of mined tokens
      FEndOfFile: Boolean;
      function getChar: Char;
      procedure doKeywordOrIdentifier(const Line, Col: Integer);
      procedure doNumber(const Line, Col: Integer);
      procedure doString(const Line, Col: Integer);
      procedure doChar(const Line, Col: Integer);
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
  FTokens := TTokens.Create;
  FLine := 1;
  FCol := 0;
  FEndOfFile := False;
  FLook := getChar;   // get first character
  ScanTokens;  // scan all tokens
end;

destructor TLexer.Destroy;
begin
  FreeAndNil(FTokens);
  inherited;
end;

procedure TLexer.doChar(const Line, Col: Integer);
begin

end;

procedure TLexer.doKeywordOrIdentifier(const Line, Col: Integer);
begin

end;

procedure TLexer.doNumber(const Line, Col: Integer);
begin

end;

procedure TLexer.doString(const Line, Col: Integer);
begin

end;

function TLexer.getChar: Char;
begin
  Result := FLook;
  if FLook <> CHAR_EOF then
  begin
    Result := FReader.NextChar;
    Inc(FCol);
    if Result = CHAR_13 then
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
    FLook := getChar;
  end;

begin
  case Flook of
    '+': if FReader.PeekChar = '=' then
         begin
           FLook := getChar;
           AddToken(ttPlusIs); //+=
         end
         else
           AddToken(ttPlus);

    '-': if FReader.PeekChar = '=' then
         begin
           Flook := getChar;
           AddToken(ttMinusIs); //-=
         end
         else
           AddToken(ttMinus);

    '/': case FReader.PeekChar of
           '/': begin
                  FLook := getChar;
                  SingleLineComment;
                end;
           '*': begin
                  FLook := getChar;
                  MultiLineComment;
                end;
           '=': begin
                  FLook := getChar;
                  AddToken(ttDivIs); {/=}
                end;
           else
             AddToken(ttDiv);
         end;

    '*': if FReader.PeekChar = '=' then
         begin
           FLook := getChar;
           AddToken(ttMulIs); // *=
         end
         else
           AddToken(ttMul);

    '%': if FReader.PeekChar = '=' then
         begin
           FLook := getChar;
           AddToken(ttRemainderIs); // %=
         end
         else
           AddToken(ttRemainder);

    ':': if FReader.PeekChar = '=' then
         begin
           FLook := getChar;
           AddToken(ttAssign); // :=
         end
         else
           AddToken(ttColon);

    '&': AddToken(ttAnd);
    '|': AddToken(ttOr);
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
           FLook := getChar;
           AddToken(ttDotDot);
         end
         else
           AddToken(ttDot);

    '=': if FReader.PeekChar = '>' then
         begin
           FLook := getChar;
           AddToken(ttArrow);
         end
         else
           AddToken(ttEQ);

    '<': case FReader.PeekChar of
           '<': begin
                  Flook := getChar;
                  AddToken(ttShl);
                end;
           '=': begin
                  Flook := getChar;
                  AddToken(ttLE);
                end;
           '>': begin
                  Flook := getChar;
                  AddToken(ttNEQ);
                end;
           else
             AddToken(ttLT);
         end;

    '>': case FReader.PeekChar of
           '>': begin
                  Flook := getChar;
                  AddToken(ttShr);
                end;
           '=': begin
                  Flook := getChar;
                  AddToken(ttGE);
                end;
           else
             AddToken(ttGT);
         end;

    '?': AddToken(ttQuestion);
    '0'..'9': doNumber(Line, Col);
    '_', 'A'..'Z', 'a'..'z': doKeywordOrIdentifier(Line, Col);
    Quote1: doString(Line, Col);
    Quote2: doChar(Line, Col);
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
      FLook := getChar;
    until FLook in ['*', CHAR_EOF];
    FLook := getChar;
  until FLook in ['/', CHAR_EOF];
  FLook := getChar;
end;

procedure TLexer.SingleLineComment;
begin
  repeat
    FLook := getChar;
  until FLook in [CHAR_13, CHAR_10, CHAR_EOF];

  FLook := getChar;
end;

procedure TLexer.SkipWhiteSpace;
begin
  while FLook in WhiteSpace do
    FLook := getChar;
end;

end.
