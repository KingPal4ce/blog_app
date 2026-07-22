# The Journal

A Flutter blog/journaling web app backed by [Supabase](https://supabase.com/) (Postgres, Auth, and Storage). Users can sign up, write posts with a rich-text editor and cover images, browse a paginated feed, and comment on posts.

This project targets **web** as its primary platform (deployed on Vercel).

## Features

- **Auth** — email/password sign up and sign in via Supabase Auth, with a `public.users` profile row created on sign-up.
- **Feed** — paginated list of posts on the discover screen.
- **Posts** — create/edit posts with a [flutter_quill](https://pub.dev/packages/flutter_quill) rich-text editor, cover image upload, and delete/edit for the post owner.
- **Comments** — add comments (with optional image attachment) on a post's detail screen.
- **Storage** — cover images and comment attachments are stored in a public `post-images` Supabase Storage bucket, scoped per user with RLS.

## Tech stack

| Concern | Package |
|---|---|
| State management | `provider` (ChangeNotifier) |
| Routing | `go_router` |
| Backend | `supabase_flutter` (Postgres + Auth + Storage) |
| Env config | `flutter_dotenv` |
| Rich text editing | `flutter_quill` |
| Image picking | `image_picker` |
| JSON models | `json_serializable` / `build_runner` |

Flutter SDK is pinned via [FVM](https://fvm.app/) — see `.fvmrc` (`3.44.6`). Dart SDK constraint: `^3.12.2`.

## Project structure

```
lib/
├── main.dart          # Entry point: loads .env, initializes Supabase, boots the app
├── app/               # App shell, theming, and go_router route table
├── models/            # Post, Comment, UserProfile (json_serializable)
├── services/          # Supabase data-access layer (auth, posts, comments)
├── providers/         # ChangeNotifier state consumed by the UI
├── screens/           # auth, feed (discover), post detail, create/edit post
├── widgets/           # Reusable UI (post card, comment tile, avatar, pagination)
└── utils/             # Date formatting, avatar initials helpers

supabase/
└── migrations/        # SQL migrations for users, posts, comments, and storage bucket
```

## Getting started

### Prerequisites

- [FVM](https://fvm.app/) (this repo pins Flutter `3.44.6` via `.fvmrc`)
- A [Supabase](https://supabase.com/) project

### Setup

1. Install the pinned Flutter version and fetch dependencies:

   ```
   make version
   make pubs
   ```

2. Create a `.env` file in the project root with your Supabase credentials:

   ```
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

   `.env` is git-ignored and is bundled as a Flutter asset, so it must exist locally (and in CI/deploy environments) for the app to run.

3. Apply the database schema. Migrations live in `supabase/migrations/` and set up the `users`, `posts`, and `comments` tables (with RLS) plus the `post-images` storage bucket. Apply them with the [Supabase CLI](https://supabase.com/docs/guides/cli):

   ```
   supabase link --project-ref your-project-ref
   supabase db push
   ```

4. Run the app (web is the primary target):

   ```
   fvm flutter run -d chrome
   ```

### Useful Makefile targets

| Command | Description |
|---|---|
| `make version` | Switch to the pinned Flutter SDK via FVM |
| `make pubs` | `flutter pub get` |
| `make models` | Regenerate `*.g.dart` files via `build_runner` |
| `make format` | Format `lib/` and `test/` (150 char line length) |
| `make lint` | `flutter analyze` |
| `make quality` | Format + lint |
| `make rebuild` | version → pubs → models → quality |

Git hooks (pre-commit/pre-push) live in `.githooks/`; enable them with:

```
git config core.hooksPath .githooks
```

## Deployment

The app is deployed as a Flutter web build on [Vercel](https://vercel.com/). `vercel.json` rewrites all routes to `/index.html` so client-side routing (`go_router`) works correctly. Remember to configure `SUPABASE_URL` / `SUPABASE_ANON_KEY` for the deployed environment (the `.env` file used by `flutter_dotenv`).
