= minimization

http://ruby-statsample.rubyforge.org/

== DESCRIPTION:

Minimization algorithms on pure Ruby. 

== FEATURES/PROBLEMS:

Unidimensional:
* Golden Section
* Brent (Port of GSL code)

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

== LICENSE:

GPL-2 (See LICENSE.txt)