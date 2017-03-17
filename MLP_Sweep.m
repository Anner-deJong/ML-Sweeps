%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Sweep parameters for MLP Regression                  %
%                               09/11/2016                                %
%                              Anner de Jong                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% run while in output storage directory
current = cd;
cd('____\Output'); %<-- Where you want to store your net models and excel

%% create save names

% current date+time
tt = fix(clock);
hh = num2str(tt(4));
mi = num2str(tt(5));

% excel file name
file     = strcat(datestr(date),'-',hh,'-',mi,'_MLP_Sweep.xlsx');

% model file name

%% fixed initialisation parameters

x       = X_Train';                     % correct input format
t       = Y_Train';                     % correct input format

epsilon = [100; 200; 500; 1000; 2000; 5000];
type    = 'regression';

index   = 6;

%% fixed hyper parameters
    
% validation + test division
% check still
% net.divideFcn = dividetrain;

% training function
base_net.trainFcn   = 'trainlm';             % 'trainlm' = Levenberg-Marquardt backpropagation using Jacobian derivatives
base_net.trainParam.showWindow = false;      % supress pop up window during training
base_net.trainParam.showCommandLine = false; % instead output in commandwindow
%%%     base_net.trainParam.mu = 5;                  % Mu
base_net.trainParam.mu_dec = 0.1;            % Mu Decrease Ratio
base_net.trainParam.mu_inc = 10;             % Mu Increase Ratio

% stop iteration criteria
base_net.trainParam.max_fail   = 100;        % max # concurrent epochs with validation failures
base_net.trainParam.epochs     = 20;         % max # epochs
base_net.trainParam.min_grad   = 1e-7;       % min perfomance gradient
base_net.trainParam.mu_max     = 1e+10;      % Maximum mu

% performance function
base_net.performFcn = 'mse';                 % mean squared error
%%%     base_net.performParam.regularization = 0.5;  % mse regularization value, between 0-1, 0 is none
no = 'none';                            % none (default), standard (normalizes errors between -2 and 2, corresponding to normalizing outputs and targets between -1 and 1)
base_net.performParam.normalization  = no;   % 'percent', which normalizes errors between -1 and 1. 
                                            % useful for networks with multi-element outputs
%     % layer specific parameters
%     out_lyr = base_net.numLayers;                % output layer / # of layers
%     base_net.layers{out_lyr}.transferFcn;        % activation function of output layer

%% determine hyperparameters range

% training function,     net.trainParam.mu
mu_num    = 3;
mu_start  = -3;
mu_finish = 1.7;
mu_range  = logspace(mu_start,mu_finish,mu_num);


% performance function,  base_net.performParam.regularization, mse regularization value, between 0-1, 0 is none
reg_num    = 3;
reg_start  = 0;
reg_finish = 0.7;
reg_range  = linspace(reg_start,reg_finish,reg_num);


% size and # of hidden layers
hid_lys_lys    = [3,5,8,10,12,15,20,25,30];
hid_lys_range  = cell(1,length(hid_lys_lys));

for lys_num = 1:length(hid_lys_lys)
    lay_length = round(logspace(2,1.3, hid_lys_lys(lys_num)));
    hid_lys_range{lys_num} = ones(1,hid_lys_lys(lys_num)) .* lay_length;
end

% % layer specific parameters
% out_lyr = base_net.numLayers;                % output layer / # of layers
% base_net.layers{out_lyr}.transferFcn;        % activation function of output layer

%% write column labels

param_label  = [{'index', 'hid_lys_count', 'cur_reg', 'cur_mu'}];
output_label = [num2cell(epsilon'),'time'];
output_mu    = [num2cell(mu_range)];
output_reg   = [num2cell(reg_range)];

xlswrite(file, {'mu_range'},  'Sheet1', 'B2');
xlswrite(file, output_mu,     'Sheet1', 'D2');
xlswrite(file, {'reg_range'}, 'Sheet1', 'B3');
xlswrite(file, output_reg,    'Sheet1', 'D3');
xlswrite(file, param_label,   'Sheet1', 'B5');
xlswrite(file, output_label,  'Sheet1', 'G5');

%% nested sweep
    
for hid_lys_count = 4:length(hid_lys_range)
    cur_hid_lys = hid_lys_range{hid_lys_count};
    hid_lys_count
    
    for reg_count = 1:length(reg_range)
        cur_reg = reg_range(reg_count);
        
        for mu_count = 1:length(mu_range)
            cur_mu = mu_range(mu_count);
            
            fix(clock)
            
            
            
            % clear important variables
            clear cur_net cur_tr temp_net
            cur_ccr      = 0;
            cur_time     = 0;
            cur_net_name = '';
            
            % initialise net
            temp_net = fitnet(cur_hid_lys);
            cur_net  = init_net(temp_net, base_net, cur_reg, cur_mu);
            
            % train + time
            tic
            [cur_net,cur_tr] = train(cur_net,x,t);   % Train the Network [net,tr]
            cur_time = toc;
            
            % calculate output
            Y_Pred  = (cur_net(X_Valid'))';       % makespan prediction    
            cur_ccr = calc_ccr( Y_Pred, Y_Valid, type, epsilon);
            output  = [cur_ccr', cur_time];
            
            % save network
            cur_net_name = strcat( 'flow_MLP_lys_', num2str(hid_lys_count), '_reg_', num2str(reg_count), '_mu_', num2str(mu_count));
            save(cur_net_name,'cur_net', 'cur_tr');
            
            % write
            param = [index, hid_lys_count, cur_reg, cur_mu]; 
            xlswrite(file, param,  'Sheet1', ['B', num2str(index)])
            xlswrite(file, output, 'Sheet1', ['G', num2str(index)])
            
            index = index + 1;
            
            
            
            
        end
    end
end

%% go back to matlab directory
cd(current);
