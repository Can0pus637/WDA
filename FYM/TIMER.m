WNS_data = zeros(length(sizes), length(methods));  % 创建 WNS 数据矩阵
for i = 1:length(sizes)
    for j = 1:length(methods)
        idx = strcmp(T.("M"), sizes{i}) & strcmp(T.("Method"), methods{j});  % 找到对应配置
        if any(idx)
            WNS_data(i, j) = T.("WNS (ns)")(idx);  % 提取对应的 WNS 值
        else
            WNS_data(i, j) = NaN;  % 若无数据则填 NaN
        end
    end
end

figure;
b = bar(WNS_data, 'grouped');  % 画分组柱状图
set(gca, 'xticklabel', sizes);  % 设置横轴标签
legend(methods, 'Location', 'northwest');  % 添加图例
xlabel('Matrix Size');
ylabel('WNS (ns)');  % 设置纵轴单位为 WNS
title('WNS Comparison');  % 设置图标题
grid on;
set(gca, 'FontSize', 12);
ylim([min(WNS_data(:), [], 'omitnan') * 1.2, max(WNS_data(:), [], 'omitnan') * 1.2]);  % 自动设置纵轴范围

x_vals = b(1).XEndPoints;  % 获取柱子的横坐标
fail_x = x_vals(fail_groups);  % 失败组的位置
ymax = max(WNS_data(:), [], 'omitnan');
fail_y = ones(1, length(fail_groups)) * ymax * 0.02;  % 失败组的 × 显示高度

for i = 1:length(fail_groups)
    text(fail_x(i), fail_y(i), '×', ...  % 显示 × 符号
        'Color', [0 0.3 1], ...
        'FontSize', 18, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
end
