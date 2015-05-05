function [Mean] = meanNotNaN(X, DIM)
% Average or mean value of the non-NaN values of the matrix X along the
% dimension DIM. If DIM = 1 calculates the average of the columns of X,
% while if DIM = 2 calculates the average of the rows.
%
%   Syntax:
%           [Mean] = meanNotNaN(X, DIM)
%
%   Parameters:
%           X           Vector or matrix.
%           DIM         Dimension
%
%   Return values:
%           Mean        Vector line with the average for the column if
%                       DIM = 1 (default), otherwise the column vector with
%                       the average per line if DIM = 2.
%
%	Author: Filippo M.  07/07/2014


try
    % Nargin
    if nargin < 2
        DIM = 1;
    elseif DIM == 2
        X = X';
    end
    
    % Parameters
    Mean = [];
    
    % Mean
    nColumns = size(X, 2);
    
    for iColumns = 1 : nColumns
        Mean(iColumns) = mean(X(find(~isnan(X(:,iColumns))), iColumns));
    end
    
    if DIM == 2
        Mean = Mean';
    end
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end
