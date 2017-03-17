function [ ccr ] = calc_ccr( Y_Calc, Y_Corr, type, epsilon )
% Calculate the CCR for any given correct and calculated output
% Anner, 7-11-2016

% both regression & classification
no_samp   = size(Y_Calc,1);


% classification
if strcmp(type,'classification')

    [~,corr_ind_Test]  = max(Y_Corr,[],2);                  % indices (classes) for correct y
    diff               = Y_Calc - corr_ind_Test;            % correctly classified if this diff = 0
    ccr                = sum(diff==0) / no_samp;            % correct classification rate

    
% regression   
elseif strcmp(type,'regression')
    
    no_eps    = length(epsilon);
    ccr       = zeros(no_eps, 1);
    
    for n = 1 : no_eps
        
        cur_eps = epsilon(n);

        diff      = max(abs(Y_Calc-Y_Corr) - cur_eps, 0);   % correct classified if this diff = 0
        diff_NaN  = diff .* Y_Calc;                         % correct for NaN's
        cur_ccr   = sum(diff_NaN==0) / no_samp;             % correct classification rate

        ccr(n) = cur_ccr;
        
    end
    
end

% retrieve the correct makespans
% idL = sub2ind(size(Test_makespans), 1:no_samp, calc_ind');
% calc_makespan = Test_makespans(idL)';

end

