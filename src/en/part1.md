# Part 1: Getting Started

## LLM Basics: How Should Non-Programmers Start Using AI?

> 🌱 *The first step to using large language models well is not understanding every technical detail. It is knowing what they can do, what they cannot do, and how to describe your task clearly.*

This opening part is written for readers who may have no programming background. You do not need to understand neural networks, model training, or API engineering before you begin. We will start from the user's point of view and treat a large language model as a practical everyday tool.

You can first imagine an LLM as a language-oriented assistant. It can read documents, draft text, revise wording, summarize long materials, explain concepts, generate plans, write code snippets, and brainstorm ideas with you.

But it is not an infallible expert. It is also not a database that naturally knows the latest truth. A better mental model is: **a capable, fast, and helpful collaborator whose output still needs human checking**.

The first thing to learn is therefore not model theory, but task communication.

### How to Read This Part

This part is designed for beginners. You do not need to memorize every model name, precisely count tokens, or understand how the model was trained.

Focus on four intuitions first:

| Intuition to Build | One-Sentence Explanation |
|---|---|
| **What an LLM is** | A collaborator that is good at language tasks |
| **What an LLM can do** | Help you read, write, revise, summarize, explain, and plan |
| **How to ask better questions** | Provide context, goal, materials, constraints, and output format |
| **When to be careful** | Verify important facts, numbers, legal, medical, and financial advice |

If, after reading this part, you can begin using LLMs for learning, writing, office work, or programming assistance, then it has achieved its goal.

## An LLM Is Not a Search Engine; It Is a Language Collaborator

Many first-time users treat an LLM like a search engine:

```text
What is the tallest mountain in the world?
What was a company's revenue this year?
Is this news story true?
```

These are valid questions, but they are not where LLMs are most valuable.

A search engine is better at helping you **find sources**. A calculator is better at **precise computation**. An LLM is especially useful for **processing language and tasks**.

For example, with the same long article:

- A search engine can help you find it.
- A browser can help you open it.
- An LLM can summarize it, explain it, rewrite it, extract arguments from it, and even turn it into a speech outline.

A concise way to remember the difference is:

> **Search engines help you find materials; LLMs help you process materials.**

If you only ask factual questions, an LLM may behave like an unreliable Q&A machine. But if you provide materials, goals, and constraints, it becomes a much more useful collaborator.

## Think of the LLM as a Capable Intern Who Needs Review

For beginners, the easiest analogy is: **an intern**.

This intern has read a lot, writes quickly, imitates patterns well, and can help organize your thoughts. But it also has several weaknesses:

- It may not know your actual background.
- It may misunderstand your goal.
- It may invent details to make an answer look complete.
- It may treat outdated information as current.
- It may produce fluent, well-formatted text that is still wrong.

So the right way to use it is not to ask for a perfect final answer in one shot. The right way is to collaborate iteratively.

A common loop looks like this:

1. You provide the task and background.
2. The model gives a first draft.
3. You check what is wrong or insufficient.
4. You add requirements or corrections.
5. The model revises.
6. You decide whether the result is usable.

For example:

```text
I am preparing a popular science article about AI for high school students.
Please first create an outline instead of writing the full article.
Use a relaxed tone, avoid complex formulas, and include one everyday analogy in each section.
```

This is much better than simply saying `Write an article about AI`, because it tells the model the audience, task, style, constraints, and expected output.

## What Can LLMs Help Ordinary People Do?

The most basic capability of an LLM is not “thinking like a human.” It is transforming and organizing language.

Give it a paragraph, and it can summarize it. Give it a topic, and it can draft. Give it scattered ideas, and it can organize them. Give it a concept, and it can explain. Give it code, and it can analyze.

From an ordinary user's perspective, the uses can be grouped like this:

| Scenario | What the LLM Can Do | Example Prompt |
|---|---|---|
| **Learning** | Explain concepts, create study plans, generate exercises, review answers | `Explain inflation in words a middle school student can understand.` |
| **Writing** | Draft, polish, change tone, expand, compress | `Make this paragraph clearer and more suitable as a blog opening.` |
| **Office work** | Write emails, organize meeting notes, extract action items | `Turn these meeting notes into a table of owner, task, and deadline.` |
| **Reading** | Summarize long documents, extract arguments, compare materials | `Summarize the article and list the author's three main arguments.` |
| **Programming** | Explain code, generate scripts, debug errors | `What does this Python error mean, and how should I fix it?` |
| **Creativity** | Name products, write scripts, brainstorm plans | `Give me 10 relaxed titles for an AI beginner course.` |
| **Decision support** | List options, compare pros and cons, identify blind spots | `Should I buy a tablet or a laptop? Please make a decision table.` |
| **Multimodal tasks** | Read screenshots, interpret charts, understand images | `What problem does this dashboard suggest?` |

A key principle is:

> **LLMs are best at helping you produce drafts, not at replacing your final judgment.**

They can help draft a resume, but you must verify the facts. They can summarize a contract, but important clauses still require professional review. They can help interpret a health report, but they cannot replace a doctor.

## How to Ask Better Questions

Many people feel that AI is not useful because their questions are too vague.

For example:

```text
Help me write a plan.
```

The model does not know who you are, who will read the plan, what the goal is, how long it should be, or what style you prefer. It can only guess.

For beginners, the simplest prompting formula is:

> **Context + Goal + Materials + Requirements + Output Format**

Let's rewrite the vague request:

```text
I am a university teacher preparing a 90-minute introductory AI class for students with no technical background.
The goal is for them to understand what LLMs can do and complete one effective prompt.
Please design a course outline.
Requirements:
1. Do not use formulas.
2. Include one interaction every 20 minutes.
3. End with a classroom exercise.
4. Output the result as a table.
```

This prompt is much clearer. It tells the model:

- **Context**: a university teacher teaching beginners.
- **Goal**: students should understand LLM capabilities and complete one effective prompt.
- **Task**: design a course outline.
- **Requirements**: no formulas, interactions, final exercise.
- **Format**: table.

You can use this reusable template:

```text
You are now acting as [role].
I want to complete [task].
The background is [context].
The materials I already have are [materials].
Please follow these requirements: [requirements].
The output format should be [format].
If information is insufficient, ask me questions first.
```

The last sentence is especially useful. It encourages the model to ask for missing information instead of making things up too quickly.

## What Is a Token?

When using LLMs, you will often see the word **token**.

You do not need the exact technical definition at the beginning. A simple intuition is enough: **tokens are the small text units that the model processes internally**.

For example, a sentence is not necessarily read as one complete object. It is split into smaller pieces. In English, a token may be a word or part of a word. In Chinese, it may be close to a character, a word, or punctuation.

Ordinary users do not need to count tokens precisely. Remember this:

> **The longer the input and output, the more tokens are consumed.**

The input is not only the latest message you typed. It may also include:

- Earlier conversation history.
- Uploaded documents.
- Pasted code.
- System instructions.
- Results returned by tools.

The model's answer becomes output tokens.

A rough cost model is:

```text
Total cost ≈ input token cost + output token cost
```

For many API models, output tokens are more expensive than input tokens because generating text requires additional computation.

## How Much Does It Cost to Use an LLM?

If you use consumer products such as ChatGPT, Claude, Gemini, Kimi, Doubao, Qwen, or DeepSeek, you usually do not need to calculate token costs manually. You are more likely to see free quotas, subscriptions, usage limits, or plan tiers.

If you call models through an API, token cost matters more.

By the time this book is written, model APIs are much cheaper than in the early days. Simple chat, short text polishing, and small summaries are usually low-cost. But long documents, full codebase analysis, or multi-step Agent execution can become expensive quickly.

Use this table to build intuition:

| Task | Token Usage Feeling | Cost Reminder |
|---|---|---|
| **Ask a simple question** | Very low | Usually not a concern |
| **Polish a paragraph** | Very low | Good for frequent daily use |
| **Write a short article** | Low | Longer output costs more |
| **Summarize a long article** | Medium | Longer source text means more input |
| **Analyze dozens of PDF pages** | High | Watch context length and cost |
| **Analyze an entire codebase** | High | Often needs batching or retrieval |
| **Let an Agent run dozens of steps** | Potentially very high | Set budget and stop conditions |

Multi-turn conversations deserve special attention. Many chat products send previous conversation history together with your new message so the model can remember context. This is convenient, but it also means long conversations may consume more input tokens.

If a conversation becomes very long, consider starting a new one. Ask the model to summarize the important context first, then bring that summary into the new conversation.

## Which AI Should Beginners Use? Where to Start? Should You Pay?

Many beginners care less about model leaderboards and more about three practical questions: **Which one should I use now? Where do I open or download it? Should I pay?**

A direct recommendation:

> **If you are completely new, do not start by studying every model. Pick one easy-to-access chat product with a good experience and enough free quota. Use it for a week before deciding whether to pay.**

### If You Just Want to Start Immediately

| Your Situation | Try First | Why |
|---|---|---|
| **You want to experience AI, writing, summarization, and learning** | `ChatGPT`, `Claude`, `Gemini`, `Kimi`, `Doubao`, `Qwen` | Low barrier, broad coverage, usually enough for beginner tasks |
| **You often read long documents, papers, or reports** | `Claude`, `Gemini`, `Kimi` | Stronger long-context reading and summarization experience |
| **You want strong general capability for writing and coding** | `ChatGPT`, `Claude`, `Gemini` | Good general-purpose reasoning, writing, and coding support |
| **You mainly write or modify code** | `Cursor`, `Trae`, `GitHub Copilot`, `Claude Code` | Integrated with editors, terminals, or project files |
| **You want low-cost API use or local deployment** | `DeepSeek`, `Qwen`, `Llama` | More relevant for developers; beginners can ignore this at first |

If you still do not know how to choose, use this order:

1. **First**: choose one easy chat product available to you.
2. **Second**: try ChatGPT, Claude, or Gemini if you can access them.
3. **Third**: if you start coding or modifying projects, try Cursor, Trae, Copilot, or Claude Code.

For most beginners, **using one tool for the first week is enough**. If you switch tools every day, it becomes hard to tell whether the tool is weak or your prompting is unclear.

### Where Should You Open or Download It?

The safest rule is: **use official websites or official app stores first; do not download unknown installers from random sources**.

| Access Method | How to Start | Best For |
|---|---|---|
| **Web app** | Search for the product name and open the official site | Desktop users who do not want to install software |
| **Mobile app** | Search in the App Store or official Android stores | Daily chat, photo understanding, voice input, quick summaries |
| **Desktop client** | Download from the official product website | Long office sessions, coding, local file workflows |
| **Editor plugin** | Install from VS Code, JetBrains, or other official plugin marketplaces | People already writing code |

Beginner rules:

- **Use the web app first if possible**: no installation, lower risk.
- **Mobile is good for daily use**: photos, screenshots, voice, quick notes.
- **Do not install programming tools too early**: if you do not write code yet, a chat product is enough.
- **Check official sources**: confirm product name, developer, and website before downloading.

### Official Entry Points for Common AI and Agent Tools

This table is not a ranking. It is a safe entry checklist for beginners. Links and product forms may change; always rely on official websites, official app stores, and project READMEs.

| Tool / Product | Type | Official Entry | Beginner Use |
|---|---|---|---|
| `ChatGPT` | Chat product / general AI assistant | [ChatGPT](https://chatgpt.com/) / [OpenAI](https://openai.com/chatgpt/) | General Q&A, writing, learning, code explanation |
| `Claude` | Chat product / long-document and coding assistant | [Claude](https://claude.ai/) | Long document reading, careful writing, code understanding |
| `Gemini` | Chat product / multimodal assistant | [Gemini](https://gemini.google.com/) | Images, video, long materials, Google ecosystem |
| `DeepSeek` | Chat product / model API | [DeepSeek Chat](https://chat.deepseek.com/) / [DeepSeek API Platform](https://platform.deepseek.com/) | Use the chat page first; developers can explore the API later |
| `Doubao` | Chinese chat product / multimodal assistant | [Doubao](https://www.doubao.com/) | Chinese daily use, writing, search, image understanding |
| `Kimi` | Chinese chat product / long-document reading | [Kimi](https://kimi.moonshot.cn/) | Uploading materials, summarizing long documents, reading papers |
| `Qwen / Tongyi Qianwen` | Chinese chat product / open-source model ecosystem | [Qwen Chat](https://chat.qwen.ai/) / [Tongyi Qianwen](https://tongyi.aliyun.com/qianwen/) / [Qwen GitHub](https://github.com/QwenLM) | Chat for ordinary users; models and APIs for developers |
| `Cursor` | AI IDE / coding Agent | [Cursor](https://www.cursor.com/) | Write code, modify projects, and ask questions inside an editor |
| `Trae` | AI IDE / coding Agent | [Trae International](https://www.trae.ai/) / [Trae China](https://www.trae.com.cn/) | AI-native IDE workflow, especially for developers |
| `GitHub Copilot` | Coding assistant / IDE plugin | [GitHub Copilot](https://github.com/features/copilot) | Code completion and explanation in VS Code, JetBrains, Visual Studio |
| `Claude Code` | Terminal coding Agent | [Claude Code](https://www.anthropic.com/claude-code) / [Official Docs](https://docs.anthropic.com/en/docs/claude-code/overview) | Read projects, edit files, run tests from the terminal; start with small tasks |
| `Codex` | OpenAI coding Agent / CLI | [OpenAI Codex GitHub](https://github.com/openai/codex) / [OpenAI](https://openai.com/) | Scripts, tests, small bug fixes, code tasks in the OpenAI ecosystem |
| `WorkBuddy` | Desktop Agent / office Agent | [WorkBuddy](https://www.codebuddy.cn/work/) | Files, spreadsheets, slides, meeting notes, multi-step office tasks |
| `OpenClaw` | Open-source local Agent / automation platform | [OpenClaw GitHub](https://github.com/openclaw/openclaw) | Better for users willing to deploy and configure tools; read permissions carefully |
| `Hermes Agent` | Open-source self-learning Agent | [Hermes Agent](https://hermes-agent.nousresearch.com/) / [GitHub](https://github.com/NousResearch/hermes-agent) | For developers studying open-source Agents, memory, and skill learning |

If you only want to start using AI, do not install everything. A safer order is: **start with chat products, move to coding tools when you write code, and consider desktop Agents only when you need AI to handle files and workflows**.

### Is the Free Version Enough? When Should You Pay?

Beginners usually **do not need to pay immediately**. First use the free version to complete tasks such as:

- Explain a concept.
- Summarize an article.
- Polish a paragraph.
- Create a study plan.
- Improve an email.
- Analyze a screenshot or short document.

If you use it continuously for a week and it truly saves time, then consider paying.

| Situation | Suggestion |
|---|---|
| **You only ask occasional questions** | Free versions are usually enough |
| **You use it every day for learning, writing, or office work** | Try a monthly subscription first |
| **You often upload long documents, images, or spreadsheets** | Paid plans usually have fewer limits and more stable experience |
| **You frequently write code or debug projects** | Consider Cursor, Copilot, or a stronger chat model plan |
| **You just want to test it** | Do not start with an annual plan; try free or monthly first |
| **You want to call models in your own program** | This is an API/developer scenario, usually billed by tokens or calls |

Two reminders:

1. **Paying does not make answers automatically correct**. Important facts, numbers, legal, medical, and financial advice still need verification.
2. **Do not subscribe to too many tools at once**. Most ordinary users only need one main tool until they encounter a clear bottleneck.

A simple choice rule:

> **If you do not want complexity, start with an accessible chat product. If you want stronger general ability, try ChatGPT, Claude, or Gemini. If you begin serious coding, add Cursor, WorkBuddy, or GitHub Copilot.**

The most important question is not “Which model is always best?” but:

> **For my current task, which tool saves me the most effort?**

## From Chat Windows to AI Tools: How Should Ordinary Users Choose?

So far, we have talked about “which model to use.” But once you start using AI seriously, another question appears:

- Should I use a chat product such as ChatGPT, Claude, or Gemini, or a dedicated coding tool?
- Claude Code, Codex, Cursor, and Trae all seem able to write code. How are they different?
- Are WorkBuddy and OpenClaw more advanced because they can operate files and workflows?
- Do beginners need to care about engineering concepts such as Harness and Trace?

A practical rule:

> **The model is the brain. The tool is the workbench, hands, permissions, and process record.**

The same model behaves differently in different tools. In a chat window, it mostly answers. In a coding Agent, it can read a project, edit files, and run tests. In an office Agent, it may organize documents, spreadsheets, and slides. In an enterprise Agent system, it needs permissions, logs, evaluation, and auditing.

Beginners do not need to study every tool first. Ask yourself three questions:

| Ask Yourself | If the Answer Is | Choose |
|---|---|---|
| **Does it need to operate my files or code?** | No, it is mainly Q&A, writing, or summarization | Chat product |
| **Does it need to understand and modify a project?** | Yes, it must read code, edit files, run tests | Coding Agent / AI IDE |
| **Does it need long-running execution, tools, or sensitive data handling?** | Yes, it needs automation, permissions, audit, rollback | Agent Harness / Trace / enterprise workflow |

In one sentence:

> **Learn prompting in chat products first, use Agents for real tasks next, and introduce Harness and Trace only when engineering control becomes necessary.**

### Model, Chat Product, Agent, Harness, and Trace Are Not the Same Thing

These terms are often mixed together, but they are different layers.

| Term | Like | Examples | Beginner Interpretation |
|---|---|---|---|
| **Model** | Brain | `GPT`, `Claude`, `Gemini`, `DeepSeek`, `Qwen` | Understands, reasons, and generates content |
| **Chat product** | Conversation window | `ChatGPT`, `Claude`, `Kimi`, `Doubao`, `Qwen` | Best entry point for Q&A, writing, summarization, explanation |
| **AI IDE / coding Agent** | AI coworker that edits code | `Claude Code`, `Codex`, `Cursor`, `Trae`, `Copilot` | Reads projects, edits files, runs commands, fixes bugs |
| **Office / desktop Agent** | AI assistant that operates work tools | `WorkBuddy`, `OpenClaw` | Handles files, spreadsheets, slides, messages, workflows |
| **Harness** | Agent control shell | Tool orchestration, permissions, memory, evaluation, logs | Keeps an Agent safe, stable, and controllable |
| **Trace / Agent Trace** | Process record | Execution logs, code attribution, audit records | Records what the AI did for checking, accountability, rollback |

A layered view:

```text
Model → Chat product → Agent tool → Harness → Trace / audit / evaluation
```

The further right you go, the more the AI can do, but the higher the risk and management cost. For beginners, the right order is not “start with the most powerful tool.” It is **start with low-risk tasks and gradually grant more permission**.

### 1. Chat Products: The Best First Stop

If your task is mainly reading, writing, revising, summarizing, explaining, or planning, a chat product is usually enough.

Common options include:

- `ChatGPT`: mature general capability and tool ecosystem for Q&A, writing, and coding assistance.
- `Claude`: often strong at long-document reading, careful writing, and rigorous summarization.
- `Gemini`: strong multimodal and long-context capability, useful for images, video, long materials, and the Google ecosystem.
- `Kimi`: friendly Chinese long-document reading experience, useful for papers, reports, and materials.
- `Doubao`, `Tongyi`, `Wenxin`, `GLM`: useful for Chinese office work, content generation, and local ecosystems.
- `DeepSeek`, `Qwen`: popular among developers for code, reasoning, low-cost APIs, or local deployment.

Example:

```text
I have a 20-page industry report.
Please summarize it into 10 key points, then list 3 risks I should focus on.
Do not invent information that is not in the report.
```

Chat products have low barriers, low risk, and fast feedback. They do not directly operate your computer or modify your files, so they are ideal for building basic AI habits.

**Good tasks for chat products**:

- Learn a new concept.
- Polish a paragraph.
- Summarize an article or report.
- Create a study plan, work plan, or event plan.
- Explain code or an error message.

If you are unsure what to use, start here.

### 2. AI IDEs and Coding Agents: For Real Project Work

When a task changes from “answer this question” to “modify this project,” a chat window becomes inconvenient.

Tools such as `Claude Code`, `Codex`, `Cursor`, `Trae`, and `Copilot` can work around a codebase. They can often:

- Read project structure.
- Search functions and call relationships.
- Explain unfamiliar code.
- Modify files.
- Continue after errors.
- Generate tests.
- Run commands or test suites and iterate from results.

A rough comparison:

| Tool | Better For | Beginner Tip |
|---|---|---|
| `Claude Code` | Multi-step coding tasks, project reading, file editing, tests | Good for medium or large projects; start with small changes |
| `Codex` | Code generation, scripting, automated development in the OpenAI ecosystem | Good for scripts, tests, and small bug fixes |
| `Cursor` | Ask and edit inside an AI editor, generate diffs, understand projects | Good for users familiar with VS Code-style workflows |
| `Trae` | AI-native IDE / Agent programming experience | Good for developers who want Agent capabilities inside an IDE |
| `Copilot` | Daily completion, code explanation, local functions and tests | Low-friction integration with existing IDEs |

A safer workflow is: ask it to read first, then ask it to modify.

```text
Please read the login flow in this project first. Do not modify code yet.
Tell me:
1. Where the login entry point is.
2. Where the token is generated and stored.
3. Which files would need changes if I add SMS verification.
```

Then:

```text
Modify according to the plan.
Requirements:
1. Do not change the existing password login flow.
2. Add SMS verification.
3. Run the related tests after modification.
4. Summarize which files changed.
```

**Beginner warning**: do not start with “refactor the whole project.” Ask the AI to explain the flow, locate the issue, and change one small feature first.

### 3. Office and Desktop Agents: For Multi-File, Multi-Tool Workflows

If your task is not coding but involves documents, spreadsheets, slides, folders, messages, and workflows, office or desktop Agents such as `WorkBuddy` and `OpenClaw` are more relevant.

The difference from chat products is that chat products mainly **answer**, while desktop Agents emphasize **execution**.

They can help with tasks such as:

- Organizing a folder of materials.
- Summarizing multiple customer interview notes.
- Extracting key information from spreadsheets.
- Generating a presentation outline or first draft.
- Turning daily reports, weekly reports, or meeting notes into action items.
- Calling external tools and sending results into a team workflow.

Example:

```text
Please organize the 20 customer interview notes in this folder.
Output:
1. Each customer's core needs.
2. Top 5 frequent issues.
3. A three-slide summary outline suitable for a presentation.
```

For automation:

```text
Every morning at 9:00, read the daily reports in the specified folder,
summarize newly added issues from yesterday,
sort them by severity,
and send the summary to the team channel.
```

These tools can be efficient, but they also require permission awareness. If an Agent can read and write local files, access company data, send messages, or call APIs, first restrict its scope and test it with non-sensitive materials.

### 4. Harness: The Control Shell That Makes Agents Reliable

A `Harness` is not usually a daily chat product for ordinary users. It is more like the engineering shell around an Agent.

For an Agent to work reliably, a model alone is not enough. It also needs:

- **Tool inventory**: Which tools can it call?
- **Permission control**: Which files can it read? Which commands can it run? Which actions require approval?
- **Memory system**: What should be remembered long term? What must not be stored?
- **Execution environment**: Where does code run? How does it stop on failure? Can it roll back?
- **Evaluation mechanism**: How do we know whether it did the right thing?
- **Logs and audit**: What did it do at each step? Who approved it?

Together, these capabilities form the Agent's `Harness`.

In one sentence:

> **The model determines how smart the Agent can be; the Harness determines whether it can work safely, stably, and controllably.**

If you are an individual user, it is enough to understand the concept. If you want to deploy Agents in a team or enterprise, Harness becomes essential.

### 5. Trace: Leaving an Inspectable Trail of AI Actions

`Trace` or `Agent Trace` means recording the Agent's execution process.

If AI only rewrites one sentence, complex tracing is unnecessary. But when it edits code, processes customer data, calls APIs, or sends messages, you need to know:

- Which files did it read?
- What did it change?
- Why did it make that decision?
- Which step introduced the problem?
- Did a human review it?
- Can the change be attributed and rolled back?

This is the value of Trace: **it does not make AI better at answering; it makes AI actions inspectable, reviewable, and accountable**.

Also note the similar name `Trae`:

| Name | Like | Focus |
|---|---|---|
| `Trace / Agent Trace` | Process record and audit mechanism | Record what AI did for inspection, attribution, and rollback |
| `Trae` | AI programming IDE / Agent tool | Help developers write code, read projects, and edit files |

### Which Path Should Beginners Follow?

| Who You Are / What You Need | Choose First | Do Not Rush Into |
|---|---|---|
| **Complete beginner exploring AI** | `ChatGPT`, `Claude`, `Kimi`, `Doubao`, `Qwen` | `OpenClaw`, Harness-heavy systems |
| **Student / writer / office worker** | `Claude`, `ChatGPT`, `Kimi`, `WorkBuddy` | Complex Agent frameworks |
| **Beginner programmer** | `ChatGPT`, `Claude`, `Copilot`, `Cursor` | Fully automated large-project refactoring |
| **Daily developer** | `Claude Code`, `Codex`, `Cursor`, `Trae` | Auto-running scripts without permission control |
| **Team tech lead** | Coding Agent + Trace + code review process | Only comparing model leaderboards without workflow design |
| **Automation builder** | `WorkBuddy`, `OpenClaw`, `MCP`, Harness | Granting full permissions immediately |
| **Enterprise deployment** | Harness, permission system, audit, evaluation, private models | Handling sensitive data through personal chat accounts |

A safer learning order:

1. **Start with chat products**: learn to describe tasks clearly.
2. **Move to AI IDEs / coding Agents**: let AI read code, make small changes, and run tests.
3. **Use office / desktop Agents**: let AI handle files, spreadsheets, slides, and multi-step tasks.
4. **Introduce Harness and Trace**: when long-running execution, collaboration, permissions, and auditing become important.

Do not pursue “full automation” too early.

> **The more automatic an AI tool becomes, the more gradually you should grant permission: first let it suggest, then let it modify, and only later let it execute.**

## A Seven-Day Beginner Practice Plan

If you are just starting with LLMs, spend one week on these exercises.

They do not require programming or technical background. The key is to use AI in real life and real work.

| Day | Exercise | Example Prompt |
|---|---|---|
| **Day 1** | Explain a concept you recently did not understand | `Explain what a large language model is using everyday analogies.` |
| **Day 2** | Improve something you wrote | `Make this paragraph clearer and more natural.` |
| **Day 3** | Summarize an article | `Summarize this article into 5 points and list the author's viewpoint.` |
| **Day 4** | Let it act as a teacher | `Create 5 practice questions about this topic and provide answers.` |
| **Day 5** | Make a plan | `Design a 14-day English speaking practice plan for me.` |
| **Day 6** | Analyze a decision | `Should I buy a tablet or a laptop? Compare pros and cons by scenario.` |
| **Day 7** | Complete a real first draft | `Help me write a polite email asking for an extension on an assignment.` |

During practice, observe three things:

1. Does the answer become more relevant when you provide more information?
2. Does the result become easier to use when you specify the output format?
3. Does the quality improve after you point out problems and ask for revision?

If yes, you have already learned the most important habit: **an LLM is not a one-shot answer machine; it is an iterative collaborator**.

## Common LLM Failure Modes

LLM answers often sound fluent, confident, and well-formatted. That does not mean they are correct.

Common risks include five categories.

### 1. Confident Fabrication

The model may invent non-existent papers, authors, links, legal clauses, statistics, or citations that look real.

When asking factual questions, request sources and verify them yourself.

### 2. Treating Old Information as Current

Some models do not have web access. Some have outdated knowledge. They may not know the latest policies, prices, model names, or company announcements.

If the question depends on current information, use a search-capable tool or check official sources.

### 3. Math and Precise Calculation Errors

LLMs are good at explaining mathematical ideas, but they are not always reliable calculators. Even simple arithmetic can be wrong, and complex computation should be verified with a calculator, spreadsheet, or code.

A practical approach is to ask the model to show the calculation process, then verify the result with a reliable tool.

### 4. Misunderstanding Your Real Intent

If you only say `Help me write a plan`, the model does not know whether you need a business plan, lesson plan, event plan, or project plan.

The less context you provide, the more it must guess. The more it guesses, the more likely it is to go off target.

### 5. Correct Format, Wrong Content

This is especially deceptive.

An LLM can present wrong content in a polished format: headings, tables, numbered lists, and confident conclusions. Good formatting does not guarantee correctness.

For important topics, do not ask only once. Use self-check prompts:

```text
Please review your previous answer. Which parts are certain, and which parts require further verification?
```

```text
Please challenge this plan from the opposing perspective and list the three most likely reasons it could fail.
```

```text
List the key assumptions behind your answer. If these assumptions are false, how would the conclusion change?
```

These follow-up prompts can significantly improve quality.

## From “Can Use” to “Use Well”: What Comes Next?

Once you consciously provide context, specify requirements, check outputs, and ask follow-up questions, you have already entered the world of Prompt Engineering.

From here, you can continue learning more advanced topics to build a full picture of Agents and understand the language-model foundation that powers them. If your only goal is to use LLMs in daily life, you can stop here and practice.

| Chapter | Content | What You'll Gain |
|---------|---------|-----------------|
| **Chapter 1** What is an Agent? | Agent definition, architecture, history, and use cases | A complete conceptual framework |
| **Chapter 2** Development Environment Setup | Python environment, core library installation, API Key management | A ready-to-run development workbench |
| **Chapter 3** LLM Fundamentals | LLM principles, Prompt Engineering, API calls | Confident mastery of the Agent's "brain" |

---

*Start learning: [Chapter 1: What is an Agent?](./chapter_intro/README.md)*
