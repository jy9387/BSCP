clear;

addpath('include/llc/');
addpath('include');
addpath(genpath('include/liblinear/matlab'));
addpath(genpath('include/toolbox/'));
addpath('include/idsc_distribute/common_innerdist/');

img_dir = 'data/Animal/';
fea_dir = fullfile('data/Animal_feas/');
if ~exist(fea_dir,'dir') 
    mkdir(fea_dir);
end
csplus_codebook_path = 'data/Animal_csplus_codebook.mat';

global TIME;
global TIME2;
TIME2.ssc = [];

para.n_shapesamp = 2000;
para.n_contsamp = 50;
para.max_curvature = 0.1;
para.n_pntsamp = 100;
para.knn = 5;
para.k_scplus = 2500;
para.n_ref = 5;
C = 10;
tr_num = 50;                % number of training images
nRounds = 10;
pyramid = [1,2,4];          %[1,2,3,4];

%% Shape-Skeleton-Context:
% tic,
% dist_sk2bd(img_dir, '*_SK.mat');
% TIME.sk2bd = toc;
% toc;
tic,
extr_cfplus(img_dir, '*.png', para);
TIME.extr = toc;
tic,
learn_codebook_plus(img_dir, csplus_codebook_path, para);% On test!
TIME.codebook = toc;
tic,
encode_csplus(img_dir, csplus_codebook_path, para);
TIME.encode = toc;
tic,
pyramid_pooling_scplus(img_dir, fea_dir, pyramid);
TIME.spm = toc;
%% Train & test:
TIME.pre_train = TIME.extr+TIME.codebook+(TIME.encode+TIME.spm)/2;
save('TIME.mat','TIME','TIME2');
svm_classify(fea_dir, tr_num, C, nRounds, inf, para.n_ref);

%% Results on Animal: (2015/10/08-18:26)
% ===============================================
% Average classification accuracy: 0.890400
% Standard deviation: 0.009513
% ===============================================