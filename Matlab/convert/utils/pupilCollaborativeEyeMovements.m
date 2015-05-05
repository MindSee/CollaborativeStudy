function [eye] = pupilCollaborativeEyeMovements(input)
% --
%
%   Syntax:
%          [eye] = pupilCollaborativeEyeMovements(input)
%
%   Parameters:
%           --
%
%   Return values:
%           --
%
%	Author: Filippo M.  20/03/2015


try
    % Nargin
    if nargin < 1
        [eye] = pupilBinocularData();
    else
        % Get RAW
        if isstruct(input)
            [eye] = input;
        else
            [eye] = pupilBinocularData(input);
        end
    end
    
    iStimulus = 0;
    
    for iTrial = 1 : length(eye.events.trial)
        if (strfind(eye.events.description{iTrial, 1}, '_Start_'))
            
            disp('');
            
            % Counter
            iStimulus = iStimulus + 1;
            
            %
            separator = strfind(eye.events.description{4, 1}, '_');
            eye.movements.simbol{iStimulus, 1} = eye.events.description{iTrial, 1}((separator(1, 2) + 1) : separator(1, 2) + 2);
            eye.movements.focus{iStimulus, 1} = eye.events.description{iTrial, 1}((separator(1, 3) + 1) : separator(1, 3) + 2);
            eye.movements.target{iStimulus, 1} = eye.events.description{iTrial, 1}((separator(1, 4) + 1) : separator(1, 4) + 2);
            disp(['Trial [number: ', num2str(eye.events.trial(iTrial, 1)), '] [simbol: ', eye.movements.simbol{iStimulus, 1}, '] [focus: ', eye.movements.focus{iStimulus, 1}, '] [stimulus: ', eye.movements.target{iStimulus, 1}, ']']);
            
            
            
            % % Blink
            eye.movements.blink.number(iStimulus, 1) = 0;
            eye.movements.blink.duration.total(iStimulus, 1) = 0;
            eye.movements.blink.duration.mean(iStimulus, 1) = 0;
            for iBlinks = 1 : length(eye.blink.trial)
                if (eye.blink.trial(iBlinks, 1) == eye.events.trial(iTrial, 1))
                    eye.movements.blink.number(iStimulus, 1) = eye.movements.blink.number(iStimulus, 1) + 1;
                    eye.movements.blink.duration.total(iStimulus, 1) = eye.movements.blink.duration.total(iStimulus, 1) + eye.blink.duration(iBlinks, 1);
                end
            end
            
            if eye.movements.blink.number(iStimulus, 1)==0
                eye.movements.blink.duration.mean(iStimulus, 1) = 0;
            else
                eye.movements.blink.duration.mean(iStimulus, 1) = pupilDataControl((eye.movements.blink.duration.total(iStimulus, 1)/eye.movements.blink.number(iStimulus, 1)));
            end
            
            disp(['    BLINK [nr.: ', num2str(eye.movements.blink.number(iStimulus, 1)), ']']);
            disp(['         duration tot.     = ', num2str(eye.movements.blink.duration.total(iStimulus, 1))]);
            disp(['         duration mean     = ', num2str(eye.movements.blink.duration.mean(iStimulus, 1))]);
            
            
            
            % % Saccade
            eye.movements.saccade.number(iStimulus, 1) = 0;
            eye.movements.saccade.duration.total(iStimulus, 1) = 0;
            eye.movements.saccade.duration.mean(iStimulus, 1) = 0;
            eye.movements.saccade.speed.total(iStimulus, 1) = 0;
            eye.movements.saccade.speed.mean(iStimulus, 1) = 0;
            for iSaccade = 1 : length(eye.saccade.trial)
                if (eye.saccade.trial(iSaccade, 1) == eye.events.trial(iTrial, 1))
                    eye.movements.saccade.number(iStimulus, 1) = eye.movements.saccade.number(iStimulus, 1) + 1;
                    eye.movements.saccade.duration.total(iStimulus, 1) = eye.movements.saccade.duration.total(iStimulus, 1) + eye.saccade.duration(iSaccade, 1);
                    eye.movements.saccade.speed.total(iStimulus, 1) = eye.movements.saccade.speed.total(iStimulus, 1) + eye.saccade.speed.average(iSaccade, 1);
                end
            end
            
            if eye.movements.saccade.number(iStimulus, 1)==0
                eye.movements.saccade.duration.mean(iStimulus, 1) = 0;
                eye.movements.saccade.speed.mean(iStimulus, 1) = 0;
            else
                eye.movements.saccade.duration.mean(iStimulus, 1) = pupilDataControl((eye.movements.saccade.duration.total(iStimulus, 1)/eye.movements.saccade.number(iStimulus, 1)));
                eye.movements.saccade.speed.mean(iStimulus, 1) = pupilDataControl((eye.movements.saccade.speed.total(iStimulus, 1)/eye.movements.saccade.number(iStimulus, 1)));
            end
            
            disp(['  SACCADE [nr.: ', num2str(eye.movements.saccade.number(iStimulus, 1)), ']']);
            disp(['         duration tot.     = ', num2str(eye.movements.saccade.duration.total(iStimulus, 1))]);
            disp(['         duration mean     = ', num2str(eye.movements.saccade.duration.mean(iStimulus, 1))]);
            disp(['         speed tot.        = ', num2str(eye.movements.saccade.speed.total(iStimulus, 1))]);
            disp(['         speed mean        = ', num2str(eye.movements.saccade.speed.mean(iStimulus, 1))]);
            
            
            
            % % Fixation
            eye.movements.fixations.number(iStimulus, 1) = 0;
            eye.movements.fixations.duration.total(iStimulus, 1) = 0;
            eye.movements.fixations.duration.mean(iStimulus, 1) = 0;
            eye.movements.fixations.pupil.size.x.total(iStimulus, 1) = 0;
            eye.movements.fixations.pupil.size.x.mean(iStimulus, 1) = 0;
            eye.movements.fixations.pupil.size.x.max(iStimulus, 1) = 0;
            for iFixation = 1 : length(eye.fixations.trial)
                if (eye.fixations.trial(iFixation, 1) == eye.events.trial(iTrial, 1))
                    eye.movements.fixations.number(iStimulus, 1) = eye.movements.fixations.number(iStimulus, 1) + 1;
                    eye.movements.fixations.duration.total(iStimulus, 1) = eye.movements.fixations.duration.total(iStimulus, 1) + eye.fixations.duration(iFixation, 1);
                    eye.movements.fixations.pupil.size.x.total(iStimulus, 1) = eye.movements.fixations.pupil.size.x.total(iStimulus, 1) + eye.fixations.pupil.size.x(iFixation, 1);
                    temp.movements.fixations.pupil.size.x.max(iFixation, 1) = eye.fixations.pupil.size.x(iFixation, 1);
                end
            end
            
            if eye.movements.fixations.number(iStimulus, 1)==0
                eye.movements.fixations.duration.mean(iStimulus, 1) = 0;
                eye.movements.fixations.pupil.size.x.mean(iStimulus, 1) = 0;
            else
                eye.movements.fixations.duration.mean(iStimulus, 1) = pupilDataControl((eye.movements.fixations.duration.total(iStimulus, 1)/eye.movements.fixations.number(iStimulus, 1)));
                eye.movements.fixations.pupil.size.x.mean(iStimulus, 1) = pupilDataControl((eye.movements.fixations.pupil.size.x.total(iStimulus, 1)/eye.movements.fixations.number(iStimulus, 1)));
            end
            
            eye.movements.fixations.pupil.size.x.max(iStimulus, 1) = pupilDataControl(max(temp.movements.fixations.pupil.size.x.max));
            
            
            disp([' FIXATION [nr.: ', num2str(eye.movements.fixations.number(iStimulus, 1)), ']']);
            disp(['         duration tot.     = ', num2str(eye.movements.fixations.duration.total(iStimulus, 1))]);
            disp(['         duration mean     = ', num2str(eye.movements.fixations.duration.mean(iStimulus, 1))]);
            disp(['         pupil size X mean = ', num2str(eye.movements.fixations.pupil.size.x.mean(iStimulus, 1))]);
            disp(['         pupil size X max  = ', num2str(eye.movements.fixations.pupil.size.x.max(iStimulus, 1))]);
            
            disp(' ');
        end
    end
    
    disp('........      ........      ........      ........      ........'); disp(' ');
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end
