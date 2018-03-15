require 'sinatra/base'
require 'omniauth-oauth2'
require_relative 'lib/ssoauth_helper'
require "yaml"

include SsoauthHelper

AppConfig[:heira_path]="/etc/puppetlabs/code/environments/development/data/profiles.yaml"

sso_url="archivesspace-stage.library.nyu.edu"
sso_frontend_port="8480"
sso_login_url="https://dev.login.library.nyu.edu"
AppConfig[:ap_id]="3cc3e7e396c1d431424fce3469f282058d2fbc035d5961eead87992a96eee90e"
AppConfig[:auth_key]="key"

if File.exists?(AppConfig[:heira_path])

  heira_hash=YAML::load_file(AppConfig[:heira_path])

  sso_url=heira_hash["profiles::acm::sso_url"]
  sso_frontend_port=heira_hash["profiles::acm::sso_frontend_port"]
  sso_login_url=heira_hash["profiles::acm::sso_login_url"]
  AppConfig[:ap_id]=heira_hash["profiles::acm::ap_id"]
  AppConfig[:auth_key]=heira_hash["profiles::acm::auth_key"]

end

sso_frontend_port.empty? ? AppConfig[:frontend_sso_url]= "https://#{sso_url}":AppConfig[:frontend_sso_url]= "https://#{sso_url}:#{sso_frontend_port}"

class ArchivesSpaceService < Sinatra::Base
  use Rack::Session::Cookie, :key => 'rack.session',
      :expire_after => 2592000, # In seconds
      :secret => 'archivesspace remote SSO session'

  use OmniAuth::Builder do
    provider :nyulibraries, AppConfig[:ap_id], AppConfig[:auth_key],
    client_options: {
            site: '"#{sso_login_url}"',
            authorize_path: '/oauth/authorize'
    }
  end

end

