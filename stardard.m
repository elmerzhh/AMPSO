clear, clc

nSize = length(r_best);
record = zeros(1, 4*nSize);
curr = 1;
for i=1:nSize
    record(curr)=r_best(i);
    curr=curr+1;
    record(curr)=r_worst(i);
    curr=curr+1;
    record(curr)=r_mean(i);
    curr=curr+1;
    record(curr)=r_median(i);
    curr=curr+1;
end

MPSO_list = [1:9, 11, 14, 15];
record_2 = zeros(2*length(MPSO_list), 1);
curr = 1;
for i=1:length(MPSO_list)
    t = MPSO_list(i);
    record_2(curr,1) = r_mean(t);
    curr = curr+1;
    record_2(curr,1) = r_std(t);
    curr = curr+1;
end