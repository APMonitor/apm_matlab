% Clear MATLAB
clear all; close all;

% Add path to APM libraries
addpath('../apm');

% Select server
server = 'http://byu.apmonitor.com';

% Application
app = 'vaccine';

% ----------- tau = 0.7 ---------------------------
% Clear previous application
apm(server,app,'clear all');

% load model variables and equations
apm_load(server,app,'vaccine.apm');

% load data
csv_load(server,app,'vaccine_0.7.csv');

% imode = 7, switch to sequential simulation
apm_option(server,app,'nlc.imode',7);

% change history horizon from the default of 100
apm_option(server,app,'nlc.hist_hor',200);

% change time units to seconds
apm_option(server,app,'nlc.ctrl_units',1);

% select solver (1=APOPT, 2=BPOPT, 3=IPOPT)
apm_option(server,app,'nlc.solver',1);

% Run APMonitor
apm(server,app,'solve')

% Retrieve solution (creates solution.csv locally)
y = apm_sol(server,app);

% Extract names
names = y.names;

% Extract values
cc = y.values;

% Time is always the first column
time = cc(:,1);

% extract values for trending
index = find(strcmpi('strain1_frac',names));  strain1_frac = cc(:,index);
index = find(strcmpi('strain2_frac',names));  strain2_frac = cc(:,index);
index = find(strcmpi('V_frac',names));        V_frac = cc(:,index);
% ----------- tau = 0.7 ---------------------------


% ----------- tau = 0.9 ---------------------------
% Clear previous application
apm(server,app,'clear all');

% load model variables and equations
apm_load(server,app,'vaccine.apm');

% load data
csv_load(server,app,'vaccine_0.9.csv');

% imode = 7, switch to sequential simulation
apm_option(server,app,'nlc.imode',7);

% change history horizon from the default of 100
apm_option(server,app,'nlc.hist_hor',200);

% change time units to seconds
apm_option(server,app,'nlc.ctrl_units',1);

% select solver (1=APOPT, 2=BPOPT, 3=IPOPT)
apm_option(server,app,'nlc.solver',1);

% Run APMonitor
apm(server,app,'solve')

% Retrieve solution (creates solution.csv locally)
y = apm_sol(server,app);

% Extract names
names = y.names;

% Extract values
cc = y.values;

% Time is always the first column
time = cc(:,1);

% extract values for trending
index = find(strcmpi('strain1_frac',names));  strain1_frac2 = cc(:,index);
index = find(strcmpi('strain2_frac',names));  strain2_frac2 = cc(:,index);
index = find(strcmpi('V_frac',names));        V_frac2 = cc(:,index);
% ----------- tau = 0.9 ---------------------------


% open web-viewer
apm_web(server,app);

% plot results
figure(1)
semilogy(time,strain1_frac,'r-');
hold on;
semilogy(time,strain2_frac,'g-');
semilogy(time,V_frac,'b-');
semilogy(time,strain1_frac2,'r.');
hold on;
semilogy(time,strain2_frac2,'g.');
semilogy(time,V_frac2,'b.');
xlabel('Time (sec)');
legend('strain 1 (tau=0.7)','strain 2 (tau=0.7)','V (tau=0.7)','strain 1 (tau=0.9)','strain 2 (tau=0.9)','V (tau=0.9)');
ylabel('fraction in population')
