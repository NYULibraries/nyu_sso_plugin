require_relative '../../../../backend/app/lib/auth_helpers'
include AuthHelpers

describe 'Authentication callback' do
  let(:user) { create(:user, :username=>'test_sso')}
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:nyulibraries, {"provider"=>:nyu_shibboleth,
                                             "uid"=>"name",
                                             "info"=>
                                                 {"name"=>"name",
                                                  "nickname"=>"name",
                                                  "email"=>"test_sso@site.com"},
                                             "credentials"=>
                                                 {"token"=>"token",
                                                  "expires_at"=>1111111111,
                                                  "expires"=>true},
                                             "extra"=>
                                                 {"provider"=>:nyulibraries,
                                                  "identities"=>nil},})
    get 'auth/doorkeeper/callback'
  end
  context 'when login was successful' do
    it 'should redirect to the frontend login_sso method after login' do
    expect(last_response.redirect?).to be true
    follow_redirect!
    expect(Session.find(last_request.params['session'])[:user]).to eq('test_sso')
    expect(last_request.path).to eq('/login_sso')
    end
  end
    context 'when user does not exist' do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.add_mock(:nyulibraries, {"provider"=>:nyu_shibboleth,
                                                 "uid"=>"name",
                                                 "info"=>
                                                     {"name"=>"name",
                                                      "nickname"=>"name",
                                                      "email"=>"test1@site.com"},
                                                 "credentials"=>
                                                     {"token"=>"token",
                                                      "expires_at"=>1111111111,
                                                      "expires"=>true},
                                                 "extra"=>
                                                     {"provider"=>:nyulibraries,
                                                      "identities"=>nil},})
        get 'auth/doorkeeper/callback'
      end
      it 'should be created' do
        expect(User.find(:username=>'test1')).not_to be nil
      end
    end
  context 'when user logins not through nyu_shibboleth' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:nyulibraries, {"provider"=>:nyulibraries,
                                               "uid"=>"name",
                                               "info"=>
                                                   {"name"=>"name",
                                                    "nickname"=>"name",
                                                    "email"=>"email@site.com"},
                                               "credentials"=>
                                                   {"token"=>"token",
                                                    "expires_at"=>1111111111,
                                                    "expires"=>true},
                                               "extra"=>
                                                   {"provider"=>:nyulibraries,
                                                    "identities"=>nil},})
      get 'auth/doorkeeper/callback'
    end
    it 'should send error message' do
      follow_redirect!
      expect(last_request.params['error']).to eq('failed')
  end
  end
  end

describe 'Session verification' do
  let(:user) { create(:user, :username=>"test1")}
  let(:username) { user.username }
  let(:another_user) { create(:user, :username=>"test2")}
  before do
     post "/users/#{username}/#{session_id}/verify"
  end
  context 'when session was created for the user in the backend' do
  let(:session) { create_session_for("test1",true) }
  let(:session_id) { session.id }
  it 'should return session_id and user json object'do
    expect(last_response.body).to include("\"session\":\"#{session.id}\"")
    expect(last_response.body).to include("\"username\":\"test1\"")
  end
  end
  context 'when session was created for a different user' do
  let(:session) { AuthHelpers::create_session_for("test2",true) }
  let(:session_id) { session.id }
  it 'should return login failed' do
    expect(last_response.body).to include("\"error\":\"Login Failed\"")
  end
  end
  context 'when session does not exists' do
  let(:session_id) { 'fake_id' }
  it 'should return login failed' do
    expect(last_response.body).to include("\"error\":\"Login Failed\"")
  end
  end
  context 'when user does not exists' do
  let(:session) { create_session_for("test1",true) }
  let(:session_id) { session.id }
  let(:username) { "fake_user" }
  it 'should return login failed' do
    expect(last_response.body).to include("\"error\":\"Login Failed\"")
  end
  end
end

