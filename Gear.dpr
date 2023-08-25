program Gear;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ReaderUnit in 'ReaderUnit.pas';
var
  FReader: TReader;
begin
  FReader := TReader.Create('123', itPrompt);
  try
    Writeln(FReader.PeekChar);
    Writeln(Ord(FReader.PeekChar));
    Writeln(FReader.NextChar);
    Writeln;

    Writeln(FReader.PeekChar);
    Writeln(Ord(FReader.PeekChar));
    Writeln(FReader.NextChar);
    Writeln;

    Writeln(FReader.PeekChar);
    Writeln(Ord(FReader.PeekChar));
    Writeln(FReader.NextChar);
    Writeln;

    Writeln(FReader.PeekChar);
    Writeln(Ord(FReader.PeekChar));
    Writeln(FReader.NextChar);

    Readln;
  finally
    FreeAndNil(FReader)
  end;
end.
