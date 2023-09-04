unit EvalMathUnit;

interface

uses
  System.Classes, System.SysUtils, TokenUnit, ErrorUnit, Math, System.Variants;

type
  TMath = Record
    private
      const
        ErrIncompatibleOperands = 'Incompatible operand types for "%s" operation.';
        ErrMustBeBothNumber  = 'Both operands must be a number for "%s" operation.';
        ErrMustBeNumber = 'Operand must be a number for "%s" operation.';
        ErrMustBeBoolean = 'Operand must be a boolean for "%s" operation.';
        ErrMustBeBothBoolean = 'Both operands must be a boolean.';
        ErrDivByZero = 'Division by zero.';
        ErrConcatNotAllowed = 'Both types must be array for concat operation.';
        ErrArrayWrongTypes = 'Both variables must be array of same type.';
        ErrArrayMismatchElem = 'Mismatch in number of array elements in array operation.';
        ErrIncompatibleTypes = 'Incompatible types in assignment: %s vs. %s.';
    public
      class function _Add(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _Sub(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _Mul(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _Div(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _Rem(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _Neg(const Value: Variant; Op: TToken): Variant; static;
      class function _Pow(const Left, Right: Variant; Op: TToken): Variant; static;
// boolean checks
    class function AreBothNumber(const Value1, Value2: Variant): Boolean; static;

  End;

implementation

{ TMath }


class function TMath.AreBothNumber(const Value1, Value2: Variant): Boolean;
begin
  Result := VarIsNumeric(Value1) and VarIsNumeric(Value2);
end;

class function TMath._Add(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if VarIsStr(Left) then
    Result := VarToStr(Left) + VarToStr(Right)
  else if AreBothNumber(Left, Right) then
    Result := Left + Right
  else
    Raise ERuntimeError.Create(Op, Format(ErrIncompatibleOperands, ['+']));
end;

class function TMath._Div(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if AreBothNumber(Left, Right) then
  begin
    if Right <> 0 then
      Exit(Left / Right)
    else
      Raise ERuntimeError.Create(Op, ErrDivByZero);
  end
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['/']));
end;

class function TMath._Mul(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if AreBothNumber(Left, Right) then
    Result := Left * Right
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['*']));
end;

class function TMath._Neg(const Value: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if VarType(Value) = varDouble then
    Result := -Value
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeNumber, ['-']));
end;

class function TMath._Pow(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if AreBothNumber(Left, Right) then
    Result := Power(Left, Right)
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['^']));
end;

class function TMath._Rem(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if AreBothNumber(Left, Right) then
  begin
    if Right <> 0 then
      Exit(Left mod Right)
    else
      Raise ERuntimeError.Create(Op, ErrDivByZero);
  end;
  Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['%']));
end;

class function TMath._Sub(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if AreBothNumber(Left, Right) then
    Result := Left - Right
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['-']));
end;

end.
