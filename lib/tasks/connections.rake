namespace :connections do
  desc 'Delete all pending connections that are older than 7 days.'
  task clean_up: :environment do
    Connection
      .pending
      .where(created_at: ...7.days.ago)
      .destroy_all
  end
end
