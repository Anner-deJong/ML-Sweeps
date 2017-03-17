function [ temp_net ] = init_net( temp_net, base_net, cur_reg, cur_mu )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


temp_net.trainFcn                    = base_net.trainFcn;                   % 'trainlm' = Levenberg-Marquardt backpropagation using Jacobian derivatives
temp_net.trainParam.showWindow       = base_net.trainParam.showWindow;      % supress pop up window during training
temp_net.trainParam.showCommandLine  = base_net.trainParam.showCommandLine; % instead output in commandwindow
temp_net.trainParam.mu               = cur_mu;                              % Mu
temp_net.trainParam.mu_dec           = base_net.trainParam.mu_dec;          % Mu Decrease Ratio
temp_net.trainParam.mu_inc           = base_net.trainParam.mu_inc;          % Mu Increase Ratio

% stop iteration criteria
temp_net.trainParam.max_fail         = base_net.trainParam.max_fail;        % max # concurrent epochs with validation failures
temp_net.trainParam.epochs           = base_net.trainParam.epochs;          % max # epochs
temp_net.trainParam.min_grad         = base_net.trainParam.min_grad;        % min perfomance gradient
temp_net.trainParam.mu_max           = base_net.trainParam.mu_max;          % Maximum mu

% performance function
temp_net.performFcn                  = base_net.performFcn;                 % mean squared error
temp_net.performParam.regularization = cur_reg;                             % mse regularization value, between 0-1, 0 is none 
temp_net.performParam.normalization  = base_net.performParam.normalization; % none (default), standard (normalizes errors between -2 and 2, corresponding to normalizing outputs and targets between -1 and 1)
                                                                            % 'percent', which normalizes errors between -1 and 1. 
                                                                            % useful for networks with multi-element outputs
% % layer specific parameters
% out_lyr = base_net.numLayers;                % output layer / # of layers
% base_net.layers{out_lyr}.transferFcn;        % activation function of output la

end

