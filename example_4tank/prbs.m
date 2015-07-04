% Add path to APM libraries
addpath('../apm');

% Clear MATLAB
clear all
close all

% Select server
server = 'http://byu.apmonitor.com';

% Application
app = 'prbs';

% Clear previous application
apm(server,app,'clear all');

% load model variables and equations
disp('Loading APM model file')
apm_load(server,app,'4tank.apm');

% choose a data set for parameter estimation with PRBS signal data
disp('Loading CSV data file')

% load 10 second data - with 1 hour horizon
csv_load(server,app,'prbs50.csv');
load prbs10.txt
data = prbs10;

% Set up variable classifications for data flow

% Feedforwards - measured process disturbances
apm_info(server,app,'FV','km');
apm_info(server,app,'FV','kb');
apm_info(server,app,'FV','gamma[1]');
apm_info(server,app,'FV','gamma[2]');
apm_info(server,app,'FV','c13');
apm_info(server,app,'FV','c24');
% Manipulated variables (for controller design)
%apm_info(server,app,'MV','v1');
%apm_info(server,app,'MV','v2');
% State variables (for display only)
apm_info(server,app,'SV','h[3]');
apm_info(server,app,'SV','h[4]');
% Controlled variables (for controller design)
apm_info(server,app,'CV','h[1]');
apm_info(server,app,'CV','h[2]');

% imode (1=ss, 2=mpu, 3=rto, 4=sim, 5=est, 6=ctl)
apm_option(server,app,'nlc.imode',5);
% nodes = 3, internal nodes in the collocation structure (2-6)
apm_option(server,app,'nlc.nodes',3);
% simulation step size for every 'solve' command
apm_option(server,app,'nlc.ctrl_time',0.25);
% read csv file
apm_option(server,app,'nlc.csv_read',1);
% estimated variable error type
apm_option(server,app,'nlc.ev_type',2);
% time units (1=sec, 2=min, 3=hrs, 4=days, etc)
apm_option(server,app,'nlc.ctrl_units',1);
apm_option(server,app,'nlc.hist_units',2);

% parameters to adjust
apm_option(server,app,'km.status',1);
apm_option(server,app,'km.lower',3);
apm_option(server,app,'km.upper',20);

apm_option(server,app,'kb.status',1);
apm_option(server,app,'kb.lower',-2);
apm_option(server,app,'kb.upper',2);

apm_option(server,app,'gamma[1].status',1);
apm_option(server,app,'gamma[1].lower',0.2);
apm_option(server,app,'gamma[1].upper',0.8);

apm_option(server,app,'gamma[2].status',1);
apm_option(server,app,'gamma[2].lower',0.2);
apm_option(server,app,'gamma[2].upper',0.8);

apm_option(server,app,'c13.status',1);
apm_option(server,app,'c13.lower',0.01);
apm_option(server,app,'c13.upper',0.2);

apm_option(server,app,'c24.status',1);
apm_option(server,app,'c24.lower',0.01);
apm_option(server,app,'c24.upper',0.2);

% data to fit
apm_option(server,app,'h[1].fstatus',1);
apm_option(server,app,'h[2].fstatus',1);

% solver
apm_option(server,app,'nlc.solver',3);

% Run APMonitor
apm(server,app,'solve')

% Open web-viewer
apm_web(server,app);

% Retrieve solution (creates solution.csv locally)
y = apm_sol(server,app);
cc = y.values;
time = cc(:,1);
v1 = cc(:,8);
v2 = cc(:,9);
h(:,1:4) = cc(:,10:13);

m = size(time,1);
hm(:,1:2) = data(1:m,4:5);

figure(1)
subplot(3,2,1)
plot(time,v1,'b-');
ylabel('Pump Input (Volt)')
legend('v_1');

subplot(3,2,2)
plot(time,v2,'b-');
ylabel('Pump Input (Volt)')
legend('v_2');

subplot(3,2,3)
plot(time,h(:,3),'b-');
ylabel('Height (cm)')
legend('h_3');

subplot(3,2,4)
plot(time,h(:,4),'b-');
ylabel('Height (cm)')
legend('h_4');

subplot(3,2,5)
plot(time,h(:,1),'b-');
hold on;
plot(time,hm(:,1),'r.');
ylabel('Height (cm)')
legend('h_1 model','h_1 meas');

subplot(3,2,6)
plot(time,h(:,2),'b-');
hold on;
plot(time,hm(:,2),'r.');
ylabel('Height (cm)')
legend('h_2 model','h_2 meas');

xlabel('Time (sec)')
