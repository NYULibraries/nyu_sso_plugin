require 'sinatra/base'
require 'omniauth-oauth2'
require_relative 'lib/ssoauth_helper'

include SsoauthHelper

AppConfig[:heira_path]="/etc/puppet/hieradata/common.yaml"

sso_url="aspace-stage.dlts.org"
frontend_port="8480"
AppConfig[:ap_id]=""
AppConfig[:auth_key]="key"


if File.exists?(AppConfig[:heira_path])

  heira_hash=YAML::load(AppConfig[:heira_path])

  heira_hash.each do |key,value|
    sso_url=value if key.includes? "auth_key"
    frontend_port=value if key.includes? "frontend_port"
    AppConfig[:ap_id]=value if key.includes? "ap_id"
    AppConfig[:auth_key]=value if key.includes? "auth_key"
  end

end

AppConfig[:sso_url]=sso_url

frontend_port.empty? ? AppConfig[:frontend_sso_url]= "https://#{sso_url}:#{frontend_port}":AppConfig[:frontend_sso_url]= "https://#{sso_url}"

 class ArchivesSpaceService < Sinatra::Base
   use Rack::Session::Cookie, :key => 'rack.session',
       :expire_after => 2592000, # In seconds
       :secret => 'archivesspace remote SSO session'

   use OmniAuth::Builder do
    provider :'nyulibraries', AppConfig[:ap_id], AppConfig[:auth_key]
   end

  end

