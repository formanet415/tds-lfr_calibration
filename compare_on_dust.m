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
    indexes = str2num(temp(2)); %#ok<ST2NM>
    tds = tdscdf_load_l2_surv_tswf(datenum(date(1),date(2),date(3)), 1, 1);
    lfr = cdf_from_server(date(1),date(2),date(3),'lfr-e');
    lfrtimes = lfr.epoch;
    for j = indexes
        tt0 = (tds.epoch(j));
        [d, index] = min(abs(lfrtimes-tt0));
        if lfrtimes(index) > tt0 
            index = index-1;
        end
        if index~=0
            sr = lfr.samp_rate(index);
            dt = 1e9*(double(2048)/sr);
            if (lfrtimes(index)+double(dt))<tt0  
                index = 0;
            else
                [lag1, lag2] = compare_signal(lfr,tds,j,index,tt0, 0, 0);
                if lag1 ~= -1
                    dust_lags(end+1)=lag1; %#ok<SAGROW>
                    dust_lags(end+1)=lag2; %#ok<SAGROW>
                end
            end
        end
    end
    
end
