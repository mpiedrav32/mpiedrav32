# Optimization examples

Examples based on Agner Fog's 
[Optimizing software in C++](https://www.agner.org/optimize/optimizing_cpp.pdf),
chapter 8 ("Optimizations in the compiler").

## Control flow, conditional, variable/pointer usage optimizations

- Function inlining
- Constant folding and constant propagation
- Pointer elimination
- Common subexpression elimination
- Register variables
- Live range analysis (share registers when variable no longer needed)
- Join identical branches
- Eliminate jumps
- Loop unrolling (if loop count is low)
- Loop invariant code motion (expressions that don't change inside a loop
are extracted)
- Induction variables (given a linear function of a loop counter,
set the constant outside the loop)
- Scheduling (reorder instructions)

## Algebraic reductions

- Use field axioms for reducing algebraic expressions
- De Morgan laws for logic expressions
- 