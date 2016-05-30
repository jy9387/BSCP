
function encode_csplus(img_dir, codebook_path, para)
    
    database = retr_database_dir(img_dir, '*_csplusfeat.mat');
    load(codebook_path);
    dict = dict;
    parfor n = 1:length(database.path)
        fprintf('Encoding ssc: %d of %d\n', n, length(database.path));
        func_encode_cfplus(database.path{n}, dict, para ); 
    end

function func_encode_cfplus(im_name, dict, para )
    
    %mirror:
    load([im_name(1:end-4),'_mirror.mat'], 'feat_scplus', 'xy', 'sz' );    
    code_scplus_mirror = LLC_coding_appr(dict.scplus, feat_scplus', para.knn)';

    %origin:
    load(im_name, 'feat_scplus', 'xy', 'sz' );    
    code_scplus_origin = LLC_coding_appr(dict.scplus, feat_scplus', para.knn)';
        
    %combine:
    code_scplus=code_scplus_origin+code_scplus_mirror;
    
    %norm:
    for i=1:size(code_scplus,2)
        code_scplus(:,i)=code_scplus(:,i)./norm(code_scplus(:,i),1);
    end
    save([im_name(1:end-15), '_codescplus.mat' ], 'code_scplus', 'xy', 'sz' );