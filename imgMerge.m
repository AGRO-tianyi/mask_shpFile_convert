function imgMerge(prm)
%IMGMERGE Merge images split by the IMGSPLIT Func
%   imgMerge(prm) 
%   is the main function of merging patch parts split by the IMGSPLIT Func (shpelFiles or images).  

%   WRITTEN BY:  Tianyi Jia (email: ttianyi12@126.com)
%   RELEASED ON: 10 October, 2021

    inputDir = uigetdir(prm.defaultDir, 'Select the input path of patch images');

    subdir = dir(inputDir);
    count = 0;

    for j=1:length(subdir)
        if( isequal(subdir(j).name, '.' )||...
            isequal(subdir(j).name, '..')||...
            ~subdir(j).isdir)   
            continue;
        end
%         outImg = zeros(prm.imgRows, prm.imgCols);
        shpInputPath = fullfile(inputDir, subdir(j).name, 'shpFile');
        shpFileSet = imageDatastore(shpInputPath, 'FileExtensions', {'.shp', '.png'});
        

        numRun = numel(shpFileSet.Files);                                  % acquire the patch images' propoerty
        patchProp = zeros(numRun, 4);
        for k = 1: numRun
            shpFileName = shpFileSet.Files{k};
            rcNum = regexp(shpFileName,'\d*\d*\d*\d*','match');
            patchProp(k, :) = cellfun(@(x) str2num(x), rcNum);
        end
        rNum = max(patchProp(:,1));
        cNum = max(patchProp(:,2));
        
        rRange_Start = ones(1, rNum)+[0:rNum-1].*prm.rpatchSize;
        rRange_End = [[1:rNum-1].*prm.rpatchSize, (rNum-1)*prm.rpatchSize+patchProp(end,3)];
        
        cRange_Start = ones(1, cNum)+[0:cNum-1].*prm.cpatchSize;
        cRange_End = [[1:cNum-1].*prm.cpatchSize, (cNum-1)*prm.cpatchSize+patchProp(end,4)];
        
        count = count+1;
        prm.title = [num2str(count), '/', num2str(sum([subdir.isdir])-2), ' image is processing...'];
        
        bar = waitbar(0, 'Data reading', 'Name',  prm.title);
        
        if ~isequal(rNum*cNum, numRun)
            close(bar)
            error([subdir(j).name, ' patch numbers are incorrect!!!'])
        end
        
        for i = 1:numRun
            str = ['Image patch merging...', num2str(i), '/', num2str(numRun)];
            waitbar(i/numRun, bar, str)  
            nstr = split(shpFileSet.Files{i}, '_');
            row = patchProp(i,1);  col = patchProp(i,2);
            
            if strcmp(shpFileSet.Files{i}(end-3:end), '.shp')
                restoreMap = shp2raster(shpFileSet.Files{i}, patchProp(i,3), patchProp(i,4));
                outImg(rRange_Start(row):rRange_End(row), cRange_Start(col):cRange_End(col)) = restoreMap; 
            else
%                 restoreMap = imread(shpFileSet.Files{i});
%                 outImg(1+(row-1)*r:row*r, 1+(col-1)*c:col*c) = restoreMap;
                outImg(rRange_Start(row):rRange_End(row), cRange_Start(col):cRange_End(col)) = zeros(patchProp(i,3), patchProp(i,4));
            end
        end
        % imwrite
        outputPath = fullfile(inputDir, [subdir(j).name, '_modified.png']);
        imwrite(logical(outImg), outputPath);
        
        close(bar)
    end
    msgbox('Done!!!')
end
