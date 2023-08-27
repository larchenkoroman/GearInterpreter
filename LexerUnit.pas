unit LexerUnit;

interface
uses
  System.Classes, System.SysUtils, ReaderUnit, TokenUnit, Variants;

const
  Space      = #32;
  Tab        = #9;
  RetCaret   = #13;
  NewLine    = #10;
  Apostrophe = #39; // '
  Quote      = #34; // "

  WhiteSpace   = [Tab, RetCaret, NewLine, Space];
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
      Procedure ScanTokens;
      Procedure SingleLineComment;
      Procedure MultiLineComment;
    public
      property Tokens: TTokens read FTokens;
      constructor Create(Reader: TReader);
      destructor Destroy; override;
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
  Result := FReader.NextChar;
  Inc(FCol);
  if Result = RetCaret then
  begin
    Inc(FLine);
    FCol := 0;
  end;
end;

procedure TLexer.MultiLineComment;
begin

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
    '+':
      if FReader.PeekChar = '=' then
      begin
        FLook := getChar;
        AddToken(ttPlusIs); //+=
      end
      else
        AddToken(ttPlus);

    '-':
      if FReader.PeekChar = '=' then
      begin
        Flook := getChar;
        AddToken(ttMinusIs); //-=
      end
      else
        AddToken(ttMinus);

    '/':
      case FReader.PeekChar of
        '/':
          begin
            FLook := getChar;
            SingleLineComment;
          end;
        '*':
          begin
            FLook := getChar;
            MultiLineComment;
          end;
        '=':
          begin
            FLook := getChar;
            AddToken(ttDivIs); {/=}
          end;
        else
          AddToken(ttDiv);
      end;

    '*':
      if FReader.PeekChar = '=' then
      begin
        FLook := getChar;
        AddToken(ttMulIs); // *=
      end
      else
        AddToken(ttMul);

    '%':
      if FReader.PeekChar = '=' then
      begin
        FLook := getChar;
        AddToken(ttRemainderIs); // %=
      end
      else
        AddToken(ttRemainder);

  end;
end;

procedure TLexer.ScanTokens;
begin
  while not FEndOfFile do
  begin
    while FLook in WhiteSpace do
      FLook := getChar;  // skip white space
    ScanToken(FLine, FCol);
  end;
  Tokens.Add(TToken.Create(ttEOF, Null, FLine, FCol));
end;

procedure TLexer.SingleLineComment;
begin

end;

end.
