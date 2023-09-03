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
  PrinterUnit in 'PrinterUnit.pas',
  InterpreterUnit in 'InterpreterUnit.pas',
  EvalMathUnit in 'EvalMathUnit.pas';


var
  Input: string;
  Reader: TReader;
  Lexer: TLexer;
  Parser: TParser;
  Printer: TPrinter;
  Product: TProduct;
  Interpreter: TInterpreter;
begin
  Input := '5 + (5-1) * 6';
  Writeln('Input:');
  Writeln(Input);
  Writeln;
  Reader := TReader.Create(Input, itPrompt);
  Lexer := TLexer.Create(Reader);
  Parser := TParser.Create(Lexer);
  Interpreter := TInterpreter.Create;
  try
    Product := Parser.Parse;
    Printer := TPrinter.Create(Product);

    Writeln('AST:');
    Printer.Print;

    Writeln('Result:');
    Interpreter.Execute(Product);

    if Errors.Count >= 0 then
      for var e in Errors do
        Writeln(e.ToString);

    Readln;
  finally
    FreeAndNil(Reader);
    FreeAndNil(Lexer);
    FreeAndNil(Parser);
    FreeAndNil(Printer);
    FreeAndNil(Interpreter);
  end;
end.
