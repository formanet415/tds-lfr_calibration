function find_lfr(date)
%FIND_LFR Summary of this function goes here
%   Detailed explanation goes here
load('tds_tswf_iaw_times.mat')
Ep = spdfdatenumtott2000(data.ep);
wa_times = char(spdfencodett2000(Ep));

times = [];
for i = 1:size(wa_times,1)
    if strcmp(wa_times(i,1:10), date)
        times(end+1) = Ep(i);
    end
end

tds = cdf_from_server(str2num(date(1:4)),str2num(date(6:7)),str2num(date(9:10)),'tswf');
lfr = cdf_from_server(str2num(date(1:4)),str2num(date(6:7)),str2num(date(9:10)),'lfr-e');

tdstimes = spdfdatenumtott2000(tds.Epoch.data);
lfrtimes = spdfdatenumtott2000(lfr.Epoch.data);
for i = times
    iT = find_index(i,tds,tdstimes);
    iL = find_index(i,lfr,lfrtimes);
end


end
function index = find_index(time,cdf,times)
    [d, index] = min(abs(times-time));
    if times(index) > time 
        index = index-1;
    end
    if index~=0 && isfield(cdf, 'SAMPS_PER_CH')
        samps = cdf.SAMPS_PER_CH.data(index);
        sr = cdf.SAMPLING_RATE.data(index);
        dt = 1e9*(double(samps)/sr);
        if (times(index)+double(dt))<time  
            
            disp('oh no')
            index = 0;
        else
            a =times(index);
            b =int64(time);
            c = times(index)+int64(dt);
            disp(spdfencodett2000(a))
            disp(spdfencodett2000(b))
            disp(spdfencodett2000(c))
            disp('yay')
        end
    end
end