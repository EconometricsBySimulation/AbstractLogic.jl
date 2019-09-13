# Source: https://www.lsac.org/lsat/taking-lsat/test-format/analytical-reasoning/analytical-reasoning-sample-questions
#
# A university library budget committee must reduce exactly five of eight areas of
# expenditure—G, L, M, N, P, R, S, and W—in accordance with the following conditions:
#
# 1 If both G and S are reduced, W is also reduced.
# 2 If N is reduced, neither R nor S is reduced.
# 3 If P is reduced, L is not reduced.
# 4 Of the three areas L, M, and R, exactly two are reduced.

julia> using AbstractLogic
Start the repl in command prompt by typing `=`.

abstractlogic> G, L, M, N, P, R, S, W ∈ red, not [clear]
Clear Workspace
G, L, M, N, P, R, S, W ∈ red, not        Feasible Outcomes: 256          Perceived Outcomes: 256 ✓       :not not red not red red red not

# 1 If both G and S are reduced, W is also reduced.
abstractlogic> G, S = 'red' ==> W = 'red'
G, S = 'red' ==> W = 'red'       Feasible Outcomes: 224          Perceived Outcomes: 256 ✓       :not red red red not red not red

# 2 If N is reduced, neither R nor S is reduced.
abstractlogic> N = 'red' ==> R, S = 'not'
N = 'red' ==> R, S = 'not'       Feasible Outcomes: 144          Perceived Outcomes: 256 ✓       :not not red not not not not not

# 3 If P is reduced, L is not reduced.
abstractlogic> P = 'red' ==> L = 'not'
P = 'red' ==> L = 'not'          Feasible Outcomes: 108          Perceived Outcomes: 256 ✓       :red not not not not not red red

# 4 Of the three areas L, M, and R, exactly two are reduced.
abstractlogic> L|M|R = 'red' {2}

# Question 1
# If both M and R are reduced,
# Save state
abstractlogic> M, R = 'red'
M, R = 'red'             Feasible Outcomes: 14   Perceived Outcomes: 16 ✓        :not not red not red red not not

# which one of the following is a pair of areas neither of which could be reduced?
# A. G, L
abstractlogic> all: G, L = 'not'
all: G, L = 'not' ... G, L = 'not'               Feasible Outcomes: 8    Perceived Outcomes: 8 ✓         :not not red not not red red not
false, 8 out of 14 possible combinations 'true'.

# B. G, N
abstractlogic> all: G, N = 'not'
all: G, N = 'not' ... G, N = 'not'               Feasible Outcomes: 8    Perceived Outcomes: 8 ✓         :not not red not not red not red
false, 8 out of 14 possible combinations 'true'.

# C. L, N
abstractlogic> all: L, N = 'not'
all: L, N = 'not' ... L, N = 'not'             Feasible Outcomes: 14   Perceived Outcomes: 16 ✓        :not not red not red red not not
true, 14 out of 14 possible combinations 'true'.
# D. L, P
abstractlogic> all: L, P = 'not'
all: L, P = 'not' ... L, P = 'not'             Feasible Outcomes: 7    Perceived Outcomes: 8 ✓         :not not red not not red red red
false, 7 out of 14 possible combinations 'true'.

# E. P, S
abstractlogic> all: P, S = 'not'
all: P, S = 'not' ... P, S = 'not'             Feasible Outcomes: 4    Perceived Outcomes: 4 ✓         :red not red not not red not not
false, 4 out of 14 possible combinations 'true'.

####
# Passage for Questions 2 and 3
# Seven piano students—T, U, V, W, X, Y, and Z—are to give a recital, and their
# instructor is deciding the order in which they will perform. Each student will
# play exactly one piece, a piano solo. In deciding the order of performance, the
# instructor must observe the following restrictions:

# 1. X cannot play first or second.
# 2. W cannot play until X has played.
# 3. Neither T nor Y can play seventh.
# 4. Either Y or Z must play immediately after W plays.
# 5. V must play either immediately after or immediately before U plays.

# Each students plays exactly one solo
abstractlogic> T, U, V, W, X, Y, Z ∈ unique [clear]
Clear Workspace
T, U, V, W, X, Y, Z ∈ unique     Feasible Outcomes: 5040         Perceived Outcomes: 823543 ✓    :3 2 4 1 7 5 6

# 1. X cannot play first or second.
abstractlogic> X != 1,2
X != 1,2                 Feasible Outcomes: 3600         Perceived Outcomes: 588245 ✓    :5 3 2 1 4 6 7

# 2. W cannot play until X has played.
abstractlogic> W > X
W > X                    Feasible Outcomes: 1200         Perceived Outcomes: 268912 ✓    :2 4 5 7 6 3 1

# 3. Neither T nor Y can play seventh.
abstractlogic> T,Y != 7
T,Y != 7                 Feasible Outcomes: 912          Perceived Outcomes: 197568 ✓    :6 4 5 7 3 1 2

# 4. Either Y or Z must play immediately after W plays.
abstractlogic> Y|Z = W + 1
Y|Z = W + 1              Feasible Outcomes: 162          Perceived Outcomes: 111132 ✓    :2 5 4 6 3 1 7

# 5. V must play either immediately after or immediately before U plays.
abstractlogic> V = U + 1 ||| V = U - 1
V = U + 1 ||| V = U - 1          Feasible Outcomes: 44   Perceived Outcomes: 63504 ✓     :5 1 2 6 4 3 7

# Question 2
# If V plays first, which one of the following must be true?

# First lets save our state since Question 1 creates an addition constraint
# which we would like to reverse.
abstractlogic> preserve
Preserving State

abstractlogic> V = 1
V = 1                    Feasible Outcomes: 9    Perceived Outcomes: 144 ✓       :5 2 1 6 3 4 7

# A. T plays sixth.
abstractlogic> all: T = 6
all: T = 6 ... T = 6                     Feasible Outcomes: 1    Perceived Outcomes: 1 ✓✓        :6 2 1 4 3 5 7
false, 1 out of 9 possible combinations 'true'.

# B. X plays third.
abstractlogic> all: X = 3
all: X = 3 ... X = 3                     Feasible Outcomes: 4    Perceived Outcomes: 27 ✓        :4 2 1 5 3 6 7
false, 4 out of 9 possible combinations 'true'.

# C. Z plays seventh.
abstractlogic> all: Z = 7
all: Z = 7 ... Z = 7                     Feasible Outcomes: 9    Perceived Outcomes: 144 ✓       :4 2 1 6 5 3 7
true, 9 out of 9 possible combinations 'true'.

# D. T plays immediately after Y.
abstractlogic> all: T = Y + 1
all: T = Y + 1 ... T = Y + 1             Feasible Outcomes: 3    Perceived Outcomes: 36 ✓        :5 2 1 6 3 4 7
false, 3 out of 9 possible combinations 'true'.

# E. W plays immediately after X.
abstractlogic> all: W = X + 1
all: W = X + 1 ... W = X + 1             Feasible Outcomes: 4    Perceived Outcomes: 108 ✓       :3 2 1 5 4 6 7
false, 4 out of 9 possible combinations 'true'.

# lets restore the previous state (we could also use the back command but that is more likely to lead to errors)
abstractlogic> restore
Restoring State - Feasible Outcomes: 44          Perceived Outcomes: 63504      :1 2 3 4 5 6 7

# Question 3
# If U plays third, what is the latest position in which Y can play?
abstractlogic> U = 3
U = 3                    Feasible Outcomes: 7    Perceived Outcomes: 160 ✓       :1 3 2 6 4 5 7

# The fast answer is:
abstractlogic> range Y
range Y
[1, 2, 4, 5, 6]

# first
# second
# fifth
# sixth
true
# seventh

# Passage for Question 4
# A charitable foundation awards grants in exactly four areas—medical services, theater arts, wildlife preservation, and youth services—each grant being in one of these areas. One or more grants are awarded in each of the four quarters of a calendar year. Additionally, over the course of a calendar year, the following must obtain:
#
# Grants are awarded in all four areas.
# No more than six grants are awarded.
# No grants in the same area are awarded in the same quarter or in consecutive quarters.
# Exactly two medical services grants are awarded.
# A wildlife preservation grant is awarded in the second quarter.
# Question 4
# If a wildlife preservation grant and a youth services grant are awarded in the same quarter of a particular calendar year, then any of the following could be true that year EXCEPT:
#
# A medical services grant is awarded in the second quarter.
# A theater arts grant is awarded in the first quarter.
# A theater arts grant is awarded in the second quarter.
# A wildlife preservation grant is awarded in the fourth quarter.
# A youth services grant is awarded in the third quarter.
# Explanation for Question 4
#
# Passage for Questions 5 and 6
# From a group of seven people—J, K, L, M, N, P, and Q—exactly four will be selected to attend a diplomat’s retirement dinner. Selection conforms to the following conditions:
#
# Either J or K must be selected, but J and K cannot both be selected.
# Either N or P must be selected, but N and P cannot both be selected.
# N cannot be selected unless L is selected.
# Q cannot be selected unless K is selected.
# Question 5
# If P is not selected to attend the retirement dinner, then exactly how many different groups of four are there each of which would be an acceptable selection?
#
# one
# two
# three
# four
# five
# Explanation for Question 5
#
# Question 6
# There is only one acceptable group of four that can be selected to attend the retirement dinner if which one of the following pairs of people is selected?
#
# J and L
# K and M
# L and N
# L and Q
# M and Q
# Explanation for Question 6
#
# Passage for Questions 7 and 8
# On a particular Saturday, a student will perform six activities—grocery shopping, hedge trimming, jogging, kitchen cleaning, laundry, and motorbike servicing. Each activity will be performed once, one at a time. The order in which the activities are performed is subject to the following conditions:
#
# Grocery shopping has to be immediately after hedge trimming.
# Kitchen cleaning has to be earlier than grocery shopping.
# Motorbike servicing has to be earlier than laundry.
# Motorbike servicing has to be either immediately before or immediately after jogging.
# Question 7
# If laundry is earlier than kitchen cleaning, then hedge trimming must be
#
# fifth
# fourth
# third
# second
# first
# Explanation for Question 7
#
#
# Question 8
# Which one of the following, if substituted for the condition that motorbike servicing has to be earlier than laundry, would have the same effect in determining the order of the student’s activities?
#
# Laundry has to be one of the last three activities.
# Laundry has to be either immediately before or immediately after jogging.
# Jogging has to be earlier than laundry.
# Laundry has to be earlier than hedge trimming.
# Laundry has to be earlier than jogging.
