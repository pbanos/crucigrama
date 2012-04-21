class Crucigrama::GrillBuilder < Crucigrama::CrosswordBuilder
  
  attr_reader :grill_spacing
  
  def initialize(opts = {})
    @grill_spacing = opts.delete(:grill_spacing) || 2
    super(opts)
  end
  
  def build
    grill_spacing.times do |i|
      (i..crossword.dimensions.values.max-1).step(grill_spacing).each do |coordinate|
        fill_line(coordinate,:horizontal) if crossword.dimensions[:horizontal] > coordinate
        fill_line(coordinate,:vertical) if crossword.dimensions[:vertical] > coordinate
      end
    end
    crossword
  end
  
  private
  
  def fill_line(index, direction)
    result = []
    other_direction = direction_other_than(direction)
    positions_to_try = crossword.black_positions.select{|position| position[other_direction]==index}
    tried_positions = []
    until positions_to_try.empty? do
      position = positions_to_try.first
      word_position = position_to_start_word(position, direction)
      result << set_longest_word_at(word_position, direction)
      tried_positions << position
      positions_to_try = crossword.black_positions.select{|position| position[other_direction]==index} - tried_positions
    end
    result.compact
  end
  
  # @todo Remove first previous_position declaration?
  def position_to_start_word(position, direction)
    return position if position[direction] == 0
    if (position_word = crossword.word_at(position, direction)).nil?
      previous_position = position.merge(direction => position[direction]-1) 
      unless position_word = crossword.word_at(previous_position, direction)
        return position
      end
    end
    other_direction = direction_other_than(direction)
    crossword.word_positions[position_word][direction].select do |word_position| 
      position[other_direction] == word_position[other_direction] and word_position[direction] <= position[direction] 
    end.last
  end
end