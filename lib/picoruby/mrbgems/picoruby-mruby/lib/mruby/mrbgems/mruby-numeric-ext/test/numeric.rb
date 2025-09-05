##
# Numeric(Ext) Test

assert('Integer#div') do
  assert_equal 52, 365.div(7)
end

assert('Float#div') do
  skip unless Object.const_defined?(:Float)
  assert_float 52, 365.2425.div(7)
end

assert('Integer#zero?') do
  assert_equal true, 0.zero?
  assert_equal false, 1.zero?
end

assert('Integer#nonzero?') do
  assert_equal nil, 0.nonzero?
  assert_equal 1000, 1000.nonzero?
end

assert('Integer#pow') do
  assert_equal(8, 2.pow(3))
  assert_equal(-8, (-2).pow(3))
  assert_equal(361, 9.pow(1024,1000))
end

assert('Integer#gcd') do
  assert_equal(1, 2.gcd(3))
  assert_equal(5, 10.gcd(15))
  assert_equal(6, 24.gcd(18))
  assert_equal(7, 7.gcd(0))
  assert_equal(7, 0.gcd(7))
  assert_equal(0, 0.gcd(0))
  assert_equal(5, (-10).gcd(15))
  assert_equal(5, 10.gcd(-15))
  assert_equal(5, (-10).gcd(-15))
end

assert('Integer#lcm') do
  assert_equal(6, 2.lcm(3))
  assert_equal(30, 10.lcm(15))
  assert_equal(72, 24.lcm(18))
  assert_equal(0, 7.lcm(0))
  assert_equal(0, 0.lcm(7))
  assert_equal(0, 0.lcm(0))
  assert_equal(30, (-10).lcm(15))
  assert_equal(30, 10.lcm(-15))
  assert_equal(30, (-10).lcm(-15))
end

assert('Integer#ceildiv') do
  assert_equal(0, 0.ceildiv(3))
  assert_equal(1, 1.ceildiv(3))
  assert_equal(1, 3.ceildiv(3))
  assert_equal(2, 4.ceildiv(3))

  assert_equal(-1, 4.ceildiv(-3))
  assert_equal(-1, -4.ceildiv(3))
  assert_equal(2, -4.ceildiv(-3))

  if Object.const_defined?(:Float)
    assert_equal(3, 3.ceildiv(1.2))
  end
  if Object.const_defined?(:Rational)
    assert_equal(3, 3.ceildiv(6/5r))
  end

#  assert_equal(10, (10**100-11).ceildiv(10**99-1))
#  assert_equal(11, (10**100-9).ceildiv(10**99-1))
  assert_equal(8, 2.pow(3))
  assert_equal(-8, (-2).pow(3))
#  assert_equal(361, 9.pow(1024,1000))
end

assert('Integer#even?') do
  assert_true(0.even?)
  assert_true(2.even?)
  assert_true(-2.even?)
  assert_false(1.even?)
  assert_false(-1.even?)

  # assert_true((10**100).even?)
  # assert_true((-10**100).even?)
  # assert_false((10**100+1).even?)
  # assert_false((-10**100-1).even?)
end

assert('Integer#odd?') do
  assert_false(0.odd?)
  assert_false(2.odd?)
  assert_false(-2.odd?)
  assert_true(1.odd?)
  assert_true(-1.odd?)

  # assert_false((10**100).odd?)
  # assert_false((-10**100).odd?)
  # assert_true((10**100+1).odd?)
  # assert_true((-10**100-1).odd?)
end

assert('Integer#digits') do
  assert_equal([5, 4, 3, 2, 1], 12345.digits)
  assert_equal([4, 6, 6, 0, 5], 12345.digits(7))
  assert_equal([45, 23, 1],     12345.digits(100))
end

assert('Integer.sqrt') do
  assert_equal(4, Integer.sqrt(16))
  assert_equal(10, Integer.sqrt(100))
  assert_equal(85, Integer.sqrt(7244))
end

assert('Integer#bit_length') do
  # zero
  assert_equal 0, 0.bit_length

  # positives
  assert_equal 1, 1.bit_length
  assert_equal 2, 2.bit_length
  assert_equal 2, 3.bit_length
  assert_equal 3, 4.bit_length
  assert_equal 3, 5.bit_length

  # negatives (use ~n semantics)
  assert_equal 0, (-1).bit_length
  assert_equal 1, (-2).bit_length
  assert_equal 2, (-3).bit_length
  assert_equal 2, (-4).bit_length
  assert_equal 3, (-5).bit_length

  # bigint cases may be enabled depending on config
  # assert_equal 100, (2**100 - 1).bit_length
  # assert_equal 101, (2**100).bit_length
  # assert_equal 0,  (-1).bit_length
end
