function spineShaftROIS(acq,thresh)
acq.roiInfo.slice.roi = [];
img = acq.motionRefImage.slice.img;
img(img < thresh) = 1.5;
figure;

if any(any(floor(img)==img))
    fprintf('Integer check failed...\n');
end
i = size(img,1);
%256
j = size(img,2);
%512
clus_num = 1;
for ji = 1:j
    for ii = 1:i
        unique = 1;
        if img(ii,ji) == 1.5
        elseif img(ii,ji) > 1.5
            if ii > 1 && ji > 1
                if floor(img(ii-1,ji-1))==img(ii-1,ji-1)
                    img(ii,ji) = img(ii-1,ji-1);
                    unique = 0;
                end
            end
            if ii > 1
                if floor(img(ii-1,ji))==img(ii-1,ji)
                    img(ii,ji) = img(ii-1,ji);
                    unique = 0;
                end
            end
            if ii > 1 && ji <= j-1
                if floor(img(ii-1,ji+1))==img(ii-1,ji+1)
                    img(ii,ji) = img(ii-1,ji+1);
                    unique = 0;
                end
            end
            if ji > 1
                if floor(img(ii,ji-1))==img(ii,ji-1)
                    img(ii,ji) = img(ii,ji-1);
                    unique = 0;
                end
            end
            if ji <= j-1
                if floor(img(ii,ji+1))==img(ii,ji+1)
                    img(ii,ji) = img(ii,ji+1);
                    unique = 0;
                end
            end
            if ii <= i-1 && ji > 1
                if floor(img(ii+1,ji-1))==img(ii+1,ji-1)
                    img(ii,ji) = img(ii+1,ji-1);
                    unique = 0;
                end
            end
            if ii <= i-1
                if floor(img(ii+1,ji))==img(ii+1,ji)
                    img(ii,ji) = img(ii+1,ji);
                    unique = 0;
                end
            end
            if ii <= i-1 && ji <= j-1
                if floor(img(ii+1,ji+1))==img(ii+1,ji+1)
                    img(ii,ji) = img(ii+1,ji+1);
                    unique = 0;
                elseif unique == 1;
                    img(ii,ji) = clus_num;
                    clus_num = clus_num+1;
                end
            end
        end
    end
end
for ji = j:-1:1
    for ii = i:-1:1
        if img(ii,ji) == 1.5
        elseif img(ii,ji) > 1.5
            if ii > 1 && ji > 1
                if floor(img(ii-1,ji-1))==img(ii-1,ji-1)
                    img(ii,ji) = img(ii-1,ji-1);
                end
            end
            if ii > 1
                if floor(img(ii-1,ji))==img(ii-1,ji)
                    img(ii,ji) = img(ii-1,ji);
                end
            end
            if ii > 1 && ji <= j-1
                if floor(img(ii-1,ji+1))==img(ii-1,ji+1)
                    img(ii,ji) = img(ii-1,ji+1);
                end
            end
            if ji > 1
                if floor(img(ii,ji-1))==img(ii,ji-1)
                    img(ii,ji) = img(ii,ji-1);
                end
            end
            if ji <= j-1
                if floor(img(ii,ji+1))==img(ii,ji+1)
                    img(ii,ji) = img(ii,ji+1);
                end
            end
            if ii <= i-1 && ji > 1
                if floor(img(ii+1,ji-1))==img(ii+1,ji-1)
                    img(ii,ji) = img(ii+1,ji-1);
                end
            end
            if ii <= i-1
                if floor(img(ii+1,ji))==img(ii+1,ji)
                    img(ii,ji) = img(ii+1,ji);
                end
            end
            if ii <= i-1 && ji <= j-1
                if floor(img(ii+1,ji+1))==img(ii+1,ji+1)
                    img(ii,ji) = img(ii+1,ji+1);
                end
            end
        end
    end
end

in_mat = zeros(i*j,1);
count = 1;

for yi = 1:j
    for xi = 1:i
        in_mat(count,1) = img(xi,yi);
        count = count+1;
    end
end
num_clus = max(max(img));
for ci = 1:num_clus
    acq.roiInfo.slice.roi(ci).id = ci;
    acq.roiInfo.slice.roi(ci).group = ci;
    acq.roiInfo.slice.roi(ci).indBody = find(in_mat==ci);
    acq.roiInfo.slice.roi(ci).subCoef = [];
end

fprintf('# of ROIs: %01d\n',num_clus);
fprintf('Press Ctrl+c to close, or Space to continue\n');
pause
subplot(2,1,1);
cov_im = acq.derivedData(1).meanRef.slice.channel.img;
image(cov_im);
title('Select Dendritic Shaft Area');
BW = impoly;
bin_mat = BW.createMask;
shaft_in = find(bin_mat);
for ci = 1:num_clus
    acq.roiInfo.slice.roi(ci).indNeuropil = shaft_in;
end

title('Covariance Data');
preview = img;
x_pos = zeros(num_clus,1);
y_pos = zeros(num_clus,1);
for ti = 1:num_clus
    [x_clus,y_clus] = find(preview == ti);
    x_pos(ti) = min(x_clus);
    y_pos(ti) = min(y_clus);
end

preview(floor(preview)==preview) = 50;
preview = imfuse(cov_im,preview);
%preview = mat2gray(preview);
clus_vec = 1:num_clus;
%coordinates = cat(2,x_pos,y_pos);
subplot(2,1,2);
image(preview);
text(y_pos,x_pos,num2cell(clus_vec),'Color','red');
title('Potential ROIs');
acq.save;
