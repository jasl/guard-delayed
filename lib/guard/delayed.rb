require 'guard'
require 'guard/guard'

module Guard
  class Delayed < Guard

    # Allowable options are:
    # :environment        defaults to 'test'
    # :min_priority       e.g. 2
    # :max_priority       e.g. 10
    # :number_of_workers  e.g. 2
    # :pid_dir            e.g. tmp/pids Specifies an alternate directory in which to store the process ids.
    # :identifier         A numeric identifier for the worker.
    # :monitor            Start monitor process.
    # :sleep-delay N      Amount of time to sleep in seconds when no jobs are found
    # :prefix NAME        String to be prefixed to worker process names
    # :command            Delayed_job script location, default is script/delayed_job

    def initialize(watchers = [], options = {})
      @command = options.delete(:command) || 'script/delayed_job'
      @options = options
      super(watchers, options)
    end

    def start
      run_cmd("stop")
      UI.info "Starting up delayed_job..."
      parameters  = "start"
      parameters << " --min-priority #{@options[:min_priority]}" if @options[:min_priority]
      parameters << " --max-priority #{@options[:max_priority]}" if @options[:max_priority]
      parameters << " --number_of_workers=#{@options[:number_of_workers]}" if @options[:number_of_workers]
      parameters << " --pid-dir=#{@options[:pid_dir]}" if @options[:pid_dir]
      parameters << " --identifier=#{@options[:identifier]}" if @options[:identifier]
      parameters << " --monitor" if @options[:monitor]
      parameters << " --sleep-delay #{@options[:sleep_delay]}" if @options[:sleep_delay]
      parameters << " --prefix #{@options[:prefix]} " if @options[:prefix]
      run_cmd(parameters)
    end

    # Called on Ctrl-C signal (when Guard quits)
    def stop
      UI.info "Stopping delayed_job..."
      run_cmd("stop")
    end

    # Called on Ctrl-Z signal
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    def reload
      UI.info "Restarting delayed_job..."
      restart
    end

    # Called on Ctrl-/ signal
    # This method should be principally used for long action like running all specs/tests/...
    def run_all
      restart
    end

    # Called on file(s) modifications
    def run_on_changes(paths)
      restart
    end

    private

    def restart
      run_cmd('restart')
    end

    def cmd
      command = "export RAILS_ENV=#{@options[:environment]}; #{@command}" if @options[:environment]
      command
    end

    def run_cmd(parameters)
      sys_response = system("#{cmd} #{parameters}")
      raise StandardError, "Bad command: #{cmd} #{parameters}" if sys_response.nil? || !sys_response
      sys_response
    end
  end
end
