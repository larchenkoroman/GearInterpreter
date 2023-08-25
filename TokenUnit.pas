unit TokenUnit;

interface
uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Variants;

type
  TTokenType = (
    //Expressions - operators
    ttPlus, ttMin, ttMul, ttDiv, ttRem,
    ttPlusIs, ttMinIs, ttMulIs, ttDivIs, ttRemIs,
    ttOr, ttAnd, ttNot, ttXor,
    ttShl, ttShr, ttPow,
    ttEQ, ttNEQ, ttGT, ttGE, ttLT, ttLE,

    //Keywords declarations
    ttArray, ttClass, ttDictionary, ttEach, ttEnum, ttExtension, ttFunc,
    ttInit, ttLet, ttVal, ttVar, ttTrait,

    //Keywords statements and expressions
    ttIf, ttThen, ttElse, ttWhile, ttDo, ttRepeat, ttUntil,
    ttFor, ttIn, ttIs, ttReturn, ttEnd, ttMatch, ttWhere, ttSwitch, ttCase,
    ttEnsure, ttPrint, ttInherited, ttSelf, ttUse, ttBreak, ttOn,
    ttIdentifier,

    //Constant values
    ttFalse, ttTrue, ttNull, ttNumber, ttString, ttChar,

    //Symbols and punctuation marks
    ttComma, ttDot, ttDotDot, ttAssign, ttQuestion, ttArrow, ttColon,
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
      property TokenType: TTokenType read FTokenType;
      property Lexeme: string read FLexeme;
      property Value: Variant read FValue;
      property Line: LongInt read FLine;
      property Col: LongInt read FCol;
      constructor Create(ATokenType: TTokenType; ALexeme: string; AValue: Variant; ALine, ACol: LongInt);
      function ToString: string; override;
      function Copy: TToken;
  end;


implementation

{ TTokenTypeHelper }

function TTokenTypeHelper.ToString: string;
begin

end;

{ TToken }

function TToken.Copy: TToken;
begin

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

end;

end.
