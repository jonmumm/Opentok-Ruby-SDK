require 'lib/opentok'

api_key = 0
api_secret = ""
o = OpenTok::OpenTokSDK.new api_key, api_secret
o.api_url = 'https://staging.opentok.com/hl'
print o.create_session '127.0.0.1'

