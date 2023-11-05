#!/bin/bash

method1() {
    echo ""
    echo -n "Please enter 'movie id' (1~1682): "
    read movie_id

    echo ""
    sed "${movie_id}q;d" u.item
}

method2() {
    echo ""
    echo -n "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n): "
    read check
    echo ""

    if [ "$check" != "${check#[Yy]}" ] ;then
        awk -F '|' 'BEGIN {count=0} $7 == 1 && count < 10 {print $1, $2; count++}' u.item
    fi
}

method3() {
    echo ""
    echo -n "Please enter the 'movie id' (1~1682): "
    read movie_id
    echo ""

    average=$(awk -v id=$movie_id -F ' ' '$2 == id {sum+=$3; count++} END {if (count > 0) printf "%.5f", sum/count}' u.data)

    echo "average rating of $movie_id: $average"
}

method4() {
    echo ""
    awk -F '|' 'NR <= 10 {printf "%s|%s|%s|%s||", $1, $2, $3, $4; for(i=6; i<=NF; i++) printf "%s|", $i; printf "\n"}' u.item
}

method5() {
    echo ""
    echo -n "Do you want to get the data about users from 'u.user'?(y/n): "
    read answer

    if [ "$answer" != "${answer#[Yy]}" ]; then
        awk -F '|' 'NR <= 10 {gender = ($3 == "M") ? "male" : "female"; printf "user %s is %s years old %s %s \n", $1, $2, gender, $4}' u.user
    fi
}

method6() {
    echo ""
    awk -F '|' 'BEGIN{months["Jan"]="01";months["Feb"]="02";months["Mar"]="03";months["Apr"]="04";months["May"]="05";months["Jun"]="06";months["Jul"]="07";months["Aug"]="08";months["Sep"]="09";months["Oct"]="10";months["Nov"]="11";months["Dec"]="12"} $1 >= 1673 && $1 <= 1682 {split($3, d, "-"); $3 = d[3] months[d[2]] d[1]; print $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "|" $10 "|" $11 "|" $12 "|" $13 "|" $14 "|" $15 "|" $16 "|" $17 "|" $18 "|" $19 "|" $20 "|" $21 "|" $22 "|" $23 "|" $24}' u.item
}

method7() {
    echo ""
    read -p "Please enter the 'user id'(1~943): " user_id
    echo ""

    movie_ids=$(awk -v user_id="$user_id" -F '\t' '{if ($1 == user_id) print $2}' u.data | sort -n | paste -sd "|" -)

    echo "$movie_ids"
    echo ""

    IFS='|' read -ra IDS <<< "$movie_ids"
    for id in "${IDS[@]:0:10}"; do
        awk -v movie_id="$id" -F '|' '{if ($1 == movie_id) print $1 " | " $2}' u.item
    done
}

method8() {
    echo ""
    user_ids=$(awk -F '|' '{if ($2 >= 20 && $2 <= 29 && $4 == "programmer") print $1}' u.user | paste -sd "|" -)

    declare -A rating_sum
    declare -A rating_count

    while IFS=$'\t' read -r user_id movie_id rating timestamp
    do
        if [[ $user_ids =~ (^|[|])$user_id($|[|]) ]]; then
            ((rating_sum[movie_id]+=rating))
            ((rating_count[movie_id]++))
        fi
    done < u.data

    for ((movie_id=1; movie_id<=1682; movie_id++))
    do
        if [ ${rating_count[$movie_id]+_} ]; then
            if [ ${rating_count[$movie_id]} -ne 0 ]; then
                average_rating=$(echo "scale=5; ${rating_sum[$movie_id]} / ${rating_count[$movie_id]}" | bc -l)
            
                if [[ $average_rating == *".000000" ]]; then
                    printf "movie_id: %d average_rating: %.0f\n" $movie_id $average_rating
                else
                    printf "movie_id: %d average_rating: %.5f\n" $movie_id $average_rating
                fi
            fi
        fi
    done
}

echo "-------------------------------------"
echo "User Name : Dong-heyon Kang"
echo "Student Number : 12201673"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of ‘action’ genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’"
echo "4. Delete the ‘IMDb URL’ from ‘u.item’"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "-------------------------------------"


while :
do
    echo ""
    echo -n "Enter your choice [1-9]: "
    read choice
    case $choice in
        1) method1 ;;
        2) method2 ;;
        3) method3 ;;
        4) method4 ;;
        5) method5 ;;
        6) method6 ;;
        7) method7 ;;
        8) method8 ;;
        9) echo "Bye!"
            break ;;
        *) echo "Invalid choice." ;;

    esac
done
