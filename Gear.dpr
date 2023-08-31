program Gear;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ReaderUnit in 'ReaderUnit.pas',
  TokenUnit in 'TokenUnit.pas',
  LexerUnit in 'LexerUnit.pas',
  ErrorUnit in 'ErrorUnit.pas',
  AstUnit in 'AstUnit.pas';

var
  Input: string;
  Reader: TReader;
  Lexer: TLexer;
begin
  Input := 'StrVar = "df for" RRR = 10.58';
  Writeln('Input:');
  Writeln(Input);
  Writeln;
  Reader := TReader.Create(Input, itPrompt);
  Lexer := TLexer.Create(Reader);
  try
    for var tok in Lexer.Tokens do
      Writeln(tok.ToString);

    if not Errors.IsEmpty then
      Writeln(Errors.ToString);

    Readln;
  finally
    FreeAndNil(Reader);
    FreeAndNil(Lexer);
  end;
end.
