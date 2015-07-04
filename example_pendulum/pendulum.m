% Add APM functions to path
addpath('../apm');

% Clear MATLAB
clear all
close all

% Select server
server = 'http://xps.apmonitor.com';

% Application name
app = 'pendulum';

% Clear previous application
apm(server,app,'clear all');

% Load plant data data
csv = csv_data('replay.csv');

% Load model file and time horizon csv info
apm_load(server,app,'pendulum.apm');

% Fixed variables
FVs = ['pend.g'];

% Manipulated variables
MVs = ['pend.m';
       'pend.s'];

SVs = ['pend.lam'];

CVs = ['pend.x';
       'pend.y';
       'pend.v';
       'pend.w'];

% Get number of each variable type
n_FVs = size(FVs,1);
n_MVs = size(MVs,1);
n_SVs = size(SVs,1);
n_CVs = size(CVs,1);

% Set up variable classifications for data flow
% Feedforwards - measured process disturbances
for i = 1:n_FVs,
   apm_info(server,app,'FV',FVs(i,:));
end
% Manipulated variables / parameters
for i = 1:n_MVs,
   apm_info(server,app,'MV',MVs(i,:));
end
% State variables (for display only)
for i = 1:n_SVs,
   apm_info(server,app,'SV',SVs(i,:));
end
% Controlled / Measured variables
for i = 1:n_CVs,
   apm_info(server,app,'CV',CVs(i,:));
end

% -----------------------------------------------------------------
% simulation step size for every 'solve' command
next_row_interval = 1; % the next row interval for skipping over plant data
                       %   for a more course replay 
collection_interval = 0.1; % time interval for each plant data row
interval = next_row_interval * collection_interval;
% imode = 5, MHE mode
apm_option(server,app,'nlc.imode',5);
% estimated variable type (1=L1 norm, 2=Squared error objective)
apm_option(server,app,'nlc.ev_type',2);
% csv_read = 0 (OFF) - don't read horizon info from pendulum.csv
apm_option(server,app,'nlc.csv_read',0);
horizon = 21;
apm_option(server,app,'nlc.ctrl_hor',horizon);
apm_option(server,app,'nlc.pred_hor',horizon);
apm_option(server,app,'nlc.ctrl_time',interval);
apm_option(server,app,'nlc.pred_time',interval);
% nodes = 3, internal nodes in the collocation structure (2-6)
apm_option(server,app,'nlc.nodes',3);
% time units (1=sec,2=min,3=hrs,etc)
apm_option(server,app,'nlc.ctrl_units',1);
apm_option(server,app,'nlc.hist_units',1);
% set trending horizons for web-viewer
apm_option(server,app,'nlc.hist_hor',200);
% calculate initial conditions - OFF
apm_option(server,app,'nlc.icd_calc',0);
% set horizons
apm_option(server,app,'nlc.hist_hor',200);
% turn sensitivity calc off
apm_option(server,app,'nlc.sensitivity',0);

% use measurement for x position
apm_option(server,app,'pend.x.FSTATUS',1);
apm_option(server,app,'pend.x.WMEAS',50);
apm_option(server,app,'pend.x.WMODEL',5);

% determine mass and length of pendulum
apm_option(server,app,'pend.s.STATUS',1);
apm_option(server,app,'pend.s.LOWER',0.1);
apm_option(server,app,'pend.s.UPPER',10);
apm_option(server,app,'pend.s.MV_STEP_HOR',horizon);

apm_option(server,app,'pend.m.STATUS',1);
apm_option(server,app,'pend.m.LOWER',0.1);
apm_option(server,app,'pend.m.UPPER',20);
apm_option(server,app,'pend.m.MV_STEP_HOR',horizon);

% MHE with APM
row = 0;
time = 0;
for isim = 1:100,  
  tic

  % row for data access
  row = row + next_row_interval;

  % store time values
  Xm(isim,1) = time;
  
  % FV measurements
  for i = 1:n_FVs,
     name = strtrim(FVs(i,:));
     value = csv_element(name,row,csv);
     if (~isnan(value)),
        apm_meas(server,app,name,value);
        % get column number
        col = csv_lookup(name,csv);
        % store measured value
        if(col>=1), Xm(isim,col) = value;, end;
     end
  end
  % MV measurements
  for i = 1:n_MVs,
     name = strtrim(MVs(i,:));
     value = csv_element(name,row,csv);
     if (~isnan(value)),
        apm_meas(server,app,name,value);
        % get column number
        col = csv_lookup(name,csv);
        % store measured value
        if(col>=1), Xm(isim,col) = value;, end;
     end
  end
  % CV measurements
  for i = 1:n_CVs,
     name = strtrim(CVs(i,:));
     value = csv_element(name,row,csv);
     if (~isnan(value)),
        apm_meas(server,app,name,value);
        % get column number
        col = csv_lookup(name,csv);
        % store measured value
        if(col>=1), Xm(isim,col) = value;, end;
     end
  end
  disp('Input measurements time')
  toc

  tic
  % Run APMonitor
  apm(server,app,'solve')

  disp('Overall solve time')
  toc
  
  tic
  % SV predictions
  for i = 1:n_SVs,
     name = strtrim(SVs(i,:));
     value = apm_tag(server,app,[name '.MODEL']);
     Xs(isim,i) = value;
  end
  % CV predictions
  for i = 1:n_CVs,
     name = strtrim(CVs(i,:));
     value = apm_tag(server,app,[name '.MODEL']);
     % get column number
     col = csv_lookup(name,csv);
     % store results
     Xc(isim,i) = value;
  end
  disp(['Store results time for cycle ' num2str(isim)])
  toc

  % for Matlab trends
  time = time + interval;

end



plot_all;


