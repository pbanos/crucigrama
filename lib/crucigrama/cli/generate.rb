require 'crucigrama/cli'
require 'optparse'
class Crucigrama::CLI::Generate
  Crucigrama::CLI.register 'generate', self, "Generates a crossword"
  
  def options_parser
    @options_parser ||= OptionParser.new do |opts|
      opts.banner = "Usage: #{Crucigrama::CLI.cli_command} generate options"
      opts.separator ""
      opts.separator "Options:"
      opts.on("-l", "--lemary LEMARY", "Uses LEMARY as words source") do |lemary|
        begin
          @options[:lemary] = File.read(lemary).split("\n")
        rescue Exception => exc
          STDERR.puts exc.message
        end 
      end
      opts.on("-d", "--dimensions DIMENSIONS", "Generates crossword of DIMENSIONS size",
                                               "in nxn format (10x10 by default)") do |dimensions|
        unless match = /(\d)+x(\d)+/.match(dimensions)
          STDERR.puts "Incorrect dimensions format, it must be nxn (for example 10x11)"
          exit 1
        end                                        
        @options[:dimensions] = Hash[[:horizontal, :vertical].collect.with_index do |direction, i|
          [direction, match[i].to_i]
        end]
      end
      opts.on("-o", "--output FILE", "Dumps the generated crossword to FILE") do |file|
        @options[:file] = file
      end
      opts.on("--[no-]definitions", "Asks for definitions for the generated crossword") do |definitions|
        @options[:definitions] = definitions
      end
      opts.on("--[no-]reverse-words", "Allow reverse words for the generated crossword") do |value|
        @options[:allow_reverse] = value
      end
      opts.separator ""
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
      opts.on_tail("--version", "Show version") do
        puts Crucigrama::VERSION
        exit
      end
    end
  end
  
  def extract_options(*args)
    @options = {}
    options_parser.parse!(args)
    unless options[:lemary] 
      STDERR.puts "Must specify lemary file!"
      exit 1
    end
    if @options[:allow_reverse]
      @options[:lemary] = @options[:lemary].collect{|word| [word, word.reverse]}.flatten.uniq
    end
  end
  
  def initialize(*args)
    extract_options(*args)
    crossword = generate_crossword
    dump_crossword(crossword)
  end
  
  private
  
  attr_reader :options
  
  def generate_crossword
    crossword = Crucigrama::GrillBuilder.build_crossword(:valid_words => options[:lemary], :dimensions => options[:dimensions])
    STDERR.puts "Crossword generated with #{crossword.black_positions.count} black cells (#{100*crossword.black_positions.count.to_f/crossword.dimensions.values.inject(1,&:*)}%)"
    if options[:definitions]
      fill_with_definitions(crossword)
    end
    crossword
  end
  
  def dump_crossword(crossword)
    if options[:file]
      begin
        File.open(options[:file],'w'){|file| file.write(crossword.to_json)}
      rescue Exception => exc
        STDERR.puts exc.message
        exit 1
      end
    else
      puts crossword.to_json
    end
  end
  
  def fill_with_definitions(crossword)
    positions = Hash[ [:horizontal, :vertical].collect do |direction|
      [direction, crossword.word_positions.keys.select{|w| w.length > 1 and crossword.word_positions[w][direction] }.collect{|w| crossword.word_positions[w][direction]}.flatten(1)]
    end]
    positions.each do |direction, word_positions|
      STDERR.puts "#{direction.to_s.capitalize} definitions:"
      word_positions.each do |position|
        STDERR.puts "[#{position[:horizontal]+1}, #{position[:vertical]+1}] #{crossword.word_at(position, direction)}:"
        crossword.add_definition(STDIN.readline.strip, position, direction)
      end
    end
  end
  
end