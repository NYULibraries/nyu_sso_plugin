require "net/http"
require "uri"
require "sinatra/base"
require 'aspace_logger'
require_relative '../lib/ssoauth_helper'

class ArchivesSpaceService < Sinatra::Base
  include BCrypt
  include JSONModel
  include SsoauthHelper

  Endpoint.get('/auth/nyulibraries/callback')
      .description("Omniauth NYULibraries Callback")
      .permissions([])
      .returns() \
  do

    auth = request.env['omniauth.auth']

    if auth.nil? || !auth.valid? || auth[:provider]!="nyu_shibboleth"
      redirect("#{AppConfig[:frontend_url]}/login_sso?error=failed")
    end

    username=auth.uid
    auth_token=auth.credentials.token

    user = User.find(:username => username)

    if user.nil?
      user=create_user_from_omniauth(username)
    end

    add_user_to_auth_db(username, auth_token)

    session = create_session_for(username, params[:expiring])
    session[:state]= auth_token
    redirect "#{AppConfig[:frontend_url]}/login_sso?session=#{session.id}&user=#{username}"
  end

  Endpoint.post('/users/:username/:session_id/verify')
      .description("Verify Session")
      .params(["username", Username, "Your username"],
              ["session_id", String, "Your session_id"])
      .permissions([])
      .returns([200, "Login accepted"],
               [403, "Login failed"]) \
  do
    username ||= params[:username]

    session_id ||= params[:session_id]

    user||=User.find(:username => username)

    session ||= Session.find(session_id)

    if (!session.nil?&&session[:user]==username)
      json_user = User.to_jsonmodel(user)
      json_user.permissions = user.permissions
      json_response({:session => session.id, :user => json_user})
    else
      json_response({:error => "Login Failed"}, 403)
    end

  end

end