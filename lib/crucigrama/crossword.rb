require 'active_support/hash_with_indifferent_access'

# This class represents a crossword
# @todo Refactor methods to modules Crucigrama::Crossword::Grid, 
#   Crucigrama::Crossword::WordQuery and Crucigrama::Crossword::Definitions
# @todo Define public API and make everything else private
class Crucigrama::Crossword
  
  # The symbol used to represent empty cells on the crossword, that is, cells occupied by no word characters
  BLACK = '#'
  
  require 'crucigrama/crossword/grid'
  require 'crucigrama/crossword/line_query'
  require 'crucigrama/crossword/word_query'
  require 'crucigrama/crossword/definitions'
  
  include Grid
  include LineQuery
  include WordQuery
  include Definitions
  
  begin
    require 'crucigrama/crossword/pdf_printable'
    include PdfPrintable
  rescue LoadError
  end
  
  require 'crucigrama/crossword/serializable'
  include Serializable
  
  include Crucigrama::Positionable
   
  
  def to_s
    "\n#{grid}"
  end
  
end