<!-- markdownlint-disable MD013 -->

# MATLAB Simulink Energy Lab（MATLAB Simulink 电池与储能实验室）

这是一个开源、可重现的 MATLAB/Simulink 教学模型库，聚焦于锂离子电池等效电路、SOC 估计、热模型、功率变换器与并网/离网场景下的 BESS 控制。

- **用途**：课程教学、论文复现、建模入门、实验室演示
- **特点**：
  - 可运行脚本和可重现的仿真流程
  - 明确的模型假设、参数和局限性说明
  - 逐例给出检查命令与期望输出
  - 与 MATLAB Online 一键打开支持集成

## 一分钟上手

```matlab
run('examples/battery-rc-model/check_battery_rc_model.m')
run('examples/battery-rc-model/run_battery_rc_model.m')
```

若已安装 Simulink，可在浏览器中直接打开：

https://matlab.mathworks.com/open/github/v1?repo=mohammadrezwankhan/matlab-simulink-energy-lab

## 适合人群

- 学生：快速掌握“方程 → 可执行脚本 → 结果验证”的建模流程
- 讲师：可用于课程实验与作业模板
- 研究者：在提交高阶模型前快速搭建低阶基线
- 从业者：先用简化模型进行概念验证与敏感性分析

## 模型结构速览

本仓库按问题导向组织，包含：

- 电池 RC 与两 RC 参数识别模型
- SOC EKF（含滞回与噪声敏感性实验）
- 电池热/模块热网络模型
- 平均与开关拓扑变换器模型
- 统一 BESS 控制（并网、离网、故障与恢复）

## 贡献与验证

所有实现在每次改动后都支持可重现检查；请优先使用有界的、提交级别的复现报告（包含环境信息）来扩展兼容性证据。

欢迎通过 Pull Request 提交可验证改进：更好的参数源、实测数据扩展、教学脚本、边界声明与复现增强。

## 学习路径（可选）

- **配套图书草案（12 章）**：`PR #166`（审阅中的草案）
- **可复现示例与模型评审方法**：<https://rezwankhan.tech/insights/reviewable-matlab-models/>

*简体中文说明仅作为额外入口，不替代英文技术主文档。*
