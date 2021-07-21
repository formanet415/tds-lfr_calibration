load('tds_tswf_iaw_times.mat')
wa_times = spdfdatenumtott2000(data.ep);
wa_times = char(spdfencodett2000(wa_times));

unique = 0;
day = '';
days = [];
recs = [];
for i = 1:size(wa_times,1)
    if strcmp(wa_times(i,1:10), day)
        recs(end)=recs(end)+1;
        continue
    else
        day = wa_times(i,1:10);
        days(end+1,1:10) = day;
        recs(end+1) = 1;
    end
    
end
days = char(days);
[num, id] = max(recs);
%most_waves = days(id,:); 
date = '2020-07-18';
worthy = days(recs>99,:);

lags = [];
lagtimes = [];
for i = string(worthy)'
    disp(i)
    [lag,lagtime] = find_overlap(i);
    if lag~=0
        for j = lag
            lags(end+1) = j;
        end
        for j = lagtime
            lagtimes(end+1) = j;
        end
    end
end
