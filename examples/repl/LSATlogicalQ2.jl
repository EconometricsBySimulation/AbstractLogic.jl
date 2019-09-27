# LSAC JUNE 2007 Form 8LSN75
# https://www.lsac.org/sites/default/files/legacy/docs/default-source/jd-docs/sampleptjune.pdf

# Questions 6-10

"""
Exactly three films—Greed, Harvest, and Limelight—are
shown during a film club’s festival held on Thursday, Friday,
and Saturday. Each film is shown at least once during the
festival but never more than once on a given day. On each day
at least one film is shown. Films are shown one at a time. The
following conditions apply:
"""
julia> using AbstractLogic
Start the repl in command prompt by typing `=`.

# Three films Greed, Harvest, and Limelight as well as 0 no film
# t1 is the first film, t2 the second, and t3 are the last film on Thursday
# f1, f2, f3 and s1, s2, s3 are similarly coded for friday and saturday
t.1, t.2, t.3, f.1, f.2, f.3, s.1, s.2, s.3  ∈  _, Greed, Harvest, Limelight [clear]

# On each day at least one film is shown. Since 3 is last slot then .3 can't be empty.
{{j}}.3 != '_'

# Let's impose the sttructural contrainst that the highest number 3 is the
# last film shown. Thus if t2|t1 != 0 => t3 != 0
# t1 != 0 ==> t2 !=0", logicset)
{{j}}.1 != '_' ==> {{j}}.2 != '_'

# Each film is shown at least once during the festival
{{i}} == 'Greed' {{1,}}
{{i}} == 'Harvest' {{1,}}
{{i}} == 'Limelight' {{1,}}

# Never more than once on a given day. If t1 does not equal '_' then t1 != t2.
# Since we know that t3 can't be '_' then we can assert that t2 != t3
{{j}}.1 != '_' ==> {{j}}.1 != {{j}}.2 &&& {{j}}.1 != {{j}}.3 &&& {{j}}.2 != {{j}}.3

# On Thursday Harvest is shown, and no film is shown after it on that day
t.3 = 'Harvest'

# On Friday either Greed or Limelight, but not both, and no film is
# shown after it on that day.
f.3 = 'Greed'|'Limelight'; f.2,f.1 != 'Greed','Limelight'

# On Saturday either Greed or Harvest, but not both, is shown, and no film is
# shown after it on that day.
s.3 = 'Greed'|'Harvest'; s.1,s.2 != 'Greed','Harvest'

export lsat3

#6. Which one of the following could be a complete and accurate description of
# the order in which the films are shown at the festival?
#(A) Thursday: Limelight, then Harvest; Friday: Limelight; Saturday: Harvest
check t.2 = 'Limelight' ; t.3 = 'Harvest' ; f.3 = 'Limelight' ; s.3 = 'Harvest' ; t.1,f.2,f.1,s.2,s.1='_'
# false 0 out of 64 possible combinations true

#(B) Thursday: Harvest; Friday: Greed, then Limelight; Saturday: Limelight, then Greed
check t.3 = 'Harvest' ; f.2 = 'Greed' ; f.3 = 'Limelight' ; s.2 = 'Limelight' ; s.3 = 'Greed'
# false 0 out of 64 possible combinations true

#(C) Thursday: Harvest; Friday: Limelight; Saturday: Limelight, then Greed
check t.3 = 'Harvest' ; f.3 = 'Limelight' ; s.2 = 'Limelight' ; s.3 = 'Greed'; t.1, t.2, f.1, f.2, s.1='_'
# true 1 out of 64 possible combinations true

#(D) Thursday: Greed, then Harvest, then Limelight; Friday: Limelight; Saturday: Greed
check t.1 = 'Greed' ; t.2 = 'Harvest' ; t.3 = 'Limelight' ; f.3 = 'Limelight' ; s.3 = 'Greed'
# false, 0 out of 64 possible combinations 'true'.

#(E) Thursday: Greed, then Harvest; Friday: Limelight, then Harvest; Saturday: Harvest
check t.2 = 'Greed' ; t.3 = 'Harvest' ; f.2 = 'Limelight' ; f.3 = 'Harvest' ; s.3 = 'Harvest'
# false, 0 out of 64 possible combinations 'true'.


#7. Which one of the following CANNOT be true?
#(A) Harvest is the last film shown on each day of the festival.
check t.3,f.3,s.3 = 'Harvest'
# false, 0 out of 64 possible combinations 'true'

# (B) Limelight is shown on each day of the festival.
any {{i}} == 'Limelight' {{3,}}
# true,  10 out of 72 possible combinations 'true'.

#(C) Greed is shown second on each day of the festival.
any f.1,f.2,f.3 |= 'Greed'
# true,  32 out of 72 possible combinations 'true'

# (D) A different film is shown first on each day of the festival.
## This will be a little trickier. Define .0 as first film

t.0, f.0, s.0 ∈ Greed, Harvest, Limelight
{{j}}.0 == {{j}}.1 if {{j}}.1 != '_'
{{j}}.1 == '_' &&& {{j}}.2 != '_' ==> {{j}}.0 == {{j}}.2
{{j}}.2 == '_' ==> {{j}}.0 == {{j}}.3
check t.0 != f.0, s.0 ; f.0 != s.0

import lsat3

# possible,  19 out of 64 possible combinations 'true'.

# (E) A different film is shown last on each day of the festival.
check t.3, f.3 != s.3; t.3 != f.3
# possible,  24 out of 74 possible combinations 'true'.

# If Limelight is never shown again during the festival once Greed is shown,
{{i}} = 'Greed' ==> {{>i}} != 'Limelight'

# which one of the following is the maximum number of film showings that could
# occur during the festival?
#(A) three
any: {{i}} != '_' {{3}}
# true

#(B) four
any: {{i}} != '_' {{4}}
# true

#(C) five
any: {{i}} != '_' {{5}}
# true

# (D) six
any: {{i}} != '_' {{6}}
# true
# * Answer

# (E) seven
any: {{i}} != '_' {{7}}
# false

# If Greed is shown exactly three times, Harvest is shown exactly twice, and
# Limelight is shown exactly once, then which one of the following must be true?
import lsat3

{{i}} = 'Greed' {{3}}; {{i}} = 'Harvest' {{2}}; {{i}} = 'Limelight' {{1}}

#(A) All three films are shown on Thursday.
prove: t.1 != '_'
# false, 2 out of 3 possible combinations 'true'.

#(B) Exactly two films are shown on Saturday.
prove: s.1 = '_'
# true, 3 out of 3 possible combinations 'true'.

#(C) Limelight and Harvest are both shown on Thursday.
prove: t.1,t.2,t.3 |= 'Limelight'; t.1,t.2,t.3 |= 'Harvest'
# false, 2 out of 3 possible combinations 'true'.

#(D) Greed is the only film shown on Saturday.
prove: s.1,s.2 != '_'; s.3 = 'Greed'
# false, 0 out of 3 possible combinations 'true'.

#(E) Harvest and Greed are both shown on Friday
prove: s.1,s.2,s.3 |= 'Harvest'; s.1,s.2,s.3 |= 'Greed'
# false, 0 out of 3 possible combinations 'true'.



# If Limelight is shown exactly three times, Harvest is shown exactly twice, and
# Greed is shown exactly once...
import lsat3
{{i}} = 'Limelight' {{3}}; {{i}} = 'Harvest' {{2}}; {{i}} = 'Greed' {{1}}

# Reintroduce first film
t.0, f.0, s.0 ∈ Greed, Harvest, Limelight
{{j}}.0 == {{j}}.1 if {{j}}.1 != '_'
{{j}}.2 != '_' &&& {{j}}.1 == '_' ==> {{j}}.0 == {{j}}.2
{{j}}.2 == '_' ==> {{j}}.0 == {{j}}.3
# Order of operations helps here as the &&& block is evaluated before the if operator

# then which one of the following is a complete and accurate list of the films
# that could be the first film shown on Thursday?
range t.1
# Greed, Limelight

# (A) Harvest
# (B) Limelight
# (C) Greed, Harvest
# (D) Greed, Limelight
# (E) Greed, Harvest, Limelight
