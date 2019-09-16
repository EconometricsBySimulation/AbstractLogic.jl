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
# A charitable foundation awards grants in exactly four areas—medical services,
# theater arts, wildlife preservation, and youth services—each grant being in
# one of these areas.
abstractlogic> q1.m, q1.t, q1.w, q1.y ∈ 0:1 [clear]
Clear Workspace
q1.m, q1.t, q1.w, q1.y ∈ 0:1     Feasible Outcomes: 16   Perceived Outcomes: 16 ✓    :1 0 1 1

abstractlogic> q2.m, q2.t, q2.w, q2.y ∈ 0:1
q2.m, q2.t, q2.w, q2.y ∈ 0:1     Feasible Outcomes: 256      Perceived Outcomes: 256 ✓       :0 0 0 0 0 1 1 1

abstractlogic> q3.m, q3.t, q3.w, q3.y ∈ 0:1
q3.m, q3.t, q3.w, q3.y ∈ 0:1     Feasible Outcomes: 4096     Perceived Outcomes: 4096 ✓      :0 1 0 1 0 1 0 0 0 0 1 1

abstractlogic> q4.m, q4.t, q4.w, q4.y ∈ 0:1
q4.m, q4.t, q4.w, q4.y ∈ 0:1     Feasible Outcomes: 65536    Perceived Outcomes: 65536 ✓     :0 1 1 0 0 0 0 0 1 0 1 0 0 0 1 0
# One or more grants are awarded in each of the four quarters of a calendar year.

abstractlogic> {{>=:q1.m,<=:q1.y}} == 1 {{1,}}
{{>=:q1.m,<=:q1.y}} == 1 {{1,}}  >>> q1.m == 1 >>> q1.t == 1 >>> q1.w == 1 >>> q1.y == 1 {{1,∞}}
     Feasible Outcomes: 61440    Perceived Outcomes: 65536 ✓     :0 1 0 1 1 1 0 1 0 0 0 0 1 1 1 0
abstractlogic> {{>=:q2.m,<=:q2.y}} == 1 {{1,}}
{{>=:q2.m,<=:q2.y}} == 1 {{1,}}  >>> q2.m == 1 >>> q2.t == 1 >>> q2.w == 1 >>> q2.y == 1 {{1,∞}}
     Feasible Outcomes: 57600    Perceived Outcomes: 65536 ✓     :1 0 0 0 0 0 1 0 1 0 1 1 0 0 1 0
abstractlogic> {{>=:q3.m,<=:q3.y}} == 1 {{1,}}
{{>=:q3.m,<=:q3.y}} == 1 {{1,}}  >>> q3.m == 1 >>> q3.t == 1 >>> q3.w == 1 >>> q3.y == 1 {{1,∞}}
     Feasible Outcomes: 54000    Perceived Outcomes: 65536 ✓     :0 1 0 1 1 1 1 0 1 0 1 0 0 1 0 1
abstractlogic> {{>=:q4.m,<=:q4.y}} == 1 {{1,}}
{{>=:q4.m,<=:q4.y}} == 1 {{1,}}  >>> q4.m == 1 >>> q4.t == 1 >>> q4.w == 1 >>> q4.y == 1 {{1,∞}}
     Feasible Outcomes: 50625    Perceived Outcomes: 65536 ✓     :0 1 0 1 1 0 1 1 1 1 0 0 1 0 0 1

# Additionally, over the course of a calendar year, the following must obtain:

# Grants are awarded in all four areas.
abstractlogic> {{j}}.m = 1 {{1,}}; {{j}}.t = 1 {{1,}}; {{j}}.w = 1 {{1,}}; {{j}}.y = 1 {{1,}}
{{j}}.m = 1 {{1,}}  >>> q1.m = 1 >>> q2.m = 1 >>> q3.m = 1 >>> q4.m = 1 {{1,∞}}
     Feasible Outcomes: 48224    Perceived Outcomes: 65536 ✓     :1 0 1 0 0 0 0 1 0 1 1 0 1 0 0 1
{{j}}.t = 1 {{1,}}  >>> q1.t = 1 >>> q2.t = 1 >>> q3.t = 1 >>> q4.t = 1 {{1,∞}}
     Feasible Outcomes: 45904    Perceived Outcomes: 65536 ✓     :1 0 1 0 1 0 0 1 1 1 0 1 1 1 1 1
{{j}}.w = 1 {{1,}}  >>> q1.w = 1 >>> q2.w = 1 >>> q3.w = 1 >>> q4.w = 1 {{1,∞}}
     Feasible Outcomes: 43664    Perceived Outcomes: 65536 ✓     :1 0 0 0 0 1 0 1 1 0 1 0 0 0 0 1
{{j}}.y = 1 {{1,}}  >>> q1.y = 1 >>> q2.y = 1 >>> q3.y = 1 >>> q4.y = 1 {{1,∞}}
     Feasible Outcomes: 41503    Perceived Outcomes: 65536 ✓     :1 0 0 0 1 1 1 1 0 1 0 1 0 1 0 1

# No more than six grants are awarded.
abstractlogic> {{i}} = 1 {{,6}}
{{i}} = 1 {{,6}}  >>> q1.m = 1 >>> q1.t = 1 ... >>> q4.w = 1 >>> q4.y = 1 {{0,6}}
     Feasible Outcomes: 2704     Perceived Outcomes: 65536 ✓     :1 0 0 0 1 0 0 0 0 1 1 0 1 0 0 1

# No grants in the same area are awarded in the same quarter or in consecutive quarters.
# Medical and theater arts
abstractlogic> {{j}}.m = 1 ==> {{j+1}}.m != 1; {{j}}.t = 1 ==> {{j+1}}.t != 1
{{j}}.m = 1 ==> {{j+1}}.m != 1  >>> q1.m = 1 ==> q2.m != 1 >>> q2.m = 1 ==> q3.m != 1 >>> q3.m = 1 ==> q4.m != 1
     Feasible Outcomes: 2088     Perceived Outcomes: 65536 ✓     :1 0 0 1 0 1 0 0 0 0 1 0 0 1 0 1
{{j}}.t = 1 ==> {{j+1}}.t != 1  >>> q1.t = 1 ==> q2.t != 1 >>> q2.t = 1 ==> q3.t != 1 >>> q3.t = 1 ==> q4.t != 1
     Feasible Outcomes: 1538     Perceived Outcomes: 65536 ✓     :0 0 1 1 1 0 0 1 0 1 0 0 1 0 0 0

# wildlife and youthservice
abstractlogic> {{j}}.w = 1 ==> {{j+1}}.w != 1; {{j}}.y = 1 ==> {{j+1}}.y != 1
{{j}}.w = 1 ==> {{j+1}}.w != 1  >>> q1.w = 1 ==> q2.w != 1 >>> q2.w = 1 ==> q3.w != 1 >>> q3.w = 1 ==> q4.w != 1
     Feasible Outcomes: 1054     Perceived Outcomes: 65536 ✓     :1 1 0 0 0 0 0 1 1 0 0 0 0 0 1 1
{{j}}.y = 1 ==> {{j+1}}.y != 1  >>> q1.y = 1 ==> q2.y != 1 >>> q2.y = 1 ==> q3.y != 1 >>> q3.y = 1 ==> q4.y != 1
     Feasible Outcomes: 636      Perceived Outcomes: 65536 ✓     :1 0 0 0 0 0 1 0 1 1 0 0 0 0 0 1

# Exactly two medical services grants are awarded.
abstractlogic> {{j}}.m = 1 {{2}}
{{j}}.m = 1 {{2}}  >>> q1.m = 1 >>> q2.m = 1 >>> q3.m = 1 >>> q4.m = 1 {{2}}
     Feasible Outcomes: 252      Perceived Outcomes: 65536 ✓     :1 0 0 0 0 1 1 0 0 0 0 1 1 1 0 0

# A wildlife preservation grant is awarded in the second quarter.
abstractlogic> q2.w = 1
q2.w = 1         Feasible Outcomes: 81   Perceived Outcomes: 8192 ✓      :1 0 0 0 0 0 1 1 1 0 0 0 0 1 0 1

# Question 4
# If a wildlife preservation grant and a youth services grant are awarded in the
# same quarter of a particular calendar year, then any of the following could be
# true that year EXCEPT:
abstractlogic> preserve
Preserving State

abstractlogic> {{j}}.w = 1 &&& {{j}}.y = 1 {{1,}}
{{j}}.w = 1 &&& {{j}}.y = 1 {{1,}}  >>> q1.w = 1 &&& q1.y = 1 >>> q2.w = 1 &&& q2.y = 1 >>> q3.w = 1 &&& q3.y = 1 >>> q4.w = 1 &&& q4.y = 1 {{1,∞}}
     Feasible Outcomes: 21   Perceived Outcomes: 2048 ✓      :1 0 0 0 0 1 1 0 1 0 0 0 0 0 1 1

# A. A medical services grant is awarded in the second quarter.
abstractlogic> any: q2.m = 1
any: q2.m = 1 ... q2.m = 1       Feasible Outcomes: 1    Perceived Outcomes: 1 ✓✓    :0 1 0 0 1 0 1 1 0 1 0 0 1 0 0 0
true, 1 out of 21 possible combinations 'true'.

# B. A theater arts grant is awarded in the first quarter.
abstractlogic> any: q1.t = 1
any: q1.t = 1 ... q1.t = 1       Feasible Outcomes: 6    Perceived Outcomes: 512 ✓       :1 1 0 0 0 0 1 1 1 0 0 0 0 0 1 0
true, 6 out of 21 possible combinations 'true'.

# C. A theater arts grant is awarded in the second quarter.
abstractlogic> any: q2.t = 1
any: q2.t = 1 ... q2.t = 1       Feasible Outcomes: 4    Perceived Outcomes: 16 ✓    :1 0 0 0 0 1 1 1 1 0 0 0 0 0 1 0
true, 4 out of 21 possible combinations 'true'.

# D. A wildlife preservation grant is awarded in the fourth quarter.
abstractlogic> any: q4.w = 1
any: q4.w = 1 ... q4.w = 1       Feasible Outcomes: 10   Perceived Outcomes: 256 ✓       :1 0 0 0 0 0 1 0 1 0 0 0 0 1 1 1
true, 10 out of 21 possible combinations 'true'.

# E. A youth services grant is awarded in the third quarter.
abstractlogic> any: q3.y = 1
any: q3.y = 1 ... q3.y = 1       Feasible Outcomes: 0    Perceived Outcomes: 0 X      [empty set]
false, 0 out of 21 possible combinations 'true'.

# Passage for Questions 5 and 6
# From a group of seven people—J, K, L, M, N, P, and Q—exactly four will be selected
# to attend a diplomat’s retirement dinner. Selection conforms to the following conditions:
abstractlogic> J, K, L, M, N, P, Q ∈ 0:1 [clear]
Clear Workspace
J, K, L, M, N, P, Q ∈ 0:1    Feasible Outcomes: 128      Perceived Outcomes: 128 ✓       :1 1 1 0 0 1 1

abstractlogic> {{i}} = 1 {{4}}
{{i}} = 1 {{4}}  >>> J = 1 >>> K = 1 ... >>> P = 1 >>> Q = 1 {{4}}
         Feasible Outcomes: 35    Perceived Outcomes: 128 ✓       :0 1 0 1 0 1 1

# Either J or K must be selected, but J and K cannot both be selected.
abstractlogic> J ^ K
J ^ K            Feasible Outcomes: 20   Perceived Outcomes: 128 ✓       :0 1 1 0 0 1 1

# Either N or P must be selected, but N and P cannot both be selected.
abstractlogic> N ^ P
N ^ P            Feasible Outcomes: 12   Perceived Outcomes: 128 ✓       :0 1 1 0 0 1 1

# N cannot be selected unless L is selected.
abstractlogic> L! ==> N!
L! ==> N!        Feasible Outcomes: 10   Perceived Outcomes: 128 ✓       :1 0 1 0 1 0 1

# Q cannot be selected unless K is selected.
abstractlogic> K! ==> !Q
K! ==> !Q        Feasible Outcomes: 7    Perceived Outcomes: 128 ✓       :0 1 0 1 0 1 1

# Question 5
abstractlogic> preserve
Preserving State
# If P is not selected to attend the retirement dinner, then exactly how many
# different groups of four are there each of which would be an acceptable selection?
abstractlogic> P = 1
P = 1            Feasible Outcomes: 4    Perceived Outcomes: 32 ✓    :0 1 1 0 0 1 1
abstractlogic> show
J K L M N P Q
– – – – – – –
0 1 0 1 0 1 1
0 1 1 0 0 1 1
0 1 1 1 0 1 0
1 0 1 1 0 1 0
# one
# two
# three
# four - we can see from the output that 4 is available
# five
abstractlogic> restore
Restoring State - Feasible Outcomes: 7   Perceived Outcomes: 128    :0 0 0 1 1 1 1

# Question 6
# There is only one acceptable group of four that can be selected to attend the
# retirement dinner if which one of the following pairs of people is selected?

# J and L
abstractlogic> check: J == 1 &&& L == 1
check: J == 1 &&& L == 1 ... check: J == 1 &&& L == 1     Feasible Outcomes: 2    Perceived Outcomes: 4 ✓     :1 0 1 1 1 0 0
possible, 2 out of 7 possible combinations 'true'.

# K and M
abstractlogic> check: K == 1 &&& M == 1
check: K == 1 &&& M == 1 ... check: K == 1 &&& M == 1     Feasible Outcomes: 3    Perceived Outcomes: 16 ✓    :0 1 1 1 1 0 0
possible, 3 out of 7 possible combinations 'true'.

# L and N
abstractlogic> check: L == 1 &&& N == 1
check: L == 1 &&& N == 1 ... check: L == 1 &&& N == 1     Feasible Outcomes: 3    Perceived Outcomes: 16 ✓    :1 0 1 1 1 0 0
possible, 3 out of 7 possible combinations 'true'.

# L and Q
abstractlogic> check: L == 1 &&& Q == 1
check: L == 1 &&& Q == 1 ... check: L == 1 &&& Q == 1     Feasible Outcomes: 2    Perceived Outcomes: 4 ✓     :0 1 1 0 0 1 1
possible, 2 out of 7 possible combinations 'true'.

# M and Q
abstractlogic> check: M == 1 &&& Q == 1
heck: M == 1 &&& Q == 1 ... check: M == 1 &&& Q == 1     Feasible Outcomes: 1    Perceived Outcomes: 1 ✓✓    :0 1 0 1 0 1 1
possible, 1 out of 7 possible combinations 'true'.

# Explanation for Question 6
#
# Passage for Questions 7 and 8
# On a particular Saturday, a student will perform six activities—grocery
# shopping, hedge trimming, jogging, kitchen cleaning, laundry, and motorbike servicing.
# Each activity will be performed once, one at a time.
abstractlogic> s, h, j, k, l, m ∈ unique [clear]
Clear Workspace
s, h, j, k, l, m ∈ unique    Feasible Outcomes: 720      Perceived Outcomes: 46656 ✓     :1 5 2 3 6 4
# The order in which the activities are performed is subject to the following conditions:

# Grocery shopping has to be immediately after hedge trimming.
abstractlogic> s = h + 1
s = h + 1        Feasible Outcomes: 120      Perceived Outcomes: 32400 ✓     :2 1 6 4 5 3

# Kitchen cleaning has to be earlier than grocery shopping.
abstractlogic> k < s
k < s            Feasible Outcomes: 60   Perceived Outcomes: 13824 ✓     :3 2 5 1 6 4

# Motorbike servicing has to be earlier than laundry.
abstractlogic> m < l
m < l            Feasible Outcomes: 30   Perceived Outcomes: 9600 ✓      :5 4 6 1 3 2

# Motorbike servicing has to be either immediately before or immediately after jogging.
abstractlogic> m = j + 1 ||| m = j - 1
m = j + 1 ||| m = j - 1      Feasible Outcomes: 12   Perceived Outcomes: 2025 ✓      :5 4 3 1 6 2

# Question 7
# If laundry is earlier than kitchen cleaning, then hedge trimming must be

abstractlogic> l < k
l < k            Feasible Outcomes: 2    Perceived Outcomes: 4 ✓     :6 5 1 4 3 2

abstractlogic> range h
range h
[5]
# fifth
# fourth
# third
# second
# first

# Question 8
# Which one of the following, if substituted for the condition that motorbike
# servicing has to be earlier than laundry,

# remove `m < l`
abstractlogic> s, h, j, k, l, m ∈ unique [clear]
Clear Workspace
s, h, j, k, l, m ∈ unique    Feasible Outcomes: 720      Perceived Outcomes: 46656 ✓     :4 6 3 1 2 5

abstractlogic> s = h + 1; k < s; m = j + 1 ||| m = j - 1
s = h + 1        Feasible Outcomes: 120      Perceived Outcomes: 32400 ✓     :6 5 4 3 1 2
k < s            Feasible Outcomes: 60   Perceived Outcomes: 13824 ✓     :4 3 6 2 1 5
m = j + 1 ||| m = j - 1      Feasible Outcomes: 24   Perceived Outcomes: 11520 ✓     :5 4 2 1 6 3

# would have the same effect in
# determining the order of the student’s activities?

abstractlogic> preserve
Preserving State

abstractlogic> m < l
m < l            Feasible Outcomes: 12   Perceived Outcomes: 2025 ✓      :5 4 1 3 6 2

abstractlogic> export refset
  julia> refset = returnreplset()

abstractlogic> restore
  Restoring State - Feasible Outcomes: 24      Perceived Outcomes: 11520  :1 2 3 4 5 6

# Laundry has to be one of the last three activities.
bstractlogic> l >=4
l >=4            Feasible Outcomes: 12   Perceived Outcomes: 1296 ✓      :6 5 2 3 4 1

abstractlogic> compare refset
active set and refset have the same number of feasible values. nfeasible(replset) == nfeasible(refset)

# Laundry has to be either immediately before or immediately after jogging.
abstractlogic> restore
Restoring State - Feasible Outcomes: 24      Perceived Outcomes: 11520  :1 2 3 4 5 6

abstractlogic> l = j + 1 ||| l = j - 1
l = j + 1 ||| l = j - 1      Feasible Outcomes: 6    Perceived Outcomes: 600 ✓       :6 5 2 4 3 1

abstractlogic> compare refset
active set has less feasible values than refset. nfeasible(replset) < nfeasible(refset)

abstractlogic> restore
Restoring State - Feasible Outcomes: 24      Perceived Outcomes: 11520  :1 2 3 4 5 6

# Jogging has to be earlier than laundry.
abstractlogic> j < l
j < l            Feasible Outcomes: 12   Perceived Outcomes: 2025 ✓      :5 4 1 3 6 2

abstractlogic> compare refset
active set and refset have the same feasible values. replset[:] == refset[:]

abstractlogic> restore
Restoring State - Feasible Outcomes: 24      Perceived Outcomes: 11520  :1 2 3 4 5 6

# Laundry has to be earlier than hedge trimming.
abstractlogic> l < h
l < h            Feasible Outcomes: 16   Perceived Outcomes: 2304 ✓      :6 5 2 3 4 1

abstractlogic> compare refset
replset set has more feasible values than refset. nfeasible(replset) > nfeasible(refset)

abstractlogic> restore
Restoring State - Feasible Outcomes: 24      Perceived Outcomes: 11520  :1 2 3 4 5 6

# Laundry has to be earlier than jogging.
abstractlogic> l < j
l < j            Feasible Outcomes: 12   Perceived Outcomes: 2025 ✓      :4 3 6 2 1 5

abstractlogic> compare refset
replset set and refset have the same number of feasible values. nfeasible(replset) == nfeasible(refset)
