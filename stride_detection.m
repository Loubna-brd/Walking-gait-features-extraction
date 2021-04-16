function [stepping_period_accel_filt,stepping_period_time_filt,stepping_period_duration_filt,loc_peak,peak_value,time_peak,section_beg,section_end,hr_stepping_period_filt,time_hr_stepping_period_filt] = stride_detection(stepping_period_accel,stepping_period_time,stepping_period_duration,hr_stepping_period,time_hr_stepping_period,min_peak_height,min_peak_distance,min_peak_prominence,window_movmean)
% Detection of strides for each walking periods
%
% Input:
%   - stepping_period_accel: raw acc from stepping periods identified
%   - stepping_period_time: time indices for stepping periods identified
%   - stepping_period_duration: duration of each stepping period in minutes
%   - stepping_period_start_date: start datetime of stepping period in activPAL's time format
%
%   IF NO HEARTRATE FILE PLEASE ENTER NAN FOR FOLLOWING TWO INPUTS
%   - hr_stepping_period: heart rate for a stepping period
%   - time_hr_stepping_period: time indices for heart rate in stepping
%   period
%
%   - min_peak_height: minimum peak height to detect (default 5)
%   - min_peak_distance: minimum distance between peaks (should be < 15, 
%                        otherwise can be bigger than length of whole signal) (default 12)
%   - min_peak_prominence: minimum prominence of a peak (default 5)
%   - window_movmean: size window for moving average to detect outliers in
%   list of distance between peaks (default 100)
%
% Output: 
%   - stepping_period_accel_filt: raw acc from stepping periods with peaks
%   detected
%   - stepping_period_time_filt: time indices for stepping periods with peaks
%   detected
%   - stepping_period_duration_filt: duration of each stepping period in minutes with peaks
%   detected
%   - loc_peak: cell with each peak index within stepping period
%   - peak_value: cell with each peak value within stepping period
%   - time_peak: time of each detected peak within stepping period
%   - section_beg and end: limits for a section of consecutive steps within
%   a stepping periods, removing peaks that were detected as outliers
%   - hr_stepping_period_filt: heart rate for a stepping period with peaks
%   detected
%   - time_hr_stepping_period_filt: time indices for heart rate in stepping
%   period with peaks detected

% Algorithm:
%   1. Filter the z-acc that we will use to detect strides
%   2. Find peaks
%   3. Build list of distance between peaks
%   4. Find outliers in this list using moving average
%   5. Create list of beg and end of a section without outliers
%   6. Filter the variables to remove walking periods without detected
%   peaks

if nargin == 5
    min_peak_height = 5;
    min_peak_distance = 12;
    min_peak_prominence = 5;
    window_movmean = 100;
elseif nargin == 6
    min_peak_distance = 12;
    min_peak_prominence = 5;
    window_movmean = 100;
elseif nargin == 7
    min_peak_prominence = 5;
    window_movmean = 100;
elseif nargin == 8
    window_movmean = 100;
end

stepping_period_accel_filt = stepping_period_accel;
stepping_period_time_filt = stepping_period_time;
stepping_period_duration_filt = stepping_period_duration;

if ~isnan(hr_stepping_period)
    hr_stepping_period_filt = hr_stepping_period;
    time_hr_stepping_period_filt = time_hr_stepping_period;
else
    hr_stepping_period_filt = NaN;
    time_hr_stepping_period_filt = NaN;    
end

k = 1;
k1 = 1;
l_k = []; %list of indices for stepping period without any peak
while k <= length(stepping_period_accel)
    acc = stepping_period_accel{k};
    time = stepping_period_time{k};
    acc_z = acc(:,3);
    acc_z_filt = smooth(acc_z,'lowess');
    if length(acc_z_filt) <= 15 % constraint to be able to use findpeaks with a MinPeakDistance of 12
        l_k = [l_k,k];
        k = k + 1;
    else
        [pks_k,loc_k] = findpeaks(acc_z_filt,'MinPeakHeight',min_peak_height,'MinPeakDistance',min_peak_distance,'MinPeakProminence',min_peak_prominence);
        if isempty(loc_k) == 1
            l_k = [l_k,k]; %list of elements that need to be removed 
            k = k + 1;
        else
            peak_value{k1} = pks_k;
            loc_peak{k1} = loc_k;
            time_peak{k1} = time(loc_k);
            loc1_k = loc_k;
            loc1_k(1) = [];
            loc2_k = loc_k;
            loc2_k(end) = [];

            distance_btw_pk = loc1_k - loc2_k; %create list of distance between peaks
            [TF,~,~,~] = isoutlier(distance_btw_pk','movmean',window_movmean); %detect outliers from this list
            index_outliers = find(TF==1);

            section_beg{k1} = [loc_k(1);loc_k(index_outliers + 1)];
            section_end{k1} = [loc_k(index_outliers);loc_k(end)];
            k = k + 1;
            k1 = k1 + 1;
        end
    end
end

stepping_period_accel_filt(l_k) = [];
stepping_period_time_filt(l_k) = [];
stepping_period_duration_filt(l_k) = [];

if ~isnan(hr_stepping_period_filt)
    hr_stepping_period_filt(l_k) = [];
    time_hr_stepping_period_filt(l_k) = [];  
end

end

