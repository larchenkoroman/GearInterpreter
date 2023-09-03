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
// boolean checks
    class function areBothNumber(const Value1, Value2: Variant): Boolean; static;
    class function areBothString(const Value1, Value2: Variant): Boolean; static;
    class function areBothBoolean(const Value1, Value2: Variant): Boolean; static;
    class function oneOfBothBoolean(const Value1, Value2: Variant): Boolean; static;
    class function oneOfBothNull(const Value1, Value2: Variant): Boolean; static;

  End;

implementation

{ TMath }

class function TMath.areBothBoolean(const Value1,
  Value2: Variant): Boolean;
begin

end;

class function TMath.areBothNumber(const Value1, Value2: Variant): Boolean;
begin
  Result := VarIsNumeric(Value1) and VarIsNumeric(Value2);
end;

class function TMath.areBothString(const Value1, Value2: Variant): Boolean;
begin

end;

class function TMath.oneOfBothBoolean(const Value1,
  Value2: Variant): Boolean;
begin

end;

class function TMath.oneOfBothNull(const Value1, Value2: Variant): Boolean;
begin

end;

class function TMath._Add(const Left, Right: Variant; Op: TToken): Variant;
begin
if VarIsStr(Left) then
    Exit(Left + Right.toString);
  if areBothNumber(Left, Right) then
    Exit(Left + Right);
  Raise ERuntimeError.Create(Op, Format(ErrIncompatibleOperands, ['+']));
end;

class function TMath._Div(const Left, Right: Variant; Op: TToken): Variant;
begin

end;

class function TMath._Mul(const Left, Right: Variant; Op: TToken): Variant;
begin
  if areBothNumber(Left, Right) then
     Exit(Left * Right);
  Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['*']));
end;

class function TMath._Neg(const Value: Variant; Op: TToken): Variant;
begin
  if VarType(Value) = varDouble then
    Exit( -Value);
  Raise ERuntimeError.Create(Op, Format(ErrMustBeNumber, ['-']));
end;

class function TMath._Rem(const Left, Right: Variant; Op: TToken): Variant;
begin

end;

class function TMath._Sub(const Left, Right: Variant; Op: TToken): Variant;
begin
  if areBothNumber(Left, Right) then
      Exit(Left - Right);  Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['-']));
end;

end.
