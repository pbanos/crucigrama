
# The namespace for the crucigrama library, a ruby library for the generation of crosswords
module Crucigrama

  # The version for the Crucigrama library, according to RubyGems Rational Versioning Policy
  VERSION = File.read(File.join(File.dirname(__FILE__), '../../VERSION'))
  
  # The major version number for the Crucigrama library, according to RubyGems Rational Versioning Policy
  MAJOR, 
  # The minor version number for the Crucigrama library, according to RubyGems Rational Versioning Policy
  MINOR, 
  # The patch version number for the Crucigrama library, according to RubyGems Rational Versioning Policy
  PATCH = * VERSION.split('.')

end