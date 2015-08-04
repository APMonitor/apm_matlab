clear all; close all; clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj_scale = 1;
% number of terms
ny = 3; % output coefficients
nu = 3; % input coefficients
% number of inputs
ni = 2;
% number of outputs
no = 2;
% load data and parse into columns
load test_data.csv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate state space model
addpath('../apm')
sysd = apm_id(test_data,ni,nu,ny);