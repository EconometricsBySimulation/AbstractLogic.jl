# AbstractLogic.jl

Welcome to AbstractLogic documentation!

This resource aims at teaching you everything you will need for using
the intuitive Abstract Logic problem solver in the Julia language.

## Introduction

### What is an abstract logic solver?

Abstract logic problems come in many forms. This solver specifically is built
to handle verbal abstract logic problems which have a finite number of possible
permutations. A typical kind of problem which one might have encountered
in an aptitude test at some point in ones life might look like the following.

### A Simple Example

```
Peter is younger than Susan. Sam is younger than Susan but older than Ali.
Li is older than Ali younger than Peter.

Who must be the oldest?
a) Peter b) Susan c) Sam d) Li e) Ali f) Cannot Tell

Who must be the youngest?
a) Peter b) Susan c) Sam d) Li e) Ali f) Cannot Tell

Who could be the same age as Li?
a) Peter b) Susan c) Sam d) Ali e) Nobody f) Cannot Tell
```

The package AbstractLogic provides a tool for easily evaluating such problems.
First lets load in the feasible matches. Because there are 5 people in the
problem we can assign them 5 age categories which represent cardinal ordered
ages rather than
```jldoctest
julia> myls = logicalparse(["Peter, Susan, Sam, Li, Ali ∈ 1, 2, 3, 4, 5"])
Peter, Susan, Sam, Li, Ali ∈ 1, 2, 3, 4, 5       feasible outcomes 3125 ✓        :4 2 4 3 4

julia> myls = logicalparse("Peter < Susan; Sam < Susan", myls)
Peter < Susan            feasible outcomes 1250 ✓        :2 3 3 4 4
Sam < Susan              feasible outcomes 750 ✓         :4 5 4 5 4

myls = logicalparse("Sam > Ali; Li > Ali; Li < Peter", myls)
Sam > Ali                feasible outcomes 175 ✓         :1 3 2 3 1
Li > Ali                 feasible outcomes 121 ✓         :4 5 2 5 1
Li < Peter               feasible outcomes 13 ✓          :4 5 4 3 2

julia> search("{{i}} > {{!i}}", myls)
Checking: Peter > Susan
Checking: Peter > Sam
Checking: Peter > Li
Checking: Peter > Ali
Checking: Susan > Peter
Checking: Susan > Sam
Checking: Susan > Li
Checking: Susan > Ali
Checking: Sam > Peter
Checking: Sam > Susan
Checking: Sam > Li
Checking: Sam > Ali
Checking: Li > Peter
Checking: Li > Susan
Checking: Li > Sam
Checking: Li > Ali
Checking: Ali > Peter
Checking: Ali > Susan
Checking: Ali > Sam
Checking: Ali > Li

:Peter is a not match with 0 feasible combinations out of 13.
:Susan is a match with 13 feasible combinations out of 13.
:Sam is a not match with 0 feasible combinations out of 13.
:Li is a not match with 0 feasible combinations out of 13.
:Ali is a not match with 0 feasible combinations out of 13.
```
From this we can see that Susan is the oldest.

`Who must be is the youngest?`
To check who is the youngest we can do the same but this time setting
`verbose=false` to reduce the printing.
```jldoctest
julia> search("{{i}} < {{!i}}", myls, verbose=false)
5-element Array{Float64,1}:
 0.0
 0.0
 0.0
 0.0
 1.0
 ```
The search function returns a ratio of feasible outcomes for each column
relative to total outcomes. A zero means no feasible combination exist that
match while a 1 indicates a 100% match.

`Who could be the same age as Li?`
```julia
julia> search("{{i}} = Li", myls)
Checking: Peter = Li
Checking: Susan = Li
Checking: Sam = Li
Checking: Li = Li
Checking: Ali = Li

:Peter is a not match with 0 feasible combinations out of 13.
:Susan is a not match with 0 feasible combinations out of 13.
:Sam is a possible match with 5 feasible combinations out of 13.
:Li is a match with 13 feasible combinations out of 13.
:Ali is a not match with 0 feasible combinations out of 13.
 ```
From the results we can see that Sam could share ages with Li.

But Abstract Logic can handle problems much more complex then simple
inequalities!

### A More Complex Example
```
You would like to figure out your plans for the evenings this week. Each evening
can do only one activity at most. There are only four options for what you can do
each night: call home, work out, homework, or eat out with friends.
Each week begins on Monday and ends on Sunday.

Your schedule is subject to the following constraints:
You do homework at least twice a week
You work out at least twice a week
You do not work out on sequential days
You only eat out if the next day you work out.
You must call home at least once and at least three after the last call.
Whatever you do on Friday must be different from what you do on Saturday or Sunday.
You must do homework at least one night on Monday, Tuesday, or Wednesday
You would like to eat out at least twice per week.

Questions:
1. Given these constraints what is the most number of times you can work out each week?
a) two b) three c) four

2. If you do homework on Monday what must be true?
a) Friday you do not do homework
b) Wednesday you do not call home
c) Saturday you do not workout
d) Tuesday you do not workout

3. Which of the following must be true?
a) If you call home on Monday then your Tuesday and Friday activity must be the same.
b) If you call home on Tuesday then your Monday and Friday activity must be the same.
c) If you call home on Wednesday then your Monday and Saturday activity must be the same.
d) If you call home on Friday then your Tuesday and Sunday activity must be the same.
e) If you call home on Saturday then your Monday and Wednesday activity must be the same.
```

Let's input this problem into Abstract Logic syntax.
```julia
julia> myls = logicalparse(["mo, tu, we, th, fr, sa, su ∈ callhome, work out, homework, eat out"])
#... feasible outcomes 16384 ✓       :workout workout workout eatout callhome callhome callhome

# You do homework at least twice a week
julia> myls = logicalparse(["{{i}} = 'homework' {{2,}}"], myls)
#... feasible outcomes 9094 ✓        :callhome eatout eatout homework workout homework workout

# You work out at least twice a week
myls = logicalparse(["{{i}} = 'workout' {{2,}}"], myls)
#... feasible outcomes 4172 ✓        :callhome eatout workout workout eatout homework homework

# You do not work out on sequential days
myls = logicalparse(["{{i}} == 'workout' ==> {{i}} != {{i+1}}"], myls)
# >>> mo == 'workout' ==> tu != 'workout'
# ...
# >>> sa == 'workout' ==> su != 'workout'
# ... feasible outcomes 2302 ✓        :workout homework eatout workout homework callhome homework

# You only eat out if the next day you work out.
myls = logicalparse(["{{i}} = 'eatout' ==> {{i+1}} = 'workout'"], myls)
# >>> mo = 'eatout' ==> tu = 'workout'
# ... feasible outcomes 1141 ✓        :eatout workout homework homework workout homework eatout

# Since the week ends on Sunday we cannot count on working out on Monday
myls = logicalparse(["su != 'eatout'"], myls)
# ... feasible outcomes 936 ✓         :callhome workout homework homework callhome eatout workout

# You must call home at least once and at least three after the last call.
myls = logicalparse(
  ["{{i}} = 'callhome' {{1,}}",
  "{{i}} = 'callhome' ==> {{i+1}} != 'callhome'",
  "{{i}} = 'callhome' ==> {{i+2}} != 'callhome'"], myls)
# ... feasible outcomes 496 ✓         :callhome workout homework homework homework workout homework

# Whatever you do on Friday must be different from what you do on Saturday or Sunday.
myls = logicalparse(["fr != sa, su"], myls)
# ... feasible outcomes 319 ✓         :homework callhome workout eatout workout homework callhome

# You must do homework at least one night on Monday, Tuesday, or Wednesday
myls = logicalparse(["mo | tu | we = 'homework'"], myls)
# ... feasible outcomes 278 ✓         :workout callhome homework homework callhome workout homework

# Would like to eat out at least twice per week.
myls = logicalparse(["{{i}} = 'eatout' {{2,}}"], myls)
```

Now for us to address the questions:
```julia
# Question 1
# Given these constraints what is the most number of times you can work out each week?
# a) two b) three c) four
checkfeasible("{{i}} = 'workout' {{2}}", myls)
# true, 18 out of 18 possible combinations 'true'.
# We could check the others but we know that in all 18 feasible permutations
# you can only work out twice a week.

# Question 2
# If you do homework on Monday what must be true?
mylssub = logicalparse(["mo = 'homework'"], myls)

# a) Tuesday you do not eat out
checkfeasible("tu != 'eatout'", mylssub, force=true)
# Check: tu != 'eatout' ... false, 4 out of 10 possible combinations 'true'.

# b) Wednesday you do not call home
checkfeasible("we != 'callhome'", mylssub, force=true)
#... true, 10 out of 10 possible combinations 'true'.

# c) Friday you do not do homework
checkfeasible("fr != 'homework'", mylssub, force=true)
# ... false, 8 out of 10 possible combinations 'true'.

# d) Saturday you do not workout
checkfeasible("sa != 'workout'", mylssub, force=true)
# ... false, 6 out of 10 possible combinations 'true'.

# Question 3
# Which of the following must be true?
# a) If you call home on Monday then your Tuesday and Friday activity must be the same.
checkfeasible("mo == 'callhome' ==> tu == fr", myls, force=true)
# ... false, 17 out of 18 possible combinations 'true'.

# b) If you call home on Tuesday then your Monday and Friday activity must be the same.
checkfeasible("tu == 'callhome' ==> mo == fr", myls, force=true)
# ... false, 17 out of 18 possible combinations 'true'.

# c) If you call home on Wednesday then your Monday and Saturday activity must be the same.
checkfeasible("we == 'callhome' ==> mo == sa", myls, force=true)
# ... true, 18 out of 18 possible combinations 'true'.

# d) If you call home on Friday then your Tuesday and Sunday activity must be the same.
checkfeasible("fr == 'callhome' ==> tu == su", myls, force=true)
# ... false, 16 out of 18 possible combinations 'true'.

# e) If you call home on Saturday then your Monday and Wednesday activity must be the same.
checkfeasible("sa == 'callhome' ==> mo == we", myls, force=true)
# ... false, 16 out of 18 possible combinations 'true'.
```
