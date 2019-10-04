# Snape's Riddle - Author JK Rowling

>Danger lies before you, while safety lies behind,
>Two of us will help you, whichever you would find,
>One among us seven will let you move ahead,
>Another will transport the drinker back instead,
>Two among our number hold only nettle wine,
>Three of us are killers, waiting hidden in line.
>Choose, unless you wish to stay here for evermore,
>To help you in your choice, we give you these clues four:
>First, however slyly the poison tries to hide
>You will always find some on nettle wine’s left side;
>Second, different are those who stand at either end,
>But if you would move onwards, neither is your friend;
>Third, as you see clearly, all are different size,
>Neither dwarf nor giant holds death in their insides;
>Fourth, the second left and the second on the right
>Are twins once you taste them, though different at first sight.

```
julia> using AbstractLogic
Start the repl in command prompt by typing `=`.
```

Codes:
* NW - is netted wine
* MA - move ahead    
* MB - move back
* PO - poison

Seven Potions a, b, c, d, e, f, g each have 1 of 4 possible values
a is left of b which is left of c etc.
```
abstractlogic> a, b, c, d, e, f, g  ∈  NW, MA, MB, PO [clear]
```

Two among our number hold only nettle wine, #code 1
```
abstractlogic> {{i}} == 'NW' {{2}}
```
Equivalent to logicalparse(["a|b|c|d|e|f|g == 1 {2}"], logicset=hpset)

One among us seven will let you move ahead, #code 2
```
abstractlogic> {{i}} == 'MA' {{1}}
```

Another will transport the drinker back instead, #code 3
```
abstractlogic> {{i}} == 'MB' {{1}}
```

Three of us are killers #code 4
```
abstractlogic> {{i}} == 'PO' {{3}}
```

This last specification does not reduce the feasible set

First, however slyly the poison tries to hide
You will always find some on nettle wine’s left side;
So if b is poison then a is nettle wine
The i-1! indicates that outofbounds matches are considered "false"
```
abstractlogic> {{i}} == 'NW' ==> {{i-1!}} == 'PO'
```

60 possible outcomes

Second, different are those who stand at either end,
```
abstractlogic> a != g
```

But if you would move onwards, neither is your friend;
```
abstractlogic> a,g != 'MA'
```
30 possible outcomes

Third, as you see clearly, all are different size,
Neither dwarf nor giant holds death in their insides;
c dwarf, f are giant
```
abstractlogic> c,f != 'PO'
```

Fourth, the second left and the second on the right
Are twins once you taste them, though different at first sight.
```
abstractlogic> b == f
```

```
abstractlogic> search ='MA'
```
c is a match, for the third bottle

```
abstractlogic> search ='MB'
```
g is a match, for the last bottle
