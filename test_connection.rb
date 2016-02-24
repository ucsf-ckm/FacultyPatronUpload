require 'rubygems'
require 'net/ldap'
require 'yaml'

properties = YAML::load(File.open('properties.yml'))

ldap = Net::LDAP.new    :host => properties["host"],
                        :port => properties["port"],
                        :encryption => :simple_tls,
                        :base => properties["base"],
                        :auth => {
                            :method => :simple,
                            :username => properties["username"],
                            :password => properties["password"]
                        }
if ldap.bind
    puts "Connection successful!  Code:  #{ldap.get_operation_result.code}, message: #{ldap.get_operation_result.message}"
else
    puts "Connection failed!  Code:  #{ldap.get_operation_result.code}, message: #{ldap.get_operation_result.message}"
end