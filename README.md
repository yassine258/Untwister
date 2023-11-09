## Conclusion

Breaking the MT19937 PRNG using linear equations is a theoretical approach to predict its internal state. In practice, this method may require a large number of observed output values, making it less feasible.

## Note

The more known values you have, the easier it is to find the coefficients and recover the internal state.You usually need around 624*32 bit outputed from the random generator to recover the internal states But In some specific occasion you'll need more since not all vectors are linear independent.In the other cases you may need to brute the the right kernel of the matrix to get all the possible internal states in the case of the matrix not being unversible


