%% SCRIPT test_script.m 
%   Multi-task learning training/testing example. This example illustrates
%   how to perform split data into training part and testing part, and how
%   to use training data to build prediction model (via cross validation).
%   
%% LICENSE
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%   Copyright (C) 2011 - 2012 Jiayu Zhou and Jieping Ye 
%
%% Related functions
%   mtSplitPerc, CrossValidation1Param, Least_Trace

clear; clc;

addpath('../../MALSAR/functions/low_rank/');
addpath('../../MALSAR/utils/');


% load data
load_data = load('../../data/school.mat');

X = load_data.X;
Y = load_data.Y;

% split data into training and testing.
training_percent = 0.3;
[X_tr, Y_tr, X_te, Y_te] = mtSplitPerc(X, Y, training_percent);

% preprocessing data
for t = 1: length(X)
    X_tr{t} = zscore(X_tr{t});  % normalization
    X_te{t} = zscore(X_te{t});
    X_tr{t} = [X_tr{t} ones(size(X_tr{t}, 1), 1)]; % add bias. 
    X_te{t} = [X_te{t} ones(size(X_te{t}, 1), 1)];
end



% the function used for evaluation.
eval_func_str = 'eval_MTL_rmse';
higher_better = false;  % mse is lower the better.

% cross validation fold
cv_fold = 5;

% optimization options
opts = [];
opts.maxIter = 100;

% model parameter range
param_range = [0.001 0.01 0.1 1 10 100 1000 10000];

fprintf('Perform model selection via cross validation: \n')
[ best_param, perform_mat] = CrossValidation1Param...
    ( X_tr, Y_tr, 'Least_Trace', opts, param_range, cv_fold, eval_func_str, higher_better);

%disp(perform_mat) % show the performance for each parameter.

% build model using the optimal parameter 
W = Least_Trace(X_tr, Y_tr, best_param, opts);

% show final performance
eval_func = str2func(eval_func_str);
final_performance = eval_func(Y_te, X_te, W);
fprintf('Performance on test data: %.4f\n', final_performance);