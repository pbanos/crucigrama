# This module defines some methods of use to interact with {Crucigrama::Crossword}s
module Crucigrama::Positionable
  
  # @return [Hash<Symbol,Integer>] a hash with the horizontal and vertical coordinates
  # @param [Integer] x the horizontal coordinate
  # @param [Integer] y the vertical coordinate
  def position(x,y)
    {:horizontal => x, :vertical => y}
  end
  
  # @return [Symbol, nil] the direction opposite to the one given,
  #   that is, :horizontal for :vertical and :vertical for :horizontal;
  #   or nil if neither :horizontal nor :vertical is provided as direction
  # @param [:horizontal, :vertical, nil] direction the direction whose
  #   opposite is queried
  def direction_other_than(direction)
    { :horizontal => :vertical, :vertical => :horizontal}[direction]
  end
end