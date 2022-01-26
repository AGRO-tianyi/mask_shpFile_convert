
%   WRITTEN BY:  Tianyi Jia (email: ttianyi12@126.com)
%   RELEASED ON: 10 October, 2021

function Map = extractShp(inImg)   
    [r, c] = size(inImg);
%     inImg = flipud(inImg);
    
    inImgNew = zeros(r+2, c+2);
    inImgNew(2:end-1, 2:end-1) = inImg;

    Map.Geometry = '';
    Map.Id = []; Map.X = [];  Map.Y = [];
%     R = maprefcells([0.5 size(inImg, 1)+0.5],[0.5 size(inImg, 2)+0.5], [size(inImg, 1) size(inImg, 2)]);
    R = maprefcells([0 c],[0 r], [r c]);
%     figure, imshow(inImgNew), hold on  
    
    [L, num] = bwlabel(inImgNew, 4);
    count = 0;

%     g = zeros(size(L));  
    for i=1:num
        tmpImg = (L==i);
        objBoundary = bwboundaries(tmpImg, 4, 'holes');
%         g = g | tmpImg;
%         imshow(g) 

        data = objBoundary{1};                
        outPs = expandBoundaries(data, 0.5, 'out');                        % outPoints calculating
        
        outP = [];
        outP = [outP; outPs; [NaN NaN]];                                   % outputPoints generation
        
        if numel(objBoundary) > 1                                          % hole optimization
            tmpImg2 = imfill(tmpImg, 'holes') - tmpImg;
            objBoundary = bwboundaries(tmpImg2, 4, 'holes');            
            for j=1:numel(objBoundary)
                data = objBoundary{j}; 
                outPs = expandBoundaries(data, 0.5, 'out');
                outP = [outP; outPs; [NaN NaN]];
            end
        end
%         hold on, plot(data(:,2), data(:,1), 'g')
%         hold on, plot(outP(:,2), outP(:,1), 'r')

        % image -> map
        [x, y] = pix2map(R, outP(:,1)-1, outP(:,2)-1); 
        count = count + 1;
        Map(count).Geometry = 'Polygon';
        Map(count).Id = count;                    
        Map(count).X = x;
        Map(count).Y = y;
    end
end
