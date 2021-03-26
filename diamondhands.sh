#!/bin/bash

confirm() {
    prompt="$1"
    [[ "$(read -e -p "$prompt (y/N): "; echo $REPLY)" == [Yy]* ]] && return 0 || return 1
}

buildFetchUrl() {
    echo "https://query1.finance.yahoo.com/v7/finance/quote?lang=en-US&region=US&corsDomain=finance.yahoo.com&fields=regularMarketPrice&symbols=$1"
}

buildChartUrl() {
    echo "https://query1.finance.yahoo.com/v8/finance/chart/$1?region=US&lang=en-US&includePrePost=false&interval=1d&useYfid=true&range=5d&corsDomain=finance.yahoo.com&.tsrc=finance"
}

getStockPrice(){
    fetchUrl=$(buildFetchUrl $1)
    fetchData=$(curl -s "$fetchUrl")

    stockPrice=$(echo "$fetchData" | grep -Po '"regularMarketPrice":\K.+?(?=,)')
    echo "$stockPrice"
}

viewStock() {

    stockPrice=$(getStockPrice $1)

    chartUrl=$(buildChartUrl $1)
    chartResponse=$(curl -s "$chartUrl")
    chartPrices=$(echo "$chartResponse" | grep -Po '"close":\[\K.+?(?=])'| tr ',' ' ')

    #output graph data
    ar1=(-5 -4 -3 -2 -1)
    read -r -a ar2 <<< "$chartPrices"
    paste <(printf "%s\n" "${ar1[@]}") <(printf "%s\n" "${ar2[@]}") > /tmp/diamondhands_chart.dat

    echo "$1 STOCK:"
    echo "Right now:" $stockPrice
    echo "Last 5 days:"

    echo -e "\nTable:"
    paste <(printf "%s\n" "${ar1[@]}") <(printf "%s\n" "${ar2[@]}")

    echo -e "\n\nChart:"
    gnuplot -e 'set terminal dumb ansirgb; set grid xtics; set xtics 1; set style line 1 pt "*" ps 1 lt 1 lw 2; plot "/tmp/diamondhands_chart.dat" title "" with linespoint ls 1'
}

getPortfolioEntry() {
    output=$(awk -v entry="\$$1" '($1==entry) {print $2}' portfolio.dat)
    echo $([[ -n $output ]] && echo "$output" || echo "0")
}
setPortfolioEntry() {
    key="$1"
    val="$2"

    # delete old entries if they exist,
    # two step because vanilla awk can't operate on same file
    portfolioRest=$(awk -v regex="\$$key" '$1!=regex' portfolio.dat)
    echo "$portfolioRest" > portfolio.dat
    

    echo "\$$key $val" >> portfolio.dat
}

isNegativeN() {
    [[ $1 == -* ]] && return 0 || return 1
}

# adds '+' to number if positive, only for display
addSignN() {
    echo $(isNegativeN "$1" || echo "+")"$1"
}

# invert number, cut '-' if negative, add '-' if positive
invertN() {
    echo $(isNegativeN "$1" && echo ${1:1} || echo "-$1")
}

tradeStock() {
    stockName="$1"
    transactionBal="$2"

    stockPrice=$(getStockPrice "$stockName")
    # if fail-> error and quit COuldnt find stock X,

    cash=$(getPortfolioEntry)
    echo "Cash: $cash\$"
    stockOwned=$(getPortfolioEntry "$stockName")
    stockValue=$(echo "$stockPrice" '*' "$stockOwned" | bc)
    echo "$stockName in portfolio: $stockOwned * $stockPrice\$ = $stockValue\$"


    # invert transactionBal because the money used in the transaction is
    # the opposite of bal, a -10 transaction means you put +10 on the stock
    transactionStock=$(echo -e "scale = 5\n $(invertN $transactionBal) / $stockPrice" | bc)

    echo "Transaction: $transactionStock * $stockPrice\$ = $(invertN $transactionBal)\$";

    resultStock=$(echo "$stockOwned + $transactionStock" | bc)
    resultCash=$(echo "$cash + $transactionBal" | bc)
    echo "Trade Result:"
    echo -e "\t$stockName stock:\t$resultStock\t" $(addSignN "$transactionStock")
    echo -e "\tBalance: \t$resultCash\t" $(addSignN "$transactionBal")

    isNegativeN "$resultStock" && echo "Not enough stocks" && return 0;
    isNegativeN "$resultCash" && echo "Not enough cash" && return 0;

    echo -e "\n"
    if ! confirm "Trade?"; then
	echo "Trade cancelled"
	return 0
    fi

    setPortfolioEntry "$stockName" "$resultStock"
    setPortfolioEntry "" "$resultCash"
    echo "Portfolio: "
    cat portfolio.dat
}

command="$1"
shift
case $command in
    "view")
	viewStock "$@";;
    "trade")
	tradeStock "$@";;
    *)
	echo "Unknown option.";;
esac
	
