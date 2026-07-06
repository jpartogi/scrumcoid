class PruneUniqueVisitsJob < ApplicationJob
  queue_as :default

  # Prunes old unique visit records. retention_days controls how much history we keep
  # for the dashboard stats (default keeps ~3 months).
  def perform(retention_days: 90)
    UniqueVisit.prune_old!(retention_days: retention_days)
    PageView.prune_old!(retention_days: retention_days)
    TrafficPageView.prune_old!(retention_days: retention_days)
  end
end
