# frozen_string_literal: true

require 'ostruct'
require 'shellwords'

module Danger
  # Run Ruby files through Rubocop.
  # Results are passed out in a hash with errors/warnings
  #
  # @example Specifying custom config file.
  #
  #          shiphawk_plugin.checkup
  #
  #
  # @see  ShipHawk/danger-shiphawk-plugin
  # @tags ruby, rubocop, rubocop-plugin
  #
  class ShiphawkPlugin < Plugin
    # Runs Ruby files through Rubocop. Generates a list of errors/warnings
    #
    # @param  [Hash] options
    # @return [void]
    def checkup(options = {})
      @files = options.fetch(:files, 'all')
      @config = options.fetch(:config, nil)
      @limit_of_warnings = options.fetch(:limit_of_warnings, 10)
      @autofix_count = options.fetch(:autofix_count, 30)

      return if offenses.empty?

      message_detailed_report
      message_compact_report
      message_hint
      message_autofix

      nil
    end

    private

    def offenses
      @offenses ||= detect_offenses
    end

    def detect_offenses
      rubocop_output = json_parse(rubocop)

      all_offenses = rubocop_output.files.flat_map do |file|
        offenses = file.offenses
        next [] if offenses.empty?

        offenses.map do |offense|
          OpenStruct.new(
            path: file.path,
            message: offense.message,
            serenity: serenity_lvl_for(offense.cop_name)
          )
        end
      end

      all_offenses.sort_by(&:serenity)
    end

    def rubocop
      command = ['rubocop']
      command << ['--format', 'json']
      command << ['--config', @config.shellescape] if @config

      `#{command.join(' ')} #{files_to_lint}`
    end

    def files_to_lint
      file_paths = case @files
      when 'all'
        Dir.glob('.')
      when 'diff'
        git.modified_files + git.added_files
      else
        raise ArgumentError, "Incorrect 'files' option"
      end

      Shellwords.join(file_paths)
    end

    def message_autofix
      return if offenses.empty?
      return if offenses.size > @autofix_count

      msg = '## Please fix rubocop mistakes: `rubocop --auto-correct`'
      print_message(msg, :fail)
    end

    def message_detailed_report
      wide_report_offenses = offenses[0...@limit_of_warnings]

      wide_report_offenses.each do |offense|
        msg = []
        msg << '## Syntax error detected:' if offense.serenity == :fail
        msg << offense.path
        msg << offense.message

        print_message(msg.join('\n'), offense.serenity)
      end
    end

    def message_compact_report
      compact_report_offenses = offenses[@limit_of_warnings..-1]

      return if compact_report_offenses.nil?

      msg = "...And other #{compact_report_offenses.size} warnings"
      print_message(msg, :warn)
    end

    def message_hint
      file_names = offenses.map(&:path).uniq
      file_paths_sentance = Shellwords.join(file_names)

      msg = "To locally check these files run: \n `rubocop #{file_paths_sentance}`"
      print_message(msg, :warn)
    end

    def print_message(message, serenity)
      __send__(serenity, message)
    end

    def serenity_lvl_for(cop_name)
      return :fail if cop_name == 'Lint/Syntax'

      :warn
    end

    def json_parse(data)
      JSON.parse(data, object_class: OpenStruct)
    end
  end
end
