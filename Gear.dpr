program Gear;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ReaderUnit in 'ReaderUnit.pas',
  TokenUnit in 'TokenUnit.pas',
  LexerUnit in 'LexerUnit.pas',
  ErrorUnit in 'ErrorUnit.pas',
  AstUnit in 'AstUnit.pas',
  ParserUnit in 'ParserUnit.pas',
  VisitorUnit in 'VisitorUnit.pas',
  PrinterUnit in 'PrinterUnit.pas';

var
  Input: string;
  Reader: TReader;
  Lexer: TLexer;
  Parser: TParser;
  Printer: TPrinter;
  Product: TProduct;
begin
  Input := '5 + (5-1) * 6';
  Writeln('Input:');
  Writeln(Input);
  Writeln;
  Reader := TReader.Create(Input, itPrompt);
  Lexer := TLexer.Create(Reader);
  Parser := TParser.Create(Lexer);
  try
    Product := Parser.Parse;
    Printer := TPrinter.Create(Product);
    Printer.Print;

    Writeln('done.');
    Readln;
  finally
    FreeAndNil(Reader);
    FreeAndNil(Lexer);
    FreeAndNil(Parser);
    FreeAndNil(Printer);
  end;
end.
