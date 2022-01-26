
%   WRITTEN BY:  Tianyi Jia (email: ttianyi12@126.com)
%   RELEASED ON: 10 October, 2021

function outP = expandBoundaries(p, dis, pattern)

    if size(p,2)==2 && (sum(p(1,:)-p(2,:))==0)                             % for single pixel
        outP(1,:) = [p(1,1)-dis p(1,2)-dis];
        outP(2,:) = [p(1,1)-dis p(1,2)+dis];
        outP(3,:) = [p(1,1)+dis p(1,2)+dis];
        outP(4,:) = [p(1,1)+dis p(1,2)-dis];
        outP(5,:) = [p(1,1)-dis p(1,2)-dis];
    else 
        p = [p; [p([2 3],1) p([2 3],2)]];
        pu = p(1:end-2,:);  
        pc = p(2:end-1,:); 
        pd = p(3:end,:);                                                   % pointSet construction
        v1 = pu - pc;             v2 = pd - pc;                            % vector construction
        vAdd = v1 + v2;
        normVAdd = sum(vAdd.^2, 2).^(1/2);
        unitvAdd = vAdd ./ normVAdd;
        c2theta = sum(v1 .* v2, 2);
        stheta = sqrt(0.5 .* (1-c2theta));
        pqVec = unitvAdd .* (dis./stheta);
        v1 = [v1 zeros(size(v1,1),1)];
        v2 = [v2 zeros(size(v2,1),1)];

        vectorP = p(1:end-1,:) - p(2:end, :);                              % is LineSegment
        dd = sum(vectorP(1:end-1,:) .* vectorP(2:end, :), 2);
        abnormalV = find(dd<0);

        if strcmp(pattern, 'in')                                           % pattern - in
            crossProduct = cross(v1,v2);
            for i = 1:numel(abnormalV)                            
                loc = abnormalV(numel(abnormalV)-i+1);
                pqVec(loc-1:loc,:) = []; 
                crossProduct(loc-1:loc,:) = []; 
                pc(loc-1:loc,:) = [];
            end
        else                                                               % pattern - out
            crossProduct = -cross(v1,v2);   
            count = 0;
            for i = 1:numel(abnormalV)                                     
                labelP = vectorP(abnormalV(i), :);
                loc = abnormalV(i)+count;
                pqVec(loc,:) = []; 
                crossProduct(loc,:) = [];

                if  isequal(labelP, [1, 0])                        
                    vNew = [-dis -dis; -dis dis];                      
                elseif isequal(labelP, [-1, 0])                       
                    vNew = [dis dis; dis -dis];
                elseif isequal(labelP, [0, -1]) 
                    vNew = [-dis dis; dis dis];
                elseif isequal(labelP, [0, 1])  
                    vNew = [dis -dis; -dis -dis];
                end

                pqVec = [pqVec(1:loc-1,:); vNew; pqVec(loc:end,:)];
                crossProduct = [crossProduct(1:loc-1,:); [0 0 1;0 0 1]; crossProduct(loc:end,:)];
                pc = [pc(1:loc,:); pc(loc, :); pc(loc+1:end,:)];         
                count = count+1;
            end
        end
        outP = pc + (pqVec .* crossProduct(:,3));       
        outP(isnan(outP(:,1)),:)=[];
        if ~(sum(outP(1,:)-outP(end,:))==0)
            outP = [outP; outP(1,:)];
        end
    end
end
