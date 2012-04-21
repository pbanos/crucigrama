require 'crucigrama'

module Crucigrama::CLI
  @@commands = {}
  @@cli_command =  nil
  
  def self.cli_command
    @@cli_command
  end
  
  def self.cli_command=(value)
    @@cli_command = value
  end
  
  def self.register(command, command_handler, description)
    @@commands[command] = {:command_handler => command_handler, :description => description}
  end
  
  def self.deregister(command)
    @@commands.delete(command)
  end
  
  def self.run(*args)
    command = args.delete_at(0)
    if command = @@commands[command]
      command[:command_handler].new(*args)
    else
      show_banner
    end
  end
  
  def self.show_banner
    puts "\nUsage: #{self.cli_command} command [options]\n
where command can be one of the following:\n
#{@@commands.collect do |key, value| 
      "#{key}: #{value[:description]}"
    end.join("\n")}\n\n"
  end
end