# Facebase configuration
Facebase.configure do |config|

  # tracking_host: (Required)
  # The hostname and port (if necessary) of the server Facebase
  # will make requests to for email tracking. DON'T PREFIX PROTOCOL
  config.tracker_host = "myapp.herokuapp.com"

  # tracker_fall_back_site: (Optional) (Recommended)
  # When a error occurs during link or unsubscribe tracking the user is redirected
  # here instead. Great for ensuring that when a bad link is written in a email
  # you at least get some relevant page. 404, homepage, whatever
  # config.tracker_fall_back_site = "http://yoursite.com"

  # aws_access_key_id: (Required)
  # aws_secret_access_key:(Required)
  # aws_campaign_bucket:(Required)
  # We use aws to store the templates for the emails. Authentication and bucket
  # name are required
  config.aws_access_key_id = "YOUR ACCESS KEY"
  config.aws_secret_access_key = "YOUR SECRET ACCESS KEY"
  config.aws_campaign_bucket = "campaigns-yourco-com"

  # mixpanel_token: (Optional)
  # Mixpanel tracking can be enabled for clicks, opens and unsubscribes if a
  # valid mixpanel token is provided
  # config.mixpanel_token = "optional mixpanel token for tracking"

  # litmus_static_email: (optional)
  # Provides email testing via litmus. If provided we can send test emails
  # to litmus for cross browser testing.
  config.litmus_static_email = "something@litmus.com"

  # redis_lock_uri: (Required)
  # Redis is used to provide fast locks across our principle sharded model
  # this is required to prevent duplicate rows in normal operation
  config.redis_lock_uri = "redis://user:pass@host.com:port/db_num"


  # redis_resque_uri: (Required)
  # Redis uri for the resque. It may be on the same host as the redis lock
  # but should probably be on a different database(specify at end)
  config.redis_resque_uri = "redis://user:pass@host.com:port/db_num"

  # redis_index_store: (Optional)
  # Redis can also be used as a index for the principle model which is
  # especially useful for large imports of data or very write insensive
  # applications on the principle model. You will need approximately
  # 1GB of ram for every 10M records of profile data (global count = 10M)
  #
  # config.redis_index_uri = "redis://user:pass@host.com:port/db_num"

  # unsubscribe_url: (Optional)
  # When a user clicks unsubscribe in a email they will then be forwarded
  # to this page. If the email address is known it will be passed as a uri param
  # If not present a default text page will simply say you have been unsubscribed
  #
  # config.unsubscribe_url = "http://somehost/somepath/unsub"

  # config_database_uri (Optional)
  # If using facebase in a centralized manner this will be the database that
  # the shard configuration, esp, etc settings are hosted at. If blank the
  # default is to use the current database connection from the rails app.
  # Expects a SQL server (tested on mysql)
  #
  # config.config_database_uri = "mysql2://user:pass@host:port/somedb"

end
