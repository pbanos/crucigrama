# @todo document everything!
class Crucigrama::CrosswordBuilder
  
  NOT_REPEATABLE_WORD_MINIMUM_LENGTH = 3
  
  include Crucigrama::Positionable
  
  attr_reader :valid_words, :crossword_class, :crossword
  def initialize(opts = {})
    @valid_words = opts[:valid_words] || []
    @crossword_class = opts[:crossword_class] || Crucigrama::Crossword
    @crossword = @crossword_class.new(opts[:dimensions]||{})
  end
  
  
  def self.build_crossword(opts = {})
    self.new(opts).build
  end
  
  def build
    crossword.black_positions.each do |position|
      set_longest_word_at(position,:horizontal) unless crossword.word_at(position, :horizontal).to_s.length > 1
      set_longest_word_at(position,:vertical) unless crossword.word_at(position, :vertical).to_s.length > 1
    end
    crossword
  end
  
  def valid_word?(word)
    word == crossword_class::BLACK || word.length == 1 || valid_words.include?(word)
  end
  
  # @todo remove method ?
  def validate
    crossword.words.collect{|word| valid_word?(word)}.include?(false) ? false : true
  end
  
  # @todo return both the word and the position it was placed at ?
  def set_longest_word_at(word_position, direction)
    transversal_conditions = transversal_conditions_for(word_position, direction)
    not_word_destructive_condition = not_word_destructive_condition(word_position, direction)
    can_be_set_condition = can_be_set_condition(word_position, direction)
    already_used_words = used_words
    (2..crossword.dimensions[direction]-word_position[direction]).to_a.reverse.each do |length|
      restricting_word_conditions = [can_be_set_condition, *transversal_conditions[0..length-1], not_word_destructive_condition]
      eligible_words = restricting_word_conditions.inject(valid_words_by_length(length) - already_used_words) do |word_list, restricting_condition|
        word_list.select(&restricting_condition)
      end
      if word = eligible_words.sample
        raise "Could not add selected #{word} to crossword:\n#{crossword}" unless crossword.add(word, word_position, direction)
        return word
      end
    end
    nil
  end
  
  def adyacent_words_to_position(position, direction)
    return nil if crossword.word_at(position, direction)
    [crossword.word_at(position.merge(direction => position[direction]-1), direction), crossword.word_at(position.merge(direction => position[direction]+1), direction)]
  end
  
  def transversal_conditions_for(position, direction)
    (crossword.dimensions[direction] - position[direction]).times.collect do |word_index|
      adyacent_words = adyacent_words_to_position(position.merge(direction => position[direction]+word_index), direction_other_than(direction))
      lambda do |word|
        adyacent_words.nil? || valid_word?("#{adyacent_words[0]}#{word[word_index]}#{adyacent_words[1]}")
      end
    end
  end
  
  # @todo Remove ?
  #def word_length_condition(length)
  #  lambda do |word|
  #    word.length == length
  #  end
  #end
  
  def valid_words_by_length(length)
    @valid_words_by_length ||={}
    @valid_words_by_length[length] ||= valid_words.select{|word| word.length == length}
  end
  
  # @todo rename to not_word_invalidating_condition ?
  def not_word_destructive_condition(coordinates, direction)
    other_direction = direction_other_than(direction)
    line = crossword.line(coordinates[other_direction], direction)
    lambda do |word|
      words_at_line = line.dup.tap{|line| line[coordinates[direction]..coordinates[direction]+word.length-1]=word}.split(crossword_class::BLACK)
      words_at_line.detect{|word| valid_word?(word)==false}.nil?
    end
  end
  
  def can_be_set_condition(position, direction)
    other_direction = direction_other_than(direction)
    line = crossword.line(position[other_direction], direction)
    regexp_str = line[position[direction]..line.length].gsub(crossword_class::BLACK, '.')
    length_regexps = regexp_str.length.times.collect {|t| Regexp.new(regexp_str[0..t])}
    lambda do |word|
      if word.length > length_regexps.length
        false
      else
        word.empty? ? true : length_regexps[word.length - 1].match(word)
      end
    end
  end
  
  def used_words
    crossword.words.reject{|word| word.length < NOT_REPEATABLE_WORD_MINIMUM_LENGTH}
  end
  
end