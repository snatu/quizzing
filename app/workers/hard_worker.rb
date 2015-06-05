class HardWorker
  include Sidekiq::Worker

  def perform(area)
  	Rake::Task['db:update_area_standings'].invoke(area)
  end
end