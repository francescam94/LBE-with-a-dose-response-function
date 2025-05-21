*Set directory
cd "directory"

*Import the patent data from Orbis
use "bvdid patent priority.dta"

*generate the year variable
 gen year=substr(prioritydate,7,4) 
 destring year, replace

 *generate the patent counter
 gen number_patents=1
 
 *Veryfy what patents are co-ownes
 bysort publicationnumber year: gen co_own=_N
 
 *Adjust the number by the number of co-owners
  replace number_patents= number_patents/co_own
  
  *Compute the number of patents by applicant
 bysort applicantsbvdidnumbers year: egen patents_n=total(number_patents)
 
 *rename the variables
 rename applicantsbvdidnumbers bvdidnumber
 
 *Keep relevant
 keep bvdidnumber year patents_n

 duplicates drop
 
 save "Data/bvdid_patent_priority.dta"
