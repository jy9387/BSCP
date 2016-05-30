
function normalize_size(img_dir, fmt)
    
    database = retr_database_dir(img_dir, fmt);

	tic
    %matlabpool(4);
    for n = 1:length(database.path)
        fprintf('Normalize size: %d of %d\n', n, length(database.path));
        func_normalize_size(database.path{n} ); 
    end
    %matlabpool close;
	toc

function func_normalize_size(SK_name )
    
	load(SK_name);
    I = imread([SK_name(1:end-7),'.png']);
    [row, col] = size(SK');
    I = imresize(I, [row, col]);
    imwrite(I, [SK_name(1:end-7), '.png']);
    
    