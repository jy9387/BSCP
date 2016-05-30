function learn_codebook_plus(img_dir, codebook_path, para)
if exist('data/feats_scplus.mat','file')
    disp('feats_scplus.mat existed.');
    load('data/feats_scplus.mat');
else
    database1 = retr_database_dir(img_dir, '*_csplusfeat.mat');
    database2 = retr_database_dir(img_dir, '*_csplusfeat_mirror.mat');
    %database=database1;database.path=[database1.path,database2.path];database.label=[database1.label;database2.label];
    N = length(database1.path);
    assert(N==length(database2.path));
    ri = randperm(N);
    M = N;
    feats_scplus = cell( 1, M );
    for n = 1:M
        fprintf('Loading ssc features: %d of %d\n', n, M );
        load(database2.path{ri(n)}, 'feat_scplus' );
        feat_scplus_mirror=feat_scplus;
        load(database1.path{ri(n)}, 'feat_scplus' );
        feat_scplus_origin=feat_scplus;
        assert(size(feat_scplus_origin,2)==size(feat_scplus_mirror,2));
        nmax = 600;
        if size(feat_scplus_origin, 2) > nmax
            ri2 = randperm( size(feat_scplus_origin,2) );
            feat_scplus_origin = feat_scplus_origin(:, ri2(1:nmax) );
            feat_scplus_mirror = feat_scplus_mirror(:, ri2(1:nmax) );
        end
        feat_scplus=[feat_scplus_origin, feat_scplus_mirror];
        feats_scplus{n} = feat_scplus;
    end
    clear database1;clear database2;clear feat_scplus_origin;clear feat_scplus_mirror;
    feats_scplus = single(cell2mat(feats_scplus));
    save('data/feats_scplus.mat','feats_scplus');
end
% %     [IDX, dict_scplus, d] = kmeans2(feats_scplus', para.k_scplus);
    
%% hierarchical kmeans:
    dict_scplus=zeros(para.k_scplus,size(feats_scplus,1));
    k1=5;
if exist(['data/IDX0(',num2str(para.k_scplus),').mat'],'file')
    disp('data/IDX0.mat existed. Loading...');
    load(['data/IDX0(',num2str(para.k_scplus),').mat']);
else
    tic,
    IDX0 = kmeans2(feats_scplus', k1);
    toc;
    save(['data/IDX0(',num2str(para.k_scplus),').mat'],'IDX0');
end
    for i=1:k1
        tic,
        feats_tmp=feats_scplus(:,IDX0==i);
        assert(size(feats_tmp,2)>=para.k_scplus/k1);
        [~,dict_scplus(((i-1)*para.k_scplus/k1+(1:para.k_scplus/k1)),:),~]=kmeans2(feats_tmp', para.k_scplus/k1);
        toc;
    end
    
    dict.scplus = dict_scplus;

    save(codebook_path, 'dict' );