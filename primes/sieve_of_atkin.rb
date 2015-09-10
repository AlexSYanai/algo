class SieveofAtkin
  attr_accessor :primes, :sieve
  attr_reader   :limit,  :finish
  def initialize(limit)
    @limit  = limit
    @finish = Math.sqrt(limit).round
    @primes = [2,3]
    @sieve  = Array.new(limit+1) { false }
  end

  def use_sieve
    1.upto(finish+1) do |i|
      1.upto(finish+1) do |j|
        first_60_check( 4*i**2 + j**2)
        second_60_check(3*i**2 + j**2)
        third_60_check((3*i**2 - j**2)) if i > j
      end
    end
    check_sieve
    check_primes
  end
  
  private
  def first_60_check(n)
    @sieve[n] = !sieve[n] if n <= limit && (n % 12 == 1 || n % 12 == 5)
  end

  def second_60_check(n)
    @sieve[n] = !sieve[n] if n <= limit &&  n % 12 == 7
  end

  def third_60_check(n)
    @sieve[n] = !sieve[n] if n <= limit &&  n % 12 == 11
  end

  def check_sieve
    5.upto(finish) { |n| set_primes(n) if sieve[n] }
  end

  def check_primes
    5.upto(limit)  { |n| @primes << n  if sieve[n] }
  end

  def set_primes(x)
    ((x**2)..(limit+1)).step(x**2).each { |n| @sieve[n] = false }
  end
end

sieve = SieveofAtkin.new(2000000)
sieve.use_sieve
p sieve.primes.last