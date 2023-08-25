unit ReaderUnit;

interface
uses
  System.Classes, System.SysUtils;

const
  FileEnding = #26;

type
  TInputType = (itPrompt, itFile);

  TReader = class(TStringList)
    private
      FFileName: string;
      Index: LongInt;
      function getPeekChar: Char;
    public
      property FileName: string read FFileName;
      property PeekChar: Char read getPeekChar;
      constructor Create(Source: string; InputType: TInputType);
      function NextChar: Char;
  end;

implementation

{ TReader }

constructor TReader.Create(Source: string; InputType: TInputType);
begin
  inherited Create;
  FFileName := '';
  Index := 1;
  case InputType of
    itPrompt: Add(Source);
    itFile:
      begin
        FFileName := Source;
        LoadFromFile(FFileName);
      end;
  end;
end;

function TReader.getPeekChar: Char;
begin
  if Index <= Length(Text) then
    Result := Text[Index]
  else
    Result := FileEnding;
end;

function TReader.NextChar: Char;
begin
  if Index <= Length(Text) then
  begin
    Result := Text[Index];
    Inc(Index);
  end
  else
    Result := FileEnding;
end;

end.
