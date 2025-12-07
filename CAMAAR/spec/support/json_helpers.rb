# frozen_string_literal: true
module JsonHelpers
  def fixture_file(path)
    Rails.root.join('spec', 'fixtures', 'files', path)
  end

  def read_json_fixture(path)
    File.read(fixture_file(path))
  end
end

RSpec.configure do |config|
  config.include JsonHelpers
end
