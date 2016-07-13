require "net/http"
require "uri"

my_routes = [File.join(File.dirname(__FILE__), "routes.rb")]
ArchivesSpace::Application.config.paths['config/routes'].concat(my_routes)

AppConfig[:ssologin_url]="http://aspace-prod.dlts.org/auth/nyulibraries"

AppConfig[:ssologout_url]="https://login.library.nyu.edu/logged_out"

AppConfig[:frontend_host_url]="https://aspace-stage.dlts.org:8480"
