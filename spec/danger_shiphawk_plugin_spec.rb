# frozen_string_literal: true

require File.expand_path('spec_helper', __dir__)

describe Danger::ShiphawkPlugin do
  it 'should be a plugin' do
    expect(Danger::ShiphawkPlugin).to be < Danger::Plugin
  end

  describe 'with Dangerfile' do
    let(:rubocop_response_blank) do
      '{"files": []}'
    end
    let(:rubocop_response_with_errors) do
      <<-EOS
        {
          "files":[
            {
              "path":"Gemfile",
              "offenses":[{
                "message":"Prefer single-quoted strings",
                "cop_name":"Style/StringLiterals"
              }]
            },
            {
              "path":"app.rb",
              "offenses":[{
                "message":"Unexpected token",
                "cop_name":"Lint/Syntax"
              }]
            },
            {
              "path":"helper.rb",
              "offenses":[{
                "severity":"convention",
                "message":"Line is too long. [88/80]",
                "cop_name":"Metrics/LineLength"
              }]
            }
          ]
        }
      EOS
    end

    before do
      @dangerfile = testing_dangerfile
      @shiphawk_plugin = @dangerfile.shiphawk_plugin
    end

    context 'rubocop launch' do
      it 'with format only' do
        expect_any_instance_of(described_class).to receive(:`)
          .with('rubocop --format json .').and_return(rubocop_response_blank)

        @shiphawk_plugin.checkup
      end

      it 'with config-file' do
        expect_any_instance_of(described_class).to receive(:`)
          .with('rubocop --format json --config hello.txt .').and_return(rubocop_response_blank)

        @shiphawk_plugin.checkup(config: 'hello.txt')
      end

      it 'with diff only files to lint' do
        expect(@shiphawk_plugin.git).to receive(:modified_files).and_return(['temp.rb'])
        expect(@shiphawk_plugin.git).to receive(:added_files).and_return(['log/temp.rb'])

        expect_any_instance_of(described_class).to receive(:`)
          .with('rubocop --format json temp.rb log/temp.rb').and_return(rubocop_response_blank)

        @shiphawk_plugin.checkup(files: 'diff')
      end
    end

    context 'offenses' do
      before do
        expect_any_instance_of(described_class).to receive(:`)
          .with('rubocop --format json .').and_return(rubocop_response_with_errors)
      end

      it 'check errors messages' do
        @shiphawk_plugin.checkup(autofix_count: 0)

        errors = @dangerfile.status_report[:errors]

        expect(errors).to match_array([
                                        '## Syntax error detected:\\napp.rb\\nUnexpected token'
                                      ])
      end

      it 'check autofix error message' do
        @shiphawk_plugin.checkup

        errors = @dangerfile.status_report[:errors]

        expect(errors).to match_array([
                                        '## Syntax error detected:\\napp.rb\\nUnexpected token',
                                        '## Please fix rubocop mistakes: `rubocop --auto-correct`'
                                      ])
      end

      it 'check warning messages' do
        @shiphawk_plugin.checkup

        warnings = @dangerfile.status_report[:warnings]

        expect(warnings.size).to eq(2 + 1)
        expect(warnings).to match_array([
                                          'Gemfile\\nPrefer single-quoted strings',
                                          'helper.rb\\nLine is too long. [88/80]',
                                          "To locally check these files run: \n `rubocop app.rb Gemfile helper.rb`"
                                        ])
      end

      it 'check compact messages' do
        @shiphawk_plugin.checkup(limit_of_warnings: 2)

        warnings = @dangerfile.status_report[:warnings]

        expect(warnings.size).to eq(1 + 1 + 1)
        expect(warnings).to match_array([
                                          'Gemfile\\nPrefer single-quoted strings',
                                          '...And other 1 warnings',
                                          "To locally check these files run: \n `rubocop app.rb Gemfile helper.rb`"
                                        ])
      end
    end
  end
end
