program GearTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  TestReaderUnit in 'TestReaderUnit.pas',
  ReaderUnit in '..\ReaderUnit.pas',
  TokenUnit in '..\TokenUnit.pas',
  LexerUnit in '..\LexerUnit.pas',
  TestLexerUnit in 'TestLexerUnit.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

