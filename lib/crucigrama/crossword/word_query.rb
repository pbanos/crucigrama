# This module provides methods to query word existence, placement and search on a crossword
module Crucigrama::Crossword::WordQuery
  
  
  # @return [String, nil] the word in the crossword at the given coordinates and direction, if there is one, or nil otherwise
  # @param [Hash<Symbol,Integer>] coordinates the coordinates for the crossword cell being queried
  # @option coordinates [Integer] :horizontal a number between 0 and the horizontal dimension of the
  #   crossword minus one specifying the row of the cell being queried
  # @option coordinates [Integer] :vertical a number between 0 and the vertical dimension of the 
  #   crossword minus one specifying the column of the cell being queried
  # @param [:horizontal,:vertical] direction the direction of the word being queried
  def word_at(coordinates, direction)
    other_direction = direction_other_than(direction)
    words.detect do |word|
      (word_positions[word][direction]||=[]).detect do |position|
        position[other_direction] == coordinates[other_direction] and position[direction] <= coordinates[direction] and position[direction] + word.length > coordinates[direction]
      end
    end
  end
  
  # @return [Boolean] if the word at the given coordinates and direction on the crossword is the given word
  # @param [Hash<Symbol,Integer>] coordinates the coordinates for the crossword cell being queried
  # @option coordinates [Integer] :horizontal a number between 0 and the horizontal dimension of the
  #   crossword minus one specifying the row of the cell being queried
  # @option coordinates [Integer] :vertical a number between 0 and the vertical dimension of the 
  #   crossword minus one specifying the column of the cell being queried
  # @param [:horizontal,:vertical] direction the direction of the word being queried
  # @param [String] word the word that is or is not the word at the crossword
  def word_at?(coordinates, direction, word)
    word_at(coordinates, direction) == word
  end
  
  # @return [Array<Hash<Symbol,Integer>>] the list of black positions (or empty cells) in the crossword
  def black_positions
    @black_positions ||= lines(:horizontal).collect.with_index do |row, vertical_index|
      row.chars.collect.with_index do |cell, horizontal_index|
        cell == self.class::BLACK ? {:horizontal => horizontal_index, :vertical => vertical_index} : nil
      end.compact
    end.flatten
  end
  
  # @return [Array<String>] the list of words present in the crossword
  def words
    word_positions.keys
  end
  
  # @return [Hash<String,Hash<Symbol, Array<Hash<Symbol, Integer>>>>] a relation of the
  #   words in the crosswords and their starting positions in both directions. Words are
  #   the primary key in the returned tree, followed by the direction (:horizontal or
  #   :vertical). The list of positions is given as an Array of hashes with values for
  #   the :horizontal and :vertical coordinates 
  # @todo reimplement using lines(direction)
  def word_positions
    @word_positions ||= begin
      result = {}
      [:horizontal, :vertical].each do |direction|
        other_direction = direction_other_than(direction)
        lines(direction).each.with_index do |row, row_index|
          position = 0
          row.split(self.class::BLACK).each do |word|
            unless word.empty?
              result[word]||= {}
              result[word][direction]||= []
              result[word][direction] << {direction => position, other_direction=> row_index}
            end
            position+= word.length + 1
          end
        end
      end
      result
    end
  end
  
  # @return [Boolean] if the given word can be set on the crossword on the given coordinates and the given direction.
  #   The word can be set if it is not out of bounds on the crossword (that is, the cells it would occupy are defined)
  #   and if every crossword cell it would occupy either contains the corresponding word character or is a black
  #   position or empty cell.
  def can_set_word?(word, coordinates, direction)
    return false if out_of_bounds(word, coordinates, direction)
    return true if word.empty?
    other_direction = direction_other_than(direction)
    line = line(coordinates[other_direction], direction)
    regexp_str = line[coordinates[direction]..line.length][0..word.length-1].gsub(self.class::BLACK, '.')
    Regexp.new(regexp_str).match(word)
  end
  
  private
  
  # @return [Boolean] whether the given word would be out of bounds on the
  #   crossword on the given coordinates and direction
  # @param [Hash<Symbol,Integer>] coordinates the coordinates for the crossword cell where the queried word would start
  # @option coordinates [Integer] :horizontal a number between 0 and the horizontal dimension of the
  #   crossword minus one specifying the row of the cell where the queried word would start
  # @option coordinates [Integer] :vertical a number between 0 and the vertical dimension of the 
  #   crossword minus one specifying the column of the cell where the queried word would start
  def out_of_bounds(word, coordinates, direction)
    other_direction = direction_other_than(direction)
    coordinates[:horizontal] < 0 or coordinates[:vertical] < 0 or dimensions[other_direction] <= coordinates[other_direction] or dimensions[direction] <= coordinates[direction] + word.length - 1
  end
  
  def grid_modified!
    @word_positions = nil
    @black_positions = nil
    super
  end

end