# Run rails server and generator subcommands from the Rails console
#
# This is a solution based on http://blockgiven.tumblr.com/post/5161067729/rails-server
# Can be used to run rails server, rails generate from the Rails console thus
# speeding up Rails server startup to ~ 1 second.
#
# Usage:
#   Rails.server                     to start the rails server
#   Rails.generate                   to list generators
#   Rails.generate "model", "user"   to use a generator
#   Rails.update   "model", "user"   to update the generated code
#   Rails.destroy  "model", "user"   to remove the generated code
# 
# NOTE: after Rails.server, you cannot use Control-C anymore in the console
# because it first stops the server, secondly stops the process
#

module IGem::Rails

  def generate *args
    args = args[0].split(" ") if args.count == 1
    args = args.map{|e|e.to_s}
    require "rails/generators"
    Rails::Generators.help && return if args.empty?
    name = args.shift
    args << "--orm=active_record" if args.none? {|a|a =~ /--orm/}
    Rails::Generators.invoke name, args, :behavior => :invoke
  end

  alias g generate

  def destroy *args
    args = args[0].split(" ") if args.count == 1
    args = args.map{|e|e.to_s}
    require "rails/generators"
    Rails::Generators.help && return if args.empty?
    name = args.shift
    args << "--orm=active_record" if args.none? {|a|a =~ /--orm/}
    Rails::Generators.invoke name, args, :behavior => :revoke
  end

  alias d destroy

  def update *args
    args = args[0].split(" ") if args.count == 1
    args = args.map{|e|e.to_s}
    require "rails/generators"
    Rails::Generators.help && return if args.empty?
    name = args.shift
    args << "--orm=active_record" if args.none? {|a|a =~ /--orm/}
    Rails::Generators.invoke name, args, :behavior => :skip
  end

  def server options={:Port => 3000}
    require "rails/commands/server"

    return @server if defined? @server and @server.alive?

    if defined? @server and not @server.alive?
      ObjectSpace.each_object(TCPServer){|s| s.close if !s.closed? && s.addr[1] == options[:Port]}
    end

    @server = Thread.new do
      options[:Port] = options[:Port].to_s

      server = Rails::Server.new
      server.options.merge options
      server.start
    end
  end

  alias s server
end
