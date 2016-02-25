Faculty Patron Upload
=====================

This repository contains the a ruby script for uploading faculty and staff patron data into the UCSF library INNOPAC system.

The script queries campus EDS (ldap) for patron information,looks up a pstat and expiration date based on job title, and formats a marc record for ingest into INNOPAC.

The pstat_title.txt file contains a lookup table for job titles and pstat codes. 

To generate the marc records, run the ruby script "create_marc_standalone.rb".  If the system encounters a job title not present in the "pstat_titles.txt" file, that patron will be assigned a pstat of "50" and the missing job title will be logged in "missing.txt".  If a pstat can't be calculated for an individual faculty or staff member, the error will be logged in "errors.txt" (and again, the patron will be assigned a pstat of 50 for general staff).  You can add the title and pstat to the pstat_title.text file if you wish.  

After successful completion, the marc records will be written to a file called "out.dat".

If you'd like to verify that this is a correct marc file using a different library than the one that was used to produce it, there is a short java script available.  Run java -cp .:lib/* ReadMarcExample out.dat to parse and print the marc records.  This script may help flag any errors that were produced in the marc file by the ruby script.  

To run this script, you will need an EDS bind with access to the variables and access to a REST service providing barcode information.  

cn
givenName
postalAddress
telephoneNumber
mail
ucsfEduIDNumber
eduPersonPrimaryAffiliation
title

https://wiki.library.ucsf.edu/display/IAM/EDS+Attributes

Windows Executable

If you want to install the app on a windows workstation without requiring a ruby installation,
you can create a Ruby executable file (that will have ruby and all necessary gems included).

http://rubyonwindows.blogspot.com/2009/05/ocra-one-click-ruby-application-builder.html

you do need to be on a windows machine, this won't work on Mac

gem install orca

orca create_marc_standalone.rb

This will create an .exe file with no external ruby dependencies.  

NOTE: to install this on windows, you will need to install the DevKit as well as Ruby 2.0.0
Don't try to use 2.1.8, there's a path problem for ocra.  

http://rubyinstaller.org/add-ons/devkit
follow the instructions at
https://github.com/oneclick/rubyinstaller/wiki/development-kit




