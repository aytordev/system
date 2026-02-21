# Storyboard — Full Framework

## Purpose

Create a 6-frame visual narrative that tells the story of a user's journey from
problem to solution, using a classic storytelling arc. This builds empathy,
illustrates value, and makes abstract product concepts concrete before any
design or engineering work begins.

This is a storytelling tool, not a UI mockup. If the team cannot tell the story
of a user's experience in six frames, the value proposition is not clear enough
to build.

## When to Use

- Pitching a new product or feature to stakeholders
- Aligning cross-functional teams (product, design, engineering, executives) on
  user value
- Testing whether a product idea resonates emotionally before building
- Communicating product vision at all-hands or investor meetings
- Validating problem-solution fit with a narrative rather than a spec

## When NOT to Use

- For technical implementation details (use architecture diagrams)
- When the user problem is trivial or well-understood by all parties
- As a replacement for user research (storyboards illustrate insights, they do
  not create them)
- For detailed UI or interaction flows (use wireframes or prototypes)

## The 6-Frame Structure

Each frame maps to a stage in a classic narrative arc:

| Frame | Name                  | Role                                              |
|-------|-----------------------|---------------------------------------------------|
| 1     | Main Character        | Introduce the persona and their context            |
| 2     | The Problem Emerges   | Show the challenge or obstacle they face           |
| 3     | The "Oh Crap" Moment  | Escalate the problem to create urgency             |
| 4     | The Solution Appears  | Introduce your product or feature naturally        |
| 5     | The "Aha" Moment      | Show the user experiencing the breakthrough        |
| 6     | Life After            | Illustrate the improved state and new normal       |

## Complete Template

```markdown
## 6-Frame Storyboard: [Feature/Product Name]

**Frame 1: Main Character**
[Name, age, role, context. Specific enough that the target persona recognizes
themselves. Include a visual description: setting, mood, key objects.]

**Frame 2: The Problem Emerges**
[Describe the challenge. Show observable behavior — what they are doing, what is
going wrong, how it affects their day.]

**Frame 3: The "Oh Crap" Moment**
[Escalate. The problem causes real consequences — missed deadline, lost money,
embarrassment, anxiety. Make it visceral.]

**Frame 4: The Solution Appears**
[Show realistic discovery — a colleague mentions it, they see a recommendation,
they search for help. NOT "magically discovers our product."]

**Frame 5: The "Aha" Moment**
[Show the outcome of using the solution, not the features. The character
experiences relief, surprise, delight. Focus on feeling, not UI.]

**Frame 6: Life After the Solution**
[Concrete improved state with specific details — time saved, stress removed,
new behavior enabled. Quantify where possible.]

**Visual Style:** [Fat-marker sharpie sketches / hand-drawn / minimal / other]
```

## Worked Example

```markdown
## 6-Frame Storyboard: SmartInvoice Auto-Reminders

**Frame 1: Main Character**
Sarah, 35, freelance graphic designer. Home office, 10 active client projects.
Laptop surrounded by sticky notes, coffee cup, design tools. Busy but happy.

**Frame 2: The Problem Emerges**
Sarah stares at a spreadsheet labeled "Overdue Invoices." Multiple browser tabs
open. Clock shows 10pm. She spends 8 hours per month chasing late payments via
email and spreadsheets instead of doing design work.

**Frame 3: The "Oh Crap" Moment**
Phone notification: "Day 14: Payment Overdue from Client XYZ — $5,000." Sarah's
face shows worry. Calendar shows rent due in 3 days. The client has gone silent.
She forgot to follow up because she was focused on a design deadline.

**Frame 4: The Solution Appears**
Sarah reads a designer forum post: "Anyone else hate chasing invoices?" A reply
recommends SmartInvoice. She visits the landing page — headline: "Stop Chasing
Payments." Testimonial: "Saved me 5 hours/month." She's curious but skeptical.

**Frame 5: The "Aha" Moment**
Two days later, Sarah's phone buzzes: "Client XYZ just paid! $5,000 received."
The AI-timed reminder worked — no awkward follow-up call needed. She smiles,
relieved. Background shows sunset — she's done with work early.

**Frame 6: Life After the Solution**
Sarah plays with her kids in the backyard at 6pm, laptop closed on the patio
table. On-time payments jumped from 50% to 80%. She spends 30 minutes per month
on invoicing instead of 8 hours. Her cash flow is predictable, her anxiety gone.

**Visual Style:** Fat-marker sharpie sketches — minimal, monochrome, hand-drawn.
```

## Process

### Step 1: Gather Context

Before creating the storyboard, you need:

- **Persona clarity:** Who is the main character? (use proto-persona framework)
- **Problem understanding:** What challenge do they face? (use problem statement)
- **Solution definition:** What product or feature will help? (use positioning)
- **Desired outcome:** What does success look like for the user?

If any of these are missing, run discovery work first. Do not fabricate.

### Step 2: Answer the 7 Questions

Work through these sequentially:

1. Who is the main character experiencing this problem?
2. Describe the problem or challenge they face.
3. Describe the "Oh Crap" moment where the problem creates a major issue.
4. How is the solution introduced to the main character?
5. Describe the character using the solution and experiencing the "Aha" moment.
6. What is life like for the character after using the solution?
7. Do you have specific visual style or rendering instructions?

### Step 3: Test the Storyboard

Run these validation questions:

1. **Is the character relatable?** Would the target persona recognize themselves?
2. **Is the problem visceral?** Do people feel the frustration in Frames 2-3?
3. **Is the escalation authentic?** Does the "Oh Crap" moment feel real, not manufactured?
4. **Is discovery natural?** Or does the solution introduction feel forced?
5. **Is the "Aha" moment believable?** Can users imagine experiencing this?
6. **Is the "after" state aspirational?** Would users want this outcome?

If any answer is "no," revise that frame.

## Common Failure Modes

| Failure Mode                 | Example                                           | Fix                                                    |
|------------------------------|---------------------------------------------------|--------------------------------------------------------|
| Generic persona              | "Meet User, a busy professional"                  | Get specific: name, age, role, context, observable details |
| Weak problem                 | "User has a problem with efficiency"              | Make it visceral: describe time lost, money wasted, stress caused |
| Forced solution introduction | "User magically discovers our product"            | Show realistic discovery: forum, colleague, search     |
| Feature-centric "Aha"       | "User sees the dashboard and loves the features"  | Focus on outcome: what changed for them, how they feel |
| Vague "after" state          | "Life is better now"                              | Quantify: hours saved, money recovered, stress removed |
| Too polished too early       | Spending hours on perfect visuals                 | Sketches work. Content first, polish later             |

## Quality Checklist

- [ ] Main character is specific enough that the target persona recognizes themselves
- [ ] Problem is observable behavior, not an abstract concept
- [ ] "Oh Crap" moment escalates authentically — not contrived
- [ ] Solution introduction is realistic — not a product placement
- [ ] "Aha" moment is about the user's outcome, not the product's features
- [ ] "After" state is concrete and quantified where possible
- [ ] Visual style is specified (even if "rough sketches")
- [ ] Stakeholders can give feedback on the story, not just nod politely

## Relationship to Other Frameworks

1. **Proto-Persona** — defines the main character for Frame 1
2. **Problem Statement** — frames the problem for Frames 2-3
3. **Positioning Statement** — informs the solution introduction in Frame 4
4. **Jobs-to-be-Done** — informs the desired outcome in Frame 6
5. **Press Release** — a complementary storytelling format; storyboard is visual,
   press release is written narrative
