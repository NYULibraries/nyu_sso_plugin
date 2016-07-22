require 'sinatra/base'
require 'omniauth-oauth2'
require_relative 'lib/ssoauth_helper'
require "yaml"

include SsoauthHelper

AppConfig[:heira_path]="/etc/puppet/hieradata/common.yaml"

sso_url="aspace-stage.dlts.org"
frontend_port="8480"
AppConfig[:ap_id]="3cc3e7e396c1d431424fce3469f282058d2fbc035d5961eead87992a96eee90e"
AppConfig[:auth_key]="key"


if File.exists?(AppConfig[:heira_path])

  heira_hash=YAML::load_file(AppConfig[:heira_path])

  heira_hash.each do |key,value|
    sso_url=value if key.include? "sso_url"
    frontend_port=value if key.include? "frontend_port"
    AppConfig[:ap_id]=value if key.include? "ap_id"
    AppConfig[:auth_key]=value if key.include? "auth_key"
  end

end

AppConfig[:sso_url]=sso_url

frontend_port.empty? ? AppConfig[:frontend_sso_url]= "https://#{sso_url}":AppConfig[:frontend_sso_url]= "https://#{sso_url}:#{frontend_port}"

class ArchivesSpaceService < Sinatra::Base
  use Rack::Session::Cookie, :key => 'rack.session',
      :expire_after => 2592000, # In seconds
      :secret => 'archivesspace remote SSO session'

  use OmniAuth::Builder do
    provider :'nyulibraries', AppConfig[:ap_id], AppConfig[:auth_key]
  end

end

