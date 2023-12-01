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
  EvalMathUnit in 'EvalMathUnit.pas',
  LanguageUnit in 'LanguageUnit.pas',
  ProgrammUnit in 'ProgrammUnit.pas',
  MemoryUnit in 'MemoryUnit.pas',
  ResolverUnit in 'ResolverUnit.pas',
  CallableUnit in 'CallableUnit.pas',
  FuncUnit in 'FuncUnit.pas',
  StandardFunctionsUnit in 'StandardFunctionsUnit.pas',
  ListUnit in 'ListUnit.pas',
  VariantHelperUnit in 'VariantHelperUnit.pas',
  DictionaryUnit in 'DictionaryUnit.pas';

begin
  ProgrammUnit.DoRun;
end.
