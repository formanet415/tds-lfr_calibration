load('days_with_lags.mat')
days = string(days)';
lags=[];
setenv('OKF', 'Z:')

for i = days
    disp(i)
    date = str2num(replace(i,'-',',')');
    tds = tdscdf_load_l2_surv_tswf(datenum(date(1),date(2),date(3)), 1, 1);
    [channels,indexes] = size(tds.ch_mask);
    for j = 1:indexes
        for k = 1:channels
            if tds.ch_mask(k,j)==1
                lag = compare_TDS_signal(tds.voltage_data(k,:,j),tds.data(k,:,j),tds.samp_rate(j));
                if lag ~= -1
                    lags(end+1)=lag; %#ok<SAGROW>
                end
            end
        end
    end
end