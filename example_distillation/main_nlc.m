addpath('../apm');

% Clear MATLAB
clear all
close all

% Select server
server = 'http://xps.apmonitor.com'

% Set application name
app = int2str(int32(rand()*10000));

% Clear previous application
apm(server,app,'clear all');

% Load model file
disp ('Load Model')
apm_load(server,app,'distill.apm');

% Load time points for future predictions
disp ('Load CSV File')
csv_load(server,app,'horizon_ctl.csv');

% Load replay replay data for local use
csv = csv_data('replay_ctl.csv');

% APM Variable Classification
% class = FV, MV, SV, CV
%   F or FV = Fixed value - parameter may change to a new value every cycle
%   M or MV = Manipulated variable - independent variable over time horizon
%   S or SV = State variable - model variable for viewing
%   C or CV = Controlled variable - model variable for control
% Names of each variable type in cell arrays
% Same as listed in the model.apm file
FVs = {'feed','x_feed','alpha','atray','acond','areb'};
MVs = {'rr','fbot','sp_x[1]','sp_x[32]'};
SVs = {'x[2]','x[5]','x[10]','x[15]','x[20]','x[25]','x[30]','x[31]'};
CVs = {'x[1]','x[32]'};

% Get number of each variable type
n_FVs = size(FVs,2);
n_MVs = size(MVs,2);
n_SVs = size(SVs,2);
n_CVs = size(CVs,2);

% Set up variable classifications for data flow
% Feedforwards - measured process disturbances
for i = 1:n_FVs,
   apm_info(server,app,'FV',FVs(:,i));
end
% Manipulated variables / parameters
for i = 1:n_MVs,
   apm_info(server,app,'MV',MVs(:,i));
end
% State variables (for display only)
for i = 1:n_SVs,
   apm_info(server,app,'SV',SVs(:,i));
end
% Controlled / Measured variables
for i = 1:n_CVs,
   apm_info(server,app,'CV',CVs(:,i));
end

% Options

% time units (1=sec,2=min,3=hrs,etc)
apm_option(server,app,'nlc.ctrl_units',2);
apm_option(server,app,'nlc.hist_units',3);

% set controlled variable error model type
apm_option(server,app,'nlc.cv_type',1);
apm_option(server,app,'nlc.ev_type',1);

% controller mode (1=simulate, 2=predict, 3=control)
apm_option(server,app,'nlc.reqctrlmode',1);

% read discretization from CSV file
apm_option(server,app,'nlc.csv_read',1);

% turn on historization to see past results
apm_option(server,app,'nlc.hist_hor',200);

% set web plot update frequency
apm_option(server,app,'nlc.web_plot_freq',10);

% Controlled variable (c)
apm_option(server,app,'x[1].sphi',0.95);
apm_option(server,app,'x[1].splo',0.94);
apm_option(server,app,'x[1].tau',20.0);
apm_option(server,app,'x[1].fstatus',0);

apm_option(server,app,'x[32].sphi',0.05);
apm_option(server,app,'x[32].splo',0.04);
apm_option(server,app,'x[32].tau',20.0);
apm_option(server,app,'x[32].fstatus',0);

% Manipulated variables (u)
apm_option(server,app,'rr.upper',10);
apm_option(server,app,'rr.dmax',0.2);
apm_option(server,app,'rr.lower',1);
apm_option(server,app,'rr.fstatus',0);

apm_option(server,app,'fbot.upper',1);
apm_option(server,app,'fbot.dmax',0.05);
apm_option(server,app,'fbot.lower',0);
apm_option(server,app,'fbot.fstatus',0);

% Measured Disturbances
apm_option(server,app,'feed.fstatus',1);
apm_option(server,app,'x_feed.fstatus',1);

% imode (1=ss, 2=mpu, 3=rto, 4=sim, 5=mhe, 6=nlc)
apm_option(server,app,'nlc.imode',1);
apm_option(server,app,'nlc.sensitivity',1);

% steady state solution
apm(server,app,'solve');

% imode (1=ss, 2=mpu, 3=rto, 4=sim, 5=mhe, 6=nlc)
apm_option(server,app,'nlc.imode',6)
apm_option(server,app,'nlc.sensitivity',0);

blank_line = sprintf('\n');
for isim = 1:size(csv,1)-1,
  pause(0.1)

  disp(blank_line)
  disp(['--- Cycle '  num2str(isim) ' of ' num2str(size(csv,1)-1) '---'])

  if (isim==2),
        % turn on controller
        apm_option(server,app,'nlc.reqctrlmode',3);
        % turn on overhead composition control
        apm_option(server,app,'rr.status',1);
        apm_option(server,app,'x[1].sphi',0.952);
        apm_option(server,app,'x[1].splo',0.952);
        apm_option(server,app,'x[1].status',1);
        apm_meas(server,app,'sp_x[1]',0.952);
        % turn on bottoms composition control
        apm_option(server,app,'fbot.status',1);
        apm_option(server,app,'x[32].sphi',0.019);
        apm_option(server,app,'x[32].splo',0.019);
        apm_option(server,app,'x[32].status',1);
        apm_meas(server,app,'sp_x[32]',0.019);
  end

  if (isim==70),
        % set point change
        apm_option(server,app,'x[1].sphi',0.9955);
        apm_option(server,app,'x[1].splo',0.9955);
        apm_option(server,app,'x[32].sphi',0.0095);
        apm_option(server,app,'x[32].splo',0.0095);
        apm_meas(server,app,'sp_x[1]',0.9955);
        apm_meas(server,app,'sp_x[32]',0.0095);
  end

  % FV measurements
  for i = 1:n_FVs,
     name = deblank(FVs(:,i));
     value = csv_element(name,isim,csv);
     if (~isnan(value)),
        apm_meas(server,app,name,value);
     end
  end
  % MV measurements
  for i = 1:n_MVs,
     name = deblank(MVs(:,i));
     value = csv_element(name,isim,csv);
     if (~isnan(value)),
        apm_meas(server,app,name,value);
     end
  end
  % CV measurements
  for i = 1:n_CVs,
     name = deblank(CVs(:,i));
     value = csv_element(name,isim,csv);
     if (~isnan(value)),
        apm_meas(server,app,name,value);
     end
  end
  
  % Run NLC on APMonitor server
  apm(server,app,'solve');

  if (isim==1),
    apm_web(server,app)
  end

end
