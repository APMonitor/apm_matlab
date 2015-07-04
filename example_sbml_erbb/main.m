% Clear MATLAB
clear all; close all; clc

% Add path to APM libraries
addpath('../apm')

% Solve ErbB model with dynamic sequential simulation
y = apm_solve('erbb',7);

% extract values for trending
time = y.x.time;
akt_pp = y.x.relakt_pp;
erk_pp = y.x.relerk_pp;
erb1_p = y.x.relerb1_p;

% plot results
figure(1)
subplot(2,1,1);
plot(time,akt_pp,'b-');
hold on;
plot(time,erk_pp,'r-');
legend('AKT PP','ERK PP');
ylabel('Relative Value')
subplot(2,1,2);
plot(time,erb1_p,'g-');
ylabel('Relative Value');
legend('ERB1 P');
xlabel('Time (sec)');
