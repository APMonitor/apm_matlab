addpath('../apm');

% Select server
server = 'http://byu.apmonitor.com';

% Application name
app = 'trial';

% Clear previous application
apm(server,app,'clear all');

% Load model file
apm_load(server,app,'hs71.apm');

% Option to select solver (1=APOPT, 2=BPOPT, 3=IPOPT)
apm_option(server,app,'nlc.solver',3);

% Solve on APM server
apm(server,app,'solve')

% Retrieve results
disp('Results');
results = apm_sol(server,app)
values = cell2mat(results(2:end,:));

% Display Results in Web Viewer 
url = apm_web_var(server,app);
	
