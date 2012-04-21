require 'multi_json'

# This module provides methods to serialize a crossword
module Crucigrama::Crossword::Serializable
  
  # @return [Hash] a hash with the dimensions, grid and serialized definitions of a crossword
  def attributes
    {
      :dimensions => dimensions,
      :grid => grid,
      :definitions => serialized_definitions
    }
  end
  
  # @return [Hash] the definitions of a crossword in a JSON-compatible format
  def serialized_definitions 
    Hash[definitions.collect do |direction, defs|
      [direction, Hash[defs.collect do |line_number, line_defs|
        [line_number.to_s, Hash[line_defs.collect do |pos_number, definition|
          [pos_number.to_s, definition]
        end]]
      end]]
    end]
  end
  
  # @return [String] the attributes of the crossword as returned by #attributes in a JSON string
  def to_json
    MultiJson.encode(attributes)
  end 
  
end