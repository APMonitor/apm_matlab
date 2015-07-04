% Add path to APM libraries
addpath('../apm');

% Clear MATLAB
clear all
close all

% Select server
server = 'http://byu.apmonitor.com';

% Application
app = 'nlc';

% Clear previous application
apm(server,app,'clear all');

% load model variables and equations
apm_load(server,app,'cstr.apm');

% load data
csv_load(server,app,'cstr.csv');

% Set up variable classifications for data flow

% Feedforwards - measured process disturbances
apm_info(server,app,'FV','Caf');
apm_info(server,app,'FV','Tf');
% Manipulated variables (for controller design)
apm_info(server,app,'MV','tc');
% State variables (for display only)
apm_info(server,app,'SV','Ca');
% Controlled variables (for controller design)
apm_info(server,app,'CV','T');

% imode = 1, steady state mode
apm_option(server,app,'nlc.imode',1);
% solve here for steady state initialization
apm(server,app,'solve')

% imode = 7, switch to sequential simulation
apm_option(server,app,'nlc.imode',7);
% nodes = 3, internal nodes in the collocation structure (2-6)
apm_option(server,app,'nlc.nodes',3);
% simulation step size for every 'solve' command
apm_option(server,app,'nlc.ctrl_time',0.25);
% coldstart application
apm_option(server,app,'nlc.coldstart',1);
% read csv file
apm_option(server,app,'nlc.csv_read',1);

% Run APMonitor
apm(server,app,'solve')

% Retrieve solution (creates solution.csv locally)
y = apm_sol(server,app);
% Extract names
names = y.names;
% Extract values
cc = y.values;

% Time is always the first column or row
time_apm = cc(:,1);

% extract 'Ca'
index = find(strcmpi('Ca',names));
Ca_apm = cc(:,index);

% extract 'T'
index = find(strcmpi('T',names));
T_apm = cc(:,index);

% extract 'Tc'
index = find(strcmpi('Tc',names));
Tc_apm = cc(:,index);

% ---------------------------------------------------------
% simulate with ode15s (for comparison)
% Verify dynamic response of CSTR model

global u

% Steady State Initial Conditions for the States
Ca_ss = 0.989;
T_ss = 296.6;
y_ss = [Ca_ss;T_ss];

% Open Loop Step Change
u = 220;

% Final Time (sec)
tf = 5;

[t_ode15s,y] = ode15s('cstr1',[0.25 tf],y_ss);

% Parse out the state values
Ca_ode15s = y(:,1);
T_ode15s = y(:,2);
% ---------------------------------------------------------


figure(1)
plot(time_apm,Ca_apm,'b-');
hold on;
plot(t_ode15s,Ca_ode15s,'k--')
xlabel('Time (min)')
ylabel('Concentration')
legend('APM','ODE15S');

figure(2)
subplot(2,1,1);
plot(time_apm,T_apm,'b-');
hold on;
plot(t_ode15s,T_ode15s,'k--');
ylabel('Temp (K)');
legend('APM','ODE15S');

subplot(2,1,2);
plot(time_apm,Tc_apm,'r-');
xlabel('Time (min)');
ylabel('Temp (K)');
legend('Jacket');