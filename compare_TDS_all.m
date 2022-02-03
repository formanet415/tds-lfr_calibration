avglags = [];
avglagsstd = [];
dates = [];
lags = [];
setenv('OKF', 'Z:')

year = 2020;
for month = 4:12
    for day = 1:eomday(year,month)
        theselags = [];
        tds = tdscdf_load_l2_surv_tswf(datenum(year,month,day), 1, 1);
        if ~isempty(tds)
            [channels,indexes] = size(tds.ch_mask);
            for j = 1:indexes
                for k = 1:channels
                    if tds.ch_mask(k,j) == 1
                        lag = compare_TDS_signal(tds.voltage_data(k,:,j),tds.data(k,:,j),tds.samp_rate(j));
                        if lag ~= -1
                            lags(end+1) = lag;      %#ok<SAGROW>
                            theselags(end+1) = lag; %#ok<SAGROW>
                        end
                    end
                end
            end
            [avg, std] = threesigma(theselags);
            avglags(end+1) = avg;                   %#ok<SAGROW>
            avglagsstd(end+1) = std;                %#ok<SAGROW>
            dates(end+1) = datenum(year,month,day); %#ok<SAGROW>
        end
    end
end