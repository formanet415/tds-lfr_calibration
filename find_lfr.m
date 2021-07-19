function find_lfr(date)
%FIND_LFR Summary of this function goes here
%   Detailed explanation goes here
load('tds_tswf_iaw_times.mat')
Ep = data.ep;
wa_times = spdfencodett2000(Ep);

times = [];
for i = 1:size(wa_times,1)
    if strcmp(wa_times(i,1:10), date)
        times(end+1) = Ep(i);
    end
end

tds = cdf_load_tswf('cdfs/solo_L2_rpw-tds-surv-rswf-e-cdag_20201130_V04.cdf');
lfr = cdf_load_tswf('cdfs/solo_L2_rpw-lfr-surv-cwf-e-cdag_20201130_V05.cdf');

for i = times
    iT = find_index(i,tds);
    iL = find_index(i,lfr);
end


end
function index = find_index(time,cdf)
    times = cdf.Epoch.data;
    [d, index] = min(abs(times-time));
    if times(index) - time > 0
        index = index-1;
    end
    if index~=0
        if isfield(cdf, 'SAMPS_PER_CH')
            samps = cdf.SAMPS_PER_CH.data(index);
            sr = cdf.SAMPLING_RATE.data(index);
            dt = samps/sr;
        end
    end
end