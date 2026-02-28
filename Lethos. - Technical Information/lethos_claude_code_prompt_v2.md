# Lethos — Claude Code Build Prompt (v2)

Paste this into Claude Code (Opus 4.6) in terminal. Make sure you're in the /Users/patrickboulton/Documents/Lethos directory first.

---

```
Build me a SwiftUI iOS app called "Lethos" — an AI-powered fitness app that analyses a user's goal physique from a photo and generates a personalised beginner workout plan. The project should be created in this directory: /Users/patrickboulton/Documents/Lethos

IMPORTANT: Read the spec document at /Users/patrickboulton/Documents/Lethos/Lethos.pdf first — it contains the onboarding flowchart, feature requirements, and paywall details. The instructions below expand on and clarify that spec. Where this prompt and the PDF conflict, this prompt takes priority as it contains the latest decisions.

## Core Principle

This app is for ABSOLUTE BEGINNERS. Keep everything REALLY simple. Do NOT overcomplicate it. Every screen should be clean, minimal, and obvious. A user who has never been to a gym should feel confident using this app.

## Tech Stack

- SwiftUI (iOS 17+ minimum deployment target)
- Supabase for auth (email/password sign up + login) and data storage (user profiles, workout plans, onboarding data, progress photos)
- OpenAI GPT-4o API for AI features (hardcode the API key for now as a constant in a Config file — this is dev only, I'll move it to a backend later). Use this placeholder: "sk-YOUR-KEY-HERE"
- Local image picker (PHPhotoPicker) for photo uploads
- SwiftData or UserDefaults for any lightweight local caching

## App Flow

### 1. Onboarding (follows the flowchart in the PDF)

The onboarding has a branching path — the user can upload a photo of themselves OR enter details manually.

**Screen 1 — Welcome**
- App name "Lethos" as hero text (italic accent on "Lethos")
- Tagline: "Your AI-powered physique coach"
- Subtitle: "Get your personalised workout plan in SECONDS"
- Single CTA: "Get Started"

**Screen 2 — "Tell us about you"**
Two options presented as large tappable cards:
1. **Upload a photo** (recommended) — "Best results" badge. Opens the photo picker. The AI will analyse the photo to determine their current build, weight estimate, and body composition.
2. **Enter manually** — "I'll fill in my details". Proceeds to the manual entry flow.

All tappable tabs/cards should have a GREEN GLOWY HUE animation when pressed. Change accent colours between tab selections with agreeable greens as per the styling guide.

**PATH A — Photo Upload (AI determines build)**
- User selects a photo of themselves
- Next screen: "Analysing..." with a loading animation
- AI analyses the photo and returns: estimated current build (from the build categories), confidence level (0-100%), estimated body composition
- If AI confidence >= 60%: show the result ("We think you're: Athletic") with a "That's right" CTA and a "Not quite — let me choose" secondary action
- If AI confidence < 60%: automatically show the manual build selection (Screen 3B) with the AI's best guess pre-selected

**PATH B — Manual Entry**
Collects the following across screens (one or two fields per screen to keep it simple):
- What's your weight? (kg)
- What's your height? (cm)
- What's your build? (Screen 3B — see below)
- What's your age?
- What's your gender? (M / F / PNTS — "Prefer not to say")

**Screen 3B — Current Build Selection**
Show these as tappable cards. The BOLD label is the main visible part of the card. If the user PRESSES AND HOLDS, the card expands to reveal the description underneath. This expand-on-hold behaviour only appears if either: (a) the user selected manual entry, or (b) the AI responded with confidence < 60%.

1. **Skinny** — (on hold expand): "I'm naturally thin and find it hard to gain weight"
2. **Average** — "I'm a pretty normal size, nothing extreme"
3. **Skinny Fat** — "I look slim in clothes but soft underneath"
4. **Overweight** — "I'm carrying extra weight I'd like to lose"
5. **Obese** — "I have a lot of weight to lose"
6. **Muscular but Out of Shape** — "I used to train but I've let it slip"

Selected state: green accent border with glowy hue + very dark green tinted background (#0D1F17). Unselected: subtle grey border (#2A2A2A) on dark surface (#1A1A1A).

**Screen 4 — Dietary Requirements**
Multi-select cards (user can pick multiple):
- No restrictions
- Vegan
- Vegetarian
- Peanut allergy
- Lactose intolerance
- Gluten free
- Other (free text field)

**Screen 5 — Upload Your Desired Physique**
- Headline: "Now show us your goal"
- Subtitle: "Upload a photo of the physique you want to achieve"
- Photo picker opens
- Next screen: "Analysing..." — sends image to OpenAI GPT-4o Vision for physique analysis
- IMPORTANT: The AI analysis call should ONLY fire if the user has paid (is_pro = true). If they haven't paid, store the image and defer the analysis until after payment. Show a message: "Your goal is saved — unlock your plan to see your AI analysis."

**Both paths converge → Paywall**

### 2. Paywall Screen

Styled to the Lethos design language. Show:

- Headline: "To see your full" then on the next line "PERSONALISED" (green accent, italic, bold) then "workout plan"
- Feature bullets:
  - Weekly check-ins with AI coaching
  - Personalised meal plan
  - Cancel anytime
- Pricing (stacked, monthly on top):
  - **£7.99/month** — standard card
  - **£80/year** — card below with a small green badge in the top right corner saying "SAVE £15"
- Primary CTA: "Start PRO" (green gradient button) — applies to whichever pricing option is selected
- "Restore Purchases" secondary action
- "Skip for now" tertiary underlined action

CRITICAL LOGIC: If the user pays (taps Start PRO), set is_pro = true in Supabase, THEN fire the AI prompts (physique analysis + workout plan generation). If the user skips, do NOT send any AI prompts. Store their data but don't call OpenAI. They see a locked state in the main app prompting them to upgrade.

For the MVP, don't implement actual StoreKit purchases yet — just wire up the navigation and the is_pro flag. Tapping "Start PRO" sets is_pro = true. Tapping "Skip" sets is_pro = false.

### 3. Main App (Tab Bar — 3 tabs)

**Tab 1 — Home / Dashboard**
- Greeting: "Hey [name or "there"]" with today's date
- If is_pro = false: show locked state — "Upgrade to PRO to unlock your personalised plan" with upgrade CTA
- If is_pro = true and no physique analysis yet: show "Analysing your goal..." loading state (the AI calls should be running)
- If workout plan exists: show today's workout summary card:
  - Session name (e.g. "Full Body A")
  - Number of exercises
  - Estimated duration
  - What muscles you'll train today and WHY (keep this simple — 1 sentence)
  - "Start Workout" button
- Below: "Your Goal" card showing the uploaded goal physique image thumbnail, the physique_summary text, and the percentage/estimated time to reach goal
- Below: Weekly completion tracker — how many planned workouts this week has the user actually done? Simple progress ring or bar.

**Tab 2 — Workout Plan**
Keep this SIMPLE. The user needs to see:
- What exercises to do
- What muscles they target and WHY (one sentence per exercise)
- How many sets and reps
- How long the session takes
- Starting weight suggestions

Show the full weekly schedule. Each day is a collapsible section (day label + session type as header). Expanding a day shows all exercises with: exercise name, sets × reps, target muscle, brief "why this exercise" note, and form tip. Rest days show the rest day recommendation.

If is_pro = false, show a blurred/locked version prompting upgrade.

**Tab 3 — Profile & Progress**
- User stats (height, weight, age, displayed from Supabase)
- Current body type and goal physique selections
- Goal physique image (tappable to re-upload)
- Progress photos section — shows historical weekly photos in a timeline/grid
- "Regenerate Plan" button (re-runs the AI workout plan generation, PRO only)
- Dietary requirements (editable)
- Subscription status
- Sign out button

### 4. AI Features

ALL AI CALLS ARE PRO-ONLY. Never send prompts to OpenAI if is_pro = false. Gate every API call behind this check.

**Feature 1 — Current Body Analysis (Photo Path Only)**
When the user uploads a photo of themselves during onboarding:
- Send to GPT-4o Vision
- System prompt: "You are a fitness AI that analyses a user's current physique from a photo. Determine their current build category from this list: skinny, average, skinny_fat, overweight, obese, muscular_but_out_of_shape. Also estimate their body fat percentage range and overall body composition. Return ONLY a JSON response with: build_category (string), confidence_percentage (integer 0-100), estimated_body_fat (range_low, range_high), notes (string — brief observation). If the image is unclear or not a body photo, return: {error: 'Unable to analyse', confidence_percentage: 0}. Return ONLY JSON."
- This call CAN run before payment (it's a quick, cheap call to improve onboarding UX). The expensive calls (physique analysis + plan generation) are PRO-only.

**Feature 2 — Goal Physique Analysis (PRO only)**
When the user uploads a goal physique image AND is_pro = true:
- Send the image to OpenAI GPT-4o Vision

System prompt: "You are a fitness AI that analyses physique reference images. Your job is to break down what you see into actionable training and nutrition data. Be specific, realistic, and honest. You will receive: 1. A reference image of the user's desired physique 2. The user's current body type 3. The user's basic stats (height, weight, age, gender). Analyse the reference image and return ONLY a JSON response with these fields: physique_summary (string — 1-2 sentences), estimated_body_fat_percentage (range_low, range_high), build_type (lean/toned/athletic/muscular/heavyweight), muscle_emphasis (primary array, secondary array, proportionality), definition_level (overall, visible_abs, vascularity, muscle_separation), frame (shoulder_width, v_taper, waist, limb_thickness), training_recommendation (style, priority_muscles array, training_split_suggestion, sessions_per_week), nutrition_recommendation (strategy, target_body_fat_percentage range, calorie_approach, protein_priority), realistic_timeline (from_current_body_type, estimated_months_minimum, estimated_months_maximum, phases array with phase_name/duration_weeks/focus, achievability, notes), percentage_difference_from_current (integer — estimated percentage difference between user's current state and this goal physique). Rules: Never assume the person in the image is the user. Be honest about achievability and PED use. Factor in the user's current body type for timelines. If the image is unclear, return an error JSON. Keep estimates conservative. Return ONLY JSON."

User message includes the image and: "Analyse this physique image. User's current body type: {bodyType}. User stats: {height}cm, {weight}kg, age {age}, {gender}"

**Feature 3 — Workout Plan Generator (PRO only)**
After physique analysis completes, automatically trigger:

System prompt: "You are a fitness AI that generates workout plans for ABSOLUTE BEGINNERS. These users have never set foot in a gym. They don't know what a rep is. They are likely nervous and overwhelmed. Your job is to create a precise, detailed, hand-holding workout plan that tells them EXACTLY what to do. Keep it SIMPLE — do NOT overcomplicate it. For each exercise tell them: what muscles it trains, why they need to do it (one simple sentence), how to do it, and what weight to start with. Every exercise must include step-by-step instructions, common mistakes, starting weight suggestions (with health disclaimer), and a YouTube search term for form demos. Return ONLY a JSON response with: health_disclaimer (string), plan_overview (plan_name, training_split, sessions_per_week, plan_duration_weeks, current_phase, rationale), weekly_schedule (array of day objects — each training day has: day number, day_label, session_name, estimated_duration_minutes, session_goal, warmup exercises, main exercises array, cooldown stretches. Each exercise has: order, exercise_name, equipment_needed, why_this_exercise (1 simple sentence), muscles_targeted (primary/secondary), how_to_do_it (setup string, movement steps array, common_mistakes array), sets, reps, rest_seconds, starting_weight_guide (male_beginner, female_beginner, disclaimer), video_search_term. Rest days have: description, activities array), weekly_structure_summary. Rules: Assume they know NOTHING. Max 5-6 exercises per session. Sessions 40-50 minutes max. Compound movements only. Never prescribe barbell squats/deadlifts/bench or pull-ups for beginners — use dumbbell and machine alternatives. Always include warmup and cooldown. Return ONLY JSON."

User message: "Generate a beginner workout plan. Physique Analysis: {physiqueAnalysisJSON}. User Stats: {height}cm, {weight}kg, age {age}, {gender}. Experience level: never_trained. Available training days: 3. Equipment: full_gym. Session time limit: 45 minutes. Dietary requirements: {dietaryRequirements}. Priority muscles: {priorityMusclesFromAnalysis}. This user has NEVER trained before. Keep it simple."

**Feature 4 — Weekly Check-in Coach (PRO only)**
This is triggered when the user submits a weekly check-in (progress photo + weight update).

System prompt: "You are a supportive fitness coach conducting a weekly check-in for an absolute beginner. You will receive: 1. The user's progress photo from THIS week 2. The user's progress photo from LAST week (if available) 3. The user's goal physique analysis 4. Their current workout plan 5. Their check-in data (weight, sessions completed, how they feel). Your job is to: Compare this week's photo to last week's photo and note specific visible changes or achievements. Be encouraging but honest. Calculate an estimated percentage progress toward their goal physique. Estimate remaining time to reach their goal. Suggest any plan adjustments if needed. Return ONLY a JSON response with: overall_assessment (excellent/good/okay/needs_attention), headline (one encouraging sentence referencing something specific), visible_changes (string — specific observations comparing this week to last week, e.g. 'Your shoulders look slightly broader and your midsection is tightening up'), wins (array of strings), areas_to_improve (array of strings), progress_percentage_toward_goal (integer), estimated_weeks_remaining (integer), weight_trend (losing/stable/gaining), training_compliance (sessions_completed vs sessions_planned), plan_adjustments (array of change objects or empty if no changes needed), motivation_message (personalised, references something specific from their data). Rules: Be ENCOURAGING. These are beginners — celebrate small wins. Never say they're failing. Compare photos carefully and note even subtle changes. If no photo from last week, compare to their starting body type description. Return ONLY JSON."

Include both the current and previous week's photos in the API call (as two images). User message: "Weekly check-in. Goal physique analysis: {goalAnalysisJSON}. Current plan: {planOverviewJSON}. This week's weight: {weight}kg. Last week's weight: {lastWeight}kg. Starting weight: {startWeight}kg. Sessions completed this week: {completed}/{planned}. Energy level (1-10): {energy}. How they feel: {userNotes}. Week number: {weekNumber}."

Store every check-in response and progress photo in Supabase so the user builds a historical timeline.

## Styling Guide

The app uses a pure black (#000000) background with no gradients or dark greys. All elevated surfaces and cards use #1A1A1A. The sole accent colour is green, ranging from #22C55E to #86EFAC for gradients and #34D399 for icons, checkmarks, and highlights. Primary text is white (#FFFFFF), secondary text is muted grey (#A0A0A0), and fine print uses a darker grey (#666666). The typeface is the system default (SF Pro). Headlines are bold (700 weight) at 34pt with a line height of 1.1, body text is regular (400 weight) at 17pt with a line height of 1.5, and button labels are bold at 18pt. Accent words within headlines use bold italic in the green accent colour. No thin font weights below 400.

Additional styling rules:
- Cards: #1A1A1A background, 16pt corner radius, 24pt internal padding
- Primary CTA buttons: full width, 56pt height, 16pt corner radius, linear gradient left-to-right #22C55E → #86EFAC, black bold text, green glow shadow beneath
- Selected cards: 1px #34D399 border, background tinted very dark green (#0D1F17), GREEN GLOWY HUE effect on press
- Unselected cards: 1px #2A2A2A border, #1A1A1A background
- Icon circles: 44pt, #166534 background, #34D399 icon colour
- Screen horizontal padding: 20pt
- Spacing between major sections: 32pt
- Tab bar: standard iOS tab bar, dark background, green accent for selected tab
- All tap targets minimum 44pt
- ALL tappable elements should have a subtle green glow animation on press (use a combination of scaleEffect and shadow with the accent green)
- Build selection cards: bold label visible by default, description hidden until long-press expands the card with a smooth animation

## Supabase Schema

Create these tables:

**profiles**
- id (uuid, references auth.users)
- email (text)
- height_cm (integer)
- weight_kg (float)
- age (integer)
- gender (text)
- current_body_type (text)
- goal_physique_type (text)
- training_days_per_week (integer, default 3)
- equipment_access (text, default "full_gym")
- dietary_requirements (text array)
- is_pro (boolean, default false)
- created_at (timestamp)
- updated_at (timestamp)

**physique_analyses**
- id (uuid, primary key)
- user_id (uuid, references profiles)
- goal_image_url (text — store the image in Supabase Storage)
- analysis_json (jsonb — the full GPT-4o response)
- percentage_difference (integer)
- created_at (timestamp)

**workout_plans**
- id (uuid, primary key)
- user_id (uuid, references profiles)
- physique_analysis_id (uuid, references physique_analyses)
- plan_json (jsonb — the full GPT-4o response)
- is_active (boolean, default true)
- created_at (timestamp)

**weekly_checkins**
- id (uuid, primary key)
- user_id (uuid, references profiles)
- week_number (integer)
- photo_url (text — store in Supabase Storage)
- weight_kg (float)
- sessions_completed (integer)
- sessions_planned (integer)
- energy_level (integer)
- user_notes (text)
- ai_response_json (jsonb — the full check-in coach response)
- progress_percentage (integer)
- created_at (timestamp)

**workout_completions**
- id (uuid, primary key)
- user_id (uuid, references profiles)
- workout_plan_id (uuid, references workout_plans)
- day_number (integer)
- completed_at (timestamp)

## Project Structure

Organise the Xcode project cleanly:
- /Lethos/App — App entry point, tab view
- /Lethos/Views/Onboarding — All onboarding screens (welcome, photo-or-manual choice, build selection, stats entry, dietary requirements, goal physique upload)
- /Lethos/Views/Paywall — Paywall screen
- /Lethos/Views/Home — Dashboard tab
- /Lethos/Views/WorkoutPlan — Workout plan tab
- /Lethos/Views/Profile — Profile tab, progress photos, check-ins
- /Lethos/Models — Data models (Profile, PhysiqueAnalysis, WorkoutPlan, WeeklyCheckin)
- /Lethos/Services — SupabaseService, OpenAIService
- /Lethos/Components — Reusable UI components (GlowCard, GradientButton, ExpandableCard, etc.)
- /Lethos/Theme — Colour definitions, typography, spacing constants
- /Lethos/Config — API keys and configuration

## Important Notes

- This is an MVP. Do NOT over-engineer. Get the flow working end to end.
- Keep it SIMPLE. Beginners should never feel overwhelmed.
- The OpenAI API key is hardcoded for dev — put it in Config.swift with a clear comment saying "MOVE TO BACKEND BEFORE RELEASE".
- For Supabase, create a SupabaseService singleton. Put the Supabase URL and anon key in Config.swift (placeholders are fine).
- AI CALLS ARE PRO-ONLY (except the initial body type analysis during onboarding which is a cheap call). Check is_pro before every expensive OpenAI call.
- The AI responses are large JSON blobs. Parse them into Swift structs using Codable. If parsing fails, show a user-friendly error and let them retry.
- Image upload: use PhotosPicker to select an image, compress it to JPEG, upload to Supabase Storage, then send the base64 to OpenAI.
- Show loading states during AI calls (10-30 seconds). Make the loading screen feel premium, not broken.
- The green glow effect on tappable elements is a key part of the brand — implement it as a reusable ViewModifier.
- Build selection cards use a press-and-hold to expand interaction — implement with a LongPressGesture that triggers a withAnimation expansion revealing the description text.
- Store progress photos in Supabase Storage and keep references in the weekly_checkins table. The app should build a visual timeline of the user's journey over weeks.
- Track workout completion — when a user taps "Complete Workout", log it to workout_completions so the dashboard can show weekly compliance (planned vs actual).

Build the complete project now. Start with the project structure and theme, then onboarding flow (with both paths), then Supabase integration, then paywall, then AI features, then the main app tabs.
```
