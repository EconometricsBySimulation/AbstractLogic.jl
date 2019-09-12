# AbstractLogic.jl

Welcome to AbstractLogic documentation!

This resource aims at teaching you everything you will need for using the intuitive Abstract Logic problem solver in the Julia language.

## Introduction

### What is an abstract logic solver?

Abstract logic problems come in many forms. This solver specifically is built to handle verbal abstract logic problems which have a finite number of possible permutations. Verbal abstract reasoning problems are often found in cognitive testing environments such as employee aptitude testing and prominently as a section on the Law School Entrance Exam.

### Why an abstract logic solver?

The cost of hand writing and evaluating items can be expensive. Abstract logic items are easy to write but relatively hard to evaluate. This package goes a long way to reducing the cost of evaluating items and is intended as a tool to aid in the generation of large batches of abstract reasoning items.

The need for large batches of items stems from a great deal of interest by test takers in illegally obtaining copies of items from high stakes exams. Cheating on high stakes exams is known to be common. This forces testing companies to spend a great deal of resources protecting their intellectual capital while also creating an environment in which they finds themselves vulnerable to accusations of secrecy. Producing tools that reduce the cost of generating and evaluating items has the promise of alleviating concerns over item exposure.

In addition to the benefit to testing companies of reduced cost items, reducing the cost of items has the promise of aiding in the production of items for the use by researchers and companies interested in evaluating the efforts and aptitudes of their employees who do not have the means of producing their own instrument or of obtaining and providing a secure environment for the deployment of a commercial instrument.

### A Simple Example

A typical kind of problem which one might have encountered in an aptitude test at some point in ones life might look like the following.

```
Peter is younger than Susan. Sam is younger than Susan but older than Ali.
Li is older than Ali younger than Peter.

1. Who must be the oldest?
a) Peter b) Susan c) Sam d) Li e) Ali f) Cannot Tell

2. Who must be the youngest?
a) Peter b) Susan c) Sam d) Li e) Ali f) Cannot Tell

3. Who could be the same age as Li?
a) Peter b) Susan c) Sam d) Ali e) Nobody f) Cannot Tell
```

The package AbstractLogic provides a tool for easily evaluating such problems. First lets load in the feasible matches. Because there are 5 people in the problem we can assign them 5 age categories which represent cardinal ordered ages.

Let's input this problem into Abstract Logic syntax.

```julia
julia> using AbstractLogic
Start the repl in command prompt by typing `=`.

abstractlogic> Peter, Susan, Sam, Li, Ali ∈ 1, 2, 3, 4, 5 [clear]
Clear Workspace
Peter, Susan, Sam, Li, Ali ∈ 1, 2, 3, 4, 5       Feasible Outcomes: 3125         Perceived Outcomes: 3125 ✓      :1 3 4 1 1

abstractlogic> Peter < Susan; Sam < Susan

Peter < Susan            Feasible Outcomes: 1250         Perceived Outcomes: 2000 ✓      :1 2 2 1 2
Sam < Susan              Feasible Outcomes: 750          Perceived Outcomes: 1600 ✓      :1 2 1 5 4

abstractlogic> Sam > Ali; Li > Ali; Li < Peter

Sam > Ali                Feasible Outcomes: 175          Perceived Outcomes: 540 ✓       :1 5 3 4 1
Li > Ali                 Feasible Outcomes: 121          Perceived Outcomes: 432 ✓       :1 4 3 5 1
Li < Peter               Feasible Outcomes: 13   Perceived Outcomes: 48 ✓        :3 5 4 2 1
```

Now that we have input our constraints we can start asking our questions.

Question 1. Who must be the oldest?
```julia
abstractlogic> search {{i}} > {{!i}}
  Checking: Peter > Susan Checking: Peter > Sam ... Checking: Ali > Sam Checking: Ali > Li

:Peter is a not match with 0 feasible combinations out of 13.
:Susan is a match with 13 feasible combinations out of 13.
:Sam is a not match with 0 feasible combinations out of 13.
:Li is a not match with 0 feasible combinations out of 13.
:Ali is a not match with 0 feasible combinations out of 13.
```
From this we can see that Susan is the oldest.

Question 2. Who must be is the youngest?
To check who is the youngest we can do the same but this time setting
`verbose=false` to reduce the printing.

```julia
abstractlogic> search {{i}} < {{!i}}
  Checking: Peter < Susan Checking: Peter < Sam ... Checking: Ali < Sam Checking: Ali < Li

:Peter is a not match with 0 feasible combinations out of 13.
:Susan is a not match with 0 feasible combinations out of 13.
:Sam is a not match with 0 feasible combinations out of 13.
:Li is a not match with 0 feasible combinations out of 13.
:Ali is a match with 13 feasible combinations out of 13.
```
The search function returns a ratio of feasible outcomes for each column
relative to total outcomes. A zero means no feasible combination exist that
match while a 1 indicates a 100% match.

Question 3. Who could be the same age as Li?
```julia
abstractlogic> search {{i}} = Li
  Checking: Peter = Li Checking: Susan = Li ... Checking: Li = Li Checking: Ali = Li

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
You must call home at least once and at least three days after the last call.
Whatever you do on Fri must be different from what you do on Sat or Sun.
You must do homework at least one night on Monday, Tuesday, or Wednesday
You eat out at least twice per week.

Questions:
1. Given these constraints what is the most number of times you can work out each week?
a) two b) three c) four

2. If you do homework on Monday what must be true?
a) Friday you do not do homework
b) Wednesday you do not call home
c) Saturday you do not workout
d) Tuesday you do not workout

3. Which of the following must be true?
a) If you call home on Mon then your Tue and Fri activity must be the same.
b) If you call home on Tues then your Mon and Fri activity must be the same.
c) If you call home on Wed then your Mon and Sat activity must be the same.
d) If you call home on Fri then your Tues and Sun activity must be the same.
e) If you call home on Sat then your Mon and Wed activity must be the same.
```

Let's input this problem into Abstract Logic syntax.

```julia
julia> using AbstractLogic
Start the repl in command prompt by typing `=`.

abstractlogic> mo, tu, we, th, fr, sa, su ∈ call, gym, hmwk, eat [clear]
Clear Workspace
mo, tu, we, th, fr, sa, su ∈ call, gym, hmwk, eat        Feasible Outcomes: 16384        Perceived Outcomes: 16384 ✓     :eat hmwk eat eat call hmwk eat
```

You do homework at least twice a week

```julia
abstractlogic> {{i}} = 'hmwk' {{2,}}
{{i}} = 'hmwk' {{2,}}  >>> mo = 'hmwk' >>> tu = 'hmwk' ... >>> sa = 'hmwk' >>> su = 'hmwk' {{2,∞}}
         Feasible Outcomes: 9094         Perceived Outcomes: 16384 ✓     :eat call hmwk hmwk gym gym call
```

You work out at least twice a week

```julia
abstractlogic> {{i}} = 'gym' {{2,}}
{{i}} = 'gym' {{2,}}  >>> mo = 'gym' >>> tu = 'gym' ... >>> sa = 'gym' >>> su = 'gym' {{2,∞}}
         Feasible Outcomes: 4172         Perceived Outcomes: 16384 ✓     :gym hmwk hmwk eat gym eat gym
```

You do not work out on sequential days

```julia
abstractlogic>  {{i}} == 'gym' ==> {{i}} != {{i+1}}
{{i}} == 'gym' ==> {{i}} != {{i+1}}  >>> mo == 'gym' ==> mo != tu >>> tu == 'gym' ==> tu != we ... >>> fr == 'gym' ==> fr != sa >>> sa == 'gym' ==> sa != su
         Feasible Outcomes: 2302         Perceived Outcomes: 16384 ✓     :gym call hmwk eat hmwk call gym
```

You only eat out if the next day you work out. The `!` in `{{i+1!}}` tells the spawner to swap `OUTOFBOUNDS` with 999 for comparison purposes.

```julia
abstractlogic> {{i}} = 'eat' ==> {{i+1!}} = 'gym'
{{i}} = 'eat' ==> {{i+1!}} = 'gym'  >>> mo = 'eat' ==> tu = 'gym' >>> tu = 'eat' ==> we = 'gym' ... >>> sa = 'eat' ==> su = 'gym' >>> su = 'eat' ==> 999 = 'gym'
         Feasible Outcomes: 936          Perceived Outcomes: 12288 ✓     :call gym hmwk gym hmwk hmwk gym
```

Since the week ends on Sunday we cannot count on working out on Monday. This constraint is redundant since this has already been restricted from the `!` in the last expression.

```julia
abstractlogic> su != 'eatout'
su != 'eatout'           Feasible Outcomes: 936          Perceived Outcomes: 12288 ✓     :hmwk gym hmwk call call hmwk gym
```

You must call home at least once and any follow up calls have to be three after the last call.

```julia
abstractlogic> {{i}} = 'call' {{1,}}; {{i}} = 'call' ==> {{<i+3,>i}} != 'call'

{{i}} = 'call' {{1,}}  >>> mo = 'call' >>> tu = 'call' ... >>> sa = 'call' >>> su = 'call' {{1,∞}}
         Feasible Outcomes: 830          Perceived Outcomes: 12288 ✓     :gym call gym hmwk call call hmwk
{{i}} = 'call' ==> {{<i+3,>i}} != 'call'  >>> mo = 'call' ==> tu != 'call' >>> mo = 'call' ==> we != 'call' ... >>> fr = 'call' ==> su != 'call' >>> sa = 'call' ==> su != 'call'
         Feasible Outcomes: 496          Perceived Outcomes: 12288 ✓     :call gym hmwk hmwk hmwk gym hmwk
```

Let's check if that least command is doing what we expect. Lets restrict ourselves to the cases in which we call home at least twice.

```julia
abstractlogic> {{i}} = 'call' {{2,}}
{{i}} = 'call' {{2,}}  >>> mo = 'call' >>> tu = 'call' ... >>> sa = 'call' >>> su = 'call' {{2,∞}}
         Feasible Outcomes: 176          Perceived Outcomes: 12288 ✓     :call hmwk gym hmwk call gym hmwk
```

Let's see what they look like. Yeap, none of them feature calls closer than 3 days apart.

```julia
abstractlogic> show
  Showing 10 of 176 rows

 mo  tu   we   th   fr   sa   su
–––– ––– –––– –––– –––– –––– ––––
call gym hmwk call gym  hmwk call
call gym hmwk call gym  hmwk gym
call gym hmwk call gym  hmwk hmwk
call gym hmwk call hmwk gym  call
call gym hmwk call hmwk gym  hmwk
 ⋮    ⋮   ⋮    ⋮    ⋮    ⋮    ⋮
eat  gym call hmwk gym  hmwk call
eat  gym call hmwk hmwk call gym
eat  gym call hmwk hmwk gym  call
eat  gym hmwk call gym  hmwk call
eat  gym hmwk call hmwk gym  call
```

```julia
abstractlogic> back
Last command: "{{i}} = 'call' {{1,}}; {{i}} = 'call' ==> {{<i+3,>i}} != 'call'" - Feasible Outcomes: 496         Perceived Outcomes: 12288      :call call gym gym hmwk hmwk hmwk
```

Whatever you do on Friday must be different from what you do on Saturday or Sunday.

```julia
abstractlogic> fr != sa, su
fr != sa, su             Feasible Outcomes: 319          Perceived Outcomes: 12288 ✓     :gym call hmwk hmwk hmwk gym call
```

You must do homework at least one night on Monday, Tuesday, or Wednesday

```julia
abstractlogic> mo | tu | we = 'hmwk'
mo | tu | we = 'hmwk'    Feasible Outcomes: 278          Perceived Outcomes: 12288 ✓     :call hmwk gym eat gym hmwk hmwk
```

Would like to eat out at least twice per week.

```julia
abstractlogic> {{i}} = 'eat' {{2,}}
{{i}} = 'eat' {{2,}}  >>> mo = 'eat' >>> tu = 'eat' ... >>> sa = 'eat' >>> su = 'eat' {{2,∞}}
         Feasible Outcomes: 18   Perceived Outcomes: 6912 ✓      :eat gym hmwk eat gym hmwk call
```

Now for us to address the questions:
```julia
abstractlogic> silence
Silencing REPL print. Reverse with command 'noisy'
```
---

Question 1. Given these constraints what is the most number of times you can work out each week?

a) two b) three c) four

```julia
abstractlogic> check: {{i}} = 'gym' {{2}}
true
```
---

Question 2. If you do homework on Monday what must be true?

First we will preserve the current state of the data so that we can reverse the preserve.
```julia
abstractlogic> preserve
Preserving State

abstractlogic> mo = 'hmwk'
```

a) Tuesday you do not eat out
```julia
abstractlogic> prove: tu != 'eat'
false
```

b) Wednesday you do not call home
```julia
abstractlogic> prove: we != 'call'
true
```

c) Friday you do not do homework
```julia
abstractlogic> prove: fr != 'hmwk'
false
```

d) Saturday you do not workout
```julia
abstractlogic> prove: sa != 'gym'
false
```

Return to the state before requiring us to do homework on Monday.
```julia
abstractlogic> restore
Restoring State - Feasible Outcomes: 18          Perceived Outcomes: 6912       :call eat eat gym gym hmwk hmwk
```
---

Question 3. Which of the following must be true?
a) If you call home on Monday then your Tuesday and Friday activity must be the same.
```julia
abstractlogic> prove: mo == 'call' ==> tu == fr
false
```

b) If you call home on Tuesday then your Monday and Friday activity must be the same.

```julia
abstractlogic> prove: tu == 'call' ==> mo == fr
false
```

c) If you call home on Wednesday then your Monday and Saturday activity must be the same.

```julia
abstractlogic> prove: we == 'call' ==> mo == sa
true
```

d) If you call home on Friday then your Tuesday and Sunday activity must be the same.

```julia
abstractlogic> prove: fr == 'call' ==> tu == su
false
```

e) If you call home on Saturday then your Monday and Wednesday activity must be the same.

```julia
abstractlogic> prove: sa == 'call' ==> mo == we
false
```
