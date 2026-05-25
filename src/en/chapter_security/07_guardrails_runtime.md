# 18.7 Guardrails Runtime Protection

> **Goal**: Understand the concept and architecture of Guardrails, learn mainstream frameworks such as NVIDIA NeMo Guardrails and Guardrails AI, and build custom runtime protection for Agent systems.

---

## Why Prompt-Only Safety Is Not Enough

Many safety methods rely on the model to "follow instructions". This is fragile:

| Limitation | Concrete Problem |
|-----------|------------------|
| Instructions can be overridden | Prompt injection |
| Instructions can be forgotten | Long-context dilution |
| No hard enforcement | The model only probabilistically follows rules |
| Hard to audit | Failures are difficult to trace |
| Not runtime-aware | Policies cannot adapt to current state |

> 💡 **Core idea of Guardrails**: build a programmable, auditable, enforceable safety layer between inputs, model reasoning, tool calls, and outputs.

---

## Three-Layer Guardrails Architecture

```text
Input Guardrails
  - injection detection
  - topic constraints
  - PII detection and redaction
  - length and format limits
        ↓
Flow Guardrails
  - conversation policy
  - state tracking
  - tool permission checks
  - multi-turn risk accumulation
        ↓
Output Guardrails
  - sensitive information filtering
  - factuality checks
  - format validation
  - policy compliance
```

Guardrails differ from prompt constraints because they are enforced by code, not only by model behavior.

---

## A Minimal Runtime Guardrail

```python
from dataclasses import dataclass
from enum import Enum


class GuardrailDecision(Enum):
    ALLOW = "allow"
    BLOCK = "block"
    MODIFY = "modify"
    ESCALATE = "escalate"


@dataclass
class GuardrailResult:
    decision: GuardrailDecision
    reason: str
    modified_content: str | None = None


class InputGuardrail:
    def check(self, user_input: str) -> GuardrailResult:
        lowered = user_input.lower()
        if "ignore previous instructions" in lowered:
            return GuardrailResult(GuardrailDecision.BLOCK, "Prompt injection pattern detected")
        if len(user_input) > 20_000:
            return GuardrailResult(GuardrailDecision.BLOCK, "Input too long")
        return GuardrailResult(GuardrailDecision.ALLOW, "Input allowed")
```

---

## Tool-Call Guardrails

For Agents, the most important guardrails sit before tool execution.

```python
DANGEROUS_COMMANDS = ["rm -rf", "sudo", "curl | sh", "wget", "chmod 777"]
SENSITIVE_PATHS = [".env", "secrets/", "id_rsa", "production.json"]


class ToolGuardrail:
    def check_tool_call(self, tool_name: str, arguments: dict) -> GuardrailResult:
        if tool_name == "bash":
            command = arguments.get("command", "")
            if any(pattern in command for pattern in DANGEROUS_COMMANDS):
                return GuardrailResult(GuardrailDecision.BLOCK, "Dangerous shell command")

        if tool_name in {"read_file", "write_file"}:
            path = arguments.get("path", "")
            if any(pattern in path for pattern in SENSITIVE_PATHS):
                return GuardrailResult(GuardrailDecision.ESCALATE, "Sensitive file access")

        return GuardrailResult(GuardrailDecision.ALLOW, "Tool call allowed")
```

The model may propose a dangerous action, but the runtime must decide whether the action is allowed.

---

## Output Guardrails

```python
class OutputGuardrail:
    def check(self, output: str) -> GuardrailResult:
        if "sk-" in output or "BEGIN PRIVATE KEY" in output:
            return GuardrailResult(
                GuardrailDecision.MODIFY,
                "Potential secret detected",
                modified_content="[REDACTED: potential secret]",
            )
        return GuardrailResult(GuardrailDecision.ALLOW, "Output allowed")
```

Output guardrails are useful for redacting secrets, enforcing JSON schemas, blocking unsafe advice, and verifying citations.

---

## Stateful Risk Tracking

Single-turn checks are not enough for Agents. Risk can accumulate across steps.

```python
@dataclass
class RiskState:
    prompt_injection_hits: int = 0
    sensitive_access_attempts: int = 0
    dangerous_tool_attempts: int = 0

    def risk_score(self) -> int:
        return (
            self.prompt_injection_hits * 2
            + self.sensitive_access_attempts * 3
            + self.dangerous_tool_attempts * 4
        )


class StatefulGuardrail:
    def __init__(self):
        self.state = RiskState()

    def should_escalate(self) -> bool:
        return self.state.risk_score() >= 5
```

A modern Agent safety system should be stateful: it should remember previous suspicious behavior and tighten controls as risk increases.

---

## Framework Landscape

| Framework | Focus | Typical Use |
|----------|-------|-------------|
| NeMo Guardrails | Conversational flow and policy rails | Enterprise chat and workflow control |
| Guardrails AI | Structured validation and output correction | JSON/schema validation, content checks |
| Llama Guard / classifiers | Safety classification | Input/output moderation |
| Custom runtime guardrails | Tool and environment control | Production Agent systems |

Frameworks help, but production Agents usually still require custom guardrails around tools, permissions, data, and deployment environment.

---

## Best Practices

- Place guardrails before tool execution, not only before final output.
- Treat model output as a proposal, not as an authorized action.
- Log every blocked, modified, or escalated event.
- Use stateful risk tracking for multi-step workflows.
- Combine allowlists, blocklists, classifiers, schema validation, and human approval.
- Test guardrails with red-team cases before deployment.

---

## Chapter Takeaways

- Prompt constraints are not enforceable security boundaries.
- Guardrails provide programmable, auditable, runtime safety controls.
- Agent systems need input, flow, tool-call, and output guardrails.
- Stateful risk tracking is essential for multi-step Agents.
- Guardrails should be validated through systematic red-team testing.

---

*Previous: [18.6 Security Paper Readings](./06_paper_readings.md)*  
*Next: [18.8 Red Teaming Methodology](./08_red_teaming.md)*
