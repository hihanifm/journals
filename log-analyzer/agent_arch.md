# Agent Pipeline Architecture

## End-to-end Flow

```mermaid
flowchart LR
  User --> Orchestrator
  Orchestrator --> ContextBuilder
  ContextBuilder --> PromptBuilder
  PromptBuilder --> LLM
  LLM --> Response
```
