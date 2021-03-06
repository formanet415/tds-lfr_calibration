function [lags, lagtimes] = find_overlap(date, varargin)
%FIND_OVERLAP This function finds places where there is an overlap between
%lfr and tds data and then plots out both. 

plotit = 1;
printdelay = 1;
while ~isempty(varargin)
    switch lower(varargin{1})
        case 'plotit'
            plotit = varargin{2};
        case 'printdelay'
            printdelay = varargin{2};
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
    varargin(1:2) = [];
end

load('tds_tswf_iaw_times.mat')
Ep = spdfdatenumtott2000(data.ep);
wa_times = char(spdfencodett2000(Ep));

times = [];
for i = 1:size(wa_times,1)
    if strcmp(wa_times(i,1:10), date)
        times(end+1) = Ep(i);
    end
end
times=int64(times);
if ~ischar(date)
    date = char(date);
end
tds = tdscdf_load_l2_surv_tswf(datenum(str2num(date(1:4)),str2num(date(6:7)),str2num(date(9:10))), 1, 1); %#ok<ST2NM>
lfr = cdf_from_server(str2num(date(1:4)),str2num(date(6:7)),str2num(date(9:10)),'lfr-e'); %#ok<ST2NM>
lfrtimes = lfr.epoch;
tdstimes = tds.epoch;

lags = [];
lagtimes = [];
for i = times
    iT = find_index(i,tds,tdstimes);
    iL = find_index(i,lfr,lfrtimes);
    if iT ~= 0 && iL ~= 0
        lag = compare_signal(lfr,tds,iT,iL,i, plotit, printdelay);
        if ~islogical(lag)
            lags(end+1) = lag;
            lagtimes(end+1) = i;
        end
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
        if isfield(cdf, 'samples_per_ch')
            samps = cdf.samples_per_ch(index);
            t='tds';
        end
        sr = cdf.samp_rate(index);
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