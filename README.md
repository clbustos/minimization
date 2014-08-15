= minimization

* http://github.com/clbustos/minimization

== DESCRIPTION:

Minimization algorithms on pure Ruby. 

== FEATURES/PROBLEMS:

Unidimensional:
* Newton-Rahpson (requires first and second derivative)
* Golden Section
* Brent (Port of GSL code)

Multidimensional:
* Fletcher-Reeves (requires first derivative)
* Polak Rebirer (requires first derivative)
* Nelder-Mead
* Powell's method

If you needs speed, use rb-gsl

== SYNOPSIS:

d=Minimization::Brent.new(-1000,20000  , proc {|x| x**2})

d.iterate

puts d.x_minimum
puts d.f_minimum

== REQUIREMENTS:

* Pure Ruby

== INSTALL:

  sudo gem install minimization 

== API:

http://ruby-statsample.rubyforge.org/minimization/

== LICENSE:

BSD 2-clause (See LICENSE.txt)
