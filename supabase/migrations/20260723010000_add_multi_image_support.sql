CREATE TABLE public.post_images (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  post_id     BIGINT NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  image_path  TEXT NOT NULL,
  sort_order  INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX post_images_post_id_idx ON public.post_images (post_id);

ALTER TABLE public.post_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read for all"
  ON public.post_images FOR SELECT USING (true);

CREATE POLICY "Enable insert for owner"
  ON public.post_images FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.posts
      WHERE posts.id = post_id AND posts.user_id = auth.uid()
    )
  );

CREATE POLICY "Enable delete for owner"
  ON public.post_images FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.posts
      WHERE posts.id = post_id AND posts.user_id = auth.uid()
    )
  );

CREATE TABLE public.comment_images (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  comment_id  BIGINT NOT NULL REFERENCES public.comments(id) ON DELETE CASCADE,
  image_path  TEXT NOT NULL,
  sort_order  INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX comment_images_comment_id_idx ON public.comment_images (comment_id);

ALTER TABLE public.comment_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read for all"
  ON public.comment_images FOR SELECT USING (true);

CREATE POLICY "Enable insert for owner"
  ON public.comment_images FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.comments
      WHERE comments.id = comment_id AND comments.user_id = auth.uid()
    )
  );

CREATE POLICY "Enable delete for owner"
  ON public.comment_images FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.comments
      WHERE comments.id = comment_id AND comments.user_id = auth.uid()
    )
  );

INSERT INTO public.post_images (post_id, image_path, sort_order)
SELECT id, cover_image_path, 0 FROM public.posts WHERE cover_image_path IS NOT NULL;

INSERT INTO public.comment_images (comment_id, image_path, sort_order)
SELECT id, image_path, 0 FROM public.comments WHERE image_path IS NOT NULL;

ALTER TABLE public.posts DROP COLUMN cover_image_path;
ALTER TABLE public.comments DROP COLUMN image_path;
