# 2.9 Prompt 自动调优：从手工提示词到自我进化的 Agent

> 🧬 *"一个好的 Prompt 不是一次写成的，而是在任务、反馈、失败和反思中不断进化出来的。未来的 Agent 不只是会回答问题，还会观察自己的失败，修改自己的工作方式，并把成功经验沉淀下来。"*

在前面的章节中，我们学习了 LLM 的工作原理、Prompt Engineering、常见提示策略、模型 API 调用、模型参数，以及 SFT / RL 训练数据准备。

这些方法能帮助我们写出更好的 Prompt，但在真实的 Agent 系统里，问题会变得更复杂：

- 一个 Agent 往往不是一个 Prompt，而是一组 Prompt。
- 规划、检索、工具选择、代码执行、验证、总结、记忆、安全策略，可能都有各自的 Prompt。
- 修改其中一个 Prompt，可能会影响其他模块。
- 手工调 Prompt 依赖少数专家经验，效率低、难复现、难规模化。
- 如果用强化学习改模型权重，又需要大量 rollout、训练基础设施和成本。

于是，一个新的方向出现了：**Prompt 自动调优（Automatic Prompt Optimization）**。

它想解决的问题很直接：

> 能不能让系统自己运行任务、发现失败、阅读反馈、反思原因、重写 Prompt，并保留更好的版本？

本节不是只介绍某一篇论文，而是对这个方向做一个整体综述。我们会从最容易理解的例子开始，逐步介绍：

- 为什么需要 Prompt 自动调优。
- Prompt 自动调优和强化学习有什么不同。
- APE、OPRO、ProTeGi、TextGrad、DSPy / MIPROv2、EvoPrompt、PromptBreeder、Trace 等方法分别解决了什么问题。
- 为什么 GEPA 是这个方向的一个集成型代表。
- Prompt 进化和 Skill 进化有什么关系。
- 如果要在真实 Agent 项目中落地，应该怎么做。

---

## 先用一个生活类比理解 Prompt 自动调优

可以把 Prompt 想象成老师给学生写的“做题说明”。

比如老师让学生做阅读理解，最初只写了一句话：

```text
请阅读文章并回答问题。
```

学生经常答错。老师看了几次错题后发现：

- 学生经常不引用原文。
- 学生容易把自己的猜测当答案。
- 如果问题问的是时间，学生会忽略年份。

于是老师把说明改成：

```text
请先在文章中找到能直接支持答案的句子。
如果问题包含时间或年份，必须优先寻找包含相同时间或年份的句子。
最后回答时，只能使用原文支持的信息，不要猜测。
```

这就是一次手工 Prompt 优化。

Prompt 自动调优要做的事情，就是让系统自动完成类似过程：

![Prompt 自动调优闭环](../svg/chapter_llm_09_apo_loop.svg)

如果这个过程能自动循环，Prompt 就不再是写完就固定的文本，而会变成一种可以持续改进的“文本参数”。

---

## 为什么手工 Prompt 调优不够用了？

简单任务中，手工写 Prompt 通常已经够用。例如：

```text
请把下面这段话翻译成英文。
```

但真实 Agent 系统往往是多模块系统。以一个文档问答 Agent 为例：

| 模块 | Prompt 负责的事情 | 常见失败模式 |
|------|------------------|--------------|
| **查询分析器** | 理解用户到底想问什么 | 意图判断错误，忽略隐藏条件 |
| **检索器** | 生成搜索词，找到相关文档 | 搜到无关文档，漏掉关键文档 |
| **阅读器** | 从文档里抽取证据 | 漏看关键句，引用弱证据 |
| **推理器** | 把多个证据组合成答案 | 做出没有证据支撑的推理 |
| **工具选择器** | 决定是否调用搜索、计算器、代码执行器等工具 | 工具选错，或者该用工具时不用 |
| **验证器** | 检查答案是否可靠 | 没发现幻觉或格式错误 |
| **格式化器** | 输出 JSON、报告、引用格式 | 破坏 schema，混入多余解释 |
| **安全模块** | 拦截不安全请求 | 规则过松或过严 |

如果最终答案错了，我们应该改哪个 Prompt？

- 是检索 Prompt 太宽泛？
- 是阅读 Prompt 没要求引用证据？
- 是推理 Prompt 允许模型猜测？
- 是验证 Prompt 没有发现错误？
- 还是格式化 Prompt 把结构化输出弄坏了？

人类专家可以看执行过程来判断，但这很慢。系统越复杂，Prompt 越多，手工维护成本越高。

因此，Prompt 自动调优的目标不是替代所有人类判断，而是把“看失败、找原因、改 Prompt、再验证”这个流程工程化、自动化、可复现。

---

## Prompt 自动调优到底在优化什么？

在神经网络训练中，我们优化的是模型权重。权重是数字，所以可以用梯度下降更新。

在 Prompt 自动调优中，我们优化的是 Prompt 文本。Prompt 是自然语言，不能像数字一样直接求导，但它仍然可以通过反馈变得更好。

可以把两者对比如下：

| 项目 | 模型训练 / 强化学习 | Prompt 自动调优 |
|------|-------------------|----------------|
| 优化对象 | 模型权重或策略参数 | Prompt、instruction、few-shot 示例 |
| 是否修改模型 | 通常会修改 | 通常不修改 |
| 反馈形式 | 标量奖励、偏好数据、loss | 分数、文本反馈、执行轨迹 |
| 成本 | 通常较高 | 通常可以在应用层完成 |
| 可解释性 | 权重变化难解释 | Prompt diff 人类可读 |
| 适合场景 | 深层能力训练、新策略学习 | 应用层行为、格式、工具使用、工作流约束 |

一个最小的 Prompt 自动调优闭环如下：

```text
初始 Prompt
   ↓
在训练任务上运行系统
   ↓
收集输出、分数、错误案例和执行轨迹
   ↓
让 LLM 或评估器写出自然语言反馈
   ↓
根据反馈重写 Prompt
   ↓
评估新 Prompt
   ↓
保留表现更好的版本
   ↓
重复
```

这里最关键的思想是：

> **不要只把反馈压缩成一个数字，要尽量保留语言解释。**

例如，下面两个反馈都表示答案错了，但信息量完全不同：

```text
分数：0
```

和：

```text
答案错误。模型引用了文档 A，但真正支持答案的证据在文档 C。
问题问的是 2021 年的收购事件，模型却使用了 2019 年投资事件。
Prompt 应要求模型优先选择显式匹配年份的证据句。
```

第二种反馈更像老师批改作业。它不仅告诉你错了，还告诉你为什么错、该怎么改。

---

## 这个方向的发展脉络

Prompt 自动调优不是突然出现的。它大致经历了下面几步发展：

![Prompt 自动调优的发展脉络](../svg/chapter_llm_09_research_map.svg)

下面我们按方法类型来介绍。

### 从综述视角看：这个方向到底在研究什么？

如果不只看某一篇论文，而是看整个方向，Prompt 自动调优大致可以拆成四个问题：

| 研究问题 | 想解决什么 | 代表方法 |
|----------|------------|----------|
| **谁来写 Prompt？** | 从人工写 Prompt，变成让 LLM 自动生成候选 Prompt | `APE` |
| **怎么判断 Prompt 好不好？** | 从只看最终分数，变成结合验证集、文字反馈和执行轨迹 | `OPRO`、`ProTeGi`、`TextGrad` |
| **怎么搜索更好的 Prompt？** | 从单次改写，变成 beam search、贝叶斯优化、遗传进化、Pareto 选择 | `MIPROv2`、`EvoPrompt`、`PromptBreeder`、`GEPA` |
| **怎么让 Agent 长期变强？** | 从只改 Prompt，进一步沉淀经验、代码和技能库 | `Reflexion`、`Voyager`、`ExpeL`、`SkillRL`、`SkillX` |

所以，`GEPA` 不是孤立出现的。它更像是把前面几条路线组合起来：

```text
文本反馈思想：来自 ProTeGi / TextGrad
进化搜索思想：来自 EvoPrompt / PromptBreeder
多模块系统思想：来自 DSPy / Trace
长期经验沉淀思想：和 Reflexion / ExpeL / Voyager 等 Skill 方向相邻
```

也就是说，本节的重点不是“GEPA 这一种方法怎么用”，而是理解一个更大的趋势：

> **Agent 系统正在从人工调参，走向基于反馈、轨迹、反思和技能库的自动改进。**

---

## 第一类：自动生成 Prompt

### APE：让 LLM 自动写 Prompt

**APE** 的全名是 *Large Language Models Are Human-Level Prompt Engineers*，发表于 ICLR 2023。

它的想法很简单：既然 LLM 很会写文字，能不能让 LLM 自己给任务写 Prompt？

流程大致是：

```text
给 LLM 一些输入输出示例
   ↓
让 LLM 猜测这些示例背后的任务指令
   ↓
生成很多候选 Prompt
   ↓
在验证集上测试
   ↓
选择得分最高的 Prompt
```

例如，给模型几个例子：

```text
输入：I love this movie.
输出：positive

输入：This is terrible.
输出：negative
```

模型可能生成候选 Prompt：

```text
判断下面句子的情感是 positive 还是 negative。
```

APE 的意义在于：它证明了 **LLM 不仅能执行 Prompt，也能生成 Prompt**。

但 APE 也有明显局限：它主要是单阶段优化，通常只看最终效果，不太分析系统中间为什么失败。

---

## 第二类：把 LLM 当优化器

### OPRO：把历史候选和分数写进 Prompt

**OPRO** 的全名是 *Large Language Models as Optimizers*，发表于 ICLR 2024。

它的核心想法是：把 LLM 当成一个优化器。

做法是把历史尝试写进一个 meta-prompt：

```text
候选 Prompt A：得分 62
候选 Prompt B：得分 70
候选 Prompt C：得分 68

请根据这些历史结果，提出一个可能得分更高的新 Prompt。
```

LLM 会观察哪些 Prompt 得分更高，然后继续生成新候选。

OPRO 的优点是简单、通用，不需要训练模型。它让我们看到：**LLM 可以根据“候选 + 分数”进行黑盒优化**。

但它的弱点也很清楚：如果只看到分数，LLM 不知道错误发生在哪里。它知道 B 比 A 好，但不知道 A 为什么错。

---

## 第三类：文本反馈驱动的 Prompt 优化

### ProTeGi：文字版“梯度下降”

**ProTeGi** 的全名是 *Automatic Prompt Optimization with “Gradient Descent” and Beam Search*，发表于 EMNLP 2023。

它是 GEPA 最重要的思想来源之一。

我们知道，神经网络可以用梯度下降优化，因为参数是连续数字。但 Prompt 是一段自然语言，没法求数值梯度。

ProTeGi 提出一个很形象的想法：

> 能不能用自然语言批评来充当“文本梯度”？

它的流程如下：

```text
拿当前 Prompt 跑一批训练样本
   ↓
找出答错的样本
   ↓
让 LLM 批评当前 Prompt 哪里没说清楚
   ↓
这段批评就是“文本梯度”
   ↓
让 LLM 根据批评反方向改写 Prompt
   ↓
生成多个候选 Prompt
   ↓
用 beam search 和 bandit 策略保留更有希望的候选
   ↓
继续迭代
```

举个例子，当前 Prompt 是：

```text
请回答用户的问题。
```

错误案例显示模型经常编造答案。LLM 写出的“文本梯度”可能是：

```text
当前 Prompt 没有要求模型区分已知信息和未知信息。
它也没有要求模型在证据不足时拒绝回答。
```

于是新 Prompt 可能变成：

```text
请只根据给定资料回答问题。
如果资料中没有足够证据，请明确说明无法确定，不要编造。
```

ProTeGi 的价值在于，它把“批评”变成了可操作的优化信号。

它和 GEPA 的关系非常近：

| 对比点 | ProTeGi | GEPA |
|--------|---------|------|
| 优化对象 | 主要是单个 Prompt | 可以是多模块 AI 系统中的多个 Prompt |
| 反馈来源 | 错误样本和文本批评 | 执行轨迹、分数、评估器文本反馈 |
| 候选选择 | Beam search，偏向高分候选 | Pareto 前沿，保留互补候选 |
| 关注重点 | 文本梯度 | 轨迹反思 + 进化搜索 |

可以把 GEPA 理解为：在 ProTeGi 的“文本梯度”思想上，进一步加入了多模块轨迹、进化搜索和 Pareto 选择。

### TextGrad：像自动微分一样传播文字反馈

**TextGrad** 的全名是 *TextGrad: Automatic Differentiation via Text*，发表于 2024。

它的想法更抽象：既然 PyTorch 可以把数值梯度沿计算图反向传播，那么能不能把文字反馈也组织成类似的“反向传播”？

在 TextGrad 中，优化对象不一定只是 Prompt，也可以是：

- 一个中间答案。
- 一段解释。
- 一个工具调用计划。
- 一个多步骤推理链。
- 一个系统中的多个文本变量。

它把每个文本变量都看成可优化对象，然后让评估反馈沿着系统结构反向传递。

TextGrad 和 GEPA 的共同点是：都认为自然语言可以承载优化信号。

区别是：

- TextGrad 更像一个通用框架，强调“文本自动微分”。
- GEPA 更聚焦 Prompt 优化，强调“轨迹反思 + 进化选择”。

---

## 第四类：进化算法做 Prompt 搜索

### EvoPrompt：把遗传算法搬到 Prompt 上

**EvoPrompt** 的全名是 *Connecting Large Language Models with Evolutionary Algorithms Yields Powerful Prompt Optimizers*，发表于 ICLR 2024。

它把 Prompt 优化看成一种进化过程：

```text
一批 Prompt 候选
   ↓
评估每个候选的适应度
   ↓
选择表现好的候选
   ↓
交叉、变异，生成新候选
   ↓
继续筛选
```

这和生物进化很像：

- Prompt 候选就像不同个体。
- 分数就是适应度。
- 改写 Prompt 就像基因变异。
- 合并两个 Prompt 的优点就像基因交叉。

EvoPrompt 的贡献是把经典进化算法用于 Prompt 搜索。

它和 GEPA 的共同点是都使用进化思想。不同点是，GEPA 更重视执行轨迹和自然语言反思，不只是随机搜索或分数筛选。

### PromptBreeder：连“变异规则”也一起进化

**PromptBreeder** 的全名是 *Promptbreeder: Self-Referential Self-Improvement via Prompt Evolution*，发表于 ICML 2024。

它更进一步：不只进化任务 Prompt，还进化“如何修改 Prompt 的 Prompt”。

也就是说，系统里有两类 Prompt：

```text
任务 Prompt：告诉模型怎么完成任务。
变异 Prompt：告诉模型怎么改任务 Prompt。
```

PromptBreeder 让这两类 Prompt 一起进化，因此带有一种“自指式改进”的味道。

这说明 Prompt 优化已经不只是“搜索一句更好的指令”，而是在探索系统如何改进自己的改进方法。

---

## 第五类：多模块 LLM 程序优化

### DSPy：从手写 Prompt 到编译 LLM 程序

**DSPy** 是 Stanford 开源的 LLM 编程框架。它背后的思想是：

> 不要把 LLM 应用写成一堆手工 Prompt，而是写成模块化程序，再让框架自动优化 Prompt 和示例。

比如一个 RAG 系统可能有三个模块：

```text
问题改写器 → 检索器 → 答案生成器
```

在传统写法中，开发者要为每个模块手写 Prompt。

在 DSPy 中，开发者更关注输入输出签名，例如：

```text
输入：question
输出：answer, evidence
```

框架会根据模块结构、训练数据和评估指标，自动寻找更好的 instruction 和 few-shot examples。

### MIPROv2：优化 instruction 和 few-shot 的组合

**MIPROv2** 是 DSPy 中常用的优化器，对应论文 *Optimizing Instructions and Demonstrations for Multi-Stage Language Model Programs*，发表于 EMNLP 2024。

它要优化的是：

```text
instruction × few-shot examples
```

也就是：

- 每个模块该写什么指令。
- 每个模块该配哪些示例。

大致流程是：

```text
用初始系统跑训练集
   ↓
保留成功样例，作为 few-shot 候选
   ↓
让 LLM 根据数据摘要和程序结构生成候选 instruction
   ↓
组合 instruction 和 few-shot
   ↓
小批量评估候选
   ↓
用贝叶斯优化搜索更好的组合
   ↓
在验证集上选择最终版本
```

MIPROv2 的优势是适合模块化 LM pipeline，并且能同时优化指令和示例。

它和 GEPA 的区别是：

| 对比点 | MIPROv2 | GEPA |
|--------|---------|------|
| 优化空间 | instruction × few-shot examples | Prompt 文本变异和组合 |
| 搜索方式 | 贝叶斯优化 | 反思式进化搜索 |
| 反馈利用 | 更多依赖最终分数 | 利用完整 trace 和文本反馈 |
| 强项 | 模块化程序编译优化 | 失败诊断和针对性 Prompt 改写 |

两者并不矛盾。GEPA 后来也可以被集成到 DSPy 生态中，作为一种更重视轨迹反思的优化器使用。

---

## 第六类：轨迹驱动的通用优化

### Trace：把执行轨迹当成优化信号

**Trace** 的全名是 *Trace is the Next AutoDiff: Generative Optimization with Rich Feedback, Execution Traces, and LLMs*，发表于 2024。

它提出一个更宽的观点：

> 对复杂 AI 系统来说，执行轨迹就像新的“计算图”。如果我们能记录系统每一步做了什么，就能利用这些轨迹优化系统。

这里的轨迹不只是最终答案，而是完整过程：

- 用户输入。
- 每个模块的 Prompt。
- 每个模块的输出。
- 工具调用。
- 工具返回结果。
- 中间推理。
- 错误信息。
- 最终输出。
- 评估反馈。

Trace 的优化对象可以很广：

- Prompt。
- 代码。
- 超参数。
- 工具调用策略。
- 工作流结构。

GEPA 和 Trace 都重视 trace，但 GEPA 更聚焦于 Prompt 优化这个子问题。

---

## GEPA：这个方向的集成型代表

现在我们可以更好地理解 GEPA。

**GEPA** 的全名是 *Genetic-Pareto Prompt Evolution through Reflection*，论文标题是 *GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning*，发表于 ICLR 2026。

一句话理解 GEPA：

> GEPA 是一种 Prompt 优化器。它让系统运行任务，收集完整执行轨迹，再让 LLM 用自然语言反思失败原因，生成 Prompt 变异，并用 Pareto 前沿保留不同场景下表现强的候选 Prompt。

GEPA 这个名字里有三个关键词：

| 关键词 | 含义 | 为什么重要 |
|--------|------|------------|
| **Genetic** | 遗传式搜索，维护一组候选 Prompt，不断变异和筛选 | 避免只盯着一个 Prompt 版本，减少局部最优 |
| **Pareto** | 帕累托选择，不只保留平均分最高的候选 | 保留在不同样本子集上各有优势的 Prompt |
| **Prompt Evolution** | Prompt 会随着反馈持续进化 | Prompt 不再是一次性手工产物 |

---

## GEPA 要解决什么问题？

GEPA 针对的是这样的场景：

- 有一个复杂 AI 系统，里面包含一个或多个 LLM Prompt。
- 不想或不能修改模型权重。
- 每次完整运行系统都很贵，因为可能涉及模型调用、检索、工具执行、代码运行等。
- 只看最终分数不够，需要知道中间哪里失败。
- 希望用尽量少的 rollout 得到更好的效果。

以前常见做法有两类：

| 做法 | 问题 |
|------|------|
| 人工调 Prompt | 依赖专家经验，效率低，难复现 |
| 强化学习改模型权重 | rollout 多，成本高，训练和部署复杂 |

GEPA 的选择是第三条路：

> 不改模型权重，而是在应用层自动改 Prompt；不靠大量盲目试错，而是利用语言反思提高样本效率。

---

## GEPA 的输入和输出

GEPA 的输入通常包括五类：

| 输入 | 说明 | 例子 |
|------|------|------|
| **AI 系统** | 待优化的系统，可能包含多个 LLM 模块 | RAG、编程 Agent、客服工作流、数学求解器 |
| **训练集** | 用于优化的任务集合 | 问题、文档、代码题、用户请求 |
| **评估指标** | 定量目标 | Accuracy、F1、单测通过率、任务成功率 |
| **反馈函数** | 能返回文字批评的评估器 | “答案引用了错误文档，应检查年份匹配。” |
| **Rollout 预算** | 最多允许完整运行多少次系统 | 100、500、2000 次 |

GEPA 的输出不是一个新模型，而是一组优化后的 Prompt：

```text
优化前：
  planner_prompt_v0
  retriever_prompt_v0
  verifier_prompt_v0

优化后：
  planner_prompt_v7
  retriever_prompt_v4
  verifier_prompt_v9
```

模型本身没有变，变的是系统中的文本参数。

---

## GEPA 的核心流程

一个简化版 GEPA 流程如下：

![GEPA 核心流程](../svg/chapter_llm_09_gepa_flow.svg)

下面拆解其中最重要的组件。

### 1. 记录执行轨迹

**轨迹（trace）**是一轮运行中发生了什么的完整记录。在 Agent 系统中，它可能包括：

```text
用户输入
模块 Prompt
模块输出
工具调用
工具返回结果
检索文档
中间推理
验证结果
最终答案
评估分数
文字反馈
```

例如，一个 RAG 系统的失败轨迹可能是：

```text
问题：2021 年哪家公司收购了 X？

检索查询：
  "X acquisition"

检索到的文档：
  文档 1：提到 2019 年的一次投资
  文档 2：提到 2021 年 Company Y 对 X 的收购

阅读器输出：
  "Company Z 收购了 X。"

评估反馈：
  "错误。支持文档中写的是 Company Y，而不是 Company Z。
   阅读器忽略了包含准确年份 2021 的句子。"
```

如果只看最终分数，我们只知道这题错了。如果看轨迹，我们能知道错在哪里。

### 2. 用自然语言反思失败

优化器会让 LLM 读取轨迹，并写出类似下面的诊断：

```text
当前 reader prompt 没有强制模型把实体和年份对齐。
模型倾向于使用第一个看起来相关的公司名，而不是优先选择包含目标年份的证据句。
应加入规则：如果问题包含年份，必须优先使用显式提到同一年份的句子作为证据。
```

这段诊断就是高质量的学习信号。

它比一个 `0` 分更有用，因为它能指导 Prompt 应该怎么改。

### 3. 生成 Prompt 变异

基于反思，优化器会重写某个 Prompt。

原 Prompt 可能是：

```text
从检索到的文档中抽取答案。
```

变异后的 Prompt 可能是：

```text
只能从直接支持问题目标关系的句子中抽取答案。
如果问题包含日期或年份，必须优先选择显式提到相同日期或年份的句子。
回答前先确认实体、关系和时间是否都与问题匹配。
如果没有足够证据，请回答无法确定。
```

这不是随机改写，而是由失败案例驱动的定向修改。

### 4. 评估候选 Prompt

每个新 Prompt 都需要评估。否则它可能只是“听起来更好”，实际表现并不好。

评估时通常要记录：

```text
每个样本上的分数
哪些错误被修复了
哪些新错误出现了
成本和延迟是否增加
评估器返回的文本反馈
```

### 5. 更新 Pareto 前沿

这是 GEPA 很重要的地方。

普通优化器可能只保留平均分最高的 Prompt。但真实任务往往很复杂，某个 Prompt 可能在数学题上强，另一个 Prompt 可能在多跳问答上强。

例如：

| Prompt | 多跳问答 | 数学 | 指令遵循 | 平均分 |
|--------|----------|------|----------|--------|
| `P1` | 90 | 40 | 70 | 66.7 |
| `P2` | 70 | 85 | 55 | 70.0 |
| `P3` | 60 | 60 | 92 | 70.7 |

如果只看平均分，会保留 `P3`。但 `P1` 在多跳问答上很强，`P2` 在数学上很强，直接丢掉它们可能很可惜。

Pareto 前沿的思想是：

> 如果一个候选没有被另一个候选在所有方面全面超过，就值得暂时保留。

这样可以保持多样性，为后续变异和合并提供更多材料。

---

## GEPA 的实验结果说明了什么？

根据 GEPA 论文中的实验，它测试了多类任务：

| 任务 | 说明 |
|------|------|
| **HotpotQA** | 多跳问答，需要组合多个证据 |
| **IFBench** | 指令遵循能力测试 |
| **HoVer** | 事实验证 |
| **PUPA** | 隐私保护任务委托 |
| **AIME-2025** | 数学竞赛题 |
| **LiveBench-Math** | 数学推理任务 |

使用的模型包括：

- Qwen3-8B。
- GPT-4.1 Mini。

对比方法包括：

- GRPO。
- MIPROv2。
- TextGrad。
- Trace。

关键结果可以概括为：

| 模型 | Baseline | 对比方法表现 | GEPA 表现 |
|------|----------|--------------|-----------|
| Qwen3-8B | 45.23 | GRPO 48.91，MIPROv2 47.84 | **54.85** |
| GPT-4.1 Mini | 53.03 | MIPROv2 58.67，TextGrad 59.14 | **65.22** |
| GPT-4.1 Mini + Merge | 53.03 | - | **66.36** |

论文报告中，GEPA 相比 GRPO 平均高约 6%，最高高约 20%，同时 rollout 数最多可以少 35 倍。

这说明 GEPA 的核心优势不是“无限试错”，而是：

> 利用语言反思，从更少的试跑中学到更有用的规则。

---

## 为什么 GEPA 可能比强化学习更省样本？

强化学习经常只看到这样的信号：

```text
这次得分：0.2
```

它需要大量尝试，才能慢慢学出哪些行为更好。

GEPA 看到的信号更像这样：

```text
这次失败是因为 planner 选择了错误工具。
用户要求计算表达式，但系统调用了 web_search。
应修改 tool_selector prompt：遇到明确算术表达式时优先调用 calculator。
```

这条反馈直接指出了：

- 哪个模块错了。
- 为什么错。
- 应该加什么规则。

所以它可能用更少 rollout 达到更好效果。

当然，GEPA 不能替代所有强化学习。如果任务需要模型学会新的深层能力，或者 Prompt 很难表达目标行为，权重训练仍然重要。

更准确的说法是：

> 当目标行为可以通过更好的指令、约束、示例或工作流策略表达时，Prompt 自动调优通常比权重训练更便宜、更可解释、更容易上线。

---

## 如何设计好的反馈函数？

Prompt 自动调优的效果高度依赖反馈质量。

一个差反馈可能是：

```text
答案不好。
```

这几乎没法指导修改。

一个好反馈应该像老师批改作业：

```text
答案错误，因为它引用了错误实体。
参考答案是 Company Y，但预测结果写成了 Company Z。
模型似乎依赖了第一篇检索文档，而没有检查包含目标年份 2021 的文档。
建议修改 Prompt：要求模型优先选择显式匹配目标日期的证据。
```

好反馈通常具备四个特点：

| 特点 | 好反馈 | 坏反馈 |
|------|--------|--------|
| **具体** | “JSON 缺少 `deadline` 字段。” | “格式不对。” |
| **因果** | “模型忽略了包含答案的检索文档。” | “答案错了。” |
| **可执行** | “回答前必须先列出支持证据。” | “更准确一点。” |
| **局部化** | “tool_selector 选择了错误工具。” | “Agent 失败了。” |

对多模块 Agent 来说，反馈最好能指出失败模块。

---

## 如何避免 Prompt 自动调优过拟合？

Prompt 自动调优也会过拟合。

如果优化器反复看同一批样本，它可能写出很多只针对这些样本的小补丁。例如：

```text
如果问题问 Company Y，就回答 Company Y。
```

这在训练集上可能得分高，但换个问题就不行。

一个稳健的评估设计应包含：

| 数据集合 | 用途 |
|----------|------|
| **训练集** | 用于生成 Prompt 变异和反思 |
| **验证集** | 用于选择候选版本和早停 |
| **测试集** | 最终只使用一次，报告真实性能 |
| **回归集** | 确保关键能力没有退化 |
| **对抗集** | 测试 Prompt 注入、畸形输入、边界情况 |

生产系统还应评估：

- 输出格式是否合法。
- 工具使用是否正确。
- 结论是否有证据支持。
- 安全规则是否被削弱。
- Token 成本是否增加太多。
- 延迟是否可接受。

特别要注意：

> **不能允许优化器为了提高任务分数而删除安全规则。**

安全 Prompt 和策略约束应该作为硬约束或单独回归测试存在。

---

## Prompt 进化之外：Skill 自动进化

到这里为止，我们讨论的是 Prompt 如何自动变好。

但真正长期运行的 Agent 还需要另一种能力：**Skill 自动进化**。

Prompt 进化解决的是：

```text
Agent 应该如何思考、规划和表达？
```

Skill 进化解决的是：

```text
Agent 已经学会的成功方法，能不能保存下来，下次复用？
```

可以这样理解：

```text
Prompt 进化：改说明书。
Skill 进化：积累工具箱。
```

两者是互补的。Agent 不仅要把说明书写得更好，还要把自己做过的事情变成可复用技能。

---

## Skill 进化代表方法

### Reflexion：失败后写反思，下次再用

**Reflexion** 发表于 NeurIPS 2023，是自然语言反思方向的重要代表。

它的思路是：Agent 做错任务后，不马上训练模型，而是写一段反思记忆：

```text
我失败是因为没有先检查函数参数类型。
下次遇到类似编程题，应先阅读测试用例，再修改代码。
```

下次遇到类似任务时，把这段反思放进上下文中，帮助 Agent 避免重复犯错。

Reflexion 的核心意义是：

> 经验可以用自然语言存储，不一定非要写进模型权重。

### Voyager：把成功代码存成技能库

**Voyager** 是 NVIDIA 在 2023 年提出的开放世界 Agent，运行在 Minecraft 环境中。

它有三个关键组件：

| 组件 | 作用 |
|------|------|
| **自动课程** | Agent 根据当前状态，自己决定下一步学什么 |
| **技能库** | 成功完成任务后，把可执行代码保存成 skill |
| **自修复循环** | 代码报错后，读取错误信息并修改代码，再尝试 |

Voyager 的技能不是一句经验，而是可执行代码。比如：

```text
如何采集木头
如何制作工具
如何探索洞穴
```

这些技能会被保存下来。以后遇到类似任务时，Agent 可以直接检索并调用。

这说明 skill 可以是：

- 自然语言经验。
- 可执行代码。
- 工具调用模板。
- 工作流片段。
- 结构化策略。

### ExpeL：从多次经验中提炼通用 insight

**ExpeL** 的全名是 *LLM Agents Are Experiential Learners*，发表于 AAAI 2024。

它想解决的问题是：

> Agent 能不能从很多成功和失败轨迹中，总结出更通用的经验规则？

流程大致是：

```text
收集成功和失败轨迹
   ↓
对比这些轨迹
   ↓
提炼通用 insight
   ↓
存入经验库
   ↓
新任务到来时检索相关 insight
   ↓
把 insight 放进 Prompt 中辅助推理
```

例如，在 WebShop 任务中，系统可能总结出：

```text
如果用户有明确预算，应先过滤价格，再比较评分。
```

ExpeL 和 GEPA 的关系是：

| 方法 | 产物 | 是否直接改 Prompt |
|------|------|------------------|
| ExpeL | 可检索的经验 insight | 不一定 |
| GEPA | 优化后的 Prompt | 是 |

两者可以结合：ExpeL 负责积累经验库，GEPA 负责把这些经验转化成更好的 Prompt。

### SkillRL / SkillX：结构化技能库方向

更新一些的工作，如 SkillRL、SkillX，开始探索更结构化的技能知识库。

它们不只是存几句话，而是可能把技能组织成不同层级：

```text
战略计划
  ↓
功能技能
  ↓
原子动作
```

例如，在一个软件操作 Agent 中：

```text
战略计划：完成一次数据分析报告
功能技能：读取 CSV、清洗字段、画图、生成摘要
原子动作：点击按钮、调用 pandas、保存图片
```

这种结构化技能库可以让 Agent 更长期地积累能力。

### Watch Every Step / IPR：从专家轨迹里学习每一步

**Watch Every Step** 关注的是 step-level learning，也就是不只看最终任务成功或失败，而是评估执行过程中的每一步是否合理。

很多 Agent 任务不是一步完成的。例如在 WebShop 中，Agent 可能需要：

```text
理解用户需求 → 搜索商品 → 过滤价格 → 比较评价 → 加入购物车 → 提交答案
```

如果最后失败了，只知道“失败”还不够。更有用的是知道：

```text
哪一步开始走偏了？
哪一步本来有更好的选择？
专家轨迹在同一步会怎么做？
```

这类方法会利用专家轨迹或高质量轨迹，对每一步动作进行过程级别的改进。它和 `GEPA` 的共同点是都重视执行过程，而不是只看最终结果。

不过两者也有区别：

| 对比点 | Watch Every Step / IPR | GEPA |
|--------|-------------------------|------|
| 优化对象 | Agent 的步骤选择策略，可能涉及模型训练 | Prompt 文本 |
| 反馈粒度 | 每一步动作的过程质量 | Prompt 造成的轨迹失败原因 |
| 是否改权重 | 通常可能需要训练或偏好优化 | 通常不改模型权重 |
| 更适合 | 有专家轨迹、希望学会更好过程策略的任务 | 有文字反馈、希望快速改进 Prompt 的系统 |

所以它更像是 Skill / Agent Learning 方向中的“过程学习”代表，而不是纯 Prompt 优化方法。

### Hermes Agent：工程化的长期自改进 Agent

**Hermes Agent** 更偏工程系统，而不是一篇有完整 benchmark 的学术论文。

它的价值在于展示了一种产品化思路：Agent 不只是执行一次任务，而是可以跨会话积累经验，自动创建 skill、改进 skill，并在未来任务中检索复用。

可以把它理解为下面这个循环：

```text
执行任务
  ↓
发现重复模式或失败点
  ↓
创建或修改 skill
  ↓
把 skill 存入长期记忆
  ↓
下次任务检索并复用
```

它和 `GEPA` 的关系也很直接：

- `Hermes Agent` 这类系统需要大量 Prompt 来决定何时创建 skill、如何描述 skill、如何检索 skill、如何调用 skill。
- 这些 Prompt 本身可以用 `GEPA` 这类方法继续优化。
- 因此，`GEPA` 更像是优化 Agent 内部“说明书”的方法，而 `Hermes Agent` 代表的是把说明书、经验库和技能库组合成长期运行系统的工程方向。

---

## Prompt 进化和 Skill 进化如何结合？

一个长期自我改进的 Agent，可能会同时做两件事：

```text
1. 用 GEPA 类方法优化 Prompt。
2. 用 Reflexion / ExpeL / Voyager 类方法沉淀 Skill。
```

它们之间可以形成闭环：

![Prompt 进化与 Skill 进化结合](../svg/chapter_llm_09_prompt_skill_loop.svg)

举个例子：

1. Agent 做代码修复任务失败。
2. 轨迹显示它没有先运行测试，而是直接改代码。
3. GEPA 修改 planner Prompt：要求修改前先定位测试失败原因。
4. ExpeL 提炼 insight：修复 bug 前先复现错误。
5. Skill 库保存一个“运行测试并解析失败日志”的工具调用流程。
6. 下次遇到类似任务，Agent 先检索该 skill，再按新 Prompt 执行。

这样，系统不仅“说明书”变好了，“工具箱”也变丰富了。

---

## 实际项目中如何落地 Prompt 自动调优？

下面是一套可以在 Agent 项目中落地的流程。

### Step 1：让 Prompt 模块化

不要把所有 Prompt 混在一个巨大字符串里。

更好的做法是显式命名：

```python
PROMPTS = {
    "intent_classifier": "...",
    "planner": "...",
    "tool_selector": "...",
    "reader": "...",
    "verifier": "...",
    "final_answer": "...",
}
```

这样优化器才能知道每个 Prompt 对应哪个模块。

### Step 2：记录完整 trace

一个最小 trace 可以长这样：

```text
trace = {
    "input": "用户原始请求",
    "module_prompts": "本轮使用到的各模块 Prompt",
    "module_outputs": "各模块的中间输出",
    "tool_calls": "工具调用记录",
    "tool_results": "工具返回结果",
    "final_output": "最终输出",
    "score": "评估分数",
    "feedback": "评估器给出的文字反馈"
}
```

没有 trace，优化器就像只看考试总分，却看不到错题过程。

### Step 3：设计可执行的反馈函数

反馈函数不要只返回分数，最好返回文字解释：

```python
def evaluate_answer(question: str, prediction: str, reference: str) -> dict:
    return {
        "score": 0.0,
        "feedback": """
答案错误。参考答案是 Company Y，但预测结果是 Company Z。
模型使用了无关文档，没有检查包含目标年份 2021 的文档。
建议修改 reader prompt：要求先匹配实体、关系和年份，再生成答案。
"""
    }
```

### Step 4：从高价值失败案例开始

不要一开始就随机收集大量数据。优先选择：

- 高频失败案例。
- 高业务价值案例。
- 格式敏感案例。
- 安全关键案例。
- 暴露 Prompt 歧义的边界情况。

### Step 5：小批量、低成本地迭代

常见策略是：

1. 用强模型生成 Prompt 变异。
2. 用小批量样本快速评估。
3. 早停明显不好的候选。
4. 对有希望的候选跑更大验证集。
5. 最终用生产模型和回归集完整测试。

### Step 6：保留人类审核

Prompt 自动调优生成的是人类可读文本，这是它的优势。

上线前应检查：

- Prompt diff 是否合理。
- 是否删除了安全规则。
- 是否加入过度特化的补丁。
- 是否让 Prompt 变得太长。
- 是否破坏了输出格式。

---

## 常见失败模式与风险

Prompt 自动调优很有用，但不是魔法。它也有风险。

| 失败模式 | 说明 | 缓解方法 |
|----------|------|----------|
| **评估器被 hack** | Prompt 学会讨好评估器，而不是真正解决任务 | 使用多评估器、隐藏测试集 |
| **Prompt 过度特化** | Prompt 充满针对个别样本的补丁 | 使用多样验证集、限制 Prompt 长度 |
| **安全退化** | 优化器删除影响得分的安全规则 | 冻结安全规则、加入安全回归测试 |
| **Token 膨胀** | 每轮都加规则，Prompt 越来越长 | 加入压缩步骤和成本惩罚 |
| **模块归因错误** | 改错了 Prompt | 使用 trace 级诊断和模块级反馈 |
| **评估不稳定** | 候选排名随随机性波动 | 固定随机种子、多次评估、看置信区间 |
| **迁移失败** | 在训练任务变好，真实场景不变好 | 使用真实分布样本和线上灰度 |

成熟的优化器不应只追求准确率，还要同时考虑：

- 鲁棒性。
- 安全性。
- 可解释性。
- 成本。
- 延迟。
- 可维护性。

---

## 什么时候应该使用 Prompt 自动调优？

适合使用的情况：

- 已经有明确任务和评估指标。
- 能收集代表性样本。
- 有失败案例和文字反馈。
- 手工调 Prompt 已经变慢或不稳定。
- 系统包含多个带 Prompt 的模块。
- 不方便或没必要微调模型权重。

不适合一开始就使用的情况：

- 还不清楚产品到底要做什么。
- 没有评估指标。
- 失败主要来自缺数据或缺工具。
- 安全策略还没定义清楚。
- Prompt 仍然很短，人工快速修改就够了。

一个实用原则是：

> **先手工写出可用 Prompt，再建设评估体系，最后做自动优化。**

Prompt 自动调优放大的是工程纪律，而不是替代工程纪律。

---

## 用一张表总结主要方法

| 方法 | 时间 | 核心思想 | 单阶段 / 多阶段 | 和 GEPA 的关系 |
|------|------|----------|----------------|----------------|
| **APE** | 2023 | 让 LLM 自动生成候选 Prompt，再用验证集筛选 | 单阶段 | 证明 LLM 可以自动写 Prompt |
| **ProTeGi** | 2023 | 用文本批评作为“文本梯度”，再改 Prompt | 单阶段 | GEPA 的重要思想来源 |
| **OPRO** | 2024 | 把历史候选和分数放进 meta-prompt，让 LLM 继续优化 | 单阶段 | 提供 LLM-as-optimizer 思路 |
| **EvoPrompt** | 2024 | 用遗传算法 / 差分进化搜索 Prompt | 单阶段 | 共享进化搜索思想 |
| **PromptBreeder** | 2024 | 任务 Prompt 和变异 Prompt 一起进化 | 过渡型 | 共享自指式 Prompt 进化思想 |
| **TextGrad** | 2024 | 像自动微分一样组织文本反馈 | 多阶段 | 共享“语言反馈可传播”的思想 |
| **DSPy / MIPROv2** | 2024 | 编译模块化 LLM 程序，优化 instruction 和 few-shot | 多阶段 | GEPA 可作为反思式补充 |
| **Trace** | 2024 | 用执行轨迹和丰富反馈优化生成式系统 | 多阶段 | 共享 trace-as-signal 思想 |
| **GEPA** | 2026 | 轨迹反思 + Prompt 变异 + Pareto 前沿 | 多阶段 | 集成型代表方法 |
| **Reflexion** | 2023 | 失败后写自然语言反思，并在后续任务中复用 | 多阶段 | 共享“自然语言反思可作为学习信号”的思想 |
| **Voyager** | 2023 | 把成功代码沉淀成可检索、可复用的技能库 | 多阶段 | 说明 Agent 不只应改 Prompt，也应沉淀 Skill |
| **ExpeL** | 2024 | 从成功和失败轨迹中提炼可检索 insight | 多阶段 | 可与 GEPA 组合：经验库提供素材，GEPA 改写 Prompt |
| **Watch Every Step / IPR** | 2024 | 用专家轨迹做步骤级过程改进 | 多阶段 | 与 GEPA 一样重视过程，但更偏策略学习 |
| **SkillRL / SkillX** | 2026 | 构建结构化技能知识库，让 Agent 递归进化 | 多阶段 | Prompt 进化和 Skill 进化的后续延伸 |
| **Hermes Agent** | 2026 | 工程化的跨会话 skill 创建、改进和检索 | 多阶段 | 展示 Prompt 优化与长期 Skill 系统的工程结合 |

---

## 本节小结

| 主题 | 关键要点 |
|------|----------|
| **为什么需要 Prompt 自动调优** | 复杂 Agent 有大量 Prompt，手工维护成本高 |
| **核心思想** | 把 Prompt 当作文本参数，用分数、文字反馈和执行轨迹优化 |
| **早期路线** | APE 证明 LLM 能写 Prompt，OPRO 把 LLM 当优化器 |
| **文本反馈路线** | ProTeGi 和 TextGrad 强调自然语言批评比纯分数更有信息量 |
| **进化路线** | EvoPrompt、PromptBreeder 把遗传搜索用于 Prompt 变异 |
| **多模块路线** | DSPy / MIPROv2 优化模块化 LLM 程序的 instruction 和 few-shot |
| **轨迹路线** | Trace 和 GEPA 都重视完整执行过程，而不只看最终答案 |
| **GEPA 的特点** | 用轨迹反思诊断失败，用 Prompt 变异修复问题，用 Pareto 保留互补候选 |
| **Skill 进化** | Reflexion、Voyager、ExpeL 等方法把经验、代码和技能沉淀下来 |
| **落地重点** | 模块化 Prompt、记录 trace、设计反馈函数、建立验证集和回归测试 |
| **主要风险** | 过拟合、评估器被 hack、安全退化、Token 膨胀、模块归因错误 |

Prompt 自动调优标志着一个重要转变：Prompt Engineering 不再只是个人经验，而正在变成一个反馈驱动的系统工程。

更长远地看，Agent 的自我改进可能会由两条线共同组成：

```text
Prompt 进化：让 Agent 更会思考和表达。
Skill 进化：让 Agent 更会复用和执行。
```

当这两条线结合起来，Agent 就不只是“被写出来的程序”，而会逐渐变成一个能从失败中总结、从成功中沉淀、并持续改进自己的系统。

---

## 参考文献

[1] ZHOU et al. [GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning](https://arxiv.org/abs/2507.19457)[C]//ICLR. 2026.

[2] ZHOU et al. [Large Language Models Are Human-Level Prompt Engineers](https://arxiv.org/abs/2211.01910)[C]//ICLR. 2023.

[3] YANG et al. [Large Language Models as Optimizers](https://arxiv.org/abs/2309.03409)[C]//ICLR. 2024.

[4] PRYZANT et al. [Automatic Prompt Optimization with Gradient Descent and Beam Search](https://arxiv.org/abs/2305.03495)[C]//EMNLP. 2023.

[5] YUKSEKGONUL et al. [TextGrad: Automatic Differentiation via Text](https://arxiv.org/abs/2406.07496)[R]. 2024.

[6] GUO et al. [Connecting Large Language Models with Evolutionary Algorithms Yields Powerful Prompt Optimizers](https://arxiv.org/abs/2309.08532)[C]//ICLR. 2024.

[7] FERNANDO et al. [Promptbreeder: Self-Referential Self-Improvement via Prompt Evolution](https://arxiv.org/abs/2309.16797)[C]//ICML. 2024.

[8] KHATTAB et al. [Optimizing Instructions and Demonstrations for Multi-Stage Language Model Programs](https://arxiv.org/abs/2406.11695)[C]//EMNLP. 2024.

[9] WANG et al. [Trace is the Next AutoDiff: Generative Optimization with Rich Feedback, Execution Traces, and LLMs](https://arxiv.org/abs/2406.16218)[R]. 2024.

[10] SHINN et al. [Reflexion: Language Agents with Verbal Reinforcement Learning](https://arxiv.org/abs/2303.11366)[C]//NeurIPS. 2023.

[11] WANG et al. [Voyager: An Open-Ended Embodied Agent with Large Language Models](https://arxiv.org/abs/2305.16291)[R]. 2023.

[12] ZHAO et al. [ExpeL: LLM Agents Are Experiential Learners](https://arxiv.org/abs/2308.10144)[C]//AAAI. 2024.

[13] LI et al. [Watch Every Step! LLM Agent Learning via Iterative Step-level Process Refinement](https://arxiv.org/abs/2406.11176)[R]. 2024.

[14] [SkillRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning](https://arxiv.org/abs/2602.08234)[R]. 2026.

[15] [SkillX: Automatically Constructing Skill Knowledge Bases for Agents](https://arxiv.org/abs/2604.04804)[R]. 2026.

[16] NousResearch. [Hermes Agent: The agent that grows with you](https://github.com/nousresearch/hermes-agent)[EB/OL]. 2026. 说明：`Hermes Agent` 当前更偏工程项目，暂无正式论文，因此这里附项目链接。

---

*上一节：[2.8 SFT 与强化学习训练数据准备](./08_training_data.md)*

*下一章：[第3章 工具调用（Tool Use / Function Calling）](../chapter_tools/README.md)*