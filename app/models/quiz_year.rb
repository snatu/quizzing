class QuizYear #refers to academic bible quizzing year
  def initialize(start_year=nil,end_year=nil)
    if start_year.nil? && end_year.nil? 
      find_default_dates 
    else
      end_year ||= start_year + 1
      @start_date = Date.new(start_year,8,1)
      @end_date   = Date.new(end_year,7,31)
    end
  end
  
  attr_reader :start_date, :end_date
  
  def include?(date)
    #.cover faster is faster than .include
    (start_date..end_date).cover?(date)
  end

  def span
    "#{start_date.year} - #{end_date.year}"
  end

  def this_yr_events
    # return an array of all events scheduled for this academic bible quizzing year
    Event.all.select {|e| e.start_date >= @start_date && e.start_date <= @end_date}.sort_by{|e| e.start_date && e.end_date}
  end

  def completed_events
    # returns an array of events that essentially have scores associated with them
    Event.all.select {|e| e.start_date >= @start_date && e.start_date <= Date.today}
  end

  def prev_events
    # returns an array of events for previous academic bible quizing years
    Event.all.select {|e| e.start_date <= @start_date && e.end_date <= @end_date}.sort_by{|e| e.start_date && e.end_date}
  end

  private
  def find_default_dates
    year  = Date.today.year
    month = Date.today.month
    if month < 8
      start_year = year - 1
      end_year   = year
    else
      start_year = year
      end_year   = year + 1
    end
    @start_date = Date.new(start_year,8,1)
    @end_date   = Date.new(end_year,7,31)
  end
  
end

