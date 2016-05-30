function [ mirror_pnts ] = mirror( pnts,I )
    if ~iscell(pnts)
        error('pnt is not a cell');
    end
    centerX=size(I,2)/2;
    
    nPnt=length(pnts);
    mirror_pnts=cell(nPnt,1);
    centerX=repmat(centerX,size(pnts{1},1),1);
    for l=1:nPnt
        tmp=pnts{l};
        tmp=tmp(end:-1:1,:);
        mirror_pnts{l}=[2*centerX-tmp(:,1),tmp(:,2)];
    end


end

