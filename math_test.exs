Code.require_file("assertion.ex", __DIR__)

defmodule MathTest do
  use Assertion

  test "integers can be added and subtracted" do
    assert 1 + 1 == 2
    assert 2 + 3 == 5
    assert 5 - 5 == 0
  end

  test "integers can be multiplied and divided" do
    assert 5 * 5 == 25
    assert 10 / 2 == 5
  end

  test "integers can be compared" do
    assert 5 > 4
    assert 4 >= 4
    assert 4 < 5
    assert 4 <= 4
  end

  test "integers are really integers" do
    assert is_integer(10)
  end
end

MathTest.run
