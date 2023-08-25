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

function TReader.GetPeekChar: Char;
begin

end;

function TReader.NextChar: Char;
begin

end;

end.
