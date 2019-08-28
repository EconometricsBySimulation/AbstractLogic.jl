"""
Snape's Riddle - Author JK Rowling
Danger lies before you, while safety lies behind,
Two of us will help you, whichever you would find,
One among us seven will let you move ahead,
Another will transport the drinker back instead,
Two among our number hold only nettle wine,
Three of us are killers, waiting hidden in line.
Choose, unless you wish to stay here for evermore,
To help you in your choice, we give you these clues four:
First, however slyly the poison tries to hide
You will always find some on nettle wine’s left side;
Second, different are those who stand at either end,
But if you would move onwards, neither is your friend;
Third, as you see clearly, all are different size,
Neither dwarf nor giant holds death in their insides;
Fourth, the second left and the second on the right
Are twins once you taste them, though different at first sight.
"""

# Codes:
# 1 is netted wine
# 2 move ahead
# 3 move back
# 4 kill

# Seven Potions a,b,c,d,e,f,g each have 1 of 4 possible values
# a is left of b which is left of c etc.
logicset = logicalparse(["a, b, c, d, e, f, g  ∈  1:4"])

# Two among our number hold only nettle wine, #code 1
logicset = logicalparse(["{{i}} == 1 {{2}}"], logicset=logicset); showfeasible(logicset)
# Equivalent to logicalparse(["a|b|c|d|e|f|g == 1 {2}"], logicset=logicset)

# One among us seven will let you move ahead, #code 2
logicset = logicalparse(["{{i}} == 2 {{1}}"], logicset=logicset); showfeasible(logicset)
#logicset = logicalparse(["a|b|c|d|e|f|g == 2 {1}"], logicset=logicset)

#Another will transport the drinker back instead, #code 3
logicset = logicalparse(["{{i}} == 3 {{1}}"], logicset=logicset); showfeasible(logicset)

# Three of us are killers #code 4
logicset = logicalparse(["{{i}} == 4 {{3}}"], logicset=logicset); showfeasible(logicset)
# This last specification does not reduce the feasible set

# First, however slyly the poison tries to hide
# You will always find some on nettle wine’s left side;
# So if b is poison then a is nettle wine
logicset = logicalparse(["{{i+1}} == 1 ==> {{i}} == 4"], logicset=logicset); showfeasible(logicset)
# 120 Possibilities

# Wine cannot be in the first bottle since poison is to the left
logicset = logicalparse(["a != 1"], logicset=logicset); showfeasible(logicset)
# 60 possible outcomes

# Second, different are those who stand at either end,
logicset = logicalparse(["a != g"], logicset=logicset)

# But if you would move onwards, neither is your friend;
logicset = logicalparse(["a|g == 2 {0}"], logicset=logicset); showfeasible(logicset)
logicset = logicalparse(["a & g != 2 "], logicset=logicset); showfeasible(logicset)
# 30 possible outcomes

# But if you would move onwards, neither is your friend;
# Third, as you see clearly, all are different size,
# Neither dwarf nor giant holds death in their insides;
# c dwarf, f are giant
logicset = logicalparse(["c|f == 4 {0}"], logicset=logicset); showfeasible(logicset)

# Fourth, the second left and the second on the right
# Are twins once you taste them, though different at first sight.
logicset = logicalparse(["b == f"], logicset=logicset)

showfeasible(logicset)
# You pick the 3rd (move ahead) and the 7th (move back)
