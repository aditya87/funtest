require 'sourcify'
require 'colorize'
require_relative './exceptions'
require_relative './assertions'
require_relative './section'

def describe(desc, &func)
  sp = Section.new(desc)
  pad = [' '] * Section::specstack.length * ''
  puts
  puts pad + desc.blue + ":"
  func.call
  Section::specstack.pop
  if Section::specstack.empty?
    puts
    msg = <<EOM
Result: #{sp.tests} ran, #{sp.passes.to_s.green} #{"passed".green}, #{sp.fails.to_s.red} #{"failed".red}
EOM
    puts msg
  else
    Section::lastspec.inc_tests sp.tests
    Section::lastspec.inc_passes sp.passes
    Section::lastspec.inc_fails sp.fails
  end
end

def it(desc, &func)
  pad = [' '] * Section::specstack.length * ''
  print pad + desc + ": "
  Section::lastspec.inc_tests
  begin
    Section::lastspec.run_setups
    func.call
    Section::lastspec.run_cleanups
  rescue BlockError
    Section::lastspec.inc_fails
    puts
    return
  end
  Section::lastspec.inc_passes
  puts
end

def setup(&func)
  Section::lastspec.push_setup(func)
end

def cleanup(&func)
  Section::lastspec.push_cleanup(func)
end
