require "net/http"
require "uri"
require "yaml"

ArchivesSpace::Application.extend_aspace_routes(File.join(File.dirname(__FILE__), "routes.rb"))

sso_url="archivesspace-stage.library.nyu.edu"
sso_backend_port="8489"
sso_login_url="dev.login.library.nyu.edu"

AppConfig[:heira_path]="/etc/puppetlabs/code/environments/development/data/aspace_sso.yaml"

 if File.exists?(AppConfig[:heira_path])

   heira_hash=YAML::load_file(AppConfig[:heira_path])

   sso_url=heira_hash["aspace_sso::acm::sso_url"]
   sso_backend_port=heira_hash["aspace_sso::acm::sso_backend_port"]
   sso_login_url=heira_hash["aspace_sso::acm::sso_login_url"]

 end

sso_backend_port.empty? ? AppConfig[:backend_sso_url]= "https://#{sso_url}":AppConfig[:backend_sso_url]= "https://#{sso_url}:#{sso_backend_port}"

AppConfig[:ssologin_url]="#{AppConfig[:backend_sso_url]}/auth/nyulibraries"

AppConfig[:ssologout_url]="https://#{sso_login_url}/logged_out"


