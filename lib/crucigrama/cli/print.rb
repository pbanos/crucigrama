require 'crucigrama/cli'
require 'optparse'
class Crucigrama::CLI::Print
  Crucigrama::CLI.register 'print', self, "Prints a crossword to a PDF file"
  
  def options_parser
    @options_parser ||= OptionParser.new do |opts|
      opts.banner = "Usage: #{Crucigrama::CLI.cli_command} print options"
      opts.separator ""
      opts.separator "Options:"
      opts.on("-o", "--output PDF_FILE", "Prints the crossword to PDF_FILE") do |file|
        @options[:output_file] = file
      end
      opts.on("-i", "--input JSON_FILE", "Extracts the crossword from the JSON_FILE file") do |file|
        begin
          @options[:json_crossword] = File.read(file)
        rescue Exception => exc
          STDERR.puts exc.message
        end
      end
      opts.on("--[no-]solution", "Prints a reduced and inverted solution for the crossword next to it") do |value|
        @options[:include_solution] = value
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
    unless options[:json_crossword]
      STDERR.puts "Must specify input file!"
      exit 1
    end
    unless options[:output_file] 
      STDERR.puts "Must specify output file!"
      exit 1
    end
  end
  
  def initialize(*args)
    extract_options(*args)
    crossword = begin
      Crucigrama::Crossword.new(MultiJson.decode(options[:json_crossword]))
    rescue Exception => exc
      STDERR.puts exc.message
      STDERR.puts "Could not parse input crossword!"
      exit 1
    end
    begin
      crossword.to_pdf(options[:output_file], :include_solution => options[:include_solution])
    rescue Exception => exc
      STDERR.puts exc.message
      STDERR.puts "Could not print crossword!"
      exit 1
    end
  end
  
  private
  
  attr_reader :options
end