program Gear;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ReaderUnit in 'ReaderUnit.pas',
  TokenUnit in 'TokenUnit.pas',
  LexerUnit in 'LexerUnit.pas';

var
  Input: string;
  Reader: TReader;
  Lexer: TLexer;
begin
  Input := '+-<=MyVar = 123.00089 for/*qwe'#13#10'@#$fwe*//';
  Writeln(Input);
  Writeln;
  Reader := TReader.Create(Input, itPrompt);
  Lexer := TLexer.Create(Reader);
  try
    for var tok in Lexer.Tokens do
      Writeln(tok.ToString);

    Readln;
  finally
    FreeAndNil(Reader);
    FreeAndNil(Lexer);
  end;
end.
