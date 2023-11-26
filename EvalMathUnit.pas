unit EvalMathUnit;

interface

uses
  System.Classes, System.SysUtils, TokenUnit, ErrorUnit, Math, System.Variants, VariantHelperUnit, TupleUnit;

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

      class function _Or(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _And(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _XOr(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _Not(const Value: Variant; Op: TToken): Variant; static;
      class function _EQ(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _NEQ(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _GT(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _GE(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _LT(const Left, Right: Variant; Op: TToken): Variant; static;
      class function _LE(const Left, Right: Variant; Op: TToken): Variant; static;

      // boolean checks
      class function AreBothNumber(const Value1, Value2: Variant): Boolean; static;
      class function AreBothTuple(const Value1, Value2: Variant): Boolean; static;
      class function AreBothBoolean(const Value1, Value2: Variant): Boolean; static;
      class function AreBothString(const Value1, Value2: Variant): Boolean; static;
      class function OneOfBothBoolean(const Value1, Value2: Variant): Boolean; static;
      class function OneOfBothNull(const Value1, Value2: Variant): Boolean; static;
  End;

implementation

{ TMath }


class function TMath.AreBothBoolean(const Value1, Value2: Variant): Boolean;
begin
  Result :=     (VarType(Value1) = varBoolean)
            and (VarType(Value2) = varBoolean);
end;

class function TMath.AreBothNumber(const Value1, Value2: Variant): Boolean;
begin
  Result := VarIsNumeric(Value1) and VarIsNumeric(Value2);
end;

class function TMath.AreBothString(const Value1, Value2: Variant): Boolean;
begin
  Result := VarIsStr(Value1) and VarIsStr(Value2);
end;

class function TMath.AreBothTuple(const Value1, Value2: Variant): Boolean;
begin
  Result :=  VarIsList(Value1) and VarIsList(Value2);
end;

class function TMath.OneOfBothBoolean(const Value1, Value2: Variant): Boolean;
begin
  Result :=    (VarType(Value1) = varBoolean)
            or (VarType(Value2) = varBoolean);
end;

class function TMath.OneOfBothNull(const Value1, Value2: Variant): Boolean;
begin
  Result := VarIsNull(Value1) or VarIsNull(Value2);
end;

class function TMath._Add(const Left, Right: Variant; Op: TToken): Variant;
var
  Tuple: ITuple;
begin
  Result := Null;

  if VarIsStr(Left) then
    Result := VarToStr(Left) + VariantToStr(Right)
  else if OneOfBothNull(Left, Right) then
    Result := Null
  else if AreBothNumber(Left, Right) then
    Result := Left + Right
  else if AreBothTuple(Left, Right) then
  begin
    Tuple := ITuple(TTuple.Create);
    Tuple.AddFromTuple(ITuple(TVarData(Left).VPointer));
    Tuple.AddFromTuple(ITuple(TVarData(Right).VPointer));
    Result := Tuple;
  end
  else if VarIsList(Left) then
  begin
    Tuple := ITuple(TVarData(Left).VPointer);
    Tuple.Elements.Add(Right);
    Result := Left;
  end
  else
    Raise ERuntimeError.Create(Op, Format(ErrIncompatibleOperands, ['+']));
end;

class function TMath._And(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if areBothBoolean(Left, Right) then
  begin
    if not Left then
      Result := Left
    else
      Result := Right;
  end
  else
    Raise ERuntimeError.Create(Op, ErrMustBeBothBoolean);
end;

class function TMath._Div(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if AreBothNumber(Left, Right) then
  begin
    if Right <> 0 then
      Exit(Left / Right)
    else
      Raise ERuntimeError.Create(Op, ErrDivByZero);
  end
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['/']));
end;

class function TMath._EQ(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if    areBothBoolean(Left, Right)
          or areBothNumber(Left, Right)
          or AreBothString(Left, Right) then
  begin
    Result := Left = Right;
  end
  else
    Raise ERuntimeError.Create(Op, Format(ErrIncompatibleOperands, ['equal']));
end;

class function TMath._GE(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if oneOfBothNull(Left, Right) then
    Result := Null
  else if areBothNumber(Left, Right) then
    Result := Left >= Right
  else if areBothString(Left, Right) then
     Result := Left >= Right
  else
    Raise ERuntimeError.Create(Op, Format(ErrIncompatibleOperands, ['>=']));
end;

class function TMath._GT(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if oneOfBothNull(Left, Right) then
    Result := Null
  else if areBothNumber(Left, Right) then
    Result := Left > Right
  else if areBothString(Left, Right) then
    Result := Left > Right
  else
    Raise ERuntimeError.Create(Op, Format(ErrIncompatibleOperands, ['>']));
end;

class function TMath._LE(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if areBothNumber(Left, Right) then
    Result := Left <= Right
  else if areBothString(Left, Right) then
    Result := Left <= Right
  else
    Raise ERuntimeError.Create(Op, Format(ErrIncompatibleOperands, ['<=']));
end;

class function TMath._LT(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if oneOfBothNull(Left, Right) then
    Result := Null
  else if areBothNumber(Left, Right) then
    Result := Left < Right
  else if areBothString(Left, Right) then
    Result := Left < Right
  else
    Raise ERuntimeError.Create(Op, Format(ErrIncompatibleOperands, ['<']));
end;

class function TMath._Mul(const Left, Right: Variant; Op: TToken): Variant;
var
  str: string;
  N: Integer;
begin
  Result := Null;
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if     VarIsStr(Left)
          and VarIsNumeric(Right) then
  begin
    str := VarToStr(Left);
    N := Right;
    Result := '';
    for var i := 1 to N do //умножение строк как в питоне
      Result := Result + str;
  end
  else if AreBothNumber(Left, Right) then
    Result := Left * Right
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['*']));
end;

class function TMath._Neg(const Value: Variant; Op: TToken): Variant;
begin
  Result := Null;
  Result := Null;
  if VarIsNull(Value) then
    Result := Null
  else if VarType(Value) = varDouble then
    Result := -Value
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeNumber, ['-']));
end;

class function TMath._NEQ(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := not _EQ(Left, Right, Op);
end;

class function TMath._Not(const Value: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if VarIsNull(Value) then
    Result := Null
  else if VarType(Value) = varBoolean then
    Result := not Value
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeBoolean, ['Not']));
end;

class function TMath._Or(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if AreBothBoolean(Left, Right) then
  begin
    if Left then
      Result := Left
    else
      Result := Right;
  end
  else
    Raise ERuntimeError.Create(Op, ErrMustBeBothBoolean);
end;

class function TMath._Pow(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if AreBothNumber(Left, Right) then
    Result := Power(Left, Right)
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['^']));
end;

class function TMath._Rem(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if AreBothNumber(Left, Right) then
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
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if AreBothNumber(Left, Right) then
    Result := Left - Right
  else
    Raise ERuntimeError.Create(Op, Format(ErrMustBeBothNumber, ['-']));
end;

class function TMath._XOr(const Left, Right: Variant; Op: TToken): Variant;
begin
  Result := Null;
  if OneOfBothNull(Left, Right) then
    Result := Null
  else if areBothBoolean(Left, Right) then
     Result := Left xor Right
   else
     Raise ERuntimeError.Create(Op, ErrMustBeBothBoolean);
end;

end.
