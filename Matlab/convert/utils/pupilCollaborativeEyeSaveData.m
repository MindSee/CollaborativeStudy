function [] = pupilCollaborativeEyeSaveData(fileSave, eyes, threesholdTrials, overwrite)
% --
%
%   Syntax:
%          [] = pupilCollaborativeEyeSaveData(fileSave, eyes, threesholdTrials, overwrite)
%
%   Parameters:
%               --
%
%   Return values:
%           	--
%
%	Author: Filippo M.  02/02/2015


try
    % Variables
    fileExtension = '.xlsx';
    file = [fileSave, fileExtension];
    nBlock = length(eyes);
    nTrial = 4;
    
    if (exist(file)~=0) && (overwrite == false)
    else
        delete(file);
        if (nBlock~=0)
            
            if ismac
                % xlwrite Initialize
                xlwriteInitialize();
            end
            
            % % Sheet 1
            sheet = 1;  iRow = 3;
            % Headings
            writeXlsx(file, {[num2str(threesholdTrials), ' trials for each block [SUM for coloumn: B, C, E, F, H, J, K] [AVERAGE for other coloumn]']}, sheet, strcat('A', '1'));
            
            writeXlsx(file, {'Trial'}, sheet, strcat('A', num2str(iRow)));
            writeXlsx(file, {'Blink number'}, sheet, strcat('B', num2str(iRow)));
            writeXlsx(file, {'Blink duration tot.'}, sheet, strcat('C', num2str(iRow)));
            writeXlsx(file, {'Blink duration mean'}, sheet, strcat('D', num2str(iRow)));
            writeXlsx(file, {'Saccade number'}, sheet, strcat('E', num2str(iRow)));
            writeXlsx(file, {'Saccade duration tot.'}, sheet, strcat('F', num2str(iRow)));
            writeXlsx(file, {'Saccade duration mean'}, sheet, strcat('G', num2str(iRow)));
            writeXlsx(file, {'Saccade speed tot.'}, sheet, strcat('H', num2str(iRow)));
            writeXlsx(file, {'Saccade speed mean'}, sheet, strcat('I', num2str(iRow)));
            writeXlsx(file, {'Fixation number'}, sheet, strcat('J', num2str(iRow)));
            writeXlsx(file, {'Fixation duration tot.'}, sheet, strcat('K', num2str(iRow)));
            writeXlsx(file, {'Fixation duration mean'}, sheet, strcat('L', num2str(iRow)));
            writeXlsx(file, {'Fixation pupil size X mean'}, sheet, strcat('M', num2str(iRow)));
            writeXlsx(file, {'Fixation pupil size X max'}, sheet, strcat('N', num2str(iRow)));
            for iBlock = 1 : nBlock
                nTrial = length(eyes(iBlock, 1).eye.movements.target);
                if nTrial > threesholdTrials
                    nTrial = threesholdTrials;
                end
                for iTrial = 1 : nTrial
                    iRow = iRow + 1;
                    writeXlsx(file, {[eyes(iBlock, 1).eye.movements.simbol{iTrial, 1}, '_', eyes(iBlock, 1).eye.movements.focus{iTrial, 1}, '_', eyes(iBlock, 1).eye.movements.target{iTrial, 1}]}, sheet, strcat('A', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.blink.number(iTrial, 1)}, sheet, strcat('B', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.blink.duration.total(iTrial, 1)}, sheet, strcat('C', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.blink.duration.mean(iTrial, 1)}, sheet, strcat('D', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.number(iTrial, 1)}, sheet, strcat('E', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.duration.total(iTrial, 1)}, sheet, strcat('F', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.duration.mean(iTrial, 1)}, sheet, strcat('G', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.speed.total(iTrial, 1)}, sheet, strcat('H', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.speed.mean(iTrial, 1)}, sheet, strcat('I', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.number(iTrial, 1)}, sheet, strcat('J', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.duration.total(iTrial, 1)}, sheet, strcat('K', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.duration.mean(iTrial, 1)}, sheet, strcat('L', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.pupil.size.x.mean(iTrial, 1)}, sheet, strcat('M', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.pupil.size.x.max(iTrial, 1)}, sheet, strcat('N', num2str(iRow)));
                end
                
                iRow = iRow + 1;
                
                writeXlsx(file, {['Block sum/mean']}, sheet, strcat('A', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(sum(eyes(iBlock, 1).eye.movements.blink.number((1 : threesholdTrials), 1)))}, sheet, strcat('B', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(sum(eyes(iBlock, 1).eye.movements.blink.duration.total((1 : threesholdTrials), 1)))}, sheet, strcat('C', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(meanNotNaN(eyes(iBlock, 1).eye.movements.blink.duration.mean((1 : threesholdTrials), 1)))}, sheet, strcat('D', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(sum(eyes(iBlock, 1).eye.movements.saccade.number((1 : threesholdTrials), 1)))}, sheet, strcat('E', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(sum(eyes(iBlock, 1).eye.movements.saccade.duration.total((1 : threesholdTrials), 1)))}, sheet, strcat('F', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(meanNotNaN(eyes(iBlock, 1).eye.movements.saccade.duration.mean((1 : threesholdTrials), 1)))}, sheet, strcat('G', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(sum(eyes(iBlock, 1).eye.movements.saccade.speed.total((1 : threesholdTrials), 1)))}, sheet, strcat('H', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(meanNotNaN(eyes(iBlock, 1).eye.movements.saccade.speed.mean((1 : threesholdTrials), 1)))}, sheet, strcat('I', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(sum(eyes(iBlock, 1).eye.movements.fixations.number((1 : threesholdTrials), 1)))}, sheet, strcat('J', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(sum(eyes(iBlock, 1).eye.movements.fixations.duration.total((1 : threesholdTrials), 1)))}, sheet, strcat('K', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(meanNotNaN(eyes(iBlock, 1).eye.movements.fixations.duration.mean((1 : threesholdTrials), 1)))}, sheet, strcat('L', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(meanNotNaN(eyes(iBlock, 1).eye.movements.fixations.pupil.size.x.mean((1 : threesholdTrials), 1)))}, sheet, strcat('M', num2str(iRow)));
                writeXlsx(file, {pupilDataControl(meanNotNaN(eyes(iBlock, 1).eye.movements.fixations.pupil.size.x.max((1 : threesholdTrials), 1)))}, sheet, strcat('N', num2str(iRow)));
                
                iRow = iRow + 1;
                
            end
            
            % % Sheet 2
            sheet = 2; iRow = 3;
            % Headings
            writeXlsx(file, {[num2str(threesholdTrials), ' trials for each block [SUM for coloumn: B, C, E, F, H, J, K] [AVERAGE for other coloumn]']}, sheet, strcat('A', '1'));
            
            writeXlsx(file, {'Trial'}, sheet, strcat('A', num2str(iRow)));
            writeXlsx(file, {'Blink number'}, sheet, strcat('B', num2str(iRow)));
            writeXlsx(file, {'Blink duration tot.'}, sheet, strcat('C', num2str(iRow)));
            writeXlsx(file, {'Blink duration mean'}, sheet, strcat('D', num2str(iRow)));
            writeXlsx(file, {'Saccade number'}, sheet, strcat('E', num2str(iRow)));
            writeXlsx(file, {'Saccade duration tot.'}, sheet, strcat('F', num2str(iRow)));
            writeXlsx(file, {'Saccade duration mean'}, sheet, strcat('G', num2str(iRow)));
            writeXlsx(file, {'Saccade speed tot.'}, sheet, strcat('H', num2str(iRow)));
            writeXlsx(file, {'Saccade speed mean'}, sheet, strcat('I', num2str(iRow)));
            writeXlsx(file, {'Fixation number'}, sheet, strcat('J', num2str(iRow)));
            writeXlsx(file, {'Fixation duration tot.'}, sheet, strcat('K', num2str(iRow)));
            writeXlsx(file, {'Fixation duration mean'}, sheet, strcat('L', num2str(iRow)));
            writeXlsx(file, {'Fixation pupil size X mean'}, sheet, strcat('M', num2str(iRow)));
            writeXlsx(file, {'Fixation pupil size X max'}, sheet, strcat('N', num2str(iRow)));
            for iBlock = 1 : nBlock
                nTrial = length(eyes(iBlock, 1).eye.movements.target);
                if nTrial > threesholdTrials
                    nTrial = threesholdTrials;
                end
                for iTrial = 1 : nTrial
                    iRow = iRow + 1;
                    writeXlsx(file, {[eyes(iBlock, 1).eye.movements.simbol{iTrial, 1}, '_', eyes(iBlock, 1).eye.movements.focus{iTrial, 1}, '_', eyes(iBlock, 1).eye.movements.target{iTrial, 1}]}, sheet, strcat('A', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.blink.number(iTrial, 1)}, sheet, strcat('B', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.blink.duration.total(iTrial, 1)}, sheet, strcat('C', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.blink.duration.mean(iTrial, 1)}, sheet, strcat('D', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.number(iTrial, 1)}, sheet, strcat('E', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.duration.total(iTrial, 1)}, sheet, strcat('F', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.duration.mean(iTrial, 1)}, sheet, strcat('G', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.speed.total(iTrial, 1)}, sheet, strcat('H', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.speed.mean(iTrial, 1)}, sheet, strcat('I', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.number(iTrial, 1)}, sheet, strcat('J', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.duration.total(iTrial, 1)}, sheet, strcat('K', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.duration.mean(iTrial, 1)}, sheet, strcat('L', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.pupil.size.x.mean(iTrial, 1)}, sheet, strcat('M', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.pupil.size.x.max(iTrial, 1)}, sheet, strcat('N', num2str(iRow)));
                end
                if (iBlock == 6) || (iBlock == 12)
                    
                    iRow = iRow + 1;
                    
                    
                    writeXlsx(file, {['Focus sum/mean']}, sheet, strcat('A', num2str(iRow)));
                    writeXlsx(file, {pupilDataControl(sum([eyes(((iBlock - 5)), 1).eye.movements.blink.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.blink.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.blink.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.blink.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.blink.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.blink.number((1 : threesholdTrials), 1)]))}, sheet, strcat('B', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(sum([eyes(((iBlock - 5)), 1).eye.movements.blink.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.blink.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.blink.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.blink.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.blink.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.blink.duration.total((1 : threesholdTrials), 1)]))}, sheet, strcat('C', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(meanNotNaN([eyes(((iBlock - 5)), 1).eye.movements.blink.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.blink.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.blink.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.blink.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.blink.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.blink.duration.mean((1 : threesholdTrials), 1)]))}, sheet, strcat('D', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(sum([eyes(((iBlock - 5)), 1).eye.movements.saccade.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.saccade.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.saccade.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.saccade.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.saccade.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.saccade.number((1 : threesholdTrials), 1)]))}, sheet, strcat('E', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(sum([eyes(((iBlock - 5)), 1).eye.movements.saccade.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.saccade.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.saccade.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.saccade.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.saccade.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.saccade.duration.total((1 : threesholdTrials), 1)]))}, sheet, strcat('F', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(meanNotNaN([eyes(((iBlock - 5)), 1).eye.movements.saccade.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.saccade.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.saccade.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.saccade.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.saccade.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.saccade.duration.mean((1 : threesholdTrials), 1)]))}, sheet, strcat('G', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(sum([eyes(((iBlock - 5)), 1).eye.movements.saccade.speed.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.saccade.speed.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.saccade.speed.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.saccade.speed.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.saccade.speed.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.saccade.speed.total((1 : threesholdTrials), 1)]))}, sheet, strcat('H', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(meanNotNaN([eyes(((iBlock - 5)), 1).eye.movements.saccade.speed.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.saccade.speed.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.saccade.speed.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.saccade.speed.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.saccade.speed.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.saccade.speed.mean((1 : threesholdTrials), 1)]))}, sheet, strcat('I', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(sum([eyes(((iBlock - 5)), 1).eye.movements.fixations.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.fixations.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.fixations.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.fixations.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.fixations.number((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.fixations.number((1 : threesholdTrials), 1)]))}, sheet, strcat('J', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(sum([eyes(((iBlock - 5)), 1).eye.movements.fixations.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.fixations.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.fixations.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.fixations.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.fixations.duration.total((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.fixations.duration.total((1 : threesholdTrials), 1)]))}, sheet, strcat('K', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(meanNotNaN([eyes(((iBlock - 5)), 1).eye.movements.fixations.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.fixations.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.fixations.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.fixations.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.fixations.duration.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.fixations.duration.mean((1 : threesholdTrials), 1)]))}, sheet, strcat('L', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(meanNotNaN([eyes(((iBlock - 5)), 1).eye.movements.fixations.pupil.size.x.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.fixations.pupil.size.x.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.fixations.pupil.size.x.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.fixations.pupil.size.x.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.fixations.pupil.size.x.mean((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.fixations.pupil.size.x.mean((1 : threesholdTrials), 1)]))}, sheet, strcat('M', num2str(iRow)));
                    
                    writeXlsx(file, {pupilDataControl(meanNotNaN([eyes(((iBlock - 5)), 1).eye.movements.fixations.pupil.size.x.max((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 4)), 1).eye.movements.fixations.pupil.size.x.max((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 3)), 1).eye.movements.fixations.pupil.size.x.max((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 2)), 1).eye.movements.fixations.pupil.size.x.max((1 : threesholdTrials), 1);...
                        eyes(((iBlock - 1)), 1).eye.movements.fixations.pupil.size.x.max((1 : threesholdTrials), 1);...
                        eyes(((iBlock)), 1).eye.movements.fixations.pupil.size.x.max((1 : threesholdTrials), 1)]))}, sheet, strcat('N', num2str(iRow)));
                    
                    iRow = iRow + 1;
                    
                end
            end
            
            % % Sheet 3
            sheet = 3; iRow = 3;
            % Headings
            writeXlsx(file, {'All trials for each block (without sum and average)'}, sheet, strcat('A', '1'));
            
            writeXlsx(file, {'Trial'}, sheet, strcat('A', num2str(iRow)));
            writeXlsx(file, {'Blink number'}, sheet, strcat('B', num2str(iRow)));
            writeXlsx(file, {'Blink duration tot.'}, sheet, strcat('C', num2str(iRow)));
            writeXlsx(file, {'Blink duration mean'}, sheet, strcat('D', num2str(iRow)));
            writeXlsx(file, {'Saccade number'}, sheet, strcat('E', num2str(iRow)));
            writeXlsx(file, {'Saccade duration tot.'}, sheet, strcat('F', num2str(iRow)));
            writeXlsx(file, {'Saccade duration mean'}, sheet, strcat('G', num2str(iRow)));
            writeXlsx(file, {'Saccade speed tot.'}, sheet, strcat('H', num2str(iRow)));
            writeXlsx(file, {'Saccade speed mean'}, sheet, strcat('I', num2str(iRow)));
            writeXlsx(file, {'Fixation number'}, sheet, strcat('J', num2str(iRow)));
            writeXlsx(file, {'Fixation duration tot.'}, sheet, strcat('K', num2str(iRow)));
            writeXlsx(file, {'Fixation duration mean'}, sheet, strcat('L', num2str(iRow)));
            writeXlsx(file, {'Fixation pupil size X mean'}, sheet, strcat('M', num2str(iRow)));
            writeXlsx(file, {'Fixation pupil size X max'}, sheet, strcat('N', num2str(iRow)));
            
            for iBlock = 1 : nBlock
                for iTrial = 1 : length(eyes(iBlock, 1).eye.movements.target)
                    iRow = iRow + 1;
                    writeXlsx(file, {[eyes(iBlock, 1).eye.movements.simbol{iTrial, 1}, '_', eyes(iBlock, 1).eye.movements.focus{iTrial, 1}, '_', eyes(iBlock, 1).eye.movements.target{iTrial, 1}]}, sheet, strcat('A', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.blink.number(iTrial, 1)}, sheet, strcat('B', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.blink.duration.total(iTrial, 1)}, sheet, strcat('C', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.blink.duration.mean(iTrial, 1)}, sheet, strcat('D', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.number(iTrial, 1)}, sheet, strcat('E', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.duration.total(iTrial, 1)}, sheet, strcat('F', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.duration.mean(iTrial, 1)}, sheet, strcat('G', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.speed.total(iTrial, 1)}, sheet, strcat('H', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.saccade.speed.mean(iTrial, 1)}, sheet, strcat('I', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.number(iTrial, 1)}, sheet, strcat('J', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.duration.total(iTrial, 1)}, sheet, strcat('K', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.duration.mean(iTrial, 1)}, sheet, strcat('L', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.pupil.size.x.mean(iTrial, 1)}, sheet, strcat('M', num2str(iRow)));
                    writeXlsx(file, {eyes(iBlock, 1).eye.movements.fixations.pupil.size.x.max(iTrial, 1)}, sheet, strcat('N', num2str(iRow)));
                end
                iRow = iRow + 1;
            end
        end
    end
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

function [] = writeXlsx(file, array, sheet, range)
% --
%
%   Syntax:
%          [] = writeXlsx(file, array, sheet, range)
%
%   Parameters:
%               --
%
%   Return values:
%           	--
%
%	Author: Filippo M.  24/03/2015


try
    if ismac
        xlwrite(file, array, sheet, range);
    else
        xlswrite(file, array, sheet, range);
    end
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end