function extr_cfplus(img_dir, fmt, scplus_para)
    database = retr_database_dir(img_dir, fmt);
	tic
    for n = 1 : length(database.path)
        fprintf('Extracting SSC features: %d of %d\n', n, length(database.path));
        func_extr_cfplus(database.path{n}, scplus_para ); 
    end
	toc

function func_extr_cfplus(im_name, cf_para )
    global TIME2;
    if ~exist([im_name(1:end-4), '_csplusfeat_mirror.mat' ], 'file') || ~exist([im_name(1:end-4), '_csplusfeat.mat' ], 'file')
        I = imread( im_name );
        if size(I, 3) > 1
            for i=1:size(I,3)
                a=(I(:,:,i));
                if max(max(a))~=min(min(a))
                    I=a;
                    break               
                end
            end
        end
        I = double( I );
        %% contour information:     
        if 0
            load([im_name(1:end-4), '_feat.mat' ], 'pnts');
        else
            C = extract_longest_cont(I, cf_para.n_shapesamp);

    %         sigma = 0.2;
    %         C = C + sigma * randn(size(C));

            pnts = extr_raw_pnts( C, cf_para.max_curvature, cf_para.n_contsamp, cf_para.n_pntsamp );
        end

        %% skeleton information:
        load([im_name(1:end-4),'_SkDist.mat']);
        [dist_map, IDX] = bwdist(SkDist > 0);
        len = length(pnts);
        feat_sk=zeros( 0, len );
        for i=1:len
            tmp_IDX = IDX(round(pnts{i}(:, 2)) + round((pnts{i}(:, 1) - 1)) * size(dist_map, 1));
            sk = SkDist(tmp_IDX);
            feat_sk(1:size(sk,1),i)=sk;
        end

        %% compute ssc features:
        %origin:
        feat_scplus = zeros( 0, len ); 
        xy = zeros( len, 2 );
        tic,
        for i = 1:len
            cont=[pnts{i}, feat_sk(:,i)];
            scplus = shape_context_plus( cont, cf_para.n_ref );
            scplus = scplus(:);
            scplus = scplus / sum(scplus);

            cf = pnts{i};
            feat_scplus(  1:size(scplus,1), i ) = scplus;
            xy( i, 1:2 ) = cf( round(end/2), : );
        end
        time = toc;
        TIME2.ssc = [TIME2.ssc; time/len];
        sz = size(I);
        save([im_name(1:end-4), '_csplusfeat.mat' ], 'pnts', 'feat_scplus', 'feat_sk', 'xy', 'sz');
        %mirror:
        feat_scplus = zeros( 0, len ); 
        xy = zeros( len, 2 );
        pnts=mirror(pnts,I);
        feat_sk=feat_sk(end:-1:1,:);
        for i = 1:len
            cont=[pnts{i}, feat_sk(:,i)];
            scplus = shape_context_plus( cont, cf_para.n_ref );
            scplus = scplus(:);
            scplus = scplus / sum(scplus);

            cf = pnts{i};
            feat_scplus(  1:size(scplus,1), i ) = scplus;
            xy( i, 1:2 ) = cf( round(end/2), : );
        end
        save([im_name(1:end-4), '_csplusfeat_mirror.mat' ], 'pnts', 'feat_scplus', 'feat_sk', 'xy', 'sz');
    else
        disp([im_name(1:end-4), '_csplusfeat.mat/_mirror.mat exists. Skip...' ]);
    end