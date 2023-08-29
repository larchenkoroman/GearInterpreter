program Gear;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ReaderUnit in 'ReaderUnit.pas',
  TokenUnit in 'TokenUnit.pas',
  LexerUnit in 'LexerUnit.pas';

var
  Reader: TReader;
  Lexer: TLexer;
begin
  Reader := TReader.Create('+-<=/*qwe' + sLineBreak + '@#$fwe*//', itPrompt);
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
