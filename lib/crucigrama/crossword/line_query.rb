#This module provides methods for querying lines (rows or columns) on a crossword
module Crucigrama::Crossword::LineQuery
  # @return [String] the row with the specified number
  # @param [Integer] coordinate a number between 0 and the horizontal dimension of the
  #   crossword minus one specifying the queried row
  def row(coordinate)
    line(coordinate, :horizontal)
  end
  
  # @return [String] the column with the specified number
  # @param [Integer] coordinate a number between 0 and the vertical dimension of the
  #   crossword minus one specifying the queried column
  def column(coordinate)
    line(coordinate, :vertical)
  end
end