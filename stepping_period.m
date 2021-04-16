function [index_deb,index_end,stepping_period_accel, stepping_period_time,stepping_period_duration,stepping_period_start_date,hr_stepping_period,time_hr_stepping_period] = stepping_period(fevents,faccel,duration_threshold,fheartrate)
% Extraction of the labeled walking bouts from the activPAL
% Input:
%   - events: event file from AP where the stepping events are labeled
%   - accel: raw uncompressed accelerometer data
%   - duration_threshold: threshold for the duration of stepping periods to keep
%   - heartrate: heartrate file from PolarOH1
% Output:
%   - index_deb and index_end: start and finish index for each stepping
%   period
%   - stepping_period_accel: raw acc from stepping periods identified
%   - stepping_period_time: time indices for stepping periods identified
%   - stepping_period_duration: duration of each stepping period in minutes
%   - stepping_period_start_date: start datetime of stepping period in activPAL's time format
%   - hr_stepping_period: heart rate for a stepping period
%   - time_hr_stepping_period: time indices for heart rate in stepping
%   period
%

% Algorithm new:
%   1. Read events, accel, and heart rate files if any
%   2. Reformat acceleration: conversion from g to m/s2
%   3. Find beginning and end of all stepping activity (labelled 2)
%   4. If the duration of a stepping event is higher than the
%   duration_threshold --> keep in outputs

if nargin == 2
    duration_threshold = 0;
    fheartrate = NaN;
elseif nargin == 3
    fheartrate = NaN;
else
    heartrate = readtable(fheartrate);
end
events = readtable(fevents);
accel = readtable(faccel);

% conversion from g to m/s2
ax_ap = (accel.X./128 -4).*9.81;
ay_ap = (accel.Y./128 -4).*9.81;
az_ap = (accel.Z./128 -4).*9.81;

acc_ap = [ax_ap,ay_ap,az_ap];

time_ap = accel.Time;

if isnan(fheartrate)
    hr_stepping_period = NaN;
    time_hr_stepping_period = NaN;
else
    time_polar = datetime(heartrate.datetime,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSS');
    hr_stepping_period = {};
    time_hr_stepping_period = {};
end
% find indices for beginning and end of each stepping activity
event_type = events.EventType';
stepping = find(event_type==2); % 2 is the label for stepping activity
start_index = stepping(1);
end_index = stepping(end);
start_indices = [start_index stepping(find(diff(stepping)>1)+1)];
end_indices = [stepping(diff(stepping)>1) end_index];

index_deb = {};
index_end = {};
stepping_period_time = {};
stepping_period_accel = {};
stepping_period_duration = {};

i_walkingbouts = 1;

for i = 1:length(start_indices)
    i_beg = start_indices(i);
    i_end = end_indices(i);
    duration = sum(events.Duration_s_(i_beg:i_end));
    if duration >= duration_threshold
        time = events.Time(i_beg:i_end);
        beg_datetime = datetime(time(1),'ConvertFrom','excel');
        end_datetime = datetime(time(1),'ConvertFrom','excel') + seconds(duration);
        end_time = exceltime(end_datetime);
        mask = time_ap >= time(1) & time_ap < end_time;
        list_nonzero = find(mask);
        %step_count_cell{i_walkingbouts} = [sum(step_count(i_beg:i_end)),time(1)];
        index_deb{i_walkingbouts} = list_nonzero(1);
        index_end{i_walkingbouts} = list_nonzero(end);
        stepping_period_time{i_walkingbouts} = time_ap(mask);
        stepping_period_accel{i_walkingbouts} = acc_ap(mask,:);
        walking_AP_datetime = datetime(time_ap(mask),'ConvertFrom','excel');
        stepping_period_duration{i_walkingbouts} = minutes(walking_AP_datetime(end) - walking_AP_datetime(1));
        stepping_period_start_date{i_walkingbouts} = stepping_period_time{i_walkingbouts}(1);

        if ~isnan(fheartrate)
            mask_polar = time_polar >= beg_datetime & time_polar < end_datetime;
            if sum(mask_polar) == 0 % means there are no heart rate data for this walking period
                hr_stepping_period{i_walkingbouts} = NaN;
                time_hr_stepping_period{i_walkingbouts} = NaN;
            else
                hr_stepping_period{i_walkingbouts} = heartrate.value(mask_polar);
                time_hr_stepping_period{i_walkingbouts} = time_polar(mask_polar);
            end
        end

        i_walkingbouts = i_walkingbouts + 1;
    end
end

 
end