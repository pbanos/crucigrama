# This module provides the behaviour related to crosswords' definitions
module Crucigrama::Crossword::Definitions
  
  # Initializes the definitions of a crossword if given
  # @param [Hash<Symbol,Integer>, optional] options the options of the crossword
  # @option options [Hash] :definitions the definitions for the word in the crossword as returned by method #definitions
  def initialize(options={})
    super(options)
    self.definitions = (options[:definitions]||{})
  end
  
  # @return [Hash<Symbol,Hash<Integer,Hash<Integer,String>>>] the definitions in the crossword, in a hash to be accessed
  # with keys direction (:horizontal or :vertical), the other direction coordinate and the given direction coordinate
  def definitions
    @definitions
  end
  
  # Sets the definitions for the crossword words
  # @param [Hash<String|Symbol,Hash<String|Integer,Hash<String|Integer,String>>>] defs the definitions
  def definitions=(defs)
    @definitions = Hash[defs.collect do |key,value|
      [key.to_sym, Hash[value.collect do |key, val|
          [key.to_i, Hash[val.collect{|k,v| [k.to_i, v]}]]
        end]]
    end]
  end
  
  # Adds a crossword definition for the given position and direction
  # @param [String] definition the definition to add
  # @param [Hash<Symbol, Integer>] position a hash with the horizontal and vertical
  #   coordinates of the cell where the defined word starts
  # @param [Symbol] direction the direction of the defined word, :horizontal or :vertical
  def add_definition(definition, position, direction)
    definitions[direction]||={}
    definitions[direction][position[direction_other_than(direction)]]||={}
    definitions[direction][position[direction_other_than(direction)]][position[direction]] = definition
  end
  
  # Removes a crossword definition for the given position and direction
  # @return [String,nil] the removed definition if found, nil otherwise
  # @param [Hash<Symbol, Integer>] position a hash with the horizontal and vertical
  #   coordinates of the cell where the word whose definition is to be removed starts
  # @param [Symbol] direction the direction of the word whose definition is to be removed,
  #   :horizontal or :vertical 
  def remove_definition(position, direction)
    if definitions[direction] and definitions[direction][position[direction_other_than(direction)]]
      definition = definitions[direction][position[direction_other_than(direction)]].delete(position[direction]) 
      definitions[direction].delete(position[direction_other_than(direction)]) if definitions[direction][position[direction_other_than(direction)]].empty?
      definition
    end
  end
  
  # @return [String,nil] the definition for the word at the given position and direction
  # @param [Hash<Symbol, Integer>] position a hash with the horizontal and vertical
  #   coordinates of the cell where the queried word starts
  # @param [Symbol] direction the direction of the queried word, :horizontal or :vertical
  def definition_for(position, direction)
    return nil unless definitions[direction] and definitions[direction][position[direction_other_than(direction)]]
    definitions[direction][position[direction_other_than(direction)]][position[direction]]
  end
end