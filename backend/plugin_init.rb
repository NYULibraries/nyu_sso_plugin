require 'sinatra/base'
require 'omniauth-oauth2'
require_relative 'lib/ssoauth_helper'

include SsoauthHelper

 class ArchivesSpaceService < Sinatra::Base
   use Rack::Session::Cookie, :key => 'rack.session',
       :expire_after => 2592000, # In seconds
       :secret => 'archivesspace remote SSO session'

   use OmniAuth::Builder do
    provider :'nyulibraries','e053a72f8a61de4b401b002be59252076aaf88bb79aef99ca22b31d910eccbae','key'
   end

  end

