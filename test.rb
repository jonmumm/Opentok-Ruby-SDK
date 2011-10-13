require "test/unit"
require "net/http"
require "lib/open_tok"

class TestRubySDK < Test::Unit::TestCase

    def setup
        @api_key = 4317
        @api_secret = "91e6f7609074be23b40747a4651ba5a7"
        @o = OpenTok::OpenTokSDK.new @api_key, @api_secret
        @api_url = OpenTok::API_URL
    end

    def test_create_session
        assert_nothing_raised(OpenTok::OpenTokException) {
            s = @o.create_session
            assert_not_nil s.session_id, "Ruby SDK tests: create session (no params): did not return a session id"
            xml = get_session_info(s.session_id)
            assert_equal s.session_id, xml.root.get_elements('Session')[0].get_elements('session_id')[0].children[0].to_s, \
                "Ruby SDK tests: Session id not found"

            s = @o.create_session '216.38.134.114'
            assert_not_nil s.session_id, "Ruby SDK tests: create session (no params): did not return a session id"
            xml = get_session_info(s.session_id)
            assert_equal s.session_id, xml.root.get_elements('Session')[0].get_elements('session_id')[0].children[0].to_s, \
                "Ruby SDK tests: Session id not found"

        }
    end

    def test_num_output_streams
        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::MULTIPLEXER_NUMOUTPUTSTREAMS  => 0
        xml = get_session_info s.session_id
        assert_equal '0', xml.root.elements['Session/properties/multiplexer/numOutputStreams'][0].to_s, \
            'Ruby SDK tests: multiplexer.numOutputStreams not set to 0'

        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::MULTIPLEXER_NUMOUTPUTSTREAMS => 1
        xml = get_session_info s.session_id
        assert_equal '1', xml.root.elements['Session/properties/multiplexer/numOutputStreams'][0].to_s, \
            'Ruby SDK tests: multiplexer.numOutputStreams not set to 1'

        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::MULTIPLEXER_NUMOUTPUTSTREAMS => 5
        xml = get_session_info s.session_id
        assert_equal '5', xml.root.elements['Session/properties/multiplexer/numOutputStreams'][0].to_s, \
            'Ruby SDK tests: multiplexer.numOutputStreams not set to 5'

        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::MULTIPLEXER_NUMOUTPUTSTREAMS => 100
        xml = get_session_info s.session_id
        assert_equal '100', xml.root.elements['Session/properties/multiplexer/numOutputStreams'][0].to_s, \
            'Ruby SDK tests: multiplexer.numOutputStreams not set to 100'

        s = @o.create_session
        xml = get_session_info s.session_id
        assert_nil xml.root.elements['Session/properties/multiplexer/numOutputStreams'], \
            'Ruby SDK tests: multiplexer.numOutputStreams should not be set'
    end

    def test_switch_type
        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::MULTIPLEXER_SWITCHTYPE => 0
        xml = get_session_info s.session_id
        assert_equal '0', xml.root.elements['Session/properties/multiplexer/switchType'][0].to_s, \
            'Ruby SDK tests: multiplexer.switchType not 0'

        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::MULTIPLEXER_SWITCHTYPE => 1
        xml = get_session_info s.session_id
        assert_equal '1', xml.root.elements['Session/properties/multiplexer/switchType'][0].to_s, \
            'Ruby SDK tests: multiplexer.switchType not 1'

        s = @o.create_session
        xml = get_session_info s.session_id
        assert_nil xml.root.elements['Session/properties/multiplexer/switchType'], \
            'Ruby SDK tests: multiplexer.numOutputStreams should not be set'
    end

    def test_switch_timeout
        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::MULTIPLEXER_SWITCHTYPE => 1200
        xml = get_session_info s.session_id
        assert_equal '1200', xml.root.elements['Session/properties/multiplexer/switchType'][0].to_s, \
            'Ruby SDK tests: multiplexer.switchType not properly set (should be 1200)'

        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::MULTIPLEXER_SWITCHTYPE => 2000
        xml = get_session_info s.session_id
        assert_equal '2000', xml.root.elements['Session/properties/multiplexer/switchType'][0].to_s, \
            'Ruby SDK tests: multiplexer.switchType not properly set (should be 2000)'

        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::MULTIPLEXER_SWITCHTYPE => 100000
        xml = get_session_info s.session_id
        assert_equal '100000', xml.root.elements['Session/properties/multiplexer/switchType'][0].to_s, \
            'Ruby SDK tests: multiplexer.switchType not properly set (should be 100000)'
    end

    def test_p2p_preference
        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::P2P_PREFERENCE => 'enable'
        xml = get_session_info s.session_id
        assert_equal 'enable', xml.root.elements['Session/properties/p2p/preference'][0].to_s, \
            'Ruby SDK tests: multiplexer.p2p_preference not enabled'

        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::P2P_PREFERENCE => 'disable'
        xml = get_session_info s.session_id
        assert_equal 'disable', xml.root.elements['Session/properties/p2p/preference'][0].to_s, \
            'Ruby SDK tests: multiplexer.p2p_preference not disabled'
    end
    
    def test_echo_suppression
        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::ECHOSUPPRESSION_ENABLED => 'true'
        xml = get_session_info s.session_id
        assert_equal 'True', xml.root.elements['Session/properties/echoSuppression/enabled'][0].to_s, \
            'Ruby SDK tests: echo suppression not showing enabled'

        s = @o.create_session '127.0.0.1', properties = OpenTok::SessionPropertyConstants::ECHOSUPPRESSION_ENABLED => 'false'
        xml = get_session_info s.session_id
        assert_equal 'False', xml.root.elements['Session/properties/echoSuppression/enabled'][0].to_s, \
            'Ruby SDK tests: echo suppression not showing disabled'
    end

    def test_roles
        s = @o.create_session

        # default: publisher
        t = @o.generate_token :session_id => s.session_id
        xml = get_token_info t
        role = xml.root.elements['token/role'].children[0].to_s
        role.strip!
        assert_equal 'publisher', role, 'Ruby SDK tests: default role not publisher'
        assert_not_nil xml.root.elements['token/permissions/subscribe'], \
            'Ruby SDK tests: token default permissions should include subscribe'
        assert_not_nil xml.root.elements['token/permissions/publish'], \
            'Ruby SDK tests: token default permissions should include publish'
        assert_not_nil xml.root.elements['token/permissions/signal'], \
            'Ruby SDK tests: token default permissions should include signal'
        assert_nil xml.root.elements['token/permissions/forceunpublish'], \
            'Ruby SDK tests: token default permissions should include forceunpublish'
        assert_nil xml.root.elements['token/permissions/forcedisconnect'], \
            'Ruby SDK tests: token default permissions should include forcedisconnect'
        assert_nil xml.root.elements['token/permissions/record'], \
            'Ruby SDK tests: token default permissions should include record'
        assert_nil xml.root.elements['token/permissions/playback'], \
            'Ruby SDK tests: token default permissions should include playback'

        # publisher
        t = @o.generate_token :session_id => s.session_id, :role => 'publisher'
        xml = get_token_info t
        role = xml.root.elements['token/role'].children[0].to_s
        role.strip!
        assert_equal 'publisher', role, 'Ruby SDK tests: role not publisher'
        assert_not_nil xml.root.elements['token/permissions/subscribe'], \
            'Ruby SDK tests: token publisher permissions should include subscribe'
        assert_not_nil xml.root.elements['token/permissions/publish'], \
            'Ruby SDK tests: token publisher permissions should include publish'
        assert_not_nil xml.root.elements['token/permissions/signal'], \
            'Ruby SDK tests: token publisher permissions should include signal'
        assert_nil xml.root.elements['token/permissions/forceunpublish'], \
            'Ruby SDK tests: token publisher permissions should not include forceunpublish'
        assert_nil xml.root.elements['token/permissions/forcedisconnect'], \
            'Ruby SDK tests: token publisher permissions should not include forcedisconnect'
        assert_nil xml.root.elements['token/permissions/record'], \
            'Ruby SDK tests: token publisher permissions should not include record'
        assert_nil xml.root.elements['token/permissions/playback'], \
            'Ruby SDK tests: token publisher permissions should not include playback'

        # moderator
        t = @o.generate_token :session_id => s.session_id, :role => 'moderator'
        xml = get_token_info t
        role = xml.root.elements['token/role'].children[0].to_s
        role.strip!
        assert_equal 'moderator', role, 'Ruby SDK tests: role not moderator'
        assert_not_nil xml.root.elements['token/permissions/subscribe'], \
            'Ruby SDK tests: token moderator permissions should include subscribe'
        assert_not_nil xml.root.elements['token/permissions/publish'], \
            'Ruby SDK tests: token moderator permissions should include publish'
        assert_not_nil xml.root.elements['token/permissions/signal'], \
            'Ruby SDK tests: token moderator permissions should include signal'
        assert_not_nil xml.root.elements['token/permissions/forceunpublish'], \
            'Ruby SDK tests: token moderator permissions should include forceunpublish'
        assert_not_nil xml.root.elements['token/permissions/forcedisconnect'], \
            'Ruby SDK tests: token moderator permissions should include forcedisconnect'
        assert_not_nil xml.root.elements['token/permissions/record'], \
            'Ruby SDK tests: token moderator permissions should include record'
        assert_not_nil xml.root.elements['token/permissions/playback'], \
            'Ruby SDK tests: token moderator permissions should include playback'

        # subscriber
        t = @o.generate_token :session_id => s.session_id, :role => 'subscriber'
        xml = get_token_info t
        role = xml.root.elements['token/role'].children[0].to_s
        role.strip!
        assert_equal 'subscriber', role, 'Ruby SDK tests: role not subscriber'
        assert_not_nil xml.root.elements['token/permissions/subscribe'], \
            'Ruby SDK tests: token subscriber permissions should include subscribe'
        assert_nil xml.root.elements['token/permissions/publish'], \
            'Ruby SDK tests: token subscriber permissions should not include publish'
        assert_nil xml.root.elements['token/permissions/signal'], \
            'Ruby SDK tests: token subscriber permissions should not include signal'
        assert_nil xml.root.elements['token/permissions/forceunpublish'], \
            'Ruby SDK tests: token subscriber permissions should not include forceunpublish'
        assert_nil xml.root.elements['token/permissions/forcedisconnect'], \
            'Ruby SDK tests: token subscriber permissions should not include forcedisconnect'
        assert_nil xml.root.elements['token/permissions/record'], \
            'Ruby SDK tests: token subscriber permissions should not include record'
        assert_nil xml.root.elements['token/permissions/playback'], \
            'Ruby SDK tests: token subscriber permissions should not include playback'

        # garbage data
        assert_raise(OpenTok::OpenTokException, 'Ruby SDK tests: invalid role should be rejected') {
            t = @o.generate_token :session_id => s.session_id, :role => 'ads'
        }
    end

    def test_old_session
        s_id = '1abc70a34d069d2e6a1e565f3958b5250b435e32'
        t = @o.generate_token :session_id => s_id
        xml = get_token_info t
        assert_equal s_id, xml.root.elements['token/session_id'].children[0].to_s, \
            'Ruby SDK test: creating token with old session id failed'
    end

    def test_expire_time
        s = @o.create_session

        # past
        time = Time.now.to_i - 1000
        assert_raise(OpenTok::OpenTokException, 'Ruby SDK tests: expire time in past should be rejected') {
            t = @o.generate_token :session_id => s.session_id, :expire_time => time
        }

        # now
        time = Time.now.to_i
        t = @o.generate_token :session_id => s.session_id, :expire_time => time
        xml = get_token_info t
        assert_equal time.to_s, xml.root.elements['token/expire_time'].children[0].to_s,\
            'Ruby SDK tests: expire time not set'

        # near future
        time = Time.now.to_i + 6 * 24 * 60 * 60
        t = @o.generate_token :session_id => s.session_id, :expire_time => time
        xml = get_token_info t
        assert_equal time.to_s, xml.root.elements['token/expire_time'].children[0].to_s,\
            'Ruby SDK tests: expire time not set'

        # far future
        time = Time.now.to_i + 8 * 24 * 60 * 60
        assert_raise(OpenTok::OpenTokException, 'Ruby SDK tests: expire time more than 7 days away should be rejected') {
            t = @o.generate_token :session_id => s.session_id, :expire_time => time
        }

        # garbage data
        assert_raise(OpenTok::OpenTokException, 'Ruby SDK tests: expire time more than 7 days away should be rejected') {
            t = @o.generate_token :session_id => s.session_id, :expire_time => "asdfasdf"
        }
    end

    def test_connection_data
        s = @o.create_session

        test_string = 'test data'
        t = @o.generate_token :session_id => s.session_id, :connection_data => test_string
        xml = get_token_info t
        assert_equal test_string, xml.root.elements['token/connection_data'].children[0].to_s, \
            'Ruby SDK tests: connection data not correct'

        # Should reject over 1000 characters of connection data
        test_string = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' +
            'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc' +
            'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd' +
            'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' +
            'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' +
            'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' +
            'gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg' +
            'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh' +
            'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii' +
            'jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj' +
            'kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk' +
            'llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll' +
            'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm' +
            'nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn' +
            'oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo'
        assert_raise(OpenTok::OpenTokException, 'Ruby SDK tests: long connection data should be rejected') {
            t = @o.generate_token :session_id => s.session_id, :connection_data => test_string
        }
    end

    def get_session_info(session_id, token = 'devtoken')
        url = URI.parse @api_url + '/session/' + session_id
        headers = { 'X-TB-TOKEN-AUTH' => token }

        http = Net::HTTP.new url.host, url.port
        res = http.get url.path + '?extended=true', headers

        assert_equal '200', res.code, 'Ruby SDK tests: failed to find session'

        return REXML::Document.new res.read_body
    end

    def get_token_info(token)
        url = URI.parse @api_url + '/token/validate'
        headers = { 'X-TB-TOKEN-AUTH' => token }

        http = Net::HTTP.new url.host, url.port
        res = http.get url.path, headers

        assert_equal '200', res.code, 'Ruby SDK tests: failed to retrieve token'

        return REXML::Document.new res.read_body
    end
end
