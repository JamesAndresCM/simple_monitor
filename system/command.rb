class Command
  require 'open3'

  class CommandStatus
    @stdout     = nil
    @stderr     = nil
    @pid        = nil
    @exitstatus = nil

    def initialize(stdout, stderr, process)
      @stdout     = stdout
      @stderr     = stderr
      @pid        = process.pid
      @exitstatus = process.exitstatus
    end

    attr_reader :stdout

    attr_reader :stderr

    def exit_status
      @exitstatus
    end

    attr_reader :pid
  end


  def self.execute(command)
    command_stdout = nil
    command_stderr = nil
    process = Open3.popen3(ENV, command + ';') do |stdin, stdout, stderr, thread|
      stdin.close
      stdout_buffer   = stdout.read
      stderr_buffer   = stderr.read
      command_stdout  = stdout_buffer unless stdout_buffer.empty?
      command_stderr  = stderr_buffer unless stderr_buffer.empty?
      thread.value # Wait for Process::Status object to be returned
    end
    CommandStatus.new(command_stdout, command_stderr, process)
  end
end
