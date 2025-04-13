Throughput_data = zeros(length(sizes), length(methods));
for i = 1:length(sizes)
    for j = 1:length(methods)
        idx = strcmp(T.("M"), sizes{i}) & strcmp(T.("Method"), methods{j});
        if any(idx)
            Throughput_data(i, j) = T.("Throughput (M ops/s)")(idx);
        else
            Throughput_data(i, j) = NaN;
        end
    end
end

figure;
b = bar(Throughput_data, 'grouped');
set(gca, 'xticklabel', sizes);
legend(methods, 'Location', 'northwest');
xlabel('Matrix Size');
ylabel('MAX Throughput (M ops/s)');
title('MAX Throughput Comparison');
grid on;
set(gca, 'FontSize', 12);
ylim([0, max(Throughput_data(:), [], 'omitnan') * 1.2]);

x_vals = b(1).XEndPoints;
fail_x = x_vals(fail_groups);
ymax = max(Throughput_data(:), [], 'omitnan');
fail_y = ones(1, length(fail_groups)) * ymax * 0.02;

for i = 1:length(fail_groups)
    text(fail_x(i), fail_y(i), '×', ...
        'Color', [0 0.3 1], ...
        'FontSize', 18, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
end

annotation
