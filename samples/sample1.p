DECLARE a: INTEGER
DECLARE b: INTEGER
DECLARE c: INTEGER
DECLARE d: INTEGER
a <- 1
b <- 2 * (9 + 9) + 88 * 77 - 9 + 8 * (+9 - 6) * -3
c <- a
IF a = c THEN
    b <- a * 9 + b
    d <- b
ELSE
    d <- c
ENDIF
WHILE c > 0
    c <- c - 1
ENDWHILE

