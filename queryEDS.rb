require 'rubygems'
require 'net/ldap'
require 'marc'
require 'csv'
require 'rest-client'
require 'nokogiri'
require 'set'
require 'open-uri'
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

result_attrs = [
  "objectClass", 
  "eduPersonPrincipalName", 
  "eduPersonPrimaryAffiliation",
  "eduPersonOrgDN",
  "eduPersonAffiliation",
  "street",
  "uid", 
  "ucsfEduStuRegistrationStatusCode",
  "givenName",
  "cn",
  "postalAddress",
  "departmentNumber",
  "UCNetID",
  "Affiliation",
  "ucsfEduStuRegistrationStatusCode",
  "givenName",
  "cn",
  "postalAddress",
  "l", 
  "st",
  "postalCode",
  "telephoneNumber",
  "mail",
  "ucsfEduIDNumber",
  "ucsfEduStuTerm",
  "ucsfEduStuCurriculumCode",
  "ucsfEduStuCurriculumLevelName",
  "title"
  ]
  
search_filter = Net::LDAP::Filter.eq("mail", "John.Fahy@ucsf.edu")
  
  
# Execute search
ldap.search(:filter => search_filter, :attributes => result_attrs, :return_result => false) { |item| 

  # note - some records list 'Campus Address' as last name (with no first name)
  # this is in eds...
  uid = item['uid']
  lastname = item['cn'][0].nil? ? "" : item['cn'][0].split(',')[0]
  firstname = item['givenName'][0].nil? ? "" : item['givenName'][0].split(',')[0] 
  address = item['postalAddress'][0].nil? ? "" : item['postalAddress'][0]
  areacode = item['telephoneNumber'][0].nil? ? "" : item['telephoneNumber'][0].split(' ')[1]
  areacode = areacode.nil? ? "" : areacode
  phone = item['telephoneNumber'][0].nil? ? "" : item['telephoneNumber'][0].split(' ')[2]
  emailaddr = item['mail'][0].nil? ? "" : item['mail'][0]
  ucid = item['ucsfEduIDNumber'][0].nil? ? "" :  item['ucsfEduIDNumber'][0]
  eduPersonPrimaryAffiliation = item['eduPersonPrimaryAffiliation'][0].nil? ? "" : item['eduPersonPrimaryAffiliation'][0]
  title = item['title'][0].nil? ? "" : item['title'][0]
  title = title.strip.upcase
  title = title.delete(",")
 
  puts item.inspect
 
  if item['eduPersonAffiliation'].include?('faculty')
    puts item['eduPersonAffiliation']
  end
  
}
  