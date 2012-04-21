require 'prawn'


# This module provides a to_pdf method that allows the printing of a crossword in PDF format
module Crucigrama::Crossword::PdfPrintable 
  
  # @return [Integer] the size in PDF points of a cell side
  PDF_CELL_SIZE = 20
  
  # Prints the crossword on the given file in PDF format
  # @param [String, Prawn::Document] file the name of the file (if a String) or the PDF document
  #   (if a Prawn::Document) where the crossword must be printed
  # @params [Hash<Symbol,Object>] options a set of options governing the PDF printing:
  # @option options [Boolean] :include_solution whether or not to print a reduced and inverted
  #  solved crossword next to the actual one (false by default)
  def to_pdf(file, options = {})
    drawing_block = Proc.new do |pdf|
      draw_crossword(pdf, :solved => false, :indexes => true)
      pdf.move_down PDF_CELL_SIZE
      if options[:include_solution]
        cursor = pdf.cursor
        draw_crossword(pdf, :solved => true, 
                            :at => [pdf.bounds.width - PDF_CELL_SIZE*(dimensions[:horizontal])/2, 
                                    pdf.cursor + PDF_CELL_SIZE*(dimensions[:vertical])/2],
                            :scale => 0.5,
                            :inverted => true)
        
        pdf.move_cursor_to cursor #- PDF_CELL_SIZE
      end
      pdf.move_down PDF_CELL_SIZE
      draw_definitions(pdf)
    end
    if file.is_a?(Prawn::Document)
      drawing_block.call(file)
    else
      Prawn::Document.generate(file, &drawing_block)
    end
  end
  
  private
  
  # Draws the crossword grid on the given Prawn::Document
  # @param [Prawn::Document] pdf the pdf on which to print the crossword grid
  # @param [Hash] options a set of options governing the crossword grid printing
  # @option options [Boolean] :indexes whether or not to draw column and row indexes (false by default)
  # @option options [Boolean] :inverted whether or not to draw the grid inverted (false by default)
  # @option options [Float] :scale a scaling factor for the crossword grid, to reduce or increase its size.
  #   The value by default, 1, will print it with cell sizes of {{Crucigrama::Crossword::PdfPrintable::PDF_CELL_SIZE}}
  # @option options [Array<Integer>] :at a 2-dimensional array indicating horizontal and vertical document coordinates
  #   where the upper left corner of the grid will be placed
  # @option options [Boolean] :solved whether or not to show the content for non-black crossword cells
  #   grid cells (false by default)
  def draw_crossword(pdf, options={})
    space_for_indexes = options[:indexes] ? 1 : 0
    options = options.merge(:height => PDF_CELL_SIZE*(dimensions[:vertical] + space_for_indexes), 
                            :width =>  PDF_CELL_SIZE*(dimensions[:horizontal] + space_for_indexes),
                            :rotation => options[:inverted] ? 180 : 0)
    options = { :at => [0, pdf.cursor], 
                :scale => 1}.merge(options)
    crossword_center = [options[:at][0]+options[:width]/2, options[:at][1]-options[:height]/2]
                
    # pdf.stroke_axis
    pdf.scale(options[:scale], :origin => options[:at]) do            
      pdf.rotate(options[:rotation], :origin => crossword_center) do
        pdf.bounding_box options[:at], options do
          dimensions[:horizontal].times do |x|
            dimensions[:vertical].times do |y|
              draw_cell(pdf,x,y,options)
            end
          end
          if options[:indexes]
            draw_indexes(pdf,options)
          end
        end
      end
    end
  end
  
  # Draws the crossword grid cell corresponding to the given coordinates on the given Prawn::Document
  # @param [Prawn::Document] pdf the pdf on which to print the crossword grid cell
  # @param [Integer] x The horizontal coordinate for the crossword cell to be printed
  # @param [Integer] y The vertical coordinate for the crossword cell to be printed
  # @param [Hash] options a set of options governing the crossword grid cell printing
  # @option options [Boolean] :indexes whether or not column and row indexes are being drawn (false by default)
  # @option options [Boolean] :solved whether or not to show the content for non-black crossword cells
  #   grid cells (false by default)
  def draw_cell(pdf, x, y, options={})
    index_space = options[:indexes] ? 1 : 0
    graphic_y = dimensions[:vertical]- y - index_space
    graphic_x = x + index_space
    pdf.stroke_rectangle *pdf_cell_box(graphic_x, graphic_y)
    cell_content = char_at(position(x,y))#@panel[:horizontal][y][x]
    if cell_content == self.class::BLACK
      pdf.fill_rectangle *pdf_cell_box(graphic_x, graphic_y)
    elsif options[:solved]
      pdf.text_box cell_content.upcase, :at => [graphic_x*PDF_CELL_SIZE, graphic_y*PDF_CELL_SIZE], 
                                 :height => PDF_CELL_SIZE, 
                                 :width => PDF_CELL_SIZE, 
                                 :align => :center, 
                                 :valign => :center
    end
  end
  
  # Draws the crossword grid indexes for a crossword grid on the given Prawn::Document
  # @param [Prawn::Document] pdf the pdf on which to print the crossword grid cell
  # @param [Hash] options a set of options governing the crossword grid cell printing (not yet used)
  def draw_indexes(pdf, options={})
    dimensions[:horizontal].times do |x|
      draw_index(pdf, x+1, dimensions[:vertical] , x+1)
    end
    dimensions[:vertical].times do |y|
      draw_index(pdf, 0, dimensions[:vertical] - (y+1), y+1)
    end
  end
  
  # Draws an index for a column or row on the given Prawn::Document
  # @param [Prawn::Document] pdf the pdf on which to print the crossword grid cell
  # @param [Integer] x The horizontal coordinate in {{PDF_CELL_SIZE}} units indicating where to place the index
  # @param [Integer] y The vertical coordinate in {{PDF_CELL_SIZE}} units indicating where to place the index
  # @param [Integer] n The index to be drawn
  def draw_index(pdf,x,y,n)
    pdf.text_box "#{n}", :at => [x*PDF_CELL_SIZE, y*PDF_CELL_SIZE], 
                               :height => PDF_CELL_SIZE, 
                               :width => PDF_CELL_SIZE, 
                               :align => :center, 
                               :valign => :center
  end
  
  # Draws the definitions for a crossword on the given Prawn::Document
  # @param [Prawn::Document] pdf the pdf on which to print the crossword grid cell
  # @param [Hash] options a set of options governing the crossword definition printing
  # @option options [Hash<Symbol, #to_s>] :headers Headers or titles for the horizontal and vertical definitions sections. 
  #  "Horizontal" and "Vertical" by default
  def draw_definitions(pdf, options={})
    options = {:headers => {}}.merge(options)
    cursor = pdf.cursor
    definitions_text = [:horizontal, :vertical].collect do |direction|
      "<b>#{(options[:headers][direction]||direction.to_s.capitalize)}</b>\n" + 
      Hash[(definitions[direction]||{}).sort].collect do |line, defs|
        "<b>#{line+1}</b>.- #{defs.values.join(". ")}"
      end.join(". ")
    end.join(".\n\n")
    pdf.text definitions_text, :inline_format => true
  end
  
  # @return [Array] A crossword cell box complying to {{Prawn::Document#fill_rectangle}} and {{Prawn::Document#stroke_rectangle}} interface
  # @param [Integer] x the horizontal coordinate for the cell box in PDF_CELL_SIZE units
  # @param [Integer] y the vertical coordinate for the cell box in PDF_CELL_SIZE units
  def pdf_cell_box(x,y)
    [[x*PDF_CELL_SIZE, y*PDF_CELL_SIZE], PDF_CELL_SIZE, PDF_CELL_SIZE]
  end
end