from random import Random
from time import time

# Init Constants
upper_mask= [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
lower_mask= [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
a_val     = [1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1]
temper_a  = [1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0]
temper_b  = [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

class Untwister:
    def __init__(self,know_bit):
        self.equations=[]
        self.index=0
        self.known_bit=know_bit
        self.P=BooleanPolynomialRing(624*32,[f"x_{i}_{j}" for i in range(624) for j in range(32)])
        self.variables=self.P.gens()
        self.states=[]
        self.var_map={self.variables[i]:i for i in range(len(self.variables))}
        self.numRand=0
        self.MT=[[self.variables[32*i+j] for j in range(32)] for i in range(624)]
        self.solved=False
    def Rshift(self,y,n):
        return [0]*n+y[:-n]
    
    def Lshift(self,y,n):
        return y[n:]+[0]*n
    
    def And(self,a,b):
        return [i*j for i,j in zip(a,b)]
    
    def Add(self,a,b):
        return [i+j for i,j in zip(a,b)]
    
    def symbolic_twist(self,n=624,upper_mask=upper_mask,lower_mask=lower_mask,a=a_val,m=397):
        MT = self.MT
        for i in range(n):
            x=self.Add(self.And(MT[i],upper_mask),self.And(MT[(i+1)%n],lower_mask))
            xA=self.Rshift(x,1)
            xB_0=self.And(a,[x[-1]]*32)
            xB=self.Add(xA,xB_0)
            MT[i]=self.Add(MT[(i+m)%n],xB)    
        self.MT=MT

    def untemper_const(self,n):
        y1=self.MT[n]
        y2=self.Add(y1,self.Rshift(y1,11))
        y3=self.Add(y2,self.And(self.Lshift(y2,7),temper_a))
        y4=self.Add(y3,self.And(self.Lshift(y3,15),temper_b))
        return self.Add(y4,self.Rshift(y4,18))
    
    def solve_state(self):
        T1=time()
        if len(self.equations)<624*32:
            print("Not enough")
            return None
        if self.known_bit==32:
            print("Using Ideal For faster solutions")
            for i in range(0,624*32,32):
                state_val_i=0
                state_i=self.equations[i:i+32]
                I=Ideal(state_i)
                for k,xi in enumerate(I.groebner_basis()):
                    state_val_i=state_val_i*2+int(xi.constant_coefficient())
                self.states.append(int(state_val_i))
        else:
            print("Building Matrix")
            M=Matrix(GF(2), len(self.equations), 624*32)
            v=[0]*len(self.equations)
            for i,c in enumerate(self.equations):
                v[i]+=c.constant_coefficient()
                c=c-c.constant_coefficient()
                for j in c.terms():
                    M[i, self.var_map[j]]=1
            v=vector(GF(2),v)
            print("Solving....")
            sol=list(M.solve_right(v))
            for i in range(0,len(sol),32):
                state_i=0
                for j in sol[i:i+32]:
                    state_i=state_i*2+int(j)
                self.states.append(int(state_i))
            print("Time To solve:" ,time()-T1)
    def getRandom(self):
        if not self.solved:
            self.solve_state()
            self.solved=True
        R1=Random()
        result_state = (3, tuple([int(i) for i in self.states]+[624]), None)
        R1.setstate(result_state)
        for ii in range(624,self.numRand):
            R1.getrandbits(32)
        return R1

    def submit(self,Leak):
        self.numRand+=1
        if self.index==624:
            self.symbolic_twist()
            self.index=0
        MT_i=self.untemper_const(self.index)
        for i,j in zip(Leak,MT_i):
            if i!="?": 
                self.equations.append(j+int(i))
        self.index+=1
        
