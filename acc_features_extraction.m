function gait_features = acc_features_extraction(X,Y,Z,fs)
% Features extraction for gait acceleration signal
% Input:
%   - X, Y, Z: Raw acceleration for the three axes
%   - fs: sampling frequency
% Output:
%   - gait_features: cell containing 49 features 

% for activPAL
%ML --> Y
%AP --> Z
%vert --> X

grav = 9.81;
Ts = 1/fs;

% If using this algorithm separately for the activPAL, convert from g to
% m/s2:
% X = (ActivPal.X./128 - 4)*grav;
% Y = (ActivPal.Y./128 - 4)*grav;
% Z = (ActivPal.Z./128 - 4)*grav;
% 
% ActivPal_acc = [X,Y,Z];
gait_features.mean_x = mean(X);
gait_features.mean_y = mean(Y);
gait_features.mean_z = mean(Z);

gait_features.var_x = var(X);
gait_features.var_y = var(Y);
gait_features.var_z = var(Z);

gait_features.std_x = std(X);
gait_features.std_y = std(Y);
gait_features.std_z = std(Z);

%skewness
gait_features.sk_x = skewness(X);
gait_features.sk_y = skewness(Y);
gait_features.sk_z = skewness(Z);

%kurtosis
gait_features.kurt_x = kurtosis(X);
gait_features.kurt_y = kurtosis(Y);
gait_features.kurt_z = kurtosis(Z);

%mean absolute deviation
gait_features.mad_x = mad(X);
gait_features.mad_y = mad(Y);
gait_features.mad_z = mad(Z);

%mean frequency
gait_features.meanfreq_x = meanfreq(X,fs);
gait_features.meanfreq_y = meanfreq(Y,fs);
gait_features.meanfreq_z = meanfreq(Z,fs);

%median frequency
gait_features.medfreq_x = medfreq(X,fs);
gait_features.medfreq_y = medfreq(Y,fs);
gait_features.medfreq_z = medfreq(Z,fs);

%Signal to noise ratio
gait_features.snr_x = snr(X);
gait_features.snr_y = snr(Y);
gait_features.snr_z = snr(Z);

%power of the signal
gait_features.pwr_x = rms(X)^2;
gait_features.pwr_y = rms(Y)^2;
gait_features.pwr_z = rms(Z)^2;

%integral power spectral density
Nx = length(X);
xdft = fft(X);
xdft = xdft(1:(Nx/2+1));
psdx = (1/(fs*Nx)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
psd_x = 10*log10(psdx);

gait_features.ipsd_x = trapz(psd_x); %

Ny = length(Y);
xdft = fft(Y);
xdft = xdft(1:Ny/2+1);
psdx = (1/(fs*Ny)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
psd_y = 10*log10(psdx);

gait_features.ipsd_y = trapz(psd_y);

Nz = length(Z);
xdft = fft(Z);
xdft = xdft(1:Nz/2+1);
psdx = (1/(fs*Nz)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
psd_z = 10*log10(psdx);

gait_features.ipsd_z = trapz(psd_z);

%symmetry
ac_x = autocorr(X);
gait_features.step_reg_vt = ac_x(2);
gait_features.stride_reg_vt = ac_x(3);
gait_features.sym_vt = abs(ac_x(3) - ac_x(2));

ac_y = autocorr(Y);
gait_features.stride_reg_ml = ac_y(3);

ac_z = autocorr(Z);
gait_features.step_reg_ap = ac_z(2);
gait_features.stride_reg_ap = ac_z(3);
gait_features.sym_ap = abs(ac_z(3) - ac_z(2));

% Jerk
gait_features.jerk_x = trapz(X);
gait_features.jerk_y = trapz(Y);
gait_features.jerk_z = trapz(Z);

% Zero Crossing 
zcd = dsp.ZeroCrossingDetector;
gait_features.ZCM_ax = double(zcd(X));
gait_features.ZCM_ay = double(zcd(Y));
gait_features.ZCM_az = double(zcd(Z));

% Norm
gait_features.ax_norm = norm(X);
gait_features.ay_norm = norm(Y);
gait_features.az_norm = norm(Z);

end












