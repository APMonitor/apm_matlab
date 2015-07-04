clear all; close all; clc

addpath('../apm')

% generate LTI model in MATLAB
s = tf('s')
G = [ 1/(2*s+1) 3/(4*s+1); 0 5/(6*s+1)];
sys = ss(G)

% generate LTI model in APMonitor
apm_lti(G);

% model is now created, need to call apm_solve to solve it