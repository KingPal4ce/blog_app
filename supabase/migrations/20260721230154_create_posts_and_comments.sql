CREATE TABLE public.posts (
  id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id          UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title            TEXT NOT NULL,
  body             JSONB NOT NULL,
  cover_image_path TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX posts_created_at_idx ON public.posts (created_at DESC);
CREATE INDEX posts_user_id_idx ON public.posts (user_id);

ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read for all"
  ON public.posts FOR SELECT USING (true);

CREATE POLICY "Enable insert for owner"
  ON public.posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable update for owner"
  ON public.posts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable delete for owner"
  ON public.posts FOR DELETE
  USING (auth.uid() = user_id);

CREATE TABLE public.comments (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  post_id     BIGINT NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  body        TEXT NOT NULL,
  image_path  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX comments_post_id_idx ON public.comments (post_id);
CREATE INDEX comments_created_at_idx ON public.comments (created_at);

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read for all"
  ON public.comments FOR SELECT USING (true);

CREATE POLICY "Enable insert for owner"
  ON public.comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable update for owner"
  ON public.comments FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable delete for owner"
  ON public.comments FOR DELETE
  USING (auth.uid() = user_id);

CREATE POLICY "Enable read for all"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'post-images');

CREATE POLICY "Enable insert for authenticated users"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'post-images' AND auth.role() = 'authenticated');

CREATE POLICY "Enable update for owner"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'post-images' AND owner_id = auth.uid()::text)
  WITH CHECK (bucket_id = 'post-images' AND owner_id = auth.uid()::text);

CREATE POLICY "Enable delete for owner"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'post-images' AND owner_id = auth.uid()::text);
