# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
AsakusaSatellite::Application.config.secret_token = ENV['SECRET_TOKEN'] || '757e1ab289018387107b419f801bccc94017432f61542e0a3ef9a29d3a968670fb122e77150ddb079ab159c65d6710a3b54a2392b4f46a2ff9323bd3eb761fa7'
