<!-- markdownlint-disable MD013 -->

# MATLAB Simulink Energy Lab：电池建模与储能控制

[English](README.md) | **简体中文**

[![MATLAB 验证](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/matlab-validation.yml/badge.svg)](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/workflows/matlab-validation.yml)
[![MIT 许可证](https://img.shields.io/badge/license-MIT-2f6f5e.svg)](LICENSE)
[![在 MATLAB Online 中打开](https://img.shields.io/badge/open_in-MATLAB_Online-e86e25.svg)](https://matlab.mathworks.com/open/github/v1?repo=mohammadrezwankhan/matlab-simulink-energy-lab)

**从一个电流脉冲出发，理解电池、估计器、热模型、变换器和储能控制器中的每一个状态。**

本项目提供可运行、可检查的 MATLAB 与 Simulink 降阶参考模型，覆盖锂离子电池等效电路、荷电状态（SOC）估计、电池热管理、降压变换器，以及电池储能系统（BESS）的跟网型／构网型控制。适合电气工程课程、BMS 学习、建模练习和小规模方法研究。

部分示例只需要基础 MATLAB；生成 Simulink 框图的路线另外需要 Simulink。除非某个示例明确说明数据来源，否则参数和输入是合成或示意性的。自动检查通过，不等于实测电芯精度、硬件安全、产品认证或并网规范符合性得到验证。

本 GitHub 仓库是代码、版本、引用元数据和验证记录的权威来源。网站上的[项目介绍](https://rezwankhan.tech/models/matlab-simulink-energy-lab/)用于快速了解范围；运行和引用时请记录实际代码提交版本。

## 先得到一个结果

第一次使用时，不必先运行全部测试。从一阶 RC 电池的脉冲响应开始。

1. 点击上方 **MATLAB Online** 按钮，或克隆仓库并在 MATLAB 中打开仓库根目录。
2. 保存现有变量、图窗和模型，使用一个新的 MATLAB 会话。
3. 在命令窗口运行：

```matlab
run('examples/battery-rc-model/check_battery_rc_model.m')
run('examples/battery-rc-model/run_battery_rc_model.m')
```

检查应打印 `Battery RC check passed`，最终 SOC 约为 `0.767`，端电压范围约为 `3.425 V to 3.877 V`。第二条命令绘制电流、SOC 和端电压。正电流表示放电，负电流表示充电。这些数值是规定输入下的确定性参考结果，不是某种实际电芯的性能指标。

**工作区提醒：**已有检查脚本会清理变量，一些绘图脚本还会关闭图窗。请先保存需要保留的工作。生成模型的构建器会拒绝已加载的同名模型，但仍可能覆盖所选输出目录中的生成文件；请使用独立输出目录。

主验证环境为 MATLAB R2026a。上述首个示例不需要 Simulink 或专业工具箱。MATLAB Online 的可用产品取决于读者的账户和许可；入口按钮本身不提供额外产品授权。

![一阶 RC 电池示例：电流脉冲、荷电状态与端电压](assets/battery-rc-response.png)

*已有仓库结果图，用于解释示例；不是新增实测数据。*

## 配套教材：Battery Modeling and BESS Control in MATLAB

[阅读完整目录](book/README.md)。本书可译为《MATLAB 中的电池建模与 BESS 控制》。当前十二章正文及解答为英文初稿，中文入口和[双语术语表](book/notation.md)帮助读者使用同一套代码；这里不声称全书已完成中文翻译或独立翻译审校。

| 章 | 学习内容 | 对应代码 |
| --- | --- | --- |
| [1](book/chapters/01-one-rc.md) | 从电流脉冲理解端电压 | [一阶 RC 电池](examples/battery-rc-model/README.md) |
| [2](book/chapters/02-two-rc.md) | 快、慢两种极化时间尺度 | [二阶 RC 电池](examples/battery-2rc-model/README.md) |
| [3](book/chapters/03-identification.md) | 参数辨识与留出验证 | [二阶 RC 辨识教程](docs/two-rc-battery-parameter-identification.md) |
| [4](book/chapters/04-soc-ekf.md) | 扩展卡尔曼滤波与 SOC 估计 | [SOC EKF](examples/battery-soc-ekf/README.md) |
| [5](book/chapters/05-hysteresis.md) | 电压历史与滞回感知估计 | [滞回感知 EKF](examples/battery-soc-hysteresis-ekf/README.md) |
| [6](book/chapters/06-electrothermal.md) | 电热耦合与冷却 | [集总电热模型](examples/battery-thermal-model/README.md) |
| [7](book/chapters/07-pouch-gradients.md) | 电芯厚度方向温度梯度 | [软包电芯有限体积模型](examples/pouch-cell-thermal-gradient/README.md) |
| [8](book/chapters/08-module-cooling.md) | 串联冷却液通道与模组温差 | [模组冷却网络](examples/battery-module-cooling-network/README.md) |
| [9](book/chapters/09-averaged-control.md) | 平均模型中的电压调节 | [降压变换器控制比较](examples/converter-closed-loop-model/README.md) |
| [10](book/chapters/10-switching-control.md) | 采样控制与显式 PWM | [开关闭环变换器](examples/converter-switching-closed-loop-model/README.md) |
| [11](book/chapters/11-dc-reserve.md) | 直流母线能量与 SOC 预留 | [直流侧储能裕度](examples/bess-dc-reserve-model/README.md) |
| [12](book/chapters/12-bess-supervisor.md) | 跟网、构网、孤岛与重新并网 | [统一 BESS 控制器](examples/bess-unified-control/README.md) |

每章包含推导、离散化、代码入口、结果解读，以及四道附完整解答的练习。先写预测，再运行示例；先理解假设，再增加模型复杂度。教材不将现有维护文档直接改名为章节，也不把通过回归检查说成实际课堂验证。

## 按学习目标选择路线

| 目标 | 推荐入口 |
| --- | --- |
| 第一次画出电池电压与 SOC | [首个结果](#先得到一个结果) |
| 用一次课研究电池脉冲响应 | [电池脉冲实验](docs/battery-pulse-response-lab.md)，时长是建议而非实测保证 |
| 按工程问题选择最小模型 | [决策导向模型选择](docs/model-selection-by-decision.md) |
| 查看全部运行命令 | [示例索引](examples/README.md) |
| 理解降阶模型与高保真模型的区别 | [范围比较](docs/scope-comparison.md) |
| 检查结果及其代码版本 | [验证清单说明](docs/validation-manifest.md) |
| 找到术语、单位和符号约定 | [教材符号表](book/notation.md) |

## 环境与验证

- 教材第 1–11 章的主要路线使用基础 MATLAB。
- 第 12 章的参考计算使用 MATLAB；完整专项检查与生成的框图需要 Simulink。
- 六个生成式框图示例需要 Simulink，不应把整个仓库描述为“完全不需要 Simulink”。
- R2026a 是主要验证版本。英文 README 另有绑定到特定提交、操作系统和更新版本的 R2025b 兼容性记录；它不是对所有旧版本的支持承诺。

只使用 MATLAB 时，可从仓库根目录运行基础配置：

```matlab
addpath('examples');
run_base_matlab_checks
```

该配置包含 20 个基础 MATLAB 检查，不包含原生框图一致性或完整统一 BESS 专项检查。安装了 Simulink 后，可运行完整入口：

```matlab
addpath('examples');
run_all_checks
```

模型源码 `f0f4a93587665a9ad36a75c95bd99ed965df7676` 的[验证运行 34511290849](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/actions/runs/34511290849)记录了 25 个一般检查入口、77 个 BESS 专项测试和 8 个 BESS 场景。完整入口调用 26 个检查入口。这些统计口径不同，不能相加后声称是独立实验总数。该运行早于教材，不等于新练习已全部经过同一次 CI 测试。

请通过[教材源码映射](book/source-map.md)区分模型验证、教材检查和旧版本历史记录。`0.440 mV` 合成留出误差等既有数值必须保留其原始条件和来源，不能翻译成实测电芯精度。

## 主要模型边界

**电池与估计器。** OCV–SOC 表、等效电路参数和协方差均为可替换的教学设定。二阶 RC 拟合假设 OCV 已由其他方式获得。电流偏置实验研究的是预设、未建模的输入偏置，不是估计或消除传感器偏置。滞回模型不等于某种化学体系的完整机理模型。

**热模型。** 集总模型没有电芯内部空间分辨率。模组模型使用准稳态冷却液通道，没有压力损失、泵功耗或输运延迟。软包模型只解析厚度方向，未表示极耳、面内梯度和详细分层。这些模型不用于热失控、安全认证或保护设计。

**变换器。** 平均模型不解析 PWM 纹波。开关闭环模型具有明确采样、占空比量化和损耗近似；固定结温扫描并没有求解动态结温。死区、寄生参数、EMI、保护和完整器件非线性仍不在范围内。Simulink 与参考代码一致，不等于获得独立物理验证。

**BESS。** 统一控制器是降阶控制参考，包含项目假设，不是论文每个数值工况的严格复现，也不是合格的并网或保护控制器。直流侧 SOC 预留模型与交流侧统一控制器是两个独立示例；仓库没有声称它们已组成电池到电网的闭环系统。

详细约束见[英文范围说明](README.md#scope-and-limitations)与各示例 README。使用实测数据或硬件前，必须重新检查参数、单位、采样、限幅、边界条件和证据适用性。

## 修改、反馈与引用

在独立草稿脚本中修改返回的参数结构，保留仓库原始基线。提交作业或报告时，记录代码提交、MATLAB 版本、命令、输入、实际输出及限制。若发现差异，请提交[可复现结果报告](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/issues/new?template=reproduction_report.yml)，而不是直接修改期望值以获得通过。

欢迎提出有明确边界的修正、可追溯测量数据、参数来源和教学改进。较大的工作请先说明工程问题与验收方法；流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。如果希望以后返回某个示例，可以为仓库加星作为书签；加星本身不能说明实际使用了哪个模型。

研究、课程或教学引用请使用 [CITATION.cff](CITATION.cff)，并注明实际代码与教材版本。历史版本见[发布页](https://github.com/mohammadrezwankhan/matlab-simulink-energy-lab/releases)。本项目及随附文档使用 [MIT 许可证](LICENSE)，再分发时请保留许可证与版权声明。
