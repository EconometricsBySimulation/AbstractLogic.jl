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

# 1 If both G and S are reduced, W is also reduced.
abstractlogic> G, S = 'red' ==> W = 'red'

# 2 If N is reduced, neither R nor S is reduced.
abstractlogic> N = 'red' ==> R, S = 'not'

# 3 If P is reduced, L is not reduced.
abstractlogic> P = 'red' ==> L = 'not'

# 4 Of the three areas L, M, and R, exactly two are reduced.
abstractlogic> L|M|R = 'red' {2}

# Question 1
# If both M and R are reduced,
# Save state
abstractlogic> M, R = 'red'

# which one of the following is a pair of areas neither of which could be reduced?
# A. G, L
abstractlogic> all: G, L = 'not'

# B. G, N
abstractlogic> all: G, N = 'not'

# C. L, N
abstractlogic> all: L, N = 'not'
# D. L, P
abstractlogic> all: L, P = 'not'

# E. P, S
abstractlogic> all: P, S = 'not'

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

# 1. X cannot play first or second.
abstractlogic> X != 1,2

# 2. W cannot play until X has played.
abstractlogic> W > X

# 3. Neither T nor Y can play seventh.
abstractlogic> T,Y != 7

# 4. Either Y or Z must play immediately after W plays.
abstractlogic> Y|Z = W + 1

# 5. V must play either immediately after or immediately before U plays.
abstractlogic> V = U + 1 ||| V = U - 1

# Question 2
# If V plays first, which one of the following must be true?

# First lets save our state since Question 1 creates an addition constraint
# which we would like to reverse.
abstractlogic> export preserver

abstractlogic> V = 1

# A. T plays sixth.
abstractlogic> all: T = 6

# B. X plays third.
abstractlogic> all: X = 3

# C. Z plays seventh.
abstractlogic> all: Z = 7

# D. T plays immediately after Y.
abstractlogic> all: T = Y + 1

# E. W plays immediately after X.
abstractlogic> all: W = X + 1

# lets restore the previous state (we could also use the back command but that is more likely to lead to errors)
abstractlogic> import preserver

# Question 3
# If U plays third, what is the latest position in which Y can play?
abstractlogic> U = 3

# The fast answer is:
abstractlogic> range Y

# first
# second
# fifth
# sixth - true
# seventh

# Passage for Question 4
# A charitable foundation awards grants in exactly four areas—medical services,
# theater arts, wildlife preservation, and youth services—each grant being in
# one of these areas.
abstractlogic> q1.m, q1.t, q1.w, q1.y ∈ 0:1 [clear]
abstractlogic> q2.m, q2.t, q2.w, q2.y ∈ 0:1
abstractlogic> q3.m, q3.t, q3.w, q3.y ∈ 0:1
abstractlogic> q4.m, q4.t, q4.w, q4.y ∈ 0:1
# One or more grants are awarded in each of the four quarters of a calendar year.

abstractlogic> {{>=:q1.m,<=:q1.y}} == 1 {{1,}}
abstractlogic> {{>=:q2.m,<=:q2.y}} == 1 {{1,}}
abstractlogic> {{>=:q3.m,<=:q3.y}} == 1 {{1,}}
abstractlogic> {{>=:q4.m,<=:q4.y}} == 1 {{1,}}

# Additionally, over the course of a calendar year, the following must obtain:

# Grants are awarded in all four areas.
abstractlogic> {{j}}.m = 1 {{1,}}; {{j}}.t = 1 {{1,}}; {{j}}.w = 1 {{1,}}; {{j}}.y = 1 {{1,}}

# No more than six grants are awarded.
abstractlogic> {{i}} = 1 {{,6}}

# No grants in the same area are awarded in the same quarter or in consecutive quarters.
# Medical and theater arts
abstractlogic> {{j}}.m = 1 ==> {{j+1}}.m != 1; {{j}}.t = 1 ==> {{j+1}}.t != 1

# wildlife and youthservice
abstractlogic> {{j}}.w = 1 ==> {{j+1}}.w != 1; {{j}}.y = 1 ==> {{j+1}}.y != 1

# Exactly two medical services grants are awarded.
abstractlogic> {{j}}.m = 1 {{2}}

# A wildlife preservation grant is awarded in the second quarter.
abstractlogic> q2.w = 1

# Question 4
# If a wildlife preservation grant and a youth services grant are awarded in the
# same quarter of a particular calendar year, then any of the following could be
# true that year EXCEPT:
abstractlogic> export preserver

abstractlogic> {{j}}.w = 1 &&& {{j}}.y = 1 {{1,}}

# A. A medical services grant is awarded in the second quarter.
abstractlogic> any: q2.m = 1

# B. A theater arts grant is awarded in the first quarter.
abstractlogic> any: q1.t = 1

# C. A theater arts grant is awarded in the second quarter.
abstractlogic> any: q2.t = 1

# D. A wildlife preservation grant is awarded in the fourth quarter.
abstractlogic> any: q4.w = 1

# E. A youth services grant is awarded in the third quarter.
abstractlogic> any: q3.y = 1

# Passage for Questions 5 and 6
# From a group of seven people—J, K, L, M, N, P, and Q—exactly four will be selected
# to attend a diplomat’s retirement dinner. Selection conforms to the following conditions:
abstractlogic> J, K, L, M, N, P, Q ∈ 0:1 [clear]

abstractlogic> {{i}} = 1 {{4}}

# Either J or K must be selected, but J and K cannot both be selected.
abstractlogic> J ^ K

# Either N or P must be selected, but N and P cannot both be selected.
abstractlogic> N ^ P

# N cannot be selected unless L is selected.
abstractlogic> L! ==> N!

# Q cannot be selected unless K is selected.
abstractlogic> K! ==> !Q

# Question 5
abstractlogic> export preserver
# If P is not selected to attend the retirement dinner, then exactly how many
# different groups of four are there each of which would be an acceptable selection?
abstractlogic> P = 1
abstractlogic> show
# one
# two
# three
# four - we can see from the output that 4 is available
# five
abstractlogic> import preserver

# Question 6
# There is only one acceptable group of four that can be selected to attend the
# retirement dinner if which one of the following pairs of people is selected?

# J and L
abstractlogic> check: J == 1 &&& L == 1

# K and M
abstractlogic> check: K == 1 &&& M == 1

# L and N
abstractlogic> check: L == 1 &&& N == 1

# L and Q
abstractlogic> check: L == 1 &&& Q == 1

# M and Q
abstractlogic> check: M == 1 &&& Q == 1

# Explanation for Question 6
#
# Passage for Questions 7 and 8
# On a particular Saturday, a student will perform six activities—grocery
# shopping, hedge trimming, jogging, kitchen cleaning, laundry, and motorbike servicing.
# Each activity will be performed once, one at a time.
abstractlogic> s, h, j, k, l, m ∈ unique [clear]
# The order in which the activities are performed is subject to the following conditions:

# Grocery shopping has to be immediately after hedge trimming.
abstractlogic> s = h + 1

# Kitchen cleaning has to be earlier than grocery shopping.
abstractlogic> k < s

# Motorbike servicing has to be earlier than laundry.
abstractlogic> m < l

# Motorbike servicing has to be either immediately before or immediately after jogging.
abstractlogic> m = j + 1 ||| m = j - 1

# Question 7
# If laundry is earlier than kitchen cleaning, then hedge trimming must be

abstractlogic> l < k

abstractlogic> range h
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

abstractlogic> s = h + 1; k < s; m = j + 1 ||| m = j - 1

# would have the same effect in
# determining the order of the student’s activities?

abstractlogic> export preserver

abstractlogic> m < l

abstractlogic> export refset

abstractlogic> import preserver

# Laundry has to be one of the last three activities.
abstractlogic> l >=4

abstractlogic> compare refset

# Laundry has to be either immediately before or immediately after jogging.
abstractlogic> import preserver

abstractlogic> l = j + 1 ||| l = j - 1

abstractlogic> compare refset

abstractlogic> import preserver

# Jogging has to be earlier than laundry.
abstractlogic> j < l

abstractlogic> compare refset

abstractlogic> import preserver

# Laundry has to be earlier than hedge trimming.
abstractlogic> l < h

abstractlogic> compare refset

abstractlogic> import preserver

# Laundry has to be earlier than jogging.
abstractlogic> l < j

abstractlogic> compare refset
