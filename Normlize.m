function Normlize
img_dir = 'data/Animal/';
database = retr_database_dir(img_dir, '*.tif');

    for n = 1:length(database.path)
        I = imread(database.path{n});
        [x, y] = find(I > 0);
        pnts = [x, y];
        pnts = pnts - repmat(mean(pnts), size(pnts, 1), 1);
        pnts_cov = cov(pnts);
        pri_vec = pcacov(pnts_cov);
        ori = cal_ori(pri_vec(:, 1));
        Ir = imrotate(I, ori * 180 / pi);
        imwrite(Ir, [database.path{n}(1:end-3), 'bmp']);
    end
end

function ori = cal_ori(pri_vec)

ori = atan(pri_vec(1) / pri_vec(2) + eps);

if(pri_vec(1) < 0 && pri_vec(2) < 0)
    ori = ori - pi;
end

if(pri_vec(1) > 0 &&  pri_vec(2) < 0)
    ori = ori + pi;
end
end