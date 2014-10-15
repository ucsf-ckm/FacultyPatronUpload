Faculty Patron Upload
=====================

This repository contains the a ruby script for uploading faculty and staff patron data into the UCSF library INNOPAC system.

The script queries campus EDS (ldap) for patron information,looks up a pstat and expiration date based on job title, and formats a marc record for ingest into INNOPAC.

The pstat_title.txt file contains a lookup table for job titles and pstat codes. 

To generate the marc records, run the ruby script "create_marc_standalone.rb".  If the system encounters a job title not present in the "pstat_titles.txt" file, that patron will be assigned a pstat of "50" and the missing job title will be logged in "missing.txt".  If a pstat can't be calculated for an individual faculty or staff member, the error will be logged in "errors.txt" (and again, the patron will be assigned a pstat of 50 for general staff).  You can add the title and pstat to the pstat_title.text file if you wish.  

After successful completion, the marc records will be written to a file called "out.dat".

If you'd like to verify that this is a correct marc file using a different library than the one that was used to produce it, there is a short java script available.  Run java -cp .:lib/* ReadMarcExample out.dat to parse and print the marc records.  This script may help flag any errors that were produced in the marc file by the ruby script.  

To run this script, you will need an EDS bind with access to the variables 

cn
givenName
postalAddress
telephoneNumber
mail
ucsfEduIDNumber
eduPersonPrimaryAffiliation
title

https://wiki.library.ucsf.edu/display/IAM/EDS+Attributes





