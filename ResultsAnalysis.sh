#!/bin/bash
SlowestAndFastest() {
fastestTime=9999999
fastestSite=""
slowestTime=0
slowestSite=""
while read -r site t1 t2 t3 t4 t5 avgT; do
if [[ -z "$site" ]]; then
	continue
fi
	for time in $t1 $t2 $t3 $t4 $t5; do
		#fastest
		if (( $(echo "$time < $fastestTime" | bc -l) )); then
			fastestTime=$time
			fastestSite=$site
		fi
		#slowest
		if (( $(echo "$time > $slowestTime" | bc -l) )); then
			slowestTime=$time
			slowestSite=$site
		fi
	done
done < "$input_file"
echo "fastest time=$fastestTime fastest site=$fastestSite slowest time=$slowestTime slowest site=$slowestSite"
}

#RankByAvg(){
#}

#ShowRank(){
#}

#calculateAvgOfAvg(){
#}
input_file="PingResults.txt"
SlowestAndFastest 

