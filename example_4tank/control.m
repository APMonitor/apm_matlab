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
apm_load(server,app,'4tank_nlc.apm');

% load data
csv_load(server,app,'control.csv');

% Set up variable classifications for data flow

% Feedforwards - measured process disturbances
apm_info(server,app,'FV','gamma[1]');
apm_info(server,app,'FV','gamma[2]');
% Manipulated variables (for controller design)
apm_info(server,app,'MV','v1');
apm_info(server,app,'MV','v2');
% State variables (for display only)
apm_info(server,app,'SV','h[3]');
apm_info(server,app,'SV','h[4]');
% Controlled variables (for controller design)
apm_info(server,app,'CV','h[1]');
apm_info(server,app,'CV','h[2]');

% solve here for steady state initialization
% imode = 3, steady state mode
apm_option(server,app,'nlc.imode',3);
apm(server,app,'solve')

% imode = 6, switch to dynamic control
apm_option(server,app,'nlc.imode',6);
% nodes = 3, internal nodes in the collocation structure (2-6)
apm_option(server,app,'nlc.nodes',3);
% time units
apm_option(server,app,'nlc.ctrl_units',1);
apm_option(server,app,'nlc.hist_units',2);
% read csv file
apm_option(server,app,'nlc.csv_read',1);

% Manipulated variables
apm_option(server,app,'v1.status',1);
apm_option(server,app,'v1.upper',6);
apm_option(server,app,'v1.lower',1);
apm_option(server,app,'v1.dmax',1);
apm_option(server,app,'v1.dcost',1);

apm_option(server,app,'v2.status',1);
apm_option(server,app,'v2.upper',6);
apm_option(server,app,'v2.lower',1);
apm_option(server,app,'v2.dmax',1);
apm_option(server,app,'v2.dcost',1);

% Controlled variables
apm_option(server,app,'h[1].status',1);
apm_option(server,app,'h[1].fstatus',0);
apm_option(server,app,'h[1].sphi',10.1);
apm_option(server,app,'h[1].splo',9.9);
apm_option(server,app,'h[1].tau',10);

apm_option(server,app,'h[2].status',1);
apm_option(server,app,'h[2].fstatus',0);
apm_option(server,app,'h[2].sphi',15.1);
apm_option(server,app,'h[2].splo',14.9);
apm_option(server,app,'h[2].tau',10);

% Set controller mode
apm_option(server,app,'nlc.reqctrlmode',3);

% Run APMonitor
apm(server,app,'solve')

% Open web-viewer
apm_web(server,app);

% Retrieve solution (creates solution.csv locally)
solution = apm_sol(server,app);
cc = cell2mat(solution(2:end,:));
time = cc(:,1);
v1 = cc(:,8);
v2 = cc(:,9);
h(:,1:4) = cc(:,10:13);

figure(1)
subplot(3,2,1)
plot(time,v1,'b-');
ylabel('Pump Input (V)')
legend('v_1');

subplot(3,2,2)
plot(time,v2,'b-');
ylabel('Pump Input (V)')
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
ylabel('Height (cm)')
legend('h_1');
xlabel('Time (sec)')

subplot(3,2,6)
plot(time,h(:,2),'b-');
ylabel('Height (cm)')
legend('h_2');
xlabel('Time (sec)')
