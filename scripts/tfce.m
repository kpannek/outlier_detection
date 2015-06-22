function tfcestat=tfce(statistic,sign,levels,connectivity,E,H,dim)

if (nargin<2 || isempty(sign))
    sign=1;
end
if sign<0
    statistic=-statistic;
end

if (nargin<3 || isempty(levels))
    levels=100;
end

if (nargin<7 || isempty(dim))
    dim=2;
end
if (nargin<4 || isempty(connectivity))
    if dim==2
        connectivity=4;
    else
        connectivity=6;
    end
end

if (nargin<5 || isempty(E))
    E=.5;
end
if (nargin<6 || isempty(H))
    H=2;
end



maxStat=prctile(statistic(:),99.999);
%dStat=maxStat/levels
dStat=.1;

[xdim,ydim,zdim,tdim]=size(statistic);
tfcestat=zeros(xdim,ydim,zdim,tdim);

for titer=1:tdim
    fprintf('.')
    if dim==2
        for ziter=1:zdim
            current=statistic(:,:,ziter,titer);
            maxStatCurrent=max(current(:));
%            tmptfcestat=zeros(xdim,ydim);
            tmptfcestat=zeros(size(current));
            for thr=0:dStat:maxStatCurrent
                CC = bwconncomp(current>thr,connectivity);
                numPixels = cellfun(@numel,CC.PixelIdxList);
                for i=1:numel(CC.PixelIdxList)
    %                tmptfcestat(CC.PixelIdxList{i})=tmptfcestat(CC.PixelIdxList{i})+numPixels(i)*dStat;
                    tmptfcestat(CC.PixelIdxList{i})=tmptfcestat(CC.PixelIdxList{i})+numPixels(i).^E * thr.^H *dStat;
                end
            end
            tfcestat(:,:,ziter,titer)=tmptfcestat;
        end
    else        
        current=statistic(:,:,:,titer);
        maxStatCurrent=max(current(:));
        tmptfcestat=zeros(size(current));
        for thr=0:dStat:maxStatCurrent
            CC = bwconncomp(current>thr,connectivity);
            numPixels = cellfun(@numel,CC.PixelIdxList);
            for i=1:numel(CC.PixelIdxList)
%                tmptfcestat(CC.PixelIdxList{i})=tmptfcestat(CC.PixelIdxList{i})+numPixels(i)*dStat;
                tmptfcestat(CC.PixelIdxList{i})=tmptfcestat(CC.PixelIdxList{i})+numPixels(i).^E * thr.^H *dStat;
                tmptfcestat(CC.PixelIdxList{i})=tmptfcestat(CC.PixelIdxList{i})+numPixels(i).^E * thr.^H;
            end
        end
        tfcestat(:,:,:,titer)=tmptfcestat;
    end
end
