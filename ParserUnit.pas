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

end;

function TParser.CurrentToken: TToken;
begin
  Result := FTokens[FCurrent];
end;

destructor TParser.Destroy;
begin

  inherited;
end;

procedure TParser.Error(AToken: TToken; AMsg: string);
begin

end;

procedure TParser.Expect(const ATokenType: TTokenType);
begin

end;

function TParser.IsAddOp: Boolean;
begin

end;

function TParser.IsLastToken: Boolean;
begin

end;

function TParser.IsMulOp: Boolean;
begin

end;

function TParser.IsRelOp: Boolean;
begin

end;

procedure TParser.Next;
begin

end;

function TParser.Parse: TProduct;
begin

end;

function TParser.ParseAddExpr: TExpr;
begin

end;

function TParser.ParseExpr: TExpr;
begin

end;

function TParser.ParseFactor: TExpr;
begin

end;

function TParser.ParseMulExpr: TExpr;
begin

end;

function TParser.ParseProduct: TProduct;
begin

end;

function TParser.ParseUnaryExpr: TExpr;
begin

end;

function TParser.Peek: TToken;
begin

end;

procedure TParser.Synchronize(ATypes: TTokenTypeSet);
begin

end;

end.
