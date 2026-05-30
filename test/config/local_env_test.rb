require "test_helper"
require "tempfile"

class LocalEnvTest < ActiveSupport::TestCase
  test "loads env file values without overriding existing env" do
    file = Tempfile.new("local-env")
    file.write(<<~ENV_FILE)
      LOCAL_ENV_TEST_KEY=from_file
      export LOCAL_ENV_TEST_QUOTED="quoted value"
      LOCAL_ENV_TEST_EXISTING=from_file
      LOCAL_ENV_TEST_COMMENTED=value # comment
    ENV_FILE
    file.close

    ENV["LOCAL_ENV_TEST_EXISTING"] = "from_process"

    LocalEnv.load(file.path)

    assert_equal "from_file", ENV["LOCAL_ENV_TEST_KEY"]
    assert_equal "quoted value", ENV["LOCAL_ENV_TEST_QUOTED"]
    assert_equal "from_process", ENV["LOCAL_ENV_TEST_EXISTING"]
    assert_equal "value", ENV["LOCAL_ENV_TEST_COMMENTED"]
  ensure
    ENV.delete("LOCAL_ENV_TEST_KEY")
    ENV.delete("LOCAL_ENV_TEST_QUOTED")
    ENV.delete("LOCAL_ENV_TEST_EXISTING")
    ENV.delete("LOCAL_ENV_TEST_COMMENTED")
    file&.unlink
  end
end
