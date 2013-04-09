module IGem::Rake
  # Reloads the rake tasks. This is necessary if you want to develop your rake
  # tasks and call them from the command line
  # 
  # Usage:
  #
  #     load "path/to/my/tasks.rake"
  #     igem "rake my:task"
  #     # see results, change code
  #     Rake.reload!
  #     load "path/to/my/tasks.rake"
  #     igem "rake my:task"
  #     ...
  def reload!
    Rake.application.clear
    if defined? Rails
      Rails.application.class.load_tasks
    end
    nil
  end
end
