class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    us: { writing: :primary_shard_us, reading: :primary_shard_us_replica },
    au: { writing: :primary_shard_au, reading: :primary_shard_au_replica },
  }
end
