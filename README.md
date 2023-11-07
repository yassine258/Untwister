## Conclusion

Breaking the MT19937 PRNG using linear equations is a theoretical approach to predict its internal state. In practice, this method may require a large number of observed output values, making it less feasible.

## Challenges and Limitations

Breaking MT19937 using linear equations can be challenging and may require a significant amount of known output values. The more known values you have, the easier it is to find the coefficients and recover the internal state.You usually need around 624*32 bit outputed from the random generator to recover the internal states But In some specific occasion you'll need more since not all vectors are linear independent 


