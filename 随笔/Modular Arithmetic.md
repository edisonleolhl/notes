## 模运算基础知识

[https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/what-is-modular-arithmetic](https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/what-is-modular-arithmetic)

## An Introduction to Modular Math

When we divide two integers we will have an equation that looks like the following:

A is the dividend  B is the divisor  Q is the quotient  R is the remainder

Sometimes, we are only interested in what the **remainder** is when we divide AAAby BBB.  For these cases there is an operator called the modulo operator (abbreviated as mod).

Using the same A, B, Q, and R as above, we would have: A mod B=R

We would say this as A *modulo* B *is equal to* R. Where B is referred to as the **modulus**.

## Congruence Modulo

You may see an expression like:

A≡B(mod C)

This says that A is **congruent** to B modulo C.

## Equivalent Statements

Before proceeding it’s important to remember the following statements are equivalent

*   A≡B (mod C)

*   A mod C=B mod C

*   C ∣ (A−B)

    > (The | symbol means divides, or is a factor of)

*   A=B+K⋅C (where K is some integer)

This lets us move back and forth between **different forms** of expressing the **same idea**.

## Modular operation

### addition and subtraction

(**A + B**) mod C = (A mod C + B mod C) mod C

(A - B) mod C = (A mod C - B mod C) mod C

### multiplication

(A * B) mod C = (A mod C * B mod C) mod C

### exponentiation

**A^B mod C = ( (A mod C)^B ) mod C**

## Modular inverses

### **What is a modular inverse?**

In modular arithmetic we do not have a division operation. However, we do have modular inverses.

*   The modular inverse of A (mod C) is A^-1

*   (A * A^-1) ≡ 1 (mod C) or equivalently (A * A^-1) mod C = 1

*   Only the numbers coprime to C (numbers that share no prime factors with C) have a modular inverse (mod C)

### **How to find a modular inverse**

A naive method of finding a modular inverse for A (mod C) is:

**step 1.** Calculate A * B mod C for B values 0 through C-1

**step 2.** The modular inverse of A mod C is the B value that makes A * B mod C = 1

Note that the term B mod C can only have an integer value 0 through C-1, so testing larger values for B is redundant.

## The Euclidean Algorithm

Recall that the Greatest Common Divisor (GCD) of two integers A and B is the **largest integer that divides both A and B**.

The **Euclidean Algorithm** is a technique for quickly finding the **GCD** of two integers.

### The Algorithm

The Euclidean Algorithm for finding GCD(A,B) is as follows:

*   If A = 0 then GCD(A,B)=B, since the GCD(0,B)=B, and we can stop.

*   If B = 0 then GCD(A,B)=A, since the GCD(A,0)=A, and we can stop.

*   Write A in quotient remainder form (A = B⋅Q + R)

*   Find GCD(B,R) using the Euclidean Algorithm since GCD(A,B) = GCD(B,R)

## 求线性同余数（Using Euclid’s Algorithm）

[http://www.maths.manchester.ac.uk/~mdc/MATH10101/2010-11/Notes2010-11/Ch3%20II%20Congruences.pdf](http://www.maths.manchester.ac.uk/~mdc/MATH10101/2010-11/Notes2010-11/Ch3%20II%20Congruences.pdf)

## 求指数同余数（Using Fast modular exponentiation）

[https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/fast-modular-exponentiation](https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/fast-modular-exponentiation)