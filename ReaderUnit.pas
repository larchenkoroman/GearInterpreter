unit ReaderUnit;

interface
uses
  System.Classes, System.SysUtils, System.IOUtils;

const
  FileEnding = #26;

type
  TInputType = (itPrompt, itFile);

  TReader = class
    private
      FFileName: string;
      FText: string;
      Index: LongInt;
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
  Index := 1;

  case InputType of
    itPrompt: FText := Source;
    itFile:
      if FileExists(Source) then
      begin
        FFileName := Source;
        FText := TFile.ReadAllText(FFileName);
      end;
    else
      FText := '';
  end;
end;

function TReader.PeekChar: Char;
begin
  if Index <= FText.Length then
    Result := FText[Index]
  else
    Result := FileEnding;
end;

function TReader.NextChar: Char;
begin
  if Index <= FText.Length then
  begin
    Result := FText[Index];
    Inc(Index);
  end
  else
    Result := FileEnding;
end;

end.
