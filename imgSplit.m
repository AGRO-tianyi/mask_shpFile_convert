function imgSplit(prm)
%IMGSPLIT Split images to patch parts
%   imgSplit(prm) 
%   is the main function of spliting the input images to patch parts (shpelFiles or images).  

%   WRITTEN BY:  Tianyi Jia (email: ttianyi12@126.com)
%   RELEASED ON: 10 October, 2021

    inputMaskDir = uigetdir(prm.defaultDir, 'Select the input path of mask images...');
    loc1 = strfind(inputMaskDir, '\');                                     % mkdir for output images
    prm.outputDir = [inputMaskDir(1:loc1(end)), 'patch\'];                 % set the default outputDir name

    inputRGBDir = uigetdir(prm.defaultDir, 'Select the input path of reference images (eg: RGB images), if have...');

    maskSet = imageDatastore(inputMaskDir);                                % restore the mask dataset
    for i = 1:numel(maskSet.Files)
        prm.title = [num2str(i), '/', num2str(numel(maskSet.Files)), ' image is processing...'];
        
        prm.maskNewstr = split(maskSet.Files{i},'\');   
        maskNewStr = prm.maskNewstr; 
        outputPath = [prm.outputDir, maskNewStr{end}(1:end-4), '\'];
        if ~exist(outputPath,'dir')
            mkdir(outputPath);
        end 
        
        maskImg = logical(imread(maskSet.Files{i}));
        r = size(maskImg, 1);
        c = size(maskImg, 2);
        if (r < prm.rpatchSize) || (c < prm.cpatchSize)            
            error([prm.maskNewstr{end},' patch size exceeds the image size'])
        end
        
        if inputRGBDir ~= 0
            if i == 1
                RGBSet = imageDatastore(inputRGBDir);                      % restore the reference dataset
            end
            prm.RGBnewstr = split(RGBSet.Files{i},'\');        
            rgbImg = imread(RGBSet.Files{i});
        else
            rgbImg = [];
        end
        
       %% perform Spliting
        rNum = ceil(r/prm.rpatchSize); 
        cNum = ceil(c/prm.cpatchSize);
              
        rRange_Start = ones(1, rNum)+[0:rNum-1].*prm.rpatchSize;
        rRange_End = [[1:rNum-1].*prm.rpatchSize,  r];
        
        cRange_Start = ones(1, cNum)+[0:cNum-1].*prm.cpatchSize;
        cRange_End = [[1:cNum-1].*prm.cpatchSize,  c];
        
        bar = waitbar(0, 'Data reading', 'Name',  prm.title);
        
        for p = 1:length(rRange_Start)
            for q = 1:length(cRange_Start)
                str = ['Image patch spliting...', num2str((p-1)*cNum+q), '/', num2str(rNum*cNum)];
                waitbar(((p-1)*cNum+q)/(rNum*cNum), bar, str)   

              %% imageBlock saving
                % maskImg
                outputName = fullfile([outputPath, maskNewStr{end}(1:end-4), '_', ... 
                                      'r', num2str(p), 'c', num2str(q), '_patch', maskNewStr{end}(end-3:end)]);
                maskBlock = maskImg(rRange_Start(p):rRange_End(p), cRange_Start(q): cRange_End(q));          
                imwrite(maskBlock, outputName);

                % rgbImg or referenceImg
                if ~isempty(rgbImg) 
                    RGBnewStr = prm.RGBnewstr;
                    rRGB = size(rgbImg, 1);
                    cRGB = size(rgbImg, 2);
                    if ~isequal(rRGB, r) || ~isequal(cRGB, c)
                        close(bar)
                        error([prm.RGBnewstr{end}, 'Image size mismatch between mask image and reference image'])
                    end                   
                    
                    nameCmp = strcmp(RGBnewStr{end}(1:end-4),...
                                     maskNewStr{end}(1:end-4-numel(prm.maskSuffix)));  % same name check        
                    if p==1 && q ==1 && ~nameCmp
                        close(bar)
                        error([prm.RGBnewstr{end}, ' corresponding reference image lost!!!'])                                        % need to modify                        
                    end
                    outputName2 = fullfile([outputPath, RGBnewStr{end}(1:end-4), '_', ...
                                            'r', num2str(p), 'c', num2str(q), '_patch', RGBnewStr{end}(end-3:end)]);
                    rgbBlock = rgbImg(rRange_Start(p):rRange_End(p), cRange_Start(q): cRange_End(q), :);                    
                    imwrite(rgbBlock, outputName2);
                end

               %% shapeFile saving
                shpMap = extractShp(maskBlock);
                shpOutPath = [prm.outputDir, maskNewStr{end}(1:end-4) ,'\shpFile\'];
                if ~exist(shpOutPath,'dir')
                    mkdir(shpOutPath);
                end
                shpOutName = fullfile([shpOutPath, maskNewStr{end}(1:end-4), '_', ...
                                      'r', num2str(p), 'c', num2str(q), '_patch_', ...
                                      'rs', num2str(size(maskBlock, 1)), ...
                                      'cs', num2str(size(maskBlock, 2)), '_size','.shp']);
                                  
                if ~cellfun(@isempty,{shpMap.Id})
                    shapewrite(shpMap, shpOutName);
                else
                    imwrite(zeros(size(maskBlock)), [shpOutName(1:end-4), '.png']); % no value in the shpMap 
                end                                                      
            end
        end
        close(bar)
    end
    msgbox('Done!!!')
end
