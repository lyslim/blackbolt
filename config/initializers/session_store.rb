# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_task_session',
  :secret      => 'd8b7094545b9216c42537508174d3e9c0efc55621c12e692fddb5af64e9620d46d511e86a671c4c9ca323c3d5bf5c022046b6ec0ccfa0832b5050517677fb306'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
