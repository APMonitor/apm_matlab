addpath('../apm');

% Clear MATLAB
clc
clear all
close all

% assign server and application names
server = 'http://byu.apmonitor.com';
app = 'nlc_matlab'

% Clear previous application
apm(server,app,'clear all');

% load model variables and equations
apm_load(server,app,'model.apm');

% Set up variable classifications for data flow

% Feedforwards - measured process disturbances
apm_info(server,app,'FV','tau');
% Manipulated variables (for controller design)
apm_info(server,app,'MV','u');
% State variables (for display only)
apm_info(server,app,'SV','x');
% Controlled variables (for controller design)
apm_info(server,app,'CV','y');

% initialize time
time = 0;

% ----------------------------------------------------------
% Steady state solution
% ----------------------------------------------------------
% imode = 1, steady state mode
apm_option(server,app,'nlc.imode',1);
% turn on sensitivity analysis
apm_option(server,app,'nlc.sensitivity',1);

% change the value of tau & u
tau = 5;
u   = 10;

% input value of u and tau
apm_meas(server,app,'u',u);
apm_meas(server,app,'tau',tau);

% solve here for steady state initialization
apm(server,app,'solve')

% retrieve results
x  = apm_tag(server,app,'x.MODEL');
y  = apm_tag(server,app,'y.MODEL');

% store steady state solution
Xs = [time tau u x y];
% ----------------------------------------------------------



% ----------------------------------------------------------
% Dynamic simulation
% ----------------------------------------------------------
% imode = 4, switch to dynamic simulation
apm_option(server,app,'nlc.imode',4);
% internal nodes in the collocation (between 2 and 6)
apm_option(server,app,'nlc.nodes',3);
% turn off sensitivity analysis
apm_option(server,app,'nlc.sensitivity',0);
% simulation step size for every 'solve' command
apm_option(server,app,'nlc.ctrl_time',1.0);
apm_option(server,app,'nlc.ctrl_hor',2);
apm_option(server,app,'nlc.pred_hor',2);
% simulation time units (option 2 = minutes)
apm_option(server,app,'nlc.ctrl_units',2);
% turn on history horizon to see results from web-interface
apm_option(server,app,'nlc.hist_hor',30);
apm_option(server,app,'nlc.hist_units',2);
% turn off measurement biasing of CV
apm_option(server,app,'y.FSTATUS',0);

% step the value of u
u = 20;
apm_meas(server,app,'u',u);

% simulate with APM
for i = 1:10,
  % increment time
  time = time + 1.0;  
  
  % Run APMonitor
  apm(server,app,'solve')

  % Read APM output
  x  = apm_tag(server,app,'x.MODEL');
  y  = apm_tag(server,app,'y.MODEL');

  Xs = [Xs; time tau u x y];
end


% ----------------------------------------------------------
% Steady state solution for new starting point
% ----------------------------------------------------------
% imode = 1, steady state mode
apm_option(server,app,'nlc.imode',1);
apm(server,app,'solve')

% increment time to show SS solution results
time = time+1;

% retrieve results
x  = apm_tag(server,app,'x.MODEL');
y  = apm_tag(server,app,'y.MODEL');

% store steady state solution
Xs = [Xs; time tau u x y];
% ----------------------------------------------------------


% ----------------------------------------------------------
% Nonlinear control with L2 Error model
% ----------------------------------------------------------
% imode = 6, switch to nonlinear control mode
apm_option(server,app,'nlc.imode',6);
% request control mode (1=simulate, 2=predict, 3=control)
apm_option(server,app,'nlc.reqctrlmode',3);
% use squared error model type
apm_option(server,app,'nlc.cv_type',2);
% CV set-point
apm_option(server,app,'y.SP',10);
% set reference trajectory speed
apm_option(server,app,'y.TAU',6);
% turn off measurement biasing of CV
apm_option(server,app,'y.FSTATUS',0);
apm_option(server,app,'y.BIAS',0);
% turn ON the status of the MV and CV
apm_option(server,app,'u.STATUS',1);
apm_option(server,app,'y.STATUS',1);
% add a delta movement constraint to the MV
apm_option(server,app,'u.DMAX',10);

% set up time horizon
apm_option(server,app,'nlc.csv_read',1);

% load time horizon
csv_load(server,app,'data.csv');

% nonlinear control with APM
for i = 1:15,
  % increment time
  time = time + 1;  
  
  % Run APMonitor
  apm(server,app,'solve')

  % Read APM output
  u  = apm_tag(server,app,'u.NEWVAL');
  x  = apm_tag(server,app,'x.MODEL');
  y  = apm_tag(server,app,'y.MODEL');

  Xs = [Xs; time tau u x y];
end

% ----------------------------------------------------------
% Nonlinear control with L1 Error model
% ----------------------------------------------------------
% controller coldstart (start with steady state solution)
apm_option(server,app,'nlc.coldstart',1);
% use L1 (abs value) error model type
apm_option(server,app,'nlc.cv_type',1);
% CV set-point high and low for controller dead-band
apm_option(server,app,'y.SPHI',10.5);
apm_option(server,app,'y.SPLO',9.5);
for i = 1:15,
  % increment time
  time = time + 1;
  
  % Run APMonitor
  apm(server,app,'solve')

  % Read APM output
  u  = apm_tag(server,app,'u.NEWVAL');
  x  = apm_tag(server,app,'x.MODEL');
  y  = apm_tag(server,app,'y.MODEL');

  Xs = [Xs; time tau u x y];
end


figure(1)

subplot(2,1,1);
% plot tau
plot(Xs(:,1),Xs(:,2),'g--');
hold on;
% plot u
plot(Xs(:,1),Xs(:,3),'r-');
xlabel('Time (min)')
ylabel('Inputs')
legend('tau (FV)','u (MV)');
% get min and max values for axis adjustment
x_min = 0;
x_max = max(Xs(:,1)) + 1;
y_min = min(min(Xs(:,2:3))) - 1;
y_max = max(max(Xs(:,2:3))) + 1;
axis([x_min x_max y_min y_max]);
title('Nonlinear Control with APMonitor')

subplot(2,1,2);
% plot x
plot(Xs(:,1),Xs(:,4),'k-.');
hold on;
% plot y
plot(Xs(:,1),Xs(:,5),'b-');
y_min = min(min(Xs(:,4:5))) - 1;
y_max = max(max(Xs(:,4:5))) + 1;
axis([x_min x_max y_min y_max]);
xlabel('Time (min)')
ylabel('Outputs')
legend('x (SV)','y (CV)');

% open web viewer
apm_web(server,app);
