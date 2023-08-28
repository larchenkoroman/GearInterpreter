unit TestReaderUnit;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, System.SysUtils, System.Classes, ReaderUnit;

type
  // Test methods for class TReader

  TestTReader = class(TTestCase)
  strict private
    FReader: TReader;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestNextChar;
    procedure TestPeekChar;
  end;

implementation

procedure TestTReader.SetUp;
begin
  FReader := TReader.Create('153', itPrompt);
end;

procedure TestTReader.TearDown;
begin
  FreeAndNil(FReader);
end;

procedure TestTReader.TestNextChar;
begin
  CheckEquals('1', FReader.NextChar);
  CheckEquals('5', FReader.NextChar);
  CheckEquals('3', FReader.NextChar);
  CheckEquals(CHAR_EOF, FReader.NextChar);
end;

procedure TestTReader.TestPeekChar;
begin
  FReader.NextChar;
  CheckEquals('5', FReader.PeekChar);
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TestTReader.Suite);
end.

