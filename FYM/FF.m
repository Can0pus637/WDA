T = readtable('Final_Rounded_FPGA_Table.csv', 'VariableNamingRule', 'preserve');

methods = unique(T.("Method"), 'stable');
sizes = unique(T.("M"), 'stable');
FF_data = zeros(length(sizes), length(methods));

for i = 1:length(sizes)
    for j = 1:length(methods)
        idx = strcmp(T.("M"), sizes{i}) & strcmp(T.("Method"), methods{j});
        if any(idx)
            FF_data(i, j) = T.("FF")(idx);
        else
            FF_data(i, j) = NaN;
        end
    end
end

figure;
b = bar(FF_data, 'grouped');
set(gca, 'xticklabel', sizes);
legend(methods, 'Location', 'northwest');
xlabel('Matrix Size');
ylabel('FF Usage');
title('FF Usage Comparison');
grid on;
set(gca, 'FontSize', 12);
ylim([0, max(FF_data(:), [], 'omitnan') * 1.2]);

x_vals = b(1).XEndPoints;
fail_groups = [3, 4];
% 设置 fail_y 为 y 轴范围的 2%
ymax = max(FF_data(:), [], 'omitnan');  % 如果是 FF 图，换成 LUT 就是 LUT_data
fail_y = ones(1, length(fail_groups)) * ymax * 0.01;

fail_x = x_vals(fail_groups);

for i = 1:length(fail_groups)
    text(fail_x(i), fail_y(i), '×', ...
        'Color', [0 0.3 1], ...
        'FontSize', 18, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
end

annotation('textbox', [0.52, 0.02, 0.5, 0.05], ...
    'String', '"×" indicates synthesis failure', ...
    'FontSize', 10, 'FontAngle', 'italic', ...
    'Color', [0 0 0.6], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
