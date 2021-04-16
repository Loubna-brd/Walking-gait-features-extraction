function [table_features,C_accel,M_features] = features_extraction(stepping_period_accel_filt,loc_peak,time_peak,section_beg,section_end,l0,n,a_model,b_model,fheartrate)

% Extraction of the features from n strides in each walking period
% Input:
%   - stepping_period_accel_filt: raw acc from stepping periods with peaks
%   detected
%   - section_beg and end: section of consecutive steps (removing peak
%   outliers)
%   - loc_peak: cell with each peak index within stepping period
%   - time_peak: time of each detected peak within stepping period
%   - section_beg and end: limits for a section of consecutive steps within
%   a stepping periods, removing peaks that were detected as outliers
%   - a_model: parameter a for subject-specific model to derive stride
%   speed (if none will be set to 0)
%   - b_model: parameter b for subject-specific model to derive stride
%   speed (if none will be set to 0)
%   - l0: leg length
%   - n: number of strides for a window (default 5)
%   - fheartrate: heartrate file to extract heartrate as a feature
% Output:
%   - table_features: table [l,p]: matrix containing the features for each
%   walking bouts of n strides
%   - C_accel: cell containing all n strides windows from which features
%   have been calculated
% Algorithm:
%   1. Separate each stepping period in n strides
%   2. go through those new walking bouts to calculate the features


if nargin == 9
    fheartrate = NaN;
elseif nargin == 8 
    fheartrate = NaN;
    b_model = 0;
elseif nargin == 7
    fheartrate = NaN;
    b_model = 0;
    a_model = 0;
elseif nargin == 6
    fheartrate = NaN;
    b_model = 0;
    a_model = 0;
    n = 5;
end

grav = 9.80665; % m/s^2

if ~isnan(fheartrate)  
    heartrate = readtable(fheartrate);
    time_polar = datetime(heartrate.datetime,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSS');
end

M_features = zeros(56,20000);

i1 = 1;

for k1 = 1:length(stepping_period_accel_filt)
    section_begk1 = section_beg{k1};
    section_endk1 = section_end{k1};
    list_loc = loc_peak{k1};
    list_t_pks = time_peak{k1};
    
    accelk1 = stepping_period_accel_filt{k1};
    
    k2 = 1;
    k3 = 1;
    loc_bout_n = {}; 
    t_pks_bout_n = {};
    while k2 <= length(section_begk1)
        list_loc_index = list_loc >= section_begk1(k2) & list_loc <= section_endk1(k2);
        list_loc1 = list_loc(list_loc_index);
        list_t_pks1 = list_t_pks(list_loc_index);
        n_pks = length(list_loc1);
        int_div = fix(n_pks/n);
        if int_div == 0
            k2 = k2 + 1;
        else
            M_loc = reshape(list_loc1(1:n_pks-rem(n_pks,n)),[n,int_div]);
            M_t_pks = reshape(list_t_pks1(1:n_pks-rem(n_pks,n)),[n,int_div]);
            t_pks_bout_n{k3} = M_t_pks';
            loc_bout_n{k3} = M_loc';
            k2 = k2 + 1;
            k3 = k3 + 1;
        end
    end
    
    M_loc_n = cat(1,loc_bout_n{:});
    M_t_pks_n = cat(1,t_pks_bout_n{:});
    
    M_t_pks_n_date = datetime(M_t_pks_n,'ConvertFrom','excel');
    
    for i = 1:size(M_loc_n,1)
        accel_n = accelk1(M_loc_n(i,1):M_loc_n(i,n),:);
        
        if ~isnan(fheartrate)
        %get time for hr between time 
            time_index_hr = time_polar >= M_t_pks_n_date(i,1) & time_polar <= M_t_pks_n_date(i,n);

            if sum(time_index_hr) == 0
                hr_average = NaN;
            else
                hr_average = mean(heartrate.value(time_index_hr));
            end
        else
            hr_average = NaN;
        end
               
        features_raw_acc = acc_features_extraction(accel_n(:,1),accel_n(:,2),accel_n(:,3),20);
        
        % calculation of stride frequency
        freq_list = zeros(n-1,1);
        stime_list = zeros(n-1,1);
        for kn = 1:n-1
            freq_list(kn) = 1/seconds(M_t_pks_n_date(i,kn+1)-M_t_pks_n_date(i,kn));
            stime_list(kn) = seconds(M_t_pks_n_date(i,kn+1)-M_t_pks_n_date(i,kn));
        end
        freq = mean(freq_list);
        stride_time = mean(stime_list);

        % calculation of stride speed from stride frequency using power
        % model; value are normalized based on Hof,1996
        freq_norm = freq/sqrt(grav/l0);
        speed_norm = exp(log(a_model*freq_norm)/(1-b_model));
        stride_time_norm = stride_time/sqrt(l0/grav);

        features_raw_acc_array = struct2array(features_raw_acc)';
        
        M_features(:,i1) = [i1; k1; M_t_pks_n(i,1); hr_average;speed_norm;freq_norm;stride_time_norm;features_raw_acc_array];
            
        C_accel{i1} = accel_n;
        
        i1 = i1 + 1;
        
    end
end

M_features( :, ~any(M_features,1) ) = [];
M_features = M_features';
M_features(isinf(M_features)) = 0;
% M_features = M_features(all(M_features,2),:);

colNames = {'index','bout_number','time_first_stride',...
    'average_hr','normalized_stride_speed',...
    'normalized_stride_freq','normalized_stride_time',...
    'mean_ax','mean_ay','mean_az',...
    'var_ax','var_ay','var_az',...
    'std_ax','std_ay','std_az',...
    'skew_ax','skew_ay','skew_az',...
    'kurt_ax','kurt_ay','kurt_az',...
    'mad_ax','mad_ay','mad_az',...
    'mnf_ax','mnf_ay','mnf_az',...
    'mdf_ax','mdf_ay','mdf_az',...
    'snr_ax','snr_ay','snr_az',...
    'pwr_ax','pwr_ay','pwr_az',...
    'ipsd_ax','ipsd_ay','ipsd_az',...
    'step_reg_vt','stride_reg_vt','sym_vt',...
    'stride_reg_ml','step_reg_ap','stride_reg_ap',...
    'sym_ap','jerk_ax','jerk_ay','jerk_az',...
    'zcm_ax','zcm_ay','zcm_az',...
    'norm_ax','norm_ay','norm_az'};

table_features = array2table(M_features,'VariableNames',colNames);

if isnan(fheartrate) && a_model ~= 0 
    table_features.average_hr = [];
elseif ~isnan(fheartrate) && a_model == 0
    table_features.normalized_stride_speed = [];
elseif isnan(fheartrate) && a_model == 0 
    table_features.average_hr = [];
    table_features.normalized_stride_speed = [];
end

end
