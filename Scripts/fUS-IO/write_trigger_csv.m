function write_trigger_csv(filepath_csv,time_rising,time_falling,thresh,step)

if nargin <4
    thresh = NaN;
end
if nargin <5
    step = 1;
end

nTrigs = length(time_rising);

fid_csv = fopen(filepath_csv,'w');
fprintf(fid_csv,'%s',sprintf('Threshold=%.2f,BinSize=%.d,NumTrigs=%d\n',thresh,step,nTrigs));
fprintf(fid_csv,'%s',sprintf('Rising(s),Falling(s)\n'));
for k = 1:length(time_rising)
    fprintf(fid_csv,'%s',sprintf('%.3f,%.3f\n',time_rising(k),time_falling(k)));
end
fclose(fid_csv);

end