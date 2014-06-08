module Medusa #:nodoc:
  module Listener #:nodoc:
    # Output a progress bar as files are completed
    class ControlPanel < Medusa::Listener::Abstract

      def initialize(*args)
        require 'curses'

        super

        @workers = Hash.new
        @mode = :setup
        @worker_failures = []
        @runner_failures = []
        @error_collection = []
        @files_completed = 0
        @test_output = ""
        @errors = false
        @tests_executed = 0
        @fatals = 0
      end


      # Store the total number of files
      def testing_begin(files)
        @total_files = files.size
        @start_at = Time.now

        @files = files.dup

        @mode = :test

        render_progress_bar
      end

      def worker_startup_failure(worker, log)
        @worker_failures << log
      end

      def runner_startup_failure(runner, log)
        @runner_failures << log
      end

      def initializer_start(command, worker)
        @output.write("#{command}\n")
      end

      def initializer_result(command, worker)
        @output.write("#{command}\n")
      end

      def initializer_output(message, worker)
        line = message.output.to_s.split(/[\n\r]/).last
        id = worker.respond_to?(:[]) ? worker[:id] : worker.worker_id
        
        @workers[id] = "#{message.initializer}: #{line}"
        render
      end

      def initializer_failure(worker, initializer, result)
        @worker_failures << [
          "Initializer failed: #{initializer.class}",
          "Command: #{result.command}",
          result ? result.output.split("\n") : ""
        ].flatten
      end

      def result_received(result)
        if result.failure? || result.fatal?
          @errors = true
          @error_collection << [result.name, result.exception_class, result.exception_message, result.exception_backtrace, result.stdout]
        end

        @tests_executed += 1
        @fatals += 1 if result.fatal?
        render
      end

      # Increment completed files count and update bar
      def file_end(file)
        @files_completed += 1
        @files.delete(file)
        render
      end

      # Break the line
      def testing_end
        Curses.close_screen

        if @mode == :test
          render_summary
          render_time
        end

        render_errors
      end

      private

      def render
        setup!
        Curses.clear

        Curses.setpos(0,0)
        Curses.addstr("Medusa")

        @workers.each_with_index do |(worker, message), index|
          Curses.setpos(index + 2, 0)
          Curses.addstr("Worker #{index}: #{message}")
        end

        if @mode == :test
          render_progress_bar
        end

        Curses.refresh
      end

      def render_time
        duration = Time.now - @start_at
        @output.write "\n\nCompleted in #{duration}s\n\n"
      end

      def render_errors
        @error_collection.each do |(name, exception, message, backtrace, stdout)|
          @output.write "#{name}\n"
          @output.write "#{message}\n"
          @output.write "#{exception}\n"
          @output.write "#{backtrace.join("\n")}\n"
          if stdout.strip.length > 0
            @output.write "STDOUT:\n#{stdout}\n"
          end
          @output.write "\n\n"
        end

        if @runner_failures.length > 0
          @output.write ("\n\n#{@runner_failures.length} runner(s) failed to startup\n\n")
          @runner_failures.each do |log|
            Array(log).each do |line|
              @output.write("#{line}\n")
            end
          end
        end

        if @worker_failures.length > 0
          @output.write ("\n\n#{@worker_failures.length} worker(s) failed to startup\n\n")
          @worker_failures.each do |log|
            Array(log).each do |line|
              @output.write("#{line}\n")
            end
          end
        end

        @output.flush
      rescue => ex
        @output.write("ERROR: #{ex}")
        @output.flush
      end

      def render_summary
        @output.write "\n"
        @output.write "Completed #{@files_completed}/#{@total_files} - #{@tests_executed} completed, #{@error_collection.length} failures, #{@fatals} fatals.\n"
        @output.write "#{@workers.length} workers.\n"
      end

      def render_progress_bar
        setup!
        width = 30
        Curses.setpos(@workers.length + 4, 5)
        complete = ((@files_completed.to_f / @total_files.to_f) * width).to_i
        Curses.addstr 'Medusa Testing ['
        complete.times{Curses.addstr '#'}
        Curses.addstr '>'
        (width-complete).times{Curses.addstr ' '}
        Curses.addstr "] #{@files_completed}/#{@total_files} - #{@tests_executed} completed, #{@error_collection.length} failures, #{@fatals} fatals."

      rescue
        Curses.addstr("ERROR")
        Curses.refresh
      end

      def setup!
        @setup ||= begin
          Curses.noecho
          Curses.init_screen
          Curses.setpos(0,0)
          Curses.addstr("Medusa")
          Curses.refresh
          true
        end

      end
    end
  end
end

