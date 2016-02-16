require 'rubygems'
require 'net/ldap'
require 'marc'
require 'csv'
require 'rest-client'
require 'nokogiri'
require 'set'
require "open-uri"
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
  "postalAddress",
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

@errors = Array.new
@missing = Set.new

pstat_title = Hash.new
# create a hash of school codes
File.readlines("pstat_titles.txt").each do |t|
  t = t.split(",")
  pstat_title[t[0].strip.upcase] = t[1]
end

barcode_nums = Hash.new
# create a hash of uid to barcode
open(properties["barcode_url"]) do |f|
  f.each_line do |line| 
    barcode_nums[line.split(",")[0]] = line.split(",")[2]
  end
end

marcwriter = MARC::Writer.new('out.dat')

search_filter = ~ Net::LDAP::Filter.eq("eduPersonPrimaryAffiliation", "student")

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
  
  suffix = ''
  
  #puts ucid
  #puts lastname
  #puts "barcode"
  #puts ucid
  #puts barcode_nums[ucid]
  
  # filtering out students, which are handled through a different upload process
  if (eduPersonPrimaryAffiliation != "student")
  
    if areacode.length == 0
      areacode = '415'
    end

    # Put parentheses around areacode if and only if the areacode exists.
    if !areacode.nil?
      areacode = '(' + areacode + ')'
    end

    # Put a dash (back) in the phone number.
    if !phone.nil? && !phone.eql?('') && phone.length == 7
      phone = phone.insert(3, '-')
    end

    # Prepend a space to suffix if there's a suffix.
    if !suffix.nil? && !suffix.length == 0
      suffix = ' ' + suffix
    end

    # Prepare new MARC record for each student
    record = MARC::Record.new()
    
    #based on title...
    pstatcode = ""   
        
    if pstat_title[title].nil?
      pstatcode = nil
    else
      pstatcode = pstat_title[title]
    end         
    
    if pstatcode.nil?
        @missing.add("Could not figure pstat title for #{title}")
       	@errors <<  "Could not figure pstat title #{title} for #{item.inspect}, setting to 50" 
       	pstatcode = "50"
      next
    end
      
    record.append(MARC::DataField.new('083',' ',' ',['a', pstatcode]))
        
    # expiration date
    # based on title code and pstat
    # visiting grad and undergrad is same as regular students
    # 9/17/(one year from current year)
    # pstat 10-14 get 12/31/(5 years from current year)
    # all other pstat get one year from end of current month

    year = Time.new.year.to_s[2..-1].to_i
    month = Time.new.month.to_s

    # visiting undergraduates and graduates have a pstat of 4
    if pstatcode.to_i == 4
      expyear = year + 1
      record.append(MARC::DataField.new('078',' ', ' ',['a', '09-17-' + expyear.to_s]))
    elsif (10..14) === pstatcode.to_i
      expyear = year + 5
      record.append(MARC::DataField.new('078',' ', ' ',['a', '12-31-' + expyear.to_s]))
    else
      expyear = year + 1
      record.append(MARC::DataField.new('078',' ', ' ',['a', month + '-31-' + expyear.to_s]))
    end

    #no barcode information for now, may add this in later
    record.append(MARC::DataField.new('30',' ',' ',['a', barcode_nums[ucid]]))

    record.append(MARC::DataField.new('100',' ', ' ', ['a', "#{lastname}#{suffix}, #{firstname}"]))

    record.append(MARC::DataField.new('220', ' ',  ' ', ['a', "#{address}"]))
    
    # Blank out the areacode if there's no phone number
    if phone.eql?('') 
      areacode='' 
    end

    record.append(MARC::DataField.new('225', ' ',  ' ', ['a', "#{areacode} #{phone}"]))

    record.append(MARC::DataField.new('600', ' ',  ' ', ['a', emailaddr]))

    marcwriter.write(record)
  end

}

marcwriter.close()

File.open('missing.txt', 'w') do |f|  
@missing.each do |s|
  f.puts s
end

File.open('errors.txt', 'w') do |f|  
  @errors.each do |s|
    f.puts s
  end
end

end


