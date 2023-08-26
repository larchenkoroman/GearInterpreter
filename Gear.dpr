program Gear;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ReaderUnit in 'ReaderUnit.pas',
  TokenUnit in 'TokenUnit.pas',
  LexerUnit in 'LexerUnit.pas';

var
  FReader: TReader;
  TokenTypes: TTokenTypeSet;
begin
  FReader := TReader.Create('123', itPrompt);
  try
    Writeln(FReader.NextChar);
    Writeln('Peek ', FReader.PeekChar);
    Writeln;

    Writeln(FReader.NextChar);
    Writeln('Peek ', FReader.PeekChar);
    Writeln;

    Writeln(FReader.NextChar);
    Writeln('Peek ', FReader.PeekChar);

    Readln;
  finally
    FreeAndNil(FReader)
  end;
end.
