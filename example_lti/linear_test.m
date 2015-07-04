clear all; close all; clc

addpath('../apm')

%% generate linear model (A x = b)
A = eye(10)*2;
b = rand(10,1);
apm_linear(A,b,'=','linear');

% solve linear system of equations
s = 'http://byu.apmonitor.com';
a = 'lintest';
apm(s,a,'clear all');
apm_load(s,a,'linear.apm');
output = apm(s,a,'solve');
disp(output)
y = apm_sol(s,a);
apm_web(s,a);



%% generate linear model (A x > b)
A = eye(10)*2;
b = rand(10,1);
apm_linear(A,b,'>','linear');

% solve linear system of equations
s = 'http://byu.apmonitor.com';
a = 'lintest';
apm(s,a,'clear all');
apm_load(s,a,'linear.apm');
apm_option(s,a,'nlc.solver',3); % switch to IPOPT
output = apm(s,a,'solve');
disp(output)
y = apm_sol(s,a);
apm_web(s,a);