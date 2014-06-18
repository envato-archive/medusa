class TestListener
  attr_reader :results

  def initialize
    @results = []
  end

  def report_work_result(result)
    @results << [:work_result, result.name, result.success?, result]
  end

  def report_work_complete(file)
    @results << [:file_complete, file]
  end

  def message(string)
    @results << string
  end

  def get_results_by_class(clz)
    @results.select { |r| r.is_a?(clz) }
  end
end

