unit ProgrammUnit;

interface

uses
  System.SysUtils, LanguageUnit;

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
    or FindCmdLineSwitch('help') then
  begin
    WriteHelp;
  end
  else
  begin
    IsAstInArgs :=    FindCmdLineSwitch('ast')
                   or FindCmdLineSwitch('a');

    IsExecuteInArgs :=    FindCmdLineSwitch('execute')
                       or FindCmdLineSwitch('e');

    IsFileInArgs :=    FindCmdLineSwitch('file')
                    or FindCmdLineSwitch('f');

    IsFileNeeded := IsAstInArgs or IsExecuteInArgs;


    if IsFileNeeded and not IsFileInArgs then
      ErrorMsg := 'Input file name is required.';

    if    (ErrorMsg = '')
      and IsFileInArgs
      and (   FindCmdLineSwitch('file', InputFileName)
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
        Language.ExecutePrintAST(InputFileName)
      else if IsExecuteInArgs then
        Language.ExecuteFromFile(InputFileName)
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
  Writeln('Поиогаю');
end;


end.
