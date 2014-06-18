class TestReporter
  attr_reader :results

  def initialize
    @results = []
  end

  def report(information)
    @results << information
  end

  def get_results_by_class(clz)
    @results.select { |r| r.is_a?(clz) }
  end
end

