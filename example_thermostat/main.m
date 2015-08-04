clear all; close all; clc
addpath('../apm')

s = 'http://byu.apmonitor.com';
a = 'heater';

apm(s,a,'clear all');
apm_load(s,a,'heater.apm');
csv_load(s,a,'heater.csv');

apm_option(s,a,'nlc.imode',6);
apm_option(s,a,'nlc.solver',1);

apm_info(s,a,'MV','int_heater');
apm_option(s,a,'int_heater.status',1);
apm_option(s,a,'int_heater.dcost',0.005);

apm_info(s,a,'CV','t_inside');
apm_option(s,a,'t_inside.status',1);
apm_option(s,a,'t_inside.sphi',4);
apm_option(s,a,'t_inside.splo',3);
apm_option(s,a,'t_inside.tr_init',0);

output = apm(s,a,'solve');
disp(output);

apm_web(s,a);