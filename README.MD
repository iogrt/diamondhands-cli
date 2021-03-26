# DiamondHands-cli
> a quick & little bash program to simulate stock trading

## Installation
Just run the bash script, there may be some general cli utilities you might need like `awk` or `gnuplot`.

Remember to get run permissions (`chmod +x diamondhands.sh`) 

## Example Usage
### Viewing stocks
	```bash
$ ./diamondhands.sh view AMZN
AMZN STOCK:
Right now: 3046.26
Last 5 days:

Table:
-5	3074.9599609375
-4	3110.8701171875
-3	3137.5
-2	3087.070068359375
-1	3046.260009765625


Chart:

                                                                               
  3140 +-------------------------------------------------------------------+ 
       |                +            --- +  -             +                |
  3130 |-+              :         ---    :   --           :              +-| 
       |                :       --       :     -          :                | 
  3120 |-+              :    ---         :      --        :              +-| 
       |                : ---            :        --      :                | 
  3110 |-+             -*-               :          -     :              +-| 
       |             -- :                :           --   :                | 
  3100 |-+        ---   :                :             -  :              +-| 
       |        --      :                :              --:                | 
  3090 |-+    --        :                :                :              +-| 
       |   ---          :                :                *---             |
  3080 |---             :                :                :   --         +-|
       |-               :                :                :     --         |
  3070 |-+              :                :                :       --     +-| 
       |                :                :                :         --     | 
  3060 |-+              :                :                :           -- +-| 
       |                :                :                :             -- | 
  3050 |-+              :                :                :              +-| 
       |                +                +                +                | 
  3040 +-------------------------------------------------------------------+ 
      -5               -4               -3               -2               -1 



```
### Trading stocks
You start with 1000$, (easily editable in `portfolio.dat` file.
Here `-200` means take 200 from my balance
```bash
$ diamondhands.sh trade AMZN -200
Cash: 1000$
AMZN in portfolio: 0 * 3046.26$ = 0$
Transaction: .06565 * 3046.26$ = 200$
Trade Result:
	AMZN stock:	.06565	 +.06565
	Balance: 	800	 -200


Trade? (y/N): y
set: AMZN .06565
set:  800
Portfolio: 
$AMZN .06565
$ 800
```
Selling those stocks:
```bash
$ ./diamondhands.sh trade AMZN 200
Cash: 800$
AMZN in portfolio: .06565 * 3046.26$ = 199.98696$
Transaction: -.06565 * 3046.26$ = -200$
Trade Result:
	AMZN stock:	0	 -.06565
	Balance: 	1000	 +200


Trade? (y/N): y
Portfolio: 
$AMZN 0
$ 1000
```

## Missing features (PRs Welcome!)
- view portfolio command
- portfolio management (reset, inject cash)
- log file
