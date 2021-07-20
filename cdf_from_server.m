function cdf = cdf_from_server(year,month,day,type)
%CDF_FROM_SERVER Summary of this function goes here
%   Detailed explanation goes here
if strcmp(type, 'lfr-e')
    fPath = dir(fullfile('Z:\rpw\L2\lfr_wf_e',sprintf('%4i/%02i/solo_L2_rpw-lfr-surv-cwf-e-cdag_%4i%02i%02i*',year,month,year,month,day)));
    if size(fPath) == [1,1]
     	fname = fullfile(fPath.folder, fPath.name);
    elseif size(fPath) == [0,1]
        disp(['Missing data - file not found: ' fullfile(inputDIR,sprintf('%4i/%02i/solo_L2_rpw-lfr-surv-cwf-e-cdag_%4i%02i%02i*',year,month,year,month,day))])
    elseif length(fPath) > 1
        disp('multiple files found, choosing highest version')
        names = struct2cell(fPath);
        names = names(1,:);
        version = [];
        for j=1:length(names)
            name = char(names(j));
            Vindex = strfind(name, 'V');
            version(j) = str2num(name(Vindex+1:Vindex+2));
        end
        if sum(max(version) == version) == 1
            fname = fullfile(fPath.folder, char(names(max(version) == version)));
        else
            error('Selection failed, multiple files with same version found!')
        end
    end
    cdf = cdf_load_tswf(fname);
end

if strcmp(type, 'tswf')
    fPath = dir(fullfile('Z:\rpw\L2\tds_wf_e',sprintf('%4i/%02i/solo_L2_rpw-tds-surv-tswf-e-cdag_%4i%02i%02i*',year,month,year,month,day)));
    if size(fPath) == [1,1]
     	fname = fullfile(fPath.folder, fPath.name);
    elseif size(fPath) == [0,1]
        disp(['Missing data - file not found: ' fullfile(inputDIR,sprintf('%4i/%02i/solo_L2_rpw-tds-surv-tswf-e-cdag_%4i%02i%02i*',year,month,year,month,day))])
    elseif length(fPath) > 1
        disp('multiple files found, choosing highest version')
        names = struct2cell(fPath);
        names = names(1,:);
        version = [];
        for j=1:length(names)
            name = char(names(j));
            Vindex = strfind(name, 'V');
            version(j) = str2num(name(Vindex+1:Vindex+2));
        end
        if sum(max(version) == version) == 1
            fname = fullfile(fPath.folder, char(names(max(version) == version)));
        else
            error('Selection failed, multiple files with same version found!')
        end
    end
    cdf = cdf_load_tswf(fname);
end

if strcmp(type, 'HK')
    fPath = dir(fullfile('Z:\rpw\HK',sprintf('%4i/%02i/%02i/solo_HK_rpw-tds*',year,month,day)));
    if size(fPath) == [1,1]
     	fname = fullfile(fPath.folder, fPath.name);
    elseif size(fPath) == [0,1]
        disp(['Missing data - file not found: ' fullfile(inputDIR,sprintf('%4i/%02i/%02i/solo_HK_rpw-tds-',year,month,day))])
    elseif length(fPath) > 1
        disp('multiple files found, choosing highest version')
        names = struct2cell(fPath);
        names = names(1,:);
        version = [];
        for j=1:length(names)
            name = char(names(j));
            Vindex = strfind(name, 'V');
            version(j) = str2num(name(Vindex+1:Vindex+2));
        end
        if sum(max(version) == version) == 1
            fname = fullfile(fPath.folder, char(names(max(version) == version)));
        else
            error('Selection failed, multiple files with same version found!')
        end
    end
    cdf = cdf_load_tswf(fname);
end
end

