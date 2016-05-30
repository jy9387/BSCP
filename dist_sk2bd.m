
function dist_sk2bd(img_dir, fmt)
    % find min dist from every point on the skeleton to points on the boudary;
    database = retr_database_dir(img_dir, fmt);

	tic
    for n = 1:length(database.path)
        fprintf('Distance between skeleton and boundary: %d of %d\n', n, length(database.path));
        func_dist_sk2bd(database.path{n} ); 
    end
	toc

function func_dist_sk2bd(SK_name )
    
	load(SK_name);
    SK=SK';
    [skrow, skcol]=find(SK);
    skIndexOrigin=skrow+(skcol-1)*size(SK,1);
    %% Find the 24-connected area of all points on the boundary; 
    skIndex=[skrow+(skcol-1)*size(SK,1);...
            skrow+1+(skcol-1)*size(SK,1);...
            skrow-1+(skcol-1)*size(SK,1);...
            skrow+skcol*size(SK,1);...
            skrow+1+skcol*size(SK,1);...
            skrow-1+skcol*size(SK,1);...
            skrow+(skcol-2)*size(SK,1);...
            skrow+1+(skcol-2)*size(SK,1);...
            skrow-1+(skcol-2)*size(SK,1)]; % find the 8-connected area;
    skIndex=[skIndex;...
            skrow+2+(skcol-3)*size(SK,1);...
            skrow+2+(skcol-2)*size(SK,1);...
            skrow+2+(skcol-1)*size(SK,1);...
            skrow+2+skcol*size(SK,1);...
            skrow+2+(skcol+1)*size(SK,1);...
            skrow+1+(skcol-3)*size(SK,1);...
            skrow+1+(skcol+1)*size(SK,1);...
            skrow+(skcol-3)*size(SK,1);...
            skrow+(skcol+1)*size(SK,1);...
            skrow-1+(skcol-3)*size(SK,1);...
            skrow-1+(skcol+1)*size(SK,1);...
            skrow-2+(skcol-3)*size(SK,1);...
            skrow-2+(skcol-2)*size(SK,1);...
            skrow-2+(skcol-1)*size(SK,1);...
            skrow-2+skcol*size(SK,1);...
            skrow-2+(skcol+1)*size(SK,1)];% find the 24-connected area;
    skIndex = unique(skIndex); % row=mod(skIndex,size(SK,1)); col=skIndex/size(SK,1);
    
    %% skIndex -> skIndexOrigin;
    skRow=mod(skIndex,size(SK,1)); skCol=(skIndex-skRow)/size(SK,1)+1;
    skRowOrigin=mod(skIndexOrigin,size(SK,1)); skColOrigin=(skIndexOrigin-skRowOrigin)/size(SK,1)+1;
    skRowOrigins=repmat(skRowOrigin,1,length(skRow));
    skColOrigins=repmat(skColOrigin,1,length(skCol));
    skRows=repmat(skRow',length(skRowOrigin),1);
    skCols=repmat(skCol',length(skColOrigin),1);
    skDists=sqrt((skRows-skRowOrigins).^2+(skCols-skColOrigins).^2);
    [minDists, minIndexes]=min(skDists); % minIndexes: skIndex -> skIndexOrigin;
    assert((min(minDists)>=0)&(max(minDists)<=sqrt(8)));
    
    
    %% Calculate sk-values of the key-points on the boundary;
    I=imread([SK_name(1:end-7),'.png']);
    assert((size(SK,1)==size(I,1))&(size(SK,2)==size(I,2)));
    
    boundary=bwboundaries(I,'noholes');% format: [row;col];
    if length(boundary)>1
        fprintf('Warning: the numbers of boundary are more than one.( %s boundaries in %s )',num2str(length(boundary)),SK_name);
        L=zeros(length(boundary),1);
        for l=1:length(L)
            L(l) = size(boundary{l},1);
        end
        [~,maxL] = max(L);
        boundary=boundary{maxL};
    else
        boundary=boundary{1};
    end
    bdIndex=boundary(:,1)+(boundary(:,2)-1)*size(SK,1); % All points on the boundary;
    assert(bdIndex(1)==bdIndex(end));
    bdIndex=bdIndex(1:end-1); boundary=boundary(1:end-1,:);
    
    O=zeros(size(SK));O(bdIndex)=1;
    [~, IDX]=bwdist(O);
    sk2bd_IDX=IDX(skIndex); % Repeatable points on the boundary which are closest to points of the skeleton.
    bdKeyIndex=unique(sk2bd_IDX); % Key points on the boundary;
    bdKeyValue=zeros(size(bdKeyIndex));
    
    show=false; % visualization;
    if show
        close;
        imshow(I-SK);hold on;
    end
    for i=1:length(bdKeyIndex)
        %tmp_skIndex=skIndex(sk2bd_IDX==bdKeyIndex(i)); 
        tmp_skIndexOrigin=skIndexOrigin(minIndexes(sk2bd_IDX==bdKeyIndex(i)));% Points on the original skeleton, where their closest points on the boundary are the bdKeyIndex(i);
        tmp_skIndexOrigin=unique(tmp_skIndexOrigin);
        if isempty(tmp_skIndexOrigin)
            error('tmp_skIndexOrigin is empty! KeyPoint on the boundary match no points on the skeleton.');
        elseif (length(tmp_skIndexOrigin)==1) 
            bdKeyValue(i)=SK(tmp_skIndexOrigin);
            if show
                tmp_bdKeyRow=mod(bdKeyIndex(i),size(SK,1)); tmp_bdKeyCol=(bdKeyIndex(i)-tmp_bdKeyRow)/size(SK,1)+1;
                tmp_skRowOrigin=mod(tmp_skIndexOrigin,size(SK,1)); tmp_skColOrigin=(tmp_skIndexOrigin-tmp_skRowOrigin)/size(SK,1)+1;
                plot(linspace(double(tmp_bdKeyCol),tmp_skColOrigin,5),linspace(double(tmp_bdKeyRow),tmp_skRowOrigin,5));
            end
        else
            tmp_bdKeyRow=mod(bdKeyIndex(i),size(SK,1)); tmp_bdKeyCol=(bdKeyIndex(i)-tmp_bdKeyRow)/size(SK,1)+1;
            tmp_skRowOrigin=mod(tmp_skIndexOrigin,size(SK,1)); tmp_skColOrigin=(tmp_skIndexOrigin-tmp_skRowOrigin)/size(SK,1)+1;
            tmp_dist=sqrt((tmp_skRowOrigin-double(tmp_bdKeyRow)).^2+(tmp_skColOrigin-double(tmp_bdKeyCol)).^2);
            [~,tmp_minIndex]=min(tmp_dist);
            bdKeyValue(i)=SK(tmp_skIndexOrigin(tmp_minIndex));
            if show
                plot(linspace(double(tmp_bdKeyCol),tmp_skColOrigin(tmp_minIndex),5),linspace(double(tmp_bdKeyRow),tmp_skRowOrigin(tmp_minIndex),5));
            end
        end
    end
    
    %% Interpolate sk-values for rest of the points on the boundary;
    % find the first key-point on the list:
    bdKeyOrder=zeros(size(bdKeyIndex));
    for i=1:length(bdKeyIndex)
        Order=find(bdIndex==bdKeyIndex(i));
        if length(Order)>1
            Order=max(Order);
        end
        bdKeyOrder(i)=Order;
    end
    [bdKeyOrder_First,t]=min(bdKeyOrder);
    X=bdKeyOrder-bdKeyOrder_First+1; % bdKeyOrder_First->bdKeyOrder_Last->length(bdIndex)+1;
    X=[X;length(bdIndex)+1];
    Y=[bdKeyValue;bdKeyValue(t)];
    xi=1:(length(bdIndex)+1);
    yi=interp1(X,Y,xi)';
    bdValue=yi(1:end-1);
    bdValue=[bdValue(end-bdKeyOrder_First+2:end);bdValue(1:end-bdKeyOrder_First+1)];
    
    SkDist=zeros(size(SK));
    SkDist(bdIndex)=bdValue;
    save([SK_name(1:end-7),'_SkDist.mat'],'SkDist');