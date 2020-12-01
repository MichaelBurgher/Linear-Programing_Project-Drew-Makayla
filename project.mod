set PPL; # set of possible polling locations. 
param latp {j in PPL}; # indices refer to addresses in data document
param lonp {j in PPL}; # latitute and logitue included

set CB; #set of all census tracts
param latc {j in CB}; # indices refer to lat/lon coordinates of centroids of tracts
param lonc {j in CB};
param pop {j in CB}; # includes population in each tract

param poll_max >= 0; # max number of people that can vote at a single poll
param poll_num >= 0; # max number of polls to which the program will assign tracts

var loc_used {PPL cross CB} binary; 
	# 1 if CB is assigned to a PPL, 0 otherwise
	
minimize Total_Distance: sum {i in PPL} (sum {j in CB} (pop[j]*loc_used[i,j]*
	((latp[i] - latc[j])^2 + (lonp[i] - lonc[j])^2)));
	# minimizes total distance traveled by all voters to the polls. This is weighted by population
	
subject to Assignment {j in CB}: sum {i in PPL} loc_used[i,j] = 1;
	# ensures each tract is assigned to exactly one poll

subject to Max_People {i in PPL}: sum {j in CB} loc_used[i,j]*pop[j] <= poll_max;
	# Ensures no poll will serve over a maximum amount of voters
	# Denver has 600,000 voters. If we have 50 polling locations, that is an average of 12,000 people/CB
	# As a result, we picked 15,0000 for our max in this program

subject to Maximum_Number_of_Places_Used: sum {i in PPL} 
	(prod {j in CB} (1-loc_used[i,j])) >= 515 - poll_num;
	# We chose 50 to reflect the approximate number of actual voting places in Denver
	
# Copy what is below this in the comman line. It will run the program and display the 515 polling
# locations as well has how many tracts and how many people will be voting there

# reset; model project.mod; data tract.dat; solve; 
# display {i in PPL} sum {j in CB} loc_used[i,j]; display {i in PPL} sum {j in CB} loc_used[i,j]*pop[j];	
