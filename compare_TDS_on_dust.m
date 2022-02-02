fileID = fopen('solo_dust.txt','r');
txt = split(string(fscanf(fileID,'%s')),'`');
dust_lags = [];
setenv('OKF', 'Z:')

for i = txt'
    disp(i)
    temp = split(i,'_');
    date = str2num(replace(temp(1),'-',',')'); %#ok<ST2NM>
    if strcmp(i,"")
        disp('Plotting finshed')
        return
    end
    tds = tdscdf_load_l2_surv_tswf(datenum(date(1),date(2),date(3)), 1, 1);
    [channels,indexes] = size(tds.ch_mask);
    for j = 1:indexes
        for k = 1:channels
            if tds.ch_mask(k,j)==1
                lag = compare_TDS_signal(tds.voltage_data(k,:,j),tds.data(k,:,j),tds.samp_rate(j), 0, 0);
                if lag ~= -1
                    dust_lags(end+1)=lag; %#ok<SAGROW>
                end
            end
        end
    end
    
end
