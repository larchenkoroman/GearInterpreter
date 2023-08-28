unit ReaderUnit;

interface
uses
  System.Classes, System.SysUtils, System.IOUtils;

const
  CHAR_EOF = #26;

type
  TInputType = (itPrompt, itFile);

  TReader = class
    private
      FFileName: string;
      FText: string;
      FIndex: LongInt;
    public
      property FileName: string read FFileName;
      constructor Create(Source: string; InputType: TInputType);
      function NextChar: Char;
      function PeekChar: Char;
  end;

implementation

{ TReader }

constructor TReader.Create(Source: string; InputType: TInputType);
begin
  inherited Create;
  FFileName := '';
  FText := '';
  FIndex := 1;

  case InputType of
    itPrompt:
      FText := Source;

    itFile:
      if FileExists(Source) then
      begin
        FFileName := Source;
        FText := TFile.ReadAllText(FFileName);
      end;
  end;
end;

function TReader.PeekChar: Char;
begin
  if FIndex <= FText.Length then
    Result := FText[FIndex]
  else
    Result := CHAR_EOF;
end;

function TReader.NextChar: Char;
begin
  if FIndex <= FText.Length then
  begin
    Result := FText[FIndex];
    Inc(FIndex);
  end
  else
    Result := CHAR_EOF;
end;

end.
