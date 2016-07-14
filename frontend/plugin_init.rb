require "net/http"
require "uri"
require "yaml"

my_routes = [File.join(File.dirname(__FILE__), "routes.rb")]
ArchivesSpace::Application.config.paths['config/routes'].concat(my_routes)

AppConfig[:heira_path]="/etc/puppet/hieradata/common.yaml"

sso_url="aspace-stage.dlts.org"
backend_port="8489"


 if File.exists?(AppConfig[:heira_path])

   heira_hash=YAML::load_file(AppConfig[:heira_path])

   heira_hash.each do |key,value|
        sso_url=value if key.include? "sso_url"
        backend_port=value if key.include? "backend_port"
   end

 end

  AppConfig[:sso_url]=sso_url

  backend_port.empty? ? AppConfig[:backend_sso_url]= "https://#{sso_url}":AppConfig[:backend_sso_url]= "https://#{sso_url}:#{backend_port}"

  AppConfig[:ssologin_url]="#{AppConfig[:backend_sso_url]}/auth/nyulibraries"

  AppConfig[:ssologout_url]="https://login.library.nyu.edu/logged_out"

