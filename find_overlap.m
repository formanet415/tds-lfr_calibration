function find_overlap(date)
%FIND_OVERLAP This function finds places where there is an overlap between
%lfr and tds data and then plots out both. 
load('tds_tswf_iaw_times.mat')
Ep = spdfdatenumtott2000(data.ep);
wa_times = char(spdfencodett2000(Ep));

times = [];
for i = 1:size(wa_times,1)
    if strcmp(wa_times(i,1:10), date)
        times(end+1) = Ep(i);
    end
end

%tds = cdf_from_server(str2num(date(1:4)),str2num(date(6:7)),str2num(date(9:10)),'tswf');
%lfr = cdf_from_server(str2num(date(1:4)),str2num(date(6:7)),str2num(date(9:10)),'lfr-e');
tds = cdf_load_tswf('cdfs/solo_L2_rpw-tds-surv-tswf-e-cdag_20200718_V26.cdf');
lfr = cdf_load_tswf('cdfs/solo_L2_rpw-lfr-surv-swf-e-cdag_20200718_V26.cdf');


tdstimes = spdfdatenumtott2000(tds.Epoch.data);
lfrtimes = spdfdatenumtott2000(lfr.Epoch.data);
for i = times
    iT = find_index(i,tds,tdstimes);
    iL = find_index(i,lfr,lfrtimes);
    if iT ~= 0 && iL ~= 0
        disp('-----------match found-----------')
        compare_signal(lfr,tds,iT,iL,i);
    end
end


end
function index = find_index(time,cdf,times)
    [d, index] = min(abs(times-time));
    if times(index) > time 
        index = index-1;
    end
    if index~=0 
        samps = 2048;
        t='lfr';
        if isfield(cdf, 'SAMPS_PER_CH')
            samps = cdf.SAMPS_PER_CH.data(index);
            t='tds';
        end
        sr = cdf.SAMPLING_RATE.data(index);
        dt = 1e9*(double(samps)/sr);
        if (times(index)+double(dt))<time  
            index = 0;
        else
            a =times(index);
            b = int64(time);
            c = times(index)+int64(dt);
            
            %disp(t)
            %disp('found window')
            %disp(spdfencodett2000(a))
            %disp(spdfencodett2000(b))
            %disp(spdfencodett2000(c))
        end
    end
end