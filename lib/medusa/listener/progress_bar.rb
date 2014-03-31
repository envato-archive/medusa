module Medusa #:nodoc:
  module Listener #:nodoc:
    # Output a progress bar as files are completed
    class ProgressBar < Medusa::Listener::Abstract

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

        Curses.noecho
        Curses.init_screen        
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

      def initializer_output(line, initializer, worker)
        line = line.to_s.split("\n").last
        id = worker.respond_to?(:[]) ? worker[:id] : worker.worker_id
        
        @workers[id] = "#{initializer.class.name}: #{line}"
        render
      end

      def initializer_failure(worker, initializer, result)
        @worker_failures << [
          "Initializer failed: #{initializer.class}",
          "Command: #{result.command}",
          result ? result.output.split("\n") : ""
        ].flatten
      end

      def result_received(file, result)
        if result.failure? || result.fatal?
          @errors = true
          @error_collection << [result.description, result.exception, result.exception_backtrace]
        end

        @tests_executed += 1
        @fatals += 1 if result.fatal?
        render_progress_bar
      end

      # Increment completed files count and update bar
      def file_end(file)
        @files_completed += 1
        @files.delete(file)
        render_progress_bar
      end

      # Break the line
      def testing_end
        Curses.close_screen

        if @mode == :test
          render_progress_bar
          render_time
        end

        render_errors
      end

      private

      def render
        if @mode == :setup
          Curses.clear

          @workers.each_with_index do |(worker, message), index|
            Curses.setpos(index, 0)
            Curses.addstr("Worker #{index}: #{message}")
          end

          Curses.refresh
        else
          render_progress_bar
        end
      end

      def render_time
        duration = Time.now - @start_at
        @output.write "\n\nCompleted in #{duration}s\n\n"
      end

      def render_errors
        @error_collection.each do |(name, exception, backtrace)|
          @output.write "#{name}\n"
          @output.write "#{exception}\n"
          @output.write "#{backtrace}\n"
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
      end

      def render_progress_bar
        width = 30
        complete = ((@files_completed.to_f / @total_files.to_f) * width).to_i
        @output.write "\r" # move to beginning
        @output.write 'Medusa Testing ['
        @output.write @errors ? "\033[0;31m" : "\033[0;32m"
        complete.times{@output.write '#'}
        @output.write '>'
        (width-complete).times{@output.write ' '}
        @output.write "\033[0m"
        @output.write "] #{@files_completed}/#{@total_files} - #{@tests_executed} completed, #{@error_collection.length} failures, #{@fatals} fatals."
        @output.flush
      end
    end
  end
end

