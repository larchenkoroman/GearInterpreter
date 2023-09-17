unit ProgrammUnit;

interface

uses
  System.SysUtils, System.IOUtils, LanguageUnit;

procedure DoRun;
procedure WriteHelp;


implementation

procedure DoRun;
var
  ErrorMsg: String;
  InputFileName: String;
  IsFileNeeded: Boolean;
  IsFileInArgs: Boolean;
  IsAstInArgs: Boolean;
  IsExecuteInArgs: Boolean;
begin
  InputFileName := '';
  ErrorMsg := '';

  if   FindCmdLineSwitch('h')
    or FindCmdLineSwitch('-help') then
  begin
    WriteHelp;
  end
  else
  begin
    IsAstInArgs :=    FindCmdLineSwitch('-ast')
                   or FindCmdLineSwitch('a');

    IsExecuteInArgs :=    FindCmdLineSwitch('-execute')
                       or FindCmdLineSwitch('e');

    IsFileInArgs :=    FindCmdLineSwitch('-file')
                    or FindCmdLineSwitch('f');

    IsFileNeeded := IsAstInArgs or IsExecuteInArgs;


    if IsFileNeeded and not IsFileInArgs then
      ErrorMsg := 'Input file name is required.';

    if    (ErrorMsg = '')
      and IsFileInArgs
      and (   FindCmdLineSwitch('-file', InputFileName)
           or FindCmdLineSwitch('f', InputFileName)
          ) then
    begin
      if not FileExists(InputFileName) then
        ErrorMsg := 'Input file does not exist.';

      if    (ErrorMsg = '')
        and not (ExtractFileExt(InputFileName) = '.gear') then
      begin
        ErrorMsg := 'File extension must be ".gear".';
      end;
    end;


    if ErrorMsg = '' then
    begin
      if IsAstInArgs then
      begin
        Language.ExecutePrintAST(InputFileName);
        Readln;
      end
      else if IsExecuteInArgs then
      begin
        Language.ExecuteFromFile(InputFileName);
        Readln;
      end
      else
        Language.ExecuteFromPrompt;
    end
    else
    begin
      Writeln('ErrorMsg');
    end
  end;
end;



procedure WriteHelp;
begin
  writeln('Usage: ', TPath.GetFileNameWithoutExtension(ParamStr(0)), ' -h -(a|x|c) -f filename.gear');
  writeln('Option:    -h --help               Show help');
  writeln('Option:    -a --ast                Print AST');
  writeln('Option:    -x --execute            Execute product');
  writeln('Option:    -c --compile            Compile product');
  writeln('Required:  -f --file= filename     Input product');
  writeln('No parameters: start REPL');
  Readln;
end;


end.
