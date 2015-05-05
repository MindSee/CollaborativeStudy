function [] = pupilCollaborativeExcel2Mat()

try
    tic
    [eyes, inputPath, inputName] = pupilCollaborativeEyeAnalize(2);
    toc
    tic
    pupilCollaborativeEyeAnalize(3, eyes, inputPath, inputName);
    toc
    
catch
end
