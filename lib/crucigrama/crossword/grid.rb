# This module implements the behaviour associated to the crossword grid
module Crucigrama::Crossword::Grid
  
  # Initializes an empty crossword (without words) of the given dimensions
  # @param [Hash<Symbol,Integer>, optional] options the dimensions of the crossword
  # @option options [Integer] :horizontal the horizontal size of the crossword, that is, how many columns it has
  # @option options [Integer] :vertical the vertical size of the crossword, that is, how many rows it has
  # @option options [Hash] :dimensions a Hash with the :horizontal and :vertical options described above
  # @option options [String] :grid a raw representation of the crossword grid as described in #grid
  # @option options [Hash] :definitions the definitions for the word in the crossword as returned by method #definitions
  # @todo :dimensions option must be able to accept [x,y] representation according to Crucigrama::Positionable#position
  # @todo if accept options as array of two integers [x,y]
  def initialize(options={})
    super(options)
    options.to_options!
    @grid = {}
    if options[:grid]
      self.grid = options[:grid]
    else
      dimensions = {:horizontal => 10, :vertical => 10}.merge(options[:dimensions]||options)
      @grid[:horizontal] = Array.new(dimensions[:vertical].to_i){ Array.new(dimensions[:horizontal].to_i){self.class::BLACK}}
      @grid[:vertical] = Array.new(dimensions[:horizontal].to_i){ Array.new(dimensions[:vertical].to_i){self.class::BLACK}}
    end
  end
  
  # Builds the crossword grid specified
  # @param [String] grid a raw representation for the crossword grid to build
  def grid=(grid)
    @grid[:horizontal] = grid.split("\n").collect do |row|
      row.chars.to_a
    end
    @grid[:vertical] = @grid[:horizontal].collect.with_index do |row, i|
      row.collect.with_index do |char, j|
        @grid[:horizontal][j][i]
      end
    end
    grid_modified!
  end
  
  # @return [String] a raw representation for the crossword grid
  def grid
    @grid[:horizontal].collect do |row|
      "#{row.join}\n"
    end.join
  end
  
  
  # It adds a word to the crossword setting it on the given coordinates and direction, if it can be set.
  # @param [String] word the word to add to the crossword
  # @param [Hash<Symbol,Integer>] coordinates the coordinates of the crossword cell where the word must start
  # @option coordinates [Integer] :horizontal a number between 0 and the horizontal dimension of the
  #   crossword minus one specifying the row of the cell where the word must start
  # @option coordinates [Integer] :vertical a number between 0 and the vertical dimension of the 
  #   crossword minus one specifying the column of the cell where the word must start
  # @param [:horizontal, :vertical] direction the direction for the word to be set on the crossword
  # @return [Boolean] if the word can be set
  def add(word, coordinates, direction)
    constant_coordinate = direction_other_than(direction)
    word.chars.with_index do |char, word_position|
      @grid[direction][coordinates[constant_coordinate]][coordinates[direction]+word_position] = char
      @grid[constant_coordinate][coordinates[direction]+word_position][coordinates[constant_coordinate]] = char
    end
    grid_modified!
    true
  end
  
  # @return [Hash<Symbol,Integer>] the horizontal and vertical dimensions of the crossword
  def dimensions
    @dimensions ||={:horizontal =>@grid[:vertical].count, :vertical => @grid[:horizontal].count}
  end
  
  # @return [String] the char in the crossword at the given coordinates
  # @param [Hash<Symbol,Integer>] coordinates the coordinates for the crossword cell being queried
  # @option coordinates [Integer] :horizontal a number between 0 and the horizontal dimension of the
  #   crossword minus one specifying the row of the cell being queried
  # @option coordinates [Integer] :vertical a number between 0 and the vertical dimension of the 
  #   crossword minus one specifying the column of the cell being queried
  def char_at(coordinates)
    @grid[:horizontal][coordinates[:vertical]][coordinates[:horizontal]]
  end
  
  # @return [String] the line in the crossword in the given direction
  #   (row for :horizontal, column for :vertical) with the specified number
  # @param [Integer] coordinate a number between 0 and the horizontal dimension of the
  #   crossword minus one specifying the queried line
  # @param [:horizontal, :vertical] direction the direction of the line being queried
  def line(coordinate, direction)
    @grid[direction][coordinate].join
  end
  
  # @return [Array<String>] an array of lines in the given direction, that is, an array with the results
  # of calling {line(coordinate, direction)} on every line in the given dimension
  # @param [:horizontal, :vertical] direction the direction of the lines being queried
  def lines(direction)
    @grid[direction].collect(&:join)
  end
  
  private
  
  # It notifies the crossword that its internal grid changed, so that cached structure information may be discarded.
  # Every module included after this should provide an implementation that
  #  * Discards information depending on the grid
  #  * Calls super to allow the execution of other modules implementations of this method
  def grid_modified!
  end
end