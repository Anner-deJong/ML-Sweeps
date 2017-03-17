%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Sweep parameters for MLP Regression                  %
%                               09/11/2016                                %
%                              Anner de Jong                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% create save names

% current date+time
tt = fix(clock);
hh = num2str(tt(4));
mi = num2str(tt(5));

% excel file name
file     = strcat(datestr(date),'-',hh,'-',mi,'_MoE_Sweep.xlsx');

% model file name

%% fixed initialisation parameters

%Normalize Y
cur_mu      = mean(Y_Train);
cur_sigma   = std(Y_Train);
Y_Tr_Nrm    = (Y_Train - cur_mu) / cur_sigma;
Y_Vl_Nrm    = (Y_Valid  - cur_mu) / cur_sigma;

X           = X_Train;                     % correct input format
y           = Y_Tr_Nrm;                    % correct input format

epsilon = [100; 200; 500; 1000; 2000; 5000];
type    = 'regression';

index   = 6;

%% fixed hyper parameters
    
% training parameters
    moeType         = 'competitive';    % cooperative              
    max_iter        = 200;               % maximum number of iterations
    
%% determine hyperparameters' ranges

% Learnging rate
lrng_num    = 8;
lrng_start  = -6;
lrng_finish = -3;
lrng_range  = logspace(lrng_start,lrng_finish,lrng_num);

% rate of decay
dec_range   = [0.95, 0.98, 0.99 1];

% number of experts
exp_range   = [3,5,10,15,20,25,30];

%% write column labels

param_label  = [{'index', 'no_experts', 'cur_dec', 'cur_lrng_rate'}];
output_label = [num2cell(epsilon'),'time'];
output_lrng  = [num2cell(lrng_range)];
output_dec   = [num2cell(dec_range)];

xlswrite(file, {'lrng_rate_range'},  'Sheet1', 'B2');
xlswrite(file, output_lrng,          'Sheet1', 'D2');
xlswrite(file, {'reg_range'},        'Sheet1', 'B3');
xlswrite(file, output_dec,           'Sheet1', 'D3');
xlswrite(file, param_label,          'Sheet1', 'B5');
xlswrite(file, output_label,         'Sheet1', 'G5');

%% nested sweep
    
for exp_count = 1:length(exp_range)             % no of experts in the MoE
    cur_exp = exp_range(exp_count);
    exp_count
    
    for dec_count = 1:length(dec_range)
        cur_dec = dec_range(dec_count);
        
        for lrng_count = 1:length(lrng_range)
            cur_lrng = lrng_range(lrng_count);
            

            index
            % clear important variables
            clear wgth gate_wgth cur_net cur_tr temp_net
            cur_ccr      = 0;
            cur_time     = 0;
            cur_net_name = '';
            
            % train + time
            tic
            [wgth, gate_wgth] = TrainMoE_alter(type, moeType, ... % <---- insert the name of MoE algo file
                                                 X,        y, ...
                                           cur_exp, max_iter, ...
                                          cur_lrng, cur_dec );
            cur_time = toc;
            
            % calculate output
            [~, r, ~] = TestMoE_alter(type, X_Valid, Y_Vl_Nrm, wgth, gate_wgth);  % <---- insert the name of MoE algo file
            Y_Pred    = r * cur_sigma + cur_mu;
            cur_ccr   = calc_ccr( Y_Pred, Y_Valid, type, epsilon);
            output    = [cur_ccr', cur_time];
            
            % save network
            cur_net_name = strcat( 'flow_MoE_lys_', num2str(exp_count), '_reg_', num2str(dec_count), '_lrng_', num2str(lrng_count));
            save(cur_net_name, 'wgth', 'gate_wgth', 'cur_mu', 'cur_sigma');
            
            % write
            param = [index, exp_count, cur_dec, cur_lrng]; 
            xlswrite(file, param,  'Sheet1', ['B', num2str(index)])
            xlswrite(file, output, 'Sheet1', ['G', num2str(index)])
            
            index = index + 1;
            
            
            
            
        end
    end
end

%% go back to matlab directory
cd(current);
