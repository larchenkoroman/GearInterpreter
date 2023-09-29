unit TokenUnit;

interface
uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Variants, System.Rtti;

type
  TTokenType = (
    //Expressions - operators
    ttPlus, ttMinus, ttMul, ttDiv, ttRemainder,
    ttPlusIs, ttMinusIs, ttMulIs, ttDivIs, ttRemainderIs,
    ttOr, ttAnd, ttNot, ttXor,
    ttPow,
    ttEQ, ttNEQ, ttGT, ttGE, ttLT, ttLE,

    //Keywords declarations
    ttArray, ttClass, ttDictionary, ttEach, ttEnum, ttExtension, ttFunc,
    ttInit, ttConst, ttVal, ttVar,

    //Keywords statements and expressions
    ttIf, ttThen, ttElse, ttElseIf, ttWhile, ttDo, ttRepeat, ttUntil,
    ttFor, ttIn, ttIs, ttReturn, ttEnd, ttMatch,  ttSwitch, ttCase,
    ttEnsure, ttPrint, ttInherited, ttSelf, ttUse, ttBreak, ttContinue, ttOn,
    ttIdentifier,

    //Constant values
    ttFalse, ttTrue, ttNull, ttNumber, ttString, ttChar,

    //Symbols and punctuation marks
    ttComma, ttSemiColon, ttDot, ttDotDot, ttAssign, ttQuestion, ttArrow,
    ttOpenParen, ttCloseParen, ttOpenBrace, ttCloseBrace,
    ttOpenBrack, ttCloseBrack, ttComment, ttEOF, ttNone
  );

  TTokenTypeHelper = record helper for TTokenType
    function ToString: string;
  end;

  TTokenTypeSet = set of TTokenType;
  TKeywords = TDictionary<string, TTokenType>;

  TToken = class
    private
      FTokenType: TTokenType;
      FLexeme: string;
      FValue: Variant;
      FLine, FCol: LongInt;
    public
      constructor Create(ATokenType: TTokenType; AValue: Variant; ALine, ACol: LongInt); overload;
      constructor Create(ATokenType: TTokenType; ALexeme: string; AValue: Variant; ALine, ACol: LongInt); overload;
      property TokenType: TTokenType read FTokenType;
      property Lexeme: string read FLexeme;
      property Value: Variant read FValue;
      property Line: LongInt read FLine;
      property Col: LongInt read FCol;
      function ToString: string; override;
      function Copy: TToken;
  end;

  TTokens = TObjectList<TToken>;
  TTokensHelper = class helper for TTokens
    function ToText: string;
  end;

var
  Keywords: TKeywords;

implementation

{ TToken }

function TToken.Copy: TToken;
begin
  Result := TToken.Create(FTokenType, FValue, FLine, FCol);
end;

constructor TToken.Create(ATokenType: TTokenType; AValue: Variant; ALine, ACol: LongInt);
begin
  FTokenType := ATokenType;
  FLexeme := ATokenType.ToString;
  FValue := AValue;
  FLine := ALine;
  FCol := ACol;
end;

constructor TToken.Create(ATokenType: TTokenType; ALexeme: string; AValue: Variant; ALine, ACol: LongInt);
begin
  FTokenType := ATokenType;
  FLexeme := ALexeme;
  FValue := AValue;
  FLine := ALine;
  FCol := ACol;
end;

function TToken.ToString: string;
begin
  Result := FTokenType.ToString + ' (' + FLexeme + ')';
  if not VarIsNull(FValue) then
    Result := Result +  ' = ' + VarToStr(FValue);
end;


{ TTokenTypeHelper }

function TTokenTypeHelper.ToString: string;
begin
  case Self of
    ttPlus:        Result := '+';
    ttMinus:       Result := '-';
    ttMul:         Result := '*';
    ttDiv:         Result := '/';
    ttRemainder:   Result := '%';
    ttPlusIs:      Result := '+=';
    ttMinusIs:     Result := '-=';
    ttMulIs:       Result := '*=';
    ttDivIs:       Result := '/=';
    ttRemainderIs: Result := '%=';
    ttPow:         Result := '^';
    ttEQ:          Result := '==';
    ttNEQ:         Result := '<>';
    ttGT:          Result := '>';
    ttGE:          Result := '>=';
    ttLT:          Result := '<';
    ttLE:          Result := '<=';
    ttComma:       Result := ',';
    ttSemiColon:   Result := ';';
    ttDot:         Result := '.';
    ttDotDot:      Result := '..';
    ttAssign:      Result := '=';
    ttQuestion:    Result := '?';
    ttArrow:       Result := '=>';
    ttOpenParen:   Result := '(';
    ttCloseParen:  Result := ')';
    ttOpenBrace:   Result := '{';
    ttCloseBrace:  Result := '}';
    ttOpenBrack:   Result := '[';
    ttCloseBrack:  Result := ']';
    ttEOF:         Result := 'End of file';
  else
    Result := TRttiEnumerationType.GetName(Self).Substring(2);
  end;
end;


{ TTokensHelper }

function TTokensHelper.ToText: string;
var
 Token: TToken;
begin
  Result := '';
  for Token in Self do
    Result := Result + Token.ToString + sLineBreak;

end;

initialization
  Keywords := TKeywords.Create(100);

 // the constant values
  Keywords.Add('false', ttFalse);
  Keywords.Add('null', ttNull);
  Keywords.Add('true', ttTrue);

  // the keywords
  Keywords.Add('array', ttArray);
  Keywords.Add('break', ttBreak);
  Keywords.Add('continue', ttcontinue);
  Keywords.Add('case', ttCase);
  Keywords.Add('class', ttClass);
  Keywords.Add('dictionary', ttDictionary);
  Keywords.Add('do', ttDo);
  Keywords.Add('each', ttEach);
  Keywords.Add('else', ttElse);
  Keywords.Add('end', ttEnd);
  Keywords.Add('ensure', ttEnsure);
  Keywords.Add('enum', ttEnum);
  Keywords.Add('extension', ttExtension);
  Keywords.Add('for', ttFor);
  Keywords.Add('func', ttFunc);
  Keywords.Add('if', ttIf);
  Keywords.Add('in', ttIn);
  Keywords.Add('is', ttIs);
  Keywords.Add('inherited', ttInherited);
  Keywords.Add('init', ttInit);
  Keywords.Add('const', ttConst);
  Keywords.Add('match', ttMatch);
  Keywords.Add('on', ttOn);
  Keywords.Add('print', ttPrint);
  Keywords.Add('repeat', ttRepeat);
  Keywords.Add('return', ttReturn);
  Keywords.Add('self', ttSelf);
  Keywords.Add('switch', ttSwitch);
  Keywords.Add('then', ttThen);
  Keywords.Add('until', ttUntil);
  Keywords.Add('use', ttUse);
  Keywords.Add('val', ttVal);
  Keywords.Add('var', ttVar);
  Keywords.Add('while', ttWhile);
  Keywords.Add('or', ttOr);
  Keywords.Add('and', ttAnd);
  Keywords.Add('not', ttNot);
  Keywords.Add('xor', ttXor);
  Keywords.Add('elseif', ttElseIf);


finalization
  FreeAndNil(Keywords);

end.
