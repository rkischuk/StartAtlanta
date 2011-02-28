MongoMapper.connection = Mongo::Connection.new('209.20.80.96', 27017) #, :logger => Rails.logger)
MongoMapper.database = "connectme-#{Rails.env}"

User.ensure_index(:fb_id)

if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect if forked
   end
end
