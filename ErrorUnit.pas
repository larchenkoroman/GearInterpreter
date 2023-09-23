unit ErrorUnit;

interface
uses
  System.Classes, System.SysUtils, TokenUnit, Generics.Collections;

type
  TErrorItem = class
    Line, Col: Integer;
    Msg: string;
    constructor Create(const ALine, ACol: Integer; const AMsg: string);
    function ToString: string; override;
  end;

  TErrors = class(TObjectList<TErrorItem>)
    function IsEmpty: Boolean;
    function ToString: string; override;
    procedure Append(const ALine, ACol: Integer; const AMsg: string); overload;
    procedure Append(const AToken: TToken; const AMsg: string); overload;
    procedure Reset;
  end;

  EParseError = class(Exception);

  ERunTimeError = class(Exception)
    Token: TToken;
    constructor Create(AToken: TToken; AMessage: string);
  end;

procedure RuntimeError(E: ERuntimeError);
procedure RuntimeWarning(E: ERuntimeError);

var
  Errors: TErrors;
implementation

{ TErrorItem }

constructor TErrorItem.Create(const ALine, ACol: Integer; const AMsg: string);
begin
  Line := ALine;
  Col := ACol;
  Msg := AMsg;
end;


function TErrorItem.ToString: string;
begin
  Result := Format('[%d,%d]: %s', [Line, Col, Msg]);
end;

{ TErrors }

procedure TErrors.Append(const ALine, ACol: Integer; const AMsg: string);
begin
  Add(TErrorItem.Create(ALine, ACol, AMsg));
end;

procedure TErrors.Append(const AToken: TToken; const AMsg: string);
begin
  Append(AToken.Line, AToken.Col, AMsg);
end;

function TErrors.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;

procedure TErrors.Reset;
begin
  Clear;
end;

function TErrors.ToString: string;
var
  Item: TErrorItem;
begin
  Result := 'Errors:' + sLineBreak;
  for Item in Self do
    Result := Result + Item.ToString + sLineBreak;
end;

procedure RuntimeError(E: ERuntimeError);
begin
  WriteLn('[' + IntToStr(E.Token.Line) + ','
              + IntToStr(E.Token.Col) + '] '
              + 'Runtime error: ', E.Message);
  Exit;
end;

procedure RuntimeWarning(E: ERuntimeError);
begin
  WriteLn('[' + IntToStr(E.Token.Line) + ','
              + IntToStr(E.Token.Col) + '] '
              + 'Runtime warning: ', E.Message);
end;

{ ERunTimeError }

constructor ERunTimeError.Create(AToken: TToken; AMessage: string);
begin
  Token := AToken;
  inherited Create(AMessage);
end;

initialization
  Errors := TErrors.Create(True); //AOwnsObjects

finalization
  FreeAndNil(Errors);

end.
