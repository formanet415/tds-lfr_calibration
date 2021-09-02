function ostr = lfrcdf_load_l2_surv_lfr_swf_e(fname, find_file, KeepEpochAsIs)
%lfrcdf_load_l2_surv_lfr Loads L2 surv lfr-swf-e data into a structure.
%   fname = Filename as a string (if find_file is 0) or a datenum of the 
%   day (if find_file is 1) 
%   find_file = If set to 1, function finds the file based upon the datenum
%   from fname.
%   KeepEpochAsIs = If set to 1, loader returns Epoch in TT2000 instead of
%   datenum.

rocstr = 'solo_L2_rpw-lfr-surv-swf-e-cdag_';

if ~exist('find_file','var') || isempty(find_file)
    find_file = 0;
end
if ~exist('KeepEpochAsIs','var') || isempty(KeepEpochAsIs)
    KeepEpochAsIs = 0;
end
skip_name_check = 1;

[cstr, cinfo, fname] = tdscdf_load_roc_cdf_file(fname, skip_name_check, find_file, rocstr, KeepEpochAsIs);
if isempty(cstr)
    ostr = [];
    return;
end

%cinfo.Variables

%ivar = tdscdf_find_var_idx(cinfo, 'WAVEFORM_DATA');
%snaps = cstr{ivar};
%ivar = tdscdf_find_var_idx(cinfo, 'WAVEFORM_DATA_VOLTAGE');
%snaps_volt = cstr{ivar};

eac =  tdscdf_get_cdfvar(cinfo, cstr, 'EAC',1);
%snaps_volt = tdscdf_get_cdfvar(cinfo, cstr, 'WAVEFORM_DATA_VOLTAGE',1);


%ostr.ch_mask = tdscdf_get_cdfvar(cinfo, cstr, 'CHANNEL_ON');

%ivar = tdscdf_find_var_idx(cinfo, 'SNAPSHOT_SEQ_NR');
%ostr.snap_seq = double(cstr{ivar})';
%ivar = tdscdf_find_var_idx(cinfo, 'SAMPS_PER_CH');
%ostr.samples_per_ch = double(cstr{ivar}');

ostr.epoch = tdscdf_get_cdfvar(cinfo, cstr, 'Epoch', 0, KeepEpochAsIs); 
%ostr.inp_conf = tdscdf_get_cdfvar(cinfo, cstr, 'INPUT_CONFIG');
%ostr.ch_overflow = tdscdf_get_cdfvar(cinfo, cstr, 'CHANNEL_OVERFLOW');
ostr.samp_rate = tdscdf_get_cdfvar(cinfo, cstr, 'SAMPLING_RATE');

%quality = tdscdf_get_cdfvar(cinfo, cstr, 'QUALITY_FACT');
%reason  = tdscdf_get_cdfvar(cinfo, cstr, 'DOWNLINK_INFO');

num_snapshots = length(ostr.epoch);
%max_snap_len = max(ostr.samples_per_ch);

fprintf(1, 'Found %d LFR EAC snapshots in the L2 CDF file\n', num_snapshots);
fprintf(1, 'Time from %s to %s\n', datestr(spdftt2000todatenum(ostr.epoch(1))), datestr(spdftt2000todatenum(ostr.epoch(end))));

if (any(diff(ostr.epoch) < 0))
    fprintf(1, 'Backwards time detected in epoch!\n');
end

ostr.num_comp    = zeros(1,num_snapshots);

%for i=1:num_snapshots    
%    ostr.num_comp(i)     = nnz(ostr.ch_mask(:,i));    
%end

ostr.level = 2;
ostr.fname   = fname;
ostr.data            = eac;%snaps(:,1:max_snap_len,:);
%ostr.voltage_data    = snaps_volt(:,1:max_snap_len,:);
%ostr.quality  = double(quality);
%ostr.algo_code  = double(reason(1,:));
%ostr.select_reason  = reason(2,:);
end

