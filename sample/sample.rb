class SampleController < ApplicationController
    def action
        api_key = "5875231" # Replace with your OpenTok API key.
        api_secret = "8f5cde4ade6b11ea22cfd73ea345c64b4e423d29"  # Replace with your OpenTok API secret.

        opentok = OpenTok::OpenTokSDK.new api_key, api_secret
        session = opentok.create_session request.remote_addr

        token = opentok.generate_token :session_id => session, :role => OpenTok::RoleConstants.PUBLISHER, :connection_data => "username=Bob, level=4"
        
        puts session.session_id
        puts token
    end
end