# LSAT 2007 Analytical Reasoning
LSAC JUNE 2007 Form 8LSN75
([Source - LSAC.org](
https://www.lsac.org/sites/default/files/legacy/docs/default-source/jd-docs/sampleptjune.pdf))

# Questions 1-5

### Setup
A company employee generates a series of five-digit product
codes in accordance with the following rules:
The codes use the digits 0, 1, 2, 3, and 4, and no others.

```julia
julia> using AbstractLogic
```
Start the repl in command prompt by typing `=`.

unique forces each value to be different
```
abstractlogic> a, b, c, d, e  ∈  0:4 || unique [clear]
```

The second digit has a value exactly twice that of the first digit.
```
abstractlogic> b == a*2
```

The value of the third digit is less than the value of the fifth digit
```
abstractlogic> c < e
```

### Question 1.
If the last digit of an acceptable product code is 1...
(which of the following has must be true N out of N cases).

**A)** first digit is 2
```
abstractlogic> prove: e == 1 ==> a==2
```
Returns true: 6 of 6 possible.

**B)** second digit is 0
```
abstractlogic> prove: e == 1 ==> b==0
```
False: 5 out of 6

**C)** third digit is 3
```
abstractlogic> prove: e == 1 ==> c==3
```
False: 5 out of 6

**D)** fourth digit is 4
```
abstractlogic> prove: d == 1 ==> d==4
```
False: 5 out of 6

**E)** fourth digit is 0
```
abstractlogic> prove: d == 1 ==> d==0
```
False: 5 out of 6


### Question 2
Which one of the following must be true about any
acceptable product code?
```
abstractlogic> range
```

**A)** The digit 1 appears in some position before the digit 2.
```
abstractlogic> prove: {{i}} == 1 &&& {{>i}} == 2 {{1}}
```
False: only 3 of 6

**B)** The digit 1 appears in some position before the digit 3.
```
abstractlogic> prove: {{i}} == 1 &&& {{>i}} == 3 {{1}}
```
False: only 5 of 6

**C)** The digit 2 appears in some position before the digit 3.
```
abstractlogic> prove: {{i}} == 2 &&& {{>i}} == 3 {{1}}
```
True! 6 of 6

**D)** The digit 3 appears in some position before the digit 0.
```
abstractlogic> prove: {{i}} == 0 &&& {{>i}} == 3 {{1}}
```
False: only 5 of 6

**E)** The digit 4 appears in some position before the digit 3.
```
abstractlogic> prove: {{i}} == 4 &&& {{>i}} == 3 {{1}}
```
False: only 4 of 6

### Question 3.
If the third digit of an acceptable product code is not 0, which one of the following must be true?

**A)** The second digit of the product code is 2.
```
abstractlogic> prove: c != 0 ==> b == 2
```
False: only 5 of 6

**B)** The third digit of the product code is 3.
```
abstractlogic> prove: c != 0 ==> b == 2
```
False: only 5 of 6

**C)** The fourth digit of the product code is 0.
```
abstractlogic> prove: c != 0 ==> d == 0
```
True! 6 of 6

**D)** The fifth digit of the product code is 3. <true>
```
abstractlogic> prove: c != 0 ==> e == 3
```
False: 5 of 6

**E)** The fifth digit of the product code is 1.
```
abstractlogic> prove: c != 0 ==> e == 1
```
False: 4 of 6

### Question 4.
Any of the following pairs could be the third and fourth digits, respectively, of an acceptable product code, EXCEPT:

**A)** 0, 1
```
abstractlogic> any: c == 0 &&& d == 1
```
Possible 1 of 6

**B)** 0, 3
```
abstractlogic> any: c == 0 &&& d == 3
```
Possible 2 of 6

**C)** 1, 0
```
abstractlogic> any: c == 1 &&& d == 0
```
Possible 1 of 6

**D)** 3, 0
```
abstractlogic> any: c == 3 &&& d == 0
```
Possible 1 of 6

**E)** 3, 4
```
abstractlogic> any: c == 3 &&& d == 4
```
False! 0 of 6

### Question 5
Which one of the following must be true about any acceptable product code?

**A)** There is exactly one digit between the digit 0 and the digit 1.
```
abstractlogic> prove: {{i}} == 1|0 ==> {{i+2}} == 1|0
```
False 1 of 6 outcomes

**B)** There is exactly one digit between the digit 1 and the digit 2.
```
abstractlogic> prove: {{i}} == 1|2 ==> {{i+2}} == 1|2
```
False 0 of 6 outcomes

**C)** There are at most two digits between the digit 1 and the digit 3.
```
abstractlogic> prove: {{i}} == 1|3 ==> {{i+4}} != 1,3
```
False 5 out of 6 outcomes true

**D)** There are at most two digits between the digit 2 and the digit 3.
```
abstractlogic> prove: {{i}} == 2|3 ==> {{i+4}} != 2,3
```
False 4 out of 6 outcomes feasible

**E)** There are at most two digits between the digit 2 and the digit 4.
```
abstractlogic> prove: {{i}} == 2|4 ==> {{i+4}} != 2,4
```
True 6 out of 6 outcomes feasible

# Questions 6-10

### Setup

Exactly three films—Greed, Harvest, and Limelight—are
shown during a film club’s festival held on Thursday, Friday,
and Saturday. Each film is shown at least once during the
festival but never more than once on a given day. On each day
at least one film is shown. Films are shown one at a time.

```
julia> using AbstractLogic
```
Start the repl in command prompt by typing `=`.

**Coding The Problem**
* Three films Greed, Harvest, and Limelight as well as _ no film
* t1 is the first film, t2 the second, and t3 are the last film on Thursday
* f1, f2, f3 and s1, s2, s3 are similarly coded for Friday and Saturday
```
abstractlogic> t.1, t.2, t.3, f.1, f.2, f.3, s.1, s.2, s.3  ∈  _, Greed, Harvest, Limelight [clear]
```

**The following conditions apply:**
* On each day at least one film is shown. Since 3 is last slot then .3 can't be empty.
```
abstractlogic> {{j}}.3 != '_'
```

Let's impose the structural constraint that the highest number 3 is the
last film shown. Thus
```
abstractlogic> {{j}}.1 != '_' ==> {{j}}.2 != '_'
```

Each film is shown at least once during the festival
```
abstractlogic> {{i}} == 'Greed' {{1,}}
abstractlogic> {{i}} == 'Harvest' {{1,}}
abstractlogic> {{i}} == 'Limelight' {{1,}}
```

Never more than once on a given day. If t1 does not equal '\_' then t1 != t2.
Since we know that t3 can't be '\_' then we can assert that t2 != t3
```
abstractlogic> {{j}}.1 != '_' ==> {{j}}.1 != {{j}}.2 &&& {{j}}.1 != {{j}}.3 &&& {{j}}.2 != {{j}}.3
```

On Thursday Harvest is shown, and no film is shown after it on that day
```
abstractlogic> t.3 = 'Harvest'
```

On Friday either Greed or Limelight, but not both, and no film is
shown after it on that day.
```
abstractlogic> f.3 = 'Greed'|'Limelight'; f.2,f.1 != 'Greed','Limelight'
```

On Saturday either Greed or Harvest, but not both, is shown, and no film is
shown after it on that day.
```
abstractlogic> s.3 = 'Greed'|'Harvest'; s.1,s.2 != 'Greed','Harvest'
```

```
abstractlogic> export lsat3
```

### Question 6.
Which one of the following could be a complete and accurate description of
the order in which the films are shown at the festival?

**A)** Thursday: Limelight, then Harvest; Friday: Limelight; Saturday: Harvest
```
abstractlogic> check t.2 = 'Limelight' ; t.3 = 'Harvest' ; f.3 = 'Limelight' ; s.3 = 'Harvest' ; t.1,f.2,f.1,s.2,s.1='_'
```
false 0 out of 64 possible combinations true

**B)** Thursday: Harvest; Friday: Greed, then Limelight; Saturday: Limelight, then Greed
```
abstractlogic> check t.3 = 'Harvest' ; f.2 = 'Greed' ; f.3 = 'Limelight' ; s.2 = 'Limelight' ; s.3 = 'Greed'
```
false 0 out of 64 possible combinations true

**C)** Thursday: Harvest; Friday: Limelight; Saturday: Limelight, then Greed
```
abstractlogic> check t.3 = 'Harvest' ; f.3 = 'Limelight' ; s.2 = 'Limelight' ; s.3 = 'Greed'; t.1, t.2, f.1, f.2, s.1='_'
```
true 1 out of 64 possible combinations true

**D)** Thursday: Greed, then Harvest, then Limelight; Friday: Limelight; Saturday: Greed
```
abstractlogic> check t.1 = 'Greed' ; t.2 = 'Harvest' ; t.3 = 'Limelight' ; f.3 = 'Limelight' ; s.3 = 'Greed'
```
false, 0 out of 64 possible combinations 'true'.

**E)** Thursday: Greed, then Harvest; Friday: Limelight, then Harvest; Saturday: Harvest
```
abstractlogic> check t.2 = 'Greed' ; t.3 = 'Harvest' ; f.2 = 'Limelight' ; f.3 = 'Harvest' ; s.3 = 'Harvest'
```
false, 0 out of 64 possible combinations 'true'.


### Question 7.
Which one of the following CANNOT be true?

**A)** Harvest is the last film shown on each day of the festival.
```
abstractlogic> check t.3,f.3,s.3 = 'Harvest'
```
false, 0 out of 64 possible combinations 'true'

**B)** Limelight is shown on each day of the festival.
```
abstractlogic> any {{i}} == 'Limelight' {{3,}}
```
true,  10 out of 72 possible combinations 'true'.

**C)** Greed is shown second on each day of the festival.
```
abstractlogic> any f.1,f.2,f.3 |= 'Greed'
```
true,  32 out of 72 possible combinations 'true'

**D)** A different film is shown first on each day of the festival.
This will be a little trickier. Define .0 as first film

```
abstractlogic> t.0, f.0, s.0 ∈ Greed, Harvest, Limelight
abstractlogic> {{j}}.0 == {{j}}.1 if {{j}}.1 != '_'
abstractlogic> {{j}}.1 == '_' &&& {{j}}.2 != '_' ==> {{j}}.0 == {{j}}.2
abstractlogic> {{j}}.2 == '_' ==> {{j}}.0 == {{j}}.3
abstractlogic> check t.0 != f.0, s.0 ; f.0 != s.0
abstractlogic> import lsat3
```

possible,  19 out of 64 possible combinations 'true'.

**E)** A different film is shown last on each day of the festival.
```
abstractlogic> check t.3, f.3 != s.3; t.3 != f.3
```
possible,  24 out of 74 possible combinations 'true'.

If Limelight is never shown again during the festival once Greed is shown,
```
abstractlogic> {{i}} = 'Greed' ==> {{>i}} != 'Limelight'
```

### Question 8.
Which one of the following is the maximum number of film showings that could
occur during the festival?
**A)** three
```
abstractlogic> any: {{i}} != '_' {{3}}
```
true

**B)** four
```
abstractlogic> any: {{i}} != '_' {{4}}
```
true

**C)** five
```
abstractlogic> any: {{i}} != '_' {{5}}
```
true

**D)** six
```
abstractlogic> any: {{i}} != '_' {{6}}
```
true
* Answer

**E)** seven
```
abstractlogic> any: {{i}} != '_' {{7}}
```
false

### Question 9.
If Greed is shown exactly three times, Harvest is shown exactly twice, and
Limelight is shown exactly once, then which one of the following must be true?
```
abstractlogic> import lsat3
abstractlogic> {{i}} = 'Greed' {{3}}; {{i}} = 'Harvest' {{2}}; {{i}} = 'Limelight' {{1}}
```

**A)** All three films are shown on Thursday.
```
abstractlogic> prove: t.1 != '_'
```
false, 2 out of 3 possible combinations 'true'.

**B)** Exactly two films are shown on Saturday.
```
abstractlogic> prove: s.1 = '_'
```
true, 3 out of 3 possible combinations 'true'.

**C)** Limelight and Harvest are both shown on Thursday.
```
abstractlogic> prove: t.1,t.2,t.3 |= 'Limelight'; t.1,t.2,t.3 |= 'Harvest'
```
false, 2 out of 3 possible combinations 'true'.

**D)** Greed is the only film shown on Saturday.
```
abstractlogic> prove: s.1,s.2 != '_'; s.3 = 'Greed'
```
false, 0 out of 3 possible combinations 'true'.

**E)** Harvest and Greed are both shown on Friday
```
abstractlogic> prove: s.1,s.2,s.3 |= 'Harvest'; s.1,s.2,s.3 |= 'Greed'
```
false, 0 out of 3 possible combinations 'true'.


### Question 10.
If Limelight is shown exactly three times, Harvest is shown exactly twice, and
Greed is shown exactly once...
```
abstractlogic> import lsat3
abstractlogic> {{i}} = 'Limelight' {{3}}; {{i}} = 'Harvest' {{2}}; {{i}} = 'Greed' {{1}}
```

Reintroduce first film
```
abstractlogic> t.0, f.0, s.0 ∈ Greed, Harvest, Limelight
abstractlogic> {{j}}.0 == {{j}}.1 if {{j}}.1 != '_'
abstractlogic> {{j}}.2 != '_' &&& {{j}}.1 == '_' ==> {{j}}.0 == {{j}}.2
abstractlogic> {{j}}.2 == '_' ==> {{j}}.0 == {{j}}.3
```
Order of operations helps here as the &&& block is evaluated before the if operator

then which one of the following is a complete and accurate list of the films
that could be the first film shown on Thursday?
```
abstractlogic> range t.1
```
Greed, Limelight

**A)** Harvest
**B)** Limelight
**C)** Greed, Harvest
**D)** Greed, Limelight
**E)** Greed, Harvest, Limelight

# Questions 11-17

### Setup
A cruise line is scheduling seven week-long voyages for the ship Freedom.
* Each voyage will occur in exactly one of the first seven weeks of the season:
weeks 1 through 7.
* Each voyage will be to exactly one of four destinations: Guadeloupe, Jamaica, Martinique, or Trinidad. Each destination will be scheduled

```
julia> using AbstractLogic
```
Start the repl in command prompt by typing `=`.

**Contraints**
for at least one of the weeks. The following conditions apply to Freedom’s schedule:
exactly one of four destinations: Guadeloupe, Jamaica, Martinique, or Trinidad
```
abstractlogic> w1, w2, w3, w4, w5, w6, w7  ∈ Guadeloupe, Jamaica, Martinique, Trinidad [clear]
```

Each destination will be scheduled for at least one of the weeks.
```
abstractlogic> {{i}} = 'Guadeloupe' {{1,}}
abstractlogic> {{i}} = 'Jamaica' {{1,}}
abstractlogic> {{i}} = 'Martinique' {{1,}}
abstractlogic> {{i}} = 'Trinidad' {{1,}}
```

Jamaica will not be its destination in week 4.
```
abstractlogic> w4 != 'Jamaica'
```

Trinidad will be its destination in week 7.
```
abstractlogic> w7 = 'Trinidad'
```

Freedom will make exactly two voyages to Martinique,
```
abstractlogic> {{i}} = 'Martinique' {{2}}
```

and at least one voyage to Guadeloupe will occur in some week between those two voyages.
Unfortunately this can be a bit tedious.
```
abstractlogic> {{<i}} = 'Martinique' &&& {{>i}} = 'Martinique' &&& {{i}} = 'Guadeloupe' {{1,}}
```

Guadeloupe will be its destination in the week preceding any voyage it makes to Jamaica.
```
abstractlogic> {{i!}} = 'Jamaica' ==> {{i-1}} = 'Guadeloupe'
```

No destination will be scheduled for consecutive weeks.
```
abstractlogic> {{i}} != {{i+1}}
```
* Save the current state
```
abstractlogic> export lsat4
```
### Question 11.
Which one of the following is an acceptable schedule of destinations for
Freedom, in order from week 1 through week 7?

**A)** Guadeloupe, Jamaica, Martinique, Trinidad, Guadeloupe, Martinique, Trinidad
I'll just check the first 4 weeks at first
```
abstractlogic> check w1 = 'Guadeloupe'; w2 = 'Jamaica'; w3 = 'Martinique'; w4 = 'Trinidad'; w5 = 'Guadeloupe'; w6 = 'Martinique'; w7 = 'Trinidad'
```
true, 1 out of 50 possible combinations 'true'.

**B)** Guadeloupe, Martinique, Trinidad, Martinique, Guadeloupe, Jamaica, Trinidad
```
abstractlogic> check w1 = 'Guadeloupe'; w2 = 'Martinique'; w3 = 'Trinidad'; w4 = 'Martinique'; w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Trinidad'
```
false, 0 out of 50 possible combinations 'true'.

**C)** Jamaica, Martinique, Guadeloupe, Martinique, Guadeloupe, Jamaica, Trinidad
```
abstractlogic> check w1 = 'Jamaica'; w2 = 'Martinique'; w3 = 'Guadeloupe'; w4 = 'Martinique'; w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Trinidad'
```
false, 0 out of 50 possible combinations 'true'.

**D)** Martinique, Trinidad, Guadeloupe, Jamaica, Martinique, Guadeloupe, Trinidad
```
abstractlogic> check w1 = 'Martinique'; w2 = 'Trinidad'; w3 = 'Guadeloupe'; w4 = 'Jamaica'; w5 = 'Martinique'; w6 = 'Guadeloupe'; w7 = 'Trinidad'
```
false, 0 out of 50 possible combinations 'true'.

**E)** Martinique, Trinidad, Guadeloupe, Trinidad, Guadeloupe, Jamaica, Martinique
```
abstractlogic> check w1 = 'Martinique'; w2 = 'Trinidad'; w3 = 'Guadeloupe'; w4 = 'Trinidad'; w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Martinique'
```
false, 0 out of 50 possible combinations 'true'.


### Question 12.
Which one of the following CANNOT be true about Freedom’s schedule of voyages?
**A)** Freedom makes a voyage to Trinidad in week 6
```
abstractlogic> check w6 = 'Trinidad'
```
false, 0 out of 50 possible combinations 'true'.  - Answer

**B)** Freedom makes a voyage to Martinique in week 5.
```
abstractlogic> check w5 = 'Martinique'
```
possible,  11 out of 25 possible combinations 'true'.

**C)** Freedom makes a voyage to Jamaica in week 6.
```
abstractlogic> check w6 = 'Jamaica'
```
possible,  3 out of 25 possible combinations 'true'.

**D)** Freedom makes a voyage to Jamaica in week 3.
```
abstractlogic> check w3 = 'Jamaica'
```
possible,  8 out of 25 possible combinations 'true'.

**E)** Freedom makes a voyage to Guadeloupe in week 3
```
abstractlogic> check w3 = 'Guadeloupe'
```
possible,  4 out of 25 possible combinations 'true'.


### Question 13.
If Freedom makes a voyage to Trinidad in week 5, which one of the following
could be true?
```
abstractlogic> w5 = 'Trinidad'
```

**A)** Freedom makes a voyage to Trinidad in week 1.
```
abstractlogic> check w1 = 'Trinidad'
```
```
abstractlogic> #false, 0 out of 3 possible combinations 'true'.
```

**B)** Freedom makes a voyage to Martinique in week 2.
```
abstractlogic> check w2 = 'Martinique'
```
false, 0 out of 3 possible combinations 'true'.

**C)** Freedom makes a voyage to Guadeloupe in week 3.
```
abstractlogic> check w3 = 'Guadeloupe'
```
false, 0 out of 3 possible combinations 'true'.

**D)** Freedom makes a voyage to Martinique in week 4.
```
abstractlogic> check w4 = 'Martinique'
```
possible,  1 out of 3 possible combinations 'true'.

**E)** Freedom makes a voyage to Jamaica in week 6.
```
abstractlogic> check w6 = 'Jamaica'
```
false, 0 out of 3 possible combinations 'true'.
* Restore previous state.

```
abstractlogic> import lsat4
```

### Question 14.
If Freedom makes a voyage to Guadeloupe in week 1 and a voyage to Jamaica in
week 5, which one of the following must be true?
```
abstractlogic> w1 = 'Guadeloupe'; w5 = 'Jamaica'
```

**A)** Freedom makes a voyage to Jamaica in week 2.
```
abstractlogic> check w2 = 'Jamaica'
```
possible,  1 out of 3 possible combinations 'true'.

**B)** Freedom makes a voyage to Trinidad in week 2.
```
abstractlogic> check w2 = 'Trinidad'
```
possible,  1 out of 3 possible combinations 'true'.

**C)** Freedom makes a voyage to Martinique in week 3.
```
abstractlogic> check w3 = 'Martinique'
```
possible,  2 out of 3 possible combinations 'true'.

**D)** Freedom makes a voyage to Guadeloupe in week 6.
```
abstractlogic> check w6 = 'Guadeloupe'
```
false, 0 out of 3 possible combinations 'true'.

**E)** Freedom makes a voyage to Martinique in week 6.
```
abstractlogic> check w6 = 'Martinique'
```
true, 3 out of 3 possible combinations 'true'.

* Restore previous state.
```
abstractlogic> import lsat4
```

### Question 15.
If Freedom makes a voyage to Guadeloupe in week 1 and to Trinidad in
week 2, which one of the following must be true?
```
abstractlogic> w1 = 'Guadeloupe'; w2 = 'Trinidad'
```

**A)** Freedom makes a voyage to Martinique in week 3.
```
abstractlogic> prove w3 = 'Martinique'
```
true, 1 out of 1 possible combinations 'true'.

**B)** Freedom makes a voyage to Martinique in week 4.
```
abstractlogic> prove w4 = 'Martinique'
```
false, 0 out of 1 possible combinations 'true'.

**C)** Freedom makes a voyage to Martinique in week 5.
```
abstractlogic> prove w5 = 'Martinique'
```
false, 0 out of 1 possible combinations 'true'.

**D)** Freedom makes a voyage to Guadeloupe in week 3.
```
abstractlogic> prove w3 = 'Guadeloupe'
```
false, 0 out of 1 possible combinations 'true'.

**E)** Freedom makes a voyage to Guadeloupe in week 5
```
abstractlogic> prove w5 = 'Guadeloupe'
```
false, 0 out of 1 possible combinations 'true'.

* Restore previous state.
```
abstractlogic> import lsat4
```

### Question 16.
If Freedom makes a voyage to Martinique in week 3, which one of the
following could be an accurate list of Freedom’s destinations in week 4
and week 5,respectively?
```
abstractlogic> w3 = 'Martinique'
```

**A)** Guadeloupe, Trinidad
```
abstractlogic> any w4 = 'Guadeloupe'; w5 = 'Trinidad'
```
true,  1 out of 8 possible combinations 'true'.

**B)** Jamaica, Guadeloupe
```
abstractlogic> any w4 = 'Jamaica'; w5 = 'Guadeloupe'
```
false, 0 out of 8 possible combinations 'true'.

**C)** Martinique, Trinidad
```
abstractlogic> any w4 = 'Martinique'; w5 = 'Trinidad'
```
false, 0 out of 8 possible combinations 'true'.

**D)** Trinidad, Jamaica
```
abstractlogic> any w4 = 'Trinidad'; w5 = 'Jamaica'
```
false, 0 out of 8 possible combinations 'true'.

**E)** Trinidad, Martinique
```
abstractlogic> any w4 = 'Trinidad'; w5 = 'Martinique'
```
false, 0 out of 8 possible combinations 'true'.
* Restore previous state.
```
abstractlogic> import lsat4
```

### Question 17.
Which one of the following must be true about Freedom’s schedule of voyages?

**A)** Freedom makes a voyage to Guadeloupe either in week 1 or else in week 2.
```
abstractlogic> check w1|w2 = 'Guadeloupe'
```
false, 22 out of 25 possible combinations 'true'.
```
abstractlogic> w1,w2 != 'Guadeloupe'
```

**B)** Freedom makes a voyage to Martinique either in week 2 or else in week 3.
```
abstractlogic> check w2|w3 = 'Martinique'
```
false, 12 out of 25 possible combinations 'true'.

**C)** Freedom makes at most two voyages to Guadeloupe.
```
abstractlogic> check {{i}} = 'Guadeloupe' {{,2}}
```
false, 20 out of 25 possible combinations 'true'.

**D)** Freedom makes at most two voyages to Jamaica.
```
abstractlogic> check {{i}} = 'Jamaica' {{,2}}
```
true, 25 out of 25 possible combinations 'true'.

**E)** Freedom makes at most two voyages to Trinidad.
```
abstractlogic> check {{i}} = 'Trinidad' {{,2}}
```
false, 24 out of 25 possible combinations 'true'.
