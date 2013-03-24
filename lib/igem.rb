=begin

IGem - run gem executables with forking, thus save the loading time. Can be used to speed up Rails generate, Rails server startup or Rake from minutes to seconds.

Usage:
    $ rails console
    >> igem "script/something.rb", "argument1 argument2"
    or
    >> igem "rake db:migrate"
    >> igem "rails server", wait: false
    >> igem "rake -T", fork: false
    >> Rails.server 

You can use a simpler syntax:

    IGem.rake "db:migrate"

You may not be able to change the Rails environment this way because bundler will not load gems from other envs


=end
module IGem

  class << self
    def method_missing method_name, cmdline, opts={}
      run "#{method_name} #{cmdline}", opts
    end

    # Runs the specified command line with forking and loading the gem
    # executable or ruby file.
    #
    # @param cmdline The command line with the executable as the first word. The
    # executable can be a ruby file, a gem executable or a gem name and a gem
    # executable like this: <tt>"rspec-core#rspec"</tt>
    #
    # @param opts a hash containing the options. The following options are
    # available.
    #      fork: true    to fork the process or just run in this one (! rails generate and some others will stop the process after running)
    #      wait: true    if fork is true, wait for the forked process with Process.wait
    #      reload: true  call reload! if it exists
    #      env: {}        update the environment with these values
    #
    def run cmdline, opts={}
      opts = {
        :fork=>Process.respond_to?(:fork),
        :wait=>true,
        :env=>{},
        :reload=>true
      }.merge(opts)

      # split cmdline
      cmd, *args = cmdline.scan(/(?:[^"\s]+|"[^"]+")+/).map{|s|s.chars.grep(/[^"]/).join}

      # find executable
      case cmd
      when /\//
        # for example scripts/something.rb
        executable = cmd
      when /#/
        gem, cmd = *cmd.split("#")

        # for example rspec-core#rspec
        executable = Gem.bin_path(gem, cmd)
      else 
        # for example rspec
        executable = Gem.bin_path(nil, cmd)
      end


      # reload
      if opts[:reload]
        reload! if respond_to? :reload!
      end


      # if fork is requested
      if opts[:fork]
        fork do
          ENV.update opts[:env]
          ARGV.replace args
          load executable
        end

        # wait if requested
        Process.wait if opts[:wait]
      else
        # run without forking

        ENV.update opts[:env]
        ARGV.replace args
        load executable
      end

      if defined? ActiveRecord 
        ActiveRecord::Base.connection.execute("") rescue ActiveRecord::Base.connection.reconnect! 
      end 
      nil
    end
  end
end

if defined? Rake
  def Rake.reload!
    Rake.application.clear
    Rails.application.class.load_tasks
    nil
  end
end

if defined? Rails
  require "igem/rails"
  module Rails
    extend IGem::Rails
  end
end

if defined? Rake
  require "igem/rake"
  module Rake
    extend IGem::Rake
  end
end

module Kernel
  def igem *args
    IGem.run *args
  end
end

