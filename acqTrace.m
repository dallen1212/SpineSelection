function acqTrace(acq,thresh)

warning('off','all');
spineShaftROIS(acq,thresh)

% Parameters
num_roi = size(acq.roiInfo.slice.roi,2);
num_subplots = 10;
len = num_subplots/2;
wid = 2;
sliceNum = 1;
channelNum = 1;
sel.disp.excludeFrames = [];
sel.disp.smoothWindow = 15;

movSizes = acq.correctedMovies.slice(sliceNum).channel(channelNum).size;
movLengths = movSizes(:, 3);
sel.movMap = memmapfile(acq.indexedMovie.slice(sliceNum).channel(channelNum).fileName,...
    'Format', {'int16', [sum(movLengths), movSizes(1,1)*movSizes(1,2)], 'mov'});
mov = sel.movMap.Data.mov;

figure
start = 1;
stop = num_subplots;
counter = 0;
while 1 == 1
    for i = start:stop
        if i > num_roi 
            pause
            start = 1;
            stop = num_subplots;
            counter = 0;
            break
        else
            movIndBody = acq.roiInfo.slice.roi(i).indBody;
            movIndNeuropil = acq.roiInfo.slice.roi(i).indNeuropil;
            
            sel.disp.fBody = mean(mov(:, acq.mat2binInd(movIndBody)), 2)';
            sel.disp.fNeuropil = mean(mov(:, acq.mat2binInd(movIndNeuropil)), 2)';
            
            sel.disp.fBody(sel.disp.excludeFrames) = [];
            sel.disp.fNeuropil(sel.disp.excludeFrames) = [];
            
            sel.disp.fBody = deBleach(sel.disp.fBody, 'linear');
            sel.disp.fNeuropil = deBleach(sel.disp.fNeuropil, 'linear');
            sel.disp.f0Body = prctile(sel.disp.fBody,10);
            
            smoothWin = gausswin(sel.disp.smoothWindow)/sum(gausswin(sel.disp.smoothWindow));
            sel.disp.fBody = conv(sel.disp.fBody, smoothWin, 'valid');
            sel.disp.fNeuropil = conv(sel.disp.fNeuropil, smoothWin, 'valid');
            
            sp_in = i - 10*counter;
            subplot(wid,len,sp_in);            
            plot(sel.disp.fNeuropil-median(sel.disp.fNeuropil), sel.disp.fBody-median(sel.disp.fBody),...
                '.', 'markersize', 3)
            cur_roi = sprintf('ROI: %01d',i);
            title(cur_roi);

            if i == stop
                pause
                clf
                start = start+num_subplots;
                stop = stop + num_subplots;
                counter = counter + 1;
            end
        end
    end
end