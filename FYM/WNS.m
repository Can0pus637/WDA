WNS_data = zeros(length(sizes), length(methods));  % 改名
for i = 1:length(sizes)
    for j = 1:length(methods)
        idx = strcmp(T.("M"), sizes{i}) & strcmp(T.("Method"), methods{j});
        if any(idx)
            WNS_data(i, j) = T.("WNS (ns)")(idx);  % 改字段
        else
            WNS_data(i, j) = NaN;
        end
    end
end

figure;
b = bar(WNS_data, 'grouped');  % 用新的数据画图
set(gca, 'xticklabel', sizes);
legend(methods, 'Location', 'northwest');
xlabel('Matrix Size');
ylabel('WNS (ns)');  % 改 Y 轴标签
title('WNS Comparison');  % 改图标题
grid on;
set(gca, 'FontSize', 12);
ylim([min(WNS_data(:), [], 'omitnan') * 1.2, max(WNS_data(:), [], 'omitnan') * 1.2]);

% 如果你有 fail_groups 也可以继续用 × 标注，不改逻辑
x_vals = b(1).XEndPoints;
fail_x = x_vals(fail_groups);
ymax = max(WNS_data(:), [], 'omitnan');
fail_y = ones(1, length(fail_groups)) * ymax * 0.02;

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