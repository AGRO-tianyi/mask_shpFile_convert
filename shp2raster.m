
%   WRITTEN BY:  Tianyi Jia (email: ttianyi12@126.com)
%   RELEASED ON: 10 October, 2021

function restoreMap = shp2raster(filename, rpatchSize, cpatchSize)
    Map = shaperead(filename);
    restoreMap = zeros(rpatchSize, cpatchSize);
    for i = 1:numel(Map)
        x = Map(i).X(1:end-1)';
        y = Map(i).Y(1:end-1)';
        xloc = [];        
        xloc = find(isnan(x))-1;
        if ~isempty(xloc)
            xloc = [-1; xloc; size(x,1)];
        else
            xloc = [-1; size(x,1)];
        end
        
        for j = 1:numel(xloc)-1
            tmpLoc1 = [xloc(j)+2, xloc(j+1)];
            xnew = x(tmpLoc1(1):tmpLoc1(2));
            ynew = y(xloc(j)+2:xloc(j+1));
            
            bw = poly2mask(xnew,ynew,rpatchSize,cpatchSize);
            if numel(xloc)==2 || j==1
                restoreMap = restoreMap | bw;
            else
                restoreMap = restoreMap & ~bw;
            end
        end
    end
end

