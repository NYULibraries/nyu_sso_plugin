require "net/http"
require "uri"
require "yaml"

my_routes = [File.join(File.dirname(__FILE__), "routes.rb")]
ArchivesSpace::Application.config.paths['config/routes'].concat(my_routes)

sso_url="archivesspace-stage.library.nyu.edu"
backend_port="8489"

AppConfig[:heira_path]="/etc/puppet/hieradata/common.yaml"

 if File.exists?(AppConfig[:heira_path])

   heira_hash=YAML::load_file(AppConfig[:heira_path])

   sso_url=heira_hash["archivesspace::sso_url"]
   backend_port=heira_hash["archivesspace::backend_port"]

 end

backend_port.empty? ? AppConfig[:backend_sso_url]= "https://#{sso_url}":AppConfig[:backend_sso_url]= "https://#{sso_url}:#{backend_port}"

AppConfig[:ssologin_url]="#{AppConfig[:backend_sso_url]}/auth/nyulibraries"

AppConfig[:ssologout_url]="https://login.library.nyu.edu/logged_out"


