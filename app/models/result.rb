class Result
  attr_accessor :results
  attr_accessor :columns

  def get(param)
    index = columns.find_index(param)
    results.map{|x| x[index]}
  end
end