addpath('../apm');

% Select server
server = 'http://byu.apmonitor.com';

% Application name
app = 'mixed_integer';

% Clear previous application
apm(server,app,'clear all');

% Load model file
apm_load(server,app,'minlp.apm');

% Option to select solver (1=APOPT, 2=BPOPT, 3=IPOPT)
apm_option(server,app,'nlc.solver',1);

% Solve on APM server
apm(server,app,'solve')

% Retrieve results
disp('Results');
y = apm_sol(server,app);
disp(y)
disp(y.x)

% Display Results in Web Viewer 
url = apm_web_var(server,app);
	
