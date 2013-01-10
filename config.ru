require File.join(File.dirname(__FILE__), 'app')

use Rack::ShowExceptions

run App.new