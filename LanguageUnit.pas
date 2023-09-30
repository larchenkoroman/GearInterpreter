unit LanguageUnit;

interface

uses
  System.Classes, System.SysUtils, ReaderUnit, ParserUnit, LexerUnit, AstUnit, ErrorUnit, InterpreterUnit, PrinterUnit, ResolverUnit;

type
  Language = record
    private
      class procedure PrintAST(Tree: TProduct); static;
      class procedure Execute(const ASource: string; AInputType: TInputType); static;
    public
      class var Interpreter :TInterpreter;
      class procedure ExecuteFromFile(const ASource: string); static;
      class procedure ExecuteFromPrompt; static;
      class procedure ExecutePrintAST(const ASource: string); static;
  end;

const
  GearVersion = 'v0.1';

implementation

{ Language }

class procedure Language.Execute(const ASource: string; AInputType: TInputType);
var
  Reader: TReader;
  Lexer: TLexer;
  Parser: TParser;
  Tree: TProduct;
  Resolver: TResolver;
begin
  Tree := nil;
  try
    Reader := TReader.Create(ASource, AInputType);
    Lexer := TLexer.Create(Reader);
    Parser := TParser.Create(Lexer);
    Tree := Parser.Parse;

    Resolver := TResolver.Create;
    Resolver.Resolve(Tree);

    if Errors.IsEmpty then
      Interpreter.Execute(Tree)
    else
      Writeln(Errors.ToString);
  finally
    If Assigned(Tree) then
      FreeAndNil(Tree);

    if Assigned(Reader) then
      FreeAndNil(Reader);

    if Assigned(Lexer) then
      FreeAndNil(Lexer);

    if Assigned(Parser) then
      FreeAndNil(Parser);

    if assigned(Resolver) then
      FreeAndNil(Resolver);
  end;
end;

class procedure Language.ExecuteFromFile(const ASource: string);
begin
  WriteLn('Gear Interpreter ', GearVersion, ' - (c) Roman Ltd 2023');
  Language.Execute(ASource, itFile);
end;

class procedure Language.ExecuteFromPrompt;
var
  Source: String;
  Quit: Boolean;
begin
  Source := '';
  Quit := False;
  WriteLn('Gear REPL ', GearVersion, ' - (c) Roman Ltd 2023', sLineBreak);
  while not Quit do
  begin
    Writeln;
    Write('Gear> ');
    ReadLn(Source);
    Quit := LowerCase(Source) = 'quit';
    if not Quit then
      Language.Execute(Source, itPrompt);
    Errors.Reset;
  end;
end;

class procedure Language.ExecutePrintAST(const ASource: string);
var
  Parser: TParser;
  Tree: TProduct;
begin
  Tree := nil;
  WriteLn('Gear AST ', GearVersion, ' - (c) Roman Ltd 2023');
  try
    Parser := TParser.Create(TLexer.Create(TReader.Create(ASource, itFile)));
    Tree := Parser.Parse;
    if not Errors.IsEmpty then
      Writeln(Errors.ToString)
    else
      PrintAST(Tree);
  finally
    FreeAndNil(Parser);
    if Assigned(Tree) then
      FreeAndNil(Tree);
  end;
end;

class procedure Language.PrintAST(Tree: TProduct);
var
  Printer: TPrinter;
begin
  Printer := nil;
  try
    try
      Printer := TPrinter.Create(Tree);
      Printer.Print
    except
      on E: Exception do
      begin
        Writeln('Unable to print the AST due to:');
        Writeln(E.Message);
      end;
    end;
  finally
    if Assigned(Printer) then
      FreeAndNil(Printer);
  end;
end;

initialization
  Language.Interpreter := TInterpreter.Create;

finalization
  FreeAndNil(Language.Interpreter);

end.
