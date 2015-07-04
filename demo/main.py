# load apm library
from apm import *

# specify s=server and a=application names
s = 'http://xps.apmonitor.com'
a = 'demo'

# clear previous applicaiton by that name
apm(s,a,'clear all')

# load model and data files
apm_load(s,a,'demo.apm')
csv_load(s,a,'demo.csv')

# change to dynamic simulation
apm_option(s,a,'nlc.imode',7)

# Solve model and return solution
output = apm(s,a,'solve')
print output

# Plot results
import matplotlib
import matplotlib.pyplot as plt

# retrieve solution
(sol,ans) = apm_sol(s,a)

# plot results
plt.figure()
plt.plot(ans['time'],ans['x'],'r-')
plt.plot(ans['time'],ans['y'],'b--')
plt.legend(['x','y'])
plt.show()
