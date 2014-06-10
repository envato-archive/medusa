class TestDriver
  def accept?(file)
    true
  end

  def execute(file, reporter)
    reporter.report("Started")
  end
end
