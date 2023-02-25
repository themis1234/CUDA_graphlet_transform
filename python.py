from scipy.sparse import *
from numpy import array
from scipy.io import mmread

x = mmread("delaunay_n22.mtx")

y = csc_matrix(x)
ind = y.indptr
data = y.indices


f = open("indices.txt","w")
f.write(str(len(ind))+"\n")
for i in range(0,len(ind)):
    f.write(str(ind[i])+"\n")

f = open("data.txt","w")
f.write(str(len(data))+"\n")
for i in range(0,len(data)):
    f.write(str(data[i])+"\n")

