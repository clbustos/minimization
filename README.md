# Minimization

[![Build Status](https://travis-ci.org/SciRuby/minimization.svg)](https://travis-ci.org/SciRuby/minimization)
[![Code Climate](https://codeclimate.com/github/SciRuby/minimization/badges/gpa.svg)](https://codeclimate.com/github/SciRuby/minimization)

* https://github.com/sciruby/minimization

## DESCRIPTION

Minimization algorithms on pure Ruby.

## FEATURES/PROBLEMS

Unidimensional:
* Newton-Rahpson (requires first and second derivative)
* Golden Section
* Brent (Port of GSL code)

If you needs speed, use rb-gsl

## SYNOPSIS

d=Minimization::Brent.new(-1000,20000  , proc {|x| x**2})

d.iterate

puts d.x_minimum
puts d.f_minimum

## REQUIREMENTS

* Pure Ruby

## INSTALL

  sudo gem install minimization

## API

http://ruby-statsample.rubyforge.org/minimization/

## LICENSE

GPL-2 (See LICENSE.txt)
