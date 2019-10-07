# AbstractLogic - Main

This section defines the core functionality of the package.

## API

### checkfeasible

Checks the feasibility of a constraint set. It basically implements a new constraint
on a LogicalCombo and then asks if that constraint reduces the size of the set
entirely (false), partially (possible), or not at all (true).

### dependenton

Checks if a variable is dependent in some way on another variable or if its values
are independent.

### logicalparse

Defines the core call function which is used to generate, modify, and query LogicalCombo objects.

### LogicalCombo

Defines the basic object type for which most operations are performed.


### search

Searches a set for a possible match among variables in that set.

### setcompare

Compares the number of feasbile values in one set with that of another set.

### showfeasible

Returns a table of feasible values from a set.

## Set Evaluation Tools

Generally these functions are only called when logicalparse is called which then
sends the functions to metaoperator, superoperator, and operator in turn.

### definelogicalset

Commands which have the generator operator ∈ are sent here to be either generated
or expanded.

### metaoperator

Checks for the existance of metaoperator if it does not exist command is set to
superoperator.

### superoperator
Checks for the existance of superoperator if it does not exist command is set to
operator.

### operatorspawn
Called from superoperator if a spawning syntax is recognized. Then calls superoperator.
