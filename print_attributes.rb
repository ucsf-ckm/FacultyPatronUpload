require 'rubygems'
require 'net/ldap'
require 'yaml'
require 'set'

properties = YAML::load(File.open('./properties.yml'))

ldap = Net::LDAP.new    :host => properties["host"],
                        :port => properties["port"],
                        :encryption => :simple_tls,
                        :base => properties["base"],
                        :auth => {
                            :method => :simple,
                            :username => properties["username"],
                            :password => properties["password"]
                        }
                        
result_attrs = [
  "eduPersonPrimaryAffiliation",
  "eduPersonAffiliation",
  "title"
]

search_filter = ~ Net::LDAP::Filter.eq("eduPersonPrimaryAffiliation", "student")

roles = Set.new
roles2 = Set.new
titles = Set.new

# Execute search
ldap.search(:filter => search_filter, :attributes => result_attrs, :return_result => false) { |item| 
    roles.add(item['eduPersonPrimaryAffiliation'])
    
    item['eduPersonAffiliation'].each do |affiliation|
      roles2.add(affiliation)
    end
    
    item['title'].each do |title|
      titles.add(title)
    end
}

puts roles.inspect
puts roles2.inspect

titles.each do |title|
  puts title
end

if ldap.bind
    puts "Connection successful!  Code:  #{ldap.get_operation_result.code}, message: #{ldap.get_operation_result.message}"
else
    puts "Connection failed!  Code:  #{ldap.get_operation_result.code}, message: #{ldap.get_operation_result.message}"
end