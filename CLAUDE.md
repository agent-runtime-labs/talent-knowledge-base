# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. It serves as a primary reference for future instances of Claude Code collaborating on the `talent-knowledge-base`.

## 📖 Overview & Architecture

### Big Picture Concept
The system is an **Enterprise knowledge repository** designed to power AI-driven talent discovery and semantic search capabilities. The core function involves ingesting, structuring, and indexing candidate profile data so that it can be efficiently queried using advanced AI models (e.g., powered by Amazon Bedrock Knowledge Bases).

### Conceptual Data Flow
1.  **Source:** Raw candidate profiles are the primary input.
2.  **Infrastructure Layer (`infra-as-code/`):** This directory is critical for understanding how the operational infrastructure supporting the knowledge base is provisioned and managed. Changes here dictate changes to the system's deployable environment.
3.  **Documentation & Profiles (`docs/profiles/`, `README.md`):** These contain the business logic, data schemas, usage guidelines, and reference material that define *what* the system should store and how it should be searched.
4.  **Core System Logic (Assumed):** While explicit source code directories are not immediately visible, the application relies on components for **semantic search**, **data ingestion/processing**, and **API interaction**. Any changes to data models or processing logic must respect the schema implied by the knowledge base structure.

### Critical Conceptual Boundaries
*   **Data Schema:** The format of candidate profiles is the single most critical artifact. Maintain consistency with all definitions found in `docs/`.
*   **Search Semantics:** All code that interacts with querying mechanisms (e.g., connecting to a Vector DB or an AI service) must be designed with semantic search capabilities as its primary goal, not simple keyword matching.

## 🔨 Development Workflow & Commands

Due to the current codebase structure, explicit build and test commands are not immediately discoverable in standard files (`package.json`, `Makefile`, etc.). **It is mandatory to investigate within the following directories for command definitions:**

*   **Build/Setup Steps:** Check configuration files and setup guides within the `docs/` directory first.
*   **Infrastructure Provisioning:** Commands related to deployment or environment setup are expected to reside within the `infra-as-code/` directory. *Action: Treat this folder as the source of truth for deployment steps.*

### Local Development Best Practices (Hypothetical)
1.  **Environment Setup:** Assume a local setup script must exist, likely requiring configuration changes based on environment variables set in the root or `docs/`.
2.  **Testing Single Cases:** To develop locally, one should typically:
    *   Identify the relevant component logic file.
    *   Write a unit test for the specific failure scenario or feature.
    *   Run only that single test case to validate the fix *before* running the full suite.

## ✨ Project-Specific Rules & Guidelines

### Coding Best Practices (Mandatory Behavioral Guardrails)
All contributions must adhere strictly to the following behavioral guidelines:

1.  **Think Before Coding:** Always state explicit assumptions about the current state or external dependencies before writing any code block. If a trade-off exists between two approaches, surface it and recommend one while documenting why the others were rejected. Stop if requirements are unclear.
2.  **Simplicity First:** Code must be minimal and directly address the requested feature. Do not introduce speculative logic, magic configuration flags for non-requested features, or over-engineer components based on assumed future needs.
3.  **Surgical Changes:** Maintain absolute consistency with the existing codebase's style (indentation, variable naming, etc.). Only modify code that is demonstrably broken according to the task description. When removing unused imports or variables, **always remove your own artifacts first**.
4.  **Goal-Driven Execution:** Frame all tasks as verifiable goals (e.g., "Write a unit test for X $\rightarrow$ Run tests and confirm pass"). Do not simply write code that *looks* correct; the goal is to make it demonstrably work.

### External Directives & Notes
*   **Contribution Rules:** Review the contents of `docs/` for any files containing explicit contribution rules (e.g., a dedicated `CONTRIBUTING.md`).
*   **Architectural Constraints:** Pay special attention to how **Candidate Profiles** are defined and used in all code paths, as this is the central domain model.

***