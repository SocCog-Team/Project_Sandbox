function [ output_args ] = Test_eventIDE_ADC_signallog_v3( input_args )
%TEST_EVENTIDE_ADC_SIGNALLOG Summary of this function goes here
%   Detailed explanation goes here

% 	TrackerLog_FQN = fullfile('/', 'space', 'data_local', 'moeller', 'DPZ', 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', ...
% 		'2020', '200120', '20200120T164328.A_SMAccPhot.B_None.SCP_01.sessiondir', 'trackerlogfiles', ...
% 		'20200120T164328.A_SMAccPhot.B_None.SCP_01.TID_NISignalFileWriterADC.signallog'); % .txt.gz
% 	[ data_struct ] = fnParseEventIDETrackerLog_v01(TrackerLog_FQN, column_separator, force_number_of_columns, forced_header_string);

% 



% load a test dat set

% RP VGA with splitter 1920x1080, 60Hz (Win10 driver interface), 
%	Nvidia Control panel: eMotionST3: 60.00 Hz; DELL U2412M: 59.95Hz
%	60Hz EventIDE graphics mode, OLED reports 60.0Hz
%	-> photo diode implies 120/60Hz, Oscilloscope measured 60.24Hz
% -> ??? tight refresh time histograms BUT high latency ~50ms (3-4 frames)
%test_session_id = '20200513T130845.A_AccXYZ.B_TestB.SCP_01.sessiondir';

test_session_id = '20200522T143126.A_AccXYZ.B_TestB.SCP_01.sessiondir';
session_struct = fnLoadDataBySessionDir(test_session_id);



chan_names = {'EventIDE_TmeStamp', 'MotitorSpotDetector_LCD_level', 'RenderTriggerDO', 'AccelerationSensor_X', 'AccelerationSensor_Y', 'AccelerationSensor_Z'};
			
%LogHeader: {'Timestamp'  'Dev1/ai0'  'Dev1/ai1'  'Dev1/ai2'}
ADC_data = session_struct.signallog_NISignalFileWriterADC;
corr_time_list = ADC_data.data(:, ADC_data.cn.Tracker_corrected_EventIDE_TimeStamp);
uncorr_time_list = ADC_data.data(:, ADC_data.cn.UncorrectedEventIDE_TimeStamp);

% tmp = [diff(corr_time_list), diff(uncorr_time_list)];
% plot([diff(corr_time_list), diff(uncorr_time_list)]);
time_vec = uncorr_time_list;
time_vec = corr_time_list;




corr_time_offset = corr_time_list(1);
corr_time_vec = corr_time_list - corr_time_offset;
corr_sample_subset = (1:1:length(corr_time_vec));

uncorr_time_offset = uncorr_time_list(1);
uncorr_time_vec = uncorr_time_list - uncorr_time_offset;
uncorr_sample_subset = (1:1:length(uncorr_time_vec));




%time_offset = 0;
time_offset = time_vec(1);
time_vec = time_vec - time_offset;
%sample_subset_index= time_vec(100000:end,:);
sample_subset = (1:1:length(time_vec));

%sample_subset(20000:1:200000);
% also plot render times as vertical lines

% also plot RTs/ touch traces


% data offset

% touches as registered by eventide
trial_log = session_struct.triallog;
IF_touch_onset_list = trial_log.data(:, trial_log.cn.A_InitialFixationTouchTime_ms) ;
IF_touch_offset_list = trial_log.data(:, trial_log.cn.A_InitialFixationAdjReleaseTime_ms);

IF_touch_onset_list(IF_touch_onset_list == 0) = [];
IF_touch_offset_list(IF_touch_offset_list == 0) = [];


IF_touch_onset_list = IF_touch_onset_list - time_offset;
IF_touch_offset_list = IF_touch_offset_list - time_offset;



%touch_dur = IF_touch_offset_list - IF_touch_onset_list;

% render events
render_timestamps = trial_log.Render.data(:, trial_log.Render.cn.Timestamp);
render_timestamps = render_timestamps - time_offset;

use_PhotoDiodeRenderer = 1;
% get the photo diode information render information from evenIDE, if available
if isfield(trial_log, 'PhotoDiodeRenderer') && ~isempty(trial_log.PhotoDiodeRenderer)
	pd_render_timestamps = trial_log.PhotoDiodeRenderer.data(:, trial_log.PhotoDiodeRenderer.cn.RenderTimestamp_ms);
	pd_render_timestamps = pd_render_timestamps - time_offset;
	% onsets	
	onset_tmp_idx = find(trial_log.PhotoDiodeRenderer.data(:, trial_log.PhotoDiodeRenderer.cn.Visible) == 1);
	pd_render_onset_timestamps = trial_log.PhotoDiodeRenderer.data(onset_tmp_idx, trial_log.PhotoDiodeRenderer.cn.RenderTimestamp_ms);
	pd_render_onset_timestamps = pd_render_onset_timestamps - time_offset;
	% offsets
	offset_tmp_idx = find(trial_log.PhotoDiodeRenderer.data(:, trial_log.PhotoDiodeRenderer.cn.Visible) == 1);
	pd_render_offset_timestamps = trial_log.PhotoDiodeRenderer.data(offset_tmp_idx, trial_log.PhotoDiodeRenderer.cn.RenderTimestamp_ms);
	pd_render_offset_timestamps = pd_render_offset_timestamps - time_offset;
else
	use_PhotoDiodeRenderer = 0;
	pd_render_timestamps = render_timestamps;
end

figure('Name', 'ADC Test');
subplot(3, 1, 1)
title(chan_names{2});
plot(time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai3));
hold on
xlabel('Samples');
y_lim = get(gca(), 'YLim');

for i_IFtouch_onset = 1 : length(IF_touch_onset_list)
	plot([IF_touch_onset_list(i_IFtouch_onset), IF_touch_onset_list(i_IFtouch_onset)], y_lim, 'Color', [0 1 0]);
end
for i_IFtouch_offset = 1 : length(IF_touch_offset_list)
	plot([IF_touch_offset_list(i_IFtouch_offset), IF_touch_offset_list(i_IFtouch_offset)], y_lim, 'Color', [1 0 0]);
end


hold off



subplot(3, 1, 2)
title(chan_names{3});
plot(time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai0));
hold on
for i_render_timestamps = 1 : length(render_timestamps)
	plot([render_timestamps(i_render_timestamps), render_timestamps(i_render_timestamps)], y_lim, 'Color', [0 1 0]);
end

hold off
xlabel('Samples');

subplot(3, 1, 3)
title(chan_names{4});
plot(time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai1));
xlabel('Samples');


%sample_subset = (500000:1:length(time_vec));

figure('Name', 'RenderTrigger')
plot(time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai0)); % the photo diode signal
hold on
for i_render_timestamps = 1 : length(render_timestamps)
	plot([render_timestamps(i_render_timestamps), render_timestamps(i_render_timestamps)], y_lim, 'Color', [0 1 0]);
end
plot(time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai1), 'Color', [1 0 0]);

hold off
xlabel('Samples');



% avoid the initial period that contains gunk (sampling started before output triggers asserted)
sample_offset = 1000000;
sample_offset = 0;
sample_subset = (1+sample_offset:1:length(time_vec));
cut_off_time = time_vec(1+sample_offset);
time = time_vec(sample_subset);

% the render time stamps
render_timestamps_list = render_timestamps(render_timestamps >= cut_off_time);


% threshold the render trigger
render_trigger_voltage = ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai1);
rt_high_samples_idx = find(render_trigger_voltage >= 3);

% get the differences
delta_rt_voltage = diff(render_trigger_voltage);
rt_onset_sample_idx = find(delta_rt_voltage >= 3) + 1;
rt_offset_sample_idx = find(delta_rt_voltage <= -3) + 1;
rt_onset_sample_timestamp_list = time(rt_onset_sample_idx);
rt_offset_sample_timestamp_list = time(rt_offset_sample_idx);



% threshold the PhotoDiode signal and get 
photo_diode_voltage = ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai0);
sample_subset_time = time(sample_subset);
%pd_high_samples_idx = find(photo_diode_voltage >= 3);
% get the differences
delta_pd_voltage = diff(photo_diode_voltage);
% find the transients
pd_onset_sample_idx = find(delta_pd_voltage >= 3) + 1; % shift by one to account for diff output being 1 shorter that its inputs
pd_offset_sample_idx = find(delta_pd_voltage <= -3) + 1;

pd_onset_sample_timestamp_list = sample_subset_time(pd_onset_sample_idx);
pd_offset_sample_timestamp_list = sample_subset_time(pd_offset_sample_idx);

% find the display periods of the PhotoDiodeDriver stimulus
% the first sample is an offset of offset by definition, so make sure we
% get a delta showing this
pd_onset_diff = diff([pd_onset_sample_idx(1); pd_onset_sample_idx]);
pd_offset_diff = diff([pd_offset_sample_idx(1); pd_offset_sample_idx]);

pd_onset_sample_timestamp_diff_list = diff([pd_onset_sample_timestamp_list(1); pd_onset_sample_timestamp_list]);
pd_offset_sample_timestamp_diff_list = diff([pd_offset_sample_timestamp_list(1); pd_offset_sample_timestamp_list]);


%figure('Name', 'PhotoDiodeInterOnsetInterval')
%histogram((pd_onset_sample_timestamp_diff_list(find((pd_onset_sample_timestamp_diff_list * 1000) < 30)) * 1000));
%pd_onset_sample_timestamp_diff_list * 1000
tmp_data_idx = pd_onset_sample_timestamp_diff_list <= (30);
tmp_data = pd_onset_sample_timestamp_diff_list(tmp_data_idx);
%histogram( tmp_data );
% calculate the screen refresh times:
avg_interframe_delay_ms = mean(tmp_data(find(tmp_data <= 16 & tmp_data >= 5)));
avg_screen_framerate = 1000/avg_interframe_delay_ms;
disp(['PhotoDiode pulses coming in at ~' num2str(avg_screen_framerate), ' Hz, with ', num2str(avg_interframe_delay_ms), 'ms inter pulse delay']);
% the OLED panel runds at ~ 120 Hz, so get the best matching 
disp(['Actual screen refreshes at ~' num2str(0.5 * avg_screen_framerate), ' Hz, with ', num2str(2.0 * avg_interframe_delay_ms), 'ms inter pulse delay']);


% assume that at 2KHz sampling and 60Hz screen refresh and break is at
% least one frame
sampling_rate_hz = 2000;
frame_rate_hz = 58.9;
frame_rate_hz = (0.5 * avg_screen_framerate); % take the empirically measured frame rate instead?
samples_per_frame = sampling_rate_hz / frame_rate_hz;
min_frames_per_gap = 1.5;


proto_pd_block_onset_idx = find(pd_onset_diff >= (samples_per_frame * (min_frames_per_gap)));
proto_pd_block_offset_idx = find(pd_offset_diff >= (samples_per_frame * (min_frames_per_gap)));

pd_block_onset_sample_idx = pd_onset_sample_idx(proto_pd_block_onset_idx);
pd_block_offset_sample_idx = pd_offset_sample_idx(proto_pd_block_offset_idx);
pd_block_onset_timestamp_list = time(pd_block_onset_sample_idx);
pd_block_offset_timestamp_list = time(pd_block_offset_sample_idx);


onset_rendertrigger_rendertime_delta = zeros(size(rt_onset_sample_timestamp_list));
for i_onset = 1 : length(rt_onset_sample_timestamp_list)
	cur_onset_time = rt_onset_sample_timestamp_list(i_onset);
	onset_photodiode_rendertime_delta(i_onset) = min(abs(cur_onset_time - render_timestamps_list));
end
%figure('Name', 'RenderTrigger versus RendeTimes');
%histogram(onset_photodiode_rendertime_delta, (0:0.1:20));


if (use_PhotoDiodeRenderer)
	
	%figure('Name', 'PhotoDiodeSignalOnset versus PhotoDiodeRenderTimestamp')
	onset_photodiode_rendertrigger_delta = zeros(size(pd_block_onset_timestamp_list));
	onset_photodiodeAI_photodiode_rendertrigger_delta = zeros(size(pd_block_onset_timestamp_list));
	% try to find the best matching photo diode render timestamp in pd_render_onset_timestamps
	for i_onset = 1 : length(pd_block_onset_timestamp_list)
		cur_pd_block_onset_time = pd_block_onset_timestamp_list(i_onset);
		onset_photodiode_rendertrigger_delta(i_onset) = min(abs(cur_pd_block_onset_time - rt_onset_sample_timestamp_list));
		onset_photodiodeAI_photodiode_rendertrigger_delta(i_onset) = min(abs(cur_pd_block_onset_time - pd_render_onset_timestamps));
	end
	%legend_text = {};
	%subplot(1, 2, 1)
	%histogram(onset_photodiode_rendertrigger_delta, (30:1:100));
	%legend_text{end+1} = 'NIRenderTriggerDO';
	%hold on
	%histogram(onset_photodiodeAI_photodiode_rendertrigger_delta, (30:1:100));
	%legend_text{end+1} = 'PhotoDiodeOnset';
	%hold off
	%legend(legend_text);
	%subplot(1, 2, 2)
	
	%plot(onset_photodiode_rendertrigger_delta, 'Color', [0 1 0]);
	%plot(onset_photodiodeAI_photodiode_rendertrigger_delta, 'Color', [0 1 0]);

	hold on
	x_lim = get(gca(), 'XLim');
	frame_period_ms = 1000 / frame_rate_hz;
	%for i_frame = 2 : 5
	%	plot(x_lim, [frame_period_ms*i_frame, frame_period_ms*i_frame], 'Color', [0 0 0]);
	%end
	%plot(onset_photodiode_rendertime_delta, 'Color', [1 0 0]);
%	x_lim = get(gca(), 'XLim');
	frame_period_ms = 1000 / frame_rate_hz;
%	for i_frame = 2 : 5
%		plot(x_lim, [frame_period_ms*i_frame, frame_period_ms*i_frame], 'Color', [0 0 0]);
%	end
%	hold off
	

end


onset_photodiode_rendertrigger_delta = zeros(size(pd_block_onset_timestamp_list));
onset_photodiode_rendertime_delta = zeros(size(pd_block_onset_timestamp_list));
for i_onset = 1 : length(pd_block_onset_timestamp_list)
	cur_pd_block_onset_time = pd_block_onset_timestamp_list(i_onset);
	onset_photodiode_rendertrigger_delta(i_onset) = min(abs(cur_pd_block_onset_time - rt_onset_sample_timestamp_list));
	onset_photodiode_rendertime_delta(i_onset) = min(abs(cur_pd_block_onset_time - render_timestamps_list));
end
%figure('Name', 'BlockOnset versus Trigger/Time');
%histogram(onset_photodiode_rendertrigger_delta, (30:1:100));
%hold on
%histogram(onset_photodiode_rendertime_delta, (30:1:100));
%hold off


offset_photodiode_rendertrigger_delta = zeros(size(pd_block_offset_timestamp_list));
offset_photodiode_rendertime_delta = zeros(size(pd_block_offset_timestamp_list));
for i_offset = 1 : length(pd_block_offset_timestamp_list)
	cur_pd_block_offset_time = pd_block_offset_timestamp_list(i_offset);
	offset_photodiode_rendertrigger_delta(i_offset) = min(abs(cur_pd_block_offset_time - rt_onset_sample_timestamp_list));
	offset_photodiode_rendertime_delta(i_offset) = min(abs(cur_pd_block_offset_time - render_timestamps_list));
end
%figure('Name', 'BlockOffset versus Trigger/Time');
%histogram(offset_photodiode_rendertrigger_delta, (30:1:100));
%hold on
%histogram(offset_photodiode_rendertime_delta, (30:1:100));
%hold off


%figure('Name', 'BlockOnset versus Trigger/Time per event');
%plot(onset_photodiode_rendertrigger_delta, 'Color', [0 1 0]);
%hold on
x_lim = get(gca(), 'XLim');
frame_period_ms = 1000 / frame_rate_hz;
%for i_frame = 2 : 5
%	plot(x_lim, [frame_period_ms*i_frame, frame_period_ms*i_frame], 'Color', [0 0 0]);
%end
%plot(onset_photodiode_rendertrigger_delta, 'Color', [0 1 0]);
%plot(onset_photodiode_rendertime_delta, 'Color', [1 0 0]);
x_lim = get(gca(), 'XLim');
frame_period_ms = 1000 / frame_rate_hz;
%for i_frame = 2 : 5
%	plot(x_lim, [frame_period_ms*i_frame, frame_period_ms*i_frame], 'Color', [0 0 0]);
%end
set(gca(), 'YLim', [0 100]);
hold off

sample_offset = 0;
sample_offset = 1000000;
sample_offset = 200000;
%sample_offset = 0;

sample_end = length(time_vec);
%sample_end = 30000;
sample_subset = (1+sample_offset:1:sample_end-300000);

%figure('Name', 'RenderTrigger')
%plot(time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai0)); % the photo diode signal
%hold on

% what is going on with the timestamps


%plot(uncorr_time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai0), 'Color', [0 0 0.33]); % the photo diode signal


y_lim = get(gca(), 'YLim');
%for i_render_timestamps = 1 : length(render_timestamps)
%	plot([render_timestamps(i_render_timestamps), render_timestamps(i_render_timestamps)], y_lim, 'Color', [0 1 0]);
%end
%plot(time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai1), 'Color', [1 0 0]);
%plot(uncorr_time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai1), 'Color', [0.33 0 0]);


%for i_pd_block_onset_timestamp = 1 : length(pd_block_onset_timestamp_list)
%	plot([pd_block_onset_timestamp_list(i_pd_block_onset_timestamp), pd_block_onset_timestamp_list(i_pd_block_onset_timestamp)], y_lim, 'Color', [1 0 1]);
%end
%for i_pd_block_offset_timestamp = 1 : length(pd_block_offset_timestamp_list)
%	plot([pd_block_offset_timestamp_list(i_pd_block_offset_timestamp), pd_block_offset_timestamp_list(i_pd_block_offset_timestamp)], y_lim, 'Color', [0 0 0]);
%end
xlim([time_vec(1+sample_offset), time_vec(sample_end)]);
%hold off
%xlabel('Samples');



% the accelerometer traces
figure('Name', 'ADC Test');
%subplot(3, 1, 1)
title(chan_names{2});
plot(time_vec(sample_subset), ADC_data.data(sample_subset, ADC_data.cn.Dev1_ai3));
hold on
xlabel('Samples');
y_lim = get(gca(), 'YLim');


for i_IFtouch_onset = 1 : length(IF_touch_onset_list)
	plot([IF_touch_onset_list(i_IFtouch_onset), IF_touch_onset_list(i_IFtouch_onset)], y_lim, 'Color', [0 1 0]);
end
for i_IFtouch_offset = 1 : length(IF_touch_offset_list)
	plot([IF_touch_offset_list(i_IFtouch_offset), IF_touch_offset_list(i_IFtouch_offset)], y_lim, 'Color', [1 0 0]);
end
for i_pd_block_onset_timestamp = 1 : length(pd_block_onset_timestamp_list)
	plot([pd_block_onset_timestamp_list(i_pd_block_onset_timestamp), pd_block_onset_timestamp_list(i_pd_block_onset_timestamp)], y_lim, 'Color', [1 0 1]);
end
for i_pd_block_offset_timestamp = 1 : length(pd_block_offset_timestamp_list)
	plot([pd_block_offset_timestamp_list(i_pd_block_offset_timestamp), pd_block_offset_timestamp_list(i_pd_block_offset_timestamp)], y_lim, 'Color', [0 0 0]);
end



% the accelerometer traces
%figure('Name', 'ADC Test Chunk size');
figure('Name', 'ADC detrend');
%subplot(3, 1, 1)
title(chan_names{2});
my_sample_subset = (1000:1:6000);
my_sample_subset = sample_subset;
% de_trend_ai2= detrend(ADC_data.data(my_sample_subset, ADC_data.cn.Dev1_ai2));
% de_trend_ai3= detrend(ADC_data.data(my_sample_subset, ADC_data.cn.Dev1_ai3));
% de_trend_ai4= detrend(ADC_data.data(my_sample_subset, ADC_data.cn.Dev1_ai4));


vector_sum= sqrt((de_trend_ai2).^2+(de_trend_ai3).^2+(de_trend_ai4).^2);
% median_de_trend_ai2= medfilt1(de_trend_ai2,5);
% median_de_trend_ai3= medfilt1(de_trend_ai3,5);
% median_de_trend_ai4= medfilt1(de_trend_ai4,5);
%plot(time_vec(my_sample_subset), ADC_data.data(my_sample_subset, ADC_data.cn.Dev1_ai2));
%plot(time_vec(my_sample_subset, ADC_data.data(my_sample_subset, ADC_data.cn.Dev1_ai0));
hold on
%plot(time_vec(my_sample_subset, ADC_data.data(my_sample_subset, ADC_data.cn.Dev1_ai1));
%plot(time_vec(my_sample_subset), ADC_data.data(my_sample_subset, ADC_data.cn.Dev1_ai2));
%plot(time_vec(my_sample_subset), ADC_data.data(my_sample_subset, ADC_data.cn.Dev1_ai3));
%plot(time_vec(my_sample_subset), ADC_data.data(my_sample_subset, ADC_data.cn.Dev1_ai4));


% plot(time_vec(my_sample_subset),de_trend_ai2);
% plot(time_vec(my_sample_subset), de_trend_ai3);
% plot(time_vec(my_sample_subset), de_trend_ai4);
plot(time_vec(my_sample_subset), vector_sum);


legend(chan_names(4:end), 'Interpreter', 'none');

y_lim = get(gca(), 'YLim');

for i_IFtouch_onset = 1 : length(IF_touch_onset_list)
	plot([IF_touch_onset_list(i_IFtouch_onset), IF_touch_onset_list(i_IFtouch_onset)], y_lim, 'Color', [0 1 0]);
end
for i_IFtouch_offset = 1 : length(IF_touch_offset_list)
	plot([IF_touch_offset_list(i_IFtouch_offset), IF_touch_offset_list(i_IFtouch_offset)], y_lim, 'Color', [1 0 1]);
end




hold off
xlabel('Samples');
y_lim = get(gca(), 'YLim');



%lpFilt = designfilt('lowpassiir','FilterOrder',300, ...
%          'PassbandFrequency',1000,'PassbandRipple',0.2, ...
%          'SampleRate',2e3);

 hpFilt = designfilt('highpassfir','StopbandFrequency',0.25, ...
         'PassbandFrequency',0.35,'PassbandRipple',0.5, ...
         'StopbandAttenuation',65);

%  hpFilt = designfilt('highpassiir','FilterOrder',300, ...
%          'PassbandFrequency',300,'PassbandRipple',0.2, ...
%          'SampleRate',2e3);	 
	 
% hpFilt= designfilt('differentiatorfir','FilterOrder',300, ...
%     'PassbandFrequency',50,'StopbandFrequency',200, ...
%     'SampleRate',2000);


% lp_filtered_data_ai2= filter(hpFilt,de_trend_ai2);
% lp_filtered_data_ai3=filter(hpFilt,de_trend_ai3);
% lp_filtered_data_ai4=filter(hpFilt,de_trend_ai4); 

lp_filtered_data_ai4=filter(hpFilt,vector_sum); 
% lp_filtered_data_ai2_useful=lp_filtered_data_ai2(100000:end,:); 
% lp_filtered_data_ai3_useful=lp_filtered_data_ai3(100000:end,:); 
% lp_filtered_data_ai3_useful=lp_filtered_data_ai3(100000:end,:); 

% median_filter_ai2=medfilt1(lp_filtered_data_ai2,5);
% median_filter_ai3=medfilt1(lp_filtered_data_ai3,5);
% median_filter_ai4=medfilt1(lp_filtered_data_ai4,5);

median_filter_ai4=medfilt1(vector_sum,5);


figure('Name', 'ADC detrend_lpFiltered');
title(chan_names{2});
my_sample_subset = (1:1:6000);
my_sample_subset = sample_subset;
hold on
% plot(time_vec(my_sample_subset),median_filter_ai2);
% plot(time_vec(my_sample_subset),median_filter_ai3);
% plot(time_vec(my_sample_subset), median_filter_ai4);

plot(time_vec(my_sample_subset),median_filter_ai4 );
legend(chan_names(4:end), 'Interpreter', 'none');
hold off

% Velocity_ai2= cumsum(median_filter_ai2);
% Velocity_ai3= cumsum(median_filter_ai3);
Velocity_ai4= cumsum(median_filter_ai4);
% 
% de_trend_velocity_ai2= detrend(Velocity_ai2,'linear',10);
% de_trend_velocity_ai3= detrend(Velocity_ai3,'linear',5);
% de_trend_velocity_ai4= detrend(Velocity_ai4);

% Activity_ai=de_trend_velocity_ai2+de_trend_velocity_ai3;
% plot(time_vec(my_sample_subset),Activity_ai);

% Detrend_velocity_ai2= detrend(Velocity_ai2);
% Detrend_velocity_ai3= detrend(Velocity_ai3);
% Detrend_velocity_ai4= detrend(Velocity_ai4);

%  time_integral= time_vec(my_sample_subset);
%  Velocity_ai2= trapz(lp_filtered_data_ai2, time_integral(1), time_integral(end));
%  Velocity_ai3= trapz (lp_filtered_data_ai3, time_integral(1), time_integral(end));
%  Velocity_ai4= trapz (lp_filtered_data_ai4, time_integral(1), time_integral(end));
figure('Name','ADC Velocity');
title(chan_names{2});
hold on
% plot(time_vec(my_sample_subset),de_trend_velocity_ai2);
% plot(time_vec(my_sample_subset),de_trend_velocity_ai3);
plot(time_vec(my_sample_subset),Velocity_ai4);
% plot(time_vec(my_sample_subset),Activity_ai);
legend('Velocity_x', 'velocity_y','velocity_z','combined xy');


hold off

% position_ai2=cumsum(Velocity_ai2);
% position_ai3=cumsum(Velocity_ai3);
position_ai4=cumsum(Velocity_ai4);

figure('Name','ADC Position');
title(chan_names{2});
hold on
% plot(time_vec(my_sample_subset),position_ai2);
% plot(time_vec(my_sample_subset),position_ai3);
plot(time_vec(my_sample_subset),position_ai4);
legend('position_x', 'position_y','position_z');
hold off

end


% function [cur_fh] = fn_plot_over_time(start_ts_idx, end_ts_idx, time_vec, pd_data, )
% 
% 
% 
% end